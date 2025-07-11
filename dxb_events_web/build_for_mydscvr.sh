#!/bin/bash

# 🚀 Build DXB Events for MyDscvr.ai Production
# This script builds the Flutter web app with proper mydscvr.ai configuration

echo "🌐 Building DXB Events for MyDscvr.ai (Production)..."

# Set environment variables for production
export ENVIRONMENT=production
export API_BASE_URL=""
export FALLBACK_API_URL=http://mydscvr.xyz:8000

echo "📋 Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   Primary API: Auto-detect domain (/api for mydscvr.ai, proxied to mydscvr.xyz:8000)"
echo "   Fallback API: $FALLBACK_API_URL"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web with production configuration
echo "🔨 Building Flutter web app..."
flutter build web \
  --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL="" \
  --dart-define=FALLBACK_API_URL=http://mydscvr.xyz:8000 \
  --no-tree-shake-icons

if [ $? -eq 0 ]; then
    echo "✅ Build completed successfully!"
    echo "📁 Output directory: build/web"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Upload build/web/* to your web server"
    echo "   2. Ensure mydscvr.ai points to 3.29.102.4"
    echo "   3. Verify backend is running on mydscvr.ai:8000"
    echo ""
    echo "🔗 Your app will connect to:"
    echo "   Primary:  Auto-detect (/api for mydscvr.ai → mydscvr.xyz:8000)"
    echo "   Fallback: http://mydscvr.xyz:8000"
else
    echo "❌ Build failed!"
    exit 1
fi 