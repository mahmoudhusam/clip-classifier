@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM CLIP Classifier - GPU Portable Setup
REM
REM Run this ONCE on any machine with internet access.
REM It creates a fully self-contained folder you can copy to any flash drive.
REM Target machines need only an NVIDIA GPU with drivers - nothing else.
REM ============================================================================

set PORTABLE_NAME=CLIP_Classifier_GPU_Portable
set PYTHON_VER=3.11.9
set PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VER%/python-%PYTHON_VER%-embed-amd64.zip

REM ── CHANGE THIS if CUDA 12.1 does not match your GPU driver ──────────────
REM   cu118  →  CUDA 11.8  (older GPUs / drivers)
REM   cu121  →  CUDA 12.1  (GTX 10xx and newer)
REM   cu124  →  CUDA 12.4+ / 13.x  (current - set for your driver 581.83)
REM   Run `nvidia-smi` to see your CUDA version, then pick the closest below.
set CUDA_VER=cu124
REM ─────────────────────────────────────────────────────────────────────────

echo.
echo ================================================================
echo   CLIP Classifier - GPU Portable Setup
echo ================================================================
echo.
echo   Output folder : %PORTABLE_NAME%\
echo   Model         : openai/clip-vit-large-patch14  (best quality)
echo   GPU support   : CUDA (%CUDA_VER%)
echo   Python        : %PYTHON_VER% (embedded - no install needed)
echo.
echo   Estimated download : ~3.5 GB
echo   Estimated time     : 10-30 min depending on internet speed
echo.
echo   Flash drive needed : 8 GB or larger
echo.
echo Press any key to start or close this window to cancel.
pause >nul

REM ── Prerequisite checks ──────────────────────────────────────────────────
echo.
echo Checking prerequisites...

if not exist "main.py" (
    echo.
    echo ERROR: Run this script from inside the clip-classifier project folder.
    echo        Expected to find main.py here but did not.
    pause & exit /b 1
)

powershell -Command "exit 0" >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell is not available. It is required to download files.
    pause & exit /b 1
)

echo   OK

REM ── [1/7] Create folder structure ────────────────────────────────────────
echo.
echo [1/7] Creating folder structure...
if exist "%PORTABLE_NAME%" (
    echo   Removing old folder...
    rmdir /s /q "%PORTABLE_NAME%"
)
mkdir "%PORTABLE_NAME%"
mkdir "%PORTABLE_NAME%\python"
mkdir "%PORTABLE_NAME%\app"
mkdir "%PORTABLE_NAME%\models"
echo   Done.

REM ── [2/7] Download Python embeddable ─────────────────────────────────────
echo.
echo [2/7] Downloading Python %PYTHON_VER% embeddable (~10 MB)...
powershell -Command "Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile 'python_embed.zip' -UseBasicParsing"
if errorlevel 1 (
    echo ERROR: Could not download Python. Check your internet connection.
    pause & exit /b 1
)
echo   Extracting...
powershell -Command "Expand-Archive -Path 'python_embed.zip' -DestinationPath '%PORTABLE_NAME%\python' -Force"
del python_embed.zip
echo   Done.

REM ── [3/7] Configure embedded Python ──────────────────────────────────────
echo.
echo [3/7] Configuring embedded Python...

REM Find the ._pth file (name changes with Python version, e.g. python311._pth)
for %%f in ("%PORTABLE_NAME%\python\python3*._pth") do set PTH_FILE=%%f
echo   Patching: !PTH_FILE!

REM Uncomment "import site" so pip-installed packages are discoverable
powershell -Command "(Get-Content '!PTH_FILE!') -replace '#import site', 'import site' | Set-Content '!PTH_FILE!'"

REM Install pip into the embedded Python
echo   Installing pip...
powershell -Command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile 'get-pip.py' -UseBasicParsing"
"%PORTABLE_NAME%\python\python.exe" get-pip.py --no-warn-script-location >nul 2>&1
del get-pip.py
echo   Done.

