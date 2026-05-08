@echo off
REM ============================================================================
REM CLIP Classifier - Portable Flash Drive Setup
REM ============================================================================
REM Creates a standalone portable version ready for flash drive
REM
REM Instructions:
REM 1. Build the application first: run build_windows.bat
REM 2. Then run this script to create portable package
REM 3. Copy the portable folder to your flash drive
REM 4. Plug flash drive into any Windows machine and double-click CLIP_Classifier.exe
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ============================================================================
echo CLIP Classifier - Portable Flash Drive Creator
echo ============================================================================
echo.

REM Check if dist folder exists
if not exist "dist\CLIP_Classifier.exe" (
    echo ERROR: dist\CLIP_Classifier.exe not found!
    echo.
    echo Please run build_windows.bat first to create the executable.
    echo.
    pause
    exit /b 1
)

echo [1/4] Checking for existing portable folder...
if exist "CLIP_Classifier_Portable" (
    echo Removing old portable folder...
    rmdir /s /q "CLIP_Classifier_Portable"
)

echo [2/4] Creating portable package...
mkdir "CLIP_Classifier_Portable"

echo [3/4] Copying application files...
xcopy "dist\*" "CLIP_Classifier_Portable\" /E /I /Y >nul

echo [4/4] Creating launcher scripts...

REM Create main launcher
(
    echo @echo off
    echo title CLIP Image Classifier - Portable
    echo cd /d "%%~dp0"
    echo start http://127.0.0.1:5000
    echo CLIP_Classifier.exe
) > "CLIP_Classifier_Portable\START.bat"

REM Create a VBS launcher that hides console (optional)
(
    echo Set objShell = CreateObject("WScript.Shell"^)
    echo strPath = objShell.CurrentFolder
    echo objShell.CurrentFolder = strPath
    echo objShell.Run strPath ^& "\CLIP_Classifier.exe", 0, False
) > "CLIP_Classifier_Portable\START_HIDDEN.vbs"

REM Create README
(
    echo # CLIP Image Classifier - Portable Version
    echo.
    echo ## How to Use
    echo.
    echo 1. Double-click: START.bat
    echo    (Shows command window - recommended for first run^)
    echo.
    echo 2. Wait 30-60 seconds for the model to load
    echo    (First run only - model downloads ~2GB^)
    echo.
    echo 3. Browser opens automatically to: http://127.0.0.1:5000
    echo.
    echo 4. Enjoy! Use it completely offline
    echo.
    echo ## System Requirements
    echo.
    echo - Windows 10 or Windows 11 (64-bit^)
    echo - 4 GB RAM minimum (8 GB recommended^)
    echo - 4 GB disk space available
    echo - NVIDIA GPU recommended (optional - CPU mode works too^)
    echo.
    echo ## First Run Notes
    echo.
    echo - First launch takes 30-60 seconds while model downloads (~2GB^)
    echo - Model is cached locally - subsequent runs are instant
    echo - If USB drive is too slow, copy to local disk first
    echo.
    echo ## Features
    echo.
    echo - Classify unlimited images
    echo - Multiple export formats (JSON, CSV, Excel, PDF^)
    echo - Custom preset creation
    echo - Confidence filtering
    echo - GPU acceleration (if available^)
    echo - Completely offline operation
    echo.
    echo ## Troubleshooting
    echo.
    echo Q: Application won't start?
    echo A: Check Windows Defender doesn't block it. Run as Administrator.
    echo.
    echo Q: Very slow to start?
    echo A: Model downloads on first run. Be patient. Copy folder to local disk.
    echo.
    echo Q: Can't upload images?
    echo A: Clear browser cache. Restart the application.
    echo.
    echo Q: Out of memory?
    echo A: Close other applications. Restart the app.
    echo.
    echo Q: GPU not being used?
    echo A: CPU mode works fine. Performance is still good.
    echo.
    echo ---
    echo Built with CLIP Vision Model - openai/clip-vit-large-patch14
) > "CLIP_Classifier_Portable\README.txt"

echo.
echo ============================================================================
echo SUCCESS! Portable package created!
echo ============================================================================
echo.
echo Location: CLIP_Classifier_Portable\
echo.
echo Next Steps:
echo.
echo 1. Insert USB flash drive into your computer
echo 2. Copy the entire "CLIP_Classifier_Portable" folder to the USB
echo 3. Eject the USB safely
echo 4. Plug USB into any Windows machine
echo 5. Double-click: CLIP_Classifier_Portable\START.bat
echo 6. Wait for browser to open and enjoy!
echo.
echo Size: Check "CLIP_Classifier_Portable" folder size
echo       (Usually 1-2 GB before first run, 3-4 GB after^)
echo.
echo ============================================================================
echo READY FOR PORTABLE DEPLOYMENT!
echo ============================================================================
echo.
pause
