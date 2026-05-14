"""
Helper script called by setup_portable_gpu.bat to write launcher files.
Using Python avoids the batch-file escaping hell for % and special chars.
"""
import os
import sys

portable_dir = sys.argv[1]

# ── START.bat ──────────────────────────────────────────────────────────────
# %~dp0 expands at runtime to the folder containing START.bat,
# so it works on any drive letter (E:\, F:\, etc.)
start_bat = (
    "@echo off\r\n"
    "set ROOT=%~dp0\r\n"
    "set PYTHON=%ROOT%python\\python.exe\r\n"
    "set HF_HOME=%ROOT%models\r\n"
    "set TRANSFORMERS_CACHE=%ROOT%models\r\n"
    "set PYTHONPATH=\r\n"
    "\r\n"
    "echo ================================================\r\n"
    "echo   CLIP Classifier - GPU Mode\r\n"
    "echo ================================================\r\n"
    "echo.\r\n"
    "echo Model : openai/clip-vit-large-patch14\r\n"
    "echo Device : CUDA (GPU)\r\n"
    "echo URL    : http://127.0.0.1:5000\r\n"
    "echo.\r\n"
    "echo Browser will open automatically in 5 seconds.\r\n"
    "echo Close this window to stop the server.\r\n"
    "echo.\r\n"
    "\r\n"
    "cd /d \"%ROOT%app\"\r\n"
    "\r\n"
    "REM Open browser after 5 s in background\r\n"
    "start /B cmd /c \"timeout /t 5 /nobreak >nul & start http://127.0.0.1:5000\"\r\n"
    "\r\n"
    "REM Run server in foreground (close this window to stop)\r\n"
    "\"%PYTHON%\" main.py\r\n"
)

# ── START_HIDDEN.vbs ───────────────────────────────────────────────────────
# Launches START.bat as a minimised window (taskbar icon, can be closed).
# In VBS, "" inside a string is a literal quote character.
start_vbs = (
    'Dim objShell, objFSO, scriptDir\r\n'
    'Set objShell = CreateObject("WScript.Shell")\r\n'
    'Set objFSO   = CreateObject("Scripting.FileSystemObject")\r\n'
    'scriptDir    = objFSO.GetParentFolderName(WScript.ScriptFullName)\r\n'
    'objShell.Run "cmd /c """ & scriptDir & "\\START.bat""", 2, False\r\n'
)

# ── README.txt ─────────────────────────────────────────────────────────────
readme = (
    "CLIP Classifier - GPU Edition\r\n"
    "==============================\r\n"
    "\r\n"
    "HOW TO START\r\n"
    "  Double-click: START_HIDDEN.vbs   (no window, runs silently)\r\n"
    "       -- or --\r\n"
    "  Double-click: START.bat          (shows server window)\r\n"
    "\r\n"
    "  Browser opens automatically at http://127.0.0.1:5000\r\n"
    "\r\n"
    "HOW TO STOP\r\n"
    "  START_HIDDEN.vbs  -> Open Task Manager, end 'python.exe'\r\n"
    "  START.bat         -> Close the server window\r\n"
    "\r\n"
    "REQUIREMENTS\r\n"
    "  - Windows 10 / 11 (64-bit)\r\n"
    "  - NVIDIA GPU with up-to-date drivers\r\n"
    "  - No Python installation needed\r\n"
    "  - No internet connection needed\r\n"
    "\r\n"
    "FIRST RUN\r\n"
    "  The model is already bundled - no download needed.\r\n"
    "  First classification may take a few seconds while the\r\n"
    "  model loads into GPU memory.\r\n"
)

for filename, content in [
    ("START.bat",         start_bat),
    ("START_HIDDEN.vbs",  start_vbs),
    ("README.txt",        readme),
]:
    path = os.path.join(portable_dir, filename)
    with open(path, "w", newline="") as f:
        f.write(content)
    print(f"  Created: {filename}")

print("Launcher files created.")
