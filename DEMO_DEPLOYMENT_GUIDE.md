# Demo Deployment Guide for mydscvr.ai

This guide explains how to deploy the ad-free demo version of mydscvr.ai to `demo.mydscvr.ai` with password protection.

## Overview

You now have two versions of your site:
- **Production**: `mydscvr.ai` (with Google AdSense ads)
- **Demo**: `demo.mydscvr.ai` (clean, ad-free version with password protection)

## Files Created

### 1. Ad-Free HTML Template
- **File**: `web/index_demo.html`
- **Changes**: Removed Google AdSense script and ad header banner
- **Usage**: Use this as the main HTML file for demo deployment

### 2. Clean Ad Placeholder Widgets
- **File**: `lib/widgets/common/ad_placeholder.dart`
- **New Widgets**:
  - `CleanAdPlaceholder`: Shows nothing (invisible)
  - `MarketingContentPlaceholder`: Shows branded marketing content

### 3. Demo Home Screen
- **File**: `lib/features/home/home_screen_demo.dart`
- **Changes**: Uses `CleanAdPlaceholder` instead of real ads
- **Features**: All functionality preserved, just no ads

### 4. Demo Configuration
- **File**: `lib/config/demo_config.dart`
- **Purpose**: Manages demo vs production mode switching

## GitHub Secrets Configuration

The following secrets are configured in your repository for secure demo deployment:

| Secret Name | Value | Purpose |
|-------------|-------|---------|
| `DEMO_USERNAME` | `demo` | Demo site username |
| `DEMO_PASSWORD` | `MyDscvr2024` | Demo site password |
| `NETLIFY_AUTH_TOKEN` | `[Your Netlify token]` | Netlify deployment auth |
| `NETLIFY_DEMO_SITE_ID` | `[Your demo site ID]` | Target demo site |

These are injected during the build process and never exposed in the codebase.

## Deployment Steps

### Step 1: Build Demo Version

#### Automated via GitHub Actions (Recommended)
Demo deployment happens automatically when you push to main branch. Credentials are securely managed via GitHub Secrets.

#### Manual Build (if needed)
```bash
# Navigate to your Flutter web project
cd frontend-repo/dxb_events_web

# Build for demo with credentials from environment
flutter build web --dart-define=DEMO_MODE=true --dart-define=DEMO_USERNAME=demo --dart-define=DEMO_PASSWORD=MyDscvr2024

# Copy the demo HTML file to replace the default
cp web/index_demo.html build/web/index.html
```

### Step 2: Setup Demo Subdomain

#### Option A: Using Netlify

1. **Create New Site**:
   - Go to Netlify dashboard
   - Click "Add new site" → "Deploy manually"
   - Upload the `build/web` folder
   - Set custom domain to `demo.mydscvr.ai`

2. **Add Password Protection**:
   - Go to Site settings → Access control
   - Enable "Password protection"
   - Set password: `[YOUR_SECURE_PASSWORD]` (choose a strong password)

#### Option B: Using Vercel

1. **Deploy to Vercel**:
   ```bash
   # Install Vercel CLI if not already installed
   npm i -g vercel
   
   # Deploy from build folder
   cd build/web
   vercel --prod
   ```

2. **Set Custom Domain**:
   - Add `demo.mydscvr.ai` in Vercel dashboard
   - Configure DNS records

3. **Add Password Protection**:
   Create `vercel.json` in the build/web folder:
   ```json
   {
     "functions": {
       "pages/api/auth.js": {
         "runtime": "nodejs18.x"
       }
     },
     "rewrites": [
       {
         "source": "/(.*)",
         "destination": "/api/auth"
       }
     ]
   }
   ```

#### Option C: Using Your Current Hosting Provider

1. **Upload Demo Build**:
   - Upload `build/web` contents to a new subdomain folder
   - Point `demo.mydscvr.ai` to this folder

2. **Add HTTP Basic Auth**:
   Create `.htaccess` file in the demo folder:
   ```apache
   AuthType Basic
   AuthName "Demo Access Required"
   AuthUserFile /path/to/.htpasswd
   Require valid-user
   ```

   Create `.htpasswd` file:
   ```bash
   # Generate password hash
   htpasswd -c .htpasswd demo
   # Enter your chosen secure password
   ```

### Step 3: Configure DNS

Add a CNAME record pointing `demo.mydscvr.ai` to your hosting provider:

```
Type: CNAME
Name: demo
Value: your-hosting-provider.com
TTL: 300
```

### Step 4: Update Backend (If Needed)

Your demo site will use the same backend API (`api.mydscvr.ai`), so no backend changes are required. All functionality will work identically.

## Testing

1. **Access Demo Site**: https://demo.mydscvr.ai
2. **Enter Credentials**:
   - Username: `demo`
   - Password: `MyDscvr2024`
3. **Verify Functionality**:
   - Search works
   - User authentication works
   - All features function normally
   - No ads are displayed

## Demo vs Production Comparison

| Feature | Production | Demo |
|---------|-----------|------|
| Google AdSense | ✅ Enabled | ❌ Disabled |
| Ad Placeholders | ✅ Visible | ❌ Hidden |
| User Authentication | ✅ Full | ✅ Full |
| Event Search | ✅ Full | ✅ Full |
| Event Saving | ✅ Full | ✅ Full |
| AI Recommendations | ✅ Full | ✅ Full |
| Password Protection | ❌ No | ✅ Yes |
| Analytics Tracking | ✅ Full | ✅ Full* |

*Analytics still work for demo to track demo usage

## Updating Demo Site

To update the demo site with new features:

1. **Make Changes** to your main codebase
2. **Build Demo Version**:
   ```bash
   flutter build web --dart-define=DEMO_MODE=true
   cp web/index_demo.html build/web/index.html
   ```
3. **Deploy Updated Build** to demo hosting

## Password Management

Demo access credentials:
- **URL**: https://demo.mydscvr.ai
- **Username**: demo
- **Password**: MyDscvr2024 (stored in GitHub Secrets)

To change the password, update your hosting provider's authentication settings.

## Using for Marketing

Perfect use cases for the demo site:
- **Investor Presentations**: Clean, professional interface
- **Partner Demonstrations**: Full functionality without ads
- **Marketing Videos**: Record clean interface footage
- **App Store Screenshots**: Use for promotional materials
- **Press Demonstrations**: Professional appearance for media

## Maintenance

- **Both sites share the same backend**, so database updates apply to both
- **Only frontend differs** between production and demo
- **Update both** when making significant UI changes
- **Monitor demo usage** through analytics to see marketing effectiveness

## Security Notes

- Demo site has basic password protection
- Uses HTTPS for secure access
- Same security measures as production site
- Password can be shared with partners/investors safely

## Support

If you need to:
- Change the demo password
- Add more sophisticated authentication
- Add IP whitelisting
- Set up temporary demo links

Let me know and I can help implement these features!