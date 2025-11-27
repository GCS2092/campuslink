/**
 * Script to generate favicon for CampusLink
 */

const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

// Create favicon SVG
const faviconSVG = `<svg width="32" height="32" xmlns="http://www.w3.org/2000/svg">
  <rect width="32" height="32" fill="#0ea5e9" rx="4"/>
  <text x="50%" y="50%" font-family="Arial, sans-serif" font-size="20" font-weight="bold" fill="white" text-anchor="middle" dominant-baseline="middle">CL</text>
</svg>`;

async function generateFavicon() {
  const publicDir = path.join(__dirname, '../public');
  
  try {
    // Generate favicon.ico (32x32 PNG)
    await sharp(Buffer.from(faviconSVG))
      .resize(32, 32)
      .png()
      .toFile(path.join(publicDir, 'favicon.ico'));
    
    console.log('✓ Created: favicon.ico');
    
    // Also create favicon.png for Next.js
    await sharp(Buffer.from(faviconSVG))
      .resize(32, 32)
      .png()
      .toFile(path.join(publicDir, 'favicon.png'));
    
    console.log('✓ Created: favicon.png');
  } catch (error) {
    console.error('✗ Error creating favicon:', error.message);
  }
}

generateFavicon().catch(console.error);

