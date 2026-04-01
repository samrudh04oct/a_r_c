# Jenkins CI/CD Setup Guide for ARC Drive

This guide explains how to set up Jenkins to automatically build and deploy your ARC Drive website to `http://localhost:4173/`.

## Prerequisites

- Jenkins server installed and running
- Node.js and npm installed on Jenkins agent/worker
- Git installed on Jenkins agent
- Repository access (GitHub, GitLab, Bitbucket, etc.)

## Step 1: Install Required Jenkins Plugins

1. Go to **Manage Jenkins** → **Plugin Manager**
2. Install the following plugins:
   - Pipeline
   - Git
   - NodeJS Plugin
   - Email Extension Plugin (optional, for notifications)
   - Slack Notification Plugin (optional, for notifications)

## Step 2: Configure Node.js in Jenkins

1. Go to **Manage Jenkins** → **Global Tool Configuration**
2. Scroll to **NodeJS**
3. Click **Add NodeJS**
4. Configure:
   - **Name**: `nodejs16` (or your preferred version)
   - **Version**: Select from the list
   - **Global npm packages to install**: (leave empty)
5. Click **Save**

## Step 3: Create a New Pipeline Job

### Option A: Using GitHub/GitLab with Webhook

1. Click **New Item**
2. Enter job name: `ARC-Drive-Deploy`
3. Select **Pipeline**
4. Click **OK**

### Option B: Using Git Repository

1. Click **New Item**
2. Enter job name: `ARC-Drive-Deploy`
3. Select **Pipeline**
4. Click **OK**

## Step 4: Configure Pipeline

1. In the **Pipeline** section, choose:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/your-username/arc-drive.git`
   - **Branch**: `*/main` (or your default branch)
   - **Script Path**: `Jenkinsfile`

OR

- **Definition**: Pipeline script
- **Script**: Copy the contents of the `Jenkinsfile` directly into the text area

## Step 5: Configure Build Triggers

Choose one of the following trigger methods:

### Poll SCM (Scheduled)
1. Check **Poll SCM**
2. Schedule: `H/15 * * * *` (every 15 minutes)

### Webhook (GitHub/GitLab/Bitbucket)
1. Check **GitHub hook trigger for GITScm polling**
2. Set up webhook in your repository:
   - **Payload URL**: `http://your-jenkins-url/github-webhook/`
   - **Content type**: application/json
   - **Events**: Push events, Pull requests

### Build periodically
1. Check **Build periodically**
2. Schedule: `H 0 * * *` (daily at midnight)

## Step 6: Configure Node.js

1. In the job configuration, check **Add build step**
2. Select **Execute Shell** (Linux/Mac) or **Execute Windows batch command** (Windows)
3. Add:
   ```bash
   # Linux/Mac
   ./scripts/deploy.sh
   ```
   OR
   ```batch
   # Windows
   scripts\deploy.bat
   ```

## Step 7: Build Parameters

A parameter selection dialog will appear before each build:

**ENVIRONMENT**: Choose deployment target
- `local` - Deploy to localhost:4173 (for development/testing)
- `staging` - Deploy to staging server (if configured)
- `production` - Deploy to production server (if configured)

## Step 8: Configure Post-Build Actions (Optional)

1. Go to **Post-build Actions**
2. Add notifications:
   - **Email Notification**: Send build results to your email
   - **Slack Notification**: Send results to Slack channel
   - **Publish HTML Report**: Publish build artifacts

## Step 9: Build and Deploy

### Trigger a Build

**Option 1: Manual Trigger**
1. Click **Build with Parameters**
2. Select environment: `local`
3. Click **Build**

**Option 2: Git Push (with webhook)**
1. Push code to your repository
2. Jenkins automatically detects and builds

### Monitor Build

1. Watch the build progress in **Console Output**
2. Check logs:
   ```
   [INFO] ✓ Node.js installation verified
   [INFO] ✓ Dependencies installed
   [INFO] ✓ Application built successfully
   [INFO] ✓ Preview server started on http://localhost:4173/
   ```

## Step 10: Access Deployed Application

After successful build:
```
http://localhost:4173/app.html
```

## Troubleshooting

### Problem: Build fails with "npm not found"

**Solution**: 
1. Go to **Manage Jenkins** → **Global Tool Configuration**
2. Configure NodeJS with correct version
3. In pipeline script, add:
   ```groovy
   tools {
       nodejs 'nodejs16'
   }
   ```

### Problem: Port 4173 already in use

**Solution**: Kill existing process and rebuild:
```bash
# Linux/Mac
lsof -ti:4173 | xargs kill -9

# Windows
netstat -ano | findstr :4173
taskkill /PID <PID> /F
```

### Problem: Permission denied on deploy.sh

**Solution**: Make script executable:
```bash
chmod +x scripts/deploy.sh
```

## Webhook Configuration Examples

### GitHub Webhook
1. Go to repository **Settings** → **Webhooks**
2. Click **Add webhook**
3. **Payload URL**: `http://your-jenkins-url/github-webhook/`
4. **Content type**: `application/json`
5. **Events**: Select "Push events" and "Pull requests"
6. Click **Add webhook**

### GitLab Webhook
1. Go to repository **Settings** → **Webhooks**
2. **URL**: `http://your-jenkins-url/project/ARC-Drive-Deploy`
3. **Trigger**: Push events
4. Click **Add webhook**

## Production Deployment

For production deployment, update the `Jenkinsfile`:

```groovy
stage('Deploy to Production') {
    when {
        expression { params.ENVIRONMENT == 'production' }
    }
    steps {
        sh '''
            # Example: Deploy to AWS S3
            aws s3 sync dist/ s3://your-bucket/arc-drive/ --delete
            
            # OR: Deploy via SSH
            scp -r dist/* user@prod-server:/var/www/arc-drive/
            
            # OR: Deploy to Netlify
            netlify deploy --prod --dir=dist
        '''
    }
}
```

## Performance Optimization

### Cache npm packages
```groovy
post {
    always {
        // Don't clean node_modules to speed up next build
        cleanWs(deleteDirs: true, patterns: [[pattern: '**/dist', type: 'INCLUDE']])
    }
}
```

### Parallel builds
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

## Monitoring and Notifications

### Email Notifications
```groovy
post {
    failure {
        mail to: 'dev-team@example.com',
             subject: "Failed: ARC Drive Build #${BUILD_NUMBER}",
             body: "Build failed. Check console output at ${BUILD_URL}"
    }
    success {
        mail to: 'dev-team@example.com',
             subject: "Success: ARC Drive Build #${BUILD_NUMBER}",
             body: "Application deployed to http://localhost:4173/app.html"
    }
}
```

### Slack Notifications
```groovy
post {
    always {
        slackSend(
            channel: '#arc-drive-builds',
            message: "ARC Drive Build #${BUILD_NUMBER}: ${currentBuild.result}"
        )
    }
}
```

## Jenkins System Configuration

### Increase Build Timeout
```groovy
timeout(time: 30, unit: 'MINUTES') {
    // build steps
}
```

### Set Environment Variables
```groovy
environment {
    PATH = "${WORKSPACE}/node_modules/.bin:${PATH}"
    NODE_ENV = 'production'
}
```

## Success! 🎉

Your Jenkins CI/CD pipeline is now configured and ready to:
✅ Automatically build on git push (if webhook enabled)
✅ Run tests and quality checks
✅ Deploy to localhost:4173
✅ Send notifications on success/failure

For questions or issues, check the Jenkins console output or Jenkins logs.
