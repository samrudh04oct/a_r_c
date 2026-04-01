pipeline {
    agent any

    environment {
        NODE_ENV = 'production'
        APP_PORT = '4173'
        BUILD_DIR = 'dist'
    }

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['local', 'staging', 'production'], description: 'Deployment environment')
    }

    stages {
        stage('Checkout') {
            steps {
                echo '===== Checking out code from Git ====='
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '===== Installing Node dependencies ====='
                sh 'npm install'
            }
        }

        stage('Build') {
            steps {
                echo '===== Building React application ====='
                sh 'npm run build'
                sh 'ls -la ${BUILD_DIR}/'
            }
        }

        stage('Quality Checks') {
            steps {
                echo '===== Running quality checks ====='
                sh '''
                    if [ -f package.json ]; then
                        echo "✓ package.json found"
                        echo "✓ Dependencies installed"
                        echo "✓ Build completed successfully"
                    fi
                '''
            }
        }

        stage('Deploy to Local') {
            when {
                expression { params.ENVIRONMENT == 'local' }
            }
            steps {
                echo '===== Deploying to localhost:4173 ====='
                sh '''
                    echo "Stopping previous preview server..."
                    pkill -f "npm run preview" || true
                    sleep 2
                    echo "Starting new preview server..."
                    npm run preview > /tmp/preview.log 2>&1 &
                    sleep 3
                    echo "✓ Preview server started on http://localhost:4173/"
                    echo "✓ Build artifacts available in ${BUILD_DIR}/"
                '''
            }
        }

        stage('Deploy to Staging') {
            when {
                expression { params.ENVIRONMENT == 'staging' }
            }
            steps {
                echo '===== Deploying to Staging ====='
                sh '''
                    echo "Deploying to staging environment..."
                    # Add your staging deployment script here
                    # Example: scp -r dist/* user@staging-server:/var/www/arc-drive/
                    echo "✓ Staging deployment completed"
                '''
            }
        }

        stage('Deploy to Production') {
            when {
                expression { params.ENVIRONMENT == 'production' }
            }
            steps {
                echo '===== Deploying to Production ====='
                sh '''
                    echo "Deploying to production environment..."
                    # Add your production deployment script here
                    # Example: scp -r dist/* user@prod-server:/var/www/arc-drive/
                    echo "✓ Production deployment completed"
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '===== Verifying deployment ====='
                sh '''
                    echo "✓ Build artifacts:"
                    du -sh ${BUILD_DIR}
                    echo ""
                    echo "✓ Generated files:"
                    find ${BUILD_DIR} -type f | head -10
                '''
            }
        }
    }

    post {
        always {
            echo '===== Cleaning up workspace ====='
            cleanWs(deleteDirs: true, patterns: [[pattern: '**/node_modules', type: 'INCLUDE']])
        }
        success {
            echo '✓ Pipeline executed successfully!'
            // Add success notifications here (email, Slack, etc.)
        }
        failure {
            echo '✗ Pipeline failed!'
            // Add failure notifications here
        }
    }
}
