# Flash Drive Setup - Complete Guide

## 🎯 Your Goal: Build Once, Run Everywhere

You want to build the application **ONCE** on one Windows machine, put it on a flash drive, and run it on any Windows machine without rebuilding. This guide shows exactly how to do it.

---

## 📋 Complete Step-by-Step Process

### Phase 1: Build (On Your First Test Machine)

**Duration:** 5-15 minutes
**Internet:** Required (for PyTorch download)
**One-time:** You only do this once!

#### Step 1.1 - Prepare

```
1. Download/clone the application to your first Windows test machine
2. Extract to a folder (e.g., C:\Users\YourName\Desktop\clip-classifier)
3. Open Command Prompt in that folder
4. Make sure you have Python 3.10+ installed
```

#### Step 1.2 - Run Build Script

```batch
build_windows.bat
```

**What happens:**

- Creates virtual environment
- Installs PyTorch with CUDA support
- Packages everything into executable
- Creates `dist\CLIP_Classifier.exe`

**You'll see:**

```
[Progress messages...]
Build completed successfully!
dist/CLIP_Classifier.exe ready!
```

**Wait for:** "BUILD COMPLETE" message

---

### Phase 2: Create Portable Package (On Same Machine)

**Duration:** 1 minute
**Internet:** Not required
**Location:** Same folder as build

#### Step 2.1 - Create Portable

```batch
create_portable.bat
```

**What happens:**

- Creates `CLIP_Classifier_Portable` folder
- Includes executable and all dependencies
- Adds launcher scripts and instructions

**You'll see:**

```
[Progress messages...]
SUCCESS! Portable package created!
CLIP_Classifier_Portable folder ready!
```

---

### Phase 3: Copy to Flash Drive (On Same Machine)

**Duration:** 5 minutes (depends on USB speed)
**Internet:** Not required

#### Step 3.1 - Prepare USB

1. Insert USB flash drive
2. Make sure it has at least **4 GB free space**
3. Note its drive letter (e.g., E:, F:, etc.)

#### Step 3.2 - Copy Files

```
Method 1 (Easy):
1. Open Windows File Explorer
2. Navigate to your project folder
3. Right-click: CLIP_Classifier_Portable folder
4. Click: Copy
5. Navigate to USB drive
6. Right-click in empty space
7. Click: Paste
8. Wait for copy to complete

Method 2 (Via Command Prompt):
1. Open Command Prompt
2. Navigate to project folder
3. Run: xcopy CLIP_Classifier_Portable F: /E /I
   (Replace F: with your USB drive letter)
4. Wait for completion
```

#### Step 3.3 - Verify

```
1. Open USB drive folder
2. You should see: CLIP_Classifier_Portable folder
3. Click into it
4. You should see: CLIP_Classifier.exe, START.bat, etc.
```

#### Step 3.4 - Eject USB Safely

```
1. Right-click USB drive in File Explorer
2. Click: Eject
3. When it says safe to remove, unplug USB
```

---

### Phase 4: Use on Any Windows Machine

**Duration:** 30-60 seconds (first run) or 5 seconds (after first run)
**Internet:** Required for first run only
**Machines:** Works on all Windows 10/11 64-bit machines

#### Step 4.1 - Plug In USB

```
1. Insert USB flash drive into target Windows machine
2. Open File Explorer
3. Navigate to USB drive
4. You should see: CLIP_Classifier_Portable folder
```

#### Step 4.2 - Start Application

```
Method 1 (Recommended):
1. Double-click: CLIP_Classifier_Portable\START.bat
2. Command window appears (normal)
3. Wait 30-60 seconds...

Method 2 (Silent):
1. Double-click: CLIP_Classifier_Portable\START_HIDDEN.vbs
2. Application starts without command window

Method 3 (Direct):
1. Double-click: CLIP_Classifier_Portable\CLIP_Classifier.exe
2. Similar to Method 1
```

#### Step 4.3 - Wait for Model Load

```
First Time (30-60 seconds):
- You'll see: "Loading CLIP model..."
- Model downloads (~2GB)
- Stored locally in: AppData\Roaming\huggingface
- Browser opens automatically

Subsequent Times (5 seconds):
- Model already cached
- Starts instantly
- Browser opens automatically
```

#### Step 4.4 - Use Application

```
1. Browser opens to: http://127.0.0.1:5000
2. Upload images
3. Add labels
4. Click "Classify Images"
5. View results!
```

---

## 🔄 Repeat Usage

**On the Same USB Drive (Any Windows Machine):**

Each subsequent use:

1. Plug USB into any Windows 10/11 computer
2. Double-click: CLIP_Classifier_Portable\START.bat
3. Browser opens (model already cached from first run)
4. Use normally

**No rebuilding. No installation. No setup. Just run!**

---

## 📊 Storage Requirements

### Before First Run

```
USB drive folder size: 1-2 GB
Required free space: 4 GB
Total needed on USB: 6 GB (to be safe)
```

### After First Run (On target machine's disk)

```
USB folder: Still 1-2 GB
Model cache: ~2 GB (stored on target machine's local disk)
Total disk used: 3-4 GB (on target machine)
```

