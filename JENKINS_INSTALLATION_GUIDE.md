# 🚀 Jenkins Setup Guide for ARC Drive - Complete Installation

## Prerequisites

Before installing Jenkins, ensure you have:
- ✅ Windows 10/11 or Windows Server 2016+
- ✅ Administrator access
- ✅ 2GB RAM minimum (4GB recommended)
- ✅ 10GB disk space
- ✅ Java 11 or higher

## Step 1: Install Java JDK

Jenkins requires Java. Download and install:

### Option A: Using Chocolatey (Recommended for Windows)

```powershell
# Open PowerShell as Administrator
# Install Chocolatey if not already installed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iwr -useb https://community.chocolatey.org/install.ps1 | iex

# Install Java 17 (LTS)
choco install openjdk17 -y

# Verify installation
java -version
```

### Option B: Manual Download

1. Go to https://www.oracle.com/java/technologies/downloads/
2. Download **Java 17 LTS**
3. Run the installer and follow the wizard
4. Add to PATH:
   - Open `Environment Variables`
   - Add Java bin folder to PATH
   - Example: `C:\Program Files\Java\jdk-17.0.2\bin`

### Option C: Microsoft OpenJDK

```powershell
choco install microsoft-openjdk17 -y
```

---

## Step 2: Install Jenkins

### Option A: Using Chocolatey (Easiest)

```powershell
# Open PowerShell as Administrator
choco install jenkins -y

# Start Jenkins service
Start-Service Jenkins

# Verify it's running
Get-Service Jenkins
```

### Option B: Using Windows Installer

1. Download Jenkins from https://www.jenkins.io/download/
2. Click "Windows" tab
3. Download **Windows installer (.msi)**
4. Run the installer
5. Follow the wizard:
   - Install directory: `C:\Program Files\Jenkins` (default)
   - Run service as: Local System
   - TCP Port: `8080` (keep default)
6. Complete installation and restart

### Option C: Manual Download (Advanced)

```powershell
# Download Jenkins WAR file
$url = "https://get.jenkins.io/windows-stable/jenkins.msi"
$output = "C:\Temp\jenkins.msi"
(New-Object Net.WebClient).DownloadFile($url, $output)

# Run installer
msiexec.exe /i $output

# Start service
Start-Service Jenkins
```

---

## Step 3: Initial Jenkins Setup (First Run)

### 1. Access Jenkins Web Interface

Open your browser and go to:
```
http://localhost:8080
```

### 2. Unlock Jenkins

Jenkins will prompt for an initial admin password:

```powershell
# Find the password
Get-Content "C:\Program Files\Jenkins\secrets\initialAdminPassword"

# Or search for it in the Jenkins logs
Get-Content "C:\Program Files\Jenkins\jenkins.log" | Select-String "Initial Admin Password" -Context 0, 2
```

**Copy the password and paste it into the Jenkins web interface.**

### 3. Install Suggested Plugins

Jenkins will ask: **"Install suggested plugins"** or **"Select plugins to install"**

Choose: **"Install suggested plugins"**

This installs essential plugins like Git, Pipeline, and more.

### 4. Create First Admin User

Fill in the form:
- **Username**: `admin` (or your preference)
- **Password**: (choose a strong password)
- **Confirm password**:
- **Full name**: `Jenkins Administrator`
- **Email address**: `admin@arc-drive.local`

Click **Save and Continue**

### 5. Configure Jenkins URL

- **Jenkins URL**: `http://localhost:8080/`
- Click **Save and Finish**

### 6. Start Using Jenkins

You'll see the Jenkins dashboard. You're now ready to configure!

---

## Step 4: Install Required Plugins for ARC Drive

1. Go to **Manage Jenkins** (left sidebar)
2. Click **Manage Plugins**
3. Go to **Available** tab
4. Search and install these plugins:

### Essential Plugins

```
✓ Pipeline
✓ Pipeline: Stage View
✓ Git
✓ GitHub Integration (if using GitHub)
✓ NodeJS Plugin
```

