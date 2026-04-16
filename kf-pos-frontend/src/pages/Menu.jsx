import React, { useState, useEffect, useRef, useMemo, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useLenis } from "../components/SmoothScroll";
import { useCart } from "../context/CartContext";
import { useNavigate } from "react-router-dom";

const SIDEBAR_WIDTH = 340;
const CART_WIDTH = 360;
const TOP_NAV_HEIGHT = 180;

const Menu = () => {
  const [menuData, setMenuData] = useState([]);
  const [activeCategoryId, setActiveCategoryId] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [highlightStyle, setHighlightStyle] = useState({ top: 0, height: 0, opacity: 0 });

  // ── MODAL STATES ──
  const [selectedItem, setSelectedItem] = useState(null);
  const [selectedVariation, setSelectedVariation] = useState(null);
  const [itemModifiers, setItemModifiers] = useState([]);
  const [selectedMods, setSelectedMods] = useState([]);
  const [isModLoading, setIsModLoading] = useState(false);
  const [modalQuantity, setModalQuantity] = useState(1);

  const isScrollingAuto = useRef(false);
  const sectionRefs = useRef({});
  const sidebarRefs = useRef({});

  const lenis = useLenis();
  const { cartItems, addToCart, updateQuantity, removeFromCart, subtotal, totalItems } = useCart();
  const navigate = useNavigate();
  const API_BASE = import.meta.env.VITE_API_URL + '/api';

  useEffect(() => {
    const loadEntireMenu = async () => {
      try {
        const catResponse = await fetch(`${API_BASE}/categories`);
        if (!catResponse.ok) throw new Error("Connection failed");
        const categories = await catResponse.json();

        const categoriesWithItems = await Promise.all(
          categories.map(async (cat) => {
            try {
              const res = await fetch(`${API_BASE}/items/${cat.category_id}`);
              const items = res.ok ? await res.json() : [];

              const grouped = Array.isArray(items) ? items.reduce((acc, curr) => {
                const groupKey = curr.item_name.trim().toLowerCase();
                if (!acc[groupKey]) {
                  acc[groupKey] = {
                    item_id: curr.item_id,
                    item_name: curr.item_name,
                    image_url: curr.image_url,
                    variations: []
                  };
                }
                acc[groupKey].variations.push({
                  variation_id: curr.variation_id,
                  size_name: curr.size_name || "Standard",
                  price: curr.price
                });
                return acc;
              }, {}) : {};

              return { ...cat, products: Object.values(grouped) };
            } catch (err) {
              return { ...cat, products: [] };
            }
          })
        );

        let extrasCategory = null;
        try {
          const modRes = await fetch(`${API_BASE}/modifiers`);
          if (modRes.ok) {
            const modData = await modRes.json();
            const uniqueModifiers = modData.reduce((acc, current) => {
              if (!acc.find(i => i.name.toLowerCase() === current.name.toLowerCase())) {
                return acc.concat([current]);
              }
              return acc;
            }, []);

            if (uniqueModifiers.length > 0) {
              extrasCategory = {
                category_id: "extras-category",
                name: "Extras & Add-ons",
                products: uniqueModifiers.map(mod => ({
                  item_id: `mod-${mod.modifier_id}`,
                  item_name: mod.name,
                  // UPDATED: Using LoremFlickr for real photos in the Extras category
                  image_url: `https://loremflickr.com/800/800/food,ingredient,${encodeURIComponent(mod.name)}/all`,
                  variations: [{
                    variation_id: `mod-var-${mod.modifier_id}`,
                    size_name: "Standard",
                    price: mod.price
                  }]
                }))
              };
            }
          }
        } catch (err) {
          console.error("Failed to load extras");
        }

        const finalMenuData = extrasCategory ? [...categoriesWithItems, extrasCategory] : categoriesWithItems;
        setMenuData(finalMenuData);
        if (finalMenuData.length > 0) {
          setActiveCategoryId(String(finalMenuData[0].category_id));
        }
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    loadEntireMenu();
  }, []);

  useEffect(() => {
    if (menuData.length === 0) return;
    const observer = new IntersectionObserver(
      (entries) => {
        if (isScrollingAuto.current) return;
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setActiveCategoryId(String(entry.target.id));
          }
        });
      },
      { root: null, rootMargin: `-${TOP_NAV_HEIGHT + 100}px 0px -60% 0px`, threshold: 0 }
    );

    Object.values(sectionRefs.current).forEach((section) => {
      if (section) observer.observe(section);
    });
    return () => observer.disconnect();
  }, [menuData]);

  useEffect(() => {
    const updateHighlight = () => {
      if (!activeCategoryId) return;
      const activeElement = sidebarRefs.current[activeCategoryId];
      if (activeElement) {
        setHighlightStyle({ top: activeElement.offsetTop, height: activeElement.offsetHeight, opacity: 1 });
        activeElement.scrollIntoView({ behavior: "smooth", block: "nearest" });
      }
    };
    requestAnimationFrame(updateHighlight);
  }, [activeCategoryId, menuData]);

  const scrollToCategory = useCallback((categoryId) => {
    const stringId = String(categoryId);
    setActiveCategoryId(stringId);
    const targetElement = sectionRefs.current[stringId];
    if (targetElement) {
      const offset = TOP_NAV_HEIGHT + 60;
      if (lenis) {
        isScrollingAuto.current = true;
        lenis.scrollTo(targetElement, {
          offset: -offset, duration: 1.5, easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
          onComplete: () => { isScrollingAuto.current = false; }
        });
      } else {
        const elementPosition = targetElement.getBoundingClientRect().top + window.pageYOffset;
        window.scrollTo({ top: elementPosition - offset, behavior: "smooth" });
      }
    }
  }, [lenis]);

  const openItemModal = async (item) => {
    setSelectedItem(item);
    setSelectedVariation(null);
    setSelectedMods([]);
    setModalQuantity(1);
    setIsModLoading(true);
    if (item.variations.length === 1) setSelectedVariation(item.variations[0]);
    try {
      const res = await fetch(`${API_BASE}/modifiers`);
      if (res.ok) {
        const data = await res.json();
        const uniqueModifiers = data.reduce((acc, current) => {
          if (!acc.find(i => i.name.toLowerCase() === current.name.toLowerCase())) {
            return acc.concat([current]);
          }
          return acc;
        }, []);
        setItemModifiers(uniqueModifiers);
      } else {
        setItemModifiers([]);
      }
    } catch (err) {
      setItemModifiers([]);
    } finally {
      setIsModLoading(false);
    }
  };

  const toggleModifier = (mod) => {
    setSelectedMods((prev) =>
      prev.some(m => m.modifier_id === mod.modifier_id)
        ? prev.filter(m => m.modifier_id !== mod.modifier_id)
        : [...prev, mod]
    );
  };

  const confirmAddToCart = () => {
    if (!selectedVariation) return;
    const extraCost = selectedMods.reduce((sum, mod) => sum + parseFloat(mod.price), 0);
    const basePrice = parseFloat(selectedVariation.price);
    const uniqueCartId = `${selectedVariation.variation_id}-${selectedMods.map(m => m.modifier_id).sort().join('-')}`;
    const customItem = {
      item_id: selectedItem.item_id,
      item_name: selectedItem.item_name,
      image_url: selectedItem.image_url,
      variation_id: selectedVariation.variation_id,
      size_name: selectedVariation.size_name,
      cart_id: uniqueCartId,
      price: basePrice + extraCost,
      modifiers: selectedMods,
      quantity: modalQuantity
    };
    addToCart(customItem);
    setSelectedItem(null);
  };

  const menuContent = useMemo(() => {
    return menuData.map((category) => {
      const stringId = String(category.category_id);
      return (
        <section key={stringId} id={stringId} ref={(el) => { if (el) sectionRefs.current[stringId] = el; }} className="mb-12 md:mb-16 last:mb-40">
          <div className="flex items-center gap-3 md:gap-4 mb-4 md:mb-6">
            <h2 className="text-xl sm:text-2xl md:text-3xl font-black tracking-tighter text-white uppercase">{category.name}</h2>
            <div className="h-[2px] flex-1 bg-gradient-to-r from-zinc-900 to-transparent" />
          </div>
          <div className="grid grid-cols-4 gap-1 sm:gap-2 md:gap-3">
            {category.products.map((item, idx) => {
              const minPrice = Math.min(...item.variations.map(v => parseFloat(v.price)));
              return (
                <motion.div
                  key={item.item_id}
                  onClick={() => openItemModal(item)}
                  className="group relative flex flex-col h-full bg-linear-to-br from-zinc-900/10 to-transparent hover:to-[#e0457b]/5 p-1 sm:p-2 md:p-3 rounded-lg sm:rounded-xl md:rounded-2xl transition-all duration-700 ring-1 ring-zinc-900 hover:ring-[#e0457b]/20 cursor-pointer"
                  initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true, margin: "-50px" }} transition={{ duration: 0.6, delay: idx * 0.02 }}
                >
                  <div className="aspect-square bg-zinc-950 rounded-md sm:rounded-lg overflow-hidden relative mb-1 sm:mb-2 shadow-md">
                    {/* UPDATED: Using LoremFlickr for real photos in the main menu */}
                    <motion.img 
                      src={item.image_url || `https://loremflickr.com/800/800/food,dish,${encodeURIComponent(item.item_name)}/all`} 
                      alt={item.item_name} 
                      className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-1000 ease-out" 
                    />
                    <div className="absolute inset-0 bg-linear-to-t from-black/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
                  </div>
                  <div className="flex flex-col gap-0.5 sm:gap-1 flex-1">
                    <h3 className="text-[10px] sm:text-xs md:text-sm font-black text-zinc-100 group-hover:text-white transition-colors leading-tight line-clamp-2">{item.item_name}</h3>
                    <div className="flex items-end justify-between mt-auto pt-1 sm:pt-1.5 border-t border-zinc-900/50">
                      <div className="flex flex-col">
                        <span className="text-[6px] sm:text-[8px] text-zinc-500 font-bold uppercase tracking-wide mb-0.5">
                          {item.variations.length > 1 ? 'From' : 'Price'}
                        </span>
                        <p className="text-xs sm:text-sm md:text-base font-black tracking-tighter text-white group-hover:text-[#e0457b] transition-colors duration-500">
                          {minPrice.toLocaleString()} <span className="text-[6px] sm:text-[8px] text-zinc-500 ml-0.5">PKR</span>
                        </p>
                      </div>
                      <div className="w-5 h-5 sm:w-6 sm:h-6 md:w-8 md:h-8 rounded-md sm:rounded-lg md:rounded-xl bg-zinc-900 group-hover:bg-[#e0457b] flex items-center justify-center transition-all duration-500 hover:scale-110 active:scale-95 shadow">
                        <svg className="w-2.5 h-2.5 sm:w-3 sm:h-3 md:w-4 md:h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M12 4v16m8-8H4" /></svg>
                      </div>
                    </div>
                  </div>
                </motion.div>
              );
            })}
          </div>
        </section>
      );
    });
  }, [menuData]);

  if (loading) return <div className="flex min-h-screen bg-black text-white items-center justify-center uppercase tracking-widest text-[10px] opacity-50">Initializing...</div>;
  if (error) return <div className="flex min-h-screen bg-black text-red-500 items-center justify-center p-6 text-center text-sm">{error}</div>;

  return (
    <div className="bg-[#050505] text-white min-h-screen flex flex-col font-sans relative">

      {/* ── MODAL ── */}
      <AnimatePresence>
        {selectedItem && (
          <div className="fixed inset-0 z-[100] flex items-center justify-center p-3 sm:p-4">
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={() => setSelectedItem(null)} className="absolute inset-0 bg-black/80 backdrop-blur-md" />
            <motion.div initial={{ scale: 0.9, y: 20 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.9, y: 20 }} className="relative bg-zinc-900 w-full max-w-md sm:max-w-lg rounded-2xl sm:rounded-[2rem] p-4 sm:p-6 shadow-2xl border border-zinc-800 flex flex-col max-h-[90vh]">
              <button onClick={() => setSelectedItem(null)} className="absolute top-4 right-4 text-zinc-500 hover:text-white text-xl">✕</button>
              <h2 className="text-xl sm:text-2xl font-black italic uppercase mb-1 pr-6">{selectedItem.item_name}</h2>
              <p className="text-base sm:text-lg text-[#e0457b] font-black tracking-tighter border-b border-zinc-800 pb-3 sm:pb-4 mb-3 sm:mb-4">
                {selectedVariation ? parseFloat(selectedVariation.price).toLocaleString() : Math.min(...selectedItem.variations.map(v => parseFloat(v.price))).toLocaleString()} PKR
                <span className="text-[8px] sm:text-[10px] text-zinc-500 font-bold ml-1 tracking-widest uppercase">Base Price</span>
              </p>
              <div data-lenis-prevent="true" className="flex-1 overflow-y-auto no-scrollbar pr-1 pb-2">
                {selectedItem.variations.length > 1 && (
                  <div className="mb-4 sm:mb-6">
                    <p className="text-[8px] sm:text-[10px] text-zinc-400 font-black uppercase tracking-[0.2em] mb-2">Select Size <span className="text-red-500">*</span></p>
                    <div className="grid grid-cols-2 gap-1.5 sm:gap-2">
                      {selectedItem.variations.map(variation => (
                        <button key={variation.variation_id} onClick={() => setSelectedVariation(variation)} className={`py-1.5 sm:py-2 px-2 sm:px-3 rounded-lg sm:rounded-xl border-2 font-bold uppercase transition-all text-left ${selectedVariation?.variation_id === variation.variation_id ? 'border-[#e0457b] bg-[#e0457b]/10 text-white' : 'border-zinc-800 text-zinc-400 hover:border-zinc-600 hover:bg-zinc-800/50'}`}>
                          <span className="block text-[10px] sm:text-xs leading-none">{variation.size_name}</span>
                          <span className="block text-[8px] sm:text-[10px] mt-1 text-zinc-500">{parseFloat(variation.price).toLocaleString()} PKR</span>
                        </button>
                      ))}
                    </div>
                  </div>
                )}
                {isModLoading ? (
                  <p className="text-zinc-500 text-[10px] sm:text-xs uppercase tracking-widest animate-pulse">Loading Customizations...</p>
                ) : itemModifiers.length > 0 ? (
                  <div className="space-y-1.5 sm:space-y-2">
                    <p className="text-[8px] sm:text-[10px] text-zinc-400 font-black uppercase tracking-[0.2em] mb-2">Add-ons & Modifiers</p>
                    {itemModifiers.map((mod) => {
                      const isChecked = selectedMods.some(m => m.modifier_id === mod.modifier_id);
                      return (
                        <div key={mod.modifier_id} onClick={() => toggleModifier(mod)} className={`flex justify-between items-center p-2 sm:p-3 rounded-lg sm:rounded-xl border cursor-pointer transition-all ${isChecked ? 'bg-[#e0457b]/10 border-[#e0457b]' : 'bg-zinc-950 border-zinc-800 hover:border-zinc-700'}`}>
                          <div className="flex items-center gap-2 sm:gap-3">
                            <div className={`w-3.5 h-3.5 sm:w-4 sm:h-4 rounded-full border-2 flex items-center justify-center ${isChecked ? 'border-[#e0457b] bg-[#e0457b]' : 'border-zinc-600'}`}>
                              {isChecked && <div className="w-1.5 h-1.5 sm:w-2 sm:h-2 bg-white rounded-full" />}
                            </div>
                            <span className={`font-bold uppercase text-[10px] sm:text-xs ${isChecked ? 'text-white' : 'text-zinc-300'}`}>{mod.name}</span>
                          </div>
                          <span className="font-bold text-[#e0457b] text-xs sm:text-sm">+ {parseFloat(mod.price)} PKR</span>
                        </div>
                      );
                    })}
                  </div>
                ) : (
                  <p className="text-zinc-500 text-[10px] sm:text-xs italic py-2">No customizations available.</p>
                )}
              </div>
              <div className="pt-3 sm:pt-4 mt-3 sm:mt-4 border-t border-zinc-800 flex gap-2 sm:gap-3">
                <div className="flex items-center bg-zinc-950 rounded-lg sm:rounded-xl border border-zinc-800 px-1 py-0.5">
                  <button onClick={() => setModalQuantity(Math.max(1, modalQuantity - 1))} className="w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center text-zinc-500 hover:text-white transition-colors">
                    <svg className="w-3 h-3 sm:w-4 sm:h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M20 12H4" /></svg>
                  </button>
                  <span className="text-white font-black text-sm sm:text-base w-5 sm:w-6 text-center">{modalQuantity}</span>
                  <button onClick={() => setModalQuantity(modalQuantity + 1)} className="w-6 h-6 sm:w-7 sm:h-7 flex items-center justify-center text-zinc-500 hover:text-white transition-colors">
                    <svg className="w-3 h-3 sm:w-4 sm:h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M12 4v16m8-8H4" /></svg>
                  </button>
                </div>
                <button onClick={confirmAddToCart} disabled={!selectedVariation} className={`flex-1 py-3 sm:py-4 rounded-lg sm:rounded-xl font-black uppercase tracking-widest transition-all flex justify-between items-center px-3 sm:px-4 text-[10px] sm:text-xs ${selectedVariation ? 'bg-[#e0457b] hover:bg-[#c93c6d] text-white shadow-lg active:scale-95' : 'bg-zinc-800 text-zinc-500 cursor-not-allowed'}`}>
                  <span>{selectedVariation ? "Add to Cart" : "Select Size"}</span>
                  {selectedVariation && <span>{((parseFloat(selectedVariation.price) + selectedMods.reduce((s, m) => s + parseFloat(m.price), 0)) * modalQuantity).toLocaleString()} PKR</span>}
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* ── MOBILE CATEGORY BAR ── */}
      <div className="lg:hidden sticky top-[80px] z-30 bg-black/90 backdrop-blur-xl border-b border-zinc-800 w-full">
        <div className="overflow-x-auto no-scrollbar w-full">
          <div className="flex gap-1 px-4 py-3 w-max">
            {menuData.map((cat) => {
              const stringId = String(cat.category_id);
              const isActive = activeCategoryId === stringId;
              return (
                <button
                  key={stringId}
                  onClick={() => scrollToCategory(stringId)}
                  className={`whitespace-nowrap px-4 py-2 rounded-full text-xs font-bold uppercase tracking-wider transition-all ${
                    isActive
                      ? 'bg-[#e0457b] text-white shadow-md'
                      : 'bg-zinc-900 text-zinc-400 hover:bg-zinc-800 hover:text-zinc-200'
                  }`}
                >
                  {cat.name}
                </button>
              );
            })}
          </div>
        </div>
      </div>

      {/* ── LEFT SIDEBAR ── */}
      <aside data-lenis-prevent className="fixed left-0 border-r border-zinc-900 bg-black/40 backdrop-blur-2xl hidden lg:flex flex-col z-40 overflow-y-auto no-scrollbar" style={{ width: `${SIDEBAR_WIDTH}px`, top: `${TOP_NAV_HEIGHT}px`, height: `calc(100vh - ${TOP_NAV_HEIGHT}px)`, padding: '0px 24px 40px 24px' }}>
        <div className="relative flex flex-col gap-1.5">
          <motion.div className="absolute left-0 w-full bg-[#e0457b]/10 border-l-4 border-[#e0457b] rounded-r-2xl z-0" animate={{ top: highlightStyle.top, height: highlightStyle.height, opacity: highlightStyle.opacity }} transition={{ type: "spring", stiffness: 280, damping: 28 }} />
          {menuData.map((cat) => {
            const stringId = String(cat.category_id);
            const isActive = activeCategoryId === stringId;
            return (
              <div key={stringId} ref={(el) => { if (el) sidebarRefs.current[stringId] = el; }} onClick={() => scrollToCategory(stringId)} className={`relative z-10 px-6 py-4 cursor-pointer transition-all duration-500 flex items-center ${isActive ? "text-[#e0457b] font-bold" : "text-zinc-500 hover:text-zinc-200"}`}>
                <div className={`w-2 h-2 rounded-full bg-[#e0457b] mr-4 shadow-[0_0_10px_#e0457b] ${isActive ? "opacity-100 scale-100" : "opacity-0 scale-0"}`} />
                <p className="text-[15px] tracking-widest leading-none uppercase font-bold">{cat.name}</p>
              </div>
            );
          })}
        </div>
      </aside>

      {/* ── RIGHT SIDEBAR ── */}
      <aside className="fixed right-0 border-l border-zinc-900 bg-black/40 backdrop-blur-2xl hidden xl:flex flex-col z-40" style={{ width: `${CART_WIDTH}px`, top: `${TOP_NAV_HEIGHT}px`, height: `calc(100vh - ${TOP_NAV_HEIGHT}px)`, padding: '0px 32px 40px 32px' }}>
        <div className="flex flex-col h-full uppercase tracking-[0.2em] font-black text-[11px]">
          <div className="flex justify-between pb-8 border-b border-zinc-900">
            <span className="text-zinc-500 text-xl">Your Selection</span>
            <span className="text-[#e0457b] animate-pulse">{totalItems} {totalItems === 1 ? 'ITEM' : 'ITEMS'}</span>
          </div>
          <div className="flex-1 overflow-y-auto no-scrollbar py-6 space-y-6">
            <AnimatePresence initial={false}>
              {cartItems.length > 0 ? (
                cartItems.map((item) => (
                  <motion.div key={item.cart_id || item.variation_id} initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }} className="flex flex-col gap-4 p-4 rounded-3xl bg-zinc-900/30 border border-zinc-900 group">
                    <div className="flex gap-4">
                      <div className="w-16 h-16 rounded-2xl bg-zinc-950 overflow-hidden flex-shrink-0 ring-1 ring-zinc-800">
                        {/* UPDATED: Using LoremFlickr for real photos in the cart */}
                        <img 
                          src={item.image_url || `https://loremflickr.com/100/100/food,dish,${encodeURIComponent(item.item_name)}/all`} 
                          alt={item.item_name} 
                          className="w-full h-full object-cover" 
                        />
                      </div>
                      <div className="flex-1 min-w-0">
                        <h4 className="text-[15px] text-white leading-tight mb-1 truncate">{item.item_name}</h4>
                        {item.modifiers && item.modifiers.length > 0 && (
                          <div className="flex flex-wrap gap-1 mb-2">
                            {item.size_name && <span className="text-[8px] bg-[#e0457b] text-white px-1.5 py-0.5 rounded uppercase border border-[#e0457b]">{item.size_name}</span>}
                            {item.modifiers.map(mod => <span key={mod.modifier_id} className="text-[8px] bg-zinc-800 text-zinc-400 px-1.5 py-0.5 rounded uppercase border border-zinc-700">+{mod.name}</span>)}
                          </div>
                        )}
                        <p className="text-lg font-sans tracking-tight text-[#e0457b]">{(parseFloat(item.price) * item.quantity).toLocaleString()} PKR</p>
                      </div>
                    </div>
                    <div className="flex items-center justify-between">
                      <div className="flex items-center bg-black/50 rounded-xl px-2 py-1 gap-4 ring-1 ring-zinc-800">
                        <button onClick={() => updateQuantity(item.cart_id || item.variation_id, item.quantity - 1)} className="w-6 h-6 flex items-center justify-center text-zinc-500 hover:text-white transition-colors">
                          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M20 12H4" /></svg>
                        </button>
                        <span className="text-white font-sans text-xs min-w-[12px] text-center">{item.quantity}</span>
                        <button onClick={() => updateQuantity(item.cart_id || item.variation_id, item.quantity + 1)} className="w-6 h-6 flex items-center justify-center text-zinc-500 hover:text-white transition-colors">
                          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M12 4v16m8-8H4" /></svg>
                        </button>
                      </div>
                      <button onClick={() => removeFromCart(item.cart_id || item.variation_id)} className="text-[10px] text-red-500/50 hover:text-red-500 transition-colors font-black uppercase">Remove</button>
                    </div>
                  </motion.div>
                ))
              ) : (
                <div className="flex flex-col items-center justify-center h-full space-y-6 opacity-20 filter grayscale py-20">
                  <div className="w-20 h-20 border-2 border-dashed border-zinc-800 rounded-3xl flex items-center justify-center transform rotate-12">
                    <svg className="w-8 h-8 text-zinc-500" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" /></svg>
                  </div>
                  <p className="tracking-[0.3em]">Empty</p>
                </div>
              )}
            </AnimatePresence>
          </div>
          <div className="pt-8 border-t border-zinc-900 space-y-6 bg-[#050505]/80 backdrop-blur-sm -mx-2 px-2">
            <div className="flex justify-between items-center text-zinc-500 font-bold">
              <span>Subtotal</span>
              <span className="font-sans font-normal">{subtotal.toLocaleString()} PKR</span>
            </div>
            <div className="flex justify-between items-center text-lg text-white">
              <span className="tracking-widest">Total</span>
              <span className="text-[#e0457b] font-sans font-black">{subtotal.toLocaleString()} PKR</span>
            </div>
            <button onClick={() => navigate('/cart')} disabled={cartItems.length === 0} className={`w-full py-6 text-xl rounded-2xl transition-all border font-black tracking-[0.2em] transform active:scale-95 ${cartItems.length > 0 ? "bg-[#e0457b] text-white border-[#e0457b] hover:shadow-[0_0_30px_rgba(224,69,123,0.3)] shadow-xl" : "bg-zinc-900/50 text-zinc-700 border-zinc-800 cursor-not-allowed"}`}>
              Begin Checkout
            </button>
          </div>
        </div>
      </aside>

      {/* ── MAIN CONTENT ── */}
      <main className="lg:ml-[340px] xl:mr-[360px] flex-1 px-1.5 sm:px-3 md:px-5 pt-0 pb-24 xl:pb-20 min-h-screen">
        <div className="max-w-[1600px] mx-auto">
          {menuContent}
        </div>
      </main>
    </div>
  );
};

const globalStyles = `
  .no-scrollbar::-webkit-scrollbar { display: none; }
  .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
`;
if (typeof document !== 'undefined') {
  const style = document.createElement('style');
  style.textContent = globalStyles;
  document.head.appendChild(style);
}

export default Menu;