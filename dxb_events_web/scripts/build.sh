#!/bin/bash

# DXB Events Web App Build Script with EC2 Support
# Supports multiple environments and deployment targets including AWS EC2

set -e

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_CONFIG="$PROJECT_ROOT/build_config.yaml"

# Default values
ENVIRONMENT=""
TARGET="web"
BUILD_NUMBER=$(date +%Y%m%d%H%M%S)
VERBOSE=false
HELP=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_help() {
    cat << EOF
🚀 DXB Events Web App Build Script

USAGE:
    $0 --env <environment> --target <target> [options]

ENVIRONMENTS:
    development    Local development build
    staging        Staging environment build  
    production     Production-ready build

TARGETS:
    web           Standard Flutter web build
    firebase      Firebase Hosting deployment
    netlify       Netlify deployment
    github        GitHub Pages deployment
    ec2           AWS EC2 deployment

OPTIONS:
    --env          Environment to build for (required)
    --target       Deployment target (default: web)
    --build-number Custom build number
    --verbose      Enable verbose output
    --help         Show this help message

EXAMPLES:
    $0 --env production --target web
    $0 --env production --target ec2
    $0 --env staging --target firebase
    $0 --env development --target web --verbose

EC2 DEPLOYMENT:
    For EC2 deployment, ensure you have:
    • EC2 instance configured with nginx
    • SSH access configured
    • Environment variables set in build_config.yaml

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --target)
            TARGET="$2"
            shift 2
            ;;
        --build-number)
            BUILD_NUMBER="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            HELP=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Show help if requested
if [ "$HELP" = true ]; then
    show_help
    exit 0
fi

# Validate required parameters
if [ -z "$ENVIRONMENT" ]; then
    log_error "Environment is required. Use --env <environment>"
    echo
    log_info "Available environments: development, staging, production"
    exit 1
fi

# Validate environment
case $ENVIRONMENT in
    development|staging|production)
        ;;
    *)
        log_error "Unknown environment: $ENVIRONMENT"
        log_info "Available environments: development, staging, production"
        exit 1
        ;;
esac

# Validate target
case $TARGET in
    web|firebase|netlify|github|ec2)
        ;;
    *)
        log_error "Unknown target: $TARGET"
        log_info "Available targets: web, firebase, netlify, github, ec2"
        exit 1
        ;;
esac

# Display build information
echo "🚀 DXB Events Web App Build Script"
echo "Environment: $ENVIRONMENT"
echo "Target: $TARGET"
echo "Build Number: $BUILD_NUMBER"
echo "Root Directory: $PROJECT_ROOT"

# Prerequisites check
log_info "Checking prerequisites..."

# Check Flutter installation
log_info "Verifying Flutter installation..."
if ! command -v flutter &> /dev/null; then
    log_error "Flutter is not installed or not in PATH"
    exit 1
fi

flutter doctor

# Clean previous builds
log_info "Cleaning previous builds..."
cd "$PROJECT_ROOT"
flutter clean

# Get dependencies
log_info "Getting Flutter dependencies..."
flutter pub get

# Run code generation
log_info "Running code generation..."
dart run build_runner build --delete-conflicting-outputs

# Set up environment
log_info "Setting up environment: $ENVIRONMENT"

# Environment-specific configuration
case $ENVIRONMENT in
    development)
        export FLUTTER_BUILD_MODE="debug"
        export DART_DEFINES="ENVIRONMENT=development,API_BASE_URL=http://localhost:3000/api"
        ;;
    staging)
        export FLUTTER_BUILD_MODE="profile"
        export DART_DEFINES="ENVIRONMENT=staging,API_BASE_URL=https://api-staging.dxb-events.com"
        ;;
    production)
        export FLUTTER_BUILD_MODE="release"
        export DART_DEFINES="ENVIRONMENT=production,API_BASE_URL=https://api.dxb-events.com"
        ;;
esac

# Build the Flutter web app
log_info "Building Flutter web application..."

# Build arguments based on environment
BUILD_ARGS=()
BUILD_ARGS+=("build" "web")
BUILD_ARGS+=("--$FLUTTER_BUILD_MODE")
BUILD_ARGS+=("--dart-define=$DART_DEFINES")
BUILD_ARGS+=("--build-number=$BUILD_NUMBER")

# Production-specific optimizations
if [ "$ENVIRONMENT" = "production" ]; then
    BUILD_ARGS+=("--tree-shake-icons")
    BUILD_ARGS+=("--source-maps")
fi

# EC2-specific optimizations
if [ "$TARGET" = "ec2" ]; then
    BUILD_ARGS+=("--web-renderer=canvaskit")
    BUILD_ARGS+=("--base-href=/")
fi

# Execute the build
if [ "$VERBOSE" = true ]; then
    BUILD_ARGS+=("--verbose")
fi

flutter "${BUILD_ARGS[@]}"

log_success "Flutter web build completed"

# Target-specific deployment preparation
case $TARGET in
    web)
        log_info "Standard web build completed"
        log_success "Build artifacts available at: build/web/"
        ;;
        
    firebase)
        log_info "Preparing Firebase deployment..."
        # Generate firebase.json
        create_firebase_config
        log_success "Firebase deployment ready. Run: firebase deploy"
        ;;
        
    netlify)
        log_info "Preparing Netlify deployment..."
        # Generate netlify.toml
        create_netlify_config
        log_success "Netlify deployment ready. Upload build/web/ folder"
        ;;
        
    github)
        log_info "Preparing GitHub Pages deployment..."
        # Copy to docs folder
        rm -rf docs/
        cp -r build/web/ docs/
        log_success "GitHub Pages deployment ready. Commit docs/ folder"
        ;;
        
    ec2)
        log_info "Preparing EC2 deployment..."
        create_ec2_deployment_package
        log_success "EC2 deployment package ready"
        ;;
