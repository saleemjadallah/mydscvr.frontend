# 🌐 DXB Events - Frontend to EC2 Connection Guide

## Overview

This document explains how the **Netlify-hosted frontend** connects to your **EC2-hosted backend and data collection services**.

## 🏗️ Architecture Overview

```
┌─────────────────┐    HTTPS/HTTP     ┌─────────────────────────────────┐
│                 │ ───────────────► │        EC2 Instance             │
│  Netlify        │                  │  (3.29.102.4)                  │
│  (Frontend)     │                  │                                 │
│                 │ ◄─────────────── │  ┌─────────────────────────────┐│
└─────────────────┘                  │  │ Backend API (Port 8000)     ││
                                     │  │ - FastAPI                   ││
                                     │  │ - Authentication            ││
                                     │  │ - Events management         ││
                                     │  │ - Lifecycle management      ││
                                     │  └─────────────────────────────┘│
                                     │                                 │
                                     │  ┌─────────────────────────────┐│
                                     │  │ Data Collection (Port 8001) ││
                                     │  │ - Web scraping              ││
                                     │  │ - AI processing             ││
                                     │  │ - Data monitoring           ││
                                     │  │ - Schedule management       ││
                                     │  └─────────────────────────────┘│
                                     └─────────────────────────────────┘
```

## 🔗 Connection Configuration

### Environment-Based URLs

The frontend is configured to connect to different URLs based on the build environment:

| Environment | Backend API | Data Collection | Use Case |
|------------|-------------|-----------------|----------|
| **Development** | `http://localhost:8000` | `http://localhost:8001` | Local testing |
| **Staging** | `http://3.29.102.4:8000` | `http://3.29.102.4:8001` | Testing with EC2 |
| **Testing** | `http://3.29.102.4:8000` | `http://3.29.102.4:8001` | Direct IP testing |
| **Production** | `https://mydscvr.ai:8000` | `https://mydscvr.ai:8001` | Live deployment |

### Fallback System

The production environment includes automatic fallback to the IP address if your custom domain fails:

- **Primary**: Your custom domain (`https://mydscvr.ai:8000`)
- **Fallback**: Direct IP access (`http://3.29.102.4:8000`)

## 🚀 Building for Different Environments

### Quick Start

```bash
# Navigate to frontend directory
cd Frontend/dxb_events_web

# Build for different environments
./build_for_environments.sh development
./build_for_environments.sh staging
./build_for_environments.sh testing
./build_for_environments.sh production
```

### Custom URLs

```bash
# Use your own domain
./build_for_environments.sh production \
  --api-url https://mydscvr.ai:8000 \
  --data-url https://mydscvr.ai:8001

# Deploy directly to Netlify
./build_for_environments.sh production \
  --api-url https://mydscvr.ai:8000 \
  --deploy-netlify
```

### Build Examples

#### 1. Development Build (Local Testing)
```bash
./build_for_environments.sh development
```
**Result**: Frontend connects to `localhost:8000` and `localhost:8001`

#### 2. Staging Build (EC2 Testing)
```bash
./build_for_environments.sh staging
```
**Result**: Frontend connects directly to EC2 IP `3.29.102.4:8000`

#### 3. Production Build with Custom Domain
```bash
./build_for_environments.sh production \
  --api-url https://mydscvr.ai:8000 \
  --data-url https://mydscvr.ai:8001
```
**Result**: Frontend connects to your domain with IP fallback

## 📱 API Endpoints Available

### Backend API (Port 8000)

The frontend connects to these backend endpoints:

| Category | Endpoints | Description |
|----------|-----------|-------------|
| **Authentication** | `/api/auth/*` | Login, register, user management |
| **Events** | `/api/events/*` | Event listing, details, search |
| **Family Features** | `/api/family/*` | Family-friendly filtering |
| **User Management** | `/api/user/*` | Preferences, favorites |
| **Lifecycle** | `/api/lifecycle/*` | Data management, health |

**Example API calls from frontend:**
- `GET /api/events` - Get events list
- `GET /api/events/{id}` - Get event details
- `POST /api/auth/login` - User authentication
- `GET /api/lifecycle/health` - System health

### Data Collection API (Port 8001)

While primarily for backend integration, some frontend features may connect to:

| Category | Endpoints | Description |
|----------|-----------|-------------|
| **Health** | `/health` | Service status |
| **Metrics** | `/metrics` | Performance data |
| **Processing** | `/processing/*` | AI processing status |
| **Sources** | `/scrapers/*` | Data source information |

