#!/bin/bash

# AWS CLI Installation Script
# Supports macOS, Linux, and Windows (via WSL)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}AWS CLI Installation Script${NC}"
echo "This script will install AWS CLI v2 on your system"
echo ""

# Detect operating system
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

echo -e "${YELLOW}Detected OS: $OS${NC}"

case $OS in
    "macos")
        echo -e "${YELLOW}Installing AWS CLI for macOS...${NC}"
        
        # Check if Homebrew is installed
        if command -v brew &> /dev/null; then
            echo "Installing via Homebrew..."
            brew install awscli
        else
            echo "Installing via direct download..."
            curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
            sudo installer -pkg AWSCLIV2.pkg -target /
            rm AWSCLIV2.pkg
        fi
        ;;
        
    "linux")
        echo -e "${YELLOW}Installing AWS CLI for Linux...${NC}"
        
        # Download and install
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
        ;;
        
    "windows")
        echo -e "${YELLOW}For Windows, please download and run the MSI installer:${NC}"
        echo "https://awscli.amazonaws.com/AWSCLIV2.msi"
        echo ""
        echo "Or use Windows Subsystem for Linux (WSL) and run this script again"
        exit 0
        ;;
        
    *)
        echo -e "${RED}Unsupported operating system${NC}"
        echo "Please visit https://aws.amazon.com/cli/ for installation instructions"
        exit 1
        ;;
esac

# Verify installation
if command -v aws &> /dev/null; then
    echo -e "${GREEN}AWS CLI installed successfully!${NC}"
    aws --version
    
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Configure AWS credentials: aws configure"
    echo "2. Or use environment variables:"
    echo "   export AWS_ACCESS_KEY_ID=your-access-key"
    echo "   export AWS_SECRET_ACCESS_KEY=your-secret-key"
    echo "   export AWS_DEFAULT_REGION=us-east-1"
    echo ""
    echo "3. Then run: ./deploy-cloudfront-local.sh"
else
    echo -e "${RED}Installation failed. Please check the output above for errors.${NC}"
    exit 1
fi