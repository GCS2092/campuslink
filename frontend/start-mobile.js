/**
 * Script to start Next.js server accessible from mobile devices
 * Auto-configures IP address
 */
const { execSync } = require('child_process');
const path = require('path');

// Run auto-config first
console.log('\n🔍 Configuration automatique...\n');
try {
  require('./auto-config.js');
} catch (e) {
  console.warn('⚠️  Auto-config failed, using defaults');
}

// Load config
let localIP = 'localhost';
let apiUrl = 'http://localhost:8000/api';

try {
  const fs = require('fs');
  const configPath = path.join(__dirname, 'config.json');
  if (fs.existsSync(configPath)) {
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    localIP = config.local_ip;
    apiUrl = config.api_url;
  }
} catch (e) {
  // Fallback
  const os = require('os');
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        localIP = iface.address;
        apiUrl = `http://${localIP}:8000/api`;
        break;
      }
    }
  }
}

const port = process.env.PORT || 3000;

console.log('\n🚀 Démarrage du serveur pour mobile...\n');
console.log(`📱 IP locale: ${localIP}`);
console.log(`🌐 Frontend: http://${localIP}:${port}`);
console.log(`🔗 Backend: http://${localIP}:8000`);
console.log(`🔧 API URL: ${apiUrl}`);
console.log('\n⚠️  Assurez-vous que:');
console.log('   1. Votre téléphone est sur le même réseau WiFi');
console.log('   2. Le backend Django est lancé sur 0.0.0.0:8000');
console.log('   3. La configuration automatique a été exécutée\n');

// Set environment variable for Next.js
process.env.NEXT_PUBLIC_API_URL = apiUrl;

// Start Next.js with hostname 0.0.0.0 to allow external connections
execSync(`next dev -H 0.0.0.0 -p ${port}`, { stdio: 'inherit' });

