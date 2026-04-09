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
  const [isLogin, setIsLogin] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState({ text: "", type: "" });

  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
    role: "staff" // Default to staff
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // ── HANDLERS ──
  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setMessage({ text: "", type: "" });

    const endpoint = isLogin ? "/api/auth/login" : "/api/auth/signup";
    // Using 127.0.0.1 instead of localhost for higher reliability in some network setups
    const API_BASE = "http://127.0.0.1:3000";

    try {
      const response = await fetch(`${API_BASE}${endpoint}`, {
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

      if (isLogin) {
        // Trigger global Auth update immediately
        login(data.user, data.token);
        setMessage({ text: `Welcome back, ${data.user.name}!`, type: "success" });
        setTimeout(() => navigate("/menu"), 1000);
      } else {
        setMessage({ text: "Account created! You can now sign in.", type: "success" });
        setIsLogin(true);
      }
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
          <h1 className="text-4xl font-black tracking-tighter uppercase ">
            {isLogin ? "Login." : "Join the Team."}
          </h1>
          <p className="mt-2 text-sm font-bold text-zinc-400 uppercase tracking-widest">
            {isLogin ? "Welcome back to Kitchen Flow" : "Create your staff account"}
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
          
          {!isLogin && (
            <div className="flex flex-col gap-1.5">
              <label className="text-[10px] font-black uppercase tracking-widest ml-1">Full Name</label>
              <input
                name="name"
                type="text"
                value={formData.name}
                onChange={handleChange}
                placeholder="Staff Member Name"
                required
                className="w-full rounded-xl border-2 border-black bg-white px-5 py-3.5 text-black font-bold outline-none focus:bg-zinc-50 transition-colors"
              />
            </div>
          )}

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
            <div className="flex justify-between items-center px-1">
              <label className="text-[10px] font-black uppercase tracking-widest">Password</label>
              {isLogin && <button type="button" className="text-[9px] font-black underline uppercase opacity-50 hover:opacity-100">Forgot?</button>}
            </div>
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
            {isLoading ? "Checking..." : isLogin ? "Sign In" : "Register"}
          </button>
        </form>

        <p className="mt-8 text-center text-[10px] font-black uppercase tracking-widest text-zinc-300">
          {isLogin ? "New staff member? " : "Already registered? "}
          <button 
            type="button"
            onClick={() => setIsLogin(!isLogin)}
            className="text-black hover:underline underline-offset-4"
          >
            {isLogin ? "Register Now" : "Sign In"}
          </button>
        </p>

      </div>
    </div>
  );
};

export default LoginPage;