# 🚀 MyDscvr.ai - DXB Events Setup Guide

## ✅ **Your Configuration Summary**

Your frontend is now configured to connect to **https://mydscvr.ai** with automatic fallback to the EC2 IP address.

## 🔗 **Connection Flow**

```
Netlify Frontend (mydscvr.ai) → https://mydscvr.ai:8000 → EC2 (3.29.102.4:8000)
                                      ↓ (fallback if needed)
                                http://3.29.102.4:8000
```

## 🎯 **Quick Deployment Commands**

### 1. Deploy Backend to EC2
```bash
# From project root
./sync_all_to_ec2.sh
```

### 2. Build Frontend for MyDscvr.ai
```bash
cd Frontend/dxb_events_web

# Production build with mydscvr.ai
./build_for_environments.sh production

# Or with explicit URL (same result)
./build_for_environments.sh production \
  --api-url https://mydscvr.ai:8000 \
  --data-url https://mydscvr.ai:8001

# Build and deploy to Netlify in one step
./build_for_environments.sh production --deploy-netlify
```

### 3. Test Different Environments
```bash
# Local development
./build_for_environments.sh development

# EC2 IP testing
./build_for_environments.sh staging

# Production with mydscvr.ai
./build_for_environments.sh production
```

## 🌐 **Domain Setup Required**

To make **https://mydscvr.ai:8000** work, you need to:

### 1. DNS Configuration
```bash
# Add these DNS records to mydscvr.ai:
mydscvr.ai    A    3.29.102.4
*.mydscvr.ai  A    3.29.102.4  # Optional: for subdomains
```

### 2. EC2 Security Groups
Ensure these ports are open on your EC2 instance:
- **Port 8000**: Backend API
- **Port 8001**: Data Collection API
- **Port 80**: HTTP (for SSL setup)
- **Port 443**: HTTPS (for SSL)

### 3. SSL Certificate (Recommended)
```bash
# SSH into EC2
ssh -i Backend/mydscvrkey.pem ubuntu@3.29.102.4

# Install SSL certificate
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d mydscvr.ai

# This will automatically configure HTTPS
```

## 🔧 **Current Configuration**

| Environment | Backend API | Data Collection | Status |
|------------|-------------|-----------------|--------|
| **Development** | `http://localhost:8000` | `http://localhost:8001` | ✅ Ready |
| **Staging** | `http://3.29.102.4:8000` | `http://3.29.102.4:8001` | ✅ Ready |
| **Production** | `https://mydscvr.ai:8000` | `https://mydscvr.ai:8001` | ⚠️ DNS Required |
| **Fallback** | `http://3.29.102.4:8000` | `http://3.29.102.4:8001` | ✅ Ready |

## 🧪 **Testing Your Setup**

### 1. Test EC2 Services
```bash
# Test backend
curl http://3.29.102.4:8000/health

# Test data collection
curl http://3.29.102.4:8001/health
```

### 2. Test Domain (after DNS setup)
```bash
# Test your domain
curl https://mydscvr.ai:8000/health
curl https://mydscvr.ai:8001/health
```

### 3. Test Frontend Build
```bash
cd Frontend/dxb_events_web
./build_for_environments.sh staging

# Test locally
cd build/web
python3 -m http.server 8080

# Visit: http://localhost:8080
# Should connect to EC2: http://3.29.102.4:8000
```

## 📋 **Build Outputs**

After each build, check the deployment info:
```bash
cat build/web/deployment-info.json
```

**Example output:**
```json
{
    "environment": "production",
    "api_url": "https://mydscvr.ai:8000",
    "data_collection_url": "https://mydscvr.ai:8001",
    "build_time": "2024-01-01T12:00:00Z",
    "flutter_version": "Flutter 3.x.x"
}
```

## 🚀 **Deployment Workflow**

1. **Deploy Services**: `./sync_all_to_ec2.sh`
2. **Setup DNS**: Point `mydscvr.ai` to `3.29.102.4`
3. **Setup SSL**: `sudo certbot --nginx -d mydscvr.ai`
4. **Build Frontend**: `./build_for_environments.sh production`
5. **Deploy to Netlify**: Upload `build/web` folder

## 🔄 **Fallback System**

Your configuration includes automatic fallback:
- **Primary**: `https://mydscvr.ai:8000`
- **Fallback**: `http://3.29.102.4:8000`

If mydscvr.ai is unreachable, the frontend automatically tries the IP address.

## 🎉 **Ready to Go!**

Your frontend is fully configured for **mydscvr.ai**. Once you set up the DNS records, you'll have:

✅ **Production URL**: https://mydscvr.ai:8000  
✅ **Automatic Fallback**: http://3.29.102.4:8000  
✅ **Multi-Environment**: Development, Staging, Testing, Production  
✅ **Easy Deployment**: One-command builds and deploys  

**Next step**: Configure your DNS to point `mydscvr.ai` to `3.29.102.4`! 