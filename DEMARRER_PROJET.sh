#!/bin/bash
echo "========================================"
echo "  CAMPUSLINK - DEMARRAGE COMPLET"
echo "========================================"
echo ""
echo "Detection de l'adresse IP locale..."
cd backend
LOCAL_IP=$(python get_local_ip.py 2>/dev/null)
cd ..

if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP="localhost"
fi

echo ""
echo "========================================"
echo "  CONFIGURATION DETECTEE"
echo "========================================"
echo "  IP Locale: $LOCAL_IP"
echo ""
echo "  Backend:  http://$LOCAL_IP:8000"
echo "  Frontend: http://$LOCAL_IP:3000"
echo ""
echo "========================================"
echo "  INSTRUCTIONS"
echo "========================================"
echo ""
echo "1. Ouvrez un PREMIER terminal et executez:"
echo "   cd backend"
echo "   ./start_server.sh"
echo ""
echo "2. Ouvrez un DEUXIEME terminal et executez:"
echo "   cd frontend"
echo "   ./start-frontend.sh"
echo ""
echo "3. Accedez a l'application depuis:"
echo "   - PC: http://localhost:3000"
echo "   - Mobile: http://$LOCAL_IP:3000"
echo ""
echo "========================================"
echo ""

