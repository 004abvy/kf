import React, { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext();

// Session duration: 8 hours (in milliseconds)
const SESSION_DURATION = 8 * 60 * 60 * 1000;

// Helper: check if a JWT token is expired by decoding its payload
const isTokenExpired = (token) => {
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    // JWT exp is in seconds, Date.now() is in milliseconds
    return payload.exp * 1000 < Date.now();
  } catch {
    return true; // If we can't decode it, treat as expired
  }
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Initial check for existing session
    const savedUser = localStorage.getItem('kf_user');
    const token = localStorage.getItem('kf_token');
    const loginTime = localStorage.getItem('kf_login_time');

    if (savedUser && token) {
      // Check 1: Is the JWT itself expired? (backend sets 24h)
      if (isTokenExpired(token)) {
        console.log('🔒 Session expired (token expired)');
        localStorage.removeItem('kf_token');
        localStorage.removeItem('kf_user');
        localStorage.removeItem('kf_login_time');
        setLoading(false);
        return;
      }

      // Check 2: Has it been more than SESSION_DURATION since login?
      if (loginTime && (Date.now() - parseInt(loginTime)) > SESSION_DURATION) {
        console.log('🔒 Session expired (exceeded 8 hours)');
        localStorage.removeItem('kf_token');
        localStorage.removeItem('kf_user');
        localStorage.removeItem('kf_login_time');
        setLoading(false);
        return;
      }

      setUser(JSON.parse(savedUser));
    }
    setLoading(false);
  }, []);

  const login = (userData, token) => {
    localStorage.setItem('kf_token', token);
    localStorage.setItem('kf_user', JSON.stringify(userData));
    localStorage.setItem('kf_login_time', String(Date.now()));
    setUser(userData);
  };

  const logout = () => {
    localStorage.removeItem('kf_token');
    localStorage.removeItem('kf_user');
    localStorage.removeItem('kf_login_time');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, isLoggedIn: !!user, login, logout, loading }}>
      {!loading && children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

