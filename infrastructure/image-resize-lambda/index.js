'use strict';

const AWS = require('aws-sdk');
const Sharp = require('sharp');

const S3 = new AWS.S3();
const BUCKET = 'mydscvr-event-images';

exports.handler = async (event, context, callback) => {
    // Get the request from CloudFront
    const request = event.Records[0].cf.request;
    const response = event.Records[0].cf.response;
    
    // Parse the querystring for resize parameters
    const params = new URLSearchParams(request.querystring);
    const width = parseInt(params.get('w')) || null;
    const height = parseInt(params.get('h')) || null;
    const quality = parseInt(params.get('q')) || 85;
    const format = params.get('f') || 'jpeg';
    
    // Only process image resize requests
    if (!width && !height) {
        // No resize requested, pass through
        callback(null, response);
        return;
    }
    
    // Extract the S3 key from the URI
    const key = decodeURIComponent(request.uri.substring(1));
    
    try {
        // Get the original image from S3
        const s3Object = await S3.getObject({
            Bucket: BUCKET,
            Key: key
        }).promise();
        
        // Resize the image using Sharp
        let sharpInstance = Sharp(s3Object.Body);
        
        // Get metadata to preserve aspect ratio
        const metadata = await sharpInstance.metadata();
        
        // Calculate dimensions preserving aspect ratio
        let resizeOptions = {};
        if (width && height) {
            resizeOptions = { width, height, fit: 'inside', withoutEnlargement: true };
        } else if (width) {
            resizeOptions = { width, withoutEnlargement: true };
        } else if (height) {
            resizeOptions = { height, withoutEnlargement: true };
        }
        
        // Apply resize and format conversion
        let processedImage = sharpInstance.resize(resizeOptions);
        
        // Convert format if needed
        if (format === 'webp') {
            processedImage = processedImage.webp({ quality });
        } else if (format === 'jpeg' || format === 'jpg') {
            processedImage = processedImage.jpeg({ quality, progressive: true });
        } else if (format === 'png') {
            processedImage = processedImage.png({ quality });
        }
        
        // Get the processed image buffer
        const processedBuffer = await processedImage.toBuffer();
        
        // Return the resized image
        const resizedResponse = {
            status: '200',
            statusDescription: 'OK',
            headers: {
                'content-type': [{
                    key: 'Content-Type',
                    value: `image/${format === 'jpg' ? 'jpeg' : format}`
                }],
                'cache-control': [{
                    key: 'Cache-Control',
                    value: 'public, max-age=31536000'
                }],
                'x-resized': [{
                    key: 'X-Resized',
                    value: 'true'
                }]
            },
            body: processedBuffer.toString('base64'),
            bodyEncoding: 'base64'
        };
        
        callback(null, resizedResponse);
        
    } catch (error) {
        console.error('Error processing image:', error);
        // Return original response on error
        callback(null, response);
    }
};