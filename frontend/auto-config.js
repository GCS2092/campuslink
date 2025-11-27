/**
 * Script pour détecter automatiquement l'IP locale et configurer Next.js
 */
const fs = require('fs');
const path = require('path');
const os = require('os');

function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      // Skip internal (loopback) and non-IPv4 addresses
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

function updateEnvFile(ip) {
  const envPath = path.join(__dirname, '.env.local');
  const apiUrl = `http://${ip}:8000/api`;
  
  let envContent = '';
  if (fs.existsSync(envPath)) {
    envContent = fs.readFileSync(envPath, 'utf8');
    // Remove existing NEXT_PUBLIC_API_URL if present
    envContent = envContent.replace(/NEXT_PUBLIC_API_URL=.*\n/g, '');
  }
  
  // Add or update NEXT_PUBLIC_API_URL
  envContent += `NEXT_PUBLIC_API_URL=${apiUrl}\n`;
  
  fs.writeFileSync(envPath, envContent, 'utf8');
  return apiUrl;
}

function loadConfigFromBackend() {
  // Try to load config from backend config.json
  const backendConfigPath = path.join(__dirname, '..', 'backend', 'config.json');
  if (fs.existsSync(backendConfigPath)) {
    try {
      const config = JSON.parse(fs.readFileSync(backendConfigPath, 'utf8'));
      return config.local_ip;
    } catch (e) {
      console.warn('Could not load backend config:', e.message);
    }
  }
  return null;
}

// Main execution
const backendIP = loadConfigFromBackend();
const localIP = backendIP || getLocalIP();
const apiUrl = updateEnvFile(localIP);

console.log('\n✅ Configuration automatique terminée!');
console.log(`📱 IP locale: ${localIP}`);
console.log(`🔗 API URL: ${apiUrl}`);
console.log(`🌐 Frontend: http://${localIP}:3000`);
console.log(`🔧 Backend: http://${localIP}:8000\n`);

// Export for use in next.config.js
module.exports = { localIP, apiUrl };

