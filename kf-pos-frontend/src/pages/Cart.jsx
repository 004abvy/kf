import React, { useState, useEffect } from 'react';

const API_URL = import.meta.env.VITE_API_URL;
import { motion, AnimatePresence } from 'framer-motion';
import { Link, useNavigate } from 'react-router-dom';
import { useCart } from '../context/CartContext';

const Cart = () => {
  const { cartItems, updateQuantity, removeFromCart, addToCart, subtotal, totalItems, clearCart } = useCart();
  const navigate = useNavigate();
  
  const [paymentTab, setPaymentTab] = useState('cod'); 
  const [isPaying, setIsPaying] = useState(false);
  const [phone, setPhone] = useState(localStorage.getItem('kf_phone') || ''); 
  const [specificAddress, setSpecificAddress] = useState(localStorage.getItem('kf_address') || '');
  const [selectedLocation, setSelectedLocation] = useState(JSON.parse(localStorage.getItem('kf_location')) || null);
  const [locations, setLocations] = useState([]);
  const [showAddressModal, setShowAddressModal] = useState(false);
  const [rating, setRating] = useState(0);

  const [currentOrder, setCurrentOrder] = useState(() => {
    const saved = localStorage.getItem('last_order');
    return saved ? JSON.parse(saved) : null;
  });

  const deliveryFee = selectedLocation ? selectedLocation.delivery_fee : 0;
  const finalTotal = subtotal + deliveryFee;

  useEffect(() => {
    const fetchLocations = async () => {
      try {
        const res = await fetch(`${API_URL}/api/locations`); 
        const data = await res.json();
        const uniqueLocations = Array.from(
          new Map(data.map((loc) => [loc.area_name, loc])).values(),
        );
        setLocations(uniqueLocations);
      } catch (err) {
        console.error("Failed to fetch locations:", err);
      }
    };
    fetchLocations();
  }, []);

  useEffect(() => {
    const syncStatus = async () => {
      if (!currentOrder) return;
      if (currentOrder.status === 'Completed' || currentOrder.status === 'Rejected') return;
      try {
        const res = await fetch(`${API_URL}/api/orders/status/${currentOrder.orderNumber}`, { cache: 'no-store' });
        const data = await res.json();
        if (data.status && data.status !== currentOrder.status) {
          const updatedOrder = { 
            ...currentOrder, 
            status: data.status,
            rejection_reason: data.rejection_reason 
          };
          localStorage.setItem('last_order', JSON.stringify(updatedOrder));
          setCurrentOrder(updatedOrder);
        }
      } catch (err) { console.error("Status sync failed"); }
    };
    syncStatus();
    const interval = setInterval(syncStatus, 5000);
    return () => clearInterval(interval);
  }, [currentOrder]);

  const handleCheckout = async () => {
    if (cartItems.length === 0) return alert("Your cart is empty.");
    if (!selectedLocation || !specificAddress.trim()) return alert("Please provide a complete delivery address.");
    if (phone.length < 11) return alert("Please enter a valid 11-digit phone number (e.g., 03XXXXXXXXX).");
    
    setIsPaying(true);
    localStorage.setItem('kf_phone', phone);
    localStorage.setItem('kf_address', specificAddress);
    localStorage.setItem('kf_location', JSON.stringify(selectedLocation));

    try {
      const response = await fetch(`${API_URL}/api/checkout`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          items: cartItems,
          subtotal: subtotal,
          deliveryFee: deliveryFee,
          total: finalTotal,
          method: paymentTab,
          customerPhone: phone,
          deliveryAddress: `${specificAddress}, ${selectedLocation.area_name}`
        }),
      });
      
      const data = await response.json();
      if (data.success) {
        const newOrder = {
          orderNumber: data.orderNumber, 
          items: [...cartItems], 
          total: finalTotal, 
          method: paymentTab, 
          status: 'Pending', 
          rejection_reason: null
        };
        localStorage.setItem('last_order', JSON.stringify(newOrder));
        setCurrentOrder(newOrder);
        clearCart(); 
        navigate('/success', { state: { orderNumber: data.orderNumber, method: paymentTab } });
      } else {
        alert(data.message || "Checkout failed. Please try again.");
      }
    } catch (error) { 
      alert("Checkout failed. Please check your connection and try again."); 
    } finally { 
      setIsPaying(false); 
    }
  };

  const handleFinishOrder = () => {
    localStorage.removeItem('last_order');
    setCurrentOrder(null);
  };

  return (
    <div className="bg-white min-h-screen text-gray-900 pb-20">
      <div className="max-w-8xl mx-auto px-4 sm:px-6 lg:px-16 py-6 sm:py-12">
        {totalItems === 0 ? (
          <div className="max-w-2xl mx-auto py-10 sm:py-20 text-center relative px-4">
            {currentOrder ? (
              <>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="bg-gray-50 rounded-2xl sm:rounded-[3rem] p-6 sm:p-10 shadow-sm mb-8 sm:mb-12 text-left">
                  <div className="flex flex-col sm:flex-row justify-between items-start gap-4 mb-6 sm:mb-8">
                    <div>
                      <p className="text-[10px] font-black uppercase text-gray-400">Order Summary</p>
                      <h2 className="text-2xl sm:text-3xl font-mono font-black text-black break-all">#{currentOrder.orderNumber}</h2>
                    </div>
                    <div className={`px-3 sm:px-4 py-1.5 sm:py-2 rounded-full flex items-center gap-2 ${currentOrder.status === 'Rejected' ? 'bg-red-500 text-white' : 'bg-black text-white'}`}>
                      {currentOrder.status !== 'Rejected' && currentOrder.status !== 'Completed' && (
                        <span className="w-2 h-2 bg-yellow-400 rounded-full animate-pulse"></span>
                      )}
                      <span className="text-[10px] font-black uppercase">{currentOrder.status}</span>
                    </div>
                  </div>
                  <div className="space-y-3 sm:space-y-4 mb-6 sm:mb-8 border-y border-gray-200 py-4 sm:py-6">
                    {currentOrder.items.map((item, idx) => (
                      <div key={idx} className="flex justify-between text-xs sm:text-sm">
                        <span className="font-medium text-gray-600">{item.quantity}x {item.item_name}</span>
                        <span className="font-bold">{(item.price * item.quantity).toLocaleString()} PKR</span>
                      </div>
                    ))}
                  </div>
                  <div className="flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4">
                    <p className="text-2xl sm:text-3xl font-black">{currentOrder.total.toLocaleString()} PKR</p>
                    <p className="text-[10px] font-bold text-gray-400 uppercase">Paid via {currentOrder.method}</p>
                  </div>
                </motion.div>

                <AnimatePresence>
                  {currentOrder.status === 'Completed' && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
                      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
                      <motion.div initial={{ scale: 0.9, y: 20 }} animate={{ scale: 1, y: 0 }} className="relative bg-white w-full max-w-md rounded-2xl sm:rounded-[3rem] p-6 sm:p-12 shadow-2xl text-center border-t-8 border-green-500 mx-4">
                        <div className="text-4xl sm:text-6xl mb-4 sm:mb-6">🍔</div>
                        <h2 className="text-2xl sm:text-4xl font-black uppercase mb-2">How was KF?</h2>
                        <div className="flex justify-center gap-3 sm:gap-4 mb-8 sm:mb-12 mt-6 sm:mt-8">
                          {[1, 2, 3, 4, 5].map((star) => (
                            <button key={star} onClick={() => setRating(star)} className={`text-3xl sm:text-4xl transition-all ${rating >= star ? 'scale-125 saturate-100' : 'grayscale opacity-20'}`}>
                              {star <= 2 ? '👍' : star <= 4 ? '🔥' : '👑'}
                            </button>
                          ))}
                        </div>
                        <button onClick={handleFinishOrder} className="w-full bg-black text-white py-4 sm:py-5 rounded-xl sm:rounded-2xl font-black uppercase text-xs hover:bg-gray-800 transition-colors">
                          {rating > 0 ? 'Submit & Clear' : 'Maybe Later'}
                        </button>
                      </motion.div>
                    </div>
                  )}

                  {currentOrder.status === 'Rejected' && (
                    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
                      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/80 backdrop-blur-md" />
                      <motion.div initial={{ scale: 0.9, y: 20 }} animate={{ scale: 1, y: 0 }} className="relative bg-white w-full max-w-md rounded-2xl sm:rounded-[3rem] p-6 sm:p-10 shadow-2xl text-center border-t-8 border-red-500 mx-4">
                        <div className="w-16 h-16 sm:w-20 sm:h-20 bg-red-100 text-red-500 rounded-full flex items-center justify-center mx-auto mb-4 sm:mb-6">
                          <svg className="w-8 h-8 sm:w-10 sm:h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M6 18L18 6M6 6l12 12" /></svg>
                        </div>
                        <h2 className="text-2xl sm:text-3xl font-black uppercase mb-4 text-black">Order Rejected</h2>
                        <p className="text-gray-600 font-medium mb-4 sm:mb-6 text-sm sm:text-base">
                          Dear Customer, unfortunately your order could not be processed at this time.
                        </p>
                        <div className="bg-red-50 p-4 sm:p-5 rounded-xl sm:rounded-2xl mb-6 sm:mb-8 border border-red-100">
                          <p className="text-[10px] font-black text-red-400 uppercase tracking-widest mb-1">Reason from Kitchen:</p>
                          <p className="text-red-600 font-bold text-base sm:text-lg break-words">
                            "{currentOrder.rejection_reason || 'No specific reason provided.'}"
                          </p>
                        </div>
                        <button onClick={handleFinishOrder} className="w-full bg-red-500 text-white py-4 sm:py-5 rounded-xl sm:rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-red-600 transition-colors shadow-lg shadow-red-500/30">
                          Acknowledge & Clear
                        </button>
                      </motion.div>
                    </div>
                  )}
                </AnimatePresence>
              </>
            ) : (
              <div className="px-4">
                <h1 className="text-3xl sm:text-4xl font-bold mb-4 sm:mb-6 uppercase">Your cart is empty.</h1>
                <Link to="/menu" className="inline-block bg-black text-white px-8 sm:px-10 py-3 sm:py-4 rounded-xl sm:rounded-2xl font-black uppercase text-xs">GO TO MENU</Link>
              </div>
            )}
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 lg:gap-16 items-start">
            
            {/* LEFT COLUMN: CART ITEMS */}
            <div className="lg:col-span-2">
              <h1 className="text-3xl sm:text-4xl lg:text-5xl font-black mb-6 sm:mb-10 uppercase">Your cart.</h1>
              <div className="border-t border-gray-200">
                {cartItems.map((item) => (
                  <motion.div layout key={item.cart_id || item.variation_id} className="flex flex-col sm:flex-row justify-between items-start sm:items-center py-5 sm:py-8 border-b border-gray-100 gap-4">
                    <div className="flex gap-4 sm:gap-6 items-center flex-1 w-full">
                      <img src={item.image_url} alt="" className="w-20 h-20 sm:w-24 sm:h-24 rounded-xl sm:rounded-2xl object-cover bg-gray-50" />
                      <div className="flex-1 min-w-0">
                        <h3 className="text-base sm:text-xl font-bold uppercase leading-tight mb-1 sm:mb-2 break-words">{item.item_name}</h3>
                        <div className="flex flex-wrap gap-1 sm:gap-2 mb-2 sm:mb-3">
                          {item.size_name && item.size_name !== "Standard" && (
                             <span className="text-[8px] sm:text-[10px] bg-black text-white px-1.5 sm:px-2 py-0.5 sm:py-1 rounded uppercase font-bold tracking-widest">{item.size_name}</span>
                          )}
                          {item.modifiers && item.modifiers.map(mod => (
                            <span key={mod.modifier_id} className="text-[8px] sm:text-[10px] bg-yellow-100 text-yellow-800 px-1.5 sm:px-2 py-0.5 sm:py-1 rounded uppercase font-bold border border-yellow-200">+{mod.name}</span>
                          ))}
                        </div>
                        <p className="text-gray-500 font-medium text-sm sm:text-base">{parseFloat(item.price).toLocaleString()} PKR</p>
                        <button onClick={() => removeFromCart(item.cart_id || item.variation_id)} className="text-red-500 text-xs font-black mt-2 uppercase tracking-widest hover:underline block">Remove</button>
                      </div>
                    </div>
                    <div className="flex items-center justify-between sm:justify-end w-full sm:w-auto gap-4 sm:gap-6">
                      <div className="flex border border-gray-200 rounded-lg">
                        <button onClick={() => updateQuantity(item.cart_id || item.variation_id, item.quantity - 1)} className="w-8 h-8 sm:w-10 sm:h-10 hover:bg-gray-50 text-lg">−</button>
                        <span className="w-8 sm:w-10 text-center font-bold self-center">{item.quantity}</span>
                        <button onClick={() => updateQuantity(item.cart_id || item.variation_id, item.quantity + 1)} className="w-8 h-8 sm:w-10 sm:h-10 hover:bg-gray-50 text-lg">+</button>
                      </div>
                      <span className="text-lg sm:text-xl font-black min-w-[100px] text-right">{(item.price * item.quantity).toLocaleString()} PKR</span>
                    </div>
                  </motion.div>
                ))}
              </div>
            </div>

            {/* RIGHT COLUMN: CHECKOUT PANEL */}
            <div className="lg:col-span-1">
              <div className="bg-gray-50 p-5 sm:p-8 rounded-2xl sm:rounded-[2.5rem] lg:sticky lg:top-10 border border-gray-100 shadow-sm">
                <h2 className="text-2xl sm:text-3xl font-black mb-6 sm:mb-8 uppercase underline decoration-[#ff007f]">Checkout</h2>
                
                <div className="mb-6 sm:mb-8">
                  <div className="flex justify-between items-center mb-3">
                    <p className="text-[10px] font-black uppercase text-gray-400">Delivery Address</p>
                    {selectedLocation && (
                      <button onClick={() => setShowAddressModal(true)} className="text-[10px] font-bold text-[#ff007f] uppercase hover:underline">Edit</button>
                    )}
                  </div>
                  
                  {!selectedLocation ? (
                    <button 
                      onClick={() => setShowAddressModal(true)} 
                      className="w-full p-4 sm:p-5 rounded-xl sm:rounded-2xl border-2 border-dashed border-gray-300 font-bold text-gray-500 uppercase text-xs hover:border-black hover:text-black hover:bg-gray-100 transition-all"
                    >
                      + Add Delivery Address
                    </button>
                  ) : (
                    <div className="p-4 sm:p-5 rounded-xl sm:rounded-2xl border border-gray-200 bg-white">
                      <p className="font-black text-sm uppercase">{selectedLocation.area_name}</p>
                      <p className="text-xs font-bold text-gray-500 mt-1 break-words">{specificAddress}</p>
                    </div>
                  )}
                </div>

                <div className="mb-6 sm:mb-8">
                  <p className="text-[10px] font-black uppercase text-gray-400 mb-3">Your Phone (For Tracker)</p>
                  <input type="tel" placeholder="03XXXXXXXXX" value={phone} onChange={(e) => setPhone(e.target.value.replace(/\D/g, ""))}
                    className="w-full p-3 sm:p-4 rounded-xl sm:rounded-2xl border border-gray-200 font-bold text-base sm:text-lg outline-none focus:border-black transition-colors"
                  />
                </div>

                <div className="mb-6 sm:mb-8 border-b border-gray-200 pb-6 sm:pb-8">
                  <button onClick={() => setPaymentTab('cod')} className={`w-full p-4 sm:p-5 rounded-xl sm:rounded-2xl border-2 text-left transition-all ${paymentTab === 'cod' ? 'border-black bg-white shadow-md' : 'border-transparent bg-gray-200 opacity-60'}`}>
                    <span className="font-black text-xs uppercase block tracking-tight">Cash on Delivery</span>
                  </button>
                </div>

                <div className="space-y-2 sm:space-y-3 mb-6 sm:mb-8">
                  <div className="flex justify-between items-center text-gray-500 font-bold text-xs sm:text-sm">
                    <span className="uppercase">Subtotal</span>
                    <span>{subtotal.toLocaleString()} PKR</span>
                  </div>
                  <div className="flex justify-between items-center text-gray-500 font-bold text-xs sm:text-sm">
                    <span className="uppercase">Delivery Fee</span>
                    <span>{deliveryFee === 0 ? 'FREE' : `+${deliveryFee} PKR`}</span>
                  </div>
                  <div className="flex justify-between items-center pt-3 sm:pt-4 border-t border-gray-200">
                    <span className="text-lg sm:text-xl font-black uppercase">Total</span>
                    <span className="text-2xl sm:text-3xl font-black text-[#ff007f]">{finalTotal.toLocaleString()} PKR</span>
                  </div>
                </div>

                <button onClick={handleCheckout} disabled={isPaying} className="w-full bg-black text-white py-5 sm:py-6 rounded-2xl sm:rounded-3xl font-black text-base sm:text-lg uppercase active:scale-95 transition-all shadow-xl hover:bg-gray-800">
                  {isPaying ? 'PROCESSING...' : 'CONFIRM ORDER'}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* ── ADDRESS MODAL (responsive) ── */}
      <AnimatePresence>
        {showAddressModal && (
          <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={() => setShowAddressModal(false)} />
            <motion.div initial={{ scale: 0.95, y: 20 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.95, y: 20, opacity: 0 }} className="relative bg-white w-full max-w-md rounded-2xl sm:rounded-[2.5rem] p-6 sm:p-8 shadow-2xl mx-4 max-h-[90vh] overflow-y-auto">
              <h3 className="text-xl sm:text-2xl font-black uppercase mb-4 sm:mb-6">Delivery Details</h3>
              
              <div className="space-y-5 sm:space-y-6">
                <div>
                  <label className="text-[10px] font-black uppercase text-gray-400 mb-2 block">Select Area</label>
                  <select 
                    className="w-full p-3 sm:p-4 rounded-xl border border-gray-200 font-bold outline-none focus:border-black transition-colors appearance-none bg-gray-50 uppercase text-xs sm:text-sm"
                    value={selectedLocation ? selectedLocation.id : ''}
                    onChange={(e) => {
                      const loc = locations.find(l => l.id === parseInt(e.target.value));
                      setSelectedLocation(loc);
                    }}
                  >
                    <option value="" disabled>Select your area...</option>
                    {locations.map(loc => (
                      <option key={loc.id} value={loc.id}>{loc.area_name} (+{loc.delivery_fee} PKR)</option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="text-[10px] font-black uppercase text-gray-400 mb-2 block">House / Street Details</label>
                  <textarea 
                    placeholder="House # 123, Street 4, Near Landmark..."
                    value={specificAddress}
                    onChange={(e) => setSpecificAddress(e.target.value)}
                    className="w-full p-3 sm:p-4 rounded-xl border border-gray-200 font-bold outline-none focus:border-black transition-colors resize-none h-24 sm:h-28 text-xs sm:text-sm"
                  />
                </div>
              </div>

              <button 
                onClick={() => {
                  if(!selectedLocation || !specificAddress.trim()) return alert("Please complete all address fields.");
                  setShowAddressModal(false);
                }} 
                className="w-full bg-[#ff007f] text-white py-3 sm:py-4 rounded-xl sm:rounded-2xl font-black uppercase text-xs sm:text-sm hover:bg-pink-700 transition-colors mt-6 sm:mt-8"
              >
                Save & Continue
              </button>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

    </div>
  );
};

export default Cart;