#!/bin/bash
echo "========================================"
echo "  CampusLink - Backend Server"
echo "========================================"
echo ""

# Check if virtual environment is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "ATTENTION: Environnement virtuel non active!"
    echo ""
    echo "Activation de l'environnement virtuel..."
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
    elif [ -f "../venv/bin/activate" ]; then
        source ../venv/bin/activate
    else
        echo "ERREUR: Environnement virtuel introuvable!"
        echo "Veuillez creer un environnement virtuel avec: python -m venv venv"
        exit 1
    fi
fi

echo ""
echo "Verification des dependances..."
python -c "import environ" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Installation de django-environ..."
    pip install django-environ
fi

echo ""
echo "Detecting local IP address..."
LOCAL_IP=$(python get_local_ip.py 2>/dev/null)

if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP="0.0.0.0"
fi

echo ""
echo "========================================"
echo "  Configuration detectee"
echo "========================================"
echo "  IP Locale: $LOCAL_IP"
echo ""
echo "Starting Django server on 0.0.0.0:8000..."
echo ""
echo "Backend accessible depuis:"
echo "  - http://$LOCAL_IP:8000"
echo "  - http://localhost:8000"
echo "  - http://127.0.0.1:8000"
echo "  - http://0.0.0.0:8000"
echo ""
echo "Frontend doit utiliser: http://$LOCAL_IP:3000"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""
$PYTHON_CMD manage.py runserver 0.0.0.0:8000

