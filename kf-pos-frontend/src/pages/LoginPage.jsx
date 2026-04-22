import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const LoginPage = () => {
  const navigate = useNavigate();
  const { login, isLoggedIn } = useAuth();

  // ── PERSISTENT SESSION CHECK ──
  useEffect(() => {
    if (isLoggedIn) {
      navigate("/menu");
    }
  }, [isLoggedIn, navigate]);

  // ── STATE ──
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState({ text: "", type: "" });

  const [formData, setFormData] = useState({
    email: "",
    password: ""
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // ── HANDLERS ──
  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setMessage({ text: "", type: "" });

    const API_BASE = "http://127.0.0.1:3000";

    try {
      const response = await fetch(`${API_BASE}/api/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      // ── CHECK FOR JSON CONTENT ──
      const contentType = response.headers.get("content-type");
      if (!contentType || !contentType.includes("application/json")) {
        // If it's not JSON, it's likely an HTML 404 or 500 error page
        const text = await response.text();
        console.error("Non-JSON response received:", text.slice(0, 200));
        throw new Error("Server connection error. Please ensure the backend is running.");
      }

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || "Login failed");
      }

      // Trigger global Auth update immediately
      login(data.user, data.token);
      setMessage({ text: `Welcome back, ${data.user.name}!`, type: "success" });

      // Redirect based on user role
      const redirectPath = data.user.role === 'admin' ? '/admin' : '/staff';
      setTimeout(() => navigate(redirectPath), 1000);
    } catch (err) {
      console.error("Auth Exception:", err);
      setMessage({ text: err.name === "TypeError" ? "Could not connect to server." : err.message, type: "error" });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 px-4 py-20 font-sans text-black">
      
      <div className="w-full max-w-3xl p-8 sm:p-12 bg-white rounded-3xl border-2 border-black shadow-[8px_8px_0px_0px_rgba(0,0,0,1)]">
        
        {/* Header */}
        <div className="mb-10 text-center">
          <h1 className="text-4xl font-black tracking-tighter uppercase">
            Login.
          </h1>
          <p className="mt-2 text-sm font-bold text-zinc-400 uppercase tracking-widest">
            Welcome back to Kitchen Flow
          </p>
        </div>

        {/* Message */}
        {message.text && (
          <div className={`mb-6 p-4 rounded-xl font-bold border-2 text-sm ${
            message.type === "error" ? "bg-red-50 border-red-500 text-red-600" : "bg-green-50 border-green-500 text-green-600"
          }`}>
            {message.text}
          </div>
        )}

        <form onSubmit={handleSubmit} className="flex flex-col gap-5">
          <div className="flex flex-col gap-1.5">
            <label className="text-[10px] font-black uppercase tracking-widest ml-1">Email / ID</label>
            <input
              name="email"
              type="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="e.g. staff@kf-pos.inc"
              required
              className="w-full rounded-xl border-2 border-black bg-white px-5 py-3.5 text-black font-bold outline-none focus:bg-zinc-50 transition-colors"
            />
          </div>

          <div className="flex flex-col gap-1.5">
            <label className="text-[10px] font-black uppercase tracking-widest ml-1">Password</label>
            <input
              name="password"
              type="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="••••••••"
              required
              className="w-full rounded-xl border-2 border-black bg-white px-5 py-3.5 text-black font-bold outline-none focus:bg-zinc-50 transition-colors"
            />
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className={`mt-4 w-full rounded-xl border-2 border-black bg-black py-4 text-sm font-black uppercase tracking-widest text-white transition-all shadow-[4px_4px_0px_0px_rgba(0,0,0,0.1)] hover:shadow-none hover:translate-x-0.5 hover:translate-y-0.5 active:scale-[0.98] ${
              isLoading ? "opacity-50" : ""
            }`}
          >
            {isLoading ? "Checking..." : "Sign In"}
          </button>
        </form>

      </div>
    </div>
  );
};

export default LoginPage;