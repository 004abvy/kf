import React, { useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { motion } from 'framer-motion';

const OrderSuccess = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const orderNumber = location.state?.orderNumber;

  useEffect(() => {
    // Redirect to tracker after 3 seconds
    const timer = setTimeout(() => {
      if (orderNumber) {
        navigate(`/track/${orderNumber}`);
      } else {
        navigate('/menu');
      }
    }, 3000);

    return () => clearTimeout(timer);
  }, [orderNumber, navigate]);

  return (
    <div className="bg-white min-h-screen flex items-center justify-center p-8">
      <motion.div 
        initial={{ opacity: 0, scale: 0.9 }} 
        animate={{ opacity: 1, scale: 1 }} 
        className="text-center max-w-md"
      >
        <motion.div 
          animate={{ scale: [1, 1.1, 1] }} 
          transition={{ repeat: Infinity, duration: 2 }}
          className="text-8xl mb-6"
        >
          ✓
        </motion.div>
        
        <h1 className="text-5xl font-black italic tracking-tighter uppercase mb-4">
          Order Confirmed!
        </h1>
        
        <p className="text-gray-600 font-bold text-lg mb-8">
          Order #{orderNumber?.slice(-6)}
        </p>
        
        <p className="text-gray-400 font-bold uppercase tracking-widest text-sm mb-8">
          Redirecting to order tracker...
        </p>

        <div className="flex justify-center gap-2 mb-8">
          <div className="w-2 h-2 bg-black rounded-full animate-bounce" style={{ animationDelay: '0s' }}></div>
          <div className="w-2 h-2 bg-black rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
          <div className="w-2 h-2 bg-black rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
        </div>

        <button 
          onClick={() => navigate(`/track/${orderNumber}`)}
          className="bg-black text-white px-8 py-4 rounded-2xl font-black uppercase tracking-widest text-sm"
        >
          Track Order Now
        </button>
      </motion.div>
    </div>
  );
};

export default OrderSuccess;