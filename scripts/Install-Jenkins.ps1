# Jenkins Installation Script for Windows PowerShell
# Run this script as Administrator

param(
    [switch]$SkipChoco = $false,
    [string]$JenkinsPort = "8080"
)

# Color functions
function Write-Success { Write-Host "[✓] $args" -ForegroundColor Green }
function Write-Error { Write-Host "[✗] $args" -ForegroundColor Red }
function Write-Info { Write-Host "[ℹ] $args" -ForegroundColor Cyan }
function Write-Warning { Write-Host "[⚠] $args" -ForegroundColor Yellow }

# Check if running as Administrator
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -Match 'S-1-5-32-544')
if (-not $isAdmin) {
    Write-Error "This script must be run as Administrator!"
    Write-Info "Right-click PowerShell and select 'Run as Administrator'"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Jenkins Installation for ARC Drive" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check and Install Chocolatey
Write-Info "Step 1: Checking Chocolatey installation..."
$chocoPath = (Get-Command choco -ErrorAction SilentlyContinue).Source

if ($null -eq $chocoPath -and -not $SkipChoco) {
    Write-Info "Chocolatey not found. Installing..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Success "Chocolatey installed successfully"
} else {
    Write-Success "Chocolatey is already installed"
}
Write-Host ""

# Step 2: Install Java
Write-Info "Step 2: Checking Java installation..."
$javaVersion = (java -version 2>&1)
if ($LASTEXITCODE -eq 0) {
    Write-Success "Java is already installed"
    Write-Host $javaVersion -ForegroundColor Green
} else {
    Write-Info "Java not found. Installing OpenJDK 17..."
    choco install openjdk17 -y
    
    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    $javaVersion = (java -version 2>&1)
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Java installed successfully"
    } else {
        Write-Error "Failed to install Java"
        Write-Info "Please install Java manually from: https://www.oracle.com/java/technologies/downloads/"
        exit 1
    }
}
Write-Host ""

# Step 3: Install Jenkins
Write-Info "Step 3: Installing Jenkins..."
$jenkinsInstalled = choco list jenkins | Select-String "jenkins"

if ($null -eq $jenkinsInstalled) {
    Write-Info "Installing Jenkins..."
    choco install jenkins -y
    Write-Success "Jenkins installed successfully"
} else {
    Write-Success "Jenkins is already installed"
}
Write-Host ""

# Step 4: Start Jenkins Service
Write-Info "Step 4: Starting Jenkins service..."
try {
    Start-Service -Name Jenkins -ErrorAction Stop
    Write-Success "Jenkins service started"
} catch {
    Write-Warning "Jenkins service may already be running"
}
Write-Host ""

# Step 5: Wait for Jenkins to fully start
Write-Info "Step 5: Waiting for Jenkins to initialize (this takes about 30 seconds)..."
$maxWait = 0
$jenkinsReady = $false

while ($maxWait -lt 60) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$JenkinsPort" -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $jenkinsReady = $true
            break
        }
    } catch {
        # Jenkins not ready yet
    }
    
    Start-Sleep -Seconds 2
    $maxWait += 2
    Write-Host "." -NoNewline
}

Write-Host ""
if ($jenkinsReady) {
    Write-Success "Jenkins is ready!"
} else {
    Write-Warning "Jenkins may still be initializing. Please wait a moment."
}
Write-Host ""

# Step 6: Retrieve Initial Admin Password
Write-Info "Step 6: Retrieving initial admin password..."
$passwordFile = "C:\Program Files\Jenkins\secrets\initialAdminPassword"

if (Test-Path $passwordFile) {
    $password = Get-Content $passwordFile
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "JENKINS INITIAL ADMIN PASSWORD" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host $password -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Copy to clipboard
    $password | Set-Clipboard
    Write-Success "Password copied to clipboard"
    Write-Host ""
} else {
    Write-Error "Password file not found!"
    Write-Info "Please check Jenkins logs at: C:\Program Files\Jenkins\jenkins.log"
    Write-Host ""
}

# Step 7: Display next steps
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "JENKINS INSTALLATION COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "📍 Jenkins Dashboard:" -ForegroundColor Cyan
Write-Host "   ► http://localhost:$JenkinsPort" -ForegroundColor White
Write-Host ""

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Open http://localhost:$JenkinsPort in your browser" -ForegroundColor White
Write-Host "   2. Enter the password displayed above" -ForegroundColor White
Write-Host "   3. Click 'Continue'" -ForegroundColor White
Write-Host "   4. Select 'Install suggested plugins'" -ForegroundColor White
Write-Host "   5. Create your admin user account" -ForegroundColor White
Write-Host "      • Username: admin" -ForegroundColor Gray
Write-Host "      • Password: (your choice)" -ForegroundColor Gray
Write-Host "   6. Set Jenkins URL to http://localhost:$JenkinsPort/" -ForegroundColor White
Write-Host "   7. Click 'Start using Jenkins'" -ForegroundColor White
Write-Host "   8. Go to 'Manage Jenkins' → 'Manage Plugins'" -ForegroundColor White
Write-Host "   9. Install these plugins:" -ForegroundColor White
Write-Host "      • Pipeline" -ForegroundColor Gray
Write-Host "      • NodeJS Plugin" -ForegroundColor Gray
Write-Host "      • Git" -ForegroundColor Gray
Write-Host "      • GitHub Integration (optional)" -ForegroundColor Gray
Write-Host "      • Email Extension (optional)" -ForegroundColor Gray
Write-Host "      • Slack Notification (optional)" -ForegroundColor Gray
Write-Host ""

Write-Host "📂 Jenkins Installation Path:" -ForegroundColor Cyan
Write-Host "   ► C:\Program Files\Jenkins" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Service Management:" -ForegroundColor Cyan
Write-Host "   Get Status:    Get-Service Jenkins" -ForegroundColor Gray
Write-Host "   Start:         Start-Service Jenkins" -ForegroundColor Gray
Write-Host "   Stop:          Stop-Service Jenkins" -ForegroundColor Gray
Write-Host "   Restart:       Restart-Service Jenkins" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 View Logs:" -ForegroundColor Cyan
Write-Host "   Get-Content 'C:\Program Files\Jenkins\jenkins.log' -Tail 50" -ForegroundColor Gray
Write-Host ""

Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "   ► See JENKINS_INSTALLATION_GUIDE.md in your ARC-Drive folder" -ForegroundColor White
Write-Host "   ► See JENKINS_SETUP.md for detailed configuration" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Info "Follow the setup wizard in your browser at http://localhost:$JenkinsPort"
Write-Info "Then configure your ARC-Drive pipeline job following the JENKINS_SETUP.md guide"
Write-Success "Installation script complete! 🚀"