## 🔧 CORS Configuration

Your EC2 backend is configured to accept requests from Netlify:

```python
# Backend CORS settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configured for Netlify domains
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)
```

## 🌍 Domain Setup (Optional)

To use custom domains instead of IP addresses:

### 1. Domain Configuration
```bash
# Point your domain to EC2 IP
mydscvr.ai    A    3.29.102.4
*.mydscvr.ai  A    3.29.102.4  # Optional: for subdomains
```

### 2. SSL Certificate Setup (Recommended)
```bash
# On EC2 instance
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d mydscvr.ai
```

### 3. Nginx Configuration
```nginx
# /etc/nginx/sites-available/mydscvr
server {
    listen 80;
    listen 443 ssl;
    server_name mydscvr.ai;
    
    # Backend API (Port 8000)
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Data Collection API (Port 8001) 
    location /data/ {
        proxy_pass http://localhost:8001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Direct port access for compatibility
    location:8000/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location:8001/ {
        proxy_pass http://localhost:8001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🔄 Deployment Workflow

### Complete Deployment Process

1. **Deploy Backend & Data Collection to EC2**
   ```bash
   # From project root
   ./sync_all_to_ec2.sh
   ```

2. **Build Frontend for Production**
   ```bash
   cd Frontend/dxb_events_web
   ./build_for_environments.sh production --api-url https://mydscvr.ai:8000
   ```

3. **Deploy Frontend to Netlify**
   - Manual: Drag `build/web` folder to Netlify
   - CLI: `./build_for_environments.sh production --deploy-netlify`

### Quick Test Deployment

```bash
# Build and test with IP
cd Frontend/dxb_events_web
./build_for_environments.sh staging

# Test locally
cd build/web
python3 -m http.server 8080

# Visit: http://localhost:8080
# Should connect to EC2: http://3.29.102.4:8000
```

## 🔍 Testing Connections

### 1. Test EC2 Services
```bash
# Test backend
curl http://3.29.102.4:8000/health

# Test data collection
curl http://3.29.102.4:8001/health
```

### 2. Test Frontend Connection
```javascript
// From browser console on Netlify site
fetch('/api/health')
  .then(response => response.json())
  .then(data => console.log('Backend health:', data));
```

### 3. Network Debugging
```bash
# Check if ports are open
nmap -p 8000,8001 3.29.102.4

# Test from local machine
curl -v http://3.29.102.4:8000/api/status
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. CORS Errors
**Problem**: Browser blocks requests due to CORS policy
**Solution**: 
- Check EC2 backend CORS configuration
- Ensure Netlify domain is in allowed origins

#### 2. Connection Timeout
**Problem**: Frontend can't reach EC2 services
**Solution**:
- Verify EC2 security groups allow ports 8000, 8001
- Check if services are running on EC2
- Test with fallback URLs

#### 3. SSL/HTTPS Issues
**Problem**: Mixed content warnings (HTTPS frontend → HTTP backend)
**Solution**:
- Set up SSL certificates on EC2
- Use custom domain with HTTPS
- Configure proper SSL termination

### Debug Commands

```bash
# Check EC2 services
ssh -i Backend/mydscvrkey.pem ubuntu@3.29.102.4
sudo systemctl status backend data-collection

# View logs
tail -f ~/backend/logs/app.log
tail -f ~/data-collection/logs/app.log

# Test API endpoints
curl http://localhost:8000/health
curl http://localhost:8001/health
```

## 📊 Monitoring

### Health Checks

The frontend automatically monitors connection health:

```dart
// Automatic health checks
ApiClientProvider.instance.checkHealth();
```

### Performance Monitoring

View deployment info:
```bash
# After build
cat build/web/deployment-info.json
```

## 🔐 Security Considerations

1. **API Security**: Implement proper authentication tokens
2. **HTTPS**: Use SSL certificates for production
3. **Firewall**: Restrict EC2 access to necessary ports
4. **Environment Variables**: Keep sensitive data in environment variables

## 📞 Support

If you encounter issues:

1. Check the build logs in `Frontend/dxb_events_web/`
2. Verify EC2 services are running
3. Test API endpoints directly
4. Check browser network tab for connection errors

---

**✅ Your frontend on Netlify will seamlessly connect to your EC2 backend and data collection services using this configuration!** 