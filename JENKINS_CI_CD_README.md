# 🚀 ARC Drive - Jenkins CI/CD Integration

Complete Jenkins CI/CD pipeline setup for automatic building and deploying your ARC Drive React application.

## 📋 Files Created

### 1. **Jenkinsfile**
Main Jenkins pipeline configuration. Supports:
- Checkout from Git
- Install Node.js dependencies
- Build React application
- Quality checks
- Deploy to local (localhost:4173)
- Deploy to staging
- Deploy to production
- Health verification

### 2. **scripts/deploy.bat** (Windows)
Automated deployment script for Windows systems:
- Checks Node.js/npm installation
- Installs dependencies
- Builds the application
- Verifies build artifacts
- Stops previous server
- Starts preview server on port 4173
- Health check

**Usage:**
```batch
scripts\deploy.bat
```

### 3. **scripts/deploy.sh** (Linux/Mac)
Automated deployment script for Unix systems:
- Same features as deploy.bat
- Uses bash scripting

**Usage:**
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 4. **scripts/trigger-jenkins.sh**
Quick command-line tool to trigger Jenkins builds from terminal:

**Usage:**
```bash
./scripts/trigger-jenkins.sh local        # Deploy to local
./scripts/trigger-jenkins.sh staging      # Deploy to staging
./scripts/trigger-jenkins.sh production   # Deploy to production
```

### 5. **deployment.config**
Configuration file for different deployment environments:
- Local environment settings
- Staging environment settings
- Production environment settings
- Build settings
- Notification settings (Email, Slack)
- Security settings
- Health check settings

### 6. **JENKINS_SETUP.md**
Complete step-by-step guide for:
- Installing required plugins
- Configuring Node.js in Jenkins
- Setting up the pipeline job
- Configuring build triggers (webhook, polling, schedule)
- Setting up notifications
- Troubleshooting

## 🚀 Quick Start

### Step 1: Install Jenkins
```bash
# On Windows (using Chocolatey)
choco install jenkins

# On Mac
brew install jenkins-lts

# On Linux (Ubuntu/Debian)
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins
```

### Step 2: Start Jenkins
```bash
# Windows
# Jenkins runs as a service automatically

# Mac/Linux
jenkins
# or
sudo systemctl start jenkins
```

Jenkins will be available at: `http://localhost:8080`

### Step 3: Follow Jenkins Setup Guide
Follow the detailed instructions in [JENKINS_SETUP.md](./JENKINS_SETUP.md)

### Step 4: Test Deployment

**Option A: Manual Test (Immediate)**
```bash
# Windows
scripts\deploy.bat

# Linux/Mac
./scripts/deploy.sh
```

**Option B: Jenkins Web UI**
1. Go to Jenkins dashboard
2. Click on your job "ARC-Drive-Deploy"
3. Click "Build with Parameters"
4. Select environment: `local`
5. Click "Build"

**Option C: Command Line**
```bash
./scripts/trigger-jenkins.sh local
```

### Step 5: Access Your Application
```
http://localhost:4173/app.html
```

## 📊 Pipeline Stages

```
┌─────────────┐
│  Checkout   │  - Pull code from Git repository
└──────┬──────┘
       ↓
┌──────────────────────┐
│ Install Dependencies │  - npm install
└──────┬───────────────┘
       ↓
┌────────────┐
│   Build    │  - npm run build
└──────┬─────┘
       ↓
┌──────────────────┐
│ Quality Checks   │  - Verify build artifacts
└──────┬───────────┘
       ↓
┌────────────────┐
│ Deploy (Local) │  ├─ Stop previous server
│ Deploy (Staging)  ├─ Start new server
│ Deploy (Prod)  │  └─ Port 4173
└──────┬─────────┘
       ↓
┌──────────────────┐
│ Verify Deployment│  - Health check
└──────┬───────────┘
       ↓
┌────────────┐
│  Complete  │  ✓ Application live
└────────────┘
```

## 🔧 Environment Variables

Set these in Jenkins or your CI/CD system:

```bash
# Required
NODE_ENV=production
APP_PORT=4173
BUILD_DIR=dist

# Optional (Notifications)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
EMAIL_RECIPIENTS=dev@example.com

# Optional (Production)
SSH_HOST=prod-server.com
SSH_USER=deploy
SSH_KEY=/path/to/private/key
```

## 📦 Build Output

After successful build:
```
dist/
├── app.html              (2.46 kB)
├── assets/
│   ├── main-D9Icz0FV.css    (29.25 kB)
│   └── main-CTRrRIL0.js     (315.55 kB)
└── logo.jpeg
```

**Total Size:** ~350 kB (production optimized, gzipped)

## 🚨 Troubleshooting

### Issue: Build fails with "npm not found"
**Solution:**
1. Install Node.js on Jenkins agent
2. Configure NodeJS in Jenkins Global Tool Configuration
3. Verify PATH includes npm

### Issue: Port 4173 already in use
**Solution:**
```bash
# Windows
netstat -ano | findstr :4173
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:4173 | xargs kill -9
```

### Issue: Deploy script permission denied
**Solution:**
```bash
chmod +x scripts/deploy.sh
chmod +x scripts/trigger-jenkins.sh
```

### Issue: Jenkins can't clone repository
**Solution:**
1. Add SSH key to Jenkins credentials
2. Configure Git plugin with correct credentials
3. Test Git connection from Jenkins server

## 📈 Monitoring & Logs

### Jenkins Console Output
View detailed build logs:
```
http://localhost:8080/job/ARC-Drive-Deploy/lastBuild/console
```

### Deployment Logs
```
deployment.log          # Main deployment log
/tmp/arc-drive-preview.log   # Preview server log
/tmp/preview.log           # Alternative log location
```

### Health Check
After deployment:
```bash
curl -I http://localhost:4173/app.html
# Should return: HTTP/1.1 200 OK
```

## 🔐 Security Best Practices

1. **Credentials Management**
   - Store SSH keys in Jenkins Credentials Store
   - Use Jenkins Secrets plugin for sensitive data
   - Never commit secrets to Git

2. **Production Safety**
   - Require approval for production deploys
   - Implement blue-green deployments
   - Keep backups before deployment
   - Use limited SSH keys with specific permissions

3. **Access Control**
   - Restrict who can trigger builds
   - Use Matrix Authorization Plugin
   - Enable audit logging

## 📞 Support & Documentation

- **Jenkins Docs**: https://jenkins.io/doc/
- **Pipeline Documentation**: https://jenkins.io/doc/book/pipeline/
- **Vite Documentation**: https://vitejs.dev/
- **React Documentation**: https://react.dev/

## ✨ Next Steps

1. ✅ Set up Jenkins server
2. ✅ Configure Node.js in Jenkins
3. ✅ Create pipeline job
4. ✅ Configure Git repository
5. ✅ Set up webhook (optional)
6. ✅ Configure notifications (optional)
7. ✅ Test manual build
8. ✅ Test automated trigger
9. ✅ Monitor production deployments
10. ✅ Set up backup strategy

## 📊 Deployment Status

Track your deployments:
- **Local**: http://localhost:4173/app.html ✅
- **Staging**: (configure in Jenkinsfile)
- **Production**: (configure in Jenkinsfile)

---

**Created**: 2024
**Last Updated**: 2026-04-01
**Version**: 1.0.0

🚀 Happy Deploying!