### Optional but Recommended

```
✓ Email Extension Plugin
✓ Slack Notification Plugin
✓ AnsiColor (for colored console output)
✓ Blue Ocean (better UI)
✓ Log Parser Plugin
```

**Install Instructions:**

1. Check the checkbox next to each plugin
2. Click **Download now and install after restart**
3. Check: **Restart Jenkins when installation is complete and no jobs are running**
4. Jenkins will restart automatically

---

## Step 5: Configure Node.js in Jenkins

### After plugins install and Jenkins restarts:

1. Go to **Manage Jenkins**
2. Click **Global Tool Configuration**
3. Scroll to **NodeJS**
4. Click **Add NodeJS**

Configure:
- **Name**: `nodejs18` (or your preference)
- **Version**: Select **18.x LTS** from dropdown
- **Global npm packages to install**: Leave empty
- **Install automatically**: Keep checked

5. Click **Apply** and **Save**

---

## Step 6: Create Jenkins Pipeline Job for ARC Drive

### 1. Create New Job

1. Click **New Item** on dashboard
2. Enter name: `ARC-Drive-Deploy`
3. Select **Pipeline**
4. Click **OK**

### 2. Configure General Settings

Under **General** section:
- **Description**: `ARC Drive - Automated Build & Deployment`
- Check: **This project is parameterized**

### 3. Add Build Parameter

Click **Add Parameter** → **Choice Parameter**

Configure:
- **Name**: `ENVIRONMENT`
- **Choices**: 
  ```
  local
  staging
  production
  ```
- **Description**: `Select deployment environment`

### 4. Configure Pipeline Script

Scroll to **Pipeline** section

Choose: **Pipeline script from SCM**

Configure:
- **SCM**: Select **Git**
- **Repository URL**: 
  ```
  https://github.com/your-username/ARC-Drive.git
  ```
  (Replace with your actual repo URL)
- **Credentials**: 
  - Click **Add** → **Jenkins**
  - **Kind**: Username with password
  - **Username**: Your GitHub username
  - **Password**: Your GitHub Personal Access Token
  - Click **Add**
  - Select the newly created credentials
- **Branch**: `*/main` (or your default branch)
- **Script Path**: `Jenkinsfile`

### 5. Build Triggers (Optional)

Check one of these to auto-trigger builds:

**Option A: Poll SCM**
```
H/15 * * * *    # Every 15 minutes
```

**Option B: GitHub Webhook**
- Check: **GitHub hook trigger for GITScm polling**
- (Requires GitHub webhook setup)

### 6. Save Job

Click **Save**

---

## Step 7: Test the Pipeline Manually

### 1. Trigger First Build

Go to your job page and click **Build with Parameters**

Select:
- **ENVIRONMENT**: `local`

Click **Build**

### 2. Monitor Progress

Click on the build number (e.g., `#1`)

Click **Console Output** to watch the build in real-time

### Expected Output

```
===== Checking out code from Git =====
Cloning into '/var/lib/jenkins/workspace/ARC-Drive-Deploy'...

===== Installing Node dependencies =====
npm WARN ...
added X packages

===== Building React application =====
> arc-drive-react@0.0.0 build
> vite build

vite v8.0.3 building client environment for production...
✓ 1471 modules transformed.
✓ built in 2.50s

===== Deploying to localhost:4173 =====
✓ Preview server started on http://localhost:4173/

✓ Pipeline executed successfully!
```

### 3. Verify Application

Open browser:
```
http://localhost:4173/app.html
```

You should see your ARC Drive application!

---

## Step 8: Configure GitHub Webhook (Optional - for Auto-Deploy)

### If using GitHub:

1. Go to your GitHub repository
2. **Settings** → **Webhooks** → **Add webhook**
3. Configure:
   - **Payload URL**: 
     ```
     http://your-machine-ip:8080/github-webhook/
     ```
     (Replace `your-machine-ip` with your actual IP or domain)
   
   - **Content type**: `application/json`
   - **Which events...**: Select **Push events**
   - **Active**: Check