---

## 🎨 Customization (Optional)

If you want to modify the application before putting it on USB:

### Change Model Quality

Edit `CLIP_Classifier_Portable\config.json`:

```json
{
  "model": "openai/clip-vit-base-patch32" /* Faster but less accurate */,
  "device": "cpu" /* Use CPU instead of GPU */
}
```

### Change Default Labels

Edit `CLIP_Classifier_Portable\config.json`:

```json
{
  "default_labels": ["custom", "labels", "here"]
}
```

---

## ✅ Verification Checklist

### After Building and Creating Portable

- [ ] `dist\CLIP_Classifier.exe` exists (1+ GB)
- [ ] `CLIP_Classifier_Portable` folder exists
- [ ] `CLIP_Classifier_Portable\CLIP_Classifier.exe` exists
- [ ] `CLIP_Classifier_Portable\START.bat` exists
- [ ] `CLIP_Classifier_Portable\README.txt` exists

### After Copying to USB

- [ ] USB shows `CLIP_Classifier_Portable` folder
- [ ] Folder contains executable
- [ ] All files copied successfully
- [ ] USB ejected safely

### After First Run on Target Machine

- [ ] Application started (may take 30-60 sec)
- [ ] Browser opened to http://127.0.0.1:5000
- [ ] Web UI loaded
- [ ] Can upload images
- [ ] Can classify images
- [ ] Can export results

---

## 🚨 Troubleshooting

### Build Fails

**Problem:** build_windows.bat exits with error
**Solution:**

- Check Python 3.10+ is installed: `python --version`
- Check Python is in PATH
- Check internet connection
- Try running as Administrator
- Delete venv folder and try again

### Portable Creation Fails

**Problem:** create_portable.bat says "dist\CLIP_CLASSIFIER.exe not found"
**Solution:**

- Run build_windows.bat first
- Wait for it to complete fully
- Then run create_portable.bat

### Can't Copy to USB

**Problem:** Permission denied when copying
**Solution:**

- Eject and re-insert USB
- Try right-click → Copy (not cut)
- Check USB isn't write-protected
- Format USB if still failing

### Application Won't Start

**Problem:** Double-clicking START.bat does nothing
**Solution:**

- Windows Defender might block it:
  - Windows Defender → Virus & threat protection → Manage settings
  - Add C:\USB_DRIVE\CLIP_Classifier_Portable to exclusions
- Try running as Administrator
- Try START_HIDDEN.vbs instead
- Check antivirus isn't blocking

### "Model failed to download"

**Problem:** Error when starting application first time
**Solution:**

- Check internet connection
- Check firewall isn't blocking Python
- Check 4 GB disk space available
- Try copying folder to local disk first
- Try again - sometimes network is temporary

### Application Very Slow

**Problem:** Takes 5+ minutes to start first time
**Solution:**

- USB 2.0 is slow - normal for first run
- Copy folder to local disk: C:\Users\YourName\Desktop\
- Run from local disk first (faster)
- Model downloads much faster on local disk
- Then model is cached for USB use

### "Out of memory"

**Problem:** Error when uploading many images
**Solution:**

- Close other applications
- Restart application
- Reduce number of images
- Edit config.json: reduce batch_size to 8

---

## 🌟 Best Practices

✅ **DO:**

- Keep USB in safe place
- Test on multiple Windows machines
- Copy to local disk for first run (faster)
- Check internet before first run
- Keep at least 6 GB free on USB

❌ **DON'T:**

- Unplug USB while application is running
- Edit files inside CLIP_Classifier_Portable (they reset on run)
- Force-close application without stopping from UI
- Use USB 2.0 for first model download (too slow)

---

## 📈 Performance Tips

For Maximum Speed:

1. **Use local disk for first run** (much faster)
2. **Have 8+ GB RAM** (uses 4 GB actively)
3. **Use machine with GPU** (3-5x faster)
4. **Close other applications** (frees memory)
5. **Use SSD** (faster file I/O)

For Minimum Requirements:

1. Windows 10/11 64-bit ✓
2. 4 GB RAM minimum ✓
3. 4 GB USB space + 4 GB disk space ✓
4. Internet for first run only ✓
5. Works on CPU if no GPU ✓

---

## 🎊 Success!

Once you see the browser open with the web interface:

✅ Build completed
✅ Portable created
✅ USB ready
✅ Application running
✅ Ready for deployment!

---

## 📞 Quick Reference

```
ON FIRST TEST MACHINE:
  Step 1: build_windows.bat              (5-15 min)
  Step 2: create_portable.bat            (1 min)
  Step 3: Copy to USB manually           (5 min)
  Step 4: Eject USB safely               (1 min)

ON ANY OTHER MACHINE:
  Step 1: Plug USB in
  Step 2: Open CLIP_Classifier_Portable folder
  Step 3: Double-click START.bat
  Step 4: Wait 30-60 seconds (first run)
  Step 5: Use application!

TOTAL TIME:
  Initial Setup: 20-30 minutes
  Each New Machine: 1 minute + first-run wait
  Subsequent Runs: 5 seconds
```

---

**You're all set for portable deployment!** 🚀
