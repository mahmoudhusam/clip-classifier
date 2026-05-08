# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller spec file for CLIP Image Classifier
Bundles the FastAPI backend + HTML frontend into a Windows executable
"""

import os
from pathlib import Path

# Get the absolute path to the project root
project_root = Path(__file__).parent.absolute()

# Collect frontend assets
frontend_path = project_root / 'frontend'

a = Analysis(
    [str(project_root / 'main.py')],
    pathex=[str(project_root)],
    binaries=[],
    datas=[
        (str(frontend_path / 'index.html'), 'frontend'),
        (str(frontend_path / 'script.js'), 'frontend'),
        (str(project_root / 'config.json'), '.'),
    ],
    hiddenimports=[
        'fastapi',
        'uvicorn',
        'transformers',
        'torch',
        'torchvision',
        'PIL',
        'numpy',
        'pandas',
        'openpyxl',
        'reportlab',
        'pydantic',
        'starlette',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludedimports=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=None,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=None)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='CLIP_Classifier',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)
