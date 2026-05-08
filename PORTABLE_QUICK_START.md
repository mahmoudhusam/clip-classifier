# Quick Start - Portable Flash Drive (Easiest Method)

## The Simple Way 🚀

### Step 1: Build Once (5-15 minutes)

On your first Windows test machine:

```batch
REM Open Command Prompt in the project folder
build_windows.bat

REM Wait for it to complete...
REM You'll see: dist\CLIP_Classifier.exe created ✓
```

### Step 2: Create Portable Package (1 minute)

```batch
REM Still in the project folder, run:
create_portable.bat

REM You'll see: CLIP_Classifier_Portable folder created ✓
```

### Step 3: Copy to Flash Drive (5 minutes)

1. Insert USB flash drive into your Windows machine
2. Copy the entire `CLIP_Classifier_Portable` folder to the USB
3. Eject USB safely

### Step 4: Use on Any Windows Machine ✨

1. Plug USB into any other Windows computer
2. Open the USB drive folder
3. Double-click: `CLIP_Classifier_Portable\START.bat`
4. Wait 30-60 seconds (first run only - model downloads)
5. Browser opens automatically
6. Done! Classify images!

**That's it.** No installation, no setup, no rebuild needed. Just plug and play.

---

## What's in the Portable Folder

```
CLIP_Classifier_Portable/
├── CLIP_Classifier.exe          ← Main application (just click it!)
├── START.bat                    ← Easy launcher (recommended)
├── START_HIDDEN.vbs             ← Alternative (hides console)
├── README.txt                   ← Instructions
├── _internal/                   ← All dependencies (bundled)
├── frontend/                    ← Web UI files
└── config.json                  ← Configuration
```

---

## Key Benefits of This Approach

✅ **Build Once** - No rebuilding on each machine
✅ **Portable** - Runs from USB or any folder
✅ **Simple** - Just double-click to start
✅ **Self-Contained** - No installation needed
✅ **Offline** - Works completely offline
✅ **Fast** - Subsequent runs are instant

---

## First Run (30-60 seconds)

When you first run the application:

- Model downloads (~2GB)
- Cached locally (next runs are instant)
- Requires internet connection (only first time)

---

## Optimal Workflow

### For You (Developer):

1. Build once on your first Windows test machine: `build_windows.bat`
2. Create portable: `create_portable.bat`
3. Copy `CLIP_Classifier_Portable` to USB
4. Done! Ready for deployment

### For Anyone Using It:

1. Plug USB into Windows machine
2. Open `CLIP_Classifier_Portable` folder
3. Double-click `START.bat`
4. Classify images!

---

## Alternative: Run from Local Disk

If USB is slow on first run:

1. Copy `CLIP_Classifier_Portable` folder from USB to Desktop
2. Run `START.bat` from Desktop copy
3. Model downloads (one-time, ~2GB)
4. Super fast after that!

---

## Minimum System Requirements

- Windows 10 or Windows 11 (64-bit)
- 4 GB RAM
- 4 GB disk space (for initial setup)
- 3 GB more after first run (for model cache)

---

## Notes

- **First run slower?** Normal - model downloads. Be patient.
- **Slow USB drive?** Copy folder to local disk first, then run.
- **No GPU?** Works fine on CPU - just slower.
- **Multiple users?** Each person can plug in the same USB.
- **Offline usage?** Totally fine after first run.

---

## Troubleshooting

| Problem                | Solution                             |
| ---------------------- | ------------------------------------ |
| Program won't start    | Run as Administrator                 |
| Takes forever to start | First run = model download. Wait.    |
| Error about model      | Check internet connection            |
| Out of memory          | Close other apps, restart            |
| GPU not detected       | CPU mode is fine                     |
| Browser doesn't open   | Go to http://127.0.0.1:5000 manually |

---

**Everything ready. Just plug and play! 🎉**
