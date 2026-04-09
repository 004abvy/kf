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
      { id: 1, question: 'Where do you deliver?', answer: 'We deliver to all areas within the city and surrounding regions. Contact us for specific delivery zones.' },
      { id: 2, question: 'How long does delivery take?', answer: 'Standard delivery takes 30-45 minutes depending on distance and current order volume.' },
      { id: 3, question: 'What are your delivery hours?', answer: 'We deliver from 11 AM to 11 PM daily. Orders must be placed at least 15 minutes before closure.' },
      { id: 4, question: 'How much is the delivery fee outside Yerevan?', answer: 'Delivery fees outside Yerevan start at $5 and increase based on distance.' },
    ],
    menu: [
      { id: 5, question: 'Do you have vegetarian options?', answer: 'Yes! We offer several vegetarian rolls and vegan options. Check our menu for the full selection.' },
      { id: 6, question: 'How fresh is the sushi?', answer: 'All sushi is prepared fresh to order using the highest quality ingredients. We source fish daily.' },
      { id: 7, question: 'Do you offer spicy rolls?', answer: 'Absolutely! We have several spicy options with varying heat levels like our Dragon Roll.' },
      { id: 8, question: 'Do you use raw fish?', answer: 'Yes, we use sushi-grade raw fish in many rolls, handled with the utmost care.' },
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
      <div className="max-w-[1400px] mx-auto grid grid-cols-1 lg:grid-cols-[0.8fr_1.2fr] gap-12 lg:gap-24 xl:gap-32 items-start">
        
        {/* LEFT COLUMN: Title & Description */}
        <div className="lg:sticky lg:top-32 h-auto lg:min-h-[300px]">
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