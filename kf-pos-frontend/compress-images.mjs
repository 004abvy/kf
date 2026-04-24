import sharp from 'sharp';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const assetsDir = path.join(__dirname, 'src', 'assets');

async function compress() {
  console.log('🔧 Compressing images...\n');

  // 1. Compress landingpage.jpg (8.9MB) → WebP (~150KB)
  const landingInput = path.join(assetsDir, 'landingpage.jpg');
  const landingOutput = path.join(assetsDir, 'landingpage.webp');
  const landingPlaceholder = path.join(assetsDir, 'landingpage-placeholder.webp');

  const landingInfo = await sharp(landingInput)
    .webp({ quality: 72 })
    .toFile(landingOutput);
  console.log(`✅ landingpage.jpg → landingpage.webp (${(landingInfo.size / 1024).toFixed(0)} KB)`);

  // Generate tiny blurred placeholder
  const placeholderInfo = await sharp(landingInput)
    .resize(30)
    .blur(3)
    .webp({ quality: 30 })
    .toFile(landingPlaceholder);
  console.log(`✅ landingpage-placeholder.webp (${(placeholderInfo.size / 1024).toFixed(1)} KB)`);

  // 2. Compress logo PNGs → WebP
  const logos = [
    { input: 'desktop-logo.PNG', output: 'desktop-logo.webp' },
    { input: 'mobile-logo.PNG', output: 'mobile-logo.webp' },
  ];

  for (const logo of logos) {
    const info = await sharp(path.join(assetsDir, logo.input))
      .webp({ quality: 85 })
      .toFile(path.join(assetsDir, logo.output));
    console.log(`✅ ${logo.input} → ${logo.output} (${(info.size / 1024).toFixed(1)} KB)`);
  }

  console.log('\n🎉 All images compressed!');
}

compress().catch(console.error);
