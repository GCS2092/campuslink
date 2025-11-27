@echo off
echo ========================================
echo   CampusLink - Demarrage Automatique
echo ========================================
echo.

REM Step 1: Auto-detect IP and configure backend
echo [1/4] Configuration automatique du backend...
cd backend
python auto_config.py
if errorlevel 1 (
    echo ERREUR: Configuration backend echouee
    pause
    exit /b 1
)

REM Step 2: Auto-configure frontend
echo.
echo [2/4] Configuration automatique du frontend...
cd ..\frontend
node auto-config.js
if errorlevel 1 (
    echo ERREUR: Configuration frontend echouee
    pause
    exit /b 1
)

REM Step 3: Start backend in new window
echo.
echo [3/4] Demarrage du backend...
cd ..\backend
start "CampusLink Backend" cmd /k "call venv\Scripts\activate.bat && python manage.py runserver 0.0.0.0:8000"

REM Step 4: Start frontend
echo.
echo [4/4] Demarrage du frontend...
cd ..\frontend
timeout /t 3 /nobreak >nul
start "CampusLink Frontend" cmd /k "npm run dev:auto"

echo.
echo ========================================
echo   ✅ Demarrage termine!
echo ========================================
echo.
echo Les serveurs sont en cours de demarrage dans des fenetres separees.
echo.
pause

