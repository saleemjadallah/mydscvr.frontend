#!/usr/bin/env python3
"""
Script to migrate images from S3 to Cloudinary
This can be used to upload images directly or use Cloudinary's fetch feature
"""

import os
import sys
import boto3
import requests
from urllib.parse import quote
import json

# Cloudinary configuration
CLOUDINARY_CLOUD_NAME = "dikjgzjsq"
CLOUDINARY_API_KEY = "841946151566362"
CLOUDINARY_API_SECRET = "EVmwtCfV8W3RCYjyGjM_kCwKkpo"

# S3 configuration
S3_BUCKET = "mydscvr-event-images"
S3_REGION = "us-east-1"  # Update if different

def list_s3_images():
    """List all images in the S3 bucket"""
    s3 = boto3.client('s3', region_name=S3_REGION)
    
    images = []
    paginator = s3.get_paginator('list_objects_v2')
    
    for page in paginator.paginate(Bucket=S3_BUCKET):
        if 'Contents' in page:
            for obj in page['Contents']:
                key = obj['Key']
                # Filter for image files
                if key.lower().endswith(('.jpg', '.jpeg', '.png', '.webp', '.gif')):
                    s3_url = f"https://{S3_BUCKET}.s3.{S3_REGION}.amazonaws.com/{key}"
                    images.append({
                        'key': key,
                        's3_url': s3_url,
                        'size': obj['Size']
                    })
    
    return images

def upload_to_cloudinary(image_url, public_id=None):
    """Upload image to Cloudinary using the upload API"""
    import cloudinary
    import cloudinary.uploader
    
    cloudinary.config(
        cloud_name=CLOUDINARY_CLOUD_NAME,
        api_key=CLOUDINARY_API_KEY,
        api_secret=CLOUDINARY_API_SECRET
    )
    
    try:
        # Upload with automatic format and quality
        result = cloudinary.uploader.upload(
            image_url,
            public_id=public_id,
            overwrite=True,
            resource_type="image",
            transformation=[
                {'quality': 'auto'},
                {'fetch_format': 'auto'}
            ]
        )
        return result['secure_url']
    except Exception as e:
        print(f"Error uploading {image_url}: {e}")
        return None

def generate_cloudinary_fetch_urls(s3_images):
    """Generate Cloudinary fetch URLs for S3 images"""
    fetch_urls = []
    
    for img in s3_images:
        # Create fetch URL - Cloudinary will fetch from S3 on first request
        encoded_url = quote(img['s3_url'], safe='')
        
        # Basic fetch URL
        fetch_url = f"https://res.cloudinary.com/{CLOUDINARY_CLOUD_NAME}/image/fetch/{encoded_url}"
        
        # Optimized fetch URL with transformations
        optimized_url = f"https://res.cloudinary.com/{CLOUDINARY_CLOUD_NAME}/image/fetch/f_auto,q_auto/{encoded_url}"
        
        # Mobile optimized URL
        mobile_url = f"https://res.cloudinary.com/{CLOUDINARY_CLOUD_NAME}/image/fetch/f_auto,q_auto,w_800/{encoded_url}"
        
        fetch_urls.append({
            'key': img['key'],
            's3_url': img['s3_url'],
            'cloudinary_fetch': fetch_url,
            'cloudinary_optimized': optimized_url,
            'cloudinary_mobile': mobile_url
        })
    
    return fetch_urls

def test_cloudinary_urls():
    """Test a few Cloudinary URLs to ensure they work"""
    test_urls = [
        # Test fetch from S3
        f"https://res.cloudinary.com/{CLOUDINARY_CLOUD_NAME}/image/fetch/f_auto,q_auto/https://mydscvr-event-images.s3.us-east-1.amazonaws.com/ai-images/test.jpg",
        
        # Test direct upload (if you've uploaded any)
        f"https://res.cloudinary.com/{CLOUDINARY_CLOUD_NAME}/image/upload/v1/samples/cloudinary-icon"
    ]
    
    print("\nTesting Cloudinary URLs:")
    for url in test_urls:
        try:
            response = requests.head(url, timeout=5)
            status = "✅ OK" if response.status_code == 200 else f"❌ {response.status_code}"
            print(f"{status} - {url}")
        except Exception as e:
            print(f"❌ Error - {url}: {e}")

def main():
    print("🌩️  Cloudinary Migration Tool")
    print(f"Cloud Name: {CLOUDINARY_CLOUD_NAME}")
    print(f"S3 Bucket: {S3_BUCKET}\n")
    
    # Option 1: Generate fetch URLs (recommended - no upload needed)
    print("Option 1: Generate Cloudinary Fetch URLs")
    print("This doesn't upload images but uses Cloudinary as a proxy\n")
    
    try:
        images = list_s3_images()
        print(f"Found {len(images)} images in S3")
        
        if images:
            fetch_urls = generate_cloudinary_fetch_urls(images[:5])  # Show first 5 as example
            
            print("\nExample Cloudinary Fetch URLs:")
            for item in fetch_urls:
                print(f"\nOriginal S3: {item['s3_url']}")
                print(f"Cloudinary Mobile: {item['cloudinary_mobile']}")
            
            # Save all URLs to file
            with open('cloudinary_urls_mapping.json', 'w') as f:
                all_urls = generate_cloudinary_fetch_urls(images)
                json.dump(all_urls, f, indent=2)
            print(f"\n✅ Saved all URL mappings to cloudinary_urls_mapping.json")
            
    except Exception as e:
        print(f"Error listing S3 images: {e}")
        print("Make sure you have AWS credentials configured")
    
    # Test URLs
    test_cloudinary_urls()
    
    print("\n📱 Mobile Implementation:")
    print("The app is now configured to automatically use Cloudinary's fetch API")
    print("Images will be automatically optimized for mobile with:")
    print("- Automatic format selection (WebP/JPEG)")
    print("- Automatic quality optimization")
    print("- Width limited to 800px for mobile")

if __name__ == "__main__":
    main()