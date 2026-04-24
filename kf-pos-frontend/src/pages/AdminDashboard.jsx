import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';

const API_URL = import.meta.env.VITE_API_URL;
import { motion } from 'framer-motion';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

const AdminDashboard = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    revenue: 0,
    orderCount: 0,
    popular: [],
    revenueTrend: [],
    paymentStats: []
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [staffList, setStaffList] = useState([]);
  const [customerList, setCustomerList] = useState([]);
  const [updatingStaff, setUpdatingStaff] = useState(null);
  const [viewingCustomerOrders, setViewingCustomerOrders] = useState(null);
  const [customerOrders, setCustomerOrders] = useState([]);
  const [newPassword, setNewPassword] = useState('');
  const [isUpdating, setIsUpdating] = useState(false);
  const [isLoadingOrders, setIsLoadingOrders] = useState(false);

  // Colors for the Pie Chart
  const COLORS = ['#000000', '#FBBF24']; // Black and Yellow

  const fetchStats = async () => {
    try {
      const token = localStorage.getItem('kf_token');
      const res = await fetch(`${API_URL}/api/admin/stats`, {
        cache: 'no-store',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (!res.ok) {
        const errData = await res.json().catch(() => ({}));
        throw new Error(errData.message || 'Failed to fetch stats');
      }
      const data = await res.json();
      setStats(data);
      setError(null);
      setLoading(false);
    } catch (err) {
      setError(err.message || 'Failed to fetch stats');
      setLoading(false);
      console.error("Stats fetch error:", err);
    }
  };

  const fetchStaff = async () => {
    try {
      const token = localStorage.getItem('kf_token');
      const res = await fetch(`${API_URL}/api/admin/staff`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setStaffList(data);
      }
    } catch (err) {
      console.error("Staff fetch error:", err);
    }
  };

  const fetchCustomers = async () => {
    try {
      const token = localStorage.getItem('kf_token');
      const res = await fetch(`${API_URL}/api/admin/customers`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setCustomerList(data);
      }
    } catch (err) {
      console.error("Customer fetch error:", err);
    }
  };

  const fetchCustomerOrders = async (customerId) => {
    setIsLoadingOrders(true);
    try {
      const res = await fetch(`${API_URL}/api/customer/history/${customerId}`);
      const data = await res.json();
      setCustomerOrders(data);
    } catch (err) {
      console.error("Fetch customer orders error:", err);
    } finally {
      setIsLoadingOrders(false);
    }
  };

  const handleUpdatePassword = async () => {
    if (!newPassword) return alert("Please enter a new password");
    setIsUpdating(true);
    try {
      const token = localStorage.getItem('kf_token');
      const res = await fetch(`${API_URL}/api/admin/staff/update-password`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ staffId: updatingStaff.staff_id, newPassword })
      });
      if (res.ok) {
        alert("Password updated successfully!");
        setUpdatingStaff(null);
        setNewPassword('');
      } else {
        const data = await res.json();
        alert(data.message || "Failed to update password");
      }
    } catch (err) {
      alert("Error updating password");
    } finally {
      setIsUpdating(false);
    }
  };

  useEffect(() => {
    fetchStats();
    fetchStaff();
    fetchCustomers();
    // Refresh every 30 seconds for live money tracking
    const interval = setInterval(fetchStats, 30000);
    return () => clearInterval(interval);
  }, []);

  if (loading) return <div className="p-20 text-center font-black uppercase text-2xl tracking-widest text-gray-400 min-h-screen flex items-center justify-center">Loading Financials...</div>;
  if (error) return <div className="p-20 text-center font-black uppercase text-2xl tracking-widest text-red-500 min-h-screen flex items-center justify-center">{error}</div>;

  return (
    <div className="bg-white min-h-screen p-8 lg:p-16 text-black selection:bg-yellow-400 selection:text-black">
      
      {/* ── HEADER ── */}
      <div className="flex justify-between items-end mb-16">
        <div>
          <p className="text-[10px] font-black uppercase tracking-[0.2em] text-gray-400 mb-2">Manager Overview</p>
          <h1 className="text-6xl font-black tracking-tighter uppercase">Business Insights.</h1>
        </div>
        <div className="flex items-center gap-4">
          <div className="text-right">
            <p className="text-[10px] font-black uppercase text-gray-400 mb-1">Last Updated</p>
            <p className="font-mono font-bold text-xs">{new Date().toLocaleTimeString()}</p>
          </div>
          <button
            onClick={() => {
              logout();
              navigate('/login');
            }}
            className="px-4 py-2 rounded-full text-xs font-black uppercase border-2 border-red-500 text-red-500 hover:bg-red-500 hover:text-white transition-all"
          >
            Logout
          </button>
        </div>
      </div>

      {/* ── TOP FLASH CARDS ── */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-16">
        {/* Revenue Card */}
        <motion.div whileHover={{ y: -5 }} className="bg-black text-white p-10 rounded-[3rem] shadow-2xl relative overflow-hidden">
          <div className="relative z-10">
            <p className="text-[10px] font-black uppercase tracking-widest opacity-50 mb-4">Today's Revenue</p>
            <h2 className="text-5xl font-black">{(stats.revenue).toLocaleString()} <span className="text-sm opacity-50">PKR</span></h2>
          </div>
          <div className="absolute -right-4 -bottom-4 text-9xl opacity-10 font-black">Rs</div>
        </motion.div>

        {/* Order Count Card */}
        <motion.div whileHover={{ y: -5 }} className="bg-gray-50 p-10 rounded-[3rem] border border-gray-200">
          <p className="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-4">Orders Served</p>
          <h2 className="text-5xl font-black text-black">{stats.orderCount} <span className="text-sm opacity-30 uppercase">Today</span></h2>
        </motion.div>

        {/* Average Order Value */}
        <motion.div whileHover={{ y: -5 }} className="bg-yellow-400 p-10 rounded-[3rem] shadow-xl">
          <p className="text-[10px] font-black uppercase tracking-widest text-yellow-900/50 mb-4">Avg. Order Value</p>
          <h2 className="text-5xl font-black text-black">
            {stats.orderCount > 0 ? Math.round(stats.revenue / stats.orderCount).toLocaleString() : 0} 
            <span className="text-sm opacity-50 ml-2 uppercase text-black">PKR</span>
          </h2>
        </motion.div>
      </div>

      {/* ── LINE CHART: 7-DAY REVENUE TREND ── */}
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="bg-gray-50 p-10 rounded-[3rem] border border-gray-100 mb-16">
        <div className="mb-10 flex justify-between items-center">
          <h3 className="text-2xl font-black uppercase">7-Day Revenue Trend</h3>
          <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest bg-white border border-gray-200 px-4 py-2 rounded-full shadow-sm">Last 7 Days</span>
        </div>
        
        <div className="h-[400px] w-full">
          {stats.revenueTrend && stats.revenueTrend.length > 0 ? (
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={stats.revenueTrend}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
                <XAxis dataKey="date" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af', fontWeight: 'bold' }} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#9ca3af', fontWeight: 'bold' }} tickFormatter={(value) => `Rs ${value}`} dx={-10} />
                <Tooltip 
                  contentStyle={{ borderRadius: '1rem', border: 'none', boxShadow: '0 10px 25px -5px rgba(0, 0, 0, 0.1)', fontWeight: 'bold' }}
                  itemStyle={{ color: 'black' }}
                />
                <Line type="monotone" dataKey="revenue" stroke="#000000" strokeWidth={4} dot={{ r: 6, fill: '#FBBF24', strokeWidth: 0 }} activeDot={{ r: 8 }} />
              </LineChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-full flex items-center justify-center text-gray-400 font-bold uppercase tracking-widest text-sm">Not enough data to draw chart</div>
          )}
        </div>
      </motion.div>

      {/* ── BOTTOM SPLIT GRID ── */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-16">
        
        {/* Left: Best Sellers */}
        <div>
          <h3 className="text-2xl font-black uppercase mb-8 underline decoration-4 decoration-yellow-400 underline-offset-8">Best Sellers</h3>
          <div className="space-y-4">
            {stats.popular && stats.popular.length > 0 ? stats.popular.map((item, index) => (
              <div key={index} className="flex justify-between items-center p-6 bg-gray-50 rounded-2xl border border-gray-100 hover:bg-white hover:shadow-lg transition-all group">
                <div className="flex items-center gap-4">
                  <span className={`w-10 h-10 flex items-center justify-center rounded-full text-xs font-black ${index === 0 ? 'bg-yellow-400 text-black' : 'bg-black text-white'}`}>
                    0{index + 1}
                  </span>
                  <span className="font-bold text-lg uppercase tracking-tight">{item.name}</span>
                </div>
                <div className="text-right">
                  <span className="text-xl font-black">{item.total_sold}</span>
                  <p className="text-[9px] font-black uppercase text-gray-400">Total Sold</p>
                </div>
              </div>
            )) : (
              <p className="text-gray-400 font-bold uppercase py-10">No items sold yet.</p>
            )}
          </div>
        </div>

        {/* Right: Payment Methods Pie Chart */}
        <div className="bg-gray-50 rounded-[3rem] p-10 border border-gray-100">
          <h3 className="text-2xl font-black uppercase mb-10 text-center">Payment Methods</h3>
          <div className="h-[250px] w-full relative">
            {stats.paymentStats && stats.paymentStats.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={stats.paymentStats} cx="50%" cy="50%" innerRadius={70} outerRadius={100} paddingAngle={5} dataKey="value">
                    {stats.paymentStats.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ borderRadius: '1rem', border: 'none', fontWeight: 'bold' }} />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-gray-400 font-bold text-xs uppercase text-center">No payment data</div>
            )}
          </div>
          
          {/* Custom Pie Chart Legend */}
          <div className="flex justify-center gap-6 mt-8">
            {stats.paymentStats && stats.paymentStats.map((entry, index) => (
              <div key={index} className="flex items-center gap-3 bg-white px-4 py-2 rounded-full shadow-sm border border-gray-100">
                <div className="w-4 h-4 rounded-full" style={{ backgroundColor: COLORS[index % COLORS.length] }}></div>
                <span className="text-xs font-black uppercase text-gray-800">{entry.name}</span>
              </div>
            ))}
          </div>
        </div>

      </div>

      {/* ── STAFF MANAGEMENT SECTION ── */}
      <div className="mt-20">
        <h3 className="text-2xl font-black uppercase mb-8 underline decoration-4 decoration-yellow-400 underline-offset-8">Staff Security & Access</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {staffList.filter(s => s.role_name.toLowerCase() !== 'customer').map((staff) => (
            <div key={staff.staff_id} className="bg-gray-50 p-6 rounded-3xl border border-gray-100 flex flex-col justify-between">
              <div>
                <p className="text-[10px] font-black uppercase text-gray-400 mb-1">{staff.role_name}</p>
                <h4 className="text-xl font-bold uppercase tracking-tight">{staff.full_name}</h4>
                <p className="text-xs text-gray-500 mt-1">{staff.gmail}</p>
              </div>
              <button 
                onClick={() => setUpdatingStaff(staff)}
                className="mt-6 w-full py-3 bg-black text-white text-[10px] font-black uppercase tracking-widest rounded-xl hover:bg-yellow-400 hover:text-black transition-all"
              >
                Reset Password
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* ── CUSTOMER DIRECTORY SECTION ── */}
      <div className="mt-20">
        <h3 className="text-2xl font-black uppercase mb-8 underline decoration-4 decoration-yellow-400 underline-offset-8">Customer Directory</h3>
        <div className="bg-gray-50 rounded-[2rem] border border-gray-100 overflow-hidden">
          <table className="w-full text-left">
            <thead>
              <tr className="bg-black text-white text-[10px] font-black uppercase tracking-widest">
                <th className="px-8 py-4">Name</th>
                <th className="px-8 py-4">Email</th>
                <th className="px-8 py-4">Total Orders</th>
                <th className="px-8 py-4">Last Order</th>
                <th className="px-8 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {customerList.map((customer) => (
                <tr key={customer.id} className="hover:bg-white transition-colors group">
                  <td className="px-8 py-6 font-bold uppercase text-sm tracking-tight">{customer.full_name}</td>
                  <td className="px-8 py-6 text-xs text-gray-500">{customer.gmail}</td>
                  <td className="px-8 py-6">
                    <span className="bg-yellow-400 text-black px-3 py-1 rounded-full text-[10px] font-black">{customer.order_count}</span>
                  </td>
                  <td className="px-8 py-6 text-[10px] font-bold text-gray-400 uppercase">
                    {customer.last_order_date ? new Date(customer.last_order_date).toLocaleDateString() : 'Never'}
                  </td>
                  <td className="px-8 py-6 text-right">
                    <button 
                      onClick={() => {
                        setViewingCustomerOrders(customer);
                        fetchCustomerOrders(customer.id);
                      }}
                      className="text-[10px] font-black uppercase tracking-widest bg-black text-white px-4 py-2 rounded-lg hover:bg-yellow-400 hover:text-black transition-all"
                    >
                      View Orders
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {customerList.length === 0 && (
            <div className="p-20 text-center text-gray-400 font-bold uppercase tracking-widest">No customers found</div>
          )}
        </div>
      </div>

      {/* ── CUSTOMER ORDERS MODAL ── */}
      {viewingCustomerOrders && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-black/60 backdrop-blur-md">
          <motion.div initial={{ y: 50, opacity: 0 }} animate={{ y: 0, opacity: 1 }} className="bg-white w-full max-w-4xl max-h-[85vh] rounded-[3.5rem] shadow-2xl border-4 border-black overflow-hidden flex flex-col">
            <div className="p-10 border-b border-gray-100 flex justify-between items-start">
              <div>
                <p className="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1">Order History for</p>
                <h3 className="text-4xl font-black uppercase tracking-tighter">{viewingCustomerOrders.full_name}</h3>
              </div>
              <button 
                onClick={() => setViewingCustomerOrders(null)}
                className="w-12 h-12 rounded-full border-2 border-black flex items-center justify-center font-black hover:bg-black hover:text-white transition-all"
              >
                ✕
              </button>
            </div>
            
            <div className="flex-1 overflow-y-auto p-10 space-y-6">
              {isLoadingOrders ? (
                <div className="py-20 text-center font-black uppercase text-gray-400 tracking-widest animate-pulse">Fetching History...</div>
              ) : customerOrders.length > 0 ? (
                customerOrders.map((order) => (
                  <div key={order.order_id} className="bg-gray-50 p-8 rounded-[2rem] border border-gray-100 flex flex-col md:flex-row justify-between gap-6">
                    <div>
                      <div className="flex items-center gap-3 mb-2">
                        <span className="text-xl font-mono font-black">#{order.order_number.slice(-6)}</span>
                        <span className={`px-3 py-1 rounded-full text-[9px] font-black uppercase ${order.status === 'Completed' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'}`}>
                          {order.status}
                        </span>
                      </div>
                      <p className="text-xs font-bold text-gray-600 mb-4">
                        {order.items.map(i => `${i.quantity}x ${i.item_name}`).join(', ')}
                      </p>
                      <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">
                        {new Date(order.created_at).toLocaleString()}
                      </p>
                    </div>
                    <div className="text-right self-center">
                      <p className="text-2xl font-black">{order.total_amount.toLocaleString()} PKR</p>
                    </div>
                  </div>
                ))
              ) : (
                <div className="py-20 text-center font-black uppercase text-gray-400 tracking-widest">No order history found.</div>
              )}
            </div>
            
            <div className="p-10 bg-gray-50 border-t border-gray-100">
              <button onClick={() => setViewingCustomerOrders(null)} className="w-full py-4 bg-black text-white font-black uppercase tracking-widest rounded-2xl">Close Directory</button>
            </div>
          </motion.div>
        </div>
      )}
    </div>
  );
};

export default AdminDashboard;