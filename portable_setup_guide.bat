@echo off
REM ============================================================================
REM CLIP Classifier - Portable Setup (Visual Summary)
REM ============================================================================
REM This script provides a visual walkthrough of the portable setup process
REM ============================================================================

title CLIP Classifier - Portable Setup Guide

:menu
cls
echo.
echo ============================================================================
echo  CLIP Image Classifier - Portable Flash Drive Setup
echo ============================================================================
echo.
echo  This guide shows you the simplest way to use the application.
echo.
echo  BUILD ONCE >>> PUT ON FLASH DRIVE >>> RUN ANYWHERE
echo.
echo ============================================================================
echo.
echo  What would you like to do?
echo.
echo  1. Show Setup Process (Step-by-Step)
echo  2. Show Quick Start (Fast Version)
echo  3. Show System Requirements
echo  4. Show Troubleshooting
echo  5. Exit
echo.
echo ============================================================================
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto setup_process
if "%choice%"=="2" goto quick_start
if "%choice%"=="3" goto requirements
if "%choice%"=="4" goto troubleshooting
if "%choice%"=="5" goto end
goto menu

:setup_process
cls
echo.
echo ============================================================================
echo  COMPLETE SETUP PROCESS
echo ============================================================================
echo.
echo  STEP 1: BUILD (On Your First Windows Test Machine)
echo  ========================================================
echo.
echo    1. Download the application folder
echo    2. Open Command Prompt in the folder
echo    3. Run: build_windows.bat
echo    4. Wait 5-15 minutes for build to complete
echo    5. You'll see: "dist\CLIP_Classifier.exe created"
echo.
echo.
echo  STEP 2: CREATE PORTABLE (Same Machine)
echo  ========================================================
echo.
echo    1. In Command Prompt, run: create_portable.bat
echo    2. Wait ~1 minute
echo    3. You'll see: "CLIP_Classifier_Portable folder created"
echo.
echo.
echo  STEP 3: COPY TO USB (Same Machine)
echo  ========================================================
echo.
echo    1. Insert USB flash drive (4+ GB free space)
echo    2. Copy "CLIP_Classifier_Portable" folder to USB
echo    3. Safely eject USB
echo.
echo.
echo  STEP 4: USE ON ANY MACHINE
echo  ========================================================
echo.
echo    1. Plug USB into any Windows 10/11 computer
echo    2. Open "CLIP_Classifier_Portable" folder
echo    3. Double-click "START.bat"
echo    4. Wait 30-60 seconds (first run - model downloads)
echo    5. Browser opens automatically
echo    6. Classify images!
echo.
echo.
echo  REPEAT USAGE (Any Machine)
echo  ========================================================
echo.
echo    Each subsequent use:
echo    1. Plug USB in
echo    2. Double-click START.bat
echo    3. Use immediately! (no wait)
echo.
echo ============================================================================
echo.
pause
goto menu

:quick_start
cls
echo.
echo ============================================================================
echo  QUICK START (TL;DR)
echo ============================================================================
echo.
echo  NEVER BUILD AGAIN - Just plug and play!
echo.
echo  ON YOUR FIRST TEST MACHINE:
echo  ════════════════════════════════════════
echo    build_windows.bat           [5-15 minutes]
echo    create_portable.bat         [1 minute]
echo    Copy to USB manually        [5 minutes]
echo    Done! USB ready.
echo.
echo.
echo  ON ANY OTHER MACHINE:
echo  ════════════════════════════════════════
echo    1. Plug USB
echo    2. Double-click: CLIP_Classifier_Portable\START.bat
echo    3. Wait (first time: 30-60 sec, later: instant)
echo    4. Classify images!
echo.
echo ============================================================================
echo.
pause
goto menu

:requirements
cls
echo.
echo ============================================================================
echo  SYSTEM REQUIREMENTS
echo ============================================================================
echo.
echo  TO BUILD (First Test Machine):
echo  ════════════════════════════════════════
echo    - Windows 10 or Windows 11 (64-bit)
echo    - Python 3.10 or higher
echo    - 8 GB RAM (for building)
echo    - 10 GB disk space (for dependencies)
echo    - Internet connection
echo    - NVIDIA GPU (optional - CPU works too)
echo.
echo.
echo  TO RUN (Any Machine):
echo  ════════════════════════════════════════
echo    - Windows 10 or Windows 11 (64-bit)
echo    - 4 GB RAM minimum
echo    - 4 GB USB space + 4 GB disk space
echo    - Internet (first run only)
echo    - NVIDIA GPU (optional)
echo.
echo.
echo  USB DRIVE:
echo  ════════════════════════════════════════
echo    - 6 GB total capacity recommended
echo    - USB 3.0 strongly recommended (faster)
echo    - Any Windows machine with USB port
echo    - Reusable for multiple machines
echo.
echo ============================================================================
echo.
pause
goto menu

:troubleshooting
cls
echo.
echo ============================================================================
echo  TROUBLESHOOTING
echo ============================================================================
echo.
echo  "Build script fails" 
echo  ───────────────────────────────────────
echo    - Check Python 3.10+ installed: python --version
echo    - Check internet connection
echo    - Try running as Administrator
echo    - Delete 'venv' folder and try again
echo.
echo.
echo  "Application won't start"
echo  ───────────────────────────────────────
echo    - Windows Defender may block it (allow in settings)
echo    - Try running as Administrator
echo    - Restart your computer
echo    - Try START_HIDDEN.vbs instead
echo.
echo.
echo  "Model download fails"
echo  ───────────────────────────────────────
echo    - Check internet connection
echo    - Check firewall settings
echo    - Try copying to local disk first
echo    - Retry after internet is stable
echo.
echo.
echo  "Very slow to start"
echo  ───────────────────────────────────────
echo    - First run = model download (normal)
echo    - Copy to local disk for faster first run
echo    - Don't use USB 2.0 for first run
echo    - Be patient (can take 1-2 minutes on slow internet)
echo.
echo.
echo  "Out of memory error"
echo  ───────────────────────────────────────
echo    - Close other applications
echo    - Restart the application
echo    - Upload fewer images at once
echo.
echo.
echo  "GPU not detected"
echo  ───────────────────────────────────────
echo    - CPU mode is fine (just slower)
echo    - Check NVIDIA drivers are updated
echo    - Application will use CPU automatically
echo.
echo ============================================================================
echo.
pause
goto menu

:end
cls
echo.
echo ============================================================================
echo  You're all set!
echo ============================================================================
echo.
echo  For detailed information, see:
echo  - FLASH_DRIVE_SETUP.md (Complete guide)
echo  - PORTABLE_QUICK_START.md (Quick reference)
echo  - README.txt (In portable folder)
echo.
echo  Good luck with your deployment! 🚀
echo.
echo ============================================================================
echo.
