@echo off
setlocal enabledelayedexpansion

REM ARC Drive CI/CD Build & Deployment Script for Windows
REM This script is used by Jenkins to build and deploy the application

echo.
echo ================================
echo ARC Drive CI/CD Pipeline
echo ================================
echo.

REM Configuration
set APP_NAME=ARC Drive
set BUILD_DIR=dist
set APP_PORT=4173
set LOG_FILE=deployment.log

REM Step 1: Check Node.js and npm
echo [INFO] Checking Node.js and npm installation...
where node >nul 2>nul
if !errorlevel! neq 0 (
    echo [ERROR] Node.js is not installed
    exit /b 1
)
where npm >nul 2>nul
if !errorlevel! neq 0 (
    echo [ERROR] npm is not installed
    exit /b 1
)
for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
for /f "tokens=*" %%i in ('npm -v') do set NPM_VERSION=%%i
echo [INFO] Node.js %NODE_VERSION% found
echo [INFO] npm %NPM_VERSION% found
echo.

REM Step 2: Install dependencies
echo [INFO] Installing dependencies...
call npm install
if !errorlevel! neq 0 (
    echo [ERROR] Failed to install dependencies
    exit /b 1
)
echo [INFO] ✓ Dependencies installed
echo.

REM Step 3: Build application
echo [INFO] Building application...
call npm run build
if !errorlevel! neq 0 (
    echo [ERROR] Build failed
    exit /b 1
)
echo [INFO] ✓ Application built successfully
echo.

REM Step 4: Verify build artifacts
echo [INFO] Verifying build artifacts...
if exist "%BUILD_DIR%" (
    for /f %%A in ('dir /b %BUILD_DIR% ^| find /c /v ""') do set FILE_COUNT=%%A
    echo [INFO] ✓ Build directory exists: %BUILD_DIR% with %FILE_COUNT% items
) else (
    echo [ERROR] Build directory not found: %BUILD_DIR%
    exit /b 1
)
echo.

REM Step 5: Stop previous server
echo [INFO] Stopping previous preview server...
taskkill /F /IM node.exe /T 2>nul || echo [INFO] No previous server running
timeout /t 2 /nobreak >nul
echo [INFO] ✓ Previous server stopped
echo.

REM Step 6: Start preview server
echo [INFO] Starting preview server on port %APP_PORT%...
start /b cmd /c npm run preview
timeout /t 3 /nobreak >nul
echo [INFO] ✓ Preview server started
echo.

REM Final summary
echo.
echo ================================
echo Deployment Summary
echo ================================
echo [INFO] Application: %APP_NAME%
echo [INFO] Build Directory: %BUILD_DIR%
echo [INFO] Server URL: http://localhost:%APP_PORT%/app.html
echo [INFO] Log File: %LOG_FILE%
echo.
echo [INFO] ✓ CI/CD Pipeline completed successfully!
echo ================================
echo.

exit /b 0
