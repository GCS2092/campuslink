@echo off
echo ========================================
echo   CampusLink Backend - Mode Mobile
echo ========================================
echo.

REM Get local IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set IP=%%a
    set IP=!IP:~1!
    goto :found
)
:found

echo IP locale: %IP%
echo.
echo Backend: http://%IP%:8000
echo Frontend: http://%IP%:3000
echo.
echo Appuyez sur Ctrl+C pour arreter
echo.

REM Activate virtual environment and run server on 0.0.0.0
call venv\Scripts\activate.bat
python manage.py runserver 0.0.0.0:8000