4. Click **Add webhook**

Now every time you push code to GitHub, Jenkins will automatically build and deploy!

---

## Step 9: Configure Email Notifications (Optional)

### Setup Email for Build Notifications

1. Go to **Manage Jenkins** → **System**
2. Scroll to **Extended E-mail Notification**
3. Configure:
   - **SMTP server**: `smtp.gmail.com` (for Gmail)
   - **SMTP Port**: `587`
   - **Use SMTP Authentication**: Check
   - **User name**: Your Gmail address
   - **Password**: Your Gmail app password
   - **Use TLS**: Check
   - **SMTP TLS Port**: `587`
4. Click **Test configuration**
5. Click **Save**

### Configure Email in Job

1. Go to your **ARC-Drive-Deploy** job
2. Click **Configure**
3. Scroll to **Post-build Actions**
4. Click **Add post-build action** → **Editable Email Notification**
5. Configure:
   - **Project Recipient List**: `your-email@gmail.com`
   - **Default Subject**: `Build $BUILD_NUMBER - $BUILD_STATUS`
   - **Default Content**:
     ```
     Build Status: $BUILD_STATUS
     Build URL: $BUILD_URL
     Deployment: http://localhost:4173/app.html
     ```
6. Click **Save**

---

## Step 10: Jenkins Maintenance

### Regular Backups

Backup Jenkins configuration daily:

```powershell
# PowerShell script to backup Jenkins
$jenkinsHome = "C:\Program Files\Jenkins"
$backupPath = "C:\Backups\Jenkins"
$date = Get-Date -Format "yyyy-MM-dd"

if (-not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath
}

Copy-Item -Path $jenkinsHome -Destination "$backupPath\jenkins-$date" -Recurse -Force

Write-Host "Jenkins backed up to: $backupPath\jenkins-$date"
```

### Update Jenkins

```powershell
# Check for updates via Jenkins UI
# Or update via Chocolatey
choco upgrade jenkins -y

# Restart service
Restart-Service Jenkins
```

### Monitor Jenkins Health

Access Jenkins dashboard and check:
- **Build History** - See past builds
- **System Log** - Check for errors
- **Manage Jenkins** → **Manage Nodes and Clouds** - Monitor agents

---

## Troubleshooting

### Issue: Jenkins won't start

```powershell
# Check service status
Get-Service Jenkins

# Start service
Start-Service Jenkins

# Check logs
Get-Content "C:\Program Files\Jenkins\jenkins.log" -Tail 50
```

### Issue: Port 8080 already in use

```powershell
# Find process on port 8080
netstat -ano | findstr :8080

# Kill process
taskkill /PID <PID> /F

# Or change Jenkins port in config:
# Edit: C:\Program Files\Jenkins\jenkins.xml
# Change: <arguments>... --httpPort=8080</arguments>
# Restart Jenkins
```

### Issue: Git/GitHub not working

```powershell
# Make sure Git is installed
git --version

# Add Git to PATH if needed
setx PATH "%PATH%;C:\Program Files\Git\cmd"

# Test Git access
git clone https://github.com/your-username/ARC-Drive.git test-clone
```

### Issue: Node.js not found in pipeline

```groovy
// Add to Jenkinsfile
tools {
    nodejs 'nodejs18'  // Must match name in Global Tool Configuration
}
```

### Issue: Build fails with permission denied

```powershell
# Run PowerShell as Administrator
# Restart Jenkins service
Restart-Service Jenkins

# Or reinstall Jenkins
jenkins.exe stop
jenkins.exe remove
jenkins.exe install
jenkins.exe start
```

---

## Jenkins Web Interface Guide

### Main Dashboard
- **Welcome page** with recent builds
- **New Item** - Create new jobs
- **Manage Jenkins** - Configuration
- **Build Executor Status** - See active builds

