#!/usr/bin/env python3
"""
Simple web server to serve Flutter web build for testing
"""

import http.server
import socketserver
import os
import sys
from pathlib import Path

# Change to build/web directory
web_dir = Path(__file__).parent / "build" / "web"

if not web_dir.exists():
    print("❌ Build directory not found. Run 'flutter build web' first.")
    sys.exit(1)

os.chdir(web_dir)

PORT = 3001

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

    def do_GET(self):
        # Serve index.html for all routes (SPA routing)
        if self.path.startswith('/#/'):
            self.path = '/index.html'
        elif not self.path.startswith('/assets/') and not self.path.endswith('.js') and not self.path.endswith('.css') and not self.path.endswith('.html'):
            self.path = '/index.html'
        return super().do_GET()

Handler = MyHTTPRequestHandler

print(f"🚀 Starting server...")
print(f"📁 Serving: {web_dir}")
print(f"🌐 URL: http://localhost:{PORT}")
print(f"🧪 Test routes:")
print(f"   • Onboarding: http://localhost:{PORT}/#/onboarding")
print(f"   • Profile: http://localhost:{PORT}/#/profile") 
print(f"   • Home: http://localhost:{PORT}/#/")
print(f"📝 Press Ctrl+C to stop")

try:
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        httpd.serve_forever()
except KeyboardInterrupt:
    print("\n👋 Server stopped")