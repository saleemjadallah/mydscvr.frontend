#!/bin/bash

# 🧪 Build DXB Events for Staging (Direct EC2 IP)
# This script builds the Flutter web app for testing with direct IP access

echo "🧪 Building DXB Events for Staging (Direct IP)..."

# Set environment variables for staging
export ENVIRONMENT=staging
export API_BASE_URL=http://3.29.102.4:8000

echo "📋 Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   API URL: $API_BASE_URL"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web with staging configuration
echo "🔨 Building Flutter web app..."
flutter build web \
  --profile \
  --web-renderer canvaskit \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=API_BASE_URL=http://3.29.102.4:8000 \
  --tree-shake-icons \
  --source-maps

if [ $? -eq 0 ]; then
    echo "✅ Build completed successfully!"
    echo "📁 Output directory: build/web"
    echo ""
    echo "🧪 This staging build connects directly to:"
    echo "   http://3.29.102.4:8000"
    echo ""
    echo "💡 Use this for testing before deploying to mydscvr.ai"
else
    echo "❌ Build failed!"
    exit 1
fi 