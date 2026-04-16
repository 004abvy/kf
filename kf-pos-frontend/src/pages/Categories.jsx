import { useState, useEffect } from "react";

const API_URL = import.meta.env.VITE_API_URL;
import { StaggerText } from "../components/AnimatedText";

/* ─── Data ─────────────────────────────────────────────────── */
/* Categories data will be fetched from backend */

/* ─── CSS keyframes and foolproof layout styles ────────────── */
const STYLES = `
  @keyframes marquee-left {
    0%   { transform: translateX(0); }
    100% { transform: translateX(-50%); }
  }
  @keyframes marquee-right {
    0%   { transform: translateX(-50%); }
    100% { transform: translateX(0); }
  }
  .marquee-track {
    display: flex;
    gap: 8px; 
    width: max-content;
    will-change: transform;
  }
  .marquee-wrap {
    overflow: hidden;
    width: 100%;
  }

  /* PURE CSS SIZING (Bypasses Tailwind configuration errors) */
  .cat-card {
    position: relative;
    flex-shrink: 0;
    background-color: #111;
    overflow: hidden;
    cursor: default;
    border-radius: 12px;
    width: 180px;
    height: 120px;
  }
  .cat-title {
    position: absolute;
    margin: 0;
    font-weight: bold;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: white;
    z-index: 10;
    line-height: 1.1;
    top: 10px;
    left: 12px;
    font-size: 11px;
    max-width: 90px;
  }
  .cat-img-wrap {
    position: absolute;
    border-radius: 50%;
    overflow: hidden;
    right: -4px;
    bottom: -4px;
    width: 95px;
    height: 75px;
    background-color: #333; /* Fallback gray circle if network blocks image */
  }

  @media (min-width: 640px) {
    .marquee-track { gap: 12px; }
    .cat-card { width: 240px; height: 160px; border-radius: 18px; }
    .cat-title { top: 16px; left: 16px; font-size: 14px; max-width: 120px; }
    .cat-img-wrap { width: 140px; height: 110px; }
  }
  @media (min-width: 768px) {
    .marquee-track { gap: 16px; }
    .cat-card { width: 350px; height: 250px; }
    .cat-title { top: 22px; left: 24px; font-size: 18px; max-width: 140px; }
    .cat-img-wrap { right: -10px; bottom: -6px; width: 200px; height: 160px; }
  }

  .marquee-track.left  { animation: marquee-left  28s linear infinite; }
  .marquee-track.right { animation: marquee-right 28s linear infinite; }
  .marquee-track.paused { animation-play-state: paused; }
`;

/* ─── Card ─────────────────────────────────────────────────── */
function CategoryCard({ title, img, onEnter, onLeave }) {
  const [hovered, setHovered] = useState(false);

  return (
    <div
      onMouseEnter={() => { setHovered(true);  onEnter && onEnter(); }}
      onMouseLeave={() => { setHovered(false); onLeave && onLeave(); }}
      className="cat-card"
      style={{
        border: hovered
          ? "1px solid rgba(255,255,255,0.25)"
          : "1px solid rgba(255,255,255,0.08)",
        transition: "border-color 0.35s ease",
      }}
    >
      {/* Label */}
      <p className="cat-title" style={{ fontFamily: "'Montserrat', sans-serif" }}>
        {title}
      </p>

      {/* Oval food image */}
      <div 
        className="cat-img-wrap"
        style={{
          transform: hovered ? "scale(1.07)" : "scale(1)",
          transition: "transform 0.45s cubic-bezier(0.34,1.56,0.64,1)",
        }}
      >
        <img
          src={img}
          alt={title}
          draggable={false}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            filter: hovered ? "brightness(1.1)" : "brightness(0.9)",
            transition: "filter 0.35s ease",
          }}
        />
      </div>
    </div>
  );
}

/* ─── Infinite marquee row ─────────────────────────────────── */
function MarqueeRow({ items, direction }) {
  const [paused, setPaused] = useState(false);
  const doubled = [...items, ...items];

  return (
    <div className="marquee-wrap">
      <div className={`marquee-track ${direction} ${paused ? "paused" : ""}`}>
        {doubled.map((cat, i) => (
          <CategoryCard
            key={`${cat.id}-${i}`}
            title={cat.title}
            img={cat.img}
            onEnter={() => setPaused(true)}
            onLeave={() => setPaused(false)}
          />
        ))}
      </div>
    </div>
  );
}

/* ─── Page ─────────────────────────────────────────────────── */
export default function CategoriesPage() {
  const [rowTop, setRowTop] = useState([]);
  const [rowBottom, setRowBottom] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadCategories = async () => {
      try {
        const res = await fetch(`${API_URL}/api/categories`);
        if (!res.ok) {
          throw new Error(`Failed to load categories (${res.status})`);
        }
        const data = await res.json();

        const formatted = (Array.isArray(data) ? data : []).map((cat) => ({
          id: cat.category_id,
          title: cat.name,
          img: cat.image_url || `https://placehold.co/400x300/111/fff?text=${encodeURIComponent(cat.name)}`
        }));

        const mid = Math.ceil(formatted.length / 2);
        setRowTop(formatted.slice(0, mid));
        setRowBottom(formatted.slice(mid));
      } catch (err) {
        console.error("Failed to load categories:", err);
      } finally {
        setLoading(false);
      }
    };
    loadCategories();
  }, []);

  if (loading) return null;
  
  return (
    <div style={{
      background: "#000",
      padding: "60px 0 100px 0", 
      minHeight: "100vh", 
      fontFamily: "'Montserrat', sans-serif",
      color: "#fff",
      overflow: "hidden",
    }}>
      <style>{STYLES}</style>
      <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700;900&display=swap" />

      {/* Title */}
      <div style={{ paddingLeft: "clamp(16px, 6vw, 100px)", marginBottom: "20px" }}>
        <div style={{ margin: 0, fontSize: "clamp(24px, 5vw, 56px)", fontWeight: 900, letterSpacing: "0.04em", textTransform: "uppercase", lineHeight: 1 }}>
          <StaggerText text="OUR CATEGORIES" as="span" />
        </div>
      </div>

      {/* Row 1 */}
      <div style={{ marginBottom: "8px" }}>
        <MarqueeRow items={rowTop} direction="left" />
      </div>

      {/* Row 2 */}
      <MarqueeRow items={rowBottom} direction="right" />
    </div>
  );
}
