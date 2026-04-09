import React from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { useAuth } from '../context/AuthContext';
import { useCart } from '../context/CartContext';
import DesktopLogo from '../assets/desktop-logo.PNG'; 
import MobileLogo from '../assets/mobile-logo.PNG';   

export default function Navbar() {
  const { isLoggedIn, user, logout } = useAuth();
  const { totalItems } = useCart();
  
  return (
    <motion.nav 
      initial={{ height: 0, opacity: 0, overflow: 'hidden' }}
      animate={{ height: "auto", opacity: 1 }}
      transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
      className="flex flex-col sticky top-0 z-50 shadow-lg bg-black font-sans"
    >
      {/* 1. TOP DIV: Text / Announcement Bar */}
      <div className="bg-gradient-to-r from-purple-600 via-pink-500 to-red-500 text-gray-200 text-xs sm:text-sm md:text-base py-2 sm:py-3 px-2 text-center font-medium font-nord">
        <span>Freshness in Every Bite! Open 11 AM - 3 AM | UAN: 0304-111-4201</span>
      </div>

      {/* 2. BOTTOM DIV: Main Navigation */}
      <div className="bg-black text-white py-3 sm:py-4">
        <div className="max-w-[105rem] mx-auto flex justify-between items-center px-4 sm:px-6">          
          
          {/* LEFT DIV: Brand Logo */}
          <motion.div 
            initial={{ opacity: 0, scale: 0.5 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.4, type: 'spring', stiffness: 200, damping: 15 }}
            className="flex-shrink-0 flex items-center gap-2 cursor-pointer"
          >
            <Link to="/" className="flex items-center gap-2">
              <img src={MobileLogo} alt="Mobile Logo" className="h-8 w-auto block sm:hidden" />
              <img src={DesktopLogo} alt="Desktop Logo" className="h-16 md:h-20 w-auto hidden sm:block" />
            </Link>
          </motion.div>

          {/* RIGHT DIV: Navigation Items */}
          <motion.div 
            initial={{ opacity: 0, x: 30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.5, duration: 0.6, ease: 'easeOut' }}
            className="flex items-center space-x-2 sm:space-x-4 md:space-x-6 font-semibold text-sm sm:text-base"
          >
            <motion.div whileHover={{ scale: 1.05, y: -2 }} whileTap={{ scale: 0.95 }}>
              <Link to="/menu" className="font-humane hover:bg-gray-800 px-2 py-1.5 sm:px-3 sm:py-2 rounded-md transition-colors whitespace-nowrap">
                Shop Online
              </Link>
            </motion.div>

            {/* Authentication Toggle */}
            {isLoggedIn ? (
              <div className="flex items-center gap-2 sm:gap-4">
                <div className="hidden md:flex flex-col items-end mr-2">
                  <span className="text-[10px] font-black uppercase tracking-[0.2em] text-zinc-500">---------------------------</span>
                  <span className="font-humane text-sm font-black text-white uppercase italic">
                    Welcome, {user?.name || 'Staff'}!
                  </span>
                </div>
                <motion.div whileHover={{ scale: 1.05, y: -2 }} whileTap={{ scale: 0.95 }}>
                  <button
                    onClick={logout}
                    className="font-rova text-red-400 hover:text-red-300 px-3 py-1.5 sm:px-4 sm:py-2 rounded-md transition-all border-2 border-red-400/20 hover:border-red-400/40 font-black text-[10px] sm:text-xs uppercase tracking-widest whitespace-nowrap"
                  >
                    Sign Out
                  </button>
                </motion.div>
              </div>
            ) : (
              <motion.div whileHover={{ scale: 1.05, y: -2 }} whileTap={{ scale: 0.95 }}>
                <Link to="/login" className="hover:bg-gray-800 px-2 py-1.5 sm:px-3 sm:py-2 rounded-md transition-colors whitespace-nowrap">
                  Login
                </Link>
              </motion.div>
            )}

            <motion.div whileHover={{ scale: 1.05, y: -2 }} whileTap={{ scale: 0.95 }}>
              <Link
                to="/cart"
                className="font-rova bg-white text-red-600 hover:bg-gray-100 flex items-center gap-1 sm:gap-2 px-3 py-1.5 sm:px-5 sm:py-2 rounded-lg transition-colors shadow-sm relative"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 sm:h-5 sm:w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
                {/* Hide the word 'Cart' on very small screens to save space, show on small+ */}
                <span className="hidden sm:inline">Cart</span>
                
                {totalItems > 0 && (
                  <motion.span 
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    className="bg-red-600 text-white text-[10px] font-black w-4 h-4 sm:w-5 sm:h-5 rounded-full flex items-center justify-center absolute -top-1.5 -right-1.5 sm:-top-2 sm:-right-2 shadow-lg ring-2 ring-white"
                  >
                    {totalItems}
                  </motion.span>
                )}
              </Link>
            </motion.div>
          </motion.div>
        </div>
      </div>
    </motion.nav>
  );
}