"""
Script pour détecter automatiquement l'IP locale et configurer le projet.
"""
import os
import socket
import json
from pathlib import Path

def get_local_ip():
    """Obtenir l'adresse IP locale."""
    try:
        # Connecter à un serveur distant pour obtenir l'IP locale
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return '127.0.0.1'

def update_env_file(ip_address):
    """Mettre à jour le fichier .env avec l'IP détectée."""
    env_path = Path(__file__).parent / '.env'
    
    # Lire le fichier .env existant
    env_vars = {}
    if env_path.exists():
        with open(env_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()
    
    # Mettre à jour avec l'IP détectée
    env_vars['LOCAL_IP'] = ip_address
    env_vars['CORS_ALLOWED_ORIGINS'] = f'http://localhost:3000,http://127.0.0.1:3000,http://{ip_address}:3000'
    
    # Écrire le fichier .env
    with open(env_path, 'w', encoding='utf-8') as f:
        f.write(f"# Configuration automatique - IP détectée: {ip_address}\n")
        f.write(f"LOCAL_IP={ip_address}\n")
        f.write(f"CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000,http://{ip_address}:3000\n")
        f.write("\n# Autres variables d'environnement\n")
        for key, value in env_vars.items():
            if key not in ['LOCAL_IP', 'CORS_ALLOWED_ORIGINS']:
                f.write(f"{key}={value}\n")
    
    return ip_address

def save_config_json(ip_address):
    """Sauvegarder la configuration dans un fichier JSON pour le frontend."""
    config = {
        'local_ip': ip_address,
        'backend_url': f'http://{ip_address}:8000',
        'frontend_url': f'http://{ip_address}:3000',
        'api_url': f'http://{ip_address}:8000/api',
    }
    
    # Sauvegarder dans le backend
    backend_config_path = Path(__file__).parent / 'config.json'
    with open(backend_config_path, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=2)
    
    # Sauvegarder dans le frontend
    frontend_config_path = Path(__file__).parent.parent / 'frontend' / 'config.json'
    frontend_config_path.parent.mkdir(parents=True, exist_ok=True)
    with open(frontend_config_path, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=2)
    
    return config

if __name__ == '__main__':
    print("🔍 Détection de l'adresse IP locale...")
    ip = get_local_ip()
    print(f"✅ IP détectée: {ip}\n")
    
    print("📝 Mise à jour de la configuration...")
    update_env_file(ip)
    config = save_config_json(ip)
    
    print("✅ Configuration terminée!\n")
    print("📱 URLs configurées:")
    print(f"   Backend:  {config['backend_url']}")
    print(f"   Frontend: {config['frontend_url']}")
    print(f"   API:      {config['api_url']}\n")
    print("🚀 Vous pouvez maintenant démarrer les serveurs!")

