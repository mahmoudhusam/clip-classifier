"""
FastAPI backend server for CLIP Image Classifier
Provides REST API for image classification
"""

from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
import io
import os
from pathlib import Path

from backend.config import get_config, set_config
from backend.models.classifier import CLIPClassifier
from backend.models.image_processor import ImageProcessor
from backend.utils.exporters import ResultExporter


# ── Initialize FastAPI App ───────────────────────────────────────────────
app = FastAPI(
    title="CLIP Image Classifier",
    description="Zero-shot image classification using OpenAI's CLIP model",
    version="1.0.0"
)

# ── CORS Middleware (allow WebUI requests) ───────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Global classifier instance ───────────────────────────────────────────
_classifier = None


def get_classifier():
    """Get or create classifier instance"""
    global _classifier
    if _classifier is None:
        _classifier = CLIPClassifier()
    return _classifier


# ──────────────────────────────────────────────────────────────────────────
# HEALTH & STATUS ENDPOINTS
# ──────────────────────────────────────────────────────────────────────────

@app.get("/")
async def root():
    """Root endpoint - API info"""
    return {
        "name": "CLIP Image Classifier API",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "config": "/config",
            "classify": "/classify",
            "info": "/info"
        }
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}


@app.get("/info")
async def info():
    """Get classifier information"""
    config = get_config()
    classifier = get_classifier()
    
    return {
        "environment": config.env_name,
        "model": config.model_name,
        "device": config.device,
        "batch_size": config.batch_size,
        "supported_formats": ImageProcessor.get_supported_extensions(),
        "export_formats": config.export_formats,
        "default_labels": config.default_labels,
    }


# ──────────────────────────────────────────────────────────────────────────
# CONFIGURATION ENDPOINTS
# ──────────────────────────────────────────────────────────────────────────

@app.get("/config")
async def get_current_config():
    """Get current configuration"""
    config = get_config()
    return {
        "environment": config.env,
        "model": config.model_name,
        "device": config.device,
        "batch_size": config.batch_size,
        "max_images": config.max_images,
    }


@app.post("/config/env")
async def set_environment(env: str):
    """
    Switch environment (dev or production)
    
    Args:
        env: Environment name ('dev' or 'production')
    """
    try:
        config = set_config(env)
        return {
            "message": f"Switched to {env}",
            "environment": config.env_name,
            "model": config.model_name,
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ──────────────────────────────────────────────────────────────────────────
# CLASSIFICATION ENDPOINTS
# ──────────────────────────────────────────────────────────────────────────

@app.post("/classify")
async def classify_images(
    files: List[UploadFile] = File(...),
    labels: str = Form(...),
    model: Optional[str] = Form(None),
    export_format: str = Form("json")
):
    """
    Classify images
    
    Args:
        files: Image files to classify
        labels: Comma-separated classification labels (e.g., "person,car,nature")
        model: Optional model override
        export_format: Output format (json, csv, excel, pdf)
        
    Returns:
        Classification results in specified format
    """
    try:
        config = get_config()
        
        # Validate inputs
        if not files:
            raise HTTPException(status_code=400, detail="No files provided")
        
        if len(files) > config.max_images:
            raise HTTPException(
                status_code=400,
                detail=f"Too many images. Max: {config.max_images}"
            )
        
        # Parse labels
        label_list = [l.strip() for l in labels.split(",") if l.strip()]
        if len(label_list) < 2:
            raise HTTPException(
                status_code=400,
                detail="At least 2 labels required"
            )
        
        # Load images from upload
        images = []
        filenames = []
        
        for file in files:
            try:
                contents = await file.read()
                img, filename = ImageProcessor.load_from_bytes(contents, file.filename)
                images.append(img)
                filenames.append(filename)
            except ValueError as e:
                raise HTTPException(status_code=400, detail=str(e))
        
        if not images:
            raise HTTPException(status_code=400, detail="No valid images loaded")
        
        # Classify
        classifier = get_classifier()
        if model:
            classifier.load_model(model)
        else:
            classifier.load_model()
        
        print(f"\n🔍 Classifying {len(images)} images with labels: {label_list}")
        results = classifier.classify(images, label_list)
        
        # Export results
        exporter = ResultExporter(results, label_list, filenames)
        
        if export_format == "json":
            return JSONResponse(
                content=exporter.enriched_results,
                media_type="application/json"
            )
        
        elif export_format == "csv":
            return FileResponse(
                io.BytesIO(exporter.to_csv().encode()),
                media_type="text/csv",
                filename="results.csv"
            )
        
        elif export_format == "excel":
            return FileResponse(
                io.BytesIO(exporter.to_excel()),
                media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                filename="results.xlsx"
            )
        
        elif export_format == "pdf":
            return FileResponse(
                io.BytesIO(exporter.to_pdf()),
                media_type="application/pdf",
                filename="results.pdf"
            )
        
        else:
            raise HTTPException(status_code=400, detail=f"Unknown format: {export_format}")
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/classify-folder")
async def classify_folder(
    folder_path: str = Form(...),
    labels: str = Form(...),
    model: Optional[str] = Form(None),
    export_format: str = Form("json")
):
    """
    Classify all images in a folder
    
    Args:
        folder_path: Path to folder containing images
        labels: Comma-separated classification labels
        model: Optional model override
        export_format: Output format
        
    Returns:
        Classification results in specified format
    """
    try:
        config = get_config()
        
        # Load images from folder
        try:
            images = ImageProcessor.load_from_folder(
                folder_path,
                max_images=config.max_images
            )
            if not images:
                raise HTTPException(status_code=400, detail="No images found in folder")
            
            imgs, filenames = zip(*images)
            imgs = list(imgs)
            filenames = list(filenames)
        
        except (FileNotFoundError, ValueError) as e:
            raise HTTPException(status_code=400, detail=str(e))
        
        # Parse labels
        label_list = [l.strip() for l in labels.split(",") if l.strip()]
        if len(label_list) < 2:
            raise HTTPException(status_code=400, detail="At least 2 labels required")
        
        # Classify
        classifier = get_classifier()
        if model:
            classifier.load_model(model)
        else:
            classifier.load_model()
        
        print(f"\n🔍 Classifying {len(imgs)} images from folder")
        results = classifier.classify(imgs, label_list)
        
        # Export
        exporter = ResultExporter(results, label_list, filenames)
        
        if export_format == "json":
            return exporter.enriched_results
        elif export_format == "csv":
            return FileResponse(
                io.BytesIO(exporter.to_csv().encode()),
                media_type="text/csv",
                filename="results.csv"
            )
        elif export_format == "excel":
            return FileResponse(
                io.BytesIO(exporter.to_excel()),
                media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                filename="results.xlsx"
            )
        elif export_format == "pdf":
            return FileResponse(
                io.BytesIO(exporter.to_pdf()),
                media_type="application/pdf",
                filename="results.pdf"
            )
        else:
            raise HTTPException(status_code=400, detail=f"Unknown format: {export_format}")
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ──────────────────────────────────────────────────────────────────────────
# CLEANUP
# ──────────────────────────────────────────────────────────────────────────

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    global _classifier
    if _classifier:
        _classifier.unload_model()


if __name__ == "__main__":
    import uvicorn
    
    config = get_config()
    print(f"\n🚀 Starting CLIP Classifier API")
    print(f"   Environment: {config.env_name}")
    print(f"   Model: {config.model_name}")
    print(f"   http://localhost:8000\n")
    
    uvicorn.run(app, host="127.0.0.1", port=8000)
