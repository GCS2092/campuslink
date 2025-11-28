@echo off
setlocal enabledelayedexpansion
echo ========================================
echo   CampusLink - Frontend Server
echo ========================================
echo.
echo Detecting local IP address...
cd ..\backend
python get_local_ip.py > ..\frontend\temp_ip.txt 2>nul
set /p LOCAL_IP=<..\frontend\temp_ip.txt
del ..\frontend\temp_ip.txt 2>nul
cd ..\frontend

if "!LOCAL_IP!"=="" set LOCAL_IP=localhost

echo.
echo ========================================
echo   Configuration detectee
echo ========================================
echo   IP Locale: !LOCAL_IP!
echo.
echo Setting NEXT_PUBLIC_API_URL to http://!LOCAL_IP!:8000/api
set NEXT_PUBLIC_API_URL=http://!LOCAL_IP!:8000/api
echo.
echo Starting Next.js server on 0.0.0.0:3000...
echo.
echo Frontend accessible depuis:
echo   - http://!LOCAL_IP!:3000
echo   - http://localhost:3000
echo   - http://127.0.0.1:3000
echo.
echo Backend API: http://!LOCAL_IP!:8000/api
echo.
echo Press Ctrl+C to stop the server
echo.
set HOSTNAME=0.0.0.0
set PORT=3000
npm run dev:network

