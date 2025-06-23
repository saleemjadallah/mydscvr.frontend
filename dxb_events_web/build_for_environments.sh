#!/bin/bash

# 🚀 DXB Events - Multi-Environment Build Script
# Builds the Flutter web app for different environments with custom URLs

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 DXB Events - Multi-Environment Build Script${NC}"
echo "=============================================="

# Function to show usage
show_usage() {
    echo -e "${YELLOW}Usage: $0 [environment] [options]${NC}"
    echo ""
    echo "Environments:"
    echo "  development   - Build for local development (localhost:8000)"
    echo "  staging       - Build for staging (Public IP: 3.29.102.4:8000)"
    echo "  testing       - Build for testing (Direct IP access)"
    echo "  production    - Build for production (Custom URL with IP fallback)"
    echo ""
    echo "Options:"
    echo "  --api-url URL          Custom API URL (overrides default)"
    echo "  --data-url URL         Custom Data Collection URL"
    echo "  --deploy-netlify       Deploy to Netlify after build"
    echo "  --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 development"
    echo "  $0 production --api-url https://mydscvr.ai:8000"
    echo "  $0 staging --deploy-netlify"
    exit 1
}

# Default values
ENVIRONMENT=""
CUSTOM_API_URL=""
CUSTOM_DATA_URL=""
DEPLOY_NETLIFY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        development|staging|testing|production)
            ENVIRONMENT="$1"
            shift
            ;;
        --api-url)
            CUSTOM_API_URL="$2"
            shift 2
            ;;
        --data-url)
            CUSTOM_DATA_URL="$2"
            shift 2
            ;;
        --deploy-netlify)
            DEPLOY_NETLIFY=true
            shift
            ;;
        --help)
            show_usage
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_usage
            ;;
    esac
done

# Check if environment is specified
if [[ -z "$ENVIRONMENT" ]]; then
    echo -e "${RED}❌ Environment not specified${NC}"
    show_usage
fi

# Set default URLs based on environment
case $ENVIRONMENT in
    development)
        DEFAULT_API_URL="http://localhost:8000"
        DEFAULT_DATA_URL="http://localhost:8001"
        ;;
    staging)
        DEFAULT_API_URL="http://3.29.102.4:8000"
        DEFAULT_DATA_URL="http://3.29.102.4:8001"
        ;;
    testing)
        DEFAULT_API_URL="http://3.29.102.4:8000"
        DEFAULT_DATA_URL="http://3.29.102.4:8001"
        ;;
    production)
        DEFAULT_API_URL="https://mydscvr.ai:8000"
        DEFAULT_DATA_URL="https://mydscvr.ai:8001"
        ;;
    *)
        echo -e "${RED}❌ Invalid environment: $ENVIRONMENT${NC}"
        show_usage
        ;;
esac

# Use custom URLs if provided, otherwise use defaults
API_URL="${CUSTOM_API_URL:-$DEFAULT_API_URL}"
DATA_URL="${CUSTOM_DATA_URL:-$DEFAULT_DATA_URL}"

echo -e "${GREEN}📋 Build Configuration:${NC}"
echo "   Environment: $ENVIRONMENT"
echo "   API URL: $API_URL"
echo "   Data Collection URL: $DATA_URL"
echo "   Deploy to Netlify: $DEPLOY_NETLIFY"
echo ""

# Check if we're in the right directory
if [[ ! -f "pubspec.yaml" ]]; then
    echo -e "${RED}❌ Error: pubspec.yaml not found. Please run from the Flutter project root.${NC}"
    exit 1
fi

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Build Flutter defines
FLUTTER_DEFINES=(
    "--dart-define=ENVIRONMENT=$ENVIRONMENT"
    "--dart-define=API_BASE_URL=$API_URL"
    "--dart-define=DATA_COLLECTION_URL=$DATA_URL"
)

# Add fallback URLs for production
if [[ "$ENVIRONMENT" == "production" ]]; then
    FLUTTER_DEFINES+=(
        "--dart-define=FALLBACK_API_URL=http://3.29.102.4:8000"
        "--dart-define=FALLBACK_DATA_URL=http://3.29.102.4:8001"
    )
fi

# Additional flags based on environment
case $ENVIRONMENT in
    development)
        FLUTTER_DEFINES+=(
            "--dart-define=ENABLE_LOGS=true"
            "--dart-define=ENABLE_PERFORMANCE_OVERLAY=true"
        )
        BUILD_FLAGS=("--source-maps" "--no-tree-shake-icons")
        ;;
    staging|testing)
        FLUTTER_DEFINES+=(
            "--dart-define=ENABLE_LOGS=true"
            "--dart-define=ENABLE_PERFORMANCE_OVERLAY=false"
        )
        BUILD_FLAGS=("--source-maps" "--tree-shake-icons" "--profile")
        ;;
    production)
        FLUTTER_DEFINES+=(
            "--dart-define=ENABLE_LOGS=false"
            "--dart-define=ENABLE_PERFORMANCE_OVERLAY=false"
        )
        BUILD_FLAGS=("--no-source-maps" "--tree-shake-icons" "--release")
        ;;
esac

# Build the app
echo -e "${BLUE}🔨 Building Flutter web app for $ENVIRONMENT...${NC}"
echo "Command: flutter build web ${FLUTTER_DEFINES[*]} ${BUILD_FLAGS[*]}"
echo ""

flutter build web "${FLUTTER_DEFINES[@]}" "${BUILD_FLAGS[@]}"

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo -e "${GREEN}📂 Build output: build/web/${NC}"
    
    # Show build info
    echo ""
    echo -e "${BLUE}📊 Build Information:${NC}"
    ls -la build/web/ | head -10
    
    # Create deployment info file
    cat > build/web/deployment-info.json << EOF
{
    "environment": "$ENVIRONMENT",
    "api_url": "$API_URL",
    "data_collection_url": "$DATA_URL",
    "build_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "build_host": "$(hostname)",
    "flutter_version": "$(flutter --version | head -1)"
}
EOF
    
    echo -e "${GREEN}📋 Deployment info saved to: build/web/deployment-info.json${NC}"
    
    # Deploy to Netlify if requested
    if [[ "$DEPLOY_NETLIFY" == true ]]; then
        echo ""
        echo -e "${BLUE}🚀 Deploying to Netlify...${NC}"
        
        if command -v netlify &> /dev/null; then
            cd build/web
            netlify deploy --prod --dir .
            cd ../..
            echo -e "${GREEN}✅ Deployed to Netlify successfully!${NC}"
        else
            echo -e "${YELLOW}⚠️ Netlify CLI not found. Please install it with: npm install -g netlify-cli${NC}"
            echo -e "${BLUE}💡 Manual deployment: Upload the build/web folder to Netlify${NC}"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Build process completed!${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Test the build locally: cd build/web && python3 -m http.server 8080"
    echo "2. Deploy to Netlify: drag and drop the build/web folder"
    echo "3. Or run: $0 $ENVIRONMENT --deploy-netlify"
    
else
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi 