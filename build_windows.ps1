# CLIP Classifier - Windows Production Build Script (PowerShell Version)
# Run: powershell -ExecutionPolicy Bypass -File build_windows.ps1

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CLIP Image Classifier - Windows Production Packaging" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check Python
Write-Host "Checking Python installation..." -ForegroundColor Yellow
$pythonCheck = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python 3.10+ from python.org" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ $pythonCheck" -ForegroundColor Green

# Create virtual environment
if (!(Test-Path "venv")) {
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to create virtual environment" -ForegroundColor Red
        exit 1
    }
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Yellow
& "venv\Scripts\Activate.ps1"

# Install dependencies
Write-Host ""
Write-Host "Installing production dependencies..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Yellow
Write-Host ""

pip install --upgrade pip setuptools wheel | Out-Null
pip install pyinstaller>=6.0.0
pip install fastapi uvicorn[standard] transformers openpyxl reportlab python-multipart pydantic tqdm typer typing_extensions

# Install PyTorch with CUDA
Write-Host ""
Write-Host "Installing PyTorch with CUDA support..." -ForegroundColor Yellow
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

Write-Host ""
Write-Host "✓ All dependencies installed successfully" -ForegroundColor Green
Write-Host ""

# Build executable
Write-Host "Building Windows executable..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Yellow
Write-Host ""

pyinstaller CLIP_Classifier.spec --distpath dist --buildpath build --specpath . --clean

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Build failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ Build Completed Successfully!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is ready in the 'dist' folder:" -ForegroundColor Cyan
Write-Host "  Location: $(Get-Location)\dist\CLIP_Classifier.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Copy the entire 'dist' folder to your production Windows machine" -ForegroundColor Cyan
Write-Host "  2. Run CLIP_Classifier.exe" -ForegroundColor Cyan
Write-Host "  3. The app will open in your default browser at http://127.0.0.1:5000" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  First Run:" -ForegroundColor Yellow
Write-Host "  - The CLIP model will download (~2 GB) on first run" -ForegroundColor Yellow
Write-Host "  - This may take 5-10 minutes depending on internet speed" -ForegroundColor Yellow
Write-Host "  - The model is cached locally for future runs" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"
