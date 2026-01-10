# Yalla Traffic Landing Page

Static landing page for Yalla Traffic app, hosted on Cloudflare Pages at `mydscvr.ai`.

## Pages

| Page | Path | Description |
|------|------|-------------|
| Home | `/` | Main landing page with app overview |
| Privacy Policy | `/privacy` | Privacy policy for App Store |
| Terms of Service | `/terms` | Terms and conditions |
| Support | `/support` | FAQ and contact information |
| 404 | `/404.html` | Custom error page |

## Deployment to Cloudflare Pages

### Option 1: Direct Upload (Recommended for quick setup)

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select your account → Pages
3. Click "Create a project" → "Direct Upload"
4. Upload the contents of this `landing/` directory
5. Set custom domain to `mydscvr.ai`

### Option 2: Git Integration

1. Push this directory to a Git repository
2. In Cloudflare Pages, connect to your repository
3. Build settings:
   - Build command: (leave empty - static site)
   - Build output directory: `/`
4. Add custom domain `mydscvr.ai`

### Connecting Your Domain

After deploying to Cloudflare Pages:

1. Go to your Pages project → "Custom domains"
2. Click "Set up a custom domain"
3. Enter `mydscvr.ai`
4. Cloudflare will automatically configure DNS if your domain is on Cloudflare

If your domain DNS is managed elsewhere:
- Add a CNAME record: `mydscvr.ai` → `your-project.pages.dev`

## Files

```
landing/
├── index.html          # Main landing page
├── privacy/
│   └── index.html      # Privacy Policy
├── terms/
│   └── index.html      # Terms of Service
├── support/
│   └── index.html      # Support & FAQ
├── 404.html            # Custom 404 page
├── _headers            # Security headers
├── _redirects          # URL redirects
└── README.md           # This file
```

## App Store Requirements

This landing page fulfills Apple App Store requirements:

- ✅ **Privacy Policy URL**: `https://mydscvr.ai/privacy`
- ✅ **Terms of Service URL**: `https://mydscvr.ai/terms`
- ✅ **Support URL**: `https://mydscvr.ai/support`
- ✅ **Support Email**: `support@mydscvr.ai`

## Updating Content

Simply edit the HTML files and re-deploy. No build step required.

### Key Files to Update:

- **App Store links**: Update the App Store URL in `index.html` once your app is live
- **Last Updated dates**: Update in privacy and terms pages when making changes
- **Contact email**: Currently set to `support@mydscvr.ai`

## Design System

Uses the Yalla design system colors:

| Color | Hex | Usage |
|-------|-----|-------|
| Coral Orange | `#FF6B6B` | Primary, CTAs |
| Soft Teal | `#10B981` | Success, positive |
| Warm Yellow | `#F59E0B` | Attention |
| Surface Cream | `#FAF7F2` | Backgrounds |

Font: [Outfit](https://fonts.google.com/specimen/Outfit) from Google Fonts
