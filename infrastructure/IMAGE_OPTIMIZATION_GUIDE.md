# Image Optimization Solutions for mydscvr

Since we're experiencing encoding errors with large images on mobile, here are several solutions:

## Current Solution (Implemented)

We've implemented client-side optimizations:
- Reduced image quality for mobile browsers
- Limited cache dimensions to 800px width
- Added fallback with even lower quality (400x300)
- Using Flutter's FilterQuality.medium for mobile

## Recommended Long-term Solutions

### 1. AWS CloudFront + Lambda@Edge (Complex but Powerful)

**Pros**: On-the-fly resizing, automatic format conversion
**Cons**: Complex setup, requires Lambda@Edge in us-east-1

```javascript
// Lambda@Edge function would intercept requests and resize
// See infrastructure/image-resize-lambda/index.js
```

### 2. Cloudinary or ImageKit.io (Easiest)

**Pros**: Simple integration, automatic optimization, CDN included
**Cons**: Additional cost, external dependency

```dart
// Example URL transformation
String getOptimizedUrl(String url) {
  if (isMobile) {
    return 'https://res.cloudinary.com/your-cloud/image/fetch/w_800,q_auto,f_auto/$url';
  }
  return url;
}
```

### 3. AWS Serverless Image Handler (Recommended)

AWS provides a complete solution: https://aws.amazon.com/solutions/implementations/serverless-image-handler/

**Setup Steps**:
1. Deploy the CloudFormation template
2. Get the API endpoint
3. Update image URLs to use the handler

```dart
// Transform URLs to use image handler
String getResizedUrl(String originalUrl) {
  final encoded = base64Encode(utf8.encode(JSON.encode({
    "bucket": "mydscvr-event-images",
    "key": "ai-images/example.jpg",
    "edits": {
      "resize": {
        "width": 800,
        "height": 600,
        "fit": "inside"
      },
      "webp": {}
    }
  })));
  return 'https://your-handler.execute-api.region.amazonaws.com/image/$encoded';
}
```

### 4. Pre-generate Thumbnails (Simple)

Generate multiple sizes when uploading:
- Original: Full size
- Large: 1920x1080
- Medium: 800x600
- Thumbnail: 400x300

```python
# In your backend when saving images
def save_image_variants(original_image):
    sizes = {
        'large': (1920, 1080),
        'medium': (800, 600),
        'thumb': (400, 300)
    }
    for size_name, dimensions in sizes.items():
        resized = original_image.resize(dimensions)
        s3.upload(f"{key}_{size_name}.jpg", resized)
```

### 5. Use imgproxy (Self-hosted)

Deploy imgproxy as a Docker container:

```yaml
version: '3'
services:
  imgproxy:
    image: darthsim/imgproxy:latest
    environment:
      IMGPROXY_KEY: your_key
      IMGPROXY_SALT: your_salt
    ports:
      - "8080:8080"
```

## Quick Fix for Current Issue

If encoding errors persist, try:

1. **Limit Image Size in Backend**: 
   ```python
   # When uploading images
   if image.size > 1_000_000:  # 1MB
       image = compress_image(image, quality=85)
   ```

2. **Use Progressive JPEG**:
   ```python
   image.save(output, format='JPEG', progressive=True, optimize=True)
   ```

3. **Convert to WebP**:
   ```dart
   // Request WebP format for mobile
   String getMobileUrl(String url) {
     return url.replace('.jpg', '.webp');
   }
   ```

## Testing Image Optimization

Test your images with:
```bash
# Check image size
curl -I https://d3qhu67mvl81qc.cloudfront.net/ai-images/test.jpg | grep content-length

# Test WebP support
curl -H "Accept: image/webp" https://your-cdn.com/image.jpg
```

## Monitoring

Add logging to track:
- Image load failures by size
- Mobile vs desktop success rates
- Average image sizes served

This will help identify if large images are the root cause.