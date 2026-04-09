import React, { createContext, useContext, useState, useEffect } from 'react';

const CartContext = createContext();

export const useCart = () => {
  const context = useContext(CartContext);
  if (!context) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
};

export const CartProvider = ({ children }) => {
  const [cartItems, setCartItems] = useState(() => {
    try {
      const savedCart = localStorage.getItem('kf_cart');
      return savedCart ? JSON.parse(savedCart) : [];
    } catch (error) {
      console.error('Failed to load cart:', error);
      return [];
    }
  });

  useEffect(() => {
    localStorage.setItem('kf_cart', JSON.stringify(cartItems));
  }, [cartItems]);

  const addToCart = (product) => {
    localStorage.removeItem('last_order');

    setCartItems((prevItems) => {
      // Force IDs to be strings so React doesn't get confused between '52' and 52
      const targetId = String(product.cart_id || product.variation_id);
      
      const existingItem = prevItems.find((item) => String(item.cart_id || item.variation_id) === targetId);
      
      if (existingItem) {
        return prevItems.map((item) =>
          String(item.cart_id || item.variation_id) === targetId
            ? { ...item, quantity: item.quantity + (product.quantity || 1) }
            : item
        );
      }
      return [...prevItems, { ...product, quantity: product.quantity || 1 }];
    });
  };

  const removeFromCart = (identifier) => {
    setCartItems((prevItems) => 
      prevItems.filter((item) => String(item.cart_id || item.variation_id) !== String(identifier))
    );
  };

  const updateQuantity = (identifier, newQuantity) => {
    if (newQuantity <= 0) {
      removeFromCart(identifier);
      return;
    }
    setCartItems((prevItems) =>
      prevItems.map((item) =>
        String(item.cart_id || item.variation_id) === String(identifier) 
          ? { ...item, quantity: newQuantity } 
          : item
      )
    );
  };

  const clearCart = () => {
    setCartItems([]);
  };

  const subtotal = cartItems.reduce((acc, item) => acc + parseFloat(item.price) * item.quantity, 0);
  const totalItems = cartItems.reduce((acc, item) => acc + item.quantity, 0);

  const value = {
    cartItems,
    addToCart,
    removeFromCart,
    updateQuantity,
    clearCart,
    subtotal,
    totalItems,
  };

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
};