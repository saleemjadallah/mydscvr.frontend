# 🚀 Frontend Deployment Guide

*Last updated: 2025-01-23 - Testing automated GitHub Actions deployment to Netlify - CI/CD pipeline active*

## GitHub Secrets Configuration

All secrets are configured in the GitHub repository for secure deployment to Netlify.

### Required GitHub Secrets

The following **17 secrets** are configured:

#### Core Application Secrets
- `GOOGLE_CLIENT_ID` - Google OAuth client ID for authentication
- `API_BASE_URL` - Production backend API URL
- `BACKEND_URL` - Main backend server URL
- `DATA_COLLECTION_URL` - Data collection service URL

#### Fallback URLs (for staging/testing)
- `FALLBACK_API_URL` - Staging backend API URL
- `FALLBACK_DATA_URL` - Staging data collection URL

#### Development URLs
- `DEV_API_URL` - Local development API URL
- `DEV_DATA_URL` - Local development data URL

#### Build Configuration
- `ENABLE_LOGS` - Enable debug logging (false for production)
- `ENABLE_PERFORMANCE_OVERLAY` - Show performance overlay (false for production)

#### Deployment Configuration
- `CUSTOM_DOMAIN` - Custom domain for the application
- `CDN_URL` - CDN URL for static assets

#### Netlify Integration
- `NETLIFY_AUTH_TOKEN` - Netlify personal access token
- `NETLIFY_SITE_ID` - Netlify site identifier

#### Security & Monitoring
- `CSP_POLICY` - Content Security Policy directives
- `LOG_LEVEL` - Application logging level
- `EC2_DOMAIN` - EC2 domain configuration

## Deployment Process

### Automatic Deployment
- Push to `main` branch triggers automatic deployment to Netlify
- GitHub Actions creates environment file from secrets
- Flutter web app built with production optimizations
- Deployed to Netlify with proper redirects and headers
- Pull requests create preview deployments

### Manual Deployment
```bash
# Trigger manual deployment
gh workflow run deploy-frontend.yml
```

### Environment-Specific Builds
```bash
# Deploy to staging
gh workflow run deploy-frontend.yml -f environment=staging

# Deploy to development
gh workflow run deploy-frontend.yml -f environment=development
```

## Security Features

✅ **All secrets stored in GitHub Secrets**  
✅ **No hardcoded credentials in code**  
✅ **Environment-based configuration**  
✅ **Automated security scanning**  
✅ **CSP headers for XSS protection**  
✅ **HTTPS-only deployment**  
✅ **Secure token handling with Flutter Secure Storage**

## Build Optimizations

- **Release Mode**: Optimized production build
- **Environment Variables**: Secure configuration injection
- **Asset Compression**: Optimized images and fonts
- **Code Generation**: Automated serialization code
- **Dependency Resolution**: Clean package management

## Quality Assurance

### Automated Checks
- **Security Scan**: Detects hardcoded secrets
- **Code Formatting**: Dart format compliance
- **Static Analysis**: Flutter analyze
- **Unit Tests**: Automated test execution
- **Performance**: Build size monitoring

### Pre-deployment Verification
- ✅ Environment variables properly injected
- ✅ Google OAuth configuration secure
- ✅ API endpoints correctly configured
- ✅ No hardcoded secrets in codebase
- ✅ Build artifacts optimized

## Local Development

1. **Environment Setup**: 
   ```bash
   cp Frontend.env.example Frontend.env
   # Fill in your development values
   ```

2. **Never commit the actual `Frontend.env` file**

3. **Use environment-specific build commands**:
   ```bash
   flutter build web --dart-define=ENVIRONMENT=development
   ```

## Monitoring

- **Netlify Dashboard**: Build status and deployment logs
- **GitHub Actions**: CI/CD pipeline monitoring  
- **Performance Metrics**: Bundle size and load times
- **Error Tracking**: Automated error detection
- **Security Alerts**: Dependency vulnerability scanning

## Production URLs

🔗 **Production Site**: https://mydscvr.ai  
📊 **Netlify Dashboard**: https://app.netlify.com/sites/[SITE_ID]  
🔧 **GitHub Actions**: https://github.com/saleemjadallah/mydscvr.frontend/actions  

---

**Secure, optimized, and production-ready Flutter web deployment!** 🔐✨