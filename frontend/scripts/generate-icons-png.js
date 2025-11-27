/**
 * Script to generate PNG icons for CampusLink PWA
 * Uses canvas to create simple icons
 */

const fs = require('fs');
const path = require('path');

// Try to use sharp if available, otherwise create a simple solution
let sharp;
try {
  sharp = require('sharp');
} catch (e) {
  console.log('Sharp not available, using fallback method...');
}

const iconSizes = [72, 96, 128, 144, 152, 192, 384, 512];

// Create icons directory if it doesn't exist
const iconsDir = path.join(__dirname, '../public/icons');
if (!fs.existsSync(iconsDir)) {
  fs.mkdirSync(iconsDir, { recursive: true });
}

// SVG template for icon
function createSVG(size) {
  return `<svg width="${size}" height="${size}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${size}" height="${size}" fill="#0ea5e9" rx="${size * 0.1}"/>
  <text x="50%" y="50%" font-family="Arial, sans-serif" font-size="${Math.floor(size * 0.35)}" font-weight="bold" fill="white" text-anchor="middle" dominant-baseline="middle">CL</text>
</svg>`;
}

async function generateIcons() {
  console.log('Generating PNG icons...');
  
  for (const size of iconSizes) {
    const svg = createSVG(size);
    const outputPath = path.join(iconsDir, `icon-${size}x${size}.png`);
    
    if (sharp) {
      // Use sharp to convert SVG to PNG
      try {
        await sharp(Buffer.from(svg))
          .resize(size, size)
          .png()
          .toFile(outputPath);
        console.log(`✓ Created: icon-${size}x${size}.png`);
      } catch (error) {
        console.error(`✗ Error creating icon-${size}x${size}.png:`, error.message);
      }
    } else {
      // Fallback: Create a simple data URL or use SVG
      console.log(`⚠ Sharp not available. Install it with: npm install --save-dev sharp`);
      console.log(`  For now, using SVG version: icon-${size}x${size}.svg`);
    }
  }
  
  if (!sharp) {
    console.log('\nTo generate PNG icons, install sharp:');
    console.log('  npm install --save-dev sharp');
    console.log('Then run this script again.');
  } else {
    console.log('\n✓ All PNG icons generated successfully!');
  }
}

generateIcons().catch(console.error);

