import { Camera, MessageCircle } from 'lucide-react';
import { FadeUpText } from './AnimatedText';

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-black text-white border-t border-gray-900 font-sans w-full overflow-hidden">
      <div className="px-6 md:px-20 lg:px-32 pt-16 md:pt-32 pb-12 max-w-[120rem] mx-auto">
        
        {/* Main Grid Logic */}
        <div className="flex flex-col lg:grid lg:grid-cols-4 gap-12 lg:gap-24">
          
          {/* 1. Brand Section - Stays centered/full on mobile */}
          <FadeUpText delay={0.1} className="space-y-6 md:space-y-10">
            <h2 className="text-3xl sm:text-4xl lg:text-5xl font-black tracking-tighter uppercase flex items-center flex-wrap gap-2">
              KF
              <span className="inline-block bg-pink-600 w-6 h-6 md:w-8 md:h-8 rounded-sm"></span>
              <span className="whitespace-nowrap">FAST FOOD</span>
            </h2>

            <div className="space-y-6">
              <div className="flex items-center gap-3">
                <span className="font-bold text-2xl md:text-3xl tracking-tighter">4.5</span>
                <div className="flex text-pink-600 text-xl md:text-2xl">
                  {"★★★★★".split("").map((s, i) => <span key={i}>{s}</span>)}
                </div>
                <span className="text-gray-500 text-xs uppercase font-bold tracking-widest">102 Reviews</span>
              </div>

              <button className="w-full sm:w-fit bg-pink-600 text-white px-8 py-4 rounded-full text-[11px] font-black uppercase tracking-[0.2em] hover:bg-pink-700 transition-all active:scale-95 shadow-lg shadow-pink-900/20">
                Write a Review
              </button>
            </div>
          </FadeUpText>

          {/* 2. Links Container - This is the magic for iPhone: 2 columns side-by-side */}
          <div className="grid grid-cols-2 lg:contents gap-8">
            {/* Shop Section */}
            <FadeUpText delay={0.2} className="space-y-6">
              <h3 className="text-xs md:text-sm font-black tracking-[0.3em] uppercase text-pink-600">Shop</h3>
              <ul className="space-y-4 text-gray-400 text-sm md:text-lg font-bold uppercase tracking-wider">
                <li><a href="#" className="hover:text-white transition-colors">Menu</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Delivery</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Sign In</a></li>
              </ul>
            </FadeUpText>

            {/* Help Section */}
            <FadeUpText delay={0.3} className="space-y-6">
              <h3 className="text-xs md:text-sm font-black tracking-[0.3em] uppercase text-pink-600">Help</h3>
              <ul className="space-y-4 text-gray-400 text-sm md:text-lg font-bold uppercase tracking-wider">
                <li><a href="#" className="hover:text-white transition-colors">About</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Contact</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Blog</a></li>
              </ul>
            </FadeUpText>
          </div>

          {/* 3. Contact Section */}
          <FadeUpText delay={0.4} className="space-y-8 border-t border-gray-900 pt-10 lg:border-none lg:pt-0">
            <div className="space-y-2">
              <h3 className="text-[10px] font-black tracking-[0.3em] uppercase text-gray-500">Operating Hours</h3>
              <p className="text-xl md:text-2xl font-black text-white italic">10:00 — 02:00</p>
            </div>

            <div className="space-y-6">
              <p className="text-white font-black text-2xl md:text-3xl tracking-tighter hover:text-pink-600 cursor-pointer transition-colors">
                +374 11 388888
              </p>
              
              <div className="flex justify-between items-end">
                <div className="uppercase">
                  <p className="font-black text-sm tracking-[0.2em]">SABZAZAR</p>
                  <p className="text-gray-500 text-xs tracking-widest font-bold">BLOCK</p>
                </div>
                
                <div className="flex gap-4">
                  <a href="#" className="w-10 h-10 rounded-full border border-gray-800 flex items-center justify-center text-gray-400 hover:border-pink-600 hover:text-pink-600 transition-all">
                    <Camera size={18} />
                  </a>
                  <a href="#" className="w-10 h-10 rounded-full border border-gray-800 flex items-center justify-center text-gray-400 hover:border-pink-600 hover:text-pink-600 transition-all">
                    <MessageCircle size={18} />
                  </a>
                </div>
              </div>
            </div>
          </FadeUpText>
        </div>
      </div>

      {/* Bottom Bar */}
      <div className="border-t border-gray-900 bg-[#050505]">
        <div className="px-6 md:px-20 py-8 max-w-[120rem] mx-auto flex flex-col md:flex-row justify-between items-center gap-4 text-[9px] text-gray-600 uppercase tracking-[0.3em] font-black">
          <p>© {currentYear} KF FAST FOOD. ALL RIGHTS RESERVED.</p>
          <p className="opacity-50">DESIGN BY ABVY</p>
        </div>
      </div>
    </footer>
  );
}