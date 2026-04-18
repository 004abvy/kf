import React, { useState, useEffect } from "react";
import { useCart } from "../context/CartContext";
import { motion } from "framer-motion";

const HERO_IMG = "https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=900&q=80";
const API_BASE = import.meta.env.VITE_API_URL + '/api';
const FALLBACK_ITEM_IMG = "https://placehold.co/800x600/111111/ffffff?text=No+Image";

export default function MostWanted() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const { cartItems, addToCart } = useCart();

  useEffect(() => {
    const loadFeaturedItems = async () => {
      try {
        const catResponse = await fetch(`${API_BASE}/categories`);
        if (!catResponse.ok) throw new Error("Connection failed");
        const categories = await catResponse.json();

        const allProductsNested = await Promise.all(
          categories.map(async (cat) => {
            try {
              const res = await fetch(`${API_BASE}/items/${cat.category_id}`);
              const items = res.ok ? await res.json() : [];
              const grouped = Array.isArray(items) ? items.reduce((acc, curr) => {
                if (!acc[curr.item_id]) acc[curr.item_id] = { ...curr };
                return acc;
              }, {}) : {};
              return Object.values(grouped);
            } catch (err) {
              return [];
            }
          })
        );

        const allProducts = allProductsNested.flat();
        setProducts(allProducts.slice(0, 10));
      } catch (err) {
        console.error("Failed to load featured items:", err);
      } finally {
        setLoading(false);
      }
    };
    loadFeaturedItems();
  }, []);

  const getItemQuantity = (variationId) => {
    const item = cartItems?.find((i) => i.variation_id === variationId);
    return item ? item.quantity : 0;
  };

  // --- Framer Motion Animation Variants ---
  const containerVariants = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: { staggerChildren: 0.15 }
    }
  };

  const cardVariants = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0, transition: { type: "spring", stiffness: 80, damping: 15 } }
  };

  // Shared function to render individual product details (keeps code DRY)
  const renderProductContent = (product, qty) => (
    <>
      <div className="w-full aspect-[4/3] relative overflow-hidden bg-[#1a1a1a]">
        <img
          src={product.image_url || FALLBACK_ITEM_IMG}
          alt={product.item_name}
          onError={(e) => {
            if (e.currentTarget.src !== FALLBACK_ITEM_IMG) {
              e.currentTarget.src = FALLBACK_ITEM_IMG;
            }
          }}
          className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent lg:hidden"></div>
      </div>

      <div className="p-4 md:p-5 flex flex-col lg:flex-row justify-between lg:items-end flex-1 bg-[#111] lg:bg-black/50 z-10 -mt-2 lg:mt-0">
        <div className="overflow-hidden">
          <h4 className="text-xl lg:text-lg font-bold text-zinc-100 leading-tight mb-2 lg:mb-1 truncate" title={product.item_name}>
            {product.item_name}
          </h4>
          <p className="text-xl lg:text-lg font-black lg:font-medium text-white lg:text-zinc-400 flex items-baseline gap-1 mt-auto lg:mt-0">
            {Math.floor(product.price).toLocaleString()}
            <span className="text-xs lg:text-[10px] text-[#ff007f] lg:text-zinc-400">PKR</span>
          </p>
        </div>

        <motion.button
          whileTap={{ scale: 0.9 }}
          onClick={() => addToCart(product)}
          className={`mt-4 lg:mt-0 self-end lg:self-auto flex-shrink-0 flex items-center justify-center w-10 h-10 lg:w-8 lg:h-8 rounded-full shadow-md lg:shadow-none transition-colors ${
            qty > 0 
              ? "bg-[#ff007f] text-white font-bold lg:text-xs" 
              : "bg-white text-black hover:bg-gray-200 lg:hover:bg-[#ff007f] lg:hover:text-white"
          }`}
        >
          {qty > 0 ? qty : (
            <svg fill="none" viewBox="0 0 24 24" stroke="currentColor" className="w-5 h-5 lg:w-3.5 lg:h-3.5 stroke-2">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
            </svg>
          )}
        </motion.button>
      </div>
    </>
  );

  return (
    <section className="bg-black text-white py-10 md:py-16 px-4 lg:px-12 font-sans min-h-screen">
      <div className="max-w-[1650px] mx-auto">
        
        {/* COMMON HEADER */}
        <motion.h2 
          initial={{ opacity: 0, y: -20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-3xl md:text-5xl lg:text-6xl font-black uppercase tracking-[0.15em] mb-8 lg:mb-20 lg:ml-2"
        >
          Most Wanted
        </motion.h2>

        {/* ========================================= */}
        {/* MOBILE & TABLET LAYOUT (Carousel)         */}
        {/* Visible only below 'lg' screens           */}
        {/* ========================================= */}
        <div className="block lg:hidden">
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="relative w-full h-[250px] md:h-[400px] rounded-3xl overflow-hidden shadow-2xl mb-8"
          >
            <img src={HERO_IMG} alt="Popular dishes" className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-r from-black/80 via-black/40 to-transparent p-6 md:p-12 flex flex-col justify-center">
              <h3 className="text-2xl md:text-4xl font-extrabold uppercase tracking-wide leading-tight mb-4 text-[#ff007f]">
                Fan Favorites
              </h3>
              <p className="text-sm md:text-lg text-zinc-200 mb-6 max-w-sm">
                Discover the dishes our customers can't get enough of.
              </p>
              <button className="self-start px-6 py-3 rounded-full bg-[#ff007f] text-white font-bold tracking-widest text-xs uppercase shadow-lg">
                Order Now
              </button>
            </div>
          </motion.div>

          {loading ? (
            <div className="h-64 flex items-center justify-center text-zinc-500 animate-pulse font-bold uppercase tracking-widest">Loading...</div>
          ) : (
            <motion.div 
              variants={containerVariants} initial="hidden" whileInView="show" viewport={{ once: true }}
              className="flex overflow-x-auto gap-4 md:gap-8 pb-8 pt-4 snap-x snap-mandatory [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]"
            >
              {products.map((product) => (
                <motion.div
                  variants={cardVariants} whileHover={{ y: -5 }} key={product.variation_id}
                  className="min-w-[280px] md:min-w-[320px] max-w-[280px] md:max-w-[320px] snap-center bg-[#111] border border-zinc-800 rounded-2xl overflow-hidden flex flex-col group"
                >
                  {renderProductContent(product, getItemQuantity(product.variation_id))}
                </motion.div>
              ))}
            </motion.div>
          )}
        </div>


        {/* ========================================= */}
        {/* DESKTOP LAYOUT (Side-by-Side Grid)        */}
        {/* Visible only on 'lg' screens and up       */}
        {/* ========================================= */}
        <div className="hidden lg:grid grid-cols-12 gap-16 xl:gap-24 items-start">
          
          {/* Sticky Left Hero */}
          <div className="col-span-5 sticky top-[150px] h-[75vh] rounded-3xl overflow-hidden border border-zinc-800 shadow-2xl group">
            <img src={HERO_IMG} alt="Popular dishes" className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" />
            <div className="absolute inset-0 flex flex-col justify-end p-12 bg-gradient-to-t from-black/95 via-black/40 to-transparent">
              <p className="text-3xl xl:text-4xl font-extrabold uppercase tracking-wide leading-tight mb-6 max-w-[90%]">
                See Our Most Popular Products
              </p>
              <div>
                <button className="px-8 py-3 rounded-full bg-transparent border-2 border-[#ff007f] text-white font-bold tracking-widest text-sm uppercase transition-all duration-300 hover:bg-[#ff007f]">
                  Order Now
                </button>
              </div>
            </div>
          </div>

          {/* Scrolling Right Grid */}
          <div className="col-span-7">
            {loading ? (
              <div className="h-64 flex items-center justify-center text-zinc-500 animate-pulse font-bold uppercase tracking-widest">Loading...</div>
            ) : (
              <motion.div 
                variants={containerVariants} initial="hidden" whileInView="show" viewport={{ once: true, margin: "-100px" }}
                className="grid grid-cols-2 gap-6"
              >
                {products.map((product) => (
                  <motion.div
                    variants={cardVariants} whileHover={{ y: -5 }} key={product.variation_id}
                    className="bg-[#111] border border-zinc-800 rounded-2xl overflow-hidden flex flex-col group hover:border-[#ff007f] transition-colors duration-300"
                  >
                    {renderProductContent(product, getItemQuantity(product.variation_id))}
                  </motion.div>
                ))}
              </motion.div>
            )}
          </div>

        </div>
      </div>
    </section>
  );
}