class TagTaxonomy {
  // Meal Type taxonomy
  static const List<String> mealTypes = [
    'breakfast',
    'dinner',
    'snacks & apps',
    'dessert',
    'drinks',
  ];

  // Diet Type taxonomy
  static const List<String> dietTypes = [
    'vegetarian',
    'meat',
    'seafood',
    'gluten-free',
    'mediterranean',
  ];

  // Supplemental tags taxonomy
  static const List<String> supplementalTags = [
    'quick (<30min)',
    'healthy',
    'grill',
    'stovetop',
    'oven',
    'InstantPot',
    'air fryer',
  ];

  // All cooking methods
  static const List<String> cookingMethods = [
    'grill',
    'stovetop',
    'oven',
    'InstantPot',
    'air fryer',
  ];

  // Get all tags as a single list
  static List<String> getAllTags() {
    return [...mealTypes, ...dietTypes, ...supplementalTags];
  }

  // Check if tag belongs to meal type
  static bool isMealType(String tag) {
    return mealTypes.contains(tag);
  }

  // Check if tag belongs to diet type
  static bool isDietType(String tag) {
    return dietTypes.contains(tag);
  }

  // Check if tag belongs to supplemental type
  static bool isSupplementalTag(String tag) {
    return supplementalTags.contains(tag);
  }
}
