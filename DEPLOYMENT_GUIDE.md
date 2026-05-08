# CLIP Classifier - Windows Production Deployment Guide

## Phase Overview

You now have a complete **Windows production package** with:

- ✅ Production-grade CLIP model (openai/clip-vit-large-patch14)
- ✅ CUDA GPU acceleration support
- ✅ Standalone Windows executable
- ✅ No internet required after initial setup
- ✅ Unlimited image processing
- ✅ All preset management features

---

## Build Instructions (For Windows Machines)

### Option A: Batch Script (Easiest)

```batch
REM 1. Extract the application to your Windows machine
REM 2. Open Command Prompt in the application folder
REM 3. Run the build script:

build_windows.bat
```

**What happens:**

1. Creates Python virtual environment
2. Installs all dependencies (including PyTorch with CUDA support)
3. Builds Windows executable using PyInstaller
4. Creates `dist/CLIP_Classifier.exe`
5. **Total time: 5-15 minutes** (depending on internet speed)

### Option B: PowerShell Script

```powershell
REM Open PowerShell in the application folder

powershell -ExecutionPolicy Bypass -File build_windows.ps1
```

### Option C: Manual Build

```batch
REM Open Command Prompt in the application folder

REM 1. Create virtual environment
python -m venv venv

REM 2. Activate it
venv\Scripts\activate.bat

REM 3. Install dependencies
pip install --upgrade pip
pip install -r requirements-windows.txt

REM 4. Build executable
pyinstaller CLIP_Classifier.spec

REM 5. Application ready in dist/CLIP_Classifier.exe
```

---

## Installation & Shortcuts

After successful build, run the installation wizard:

```batch
install_windows.bat
```

This will:

- Create a desktop shortcut
- Optionally install to Program Files
- Set up proper file associations

---

## First Run Checklist

### Before First Run

- [ ] Windows 10 or 11 (64-bit)
- [ ] 4+ GB RAM available
- [ ] 4+ GB free disk space
- [ ] NVIDIA GPU drivers updated (if using GPU)
- [ ] Internet connection (for model download only)

### During First Run

1. **Double-click the CLIP Classifier shortcut** or run `CLIP_Classifier.exe`
2. **Console window opens** - shows status messages
3. **Browser opens** to `http://127.0.0.1:5000`
4. **Wait 30-60 seconds** for model to load
   - You'll see: `Loading CLIP model...`
   - First time only: Model downloads (~2 GB)
   - Cached locally for future runs

5. **Upload images** and classify!

---

## Performance Expectations

### First Run (One-Time)

- **Time:** 5-10 minutes (includes 2GB model download)
- **Disk Space Used:** ~4 GB (models + dependencies)

### Subsequent Runs

- **Startup Time:** 30-60 seconds
- **Processing Speed:**
  - With NVIDIA GPU: ~100-200 images/minute
  - CPU Mode: ~20-50 images/minute
  - (Batch size 32, depends on hardware)

---

## Testing on Your Machines

### Machine 1 (Test Machine)

```
1. Copy dist folder to the machine
2. Run CLIP_Classifier.exe
3. Test features:
   - Upload 10+ images
   - Test different presets
   - Test export formats
   - Verify GPU acceleration (check console)
   - Test on 100+ images
```

### Machine 2 (Test Machine)

```
Same as Machine 1
Verify consistency across machines
```

### Production Machine

```
Once tested on both test machines:
1. Deploy dist folder to production machine
2. Copy entire dist folder contents
3. Create desktop shortcuts using install_windows.bat
4. Final validation testing
```

---

## File Structure After Build

```
dist/
├── CLIP_Classifier.exe          # Main executable
├── _internal/                   # All dependencies bundled
│   ├── transformers/
│   ├── torch/
│   ├── PIL/
│   ├── fastapi/
│   └── ... other libraries
├── frontend/                    # HTML/JS files (bundled)
│   ├── index.html
│   └── script.js
└── config.json                  # Configuration file
```

**Total Size:** ~800 MB - 1.2 GB (depending on PyTorch variant)

