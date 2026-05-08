@echo off
REM ============================================================================
REM CLIP Classifier - Windows Production Runner
REM Starts the CLIP Classifier application
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ════════════════════════════════════════════════════════════════════════
echo      🖼️  CLIP Image Classifier - Production
echo ════════════════════════════════════════════════════════════════════════
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Check if executable exists
if not exist "%SCRIPT_DIR%CLIP_Classifier.exe" (
    echo ❌ CLIP_Classifier.exe not found!
    echo.
    echo This script should be run from the folder containing CLIP_Classifier.exe
    echo.
    echo If you haven't built the executable yet, run:
    echo   build_windows.bat
    echo.
    pause
    exit /b 1
)

echo ✓ Environment: Production
echo ✓ Model: openai/clip-vit-large-patch14 (Best Quality)
echo ✓ Device: CUDA (GPU - if available)
echo ✓ Starting CLIP Image Classifier...
echo.

REM Launch the application in a new window
start "" "%SCRIPT_DIR%CLIP_Classifier.exe"

REM Wait for server to initialize
timeout /t 3 /nobreak

REM Open browser to the application
echo.
echo Opening browser to http://127.0.0.1:5000...
start http://127.0.0.1:5000

echo.
echo ✓ Application started successfully!
echo.
echo The CLIP Classifier window will remain open while the app runs.
echo You can close it when you're done using the application.
echo.
