@echo off
setlocal enabledelayedexpansion
echo ========================================
echo   CampusLink - Backend Server
echo ========================================
echo.

REM Determine Python executable (prefer venv)
set PYTHON_CMD=python
if exist "venv\Scripts\python.exe" (
    set PYTHON_CMD=venv\Scripts\python.exe
    echo Utilisation de Python depuis venv\Scripts\python.exe
) else if exist "..\venv\Scripts\python.exe" (
    set PYTHON_CMD=..\venv\Scripts\python.exe
    echo Utilisation de Python depuis ..\venv\Scripts\python.exe
) else (
    echo ATTENTION: Environnement virtuel non trouve!
    echo Utilisation de Python sye.
    echo.
)

REM Verify django-environ is installed
echo Verification des dependances...
%PYTHON_CMD% -c "import environ" >nul 2>&1
if errorlevel 1 (
    echo Installation de django-environ...
    %PYTHON_CMD% -m pip install django-environ
    if errorlevel 1 (
        echo ERREUR: Impossible d'installer django-environ!
        echo.
        echo Solutions:
        echo 1. Activez manuellement l'environnement virtuel: venv\Scripts\activate
        echo 2. Installez les dependances: pip install -r requirements.txt
        echo 3. Ou installez django-environ: pip install django-environ
        pause
        exit /b 1
    )
    echo django-environ installe avec succes!
)

echo.
echo Detecting local IP address...
%PYTHON_CMD% get_local_ip.py > temp_ip.txt 2>nul
set /p LOCAL_IP=<temp_ip.txt
del temp_ip.txt 2>nul

if "!LOCAL_IP!"=="" set LOCAL_IP=0.0.0.0

echo.
echo ========================================
echo   Configuration detectee
echo ========================================
echo   IP Locale: !LOCAL_IP!
echo.
echo Starting Django server on 0.0.0.0:8000...
echo.
echo Backend accessible depuis:
echo   - http://!LOCAL_IP!:8000
echo   - http://localhost:8000
echo   - http://127.0.0.1:8000
echo   - http://0.0.0.0:8000
echo.
echo Frontend doit utiliser: http://!LOCAL_IP!:3000
echo.
echo Press Ctrl+C to stop the server
echo.
%PYTHON_CMD% manage.py runserver 0.0.0.0:8000