REM ── [4/7] Install CUDA PyTorch ────────────────────────────────────────────
echo.
echo [4/7] Installing CUDA PyTorch (%CUDA_VER%) - largest download (~2.5 GB)...
echo   Please wait - this can take 10-20 minutes on a slow connection.
echo.
"%PORTABLE_NAME%\python\python.exe" -m pip install torch torchvision torchaudio ^
    --index-url https://download.pytorch.org/whl/%CUDA_VER% ^
    --no-warn-script-location
if errorlevel 1 (
    echo.
    echo ERROR: PyTorch install failed.
    echo   - Check your internet connection.
    echo   - Try changing CUDA_VER at the top of this script.
    echo     Run 'nvidia-smi' on your machine and match the CUDA version.
    pause & exit /b 1
)
echo   Done.

REM ── [5/7] Install other dependencies ─────────────────────────────────────
echo.
echo [5/7] Installing app dependencies (~300 MB)...
"%PORTABLE_NAME%\python\python.exe" -m pip install ^
    fastapi "uvicorn[standard]" transformers ^
    openpyxl reportlab python-multipart pydantic ^
    tqdm pillow numpy pandas ^
    --no-warn-script-location
if errorlevel 1 (
    echo ERROR: Dependency install failed.
    pause & exit /b 1
)
echo   Done.

REM ── [6/7] Copy app files ─────────────────────────────────────────────────
echo.
echo [6/7] Copying application files...
xcopy /E /I /Q backend  "%PORTABLE_NAME%\app\backend\"  >nul
xcopy /E /I /Q frontend "%PORTABLE_NAME%\app\frontend\" >nul
copy main.py    "%PORTABLE_NAME%\app\" >nul
copy config.json "%PORTABLE_NAME%\app\" >nul
echo   Done.

REM ── [7/7] Download CLIP model ─────────────────────────────────────────────
echo.
echo [7/7] Downloading CLIP large model (~890 MB)...
echo   This is bundled into the package so target machines need NO internet.
echo.
set HF_HOME=%cd%\%PORTABLE_NAME%\models
"%PORTABLE_NAME%\python\python.exe" -c ^
    "from transformers import CLIPModel, CLIPProcessor; print('  Downloading weights...'); CLIPModel.from_pretrained('openai/clip-vit-large-patch14'); print('  Downloading processor...'); CLIPProcessor.from_pretrained('openai/clip-vit-large-patch14'); print('  Model ready!')"
if errorlevel 1 (
    echo ERROR: Model download failed. Check internet connection.
    pause & exit /b 1
)

REM ── Create launcher files ─────────────────────────────────────────────────
echo.
echo Creating launcher files...
"%PORTABLE_NAME%\python\python.exe" _write_launchers.py "%PORTABLE_NAME%"

REM ── Done ──────────────────────────────────────────────────────────────────
echo.
echo ================================================================
echo   SUCCESS!
echo ================================================================
echo.
echo   Portable folder: %cd%\%PORTABLE_NAME%\
echo.
echo   Contents:
echo     python\          - Embedded Python + all packages + CUDA
echo     app\             - Application source
echo     models\          - Pre-downloaded CLIP model
echo     START.bat        - Launch with visible server window
echo     START_HIDDEN.vbs - Launch silently (browser opens, no window)
echo     README.txt       - Instructions for end users
echo.
echo   TO DEPLOY:
echo     1. Copy the %PORTABLE_NAME%\ folder to an 8GB+ flash drive
echo     2. Plug drive into any Windows machine with an NVIDIA GPU
echo     3. Double-click START_HIDDEN.vbs
echo     4. Browser opens at http://127.0.0.1:5000  -  done!
echo.
echo   No Python, no CUDA toolkit, no installation needed on target machines.
echo   Only requirement: NVIDIA GPU drivers (usually already installed).
echo.
pause
