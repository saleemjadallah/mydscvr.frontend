/**
 * Script to check which events have placeholder image URLs
 * Run this in browser console on your mydscvr.ai site
 */

async function checkPlaceholderImages() {
    console.log('🔍 Checking for events with placeholder images...');
    
    try {
        // Fetch events from search API
        const response = await fetch('https://mydscvr.ai/api/search/?query=dubai&limit=100', {
            headers: {
                'Accept': 'application/json',
            }
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        const events = data.results || [];
        
        console.log(`Total events fetched: ${events.length}`);
        
        // Check for placeholder images
        const placeholderEvents = [];
        
        events.forEach(event => {
            const hasPlaceholder = 
                (event.image_url && event.image_url.includes('via.placeholder.com')) ||
                (event.image_urls && event.image_urls.some(url => url.includes('via.placeholder.com'))) ||
                (event.images?.ai_generated && event.images.ai_generated.includes('via.placeholder.com')) ||
                (event.images?.primary && event.images.primary.includes('via.placeholder.com'));
            
            if (hasPlaceholder) {
                placeholderEvents.push({
                    id: event.id,
                    title: event.title,
                    image_url: event.image_url,
                    image_urls: event.image_urls,
                    images: event.images
                });
            }
        });
        
        console.log(`\n📊 Results:`);
        console.log(`- Events with placeholder images: ${placeholderEvents.length}`);
        console.log(`- Events with real images: ${events.length - placeholderEvents.length}`);
        
        if (placeholderEvents.length > 0) {
            console.log('\n⚠️ Events with placeholder images:');
            placeholderEvents.forEach((event, index) => {
                console.log(`\n${index + 1}. ${event.title} (ID: ${event.id})`);
                if (event.image_url?.includes('via.placeholder.com')) {
                    console.log(`   - image_url: ${event.image_url}`);
                }
                if (event.image_urls?.some(url => url.includes('via.placeholder.com'))) {
                    console.log(`   - image_urls: ${event.image_urls.filter(url => url.includes('via.placeholder.com')).join(', ')}`);
                }
                if (event.images?.ai_generated?.includes('via.placeholder.com')) {
                    console.log(`   - images.ai_generated: ${event.images.ai_generated}`);
                }
            });
            
            // Generate fix command
            console.log('\n🔧 To fix these in MongoDB, run:');
            console.log(`db.events.updateMany(
    { 
        $or: [
            {"image_url": {$regex: "via\\\\.placeholder\\\\.com"}},
            {"image_urls": {$regex: "via\\\\.placeholder\\\\.com"}},
            {"images.ai_generated": {$regex: "via\\\\.placeholder\\\\.com"}}
        ]
    },
    { 
        $set: {"images.needs_regeneration": true},
        $unset: {"image_url": "", "image_urls": ""}
    }
)`);
        } else {
            console.log('\n✅ No placeholder images found in search results!');
        }
        
    } catch (error) {
        console.error('❌ Error checking placeholder images:', error);
    }
}

// Run the check
checkPlaceholderImages();