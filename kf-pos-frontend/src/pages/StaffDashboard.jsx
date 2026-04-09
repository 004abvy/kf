import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import io from 'socket.io-client'; 

// Connect to WebSocket Server
const socket = io('http://localhost:3000');

const StaffDashboard = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isAudioEnabled, setIsAudioEnabled] = useState(false);
  const [now, setNow] = useState(Date.now()); 
  const [activeFilter, setActiveFilter] = useState('All'); 
  
  // 🔥 Theme Toggle State (Remembers user preference)
  const [isDarkMode, setIsDarkMode] = useState(() => {
    const savedTheme = localStorage.getItem('kds_theme');
    return savedTheme ? savedTheme === 'dark' : true; // Defaults to Dark Mode
  });

  // Rejection Modal States
  const [rejectingOrder, setRejectingOrder] = useState(null);
  const [rejectReason, setRejectReason] = useState('Out of Stock');
  const [customReason, setCustomReason] = useState('');

  const audioEnabledRef = useRef(false);

  // Save theme preference whenever it changes
  useEffect(() => {
    localStorage.setItem('kds_theme', isDarkMode ? 'dark' : 'light');
  }, [isDarkMode]);

  const playNotification = () => {
    if (!audioEnabledRef.current) return;
    const audio = new Audio('/sounds/notification.mp3'); 
    audio.volume = 0.5;
    audio.play().catch(err => console.log("Audio play blocked:", err));
  };

  const fetchOrders = async () => {
    try {
      const res = await fetch('http://localhost:3000/api/staff/orders', { cache: 'no-store' });
      const data = await res.json();
      
      // Force strict First-In, First-Out (Oldest orders first)
      const sortedOrders = data.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
      
      setOrders(sortedOrders);
      setLoading(false);
    } catch (err) {
      console.error("Fetch error:", err);
      setLoading(false);
    }
  };

  // ── SET UP WEBSOCKET & LIVE TIMER ──
  useEffect(() => {
    fetchOrders(); 

    socket.on('new_order', () => {
      playNotification(); 
      fetchOrders();      
    });

    socket.on('order_updated', () => {
      fetchOrders();
    });

    // This makes the timers tick down every second
    const ticker = setInterval(() => setNow(Date.now()), 1000);

    return () => {
      socket.off('new_order');
      socket.off('order_updated');
      clearInterval(ticker);
    };
  }, []);

  const updateStatus = async (orderId, newStatus, newPaymentStatus = null, reason = null) => {
    try {
      const payload = { orderId, newStatus, newPaymentStatus };
      if (reason) payload.rejectionReason = reason;

      await fetch('http://localhost:3000/api/staff/update-status', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      
      setRejectingOrder(null);
      setCustomReason('');
    } catch (err) { console.error("Update error:", err); }
  };

  const handleConfirmReject = () => {
    const finalReason = rejectReason === 'Other' ? customReason : rejectReason;
    if (!finalReason.trim()) return alert("Please provide a reason");
    updateStatus(rejectingOrder.order_id, 'Rejected', null, finalReason);
  };

  const startSession = () => {
    setIsAudioEnabled(true);
    audioEnabledRef.current = true;
    const audio = new Audio('/sounds/notification.mp3');
    audio.volume = 0; 
    audio.play().catch(() => {});
  };

  const toggleMute = () => {
    const newState = !isAudioEnabled;
    setIsAudioEnabled(newState);
    audioEnabledRef.current = newState;
  };

  const filteredOrders = orders.filter(order => 
    activeFilter === 'All' ? true : order.status === activeFilter
  );

  // Helper for dynamic status pill colors based on Light/Dark Mode
  const getStatusStyles = (status) => {
    if (isDarkMode) {
      switch(status) {
        case 'Pending': return 'bg-yellow-500/10 text-yellow-400 border border-yellow-500/20';
        case 'Preparing': return 'bg-orange-500/10 text-orange-400 border border-orange-500/20';
        case 'On the Way': return 'bg-blue-500/10 text-blue-400 border border-blue-500/20';
        default: return 'bg-zinc-800 text-zinc-300 border border-zinc-700';
      }
    } else {
      switch(status) {
        case 'Pending': return 'bg-yellow-100 text-yellow-800 border border-yellow-200';
        case 'Preparing': return 'bg-orange-100 text-orange-800 border border-orange-200';
        case 'On the Way': return 'bg-blue-100 text-blue-800 border border-blue-200';
        default: return 'bg-gray-100 text-gray-800 border border-gray-200';
      }
    }
  };

  return (
    <div className={`min-h-screen pt-12 lg:pt-16 p-4 md:p-8 relative w-full overflow-x-hidden font-sans transition-colors duration-500 ${isDarkMode ? 'bg-[#09090b] text-zinc-100' : 'bg-gray-100 text-gray-900'}`}>
      
      {/* ── AUDIO UNLOCK OVERLAY ── */}
      <AnimatePresence>
        {!isAudioEnabled && orders.length === 0 && (
          <motion.div 
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className={`fixed inset-0 z-[200] backdrop-blur-md flex items-center justify-center text-center p-6 ${isDarkMode ? 'bg-black/90' : 'bg-white/90'}`}
          >
            <div className="max-w-sm">
              <div className="text-6xl mb-6">🔔</div>
              <h2 className={`text-3xl font-black uppercase mb-4 tracking-tight ${isDarkMode ? 'text-white' : 'text-black'}`}>Ready for Service?</h2>
              <p className={`text-sm font-bold uppercase mb-8 leading-relaxed ${isDarkMode ? 'text-zinc-400' : 'text-gray-500'}`}>
                Click below to enable live WebSocket sound alerts and start the kitchen session.
              </p>
              <button onClick={startSession} className="w-full bg-[#e0457b] text-white py-5 rounded-2xl font-black uppercase tracking-widest hover:bg-[#c93c6d] transition-all shadow-[0_0_40px_rgba(224,69,123,0.3)]">
                Start Session
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ── REJECTION MODAL ── */}
      <AnimatePresence>
        {rejectingOrder && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 lg:p-6">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={() => setRejectingOrder(null)} className={`absolute inset-0 backdrop-blur-md ${isDarkMode ? 'bg-black/80' : 'bg-black/40'}`} />
            <motion.div initial={{ scale: 0.9, y: 20 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.9, y: 20 }} className={`relative w-full max-w-md rounded-2xl lg:rounded-[2rem] p-6 lg:p-8 shadow-2xl border-t-8 border-t-red-500 flex flex-col max-h-[90vh] ${isDarkMode ? 'bg-zinc-900 border border-zinc-800' : 'bg-white border border-gray-200'}`}>
              <h2 className={`text-xl lg:text-3xl font-black uppercase mb-2 ${isDarkMode ? 'text-white' : 'text-black'}`}>Reject Order</h2>
              <p className={`text-sm lg:text-base font-bold mb-4 lg:mb-6 ${isDarkMode ? 'text-zinc-400' : 'text-gray-500'}`}>Select a reason to notify the customer.</p>

              <div className="space-y-2 lg:space-y-3 mb-6 lg:mb-8 overflow-y-auto no-scrollbar">
                {['Out of Stock', 'Kitchen Too Busy', 'Outside Delivery Zone', 'Other'].map(reason => (
                  <label key={reason} className={`flex items-center gap-3 p-3 lg:p-5 rounded-xl border cursor-pointer transition-all ${
                    rejectReason === reason 
                      ? (isDarkMode ? 'border-red-500/50 bg-red-500/10' : 'border-red-500 bg-red-50') 
                      : (isDarkMode ? 'border-zinc-800 bg-zinc-950 hover:border-zinc-700' : 'border-gray-200 bg-gray-50 hover:border-gray-300')
                  }`}>
                    <input type="radio" name="reason" value={reason} checked={rejectReason === reason} onChange={(e) => setRejectReason(e.target.value)} className="hidden" />
                    <div className={`w-4 h-4 lg:w-5 lg:h-5 rounded-full border-2 flex items-center justify-center ${rejectReason === reason ? 'border-red-500' : (isDarkMode ? 'border-zinc-700' : 'border-gray-300')}`}>
                      {rejectReason === reason && <div className="w-2 h-2 lg:w-2.5 lg:h-2.5 rounded-full bg-red-500" />}
                    </div>
                    <span className={`font-bold uppercase tracking-wide text-xs lg:text-base ${isDarkMode ? 'text-zinc-200' : 'text-gray-800'}`}>{reason}</span>
                  </label>
                ))}

                <AnimatePresence>
                  {rejectReason === 'Other' && (
                    <motion.input 
                      initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }}
                      type="text" placeholder="Type reason here..." value={customReason} onChange={(e) => setCustomReason(e.target.value)}
                      className={`w-full p-3 lg:p-5 rounded-xl outline-none focus:border-red-500 transition-colors font-bold mt-2 text-sm lg:text-lg ${isDarkMode ? 'bg-zinc-950 border border-zinc-800 text-white placeholder-zinc-600' : 'bg-white border border-gray-300 text-black placeholder-gray-400'}`}
                      autoFocus
                    />
                  )}
                </AnimatePresence>
              </div>

              <div className="flex gap-2 lg:gap-4 mt-auto">
                <button onClick={() => setRejectingOrder(null)} className={`flex-1 py-3 lg:py-5 rounded-xl font-black uppercase text-xs lg:text-sm transition-colors ${isDarkMode ? 'text-zinc-400 bg-zinc-800 hover:bg-zinc-700' : 'text-gray-600 bg-gray-200 hover:bg-gray-300'}`}>Cancel</button>
                <button onClick={handleConfirmReject} className="flex-1 py-3 lg:py-5 rounded-xl font-black uppercase text-xs lg:text-sm text-white bg-red-600 hover:bg-red-700 transition-colors shadow-lg">Confirm</button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* ── HEADER & FILTERS ── */}
      <div className="flex flex-col mb-6 lg:mb-10 gap-4 lg:gap-6">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div>
            <h1 className={`text-3xl sm:text-4xl lg:text-5xl font-black tracking-tighter uppercase leading-none ${isDarkMode ? 'text-white' : 'text-black'}`}>KDS Board</h1>
            <div className="flex items-center gap-2 mt-2 lg:mt-3">
              <span className="w-2 h-2 lg:w-3 lg:h-3 bg-green-500 rounded-full animate-ping"></span>
              <p className="text-[10px] lg:text-xs font-black text-green-500 uppercase tracking-widest">Live Sync Active</p>
            </div>
          </div>
          
          <div className="flex flex-wrap gap-2 lg:gap-4 items-center">
              <div className="hidden sm:flex flex-col items-end mr-2 lg:mr-4">
                <span className={`text-[10px] lg:text-xs uppercase font-black tracking-widest ${isDarkMode ? 'text-zinc-500' : 'text-gray-400'}`}>Avg Prep</span>
                <span className="text-sm lg:text-xl font-mono font-black text-[#e0457b]">14m</span>
              </div>
              
              {/* 🔥 THEME TOGGLE BUTTON 🔥 */}
              <button 
                onClick={() => setIsDarkMode(!isDarkMode)} 
                className={`px-3 py-2 lg:px-5 lg:py-3 rounded-full text-[10px] lg:text-sm font-black uppercase flex items-center transition-all border shadow-sm ${isDarkMode ? 'bg-zinc-800 border-zinc-700 text-zinc-300 hover:bg-zinc-700' : 'bg-white border-gray-200 text-gray-600 hover:bg-gray-50'}`}
              >
                {isDarkMode ? '☀️ Light' : '🌙 Dark'}
              </button>

              {/* Mute Button */}
              <button 
                onClick={toggleMute} 
                className={`px-3 py-2 lg:px-5 lg:py-3 rounded-full text-[10px] lg:text-sm font-black uppercase flex items-center transition-all border shadow-sm ${
                  isAudioEnabled 
                    ? (isDarkMode ? 'bg-zinc-800 border-zinc-700 text-white hover:bg-zinc-700' : 'bg-white border-gray-200 text-black hover:bg-gray-50')
                    : (isDarkMode ? 'bg-red-500/10 border-red-500/50 text-red-400 hover:bg-red-500/20' : 'bg-red-50 border-red-200 text-red-500 hover:bg-red-100')
                }`}
              >
                {isAudioEnabled ? '🔊 Alerts On' : '🔇 Muted'}
              </button>
          </div>
        </div>

        {/* ── TAB FILTERS ── */}
        <div className="flex gap-1.5 overflow-x-auto no-scrollbar pb-2 -mx-4 px-4 md:mx-0 md:px-0">
          {['All', 'Pending', 'Preparing', 'On the Way'].map(tab => (
            <button 
              key={tab}
              onClick={() => setActiveFilter(tab)}
              className={`whitespace-nowrap px-4 py-2 lg:px-6 lg:py-2.5 rounded-full text-[10px] lg:text-xs font-black uppercase tracking-widest transition-all border-2 ${
                activeFilter === tab 
                  ? 'bg-[#e0457b] text-white border-[#e0457b] shadow-[0_0_15px_rgba(224,69,123,0.3)]' 
                  : (isDarkMode ? 'bg-zinc-900 text-zinc-500 border-zinc-800 hover:border-zinc-700 hover:text-zinc-300' : 'bg-white text-gray-500 border-gray-200 hover:border-gray-300 hover:text-gray-800')
              }`}
            >
              {tab} 
              {tab !== 'All' && (
                <span className={`ml-2 px-1.5 py-0.5 rounded text-[8px] lg:text-[10px] ${
                  activeFilter === tab 
                    ? 'bg-white text-[#e0457b]' 
                    : (isDarkMode ? 'bg-zinc-800 text-zinc-400' : 'bg-gray-100 text-gray-500')
                }`}>
                  {orders.filter(o => o.status === tab).length}
                </span>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* ── SCROLLABLE GRID ── */}
      <div className="w-full overflow-x-auto no-scrollbar pb-6 -mx-4 px-4 md:mx-0 md:px-0">
        <div className="grid grid-cols-2 lg:grid-cols-3 gap-3 lg:gap-6 min-w-[380px] lg:min-w-0">
          {loading && (
            <div className="col-span-full text-center py-20">
              <div className="inline-block">
                <div className={`w-10 h-10 lg:w-16 lg:h-16 border-4 border-t-[#e0457b] rounded-full animate-spin mb-4 mx-auto ${isDarkMode ? 'border-zinc-700' : 'border-gray-200'}`}></div>
                <p className={`font-bold uppercase tracking-widest text-xs lg:text-lg ${isDarkMode ? 'text-zinc-500' : 'text-gray-400'}`}>Loading orders...</p>
              </div>
            </div>
          )}
          {!loading && filteredOrders.map((order) => {
            
            // 👇 LIVE TIMER MATH & PROGRESS BAR 👇
            const orderTime = new Date(order.created_at).getTime();
            const targetTime = orderTime + (45 * 60 * 1000); 
            const timeDiff = targetTime - now; 
            const isOverdue = timeDiff <= 0;
            const isWarning = timeDiff > 0 && timeDiff <= (22.5 * 60 * 1000); 

            const totalDuration = 45 * 60 * 1000;
            const elapsedTime = totalDuration - timeDiff;
            const progressPercent = Math.max(0, Math.min(100, (elapsedTime / totalDuration) * 100));

            const absDiff = Math.abs(timeDiff);
            const diffMins = Math.floor(absDiff / (1000 * 60));
            const diffSecs = Math.floor((absDiff % (1000 * 60)) / 1000);
            const timeString = `${diffMins}m ${diffSecs}s`;

            // Dynamic Colors based on Theme & Timer
            let timerColor = isDarkMode ? "text-emerald-400" : "text-green-600";
            let barColor = isDarkMode ? "bg-emerald-500 shadow-[0_0_10px_rgba(16,185,129,0.5)]" : "bg-green-500";
            
            if (isOverdue) {
              timerColor = isDarkMode ? "text-red-500 animate-pulse" : "text-red-600 animate-pulse";
              barColor = isDarkMode ? "bg-red-500 shadow-[0_0_10px_rgba(239,68,68,0.8)]" : "bg-red-500 shadow-[0_0_5px_rgba(239,68,68,0.4)]";
            } else if (isWarning) {
              timerColor = isDarkMode ? "text-yellow-400" : "text-yellow-600";
              barColor = isDarkMode ? "bg-yellow-400 shadow-[0_0_10px_rgba(250,204,21,0.5)]" : "bg-yellow-400";
            }

            return (
            <motion.div layout key={order.order_id} className={`rounded-xl lg:rounded-[1.5rem] p-3 lg:p-5 shadow-2xl flex flex-col h-[360px] lg:h-auto lg:min-h-[400px] ${isDarkMode ? 'bg-zinc-900 border border-zinc-800' : 'bg-white border border-gray-200'}`}>
              
              {/* Header section of card */}
              <div className="flex flex-row justify-between items-start mb-2 lg:mb-4 gap-2">
                <div className="min-w-0">
                  <p className={`text-[8px] lg:text-xs font-black uppercase tracking-widest mb-0.5 ${isDarkMode ? 'text-zinc-500' : 'text-gray-400'}`}>Order</p>
                  <h3 className={`text-[15px] sm:text-lg lg:text-2xl font-mono font-black truncate ${isDarkMode ? 'text-white' : 'text-black'}`}>#{order.order_number.slice(-6)}</h3>
                  <p className={`text-[8px] lg:text-[10px] font-bold uppercase tracking-widest mt-0.5 ${isDarkMode ? 'text-zinc-500' : 'text-gray-400'}`}>
                    {new Date(order.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                  </p>
                </div>
                
                <div className="flex flex-col items-end flex-shrink-0 w-20 lg:w-32">
                  <span className={`px-2 py-1 lg:px-3 lg:py-1.5 rounded-md text-[8px] lg:text-[10px] font-black uppercase tracking-widest text-center w-full mb-1.5 ${getStatusStyles(order.status)}`}>
                    {order.status}
                  </span>

                  {/* Timer & Progress Bar */}
                  <div className="w-full flex flex-col items-end">
                    <span className={`text-[10px] lg:text-sm font-black font-mono tracking-tighter ${timerColor}`}>
                      {isOverdue ? `-${timeString}` : timeString}
                    </span>
                    <div className={`w-full h-1 lg:h-1.5 rounded-full mt-1 overflow-visible relative ${isDarkMode ? 'bg-zinc-950' : 'bg-gray-100'}`}>
                      <div className={`h-full rounded-full transition-all duration-1000 ${barColor}`} style={{ width: `${progressPercent}%` }} />
                    </div>
                  </div>
                </div>
              </div>

              {/* CUSTOMER & SPECIAL NOTES BLOCK */}
              <div className="flex flex-col gap-1.5 mb-2 lg:mb-4 flex-shrink-0">
                <div className={`rounded-lg p-2 lg:p-3 border ${isDarkMode ? 'bg-zinc-950/50 border-zinc-800' : 'bg-gray-50 border-gray-100'}`}>
                  <p className={`text-[9px] lg:text-xs font-bold flex items-center gap-1.5 truncate ${isDarkMode ? 'text-zinc-300' : 'text-black'}`}>
                    <span className="text-[10px] lg:text-sm">📞</span> {order.customer_phone || 'No Phone'}
                  </p>
                  <p className={`text-[9px] lg:text-xs font-bold capitalize leading-tight flex items-start gap-1.5 mt-1 line-clamp-1 lg:line-clamp-2 ${isDarkMode ? 'text-zinc-500' : 'text-gray-600'}`}>
                    <span className="text-[10px] lg:text-sm">📍</span> {order.delivery_address ? order.delivery_address : 'Takeaway'}
                  </p>
                </div>
                
                {/* High Visibility Special Instructions Alert */}
                {order.special_instructions && (
                  <div className={`rounded-lg p-2 animate-pulse border ${isDarkMode ? 'bg-red-500/10 border-red-500/30 text-red-400' : 'bg-red-50 border-red-200 text-red-600'}`}>
                    <p className="text-[8px] lg:text-[10px] font-black uppercase tracking-widest mb-0.5">⚠️ Special Notes:</p>
                    <p className="text-[9px] lg:text-xs font-bold uppercase leading-tight line-clamp-2">{order.special_instructions}</p>
                  </div>
                )}
              </div>

              {/* ORDER ITEMS (Receipt Style) */}
              <div className={`border border-dashed rounded-lg p-2 lg:p-4 mb-2 lg:mb-4 flex-1 overflow-y-auto no-scrollbar relative shadow-inner ${isDarkMode ? 'bg-zinc-950 border-zinc-800' : 'bg-[#fdfbf7] border-gray-300'}`}>
                <div className={`absolute top-0 left-0 w-full h-4 bg-gradient-to-b z-10 pointer-events-none ${isDarkMode ? 'from-zinc-950 to-transparent' : 'from-[#fdfbf7] to-transparent'}`} />
                <div className="space-y-2 lg:space-y-3 pt-1">
                  {order.items.map((item, i) => (
                    <div key={i} className={`flex flex-col border-b pb-2 last:border-0 last:pb-0 ${isDarkMode ? 'border-zinc-900' : 'border-gray-200'}`}>
                      <div className="flex items-start gap-2">
                        <span className="text-[10px] lg:text-sm font-black text-[#e0457b] bg-[#e0457b]/10 px-1.5 py-0.5 rounded leading-none border border-[#e0457b]/20">
                          {item.quantity}x
                        </span>
                        <span className={`text-[10px] lg:text-sm font-black uppercase leading-tight mt-0.5 ${isDarkMode ? 'text-zinc-200' : 'text-gray-900'}`}>
                          {item.item_name}
                        </span>
                      </div>
                      {item.size_name && (
                        <span className={`text-[8px] lg:text-[10px] font-bold uppercase tracking-widest ml-7 lg:ml-9 mt-1 block ${isDarkMode ? 'text-zinc-500' : 'text-gray-500'}`}>
                          Size: {item.size_name}
                        </span>
                      )}
                    </div>
                  ))}
                </div>
                <div className={`absolute bottom-0 left-0 w-full h-4 bg-gradient-to-t z-10 pointer-events-none ${isDarkMode ? 'from-zinc-950 to-transparent' : 'from-[#fdfbf7] to-transparent'}`} />
              </div>

              {/* ACTION BUTTONS (Bump/Dispatch) */}
              <div className="flex flex-row gap-1.5 lg:gap-2 mt-auto pt-1 flex-shrink-0">
                {order.status === 'Pending' && order.payment_method === 'wallet' && order.payment_status === 'Pending Verification' && (
                  <>
                    <button onClick={() => updateStatus(order.order_id, 'Preparing', 'Paid')} className="flex-1 bg-emerald-600 text-white py-2.5 lg:py-3.5 rounded-lg font-black text-[8px] lg:text-xs uppercase hover:bg-emerald-500 transition-transform active:scale-95 shadow-md">Verify & Bump</button>
                    <button onClick={() => setRejectingOrder(order)} className={`px-2 lg:px-4 py-2.5 lg:py-3.5 rounded-lg font-black text-[8px] lg:text-xs uppercase hover:bg-red-600 hover:text-white transition-all border ${isDarkMode ? 'bg-zinc-800 text-zinc-400 border-zinc-700' : 'bg-gray-200 text-gray-600 border-gray-300'}`}>Reject</button>
                  </>
                )}

                {order.status === 'Pending' && order.payment_method === 'cod' && (
                  <>
                    <button onClick={() => updateStatus(order.order_id, 'Preparing', null)} className="flex-1 bg-orange-600 text-white py-2.5 lg:py-3.5 rounded-lg font-black text-[8px] lg:text-xs uppercase hover:bg-orange-500 transition-transform active:scale-95 shadow-md">Bump to Prep</button>
                    <button onClick={() => setRejectingOrder(order)} className={`px-2 lg:px-4 py-2.5 lg:py-3.5 rounded-lg font-black text-[8px] lg:text-xs uppercase hover:bg-red-600 hover:text-white transition-all border ${isDarkMode ? 'bg-zinc-800 text-zinc-400 border-zinc-700' : 'bg-gray-200 text-gray-600 border-gray-300'}`}>Reject</button>
                  </>
                )}

                {order.status === 'Preparing' && (
                  <button onClick={() => updateStatus(order.order_id, 'On the Way', null)} className="flex-1 bg-blue-600 text-white py-2.5 lg:py-3.5 rounded-lg font-black text-[8px] lg:text-xs uppercase hover:bg-blue-500 transition-transform active:scale-95 shadow-md">Dispatch Order</button>
                )}

                {order.status === 'On the Way' && (
                  <button onClick={() => updateStatus(order.order_id, 'Completed', order.payment_method === 'cod' ? 'Paid' : null)} className={`flex-1 py-2.5 lg:py-3.5 rounded-lg font-black text-[8px] lg:text-xs uppercase transition-transform active:scale-95 shadow-md border ${isDarkMode ? 'bg-zinc-800 text-zinc-300 border-zinc-700 hover:bg-zinc-700 hover:text-white' : 'bg-black text-white border-black hover:bg-gray-800'}`}>Complete & Clear</button>
                )}
              </div>
            </motion.div>
            );
          })}
        </div>
      </div>
      
      {filteredOrders.length === 0 && !loading && (
        <div className={`text-center py-16 lg:py-32 rounded-3xl lg:rounded-[3rem] mt-4 lg:mt-8 border ${isDarkMode ? 'bg-zinc-900/50 border-zinc-800/50' : 'bg-white border-gray-200 shadow-sm'}`}>
          <div className="text-4xl lg:text-6xl mb-4 opacity-20 filter grayscale">🔪</div>
          <p className={`font-black uppercase tracking-widest text-sm lg:text-xl px-4 ${isDarkMode ? 'text-zinc-500' : 'text-gray-400'}`}>No {activeFilter === 'All' ? 'active' : activeFilter} orders. Board is clear.</p>
        </div>
      )}
    </div>
  );
};

// Global styles for scrollbar hiding
const globalStyles = `
  .no-scrollbar::-webkit-scrollbar { display: none; }
  .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
`;
if (typeof document !== 'undefined') {
  const style = document.createElement('style');
  style.textContent = globalStyles;
  document.head.appendChild(style);
}

export default StaffDashboard;