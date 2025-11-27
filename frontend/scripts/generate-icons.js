/**
 * Script to generate missing icons for CampusLink PWA
 * This script creates simple placeholder icons using Node.js
 */

const fs = require('fs');
const path = require('path');

// Icon sizes needed
const iconSizes = [72, 96, 128, 144, 152, 192, 384, 512];

// Create a simple SVG icon
function createSVGIcon(size) {
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg width="${size}" height="${size}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${size}" height="${size}" fill="#0ea5e9"/>
  <text x="50%" y="50%" font-family="Arial, sans-serif" font-size="${size * 0.4}" font-weight="bold" fill="white" text-anchor="middle" dominant-baseline="middle">CL</text>
</svg>`;
}

// Create icons directory if it doesn't exist
const iconsDir = path.join(__dirname, '../public/icons');
if (!fs.existsSync(iconsDir)) {
  fs.mkdirSync(iconsDir, { recursive: true });
}

// Generate SVG icons (temporary solution)
console.log('Generating icon SVGs...');
iconSizes.forEach(size => {
  const svgPath = path.join(iconsDir, `icon-${size}x${size}.svg`);
  fs.writeFileSync(svgPath, createSVGIcon(size));
  console.log(`Created: icon-${size}x${size}.svg`);
});

// Note: To convert SVG to PNG, you can use:
// - Online tools like https://convertio.co/svg-png/
// - ImageMagick: magick convert icon-144x144.svg icon-144x144.png
// - Inkscape: inkscape icon-144x144.svg --export-filename=icon-144x144.png
console.log('\nSVG icons created. To convert to PNG:');
console.log('1. Use an online converter (https://convertio.co/svg-png/)');
console.log('2. Or install ImageMagick and run: magick convert icon-*.svg icon-*.png');
console.log('3. Or use Inkscape: inkscape icon-*.svg --export-filename=icon-*.png');

