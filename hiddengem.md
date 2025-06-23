# ===============================================
# DXB EVENTS: HIDDEN GEMS DISCOVERY FEATURE
# ===============================================

"""
CONCEPT: Daily Hidden Gem Discovery
An exclusive, gamified feature that reveals one unique Dubai event per day.
Creates anticipation, exclusivity, and discovery joy for premium users.

FRONTEND PLACEMENT STRATEGY:
Based on modern design trends, place the Hidden Gem feature as:
1. Hero banner replacement on homepage (rotating with main banner)
2. Floating "mystery box" icon in bottom-right corner
3. Dedicated section between "Featured Events" and "Trending Events"
4. Push notification trigger for daily reveals
"""

import json
from datetime import datetime, timedelta
import httpx
from typing import Dict, List, Optional

class HiddenGemsDiscovery:
    def __init__(self, perplexity_api_key: str):
        self.api_key = perplexity_api_key
        self.base_url = "https://api.perplexity.ai"
    
    def create_hidden_gems_prompt(self, all_events: List[Dict], previous_gems: List[str]) -> Dict:
        """
        Create enhanced prompt for identifying daily hidden gems
        """
        
        # Convert events to text for analysis
        events_text = "\n".join([
            f"Event: {event.get('title', 'N/A')} | "
            f"Venue: {event.get('venue_name', 'N/A')} | "
            f"Price: AED {event.get('min_price', 0)}-{event.get('max_price', 0)} | "
            f"Description: {event.get('description', 'N/A')[:200]}..."
            for event in all_events[:50]  # Limit to 50 events for token efficiency
        ])
        
        previous_gems_text = ", ".join(previous_gems[-7:])  # Last 7 days
        
        system_prompt = """You are a Dubai Hidden Gems Discovery Specialist.
        You excel at identifying unique, lesser-known events that offer exceptional experiences.
        You understand what makes an event special, exclusive, and worth discovering."""
        
        main_prompt = f"""
TASK: Identify ONE exceptional hidden gem event from TOMORROW's Dubai events.

CONTEXT: This is for an exclusive "Hidden Gem of the Day" feature on DXB Events platform. 
Users love discovering unique, lesser-known experiences that make them feel "in the know" about Dubai.

EVENTS TO ANALYZE:
{events_text}

PREVIOUS HIDDEN GEMS (don't repeat):
{previous_gems_text}

HIDDEN GEM CRITERIA:
1. UNIQUENESS: Not your typical mainstream event
2. EXCLUSIVITY: Limited capacity, special access, or unique venue
3. AUTHENTIC EXPERIENCE: Genuine cultural, artistic, or experiential value
4. DISCOVERY FACTOR: Something people wouldn't easily find elsewhere
5. INSTAGRAM-WORTHY: Visually interesting or memorable
6. VALUE PROPOSITION: Great experience relative to cost

SCORING FACTORS (Rate 1-10 each):
- Uniqueness Level: How different is this from typical events?
- Exclusivity Factor: Limited spots, special access, unique venue?
- Cultural Significance: Authentic Dubai/UAE cultural experience?
- Photo Opportunity: Visually stunning or memorable moments?
- Insider Knowledge: Would locals consider this a "hidden gem"?
- Value for Money: Exceptional experience for the price?

AVOID:
- Large commercial events
- Chain restaurant events
- Common shopping mall activities
- Overly touristy experiences
- Events everyone already knows about

RETURN FORMAT:
Return ONLY valid JSON in this structure:
{{
  "hidden_gem": {{
    "event_id": "extracted_event_id",
    "gem_title": "Enchanting Secret Rooftop Cinema Under Dubai Stars",
    "gem_tagline": "A cinematic experience most Dubai residents have never discovered",
    "mystery_teaser": "🎭 Tonight, watch classic films under the stars at a secret location known only to film enthusiasts...",
    "revealed_description": "Experience cinema like never before at this intimate rooftop screening in old Dubai. Limited to 40 people, this hidden venue offers vintage films, traditional snacks, and breathtaking city views.",
    "why_hidden_gem": "This pop-up cinema operates only monthly in a heritage building most people pass by daily. The location is shared only 24 hours before the event.",
    "exclusivity_level": "HIGH",
    "gem_score": 92,
    "scoring_breakdown": {{
      "uniqueness": 9,
      "exclusivity": 10,
      "cultural_significance": 8,
      "photo_opportunity": 9,
      "insider_knowledge": 10,
      "value_for_money": 8
    }},
    "discovery_hints": [
      "🏛️ Hidden in a heritage building",
      "🎬 Film buffs' best-kept secret",
      "⭐ Under 50 people know about this",
      "📱 No social media advertising"
    ],
    "insider_tips": [
      "Arrive early for the best cushion spots",
      "Bring a light jacket - it gets breezy on the rooftop",
      "The traditional snacks are made by local families"
    ],
    "gem_category": "Cultural Cinema",
    "experience_level": "Intimate",
    "best_for": ["couples", "film_enthusiasts", "culture_seekers"],
    "gem_date": "{datetime.now().isoformat()}",
    "reveal_time": "Daily at 12:00 PM UAE time"
  }},
  "analysis_metadata": {{
    "total_events_analyzed": 50,
    "gem_selection_confidence": "high",
    "alternative_gems_count": 2,
    "processing_timestamp": "{datetime.now().isoformat()}"
  }}
}}

IMPORTANT:
- Only select events happening TOMORROW or in the next 3 days
- Choose events with genuine hidden gem qualities
- Create compelling, mysterious copy that builds anticipation
- Ensure the selected event hasn't been featured in the last 7 days
- Focus on authentic Dubai experiences over commercial ones
"""
        
        return {
            "system_prompt": system_prompt,
            "main_prompt": main_prompt
        }
    
    async def discover_daily_gem(self, all_events: List[Dict], previous_gems: List[str]) -> Dict:
        """
        Use Perplexity to identify and create compelling copy for daily hidden gem
        """
        prompts = self.create_hidden_gems_prompt(all_events, previous_gems)
        
        payload = {
            "model": "llama-3.1-sonar-small-128k-online",
            "messages": [
                {"role": "system", "content": prompts["system_prompt"]},
                {"role": "user", "content": prompts["main_prompt"]}
            ],
            "max_tokens": 2000,
            "temperature": 0.3,  # Slightly higher for creative copy
            "response_format": {"type": "json_object"}
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json"
                },
                json=payload,
                timeout=30.0
            )
            
            if response.status_code == 200:
                result = response.json()
                content = result['choices'][0]['message']['content']
                return json.loads(content)
            else:
                raise Exception(f"Perplexity API error: {response.status_code}")