### Job Management
- **Configure** - Edit job settings
- **Build with Parameters** - Trigger build manually
- **Build History** - View past builds
- **Console Output** - View build logs
- **Artifacts** - Download build outputs

### Common Paths

```
Dashboard:              http://localhost:8080/
Jenkins CLI:            http://localhost:8080/cli
Build Logs:             http://localhost:8080/job/ARC-Drive-Deploy/lastBuild/console
All Builds:             http://localhost:8080/job/ARC-Drive-Deploy/
Pipeline Visualization: http://localhost:8080/job/ARC-Drive-Deploy/
```

---

## Performance Tips

### 1. Increase Heap Size for Better Performance

For large builds, increase memory:

```powershell
# Edit Jenkins startup config
# Add to Jenkins.xml arguments:
# -Xmx1024m -Xms512m
```

### 2. Enable Build Caching

In `Jenkinsfile`:
```groovy
options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 30, unit: 'MINUTES')
}
```

### 3. Use Parallel Builds

```groovy
parallel {
    stage('Build') {
        steps { sh 'npm run build' }
    }
    stage('Lint') {
        steps { sh 'npm run lint' }
    }
}
```

---

## Security Hardening

### 1. Enable Jenkins Security

1. **Manage Jenkins** → **Configure Global Security**
2. **Authorization**: Select **Matrix-based security**
3. Add users and assign appropriate permissions
4. Click **Save**

### 2. Manage Credentials Securely

All sensitive data (passwords, tokens) stored in Jenkins Credentials Store:
- Navigate to **Manage Credentials**
- Keep credentials private
- Rotate tokens regularly

### 3. Configure HTTPS (Production)

For production deployments, use HTTPS:
```
https://your-domain.com:8443
```

See Jenkins documentation for Apache/Nginx reverse proxy setup.

---

## Next Steps

✅ Installation complete!
✅ Plugins installed!
✅ Node.js configured!
✅ Pipeline job created!

### Now:

1. **Push your code to GitHub** (if not already)
2. **Configure GitHub webhook** (optional)
3. **Test first manual build** with `Build with Parameters`
4. **Verify deployment** at http://localhost:4173/app.html
5. **Setup notifications** (Email/Slack)
6. **Monitor builds** in Jenkins dashboard

---

## Useful Commands

```powershell
# Check Jenkins service status
Get-Service Jenkins

# Start/Stop/Restart Jenkins
Start-Service Jenkins
Stop-Service Jenkins
Restart-Service Jenkins

# View Jenkins logs
Get-Content "C:\Program Files\Jenkins\jenkins.log" -Tail 100

# Clear Jenkins cache
Remove-Item "C:\Program Files\Jenkins\workspace\*" -Recurse -Force

# Update Jenkins
choco upgrade jenkins -y

# Uninstall Jenkins
choco uninstall jenkins -y
```

---

## Support Resources

- **Jenkins Documentation**: https://www.jenkins.io/doc/
- **Jenkins Community Forum**: https://community.jenkins.io/
- **Troubleshooting**: https://wiki.jenkins.io/display/JENKINS/Troubleshooting
- **Plugins Directory**: https://plugins.jenkins.io/

---

## Quick Reference

| Task | Command/Path |
|------|--------------|
| Access Jenkins | http://localhost:8080 |
| View Build Logs | http://localhost:8080/job/ARC-Drive-Deploy/lastBuild/console |
| Check Service | `Get-Service Jenkins` |
| Restart Jenkins | `Restart-Service Jenkins` |
| Jenkins Home | `C:\Program Files\Jenkins` |
| Configuration Files | `C:\Program Files\Jenkins\jobs\` |
| Backups | `C:\Backups\Jenkins\` |

---

**Jenkins is now ready for ARC Drive! 🚀**

Your setup supports:
- ✅ Automated builds on Git push
- ✅ Multi-environment deployment (local/staging/production)
- ✅ Email notifications
- ✅ GitHub webhook integration
- ✅ Professional CI/CD pipeline

