@echo off
REM ============================================================================
REM CLIP Classifier - Windows Installation Wizard
REM Creates a shortcut and optional installation to Program Files
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ════════════════════════════════════════════════════════════════════════
echo      CLIP Image Classifier - Windows Installer
echo ════════════════════════════════════════════════════════════════════════
echo.

REM Check if dist folder exists
if not exist "dist\CLIP_Classifier.exe" (
    echo ❌ CLIP_Classifier.exe not found in dist folder
    echo.
    echo Please run build_windows.bat first to create the executable
    echo.
    pause
    exit /b 1
)

echo Installation Options:
echo.
echo 1. Create Desktop Shortcut (Quick Start)
echo 2. Install to Program Files
echo 3. Create Both
echo 4. Cancel
echo.

set /p choice="Select option (1-4): "

if "%choice%"=="1" goto desktop_shortcut
if "%choice%"=="2" goto program_files
if "%choice%"=="3" goto both
if "%choice%"=="4" goto cancel
goto invalid

:desktop_shortcut
echo.
echo Creating desktop shortcut...

REM Get the full path to the executable
set "EXE_PATH=%cd%\dist\CLIP_Classifier.exe"

REM Create shortcut using VBScript
(
    echo Set oWS = WScript.CreateObject("WScript.Shell"^)
    echo sLinkFile = oWS.SpecialFolders("Desktop"^) ^& "\CLIP Classifier.lnk"
    echo Set oLink = oWS.CreateShortcut(sLinkFile^)
    echo oLink.TargetPath = "%EXE_PATH%"
    echo oLink.WorkingDirectory = "%cd%\dist"
    echo oLink.Description = "CLIP Image Classifier - Production"
    echo oLink.Save
) > create_shortcut.vbs

cscript create_shortcut.vbs
del create_shortcut.vbs

echo ✓ Desktop shortcut created
echo.
goto complete

:program_files
echo.
echo Installing to Program Files...
echo.

set "INSTALL_PATH=C:\Program Files\CLIP Classifier"

REM Create installation directory
if not exist "%INSTALL_PATH%" mkdir "%INSTALL_PATH%"

REM Copy files
echo Copying application files...
xcopy "dist\*.*" "%INSTALL_PATH%\" /E /Y /I >nul

echo ✓ Application installed to: %INSTALL_PATH%
echo.

REM Create shortcut
(
    echo Set oWS = WScript.CreateObject("WScript.Shell"^)
    echo sLinkFile = oWS.SpecialFolders("Desktop"^) ^& "\CLIP Classifier.lnk"
    echo Set oLink = oWS.CreateShortcut(sLinkFile^)
    echo oLink.TargetPath = "%INSTALL_PATH%\CLIP_Classifier.exe"
    echo oLink.WorkingDirectory = "%INSTALL_PATH%"
    echo oLink.Description = "CLIP Image Classifier - Production"
    echo oLink.Save
) > create_shortcut.vbs

cscript create_shortcut.vbs
del create_shortcut.vbs

echo ✓ Desktop shortcut created
echo.
goto complete

:both
echo.
echo Creating desktop shortcut...
set "EXE_PATH=%cd%\dist\CLIP_Classifier.exe"

(
    echo Set oWS = WScript.CreateObject("WScript.Shell"^)
    echo sLinkFile = oWS.SpecialFolders("Desktop"^) ^& "\CLIP Classifier.lnk"
    echo Set oLink = oWS.CreateShortcut(sLinkFile^)
    echo oLink.TargetPath = "%EXE_PATH%"
    echo oLink.WorkingDirectory = "%cd%\dist"
    echo oLink.Description = "CLIP Image Classifier - Production"
    echo oLink.Save
) > create_shortcut.vbs

cscript create_shortcut.vbs
del create_shortcut.vbs

echo ✓ Desktop shortcut created
echo.

echo Installing to Program Files...
set "INSTALL_PATH=C:\Program Files\CLIP Classifier"

if not exist "%INSTALL_PATH%" mkdir "%INSTALL_PATH%"
xcopy "dist\*.*" "%INSTALL_PATH%\" /E /Y /I >nul

echo ✓ Application installed to: %INSTALL_PATH%
echo.
goto complete

:invalid
echo ❌ Invalid selection
echo.
goto install_options

:cancel
echo Installation cancelled
exit /b 0

:complete
echo ════════════════════════════════════════════════════════════════════════
echo      ✅ Installation Complete
echo ════════════════════════════════════════════════════════════════════════
echo.
echo Desktop shortcut created: "CLIP Classifier.lnk"
echo.
echo To Start the Application:
echo   - Double-click the "CLIP Classifier" shortcut on your desktop
echo   - Or run CLIP_Classifier.exe from the installed folder
echo.
echo First Run:
echo   - Allow 30-60 seconds for the model to load
echo   - The CLIP model (~2 GB) will download on first run
echo   - Subsequent runs will be faster
echo.
echo System Requirements:
echo   - Windows 10/11 (64-bit)
echo   - 4+ GB RAM (8+ GB recommended)
echo   - 4+ GB free disk space
echo   - NVIDIA GPU with CUDA support (recommended)
echo.
pause
