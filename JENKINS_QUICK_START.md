# ⚡ Jenkins Quick Start - 5 Minutes

## 🚀 Super Quick Installation

### Method 1: Automatic PowerShell (Recommended for Windows)

**Open PowerShell as Administrator** and run:

```powershell
# Navigate to your project
cd "C:\Users\SAMRUDH NAIK\Videos\arc drive devops\ARC-Drive"

# Run the installation script
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
.\scripts\Install-Jenkins.ps1
```

**That's it!** The script will:
- ✅ Install Java (if needed)
- ✅ Install Chocolatey (if needed)
- ✅ Install Jenkins
- ✅ Start Jenkins service
- ✅ Display your initial admin password

**Wait 30 seconds**, then open:
```
http://localhost:8080
```

---

### Method 2: Manual Batch Script

Open **Command Prompt as Administrator** and run:

```batch
cd C:\Users\SAMRUDH NAIK\Videos\arc drive devops\ARC-Drive
scripts\install-jenkins.bat
```

---

### Method 3: Manual Command Line

**Open PowerShell as Administrator** and run:

```powershell
# Install Chocolatey
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iwr -useb https://community.chocolatey.org/install.ps1 | iex

# Install Java
choco install openjdk17 -y

# Install Jenkins
choco install jenkins -y

# Start Jenkins
Start-Service Jenkins

# Wait 30 seconds
Start-Sleep -Seconds 30

# Get password
Get-Content "C:\Program Files\Jenkins\secrets\initialAdminPassword"
```

---

## 📝 Jenkins Setup Wizard (After Installation)

### 1. Open Jenkins Dashboard
```
http://localhost:8080
```

### 2. Enter Admin Password
When you see the unlock screen:
- Copy the password from your terminal/script output
- Paste it into the "Administrator password" field
- Click **Continue**

### 3. Install Suggested Plugins
- Select **"Install suggested plugins"**
- Wait for plugins to install (~5 minutes)
- Jenkins will restart automatically

### 4. Create Admin User
Fill in the form:
```
Username:        admin
Password:        your-secure-password
Confirm:         your-secure-password
Full name:       Jenkins Admin
Email:           admin@arc-drive.local
```
Click **Save and Create First Admin User**

### 5. Configure Jenkins URL
```
Jenkins URL: http://localhost:8080/
```
Click **Save and Finish**

### 6. Complete! 🎉
You'll see the Jenkins dashboard. You're ready!

---

## 🔧 Install Required Plugins for ARC Drive

### 1. Go to Manage Jenkins
```
http://localhost:8080 → Manage Jenkins → Manage Plugins
```

### 2. Go to "Available" Tab

### 3. Search and Install (Check boxes, then click "Download now and install after restart"):

**Essential:**
- [ ] Pipeline
- [ ] Git  
- [ ] NodeJS Plugin

**Optional but Recommended:**
- [ ] Email Extension Plugin (for notifications)
- [ ] Slack Notification Plugin
- [ ] AnsiColor Plugin
- [ ] Blue Ocean

### 4. Check: "Restart Jenkins when installation is complete"

### 5. Wait for restart (~2 minutes)

Done! ✅

---

## ⚙️ Configure NodeJS in Jenkins

### 1. Go to Manage Jenkins
```
http://localhost:8080 → Manage Jenkins → Global Tool Configuration
```

### 2. Find "NodeJS" Section

### 3. Click "Add NodeJS"

### 4. Enter:
```
Name:           nodejs18
Version:        18.18.0 (or latest 18.x LTS)
Install:        ☑ Install automatically
npm packages:   (leave empty)
```

### 5. Click Apply → Save

Done! ✅

---

## 🔨 Create ARC Drive Pipeline Job

### 1. Click "New Item"

### 2. Name & Type
```
Name:    ARC-Drive-Deploy
Type:    Pipeline
```
Click **OK**

### 3. Configure General
```
Description: ARC Drive - CI/CD Pipeline
☑ This project is parameterized
```

