'use strict';

const querystring = require('querystring');

// Lambda@Edge function to handle image resizing via URL redirection
exports.handler = async (event, context) => {
    const request = event.Records[0].cf.request;
    const params = querystring.parse(request.querystring);
    
    // Check if resize parameters are present
    if (params.w || params.h || params.q) {
        // For S3 origins, we'll use a different approach
        // We'll modify the request to add headers that our application can use
        
        // Add custom headers to pass resize parameters
        request.headers['x-resize-width'] = [{
            key: 'X-Resize-Width',
            value: params.w || 'auto'
        }];
        
        request.headers['x-resize-height'] = [{
            key: 'X-Resize-Height', 
            value: params.h || 'auto'
        }];
        
        request.headers['x-resize-quality'] = [{
            key: 'X-Resize-Quality',
            value: params.q || '85'
        }];
        
        // For mobile detection
        const userAgent = request.headers['user-agent'] ? request.headers['user-agent'][0].value : '';
        const isMobile = /mobile|android|iphone|ipad/i.test(userAgent);
        
        // Auto-resize for mobile if no params specified
        if (isMobile && !params.w && !params.h) {
            request.headers['x-resize-width'] = [{
                key: 'X-Resize-Width',
                value: '800'
            }];
            request.headers['x-resize-quality'] = [{
                key: 'X-Resize-Quality',
                value: '75'
            }];
        }
    }
    
    return request;
};