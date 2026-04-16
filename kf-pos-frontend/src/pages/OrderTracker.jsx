import React, { useState, useEffect } from 'react';

const API_URL = import.meta.env.VITE_API_URL;
import { useParams, Link } from 'react-router-dom';
import { motion } from 'framer-motion';

const OrderTracker = () => {
  const { id } = useParams(); 
  const [status, setStatus] = useState('Pending');
  const [rejectionReason, setRejectionReason] = useState(null); // 👈 NEW STATE
  const [loading, setLoading] = useState(true);

  const stages = ['Pending', 'Preparing', 'On the Way', 'Completed'];
  const currentStageIndex = stages.indexOf(status);

  useEffect(() => {
    const fetchStatus = async () => {
      try {
        const res = await fetch(`${API_URL}/api/orders/status/${id}`, { cache: 'no-store' });
        if (res.ok) {
          const data = await res.json();
          setStatus(data.status);
          setRejectionReason(data.rejection_reason); // 👈 SAVE THE REASON
        }
        setLoading(false);
      } catch (err) { console.error("Tracker error:", err); }
    };

    fetchStatus();
    // Keep checking every 5 seconds to see if the kitchen updated it
    const interval = setInterval(fetchStatus, 5000);
    return () => clearInterval(interval);
  }, [id]);

  if (loading) return <div className="min-h-screen flex items-center justify-center font-black uppercase text-2xl tracking-widest">Locating Order...</div>;

  return (
    <div className="bg-white min-h-screen p-8 flex flex-col items-center justify-center relative overflow-hidden">
      <div className="max-w-2xl w-full z-10">
        
        <div className="text-center mb-16">
          <p className="text-xs font-black text-gray-400 uppercase tracking-[0.3em] mb-4">Live Order Status</p>
          <h1 className="text-6xl font-black italic tracking-tighter uppercase mb-2">#{id.replace('ORD-', '')}</h1>
          
          {/* Change subtitle based on status */}
          {status === 'Rejected' ? (
             <p className="text-xl font-bold text-red-500 uppercase tracking-widest mt-4">Order Cancelled</p>
          ) : (
             <p className="text-lg font-bold text-gray-800">Your food is <span className="text-yellow-500 italic">{status.toLowerCase()}</span>.</p>
          )}
        </div>

        {/* ── CONDITIONAL UI: SHOW ERROR IF REJECTED, OTHERWISE SHOW PROGRESS BAR ── */}
        {status === 'Rejected' ? (
          <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} className="bg-red-50 border-2 border-red-200 rounded-[3rem] p-10 text-center shadow-lg">
            <div className="w-24 h-24 bg-red-100 text-red-500 rounded-full flex items-center justify-center mx-auto mb-6">
              <svg className="w-12 h-12" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M6 18L18 6M6 6l12 12" /></svg>
            </div>
            <h2 className="text-3xl font-black italic uppercase mb-4 text-black">Order Rejected</h2>
            <p className="text-gray-600 font-medium mb-6">
              We're sorry, but the kitchen could not accept your order right now.
            </p>
            
            <div className="bg-white p-6 rounded-2xl mb-8 border border-red-100 shadow-sm inline-block min-w-[80%]">
              <p className="text-[10px] font-black text-red-400 uppercase tracking-widest mb-2">Reason from Kitchen:</p>
              <p className="text-red-600 font-black text-xl">
                "{rejectionReason || 'No specific reason provided.'}"
              </p>
            </div>

            <div>
              <Link to="/menu" className="inline-block bg-black text-white px-12 py-5 rounded-2xl font-black uppercase tracking-widest text-xs hover:bg-gray-800 transition-colors">Return to Menu</Link>
            </div>
          </motion.div>
        ) : (
          <>
            {/* NORMAL PROGRESS BAR (Hidden if rejected) */}
            <div className="relative flex justify-between items-center mb-20">
              <div className="absolute top-1/2 left-0 right-0 h-2 bg-gray-100 -z-10 rounded-full -translate-y-1/2"></div>
              
              <motion.div 
                className="absolute top-1/2 left-0 h-2 bg-black -z-10 rounded-full -translate-y-1/2"
                initial={{ width: '0%' }}
                animate={{ width: `${(currentStageIndex / (stages.length - 1)) * 100}%` }}
                transition={{ duration: 0.8, ease: "easeInOut" }}
              />

              {stages.map((stage, index) => {
                const isActive = index <= currentStageIndex;
                const isCurrent = index === currentStageIndex;
                return (
                  <div key={stage} className="flex flex-col items-center">
                    <motion.div 
                      className={`w-12 h-12 rounded-full flex items-center justify-center border-4 text-xl bg-white transition-colors duration-500 ${isActive ? 'border-black text-black' : 'border-gray-200 text-gray-300'}`}
                      animate={isCurrent ? { scale: [1, 1.1, 1] } : {}}
                      transition={{ repeat: isCurrent ? Infinity : 0, duration: 2 }}
                    >
                      {index === 0 ? '📝' : index === 1 ? '🔥' : index === 2 ? '🛵' : '👑'}
                    </motion.div>
                    <span className={`mt-4 text-[10px] font-black uppercase tracking-widest absolute translate-y-14 ${isActive ? 'text-black' : 'text-gray-300'}`}>
                      {stage}
                    </span>
                  </div>
                );
              })}
            </div>

            {status === 'Completed' && (
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center mt-10">
                <h2 className="text-3xl font-black italic uppercase mb-6 text-green-500">Delivered!</h2>
                <Link to="/menu" className="bg-black text-white px-10 py-4 rounded-2xl font-black uppercase tracking-widest text-xs">Order Again</Link>
              </motion.div>
            )}
          </>
        )}

      </div>
    </div>
  );
};

export default OrderTracker;