esac

# Build summary
echo
log_success "🎉 Build completed successfully!"
echo "📊 Build Summary:"
echo "   Environment: $ENVIRONMENT"
echo "   Target: $TARGET"
echo "   Build Number: $BUILD_NUMBER"
echo "   Build Mode: $FLUTTER_BUILD_MODE"
echo "   Output: build/web/"

if [ "$TARGET" = "ec2" ]; then
    echo "   EC2 Package: deploy/ec2-deployment.tar.gz"
    echo
    echo "📋 EC2 Deployment Instructions:"
    echo "1. Upload the deployment package to your EC2 instance"
    echo "2. Extract: tar -xzf ec2-deployment.tar.gz"
    echo "3. Run: sudo ./deploy-to-ec2.sh"
fi

# Function to create EC2 deployment package
create_ec2_deployment_package() {
    log_info "Creating EC2 deployment package..."
    
    # Create deployment directory
    mkdir -p deploy/ec2
    
    # Copy web build
    cp -r build/web/* deploy/ec2/
    
    # Create nginx configuration
    create_nginx_config
    
    # Create deployment script
    create_ec2_deploy_script
    
    # Create systemd service (if needed)
    create_systemd_service
    
    # Create environment file
    create_ec2_env_file
    
    # Package everything
    cd deploy
    tar -czf ec2-deployment.tar.gz ec2/
    cd ..
    
    log_success "EC2 deployment package created: deploy/ec2-deployment.tar.gz"
}

# Function to create Nginx configuration
create_nginx_config() {
    cat > deploy/ec2/nginx.conf << EOF
server {
    listen 80;
    listen [::]:80;
    server_name \${EC2_DOMAIN};
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name \${EC2_DOMAIN};
    
    # SSL Configuration
    ssl_certificate /etc/ssl/certs/dxb-events.crt;
    ssl_certificate_key /etc/ssl/private/dxb-events.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # Security Headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Document Root
    root /var/www/dxb-events;
    index index.html;
    
    # Flutter Web Configuration
    location / {
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    # Logging
    access_log /var/log/nginx/dxb-events-access.log;
    error_log /var/log/nginx/dxb-events-error.log;
}
EOF
}

# Function to create EC2 deployment script
create_ec2_deploy_script() {
    cat > deploy/ec2/deploy-to-ec2.sh << 'EOF'
#!/bin/bash

# DXB Events EC2 Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

echo "🚀 DXB Events EC2 Deployment"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log_error "Please run as root (use sudo)"
    exit 1
fi

# Create web directory
log_info "Setting up web directory..."
mkdir -p /var/www/dxb-events
chown www-data:www-data /var/www/dxb-events

# Copy web files
log_info "Copying web files..."
cp -r ./* /var/www/dxb-events/
chown -R www-data:www-data /var/www/dxb-events
chmod -R 755 /var/www/dxb-events

# Install nginx if not present
if ! command -v nginx &> /dev/null; then
    log_info "Installing nginx..."
    apt update
    apt install -y nginx
fi

# Copy nginx configuration
log_info "Configuring nginx..."
cp nginx.conf /etc/nginx/sites-available/dxb-events
ln -sf /etc/nginx/sites-available/dxb-events /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
nginx -t

# Restart nginx
log_info "Restarting nginx..."
systemctl restart nginx
systemctl enable nginx

# Setup firewall (if ufw is available)
if command -v ufw &> /dev/null; then
    log_info "Configuring firewall..."
    ufw allow 22
    ufw allow 80
    ufw allow 443
    ufw --force enable
fi

log_success "🎉 Deployment completed successfully!"
echo
echo "📋 Next Steps:"
echo "1. Configure your domain DNS to point to this server"
echo "2. Install SSL certificate (recommended: Let's Encrypt)"
echo "3. Update nginx.conf with your actual domain name"
echo "4. Restart nginx: systemctl restart nginx"
echo
echo "🔗 Your app should be accessible at: http://$(curl -s ifconfig.me)"

EOF
    chmod +x deploy/ec2/deploy-to-ec2.sh
}

# Function to create systemd service (if needed for background processes)
create_systemd_service() {
    cat > deploy/ec2/dxb-events.service << EOF
[Unit]
Description=DXB Events Web Application
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/dxb-events
Environment=NODE_ENV=${ENVIRONMENT}
Environment=PORT=3000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
}

# Function to create environment file
create_ec2_env_file() {
    cat > deploy/ec2/.env << EOF
# DXB Events Environment Configuration
NODE_ENV=${ENVIRONMENT}
API_BASE_URL=${API_BASE_URL:-https://api.dxb-events.com}
CDN_URL=${CDN_URL:-}
ENVIRONMENT=${ENVIRONMENT}
BUILD_NUMBER=${BUILD_NUMBER}
EOF
}

# Function to create Firebase config
create_firebase_config() {
    cat > firebase.json << EOF
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(eot|otf|ttf|ttc|woff|font.css)",
        "headers": [
          {
            "key": "Access-Control-Allow-Origin",
            "value": "*"
          }
        ]
      },
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=604800"
          }
        ]
      }
    ]
  }
}
EOF
}

# Function to create Netlify config
create_netlify_config() {
    cat > netlify.toml << EOF
[build]
  publish = "build/web"
  command = "echo 'Build already completed'"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
EOF
} 