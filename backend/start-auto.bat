@echo off
echo ========================================
echo   CampusLink Backend - Auto Config
echo ========================================
echo.

REM Auto-detect IP and configure
echo [1/3] Detection de l'adresse IP...
python auto_config.py
if errorlevel 1 (
    echo ERREUR: Impossible de detecter l'IP
    pause
    exit /b 1
)

echo.
echo [2/3] Activation de l'environnement virtuel...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo ERREUR: Impossible d'activer l'environnement virtuel
    pause
    exit /b 1
)

echo.
echo [3/3] Demarrage du serveur Django...
echo.
echo Le serveur sera accessible sur:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set IP=%%a
    set IP=!IP:~1!
    echo   http://!IP!:8000
    goto :found
)
:found

echo.
echo Appuyez sur Ctrl+C pour arreter
echo.

python manage.py runserver 0.0.0.0:8000

