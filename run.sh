#!/bin/bash

# CLIP Classifier Startup Script
# Starts the FastAPI backend and opens the WebUI

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}     🖼️  CLIP Image Classifier - WebUI${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}\n"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Virtual environment not found. Creating...${NC}"
    python3 -m venv venv
fi

# Activate virtual environment
echo -e "${BLUE}Activating virtual environment...${NC}"
source venv/bin/activate

# Install/update dependencies if needed
echo -e "${BLUE}Checking dependencies...${NC}"
pip install -q -r requirements.txt 2>/dev/null || pip install -q fastapi uvicorn openpyxl reportlab python-multipart

echo -e "${GREEN}✓ Environment ready${NC}\n"

# Determine environment
ENV=${CLIP_ENV:-dev}
echo -e "${BLUE}Environment: ${YELLOW}${ENV}${NC}"
echo ""

# Start backend
echo -e "${BLUE}Starting FastAPI backend...${NC}"
echo -e "${YELLOW}→ http://localhost:8000${NC}\n"

# Start the server in the background
python -m uvicorn backend.app:app --reload --host 127.0.0.1 --port 5000 &
BACKEND_PID=$!

# Wait for server to start
sleep 3

# Check if server started successfully
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}✗ Failed to start backend${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Backend running (PID: $BACKEND_PID)${NC}\n"

# Open WebUI in browser
echo -e "${BLUE}Opening WebUI in browser...${NC}"
sleep 1

if command -v xdg-open &> /dev/null; then
    xdg-open "file://${SCRIPT_DIR}/frontend/index.html" || true
elif command -v open &> /dev/null; then
    open "file://${SCRIPT_DIR}/frontend/index.html" || true
elif command -v firefox &> /dev/null; then
    firefox "file://${SCRIPT_DIR}/frontend/index.html" &
fi

echo -e "${GREEN}✓ WebUI opening...${NC}"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 CLIP Classifier is running!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}\n"
echo -e "📖 API Documentation: ${YELLOW}http://localhost:8000/docs${NC}"
echo -e "💻 WebUI: ${YELLOW}file://${SCRIPT_DIR}/frontend/index.html${NC}\n"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}\n"

# Keep the script running
wait $BACKEND_PID