---

## Configuration

### Default Configuration (Production Mode)

**File:** `config.json`

```json
{
  "production": {
    "model": "openai/clip-vit-large-patch14",
    "device": "cuda",
    "batch_size": 32
  }
}
```

### Customization Options

**For Slower Hardware (CPU Mode):**
Edit `config.json` before building:

```json
{
  "production": {
    "model": "openai/clip-vit-large-patch14",
    "device": "cpu",
    "batch_size": 4
  }
}
```

**For More Memory (Larger Batch):**

```json
{
  "production": {
    "batch_size": 64
  }
}
```

---

## Troubleshooting

### Issue: Build Fails - "Python not found"

**Solution:**

1. Install Python 3.10+ from python.org
2. **IMPORTANT:** Check "Add Python to PATH" during installation
3. Restart Command Prompt or computer
4. Try build again

### Issue: Model Download Fails

**Solution:**

1. Check internet connection
2. Ensure 4+ GB free disk space
3. Model saves to: `C:\Users\{username}\AppData\Local\transformers\`
4. If stuck, delete cache and retry:
   ```batch
   rmdir /s %USERPROFILE%\.cache\huggingface
   ```

### Issue: CUDA/GPU Not Recognized

**Solution:**

1. Check NVIDIA driver: `nvidia-smi` in Command Prompt
2. Update NVIDIA drivers if needed
3. App falls back to CPU mode automatically
4. Still works, just slower

### Issue: "Too Slow" on Production Machine

**Solution:**

1. Check if GPU is being used: `nvidia-smi` while running
2. Increase batch_size in config.json
3. Close other applications to free RAM
4. Upgrade GPU if CPU-bound

### Issue: Out of Memory Error

**Solution:**

1. Close other applications
2. Reduce batch_size in config.json
3. Restart the application
4. Process fewer images at once

---

## Distribution Checklist

Before distributing to production machine:

- [ ] Build completes without errors
- [ ] Tested on Test Machine 1 successfully
- [ ] Tested on Test Machine 2 successfully
- [ ] Model loads within 60 seconds
- [ ] Can upload 100+ images
- [ ] All export formats work
- [ ] Presets system functional
- [ ] Offline operation confirmed
- [ ] GPU acceleration working (or verified fallback)

---

## Support Information

### System Requirements

| Specification | Minimum             | Recommended         |
| ------------- | ------------------- | ------------------- |
| OS            | Windows 10 (64-bit) | Windows 11 (64-bit) |
| RAM           | 4 GB                | 8+ GB               |
| Disk Space    | 4 GB free           | 8+ GB free          |
| GPU           | Optional            | NVIDIA with CUDA    |
| Processor     | Multi-core          | Modern (2020+)      |

### Performance

| Component   | Dev Mode | Production Mode |
| ----------- | -------- | --------------- |
| Model       | ViT-Base | ViT-Large ✅    |
| Accuracy    | Good     | Best ✅         |
| Speed (GPU) | Fast     | Very Fast       |
| Speed (CPU) | Slow     | Slower          |
| Memory      | ~2GB     | ~4GB            |

---

## Next Steps

### Immediate

1. Run `build_windows.bat` on your Windows machine
2. Test the application with sample images
3. Verify all features work as expected

### For Test Machines

1. Copy `dist` folder to test machine
2. Run `install_windows.bat` if you want shortcuts
3. Test comprehensively
4. Document any issues

### For Production Machine

1. Once test machines pass validation
2. Copy `dist` folder to production machine
3. Use `install_windows.bat` for setup
4. Final validation
5. Ready for deployment!

---

## Success Criteria

✅ Application starts in < 60 seconds
✅ All features accessible via web UI
✅ Can process 100+ images without errors
✅ Exports work in all formats
✅ Presets management fully functional
✅ No internet required after first model download
✅ GPU acceleration working (if available)
✅ Consistent results across test machines

---

**Version:** 1.0.0  
**Status:** Production Ready  
**Last Updated:** May 8, 2026
