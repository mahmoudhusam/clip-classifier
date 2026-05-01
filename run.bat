@echo off
REM CLIP Classifier Startup Script for Windows
REM Starts the FastAPI backend and opens the WebUI

setlocal enabledelayedexpansion

echo.
echo ════════════════════════════════════════════════════════
echo      🖼️  CLIP Image Classifier - WebUI
echo ════════════════════════════════════════════════════════
echo.

REM Check if virtual environment exists
if not exist "venv\" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install/update dependencies
echo Checking dependencies...
pip install -q fastapi uvicorn openpyxl reportlab python-multipart 2>nul

echo.
echo ✓ Environment ready
echo.

REM Get environment variable or default to 'dev'
if "%CLIP_ENV%"=="" (
    set ENV=dev
) else (
    set ENV=%CLIP_ENV%
)

echo Environment: %ENV%
echo.

REM Start backend
echo Starting FastAPI backend...
echo → http://localhost:8000
echo.

start "CLIP Backend" python -m uvicorn backend.app:app --reload --host 127.0.0.1 --port 8000

REM Wait for server to start
timeout /t 3 /nobreak

REM Open WebUI in default browser
echo Opening WebUI in browser...
timeout /t 1 /nobreak

for %%A in ("%cd%\frontend\index.html") do set "WEBUI=%%~fA"
start "" file:///%WEBUI%

echo.
echo ════════════════════════════════════════════════════════
echo 🚀 CLIP Classifier is running!
echo ════════════════════════════════════════════════════════
echo.
echo 📖 API Documentation: http://localhost:8000/docs
echo 💻 WebUI: file:///%WEBUI%
echo.
echo Close this window or press Ctrl+C to stop the server
echo.

pause
