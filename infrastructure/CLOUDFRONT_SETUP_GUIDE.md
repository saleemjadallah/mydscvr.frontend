# CloudFront Setup Guide for mydscvr Event Images

Since AWS CLI is not available, here's how to set up CloudFront manually through the AWS Console.

## Step 1: Login to AWS Console

1. Go to https://console.aws.amazon.com/
2. Login with your AWS credentials
3. Make sure you're in the **US East (N. Virginia) us-east-1** region (CloudFront is a global service but must be created in us-east-1)

## Step 2: Create CloudFront Distribution

1. Navigate to **CloudFront** service
2. Click **Create Distribution**
3. Configure the following settings:

### Origin Settings
- **Origin Domain**: `mydscvr-event-images.s3.me-central-1.amazonaws.com`
- **Origin Path**: Leave empty
- **Name**: `S3-mydscvr-event-images`
- **S3 bucket access**: 
  - Select **Yes use OAI (Origin Access Identity)**
  - Click **Create new OAI**
  - Name it: `mydscvr-event-images-oai`
  - Select **Yes, update the bucket policy**

### Default Cache Behavior
- **Viewer Protocol Policy**: Redirect HTTP to HTTPS
- **Allowed HTTP Methods**: GET, HEAD, OPTIONS
- **Cache Policy**: Select **CachingOptimized** (Managed)
- **Origin Request Policy**: Select **CORS-S3Origin** (Managed)
- **Response Headers Policy**: Select **SimpleCORS** (Managed)

### Distribution Settings
- **Price Class**: Use all edge locations (best performance)
- **AWS WAF web ACL**: None
- **Alternate Domain Names (CNAMEs)**: Leave empty (unless you have a custom domain)
- **Custom SSL Certificate**: Default CloudFront Certificate
- **Default Root Object**: Leave empty
- **Enable IPv6**: Yes

### Tags (Optional)
- Add tag: `Environment` = `Production`
- Add tag: `Application` = `mydscvr`

4. Click **Create Distribution**

## Step 3: Wait for Deployment

CloudFront distribution creation takes 15-20 minutes. The status will change from "Deploying" to "Deployed" when ready.

## Step 4: Update S3 Bucket Policy

If CloudFront didn't automatically update the bucket policy:

1. Go to S3 service
2. Find bucket: `mydscvr-event-images`
3. Go to **Permissions** tab
4. Edit **Bucket Policy**
5. Add this policy (replace `YOUR-OAI-ID` with the actual OAI ID from CloudFront):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity YOUR-OAI-ID"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::mydscvr-event-images/*"
        }
    ]
}
```

## Step 5: Test CloudFront

Once the distribution is deployed:

1. Copy your CloudFront domain name (e.g., `d1234567890.cloudfront.net`)
2. Test an image URL:
   - Original: `https://mydscvr-event-images.s3.me-central-1.amazonaws.com/ai-images/example.jpg`
   - CloudFront: `https://d1234567890.cloudfront.net/ai-images/example.jpg`
3. Open `test-cloudfront.html` in a browser and enter your CloudFront domain

## Step 6: Update Application

### Option 1: Environment Variable (Recommended)

When building the Flutter app:

```bash
flutter build web --dart-define=CDN_URL=https://YOUR-CLOUDFRONT-DOMAIN.cloudfront.net
```

### Option 2: Update Code

Edit `/dxb_events_web/lib/core/config/environment_config.dart`:

```dart
static const String cdnUrl = String.fromEnvironment(
  'CDN_URL',
  defaultValue: 'https://YOUR-CLOUDFRONT-DOMAIN.cloudfront.net',
);
```

## Step 7: Deploy Updated Application

1. Build the Flutter app with the new CDN URL
2. Deploy to your server
3. Test image loading on mobile devices

## Alternative: Using AWS CloudFormation

If you later get AWS CLI access, you can use the provided CloudFormation template:

```bash
cd infrastructure
./deploy-cloudfront-local.sh
```

## Monitoring

After setup, monitor your CloudFront distribution:

1. Go to CloudFront Console
2. Select your distribution
3. View the **Monitoring** tab for:
   - Requests
   - Data transfer
   - Error rate
   - Cache hit rate

## Troubleshooting

### Images not loading
- Check CloudFront distribution status is "Deployed"
- Verify S3 bucket policy includes CloudFront OAI
- Test CloudFront URL directly in browser
- Check browser console for errors

### CORS errors
- Ensure you selected CORS-S3Origin request policy
- Verify SimpleCORS response headers policy is applied
- Clear browser cache and retry

### Mobile issues
- Ensure CDN_URL is properly set in Flutter build
- Check that cache-busting parameters are working
- Test on actual mobile devices, not just browser emulation

## Cost Considerations

CloudFront pricing includes:
- Data transfer out to internet
- HTTP/HTTPS requests
- No charge for data transfer from S3 to CloudFront

Monitor costs in AWS Cost Explorer under CloudFront service.