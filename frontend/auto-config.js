/**
 * Auto-configuration script for Next.js
 * Configures NEXT_PUBLIC_API_URL based on environment
 * 
 * In production (Vercel), NEXT_PUBLIC_API_URL should be set via environment variables
 * In development, this script auto-detects the local IP
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// If NEXT_PUBLIC_API_URL is already set (production/Vercel), skip auto-config
if (process.env.NEXT_PUBLIC_API_URL) {
  console.log('✅ NEXT_PUBLIC_API_URL already set:', process.env.NEXT_PUBLIC_API_URL);
  process.exit(0);
}

// Development mode: auto-detect local IP
console.log('🔍 Auto-configuring API URL for development...');

let localIP = 'localhost';
let apiUrl = 'http://localhost:8000/api';

try {
  // Try to get local IP address
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        localIP = iface.address;
        apiUrl = `http://${localIP}:8000/api`;
        break;
      }
    }
    if (localIP !== 'localhost') break;
  }
} catch (e) {
  console.warn('⚠️  Could not detect local IP, using localhost');
}

// Save config to file for other scripts
const configPath = path.join(__dirname, 'config.json');
const config = {
  local_ip: localIP,
  api_url: apiUrl
};

try {
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  console.log(`✅ Configuration saved: ${apiUrl}`);
} catch (e) {
  console.warn('⚠️  Could not save config file:', e.message);
}

// Set environment variable for Next.js
process.env.NEXT_PUBLIC_API_URL = apiUrl;

console.log(`📱 Local IP: ${localIP}`);
console.log(`🔗 API URL: ${apiUrl}`);
console.log('');