# ===============================================
# FRONTEND IMPLEMENTATION GUIDELINES
# ===============================================

"""
HIDDEN GEMS UI/UX DESIGN SPECIFICATIONS

1. HOMEPAGE INTEGRATION
   Position: Between "Featured Events" and "categories"
   Style: Mystery card with gradient background and subtle animations
   
2. MYSTERY REVEAL INTERACTION
   - Initial State: Blurred card with "🔮 Today's Hidden Gem" 
   - Hover Effect: Subtle glow and "Click to Reveal" animation
   - Click Action: Smooth blur-to-clear transition with confetti effect
   - Revealed State: Full gem details with sharing options

3. VISUAL DESIGN ELEMENTS
   - Background: Gradient from deep purple to gold (Dubai mystique)
   - Typography: Elegant serif for gem title, clean sans-serif for details
   - Icons: Sparkle effects, gem icons, mystery box imagery
   - Animation: Smooth reveal transitions, floating particles

4. GAMIFICATION FEATURES
   - Daily streak counter for users who check gems daily
   - "Gem Hunter" badge system
   - Share functionality with custom graphics
   - "Remind me tomorrow" notification setting

5. RESPONSIVE DESIGN
   - Mobile: Full-width card with touch-friendly reveal
   - Desktop: Elegant card with hover effects
   - Tablet: Balanced layout maintaining mystique

CSS IMPLEMENTATION EXAMPLE:
"""

css_example = '''
.hidden-gem-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  padding: 30px;
  margin: 40px 0;
  position: relative;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
}

.hidden-gem-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 20px 40px rgba(0,0,0,0.1);
}

.gem-mystery-overlay {
  backdrop-filter: blur(10px);
  transition: opacity 0.5s ease;
}

.gem-mystery-overlay.revealed {
  opacity: 0;
  pointer-events: none;
}

.gem-content {
  opacity: 0;
  transition: opacity 0.5s ease 0.3s;
}

.gem-content.revealed {
  opacity: 1;
}

.sparkle-animation {
  position: absolute;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

@keyframes sparkle {
  0%, 100% { opacity: 0; transform: scale(0); }
  50% { opacity: 1; transform: scale(1); }
}
'''

"""
BACKEND INTEGRATION ENDPOINTS

POST /api/hidden-gems/daily
- Trigger daily gem discovery process
- Returns: Selected gem with metadata

GET /api/hidden-gems/current
- Fetch today's hidden gem
- Returns: Current gem (revealed or mystery state based on user)

POST /api/hidden-gems/reveal/{gem_id}
- Mark gem as revealed for user
- Track engagement analytics
- Returns: Full gem details

GET /api/hidden-gems/streak/{user_id}
- Get user's discovery streak
- Returns: Streak count and achievements

ANALYTICS TRACKING:
- Gem reveal rate (% of users who click)
- Sharing frequency
- User return rate after discovery
- Gem quality feedback scores
"""

# ===============================================
# USAGE EXAMPLE
# ===============================================

async def main():
    # Initialize the Hidden Gems Discovery
    gems_discovery = HiddenGemsDiscovery("your-perplexity-api-key")
    
    # Sample events data (from your main scraping pipeline)
    sample_events = [
        {
            "event_id": "unique_rooftop_cinema_001",
            "title": "Secret Rooftop Cinema Night",
            "venue_name": "Heritage Building, Al Fahidi",
            "min_price": 75,
            "max_price": 75,
            "description": "Intimate outdoor cinema experience in historic Dubai with vintage films and traditional snacks. Limited to 40 guests.",
            "start_date": "2025-06-15T20:00:00",
            "categories": ["cultural", "entertainment", "outdoor"]
        },
        # ... more events
    ]
    
    # Previous gems to avoid repetition
    previous_gems = [
        "Underground Art Gallery Opening",
        "Secret Spice Market Tour",
        "Rooftop Yoga at Sunrise"
    ]
    
    try:
        # Discover today's hidden gem
        hidden_gem = await gems_discovery.discover_daily_gem(sample_events, previous_gems)
        
        print("🎉 TODAY'S HIDDEN GEM DISCOVERED!")
        print(f"Title: {hidden_gem['hidden_gem']['gem_title']}")
        print(f"Score: {hidden_gem['hidden_gem']['gem_score']}/100")
        print(f"Tagline: {hidden_gem['hidden_gem']['gem_tagline']}")
        print("\n🔮 Mystery Teaser:")
        print(hidden_gem['hidden_gem']['mystery_teaser'])
        print("\n✨ Discovery Hints:")
        for hint in hidden_gem['hidden_gem']['discovery_hints']:
            print(f"  {hint}")
            
    except Exception as e:
        print(f"❌ Error discovering hidden gem: {e}")

"""
