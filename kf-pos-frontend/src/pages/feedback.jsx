import { useState, useEffect } from "react";

const reviews = [
  { 
    id: 1, 
    name: "Zubair Khan", 
    rating: 5, 
    text: "The Loaded Fries are absolutely insane! Properly topped with cheese and chunks of chicken. Best late-night snack in the city.", 
    original: "Yaar loaded fries ka maza hi agaya, full heavy scene hai!", 
    translated: true 
  },
  { 
    id: 2, 
    name: "Sara Ahmed", 
    rating: 5, 
    text: "Finally found a place that actually puts enough toppings on their Pizza. The crust was soft and the flavors were spot on.", 
    translated: false 
  },
  { 
    id: 3, 
    name: "Hassan Raza", 
    rating: 5, 
    text: "Best Shawarma in town. The chicken was juicy and the garlic sauce was legit. Not like those dry ones you get everywhere else. Highly recommend their spicy variant!", 
    translated: false 
  },
  { 
    id: 4, 
    name: "Mariam Malik", 
    rating: 5, 
    text: "Ordered the Pizza and a Platter for a house party. Delivery was right on time and everything arrived piping hot. Everyone loved the dips!", 
    translated: false 
  },
  { 
    id: 5, 
    name: "Bilal Sheikh", 
    rating: 4, 
    text: "Great value for money. The deal for 2 people was more than enough. The only thing is they should add more napkins in the bag!", 
    original: "Bhai quantity bohat fit hai, maza agaya kha k.", 
    translated: true 
  },
  { 
    id: 6, 
    name: "Anum Pervez", 
    rating: 5, 
    text: "The packaging is so clean and premium. The pizza box is sturdy and the fries didn't get soggy at all during delivery. 10/10 for hygiene and taste.", 
    translated: false 
  },
];

const StarRating = ({ rating }) => (
  <div className="flex gap-1">
    {[1, 2, 3, 4, 5].map((star) => (
      <svg
        key={star}
        width="16"
        height="20"
        viewBox="0 0 24 24"
        fill={star <= rating ? "#e91e8c" : "none"}
        stroke={star <= rating ? "#e91e8c" : "#555"}
        strokeWidth="2"
      >
        <polygon points="12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26" />
      </svg>
    ))}
  </div>
);

export default function Feedback() {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isTransitioning, setIsTransitioning] = useState(true);
  const [isPaused, setIsPaused] = useState(false);
  const [cardsPerView, setCardsPerView] = useState(3);

  const doubled = [...reviews, ...reviews];

  // Dynamically set cards per view based on screen width
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth < 640) setCardsPerView(1); // Mobile
      else if (window.innerWidth < 1024) setCardsPerView(2); // Tablet
      else setCardsPerView(3); // Desktop
    };

    handleResize(); // Initial call
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  // Handle automatic scrolling
  useEffect(() => {
    if (isPaused) return;

    const timer = setInterval(() => {
      setIsTransitioning(true);
      setCurrentIndex((prev) => prev + 1);
    }, 3500);

    return () => clearInterval(timer);
  }, [isPaused]);

  // Handle infinite loop logic
  useEffect(() => {
    // Correct loop reset point for any number of cards visible
    if (currentIndex >= reviews.length) {
      const timeout = setTimeout(() => {
        setIsTransitioning(false);
        setCurrentIndex(0);
      }, 500);
      return () => clearTimeout(timeout);
    }
  }, [currentIndex]);

  // Calculate standard card width based on Tailwind classes used below
  // For mobile w-full (1), tablet w-1/2 (2), desktop w-1/3 (3)
  const translationPercentage = 100 / cardsPerView;

  return (
    <div className="bg-black font-sans overflow-hidden -mt-10 py-8 px-4 md:px-10">
      <div className="px-4 md:px-12 mb-10 max-w-8xl mx-auto">
        <h1 className="text-white text-3xl md:text-5xl font-bold tracking-wider mb-4 uppercase">
          Your opinion matters.
        </h1>

        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-6 flex-wrap">
          <div className="flex items-center gap-3">
            <StarRating rating={5} />
            <span className="text-white font-semibold text-sm">4.5</span>
            <a
              href="#"
              className="text-pink-600 text-lg border-b border-pink-600 hover:text-pink-700 transition-colors"
            >
              102 Google Reviews
            </a>
          </div>

          <button className="border-2 border-white text-white px-6 py-2.5 rounded-full font-medium text-lg tracking-wide hover:bg-white hover:text-black transition-all duration-200">
            Leave a comment
          </button>
        </div>
      </div>

      <div
        className="overflow-hidden w-full px-4 md:px-10 pb-3 box-border"
        onMouseEnter={() => setIsPaused(true)}
        onMouseLeave={() => setIsPaused(false)}
      >
        <div
          className="flex w-full"
          style={{
            transform: `translateX(-${currentIndex * translationPercentage}%)`,
            transition: isTransitioning ? "transform 0.5s ease-in-out" : "none",
            willChange: "transform",
          }}
        >
          {doubled.map((review, i) => (
            <div
              key={`${review.id}-${i}`}
              // Responsive widths: full on mobile, half on tablet, third on desktop
              className="flex-shrink-0 w-full sm:w-1/2 lg:w-1/3 px-2.5 box-border"
            >
              <div className="bg-gray-950 border border-gray-800 rounded-xl p-5 md:p-6 flex flex-col justify-between h-full min-h-[300px]">
                <div>
                  {review.translated && (
                    <p className="text-gray-500 text-xs mb-1.5 italic">
                      (Translated by Google)
                    </p>
                  )}
                  {/* Standard text size on mobile to stop stretching, increased on desktop */}
                  <p className="text-gray-200 text-base md:text-xl leading-relaxed mb-4">
                    {review.text}
                  </p>
                  {review.original && (
                    <p className="text-gray-600 text-sm mb-3 italic">
                      (Original) {review.original}
                    </p>
                  )}
                </div>

                {/* Separator and Bottom info */}
                <div className="mt-4 border-t border-gray-800 pt-4">
                  <StarRating rating={review.rating} />
                  <p className="text-white font-semibold text-lg md:text-xl mt-2">
                    {review.name}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}