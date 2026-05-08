@echo off
REM ============================================================================
REM CLIP Classifier - Windows Production Build Script
REM Packages the application into a standalone Windows executable
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ════════════════════════════════════════════════════════════════════════
echo      CLIP Image Classifier - Windows Production Packaging
echo ════════════════════════════════════════════════════════════════════════
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed or not in PATH
    echo Please install Python 3.10+ and add it to your system PATH
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist "venv\" (
    echo Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo ❌ Failed to create virtual environment
        pause
        exit /b 1
    )
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install/update dependencies
echo.
echo Installing production dependencies (including PyInstaller, CUDA-enabled PyTorch)...
echo This may take several minutes...
echo.

REM Install core dependencies
pip install --upgrade pip setuptools wheel >nul 2>&1
pip install pyinstaller>=6.0.0
pip install fastapi uvicorn[standard] transformers openpyxl reportlab python-multipart pydantic tqdm typer typing_extensions

REM Install PyTorch CPU version for Windows
echo.
echo Installing PyTorch (CPU version)...
pip install torch torchvision torchaudio

echo.
echo ✓ All dependencies installed successfully
echo.

REM Build the executable
echo Building Windows executable...
echo This may take several minutes...
echo.

pyinstaller CLIP_Classifier.spec --distpath dist --buildpath build --specpath . --clean

if errorlevel 1 (
    echo.
    echo ❌ Build failed. Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo ════════════════════════════════════════════════════════════════════════
echo      ✅ Build Completed Successfully!
echo ════════════════════════════════════════════════════════════════════════
echo.
echo Your application is ready in the 'dist' folder:
echo   Location: %cd%\dist\CLIP_Classifier.exe
echo.
echo Next Steps:
echo   1. Copy the entire 'dist' folder to your production Windows machine
echo   2. Run CLIP_Classifier.exe
echo   3. The app will open in your default browser at http://127.0.0.1:5000
echo.
echo ⚠️  First Run:
echo   - The CLIP model will download (~2 GB) on first run
echo   - This may take 5-10 minutes depending on internet speed
echo   - The model is cached locally for future runs
echo.
echo 📝 System Requirements:
echo   - Windows 10/11 (64-bit)
echo   - 4GB RAM minimum (8GB recommended)
echo   - 4GB free disk space for model cache
echo   - GPU recommended (NVIDIA with CUDA support)
echo.
pause
