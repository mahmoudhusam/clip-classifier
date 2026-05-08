#!/usr/bin/env python3
"""
CLIP Classifier - Main Entry Point for Packaged Application
Runs the application in production mode for Windows
"""

import os
import sys
import webbrowser
import time
import signal
from pathlib import Path

# Set production environment
os.environ['CLIP_ENV'] = 'production'

# Ensure the backend module is importable
sys.path.insert(0, str(Path(__file__).parent))

import uvicorn
from backend.app import app


    def run_server():
    """Start the FastAPI server"""
    print("\n" + "="*60)
    print("  🖼️  CLIP Image Classifier - Production")
    print("="*60 + "\n")
    
    print("Loading CLIP model (lightweight model for CPU)...")
    print("This may take 30-60 seconds on first run...\n")
    
    # Run the server
    uvicorn.run(
        app,
        host="127.0.0.1",
        port=5000,
        log_level="info"
    )


if __name__ == "__main__":
    try:
        # Print startup info
        print("✓ Environment: Production")
        print("✓ Model: openai/clip-vit-base-patch32 (Fast & Lightweight)")
        print("✓ Device: CPU")
        print("✓ Batch Size: 4")
        print("✓ Starting server on http://127.0.0.1:5000\n")
        
        # Start the server
        run_server()
    except KeyboardInterrupt:
        print("\n\nShutting down...")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        sys.exit(1)
