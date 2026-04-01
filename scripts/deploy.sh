#!/bin/bash

# ARC Drive CI/CD Build & Deployment Script
# This script is used by Jenkins to build and deploy the application

set -e  # Exit on error

echo "================================"
echo "ARC Drive CI/CD Pipeline"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="ARC Drive"
BUILD_DIR="dist"
APP_PORT="4173"
LOG_FILE="deployment.log"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a $LOG_FILE
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a $LOG_FILE
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a $LOG_FILE
}

# Step 1: Check Node.js and npm
log_info "Checking Node.js and npm installation..."
if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed"
    exit 1
fi
if ! command -v npm &> /dev/null; then
    log_error "npm is not installed"
    exit 1
fi
log_info "✓ Node.js $(node -v) found"
log_info "✓ npm $(npm -v) found"
echo ""

# Step 2: Install dependencies
log_info "Installing dependencies..."
npm install >> $LOG_FILE 2>&1
log_info "✓ Dependencies installed"
echo ""

# Step 3: Build application
log_info "Building application..."
npm run build >> $LOG_FILE 2>&1
log_info "✓ Application built successfully"
echo ""

# Step 4: Verify build artifacts
log_info "Verifying build artifacts..."
if [ -d "$BUILD_DIR" ]; then
    BUILD_SIZE=$(du -sh "$BUILD_DIR" | cut -f1)
    FILE_COUNT=$(find "$BUILD_DIR" -type f | wc -l)
    log_info "✓ Build directory: $BUILD_DIR ($BUILD_SIZE, $FILE_COUNT files)"
else
    log_error "Build directory not found: $BUILD_DIR"
    exit 1
fi
echo ""

# Step 5: Stop previous server (if running)
log_info "Stopping previous preview server..."
pkill -f "npm run preview" || true
sleep 2
log_info "✓ Previous server stopped"
echo ""

# Step 6: Start preview server
log_info "Starting preview server on port $APP_PORT..."
npm run preview > /tmp/arc-drive-preview.log 2>&1 &
PREVIEW_PID=$!
sleep 3
log_info "✓ Preview server started (PID: $PREVIEW_PID)"
echo ""

# Step 7: Health check
log_info "Running health check..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$APP_PORT/app.html || echo "000")
if [ "$HTTP_STATUS" = "200" ]; then
    log_info "✓ Server is responding correctly (HTTP $HTTP_STATUS)"
else
    log_warn "Server health check returned HTTP $HTTP_STATUS"
fi
echo ""

# Final summary
echo "================================"
echo "Deployment Summary"
echo "================================"
log_info "Application: $APP_NAME"
log_info "Build Directory: $BUILD_DIR"
log_info "Server URL: http://localhost:$APP_PORT/app.html"
log_info "Server PID: $PREVIEW_PID"
log_info "Log File: $LOG_FILE"
echo ""
log_info "✓ CI/CD Pipeline completed successfully!"
echo "================================"
