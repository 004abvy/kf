import React from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import Landingimg from '../assets/landingpage.jpg';
import MostWanted from './MostWanted';
import CategoriesPage from './Categories';
import Feedback from './feedback';
import FAQ from './FAQ';
import { StaggerText, FadeUpText, FadeInBlock } from '../components/AnimatedText';

export default function LandingPage() {
  return (
    <div className="flex flex-col min-h-screen bg-black font-sans">

      {/* 1. HERO SECTION */}
      <div className="relative h-screen md:h-[90vh] flex items-center overflow-hidden">
        {/* Animated Background Image */}
        <motion.div
           initial={{ scale: 1.15, opacity: 0 }}
           animate={{ scale: 1, opacity: 1 }}
           transition={{ duration: 1.5, ease: 'easeOut' }}
           className="absolute inset-0 z-0"
           style={{
             backgroundImage: `url(${Landingimg})`,
             backgroundSize: 'cover',
             backgroundPosition: 'center'
           }}
        />
        
        {/* Overlay to ensure text readability */}
        <div className="absolute inset-0 bg-black/30 z-10"></div>

        {/* Content Container */}
        <div className="relative z-20 w-full px-4 sm:px-8 md:pl-12 lg:pl-20 -mt-10 md:-mt-20">
          <div className="max-w-4xl text-center md:text-left">
            <StaggerText 
              as="h1" 
              className="text-4xl sm:text-5xl md:text-7xl lg:text-[115px] font-black text-white uppercase leading-[1.1] md:leading-[1.0] tracking-tighter mb-6"
              text="The Best Fast Food <br/> Delivery in Sabzazar"
            />
            <FadeInBlock delay={0.8} duration={0.8}>
              <Link
                to="/menu"
                className="inline-block bg-white text-[#ff007f] font-bold text-base md:text-xl px-6 py-3 md:px-8 md:py-3 mt-8 md:mt-16 rounded-full shadow-lg hover:scale-105 hover:shadow-xl transition-transform"
              >
                Order now
              </Link>
            </FadeInBlock>
          </div>
        </div>

        {/* Carousel Arrows */}
        <div className="absolute right-6 top-1/2 -translate-y-1/2 hidden lg:flex gap-4">
          <button className="text-white/70 hover:text-white transition-colors">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <button className="text-white/70 hover:text-white transition-colors">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>
      </div>

      {/* 2. FEATURE BAR */}
      <div className="bg-black text-white border-t border-white/10">
        <div className="max-w-7xl mx-auto py-8 px-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 md:gap-4 font-bold tracking-wider">
            
            <FadeUpText delay={0.1} className="text-sm md:text-base lg:text-xl flex flex-col items-center justify-center gap-2 text-center">
              <svg className="w-6 h-6 md:w-8 md:h-8 text-[#ff007f]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
              </svg>
              <span>ALWAYS FRESH</span>
            </FadeUpText>

            <FadeUpText delay={0.2} className="text-sm md:text-base lg:text-xl flex flex-col items-center justify-center gap-2 text-center">
              <svg className="w-6 h-6 md:w-8 md:h-8 text-[#ff007f]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
              <span>FAST DELIVERY</span>
            </FadeUpText>

            <FadeUpText delay={0.3} className="text-sm md:text-base lg:text-xl flex flex-col items-center justify-center gap-2 text-center">
              <svg className="w-6 h-6 md:w-8 md:h-8 text-[#ff007f]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
              <span>SECURE PAYMENT</span>
            </FadeUpText>

            <FadeUpText delay={0.4} className="text-sm md:text-base lg:text-xl flex flex-col items-center justify-center gap-2 text-center">
              <svg className="w-6 h-6 md:w-8 md:h-8 text-[#ff007f]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span>OPEN 11AM - 3AM</span>
            </FadeUpText>
          </div>
        </div>

        {/* 3. FLOATING MENU BUTTON */}
        <div className="flex justify-center pb-8 bg-black px-4">
          <Link
            to="/menu"
            className="flex items-center justify-center w-full sm:w-auto gap-3 bg-[#ff007f] text-white px-6 py-4 md:px-10 md:py-6 mt-8 md:mt-14 rounded-full text-base md:text-lg font-bold shadow-lg hover:bg-pink-600 hover:scale-105 transition-all"
          >
            <div className="bg-white rounded-full p-1 flex flex-col justify-center gap-[3px] w-5 h-5 md:w-6 md:h-6 items-center">
              <span className="w-2 md:w-3 h-[2px] bg-[#ff007f] block rounded-sm"></span>
              <span className="w-2 md:w-3 h-[2px] bg-[#ff007f] block rounded-sm"></span>
            </div>
            Explore Full Menu
          </Link>
        </div>
      </div>
      <MostWanted />
      <CategoriesPage />
      <Feedback />
      <FAQ />
    </div>
  );
}