#!/bin/bash
echo "========================================"
echo "  CampusLink - Frontend Server"
echo "========================================"
echo ""
echo "Detecting local IP address..."
cd ../backend
LOCAL_IP=$(python get_local_ip.py 2>/dev/null)
cd ../frontend

if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP="localhost"
fi

echo ""
echo "========================================"
echo "  Configuration detectee"
echo "========================================"
echo "  IP Locale: $LOCAL_IP"
echo ""
echo "Setting NEXT_PUBLIC_API_URL to http://$LOCAL_IP:8000/api"
export NEXT_PUBLIC_API_URL="http://$LOCAL_IP:8000/api"
echo ""
echo "Starting Next.js server on 0.0.0.0:3000..."
echo ""
echo "Frontend accessible depuis:"
echo "  - http://$LOCAL_IP:3000"
echo "  - http://localhost:3000"
echo "  - http://127.0.0.1:3000"
echo ""
echo "Backend API: http://$LOCAL_IP:8000/api"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
HOSTNAME=0.0.0.0 PORT=3000 npm run dev:network