### 4. Add Parameter
Click **"Add Parameter"** → **"Choice Parameter"**
```
Name:        ENVIRONMENT
Choices:     local
             staging
             production
Description: Select deployment environment
```

### 5. Configure Pipeline Script

**Option A: From Git Repository (Recommended)**
```
Definition:        Pipeline script from SCM
SCM:               Git
Repository URL:    https://github.com/your-username/ARC-Drive.git
Branch:            */main
Script Path:       Jenkinsfile
```

**Option B: Direct Script**
```
Definition:  Pipeline script
Script:      (Copy contents of Jenkinsfile into text area)
```

### 6. Build Triggers (Optional)
Check **"GitHub hook trigger for GITScm polling"** for auto-deploy on push

### 7. Save

Done! ✅

---

## 🧪 Test Your Pipeline

### 1. Go to Your Job
```
http://localhost:8080/job/ARC-Drive-Deploy
```

### 2. Click "Build with Parameters"

### 3. Select:
```
ENVIRONMENT: local
```

### 4. Click "Build"

### 5. Watch Console Output
```
http://localhost:8080/job/ARC-Drive-Deploy/lastBuild/console
```

### 6. When Done, Check Your App
```
http://localhost:4173/app.html
```

Your ARC Drive website should be live! 🎉

---

## ✅ Verify Installation

### Jenkins is running:
```powershell
Get-Service Jenkins
```
Should show: **Status: Running**

### Jenkins is accessible:
```
http://localhost:8080
```
Should show Jenkins dashboard

### Application is deployed:
```
http://localhost:4173/app.html
```
Should show your ARC Drive website

---

## 🛑 Troubleshooting

### Jenkins won't start?

```powershell
# Check status
Get-Service Jenkins

# Try restarting
Restart-Service Jenkins

# Check logs
Get-Content "C:\Program Files\Jenkins\jenkins.log" -Tail 50
```

### Port 8080 already in use?

```powershell
# Find what's using port 8080
netstat -ano | findstr :8080

# Kill the process
taskkill /PID <PID> /F
```

### Forgot admin password?

```powershell
# Stop Jenkins
Stop-Service Jenkins

# Delete config file
Remove-Item "C:\Program Files\Jenkins\config.xml" -Force

# Start Jenkins
Start-Service Jenkins

# Wait 30 seconds, then get new password
Get-Content "C:\Program Files\Jenkins\secrets\initialAdminPassword"
```

### Plugin installation fails?

1. Go to **Manage Jenkins** → **Plugin Manager** → **Advanced**
2. Click **Check now** to update plugin index
3. Retry installation

---

## 📊 Dashboard Commands

```powershell
# Start Jenkins
Start-Service Jenkins

# Stop Jenkins
Stop-Service Jenkins

# Restart Jenkins
Restart-Service Jenkins

# View status
Get-Service Jenkins

# View recent logs
Get-Content "C:\Program Files\Jenkins\jenkins.log" -Tail 100

# Check if running
Test-Connection localhost -TcpPort 8080 -Verbose
```

---

## 🔗 Important URLs

| Purpose | URL |
|---------|-----|
| Dashboard | http://localhost:8080 |
| ARC Drive Build | http://localhost:8080/job/ARC-Drive-Deploy |
| Build Console | http://localhost:8080/job/ARC-Drive-Deploy/lastBuild/console |
| System Config | http://localhost:8080/manage/ |
| Plugin Manager | http://localhost:8080/pluginManager/ |
| **Your App** | **http://localhost:4173/app.html** |

---

## 📚 Full Guides

For detailed setup information, see:
- **JENKINS_INSTALLATION_GUIDE.md** - Complete installation guide
- **JENKINS_SETUP.md** - Complete configuration guide
- **JENKINS_CI_CD_README.md** - Overview and features

---

## ✨ You've Done It! 🎉

Your Jenkins CI/CD pipeline is now ready to:
- ✅ Build on every code push
- ✅ Deploy to localhost:4173
- ✅ Send notifications
- ✅ Support multiple environments

**Next:** Push code to GitHub and watch Jenkins auto-deploy! 🚀

