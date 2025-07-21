# CloudFront CDN Setup for mydscvr Event Images

This directory contains the infrastructure code to set up CloudFront CDN in front of the S3 bucket for better performance and easier CORS configuration.

## Benefits of Using CloudFront

1. **Simplified CORS**: CloudFront handles CORS headers more reliably than S3
2. **Better Performance**: Global edge locations cache images closer to users
3. **Mobile Compatibility**: Resolves encoding errors on mobile browsers
4. **Security**: Hides S3 bucket origin and provides DDoS protection
5. **Cost Efficiency**: Reduces S3 bandwidth costs through caching

## Prerequisites

- AWS CLI installed and configured
- AWS account with appropriate permissions
- S3 bucket `mydscvr-event-images` in `me-central-1` region

## Quick Setup

1. Deploy the CloudFront distribution:
```bash
cd infrastructure
./deploy-cloudfront.sh
```

2. The script will output your CloudFront domain (e.g., `d1234567890.cloudfront.net`)

3. Update your application configuration (see Integration section below)

## Custom Domain Setup (Optional)

To use a custom domain like `cdn.mydscvr.ai`:

1. Create an ACM certificate in `us-east-1` region
2. Update the deployment script with your domain and certificate ARN:
```bash
CUSTOM_DOMAIN="cdn.mydscvr.ai"
ACM_CERTIFICATE_ARN="arn:aws:acm:us-east-1:123456789012:certificate/..."
```

3. After deployment, create a CNAME record pointing to the CloudFront domain

## Integration with Application

After deploying CloudFront, update the application to use the CDN URL:

### Option 1: Environment Variable (Recommended)

1. Set the CDN_URL environment variable:
```bash
export CDN_URL="https://d1234567890.cloudfront.net"
```

2. Update `image_utils.dart` to use CloudFront for S3 images:

```dart
static String getSafeImageUrl(String? originalUrl, {String? eventId}) {
  if (originalUrl == null || originalUrl.isEmpty) {
    return '';
  }
  
  var url = originalUrl;
  
  // Replace S3 URLs with CloudFront URLs
  if (url.contains('mydscvr-event-images.s3')) {
    final cdnUrl = EnvironmentConfig.cdnUrl;
    if (cdnUrl.isNotEmpty) {
      // Extract the path after the bucket name
      final regex = RegExp(r'https://mydscvr-event-images\.s3\.[^/]+\.amazonaws\.com/(.+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        url = '$cdnUrl/${match.group(1)}';
      }
    }
  }
  
  // Rest of the existing logic...
}
```

### Option 2: Direct Configuration

Update the S3 URL replacement in `image_utils.dart`:

```dart
// Replace S3 URLs with CloudFront
if (url.contains('mydscvr-event-images.s3')) {
  url = url.replaceAll(
    RegExp(r'https://mydscvr-event-images\.s3\.[^/]+\.amazonaws\.com/'),
    'https://YOUR_CLOUDFRONT_DOMAIN.cloudfront.net/'
  );
}
```

## CloudFront Configuration Details

The CloudFormation template creates:

- **Origin Access Identity (OAI)**: Secure access to S3 bucket
- **S3 Bucket Policy**: Allows only CloudFront to access objects
- **Cache Behaviors**: Optimized for image delivery
- **CORS Headers**: Configured for mydscvr.ai domains
- **Security Headers**: HSTS, X-Frame-Options, etc.
- **Compression**: Enabled for better performance

## Cache Invalidation

To invalidate cached images:

```bash
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

Or invalidate specific images:

```bash
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/ai-images/specific-image.jpg"
```

## Monitoring

Monitor your CloudFront distribution:

1. **AWS Console**: CloudFront > Distributions > Your Distribution > Monitoring
2. **CloudWatch Metrics**: Requests, bandwidth, error rates
3. **Access Logs**: Enable logging to S3 for detailed analysis

## Troubleshooting

### Images not loading through CloudFront

1. Check S3 bucket policy is applied correctly
2. Verify Origin Access Identity has read permissions
3. Test direct CloudFront URL in browser
4. Check browser console for CORS errors

### CORS errors

1. Verify allowed origins in CloudFormation template
2. Check response headers using curl:
```bash
curl -I -H "Origin: https://mydscvr.ai" https://YOUR_CLOUDFRONT_DOMAIN/ai-images/test.jpg
```

### Cache not updating

1. Create an invalidation for updated objects
2. Use versioned URLs (add query parameters)
3. Check cache headers in CloudFront behavior

## Cost Optimization

- CloudFront pricing varies by region
- Monitor usage in AWS Cost Explorer
- Consider using CloudFront price class to limit edge locations
- Enable CloudFront compression for text-based formats

## Security Best Practices

1. Never expose S3 bucket directly
2. Use Origin Access Identity (OAI)
3. Enable AWS WAF for additional protection
4. Monitor access logs for suspicious activity
5. Use signed URLs for sensitive content (if needed)