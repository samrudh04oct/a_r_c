@echo off
REM Jenkins Quick Install & Setup Script for Windows
REM Run as Administrator

setlocal enabledelayedexpansion

echo.
echo ========================================
echo Jenkins Quick Installation Script
echo ========================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] This script must be run as Administrator!
    echo Right-click the PowerShell/CMD and select "Run as Administrator"
    pause
    exit /b 1
)

echo [INFO] Checking system requirements...
echo.

REM Step 1: Check if Java is installed
echo [STEP 1] Checking Java installation...
java -version >nul 2>&1
if !errorlevel! neq 0 (
    echo [INFO] Java not found. Installing...
    REM Check if Chocolatey is installed
    choco -v >nul 2>&1
    if !errorlevel! neq 0 (
        echo [INFO] Chocolatey not found. Installing Chocolatey first...
        powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; iwr -useb https://community.chocolatey.org/install.ps1 | iex"
    )
    choco install openjdk17 -y
    echo [INFO] Java installed successfully
) else (
    echo [OK] Java is already installed
    java -version
)
echo.

REM Step 2: Install Jenkins
echo [STEP 2] Installing Jenkins...
choco list jenkins >nul 2>&1
if !errorlevel! neq 0 (
    choco install jenkins -y
    echo [INFO] Jenkins installed successfully
) else (
    echo [OK] Jenkins is already installed
)
echo.

REM Step 3: Start Jenkins Service
echo [STEP 3] Starting Jenkins service...
Start-Service Jenkins 2>nul
timeout /t 5 /nobreak

REM Step 4: Wait for Jenkins to be ready
echo [STEP 4] Waiting for Jenkins to start...
echo [INFO] This may take a minute...
timeout /t 30 /nobreak

REM Step 5: Get initial admin password
echo.
echo [STEP 5] Retrieving initial admin password...
set PASSWORD_FILE=C:\Program Files\Jenkins\secrets\initialAdminPassword
if exist "!PASSWORD_FILE!" (
    echo.
    echo ========================================
    echo JENKINS INITIAL ADMIN PASSWORD
    echo ========================================
    type "!PASSWORD_FILE!"
    echo.
    echo [INFO] Password copied to clipboard (Windows only)
    powershell -Command "Get-Content '!PASSWORD_FILE!' | Set-Clipboard"
) else (
    echo [ERROR] Password file not found
    echo [INFO] Check Jenkins logs at: C:\Program Files\Jenkins\jenkins.log
)
echo.

REM Step 6: Display access information
echo ========================================
echo JENKINS INSTALLATION COMPLETE!
echo ========================================
echo.
echo [INFO] Jenkins Web Interface:
echo        ► http://localhost:8080
echo.
echo [INFO] Next Steps:
echo        1. Open http://localhost:8080 in your browser
echo        2. Paste the password above (or copy from clipboard)
echo        3. Click "Continue"
echo        4. Select "Install suggested plugins"
echo        5. Create your admin user
echo        6. Set Jenkins URL to http://localhost:8080/
echo        7. Start using Jenkins!
echo.
echo [INFO] Service Location:
echo        ► C:\Program Files\Jenkins
echo.
echo [INFO] Monitor Jenkins:
echo.
echo        Service Status:   Get-Service Jenkins
echo        Start Service:    Start-Service Jenkins
echo        Stop Service:     Stop-Service Jenkins
echo        Restart Service:  Restart-Service Jenkins
echo.
echo [INFO] View Logs:
echo        ► Get-Content "C:\Program Files\Jenkins\jenkins.log" -Tail 50
echo.
echo ========================================
echo.
pause
