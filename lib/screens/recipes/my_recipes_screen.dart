import 'package:flutter/material.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _prominentIngredientController =
      TextEditingController();
  final TextEditingController _cookbookController = TextEditingController();

  String _selectedFilter = 'All';
  String _searchMode = 'general'; // 'general' or 'prominent'

  final List<String> _filters = [
    'All',
    'Favorites',
    'Recent',
    'Cooked',
    'breakfast',
    'dinner',
    'snacks & apps',
    'dessert',
    'drinks',
  ];

  // Enhanced mock recipe data matching the requirements
  final List<Map<String, dynamic>> _mockRecipes = [
    {
      'title': 'Classic Spaghetti Carbonara',
      'description': 'Creamy pasta with eggs, cheese, and pancetta',
      'prepTime': 15, // minutes for rule-based tagging
      'cookTime': 20,
      'prepTimeDisplay': '15 min',
      'cookTimeDisplay': '20 min',
      'servings': 4,
      'originalYield': 4,
      'rating': 4.8,
      'isCooked': true,
      'isFavorite': true,
      'mealTypeTags': ['dinner'],
      'dietTypeTags': ['meat'],
      'supplementalTags': ['stovetop'], // Auto-tagged from instructions
      'allTags': ['Italian', 'Pasta', 'dinner', 'meat', 'stovetop'],
      'image': null,
      'cookbookTitle': 'Italian Classics',
      'cookbookAuthor': 'Mario Rossi',
      'sourceUrl': null,
      'ingredients': [
        {'name': 'spaghetti', 'amount': 1, 'unit': 'lb', 'isProminent': true},
        {'name': 'eggs', 'amount': 4, 'unit': 'large', 'isProminent': false},
        {'name': 'pancetta', 'amount': 4, 'unit': 'oz', 'isProminent': true},
        {
          'name': 'parmesan cheese',
          'amount': 1,
          'unit': 'cup',
          'isProminent': true
        },
        {
          'name': 'salt',
          'amount': null,
          'unit': 'to taste',
          'isProminent': false
        },
        {
          'name': 'black pepper',
          'amount': null,
          'unit': 'to taste',
          'isProminent': false
        },
      ],
      'instructions': [
        'Cook spaghetti according to package directions on stovetop',
        'Cook pancetta in large skillet until crispy',
        'Whisk eggs with cheese in bowl',
        'Combine hot pasta with pancetta, then egg mixture off heat',
        'Serve immediately with extra cheese'
      ],
      'dateAdded': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'title': 'Chocolate Chip Cookies',
      'description': 'Soft and chewy homemade cookies',
      'prepTime': 10,
      'cookTime': 12,
      'prepTimeDisplay': '10 min',
      'cookTimeDisplay': '12 min',
      'servings': 24,
      'originalYield': 24,
      'rating': 4.9,
      'isCooked': false,
      'isFavorite': true,
      'mealTypeTags': ['dessert'],
      'dietTypeTags': ['vegetarian'],
      'supplementalTags': [
        'quick',
        'oven'
      ], // Auto-tagged: total time <30min + baking method
      'allTags': [
        'Dessert',
        'Baking',
        'Sweet',
        'dessert',
        'vegetarian',
        'quick',
        'oven'
      ],
      'image': null,
      'cookbookTitle': 'Family Favorites',
      'cookbookAuthor': 'Grandma Smith',
      'sourceUrl': null,
      'ingredients': [
        {'name': 'flour', 'amount': 2, 'unit': 'cups', 'isProminent': true},
        {
          'name': 'baking soda',
          'amount': 1,
          'unit': 'tsp',
          'isProminent': false
        },
        {'name': 'butter', 'amount': 1, 'unit': 'cup', 'isProminent': true},
        {
          'name': 'brown sugar',
          'amount': 0.75,
          'unit': 'cup',
          'isProminent': false
        },
        {
          'name': 'chocolate chips',
          'amount': 2,
          'unit': 'cups',
          'isProminent': true
        },
      ],
      'instructions': [
        'Preheat oven to 375°F',
        'Mix dry ingredients in bowl',
        'Cream butter and sugars',
        'Combine wet and dry ingredients',
        'Drop onto baking sheet and bake 9-11 minutes'
      ],
      'dateAdded': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'title': 'Garlic Herb Chicken',
      'description': 'Juicy chicken with fresh herbs and lots of garlic',
      'prepTime': 20,
      'cookTime': 25,
      'prepTimeDisplay': '20 min',
      'cookTimeDisplay': '25 min',
      'servings': 4,
      'originalYield': 4,
      'rating': 4.7,
      'isCooked': true,
      'isFavorite': false,
      'mealTypeTags': ['dinner'],
      'dietTypeTags': ['meat'],
      'supplementalTags': ['oven'], // Auto-tagged from cooking method
      'allTags': ['Chicken', 'Herbs', 'dinner', 'meat', 'oven'],
      'image': null,
      'cookbookTitle': 'Modern Home Cooking',
      'cookbookAuthor': 'Chef Anderson',
      'sourceUrl': 'https://example.com/garlic-chicken',
      'ingredients': [
        {
          'name': 'chicken breast',
          'amount': 4,
          'unit': 'pieces',
          'isProminent': true
        },
        {
          'name': 'garlic',
          'amount': 6,
          'unit': 'cloves',
          'isProminent': true
        }, // Prominent due to quantity ≥4
        {
          'name': 'fresh thyme',
          'amount': 2,
          'unit': 'tbsp',
          'isProminent': false
        },
        {
          'name': 'olive oil',
          'amount': 3,
          'unit': 'tbsp',
          'isProminent': false
        },
        {
          'name': 'lemon juice',
          'amount': 2,
          'unit': 'tbsp',
          'isProminent': false
        },
      ],
      'instructions': [
        'Preheat oven to 400°F',
        'Mince garlic and mix with herbs and oil',
        'Season chicken and coat with herb mixture',
        'Bake for 25 minutes until internal temp reaches 165°F'
      ],
      'dateAdded': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  List<Map<String, dynamic>> get _filteredRecipes {
    var recipes = _mockRecipes.where((recipe) {
      // Text search across multiple fields
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final title = recipe['title'].toString().toLowerCase();
        final ingredients = (recipe['ingredients'] as List)
            .map((i) => i['name'].toString().toLowerCase())
            .join(' ');
        final author = recipe['cookbookAuthor']?.toString().toLowerCase() ?? '';
        final cookbook =
            recipe['cookbookTitle']?.toString().toLowerCase() ?? '';

        if (!title.contains(query) &&
            !ingredients.contains(query) &&
            !author.contains(query) &&
            !cookbook.contains(query)) {
          return false;
        }
      }

      // Prominent ingredient search
      if (_prominentIngredientController.text.isNotEmpty) {
        final query = _prominentIngredientController.text.toLowerCase();
        final prominentIngredients = (recipe['ingredients'] as List)
            .where((i) => i['isProminent'] == true)
            .map((i) => i['name'].toString().toLowerCase())
            .join(' ');

        if (_searchMode == 'prominent' &&
            !prominentIngredients.contains(query)) {
          return false;
        }
      }

      // Cookbook/Author search
      if (_cookbookController.text.isNotEmpty) {
        final query = _cookbookController.text.toLowerCase();
        final author = recipe['cookbookAuthor']?.toString().toLowerCase() ?? '';
        final cookbook =
            recipe['cookbookTitle']?.toString().toLowerCase() ?? '';

        if (!author.contains(query) && !cookbook.contains(query)) {
          return false;
        }
      }

      // Filter by category
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Favorites') return recipe['isFavorite'];
      if (_selectedFilter == 'Recent') {
        final dateAdded = recipe['dateAdded'] as DateTime?;
        return dateAdded
                ?.isAfter(DateTime.now().subtract(const Duration(days: 7))) ??
            false;
      }
      if (_selectedFilter == 'Cooked') return recipe['isCooked'];

      // Check meal type tags
      return (recipe['allTags'] as List<String>).contains(_selectedFilter);
    }).toList();

    // Sort: prominent ingredient matches first if searching by prominent
    if (_prominentIngredientController.text.isNotEmpty &&
        _searchMode == 'prominent') {
      final query = _prominentIngredientController.text.toLowerCase();
      recipes.sort((a, b) {
        final aProminent = (a['ingredients'] as List)
            .where((i) =>
                i['isProminent'] == true &&
                i['name'].toString().toLowerCase().contains(query))
            .isNotEmpty;
        final bProminent = (b['ingredients'] as List)
            .where((i) =>
                i['isProminent'] == true &&
                i['name'].toString().toLowerCase().contains(query))
            .isNotEmpty;

        if (aProminent && !bProminent) return -1;
        if (!aProminent && bProminent) return 1;
        return 0;
      });
    }

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes by name or ingredient...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  // Trigger search filter
                });
              },
            ),
          ),
          // Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Recipe List
          Expanded(
            child: _filteredRecipes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      return _buildRecipeCard(recipe);
                    },
                  ),
          ),
        ],
      ),
      // PRD REQUIREMENT: Plus button on all screens for quick add
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final totalTime = (recipe['prepTime'] as int) + (recipe['cookTime'] as int);
    final isQuick = totalTime <= 30;
    final prominentCount =
        (recipe['ingredients'] as List).where((i) => i['isProminent']).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                recipe['title'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (isQuick)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.green.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  'QUICK',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            if (recipe['isCooked'])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.blue.withOpacity(0.3)),
                                ),
                                child: const Text(
                                  'COOKED',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe['description'],
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        // Show source information
                        if (recipe['cookbookTitle'] != null ||
                            recipe['sourceUrl'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                recipe['sourceUrl'] != null
                                    ? Icons.link
                                    : Icons.book,
                                size: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  recipe['cookbookTitle'] ?? 'Web Recipe',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      // PRD: Rating display - FIXED to show rating properly
                      if (recipe['rating'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                recipe['rating'].toString(),
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          recipe['isFavorite']
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe['isFavorite'] ? Colors.red : null,
                        ),
                        onPressed: () {
                          setState(() {
                            recipe['isFavorite'] = !recipe['isFavorite'];
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Time and serving info with prominent ingredients hint
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.access_time, '$totalTime min'),
                  _buildInfoChip(Icons.people,
                      'Serves ${recipe['originalYield']} (original)'), // PRD: Show original yield
                  _buildInfoChip(
                      Icons.star_outline, '$prominentCount key ingredients'),
                  // PRD: Source type indicator
                  if (recipe['sourceUrl'] != null)
                    _buildInfoChip(Icons.link, 'Web'),
                  if (recipe['cookbookTitle'] != null)
                    _buildInfoChip(Icons.book, 'Cookbook'),
                ],
              ),

              const SizedBox(height: 12),

              // Tags with proper taxonomy display
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Meal type tags
                        ...(recipe['mealTypeTags'] as List<String>).map(
                          (tag) => Chip(
                            label:
                                Text(tag, style: const TextStyle(fontSize: 11)),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        // Diet type tags
                        ...(recipe['dietTypeTags'] as List<String>).take(1).map(
                              (tag) => Chip(
                                label: Text(tag,
                                    style: const TextStyle(fontSize: 11)),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                        // Supplemental tags (limited display)
                        ...(recipe['supplementalTags'] as List<String>)
                            .take(1)
                            .map(
                              (tag) => Chip(
                                label: Text(tag,
                                    style: const TextStyle(fontSize: 11)),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                      ],
                    ),
                  ),
                  if (recipe['isCooked'])
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'COOKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No recipes found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first recipe!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Search'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Mode Toggle
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Text('Search Mode: '),
                    const SizedBox(width: 8),
                    ToggleButtons(
                      isSelected: [
                        _searchMode == 'general',
                        _searchMode == 'prominent'
                      ],
                      onPressed: (index) {
                        setState(() {
                          _searchMode = index == 0 ? 'general' : 'prominent';
                        });
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('General'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Prominent'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Recipe name or general ingredient',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., pasta, chicken',
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _prominentIngredientController,
                decoration: InputDecoration(
                  labelText: _searchMode == 'prominent'
                      ? 'Prominent ingredients (priority search)'
                      : 'Prominent ingredients',
                  border: const OutlineInputBorder(),
                  hintText: 'e.g., garlic, tomatoes',
                  helperText:
                      'Searches ingredients that are prominent in the dish',
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _cookbookController,
                decoration: const InputDecoration(
                  labelText: 'Cookbook or Author',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Julia Child, Italian Classics',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _prominentIngredientController.clear();
                _cookbookController.clear();
              });
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Trigger search
              });
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter & Sort Options',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Meal Type (as per taxonomy requirements)
              const Text('Meal Type',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'breakfast',
                  'dinner',
                  'snacks & apps',
                  'dessert',
                  'drinks'
                ]
                    .map((type) => FilterChip(
                          label: Text(type),
                          selected: _selectedFilter == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? type : 'All';
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Diet Type (as per taxonomy requirements)
              const Text('Diet Type',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'vegetarian',
                  'meat',
                  'seafood',
                  'gluten-free',
                  'mediterranean'
                ]
                    .map((type) => FilterChip(
                          label: Text(type),
                          selected: _selectedFilter == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? type : 'All';
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Supplemental Tags (as per taxonomy requirements)
              const Text('Supplemental',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'quick',
                  'healthy',
                  'grill',
                  'stovetop',
                  'oven',
                  'InstantPot',
                  'air fryer'
                ]
                    .map((type) => FilterChip(
                          label: Text(type),
                          selected: _selectedFilter == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? type : 'All';
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Cook Time Range
              const Text('Cook Time Range',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(
                values: const RangeValues(0, 60),
                max: 120,
                divisions: 12,
                labels: const RangeLabels('0 min', '60 min'),
                onChanged: (values) {
                  // TODO: Implement time filtering
                },
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'All';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PRD: Plus button menu implementation
  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text('Add New',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // PRD: URL Import option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.link, color: Colors.blue),
              ),
              title: const Text('Import from URL'),
              subtitle: const Text('Scrape recipe from website'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Milestone 2',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'URL import: Coming in Milestone 2 - Recipe Import & OCR!'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),

            // PRD: OCR option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.green),
              ),
              title: const Text('Scan Recipe (OCR)'),
              subtitle: const Text('Photo → editable text'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Milestone 2',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'OCR scanning: Coming in Milestone 2 - Recipe Import & OCR!'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),

            // PRD: Manual entry
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.purple),
              ),
              title: const Text('Enter Manually'),
              subtitle: const Text('Type recipe from scratch'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Milestone 2',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manual entry: Coming in Milestone 2!'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),

            // PRD: Quick calendar/meal add
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month, color: Colors.teal),
              ),
              title: const Text('Plan Meal'),
              subtitle: const Text('Add to calendar quickly'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Ready!',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to calendar screen
                DefaultTabController.of(context)
                    .animateTo(2); // Assuming calendar is 3rd tab
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Calendar opened - ready for meal planning!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced RecipeDetailScreen with proper scaling functionality
class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  double _scaleFactor = 1.0;

  int get _scaledServings => (widget.recipe['servings'] * _scaleFactor).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing coming in Milestone 3!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Edit functionality coming in Milestone 3!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, size: 64),
            ),
            const SizedBox(height: 16),

            // Recipe Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe['title'],
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.recipe['description'],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.recipe['isFavorite']
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.recipe['isFavorite'] ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.recipe['isFavorite'] =
                          !widget.recipe['isFavorite'];
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Time and Servings Info - FIXED: Convert int to string
            Row(
              children: [
                _buildInfoCard(
                  context,
                  Icons.access_time,
                  'Prep',
                  '${widget.recipe['prepTime']} min', // Fixed: Convert int to string
                ),
                const SizedBox(width: 12),
                _buildInfoCard(
                  context,
                  Icons.schedule,
                  'Cook',
                  '${widget.recipe['cookTime']} min', // Fixed: Convert int to string
                ),
                const SizedBox(width: 12),
                _buildInfoCard(
                  context,
                  Icons.people,
                  'Serves',
                  '$_scaledServings',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Recipe Scaling with 0.5 increments
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipe Scaling',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('Original: ${widget.recipe['servings']} servings'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Scale: '),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _scaleFactor > 0.5
                              ? () {
                                  setState(() {
                                    _scaleFactor =
                                        ((_scaleFactor - 0.5) * 2).round() /
                                            2.0;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          '${_scaleFactor}x',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _scaleFactor =
                                  ((_scaleFactor + 0.5) * 2).round() / 2.0;
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                        const Spacer(),
                        Text('= $_scaledServings servings'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tags - FIXED: Use allTags instead of tags
            Text(
              'Tags',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (widget.recipe['allTags']
                      as List<String>) // Fixed: Use allTags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Ingredients - FIXED: Handle proper ingredient structure
            Text(
              'Ingredients',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (widget.recipe['ingredients'] as List?)
                          ?.map<Widget>((ingredient) {
                        // Handle both string and map ingredient formats
                        String ingredientText;
                        bool isProminent = false;

                        if (ingredient is Map) {
                          final amount = ingredient['amount'];
                          final unit = ingredient['unit'];
                          final name = ingredient['name'];
                          isProminent = ingredient['isProminent'] ?? false;

                          if (amount != null) {
                            ingredientText = '$amount $unit $name';
                          } else {
                            ingredientText = '$name ($unit)';
                          }
                        } else {
                          ingredientText = ingredient.toString();
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isProminent
                                      ? Colors.amber
                                      : Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ingredientText,
                                  style: TextStyle(
                                    fontWeight: isProminent
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isProminent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'KEY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList() ??
                      [const Text('No ingredients available.')],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Text(
              'Instructions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (widget.recipe['instructions'] as List<String>?)
                          ?.asMap()
                          .entries
                          .map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(entry.value)),
                                  ],
                                ),
                              ))
                          .toList() ??
                      [const Text('No instructions available.')],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              widget.recipe['isCooked'] = !widget.recipe['isCooked'];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.recipe['isCooked']
                      ? 'Recipe marked as cooked!'
                      : 'Recipe marked as not cooked.',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            widget.recipe['isCooked'] ? 'Mark as Not Cooked' : 'Mark as Cooked',
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
