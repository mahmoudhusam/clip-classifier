# CLIP Classifier - Windows Production Setup Guide

## Quick Start (Choose One Method)

### Method 1: Automated Build (Recommended)

1. **Download and Extract** the application to your Windows machine
   - Extract the ZIP file to a folder like `C:\CLIP_Classifier`

2. **Run Build Script**
   - Double-click `build_windows.bat`
   - Wait for it to complete (5-15 minutes)
   - The executable will be created in the `dist` folder

3. **Run Application**
   - Double-click `run_production.bat`
   - The app will start and open in your browser

### Method 2: Manual Build (Advanced)

```batch
REM Open Command Prompt in the application folder

REM Create virtual environment
python -m venv venv

REM Activate virtual environment
venv\Scripts\activate.bat

REM Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
pip install pyinstaller

REM Build executable
pyinstaller CLIP_Classifier.spec

REM Run the application
dist\CLIP_Classifier.exe
```

## System Requirements

### Minimum

- Windows 10/11 (64-bit)
- Python 3.10+
- 4 GB RAM
- 4 GB free disk space

### Recommended (for Best Performance)

- Windows 10/11 (64-bit)
- 8+ GB RAM
- NVIDIA GPU with CUDA support (highly recommended for speed)
- 8 GB free disk space

## What Gets Installed

### First Run (One-Time)

- CLIP Model (openai/clip-vit-large-patch14) - ~2 GB
- All dependencies bundled in the executable

### After First Run

- Model is cached locally for instant subsequent launches
- No additional downloads needed

## File Descriptions

| File                       | Purpose                        |
| -------------------------- | ------------------------------ |
| `build_windows.bat`        | Creates the Windows executable |
| `run_production.bat`       | Launches the application       |
| `CLIP_Classifier.spec`     | PyInstaller configuration      |
| `main.py`                  | Application entry point        |
| `dist/CLIP_Classifier.exe` | Final Windows executable       |

## Detailed Build Steps

### Step 1: Prepare Environment

- Ensure Python 3.10+ is installed
- Python should be in your system PATH

### Step 2: Run Build

- Execute `build_windows.bat`
- It will:
  - Create a virtual environment
  - Install all dependencies (including CUDA-enabled PyTorch)
  - Build the executable using PyInstaller
  - Create optimized distribution package

### Step 3: First Run

- Execute `run_production.bat` or directly run `dist/CLIP_Classifier.exe`
- Browser will open to http://127.0.0.1:5000
- Wait for model to load (30-60 seconds)

### Step 4: Start Classifying

- Upload images (unlimited)
- Add classification labels (2+)
- Click "Classify Images"
- Download results in multiple formats

## Troubleshooting

### Issue: Python not found

**Solution:** Install Python 3.10+ from python.org and ensure it's in PATH

### Issue: Build fails with CUDA errors

**Solution:** The build will work without CUDA - PyTorch will fall back to CPU mode

### Issue: CLIP model won't download

**Solution:**

- Check internet connection
- Model downloads once on first run (~2 GB)
- Ensure 4 GB free disk space

### Issue: Model is very slow

**Solution:**

- Application defaults to CUDA (GPU) if available
- Ensure NVIDIA drivers are up to date
- CPU mode works but is slower

## Features

✅ **Unlimited Image Upload** - Process as many images as memory allows
✅ **Multiple Export Formats** - JSON, CSV, Excel, PDF
✅ **Custom Presets** - Create and manage classification label presets
✅ **Confidence Filtering** - Filter results by confidence threshold
✅ **No Internet Required** - Runs completely offline
✅ **Production Quality** - Uses best CLIP model (large)
✅ **GPU Acceleration** - CUDA support for maximum speed
✅ **Standalone Executable** - No dependencies needed after build

## Advanced Configuration

### Change Model (Development vs Production)

Edit `config.json`:

```json
{
  "dev": {
    "model": "openai/clip-vit-base-patch32",
    "device": "cpu",
    "batch_size": 4
  },
  "production": {
    "model": "openai/clip-vit-large-patch14",
    "device": "cuda",
    "batch_size": 32
  }
}
```

The build automatically uses **production mode** (best model).

## Distributing to Other Machines

After successful build:

1. Copy the entire `dist` folder to target machine
2. Or create a ZIP: `dist/CLIP_Classifier.exe` + supporting files
3. No Python or virtual environment needed on target machine
4. Just run `CLIP_Classifier.exe`

## Support

For issues or questions:

- Check the troubleshooting section above
- Ensure all system requirements are met
- Verify sufficient disk space for model caching

---

**Version:** 1.0.0
**Last Updated:** May 8, 2026
**Status:** Production Ready
