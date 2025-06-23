#!/bin/bash

echo "🎬 DXB Events Frontend with Test Data from 14 Sources"
echo "=================================================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if the test API server is running
echo "🔍 Checking if test API server is running on port 3004..."
if ! curl -s http://localhost:3004/health > /dev/null; then
    echo "❌ Test API server is not running on port 3004!"
    echo "🚀 Please start the API server first:"
    echo "   cd ../../Data-Collection && python start_test_server.py"
    exit 1
fi

echo "✅ Test API server is running!"
echo ""

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build and run the app
echo ""
echo "🚀 Starting Flutter Web App..."
echo "✅ App will open in your browser with test data from 14 Dubai sources!"
echo "🌐 API Connection: http://localhost:3004"
echo ""
echo "📊 You should see events from these sources:"
echo "   • Dubai Calendar (3 events)"
echo "   • Platinumlist Dubai (3 events)"
echo "   • Eventbrite Dubai (3 events)"
echo "   • Time Out Dubai (3 events)"
echo "   • Time Out Kids UAE (3 events)"
echo "   • What's On Dubai (3 events)"
echo "   • Meetup.com Dubai (3 events)"
echo "   • BookMyShow Dubai (3 events)"
echo "   • Dubai Culture (3 events)"
echo "   • Zomato Events Dubai (3 events)"
echo "   • Gulf News Events (3 events)"
echo "   • Khaleej Times Events (3 events)"
echo "   • Dubai Web Events (3 events)"
echo "   • Time Out Market Dubai (3 events)"
echo ""
echo "🎯 Total: 42 events with AI-enhanced family scores and categorization!"
echo "=================================================================="

# Run Flutter web
flutter run -d chrome --web-port 8080 