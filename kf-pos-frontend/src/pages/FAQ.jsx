import { useState, useEffect } from 'react';
import { ChevronDown } from 'lucide-react';
import { StaggerText, FadeUpText, FadeInBlock } from '../components/AnimatedText';

export default function FAQ() {
  const [activeTab, setActiveTab] = useState('all');
  const [expandedId, setExpandedId] = useState(null);
  const [isTriggered, setIsTriggered] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      const TARGET_PIXEL = 100; 
      if (window.scrollY >= TARGET_PIXEL) {
        setIsTriggered(true);
      }
    };

    handleScroll();
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

const faqData = {
  delivery: [
    { 
      id: 1, 
      question: 'Where do you deliver?', 
      answer: 'We deliver all across the city! From DHA and Gulberg to Johar Town and Bahria. Just enter your location to see the nearest branch.' 
    },
    { 
      id: 2, 
      question: 'How long does my Pizza take to arrive?', 
      answer: 'Our goal is to get your food to you in 30-40 minutes. We bake fresh, so quality takes a few extra minutes but it is worth the wait!' 
    },
    { 
      id: 3, 
      question: 'What are your delivery timings?', 
      answer: 'We are open from 12 PM to 1 AM daily. On Fridays and Saturdays, we stay open until 3 AM for those late-night cravings.' 
    },
  ],
  menu: [
    { 
      id: 4, 
      question: 'Are your sauces made in-house?', 
      answer: 'Yes! Our signature Garlic Mayo and Spicy Dynamite sauces are made fresh daily in our kitchen.' 
    },
    { 
      id: 5, 
      question: 'Do you offer any family deals?', 
      answer: 'Bilkul! We have special "Bachat Deals" for families and large groups that include Pizzas, Loaded Fries, and drinks at a discounted price.' 
    },
    { 
      id: 6, 
      question: 'Is the meat Halal?', 
      answer: 'Yes, 100%. We only use premium, Halal-certified chicken and beef from reputable local suppliers.' 
    },
  ],
};

  const renderFaqItem = (item) => (
    <div
      key={item.id}
      className="border border-gray-800 rounded-xl overflow-hidden transition-all duration-300 hover:border-pink-500/50 hover:bg-white/[0.02]"
    >
      <button
        onClick={() => setExpandedId(expandedId === item.id ? null : item.id)}
        className="w-full px-5 py-4 md:px-6 md:py-5 flex justify-between items-center text-left font-semibold"
      >
        <span className={`text-base md:text-xl transition-colors duration-300 ${expandedId === item.id ? 'text-pink-500' : 'text-white'}`}>
          {item.question}
        </span>
        <ChevronDown
          className={`w-5 h-5 text-pink-500 transition-transform duration-300 ${expandedId === item.id ? 'rotate-180' : ''}`}
        />
      </button>
      
      <div className={`grid transition-all duration-300 ease-in-out ${expandedId === item.id ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0'}`}>
        <div className="overflow-hidden">
          <div className="px-5 pb-5 md:px-6 text-gray-400 text-sm md:text-lg leading-relaxed">
            {item.answer}
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-black text-white px-6 py-12 md:p-16 lg:p-24 font-sans">
      <div className="max-w-[1600px] mx-auto grid grid-cols-1 lg:grid-cols-[0.8fr_1.2fr] gap-12 lg:gap-24 xl:gap-32 items-start">
        
        {/* LEFT COLUMN: Title & Description */}
        <div className="lg:sticky lg:top-40 h-auto lg:min-h-[300px]">
          {isTriggered && (
            <div className="space-y-4 md:space-y-6">
              <StaggerText 
                as="h2" 
                className="text-5xl md:text-7xl lg:text-8xl xl:text-[100px] font-black uppercase leading-none tracking-tighter" 
                text="FAQ" 
              />
              <FadeUpText delay={0.2} as="p" className="text-lg md:text-xl lg:text-2xl text-gray-400 font-medium max-w-md">
                If the answer isn't here, contact us and we'll get back to you soon.
              </FadeUpText>
            </div>
          )}
        </div>

        {/* RIGHT COLUMN: Tabs and Questions */}
        <div className="w-full">
          {isTriggered && (
            <FadeInBlock delay={0.4} className="w-full">
              {/* Category Tabs */}
              <div className="flex flex-wrap gap-2 md:gap-4 mb-12 md:mb-16">
                {['all', 'delivery', 'menu'].map((tab) => (
                  <button
                    key={tab}
                    onClick={() => setActiveTab(tab)}
                    className={`px-6 py-2 md:px-8 md:py-3 text-sm md:text-lg rounded-full font-bold capitalize transition-all duration-300 ${
                      activeTab === tab
                        ? 'bg-white text-black'
                        : 'border border-gray-700 text-gray-400 hover:border-gray-500 hover:text-white'
                    }`}
                  >
                    {tab === 'menu' ? 'Menu & Food' : tab}
                  </button>
                ))}
              </div>

              {/* FAQ List */}
              <div className="space-y-16">
                {(activeTab === 'all' || activeTab === 'delivery') && (
                  <div>
                    <h3 className="text-2xl md:text-3xl font-black text-white mb-6 uppercase tracking-widest border-l-4 border-pink-500 pl-4">
                      Delivery
                    </h3>
                    <div className="space-y-4">
                      {faqData.delivery.map(renderFaqItem)}
                    </div>
                  </div>
                )}

                {(activeTab === 'all' || activeTab === 'menu') && (
                  <div>
                    <h3 className="text-2xl md:text-3xl font-black text-white mb-6 uppercase tracking-widest border-l-4 border-pink-500 pl-4">
                      Menu & Food
                    </h3>
                    <div className="space-y-4">
                      {faqData.menu.map(renderFaqItem)}
                    </div>
                  </div>
                )}
              </div>
            </FadeInBlock>
          )}
        </div>
      </div>
    </div>
  );
}