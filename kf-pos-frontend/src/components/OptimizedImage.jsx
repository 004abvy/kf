import React, { useState, useRef, useEffect } from 'react';

/**
 * OptimizedImage - A performance-focused image component.
 * 
 * Features:
 * - Native lazy loading (loading="lazy")
 * - Fade-in animation when image loads
 * - Graceful error fallback (styled gradient with item name)
 * - Prevents layout shift with aspect-ratio container
 */
const OptimizedImage = ({
  src,
  alt = '',
  className = '',
  containerClassName = '',
  fallbackText = '',
  onError: externalOnError,
  ...rest
}) => {
  const [loaded, setLoaded] = useState(false);
  const [errored, setErrored] = useState(false);
  const imgRef = useRef(null);

  // If image is already cached, mark as loaded immediately
  useEffect(() => {
    if (imgRef.current?.complete && imgRef.current?.naturalWidth > 0) {
      setLoaded(true);
    }
  }, [src]);

  // Reset state when src changes
  useEffect(() => {
    setLoaded(false);
    setErrored(false);
  }, [src]);

  const handleLoad = () => {
    setLoaded(true);
  };

  const handleError = (e) => {
    setErrored(true);
    if (externalOnError) externalOnError(e);
  };

  if (errored || !src) {
    return (
      <div
        className={`${containerClassName} flex items-center justify-center bg-gradient-to-br from-zinc-900 via-zinc-800 to-zinc-900`}
        style={{ minHeight: '60px' }}
      >
        <span className="text-zinc-600 text-[10px] font-bold uppercase tracking-widest text-center px-2 leading-tight line-clamp-2">
          {fallbackText || alt || 'No Image'}
        </span>
      </div>
    );
  }

  return (
    <div className={`${containerClassName} relative overflow-hidden bg-zinc-950`}>
      {/* Skeleton shimmer while loading */}
      {!loaded && (
        <div className="absolute inset-0 bg-zinc-900 animate-pulse" />
      )}
      <img
        ref={imgRef}
        src={src}
        alt={alt}
        loading="lazy"
        decoding="async"
        onLoad={handleLoad}
        onError={handleError}
        className={`${className} transition-opacity duration-500 ${loaded ? 'opacity-100' : 'opacity-0'}`}
        {...rest}
      />
    </div>
  );
};

export default OptimizedImage;
