import React from 'react';
import { motion, useInView } from 'framer-motion';

// Fade in and slide up slightly
export function FadeUpText({ children, delay = 0, className = '', as: Component = 'div', style = {} }) {
  const ref = React.useRef(null);
  const isInView = useInView(ref, { once: true, amount: 0.3 });
  const MotionComponent = typeof Component === 'string' && motion[Component] ? motion[Component] : motion.div;

  return (
    <MotionComponent
      ref={ref}
      style={style}
      className={className}
      initial={{ y: 40, opacity: 0 }}
      animate={isInView ? { y: 0, opacity: 1 } : { y: 40, opacity: 0 }}
      transition={{
        duration: 1.2,
        ease: [0.22, 1, 0.36, 1],
        delay,
      }}
    >
      {children}
    </MotionComponent>
  );
}

// Stagger word by word
export function StaggerText({ text, className = '', as: Component = 'h1', delay = 0 }) {
  const ref = React.useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-10%' });

  // Split text by space for words
  const words = text.split(' ');

  const container = {
    hidden: { opacity: 0 },
    visible: (i = 1) => ({
      opacity: 1,
      transition: { staggerChildren: 0.12, delayChildren: delay * i },
    }),
  };

  const child = {
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        type: 'spring',
        damping: 14,
        stiffness: 80,
      },
    },
    hidden: {
      opacity: 0,
      y: 40,
      transition: {
        type: 'spring',
        damping: 14,
        stiffness: 80,
      },
    },
  };

  return (
    <Component ref={ref} className={className}>
      <motion.div
        style={{ display: 'inline-flex', flexWrap: 'wrap', gap: '0.25em' }}
        variants={container}
        initial="hidden"
        animate={isInView ? 'visible' : 'hidden'}
      >
        {words.map((word, index) => (
          <motion.span variants={child} key={index}>
            {word === '<br/>' || word === '<br />' ? <br /> : word}
          </motion.span>
        ))}
      </motion.div>
    </Component>
  );
}

// Fade in standard
export function FadeInBlock({ children, delay = 0, className = '', duration = 1.2 }) {
  const ref = React.useRef(null);
  const isInView = useInView(ref, { once: true, amount: 0.2 });

  return (
    <motion.div
      ref={ref}
      className={className}
      initial={{ opacity: 0 }}
      animate={isInView ? { opacity: 1 } : { opacity: 0 }}
      transition={{ duration, delay, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </motion.div>
  );
}
