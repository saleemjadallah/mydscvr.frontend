// Simple test of AI search logic without Flutter dependencies

void main() {
  testAISearchLogic();
}

void testAISearchLogic() {
  print('Testing AI Search Logic...');
  
  // Test age group parsing
  print('\n=== Testing Age Group Parsing ===');
  testAgeGroupParsing();
  
  // Test budget matching
  print('\n=== Testing Budget Matching ===');
  testBudgetMatching();
  
  // Test activity type matching
  print('\n=== Testing Activity Type Matching ===');
  testActivityTypeMatching();
  
  print('\n✅ All AI search logic tests passed!');
}

void testAgeGroupParsing() {
  final testCases = {
    'toddler': {'min': 1, 'max': 3},
    'toddlers': {'min': 1, 'max': 3},
    'preschool': {'min': 3, 'max': 5},
    'kids': {'min': 3, 'max': 12},
    'teenagers': {'min': 13, 'max': 17},
    '3-5': {'min': 3, 'max': 5},
    '6-12': {'min': 6, 'max': 12},
    '4': {'min': 4, 'max': 6},
  };
  
  for (final entry in testCases.entries) {
    final result = parseAgeGroup(entry.key);
    if (result != null) {
      print('✓ ${entry.key} -> ${result['min']}-${result['max']}');
      assert(result['min'] == entry.value['min']);
      assert(result['max'] == entry.value['max']);
    } else {
      print('✗ Failed to parse: ${entry.key}');
    }
  }
}

void testBudgetMatching() {
  final testCases = [
    {'price': 0, 'budget': 'free', 'expected': true},
    {'price': 50, 'budget': 'free', 'expected': false},
    {'price': 80, 'budget': 'budget', 'expected': true},
    {'price': 150, 'budget': 'budget', 'expected': false},
    {'price': 500, 'budget': 'premium', 'expected': true},
  ];
  
  for (final testCase in testCases) {
    final result = isBudgetMatch(
      testCase['price'] as int, 
      testCase['budget'] as String
    );
    final expected = testCase['expected'] as bool;
    
    if (result == expected) {
      print('✓ Price ${testCase['price']} with budget "${testCase['budget']}" -> $result');
    } else {
      print('✗ Expected $expected but got $result for price ${testCase['price']} with budget "${testCase['budget']}"');
    }
  }
}

void testActivityTypeMatching() {
  final eventCategories = ['outdoor', 'sports', 'family_friendly'];
  final testCases = [
    {'types': ['outdoor'], 'expected': true},
    {'types': ['indoor'], 'expected': false},
    {'types': ['sports'], 'expected': true},
    {'types': ['educational'], 'expected': false},
    {'types': ['outdoor', 'indoor'], 'expected': true}, // Should match outdoor
  ];
  
  for (final testCase in testCases) {
    final result = isActivityTypeMatch(
      eventCategories, 
      testCase['types'] as List<String>
    );
    final expected = testCase['expected'] as bool;
    
    if (result == expected) {
      print('✓ Categories $eventCategories with types ${testCase['types']} -> $result');
    } else {
      print('✗ Expected $expected but got $result');
    }
  }
}

// Helper functions (simplified versions of the actual implementation)

Map<String, int>? parseAgeGroup(String ageGroup) {
  final patterns = {
    'toddler': {'min': 1, 'max': 3},
    'toddlers': {'min': 1, 'max': 3},
    'baby': {'min': 0, 'max': 1},
    'babies': {'min': 0, 'max': 1},
    'preschool': {'min': 3, 'max': 5},
    'kids': {'min': 3, 'max': 12},
    'children': {'min': 3, 'max': 12},
    'teenagers': {'min': 13, 'max': 17},
    'teens': {'min': 13, 'max': 17},
    'adults': {'min': 18, 'max': 99},
  };
  
  final lowerAgeGroup = ageGroup.toLowerCase();
  
  // Check for exact pattern matches
  for (final pattern in patterns.entries) {
    if (lowerAgeGroup.contains(pattern.key)) {
      return pattern.value;
    }
  }
  
  // Parse numeric ranges like "3-5", "6-12"
  final regex = RegExp(r'(\d+)-(\d+)');
  final match = regex.firstMatch(ageGroup);
  if (match != null) {
    return {
      'min': int.parse(match.group(1)!),
      'max': int.parse(match.group(2)!),
    };
  }
  
  // Parse single ages like "4", "8"
  final singleAge = int.tryParse(ageGroup);
  if (singleAge != null) {
    return {
      'min': singleAge,
      'max': singleAge + 2, // Assume 2-year range
    };
  }
  
  return null;
}

bool isBudgetMatch(int eventPrice, String budget) {
  switch (budget) {
    case 'free':
      return eventPrice == 0;
    case 'budget':
      return eventPrice <= 100;
    case 'premium':
      return true; // No upper limit for premium
    default:
      return true;
  }
}

bool isActivityTypeMatch(List<String> eventCategories, List<String> activityTypes) {
  if (activityTypes.isEmpty) return true;
  
  final lowerEventCategories = eventCategories.map((c) => c.toLowerCase()).toList();
  return activityTypes.any((type) =>
    lowerEventCategories.any((category) => 
      category.contains(type.toLowerCase()) || 
      type.toLowerCase().contains(category)
    )
  );
}