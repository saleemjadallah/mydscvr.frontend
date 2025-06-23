# 🌐 MyDscvr.ai DNS Setup Guide

## Architecture Overview

```
User → https://mydscvr.ai (Netlify/Frontend)
        ↓
     Flutter App calls → https://api.mydscvr.ai (EC2 Backend)
                            ↓  
                         Events API + Data Pipeline
```

## Required DNS Records

To make this architecture work, you need to set up these DNS records in your domain registrar:

### Primary Records
```dns
# Main website (Frontend on Netlify)
mydscvr.ai        CNAME   your-netlify-site.netlify.app

# API subdomain (Backend on EC2) 
api.mydscvr.ai    A       3.29.102.4
```

### Optional Records
```dns
# If you want www to work
www.mydscvr.ai    CNAME   mydscvr.ai

# If you want a staging subdomain
staging.mydscvr.ai  A     3.29.102.4
```

## SSL Certificate Setup

### For api.mydscvr.ai (EC2 Server)
```bash
# SSH into your EC2 server
ssh -i Backend/mydscvrkey.pem ubuntu@3.29.102.4

# Install certbot if not already installed
sudo apt update
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate for API subdomain
sudo certbot --nginx -d api.mydscvr.ai

# Verify renewal works
sudo certbot renew --dry-run
```

### For mydscvr.ai (Netlify)
Netlify automatically handles SSL for custom domains once DNS is configured.

## Verification Steps

### 1. Check DNS Propagation
```bash
# Check main domain
nslookup mydscvr.ai

# Check API subdomain  
nslookup api.mydscvr.ai
# Should return: 3.29.102.4
```

### 2. Test Endpoints
```bash
# Test main site (after deployment)
curl -I https://mydscvr.ai

# Test API health
curl https://api.mydscvr.ai/health

# Test events endpoint
curl https://api.mydscvr.ai/events/?page=1&per_page=1
```

## Nginx Configuration on EC2

Your EC2 server should have an nginx config like this:

```nginx
# /etc/nginx/sites-available/api.mydscvr.ai
server {
    listen 80;
    server_name api.mydscvr.ai;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name api.mydscvr.ai;
    
    ssl_certificate /etc/letsencrypt/live/api.mydscvr.ai/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.mydscvr.ai/privkey.pem;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Deployment Commands

### Build for Production
```bash
cd Frontend/dxb_events_web
./build_for_mydscvr.sh
```

### Deploy to Netlify
```bash
# Upload build/web/* to Netlify
# Or use Netlify CLI:
netlify deploy --prod --dir=build/web
```

## Environment Summary

| Environment | Frontend URL | API URL | SSL | Status |
|-------------|-------------|---------|-----|---------|
| **Development** | http://localhost:8080 | http://localhost:8000 | ❌ | Local testing |
| **Staging** | http://localhost:8080 | http://3.29.102.4:8000 | ❌ | Direct IP testing |
| **Production** | https://mydscvr.ai | https://api.mydscvr.ai | ✅ | Live with proper domains |

## Troubleshooting

### If api.mydscvr.ai doesn't resolve:
1. Check DNS propagation (can take up to 48 hours)
2. Verify A record points to 3.29.102.4
3. Check if domain registrar has nameserver changes pending

### If SSL certificate fails:
1. Ensure DNS is fully propagated first
2. Check nginx is running: `sudo systemctl status nginx`
3. Verify port 80 and 443 are open in EC2 security groups

### If API calls fail:
1. Check backend is running: `curl http://localhost:8000/health` (on EC2)
2. Verify nginx proxy configuration
3. Check SSL certificate is valid: `curl -I https://api.mydscvr.ai`

## Next Steps

1. ✅ **Frontend Configuration**: Updated to use https://api.mydscvr.ai
2. 🔲 **DNS Setup**: Configure the DNS records above
3. 🔲 **SSL Setup**: Run certbot for api.mydscvr.ai
4. 🔲 **Backend Data**: Ensure EC2 has events data populated
5. 🔲 **Deploy Frontend**: Upload to Netlify with custom domain
6. 🔲 **Test End-to-End**: Verify the full flow works

Your frontend is now properly configured for the mydscvr.ai architecture! 🚀 