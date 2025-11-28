@echo off
setlocal enabledelayedexpansion
echo ========================================
echo   CAMPUSLINK - DEMARRAGE COMPLET
echo ========================================
echo.
echo Detection de l'adresse IP locale...
cd backend
python get_local_ip.py > ..\temp_ip.txt 2>nul
set /p LOCAL_IP=<..\temp_ip.txt
del ..\temp_ip.txt 2>nul
cd ..

if "!LOCAL_IP!"=="" set LOCAL_IP=localhost

echo.
echo ========================================
echo   CONFIGURATION DETECTEE
echo ========================================
echo   IP Locale: !LOCAL_IP!
echo.
echo   Backend:  http://!LOCAL_IP!:8000
echo   Frontend: http://!LOCAL_IP!:3000
echo.
echo ========================================
echo   INSTRUCTIONS
echo ========================================
echo.
echo 1. Ouvrez un PREMIER terminal et executez:
echo    cd backend
echo    start_server.bat
echo.
echo 2. Ouvrez un DEUXIEME terminal et executez:
echo    cd frontend
echo    start-frontend.bat
echo.
echo 3. Accedez a l'application depuis:
echo    - PC: http://localhost:3000
echo    - Mobile: http://!LOCAL_IP!:3000
echo.
echo ========================================
echo.
pause

