import React, { useState } from 'react';

const API_URL = import.meta.env.VITE_API_URL;
import { useNavigate } from 'react-router-dom';
import { useCart } from '../context/CartContext'; // Ensure this path is correct!

const CustomerProfile = () => {
  const [phone, setPhone] = useState('');
  const [history, setHistory] = useState([]);
  const [hasSearched, setHasSearched] = useState(false);
  
  // We need your cart context to inject the items back into the cart
  const { addToCart } = useCart(); 
  const navigate = useNavigate();

  const fetchHistory = async () => {
    if (phone.length < 10) return alert("Enter a valid phone number");
    
    try {
      const res = await fetch(`${API_URL}/api/customer/history/${phone}`);
      const data = await res.json();
      setHistory(data);
      setHasSearched(true);
    } catch (err) {
      console.error("Failed to fetch history");
    }
  };

  const handleReorder = (orderItems) => {
    // Loop through the past items and add them to the current cart
    orderItems.forEach(item => {
      // You might need to adjust this depending on how your addToCart function expects the data
      addToCart({
        variation_id: item.variation_id,
        item_name: item.item_name,
        quantity: item.quantity,
        // ... include any other required fields your cart needs (price, image)
      });
    });
    
    // Redirect them straight to the cart!
    navigate('/cart');
  };

  return (
    <div className="bg-gray-50 min-h-screen py-20 px-8">
      <div className="max-w-3xl mx-auto">
        <h1 className="text-5xl font-black italic tracking-tighter uppercase mb-8">My Orders</h1>
        
        {/* Simple Login / Search */}
        <div className="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 mb-12 flex gap-4">
          <input 
            type="tel" 
            placeholder="Enter Phone Number (e.g. 03001234567)"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            className="flex-1 bg-gray-50 p-4 rounded-xl border border-gray-200 outline-none font-bold text-lg"
          />
          <button onClick={fetchHistory} className="bg-black text-white px-8 rounded-xl font-black uppercase tracking-widest text-xs hover:bg-gray-800 transition-all">
            Find History
          </button>
        </div>

        {/* The Order History List */}
        {hasSearched && history.length === 0 && (
          <p className="text-center text-gray-400 font-bold uppercase">No orders found for this number.</p>
        )}

        <div className="space-y-6">
          {history.map((order) => (
            <div key={order.order_id} className="bg-white p-8 rounded-[2rem] border border-gray-100 shadow-sm flex justify-between items-center group hover:border-black transition-colors">
              <div>
                <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">
                  {new Date(order.created_at).toLocaleDateString()} • {order.status}
                </p>
                <h3 className="text-2xl font-mono font-black mb-2">#{order.order_number.slice(-6)}</h3>
                <p className="text-sm font-bold text-gray-600">
                  {order.items.map(i => `${i.quantity}x ${i.item_name}`).join(', ')}
                </p>
              </div>
              
              <div className="text-right flex flex-col items-end gap-4">
                <span className="text-2xl font-black italic text-black">{order.total_amount} PKR</span>
                <button 
                  onClick={() => handleReorder(order.items)}
                  className="bg-yellow-400 text-black px-6 py-3 rounded-xl font-black uppercase tracking-widest text-[10px] hover:bg-yellow-500 transition-all"
                >
                  Reorder This
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default CustomerProfile;