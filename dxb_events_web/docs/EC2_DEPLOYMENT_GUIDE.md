# 🚀 DXB Events EC2 Deployment Guide

This guide walks you through deploying the DXB Events Flutter web application on AWS EC2.

## 📋 Prerequisites

### EC2 Instance Requirements
- **Instance Type**: t3.micro or larger (t3.small recommended for production)
- **Operating System**: Ubuntu 22.04 LTS or Ubuntu 20.04 LTS
- **Storage**: 20GB minimum
- **Security Group**: Allow HTTP (80), HTTPS (443), and SSH (22)

### Local Requirements
- Flutter SDK installed
- SSH access to your EC2 instance
- Domain name (optional but recommended)

## 🏗️ EC2 Instance Setup

### 1. Launch EC2 Instance

```bash
# 1. Create EC2 instance via AWS Console or CLI
# 2. Choose Ubuntu 22.04 LTS AMI
# 3. Configure security group with these ports:
#    - SSH: 22 (your IP only)
#    - HTTP: 80 (0.0.0.0/0)
#    - HTTPS: 443 (0.0.0.0/0)
```

### 2. Connect to Your Instance

```bash
# Connect via SSH
ssh -i your-key.pem ubuntu@your-ec2-ip

# Update the system
sudo apt update
sudo apt upgrade -y
```

### 3. Install Required Software

```bash
# Install nginx
sudo apt install -y nginx

# Install curl and wget (if not already installed)
sudo apt install -y curl wget

# Install certbot for SSL (Let's Encrypt)
sudo apt install -y certbot python3-certbot-nginx

# Verify nginx is running
sudo systemctl status nginx
```

## 📦 Build and Deploy

### 1. Build Your Application

On your local machine, build the application for EC2:

```bash
# Navigate to your project directory
cd /path/to/DXB-events/Frontend/dxb_events_web

# Build for EC2 deployment
./scripts/build.sh --env production --target ec2
```

This creates an `ec2-deployment.tar.gz` package in the `deploy/` folder.

### 2. Upload to EC2

```bash
# Upload the deployment package
scp -i your-key.pem deploy/ec2-deployment.tar.gz ubuntu@your-ec2-ip:~/

# Connect to EC2 and extract
ssh -i your-key.pem ubuntu@your-ec2-ip
tar -xzf ec2-deployment.tar.gz
cd ec2/
```

### 3. Deploy to EC2

```bash
# Run the deployment script
sudo ./deploy-to-ec2.sh
```

The script will:
- Create web directory at `/var/www/dxb-events`
- Copy your Flutter web files
- Configure nginx
- Set up firewall rules
- Start the web server

## 🌐 Domain Configuration

### 1. Point Your Domain to EC2

Update your domain's DNS records:
```
A Record: your-domain.com → your-ec2-ip
CNAME: www.your-domain.com → your-domain.com
```

### 2. Update Nginx Configuration

```bash
# Edit the nginx configuration
sudo nano /etc/nginx/sites-available/dxb-events

# Replace ${EC2_DOMAIN} with your actual domain
# Example: server_name dxb-events.com www.dxb-events.com;
```

### 3. Test Configuration

```bash
# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

## 🔒 SSL Certificate Setup

### 1. Install SSL with Let's Encrypt

```bash
# Install SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Test automatic renewal
sudo certbot renew --dry-run
```

### 2. Configure Auto-Renewal

```bash
# Add cron job for auto-renewal
sudo crontab -e

# Add this line:
0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Monitoring and Maintenance

### 1. Check Application Status

```bash
# Check nginx status
sudo systemctl status nginx

# Check nginx logs
sudo tail -f /var/log/nginx/dxb-events-access.log
sudo tail -f /var/log/nginx/dxb-events-error.log

# Check system resources
htop
df -h
```

### 2. Health Check Endpoint

Your app includes a health check endpoint:
```bash
curl http://your-domain.com/health
# Should return: healthy
```

## 🔄 Updates and Redeployment

### 1. Update Application

```bash
# On your local machine, rebuild
./scripts/build.sh --env production --target ec2

# Upload new package
scp -i your-key.pem deploy/ec2-deployment.tar.gz ubuntu@your-ec2-ip:~/

# On EC2, backup current version
sudo cp -r /var/www/dxb-events /var/www/dxb-events.backup

# Extract and deploy new version
tar -xzf ec2-deployment.tar.gz
cd ec2/
sudo cp -r ./* /var/www/dxb-events/
sudo chown -R www-data:www-data /var/www/dxb-events

# No nginx restart needed for static files
```

## 🔧 Advanced Configuration

### 1. Custom Environment Variables

Edit the environment file:
```bash
sudo nano /var/www/dxb-events/.env
```

### 2. Performance Optimization

```bash
# Enable gzip compression (already configured in nginx.conf)
# Enable browser caching (already configured)
# Monitor with tools like:
sudo apt install -y htop iotop
```

### 3. Backup Strategy

```bash
# Create backup script
sudo nano /etc/cron.daily/dxb-events-backup

#!/bin/bash
tar -czf /backup/dxb-events-$(date +%Y%m%d).tar.gz /var/www/dxb-events
find /backup -name "dxb-events-*.tar.gz" -mtime +7 -delete

# Make executable
sudo chmod +x /etc/cron.daily/dxb-events-backup
```

## 🐛 Troubleshooting

### Common Issues

1. **502 Bad Gateway**
   ```bash
   # Check nginx error logs
   sudo tail -f /var/log/nginx/error.log
   
   # Restart nginx
   sudo systemctl restart nginx
   ```

2. **Permission Issues**
   ```bash
   # Fix file permissions
   sudo chown -R www-data:www-data /var/www/dxb-events
   sudo chmod -R 755 /var/www/dxb-events
   ```

3. **SSL Certificate Issues**
   ```bash
   # Renew certificate manually
   sudo certbot renew
   
   # Check certificate status
   sudo certbot certificates
   ```

4. **Disk Space Issues**
   ```bash
   # Check disk usage
   df -h
   
   # Clean nginx logs
   sudo journalctl --vacuum-time=7d
   ```

## 📈 Scaling Options

### 1. Load Balancer Setup
- Use AWS Application Load Balancer
- Multiple EC2 instances behind ALB
- Auto Scaling Groups

### 2. CDN Integration
- AWS CloudFront for static assets
- Improved global performance
- Reduced server load

### 3. Database Separation
- RDS for user data (if needed)
- ElastiCache for caching
- S3 for file storage

## 💰 Cost Optimization

### Current Setup Cost (Approximate)
- **t3.micro**: ~$8.50/month
- **t3.small**: ~$17/month
- **Data Transfer**: ~$0.09/GB
- **Domain**: ~$12/year

### Cost Saving Tips
1. Use Reserved Instances for 1-3 year commitments
2. Enable CloudWatch monitoring for resource optimization
3. Use Spot Instances for development environments
4. Regular cleanup of logs and temporary files

## 🚀 Final Verification

After deployment, verify your application:

1. **HTTP Access**: `http://your-ec2-ip`
2. **HTTPS Access**: `https://your-domain.com`
3. **Health Check**: `https://your-domain.com/health`
4. **Mobile Responsiveness**: Test on different devices
5. **Performance**: Use tools like PageSpeed Insights

## 📞 Support

If you encounter issues:

1. Check the deployment logs
2. Verify all prerequisites are met
3. Test with a simple HTML file first
4. Check AWS Security Groups and NACLs
5. Verify domain DNS propagation

---

**🎉 Congratulations!** Your DXB Events application is now running on AWS EC2 with professional-grade configuration including SSL, security headers, and performance optimizations. 