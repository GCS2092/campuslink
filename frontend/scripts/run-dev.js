/**
 * Lance Next.js dev en forçant NEXT_PUBLIC_API_URL depuis config.json
 * (écrit par auto-config.js). On écrit .env.development.local pour que
 * Next.js utilise l’IP détectée (ex. 192.168.1.127), même si .env.local
 * contient une autre URL.
 */
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

const rootDir = path.join(__dirname, '..');
const configPath = path.join(rootDir, 'config.json');
const envDevLocalPath = path.join(rootDir, '.env.development.local');
let apiUrl = process.env.NEXT_PUBLIC_API_URL;

try {
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  if (config.api_url) {
    apiUrl = config.api_url;
    process.env.NEXT_PUBLIC_API_URL = apiUrl;
    console.log('🔗 API URL (config.json):', apiUrl);

    // Next charge .env.development.local après .env.local, donc il écrase
    // NEXT_PUBLIC_API_URL. On met à jour ce fichier pour forcer la bonne IP.
    let rest = '';
    if (fs.existsSync(envDevLocalPath)) {
      rest = fs.readFileSync(envDevLocalPath, 'utf8')
        .split('\n')
        .filter((line) => !line.trim().startsWith('NEXT_PUBLIC_API_URL='))
        .join('\n')
        .trim();
      if (rest) rest += '\n';
    }
    fs.writeFileSync(envDevLocalPath, `${rest}NEXT_PUBLIC_API_URL=${apiUrl}\n`, 'utf8');
  }
} catch (e) {
  if (!apiUrl) {
    console.warn('⚠️ config.json absent ou invalide. Relancez "npm run dev" ou définissez NEXT_PUBLIC_API_URL dans .env.local');
  }
}

const child = spawn('npx', ['next', 'dev', '-H', '0.0.0.0'], {
  env: process.env,
  stdio: 'inherit',
  shell: true,
  cwd: path.join(__dirname, '..'),
});

child.on('exit', (code) => process.exit(code ?? 0));
