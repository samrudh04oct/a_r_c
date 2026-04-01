#!/bin/bash

# Quick Jenkins Pipeline Trigger Script
# This script helps trigger the Jenkins pipeline from command line

set -e

# Configuration
JENKINS_URL="${JENKINS_URL:-http://localhost:8080}"
JOB_NAME="ARC-Drive-Deploy"
ENVIRONMENT="${1:-local}"  # Default to 'local'

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Jenkins Pipeline Trigger${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(local|staging|production)$ ]]; then
    echo -e "${RED}[ERROR] Invalid environment: $ENVIRONMENT${NC}"
    echo "Valid options: local, staging, production"
    exit 1
fi

echo -e "${GREEN}[INFO] Triggering Jenkins job...${NC}"
echo "Jenkins URL: $JENKINS_URL"
echo "Job: $JOB_NAME"
echo "Environment: $ENVIRONMENT"
echo ""

# Trigger build with parameters
JENKINS_CRUMB=$(curl -s "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" -u jenkins:password)

RESPONSE=$(curl -s -X POST \
    "$JENKINS_URL/job/$JOB_NAME/buildWithParameters?ENVIRONMENT=$ENVIRONMENT" \
    -H "$JENKINS_CRUMB" \
    -u jenkins:password)

echo -e "${GREEN}[INFO] Build triggered!${NC}"
echo ""
echo "Watch the build progress:"
echo -e "${BLUE}$JENKINS_URL/job/$JOB_NAME/lastBuild/console${NC}"
echo ""
echo -e "${GREEN}Application will be available at:${NC}"
echo -e "${BLUE}http://localhost:4173/app.html${NC}"
