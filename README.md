# 🖼️ CLIP Image Classifier - WebUI

A powerful, user-friendly web application for zero-shot image classification using OpenAI's CLIP model. Classify images with custom labels without any training!

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Python](https://img.shields.io/badge/python-3.8+-green)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- 🎯 **Zero-Shot Classification** - Classify images with any labels without training
- 🖥️ **Modern WebUI** - Intuitive drag-and-drop interface
- 📊 **Multiple Export Formats** - JSON, CSV, Excel, PDF
- ⚡ **Fast & Lightweight** (Dev Mode) - Runs on CPU with small model
- 🏆 **High Accuracy** (Production Mode) - Uses largest CLIP model with GPU support
- 📸 **All Image Formats** - JPG, PNG, WEBP, BMP, GIF, TIFF, and more
- 🔄 **Batch Processing** - Classify multiple images at once
- 💾 **Results Grouping** - Automatically groups results by category
- 🎨 **Beautiful Design** - Modern gradient UI with responsive layout

---

## 🚀 Quick Start

### Prerequisites

- Python 3.8 or higher
- pip package manager

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/mahmoudhusam/clip-classifier.git
   cd clip-classifier
   ```

2. **Create virtual environment**

   ```bash
   python -m venv venv

   # On Linux/Mac:
   source venv/bin/activate

   # On Windows:
   venv\Scripts\activate.bat
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

### Running the Application

#### Option 1: Automatic Startup (Recommended)

**Linux/Mac:**

```bash
chmod +x run.sh
./run.sh
```

**Windows:**

```bash
run.bat
```

This will:

- Start the FastAPI backend server
- Automatically open the WebUI in your default browser
- Run on `http://localhost:8000`

#### Option 2: Manual Startup

**Terminal 1 - Start Backend:**

```bash
python -m uvicorn backend.app:app --reload --host 127.0.0.1 --port 8000
```

**Terminal 2 - Open Frontend:**

```bash
# Open frontend/index.html in your browser
# Or use a local server:
python -m http.server 8001 --directory frontend
# Then visit: http://localhost:8001
```

---

## 📖 Usage Guide

### 1. Upload Images

- **Drag and drop** images into the upload zone, or
- **Click** the zone to browse files
- Supported formats: JPG, PNG, WEBP, BMP, GIF, TIFF, ICO, PPM

### 2. Set Classification Labels

- Enter labels to classify images against
- **Example:** "person", "car", "nature", "food"
- Use **Presets** for quick setup (General, Objects, Scenes, Emotions)
- Minimum 2 labels required

### 3. Configure Options

- **Confidence Threshold**: Filter results by confidence level (0-100%)
- **Export Format**: Choose output format (JSON, CSV, Excel, PDF)

### 4. Classify

- Click **Classify Images** button
- Watch real-time progress
- Results display automatically when complete

### 5. View & Export Results

- Results grouped by category
- See confidence scores for each classification
- Download in your preferred format
- Copy results to clipboard

---

## 🔧 Configuration

### Environment Setup

Edit `config.json` to customize:

```json
{
  "dev": {
    "name": "Development",
    "model": "openai/clip-vit-base-patch32",
    "batch_size": 4,
    "device": "cpu"
  },
  "production": {
    "name": "Production",
    "model": "openai/clip-vit-large-patch14",
    "batch_size": 32,
    "device": "cuda"
  }
}
```

**Development Mode** (Default):

- ✅ Small model (~350MB)
- ✅ CPU-friendly
- ✅ Fast processing
- ⚠️ Lower accuracy

**Production Mode**:

- ⚠️ Large model (~890MB)
- ⚠️ Requires GPU (CUDA)
- ⏱️ Slower but more accurate
- ✅ Best accuracy

### Switch Environment at Runtime

Use the **Settings** button in the WebUI or set environment variable:

```bash
CLIP_ENV=production python -m uvicorn backend.app:app --reload
```

---

## 🎓 Model Information

### CLIP Models Available

| Model                      | Size  | Speed   | Accuracy | Use Case         |
| -------------------------- | ----- | ------- | -------- | ---------------- |
| **clip-vit-base-patch32**  | 350MB | ⚡ Fast | Good     | Default, testing |
| **clip-vit-base-patch16**  | 350MB | Medium  | Better   | Balanced         |
| **clip-vit-large-patch14** | 890MB | Slow    | 🏆 Best  | Production       |

### How CLIP Works

- Uses vision-language alignment from 400M image-text pairs
- Can classify images with ANY text labels
- No fine-tuning required
- Multi-lingual label support

---

## 📊 Output Formats

### JSON Format (Default)

```json
{
  "filename": "photo.jpg",
  "top_label": "person",
  "top_score": 89.5,
  "scores": [
    { "label": "person", "score": 89.5 },
    { "label": "car", "score": 8.2 },
    { "label": "nature", "score": 2.3 }
  ]
}
```

### CSV Format

Spreadsheet-friendly with all label scores as columns

### Excel Format (.xlsx)

- Summary sheet with category counts
- Details sheet with all scores
- Professionally formatted

### PDF Format

- Visual report with metadata
- Category breakdown
- Confidence summary

---

## 🛠️ Project Structure

```
clip-classifier/
├── backend/                    # FastAPI backend
│   ├── app.py                 # Main API server
│   ├── config.py              # Configuration loader
│   ├── models/
│   │   ├── classifier.py      # CLIP wrapper
│   │   └── image_processor.py # Image handling
│   └── utils/
│       └── exporters.py       # Export formats
├── frontend/                   # WebUI
│   ├── index.html             # Main HTML
│   ├── styles.css             # Styling
│   ├── script.js              # JavaScript
│   └── assets/                # Images/fonts
├── config.json                # Configuration
├── requirements.txt           # Dependencies
├── run.sh                      # Linux/Mac startup
├── run.bat                     # Windows startup
└── README.md
```

---

## 🔌 API Endpoints

### Health Check

```
GET /health
```

### Server Info

```
GET /info
Returns: Model, device, supported formats, default labels
```

### Classify Images

```
POST /classify
Parameters:
  - files: Image files
  - labels: Comma-separated labels
  - model: (Optional) Model override
  - export_format: json|csv|excel|pdf
```

### Switch Environment

```
POST /config/env?env=dev|production
```

### API Documentation

Visit `http://localhost:8000/docs` for interactive API docs (Swagger UI)

---

## ⚙️ Requirements

### Python Packages

- `fastapi>=0.104.0` - Web framework
- `uvicorn[standard]>=0.24.0` - ASGI server
- `transformers>=4.30.0` - HuggingFace models
- `torch` - PyTorch (CPU or CUDA)
- `torchvision` - Vision utilities
- `Pillow>=10.0.0` - Image processing
- `openpyxl>=3.1.0` - Excel export
- `reportlab>=4.0.0` - PDF export
- `pandas>=2.0.0` - Data processing

### System Requirements

**Minimum (Development Mode)**:

- 4GB RAM
- 2GB free disk space for model cache
- Any processor (CPU-only)
- Linux/Mac/Windows

**Recommended (Production Mode)**:

- 16GB RAM
- 4GB free disk space
- NVIDIA GPU (8GB+ VRAM)
- CUDA 11.8+
- Linux/Windows

---

## 🐛 Troubleshooting

### Issue: "Server connection failed"

**Solution**: Make sure backend is running on port 8000

```bash
python -m uvicorn backend.app:app --reload
```

### Issue: "CUDA out of memory"

**Solution**: Switch to development mode (uses CPU)

```bash
CLIP_ENV=dev python -m uvicorn backend.app:app --reload
```

### Issue: "Model download fails"

**Solution**: Set HuggingFace cache directory

```bash
export HF_HOME=/path/to/cache
```

### Issue: "Images not uploading"

**Solution**: Check file formats - must be valid image files

---

## 🤝 Contributing

Pull requests welcome! Please feel free to submit issues and enhancements.

---

## 📄 License

MIT License - feel free to use this in personal and commercial projects

---

## 👨‍💻 Developer

Created by [Mahmoud Ayesh](https://github.com/mahmoudhusam)

---

## 🙏 Acknowledgments

- OpenAI for CLIP model
- HuggingFace for transformers library
- FastAPI team for the excellent web framework

---

## 📮 Support

For issues, questions, or suggestions:

- GitHub Issues: [Create an issue](https://github.com/mahmoudhusam/clip-classifier/issues)
- Email: mahayesh7@gmail.com

---

**Happy Classifying! 🎉**
