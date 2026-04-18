import React from 'react';
import { BrowserRouter, Routes, Route, useLocation } from 'react-router-dom';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import LandingPage from './pages/LandingPage';
import MostWanted from './pages/MostWanted';
import Feedback from './pages/feedback';
import FAQ from './pages/FAQ';
import Menu from './pages/Menu';
import LoginPage from './pages/LoginPage';
import Cart from './pages/Cart';
import SmoothScroll from './components/SmoothScroll';
import OrderSuccess from './pages/OrderSuccess';
import AdminDashboard from './pages/AdminDashboard';
import StaffDashboard from './pages/StaffDashboard';

import { AuthProvider } from './context/AuthContext';
import { CartProvider } from './context/CartContext';

import OrderTracker from './pages/OrderTracker';
import CustomerProfile from './pages/CustomerProfile';

// ── NEW: CONDITIONAL LAYOUT COMPONENT ──
const AppLayout = ({ children }) => {
  const location = useLocation();
  
  // Hide Nav/Footer on back-office dashboards
const isStaffPage = ['/staff', '/kitchen', '/admin'].includes(location.pathname);
  return (
    <SmoothScroll>
      {!isStaffPage && <Navbar />}
      
      <div className={!isStaffPage ? "min-h-[calc(100vh-64px)]" : "min-h-screen"}>
        {children}
      </div>

      {!isStaffPage && <Footer />}
    </SmoothScroll>
  );
};

export default function App() {
  return (
    <AuthProvider>
      <CartProvider>
        <BrowserRouter>
          <AppLayout>
            <Routes>
              <Route path="/" element={<LandingPage />} />
              <Route path="/most-wanted" element={<MostWanted />} />
              <Route path="/menu" element={<Menu />} />
              <Route path="/feedback" element={<Feedback />} />
              <Route path="/faq" element={<FAQ />} />
              <Route path="/cart" element={<Cart />} />
              <Route path="/pos" element={<div className="p-8 text-center text-2xl font-bold mt-20">Your POS UI Goes Here</div>} />
              <Route path="/login" element={<LoginPage />} />
              <Route path="/admin" element={<AdminDashboard />} />
              <Route path="/success" element={<OrderSuccess />} />
              <Route path="/staff" element={<StaffDashboard />} />
              <Route path="/kitchen" element={<StaffDashboard />} />
              <Route path="/track/:id" element={<OrderTracker />} />
              <Route path="/profile" element={<CustomerProfile />} />   
            </Routes>
          </AppLayout>
        </BrowserRouter>
      </CartProvider>
    </AuthProvider>
  );
}