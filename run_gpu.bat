@echo off
REM ============================================================================
REM CLIP Classifier - GPU Runner (CUDA + Best Model)
REM Run from source with CUDA support — no exe build needed
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ============================================================
echo   CLIP Image Classifier - GPU Mode (Best Model + CUDA)
echo ============================================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Install Python 3.10+ from python.org
    pause
    exit /b 1
)

REM Create venv if missing
if not exist "venv\" (
    echo Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo ERROR: Failed to create virtual environment
        pause
        exit /b 1
    )
    echo Done.
    echo.
)

REM Activate venv
call venv\Scripts\activate.bat

REM Check if torch is installed
python -c "import torch" >nul 2>&1
if errorlevel 1 (
    echo PyTorch not found. Installing dependencies...
    echo.
    echo  >> Installing CUDA PyTorch (CUDA 12.1)...
    echo     If this fails, check your CUDA version with: nvidia-smi
    echo     Then edit this file and change cu121 to cu118 or cu124
    echo.
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    pip install fastapi uvicorn[standard] transformers openpyxl reportlab python-multipart pydantic tqdm pillow numpy pandas
    echo.
    echo Dependencies installed.
    echo.
)

REM Verify CUDA is available
python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None')"
echo.

echo Starting CLIP Classifier with best model (openai/clip-vit-large-patch14)...
echo First run will download ~890MB model. Subsequent runs are instant.
echo.
echo Open your browser to: http://127.0.0.1:5000
echo Press Ctrl+C to stop.
echo.

python main.py
pause
