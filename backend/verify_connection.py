#!/usr/bin/env python3
"""
Vérifications pour que l'app Expo puisse joindre le backend.
À lancer depuis backend/ : python verify_connection.py
(Backend peut être arrêté : le script affiche quand même la config et l'IP.)
"""
import socket
import urllib.request
import urllib.error
import json

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.settimeout(1)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return None

def test_url(url, method='GET', data=None):
    try:
        req = urllib.request.Request(url, data=data, method=method)
        if data is not None:
            req.add_header('Content-Type', 'application/json')
        with urllib.request.urlopen(req, timeout=3) as r:
            return True, r.getcode()
    except urllib.error.HTTPError as e:
        return True, e.code
    except Exception:
        return False, None

def main():
    print("=" * 60)
    print("VÉRIFICATIONS CONNEXION BACKEND CAMPUSLINK")
    print("=" * 60)

    local_ip = get_local_ip()
    print("\n1. IP locale (pour Expo sur téléphone réel)")
    if local_ip:
        print(f"   IP = {local_ip}")
        print(f"   -> constants.ts : 'http://{local_ip}:8000/api'")
    else:
        print("   (Impossible de détecter l'IP)")

    print("\n2. Test des endpoints (backend doit tourner)")
    base = "http://127.0.0.1:8000"
    ok1, code1 = test_url(f"{base}/api/")
    ok2, code2 = test_url(f"{base}/api/auth/login/", "POST", json.dumps({"email": "x", "password": "y"}).encode())
    if ok1 or ok2:
        print(f"   GET  /api/          -> {'OK' if ok1 else 'échec'} (HTTP {code1})")
        print(f"   POST /api/auth/login/ -> {'OK' if ok2 else 'échec'} (HTTP {code2})")
        if code2 in (200, 400, 401):
            print("   Backend joignable.")
    else:
        print("   Backend non joignable. Démarrez : python manage.py runserver 0.0.0.0:8000")

    print("\n3. URLs pour Expo (constants.ts)")
    print("   Émulateur Android : http://10.0.2.2:8000/api")
    if local_ip:
        print(f"   Téléphone réel   : http://{local_ip}:8000/api")
    print("=" * 60)

if __name__ == "__main__":
    main()
