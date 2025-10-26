import 'package:flutter/material.dart';

class URLImportScreen extends StatefulWidget {
  const URLImportScreen({super.key});

  @override
  State<URLImportScreen> createState() => _URLImportScreenState();
}

class _URLImportScreenState extends State<URLImportScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import from URL')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How it works',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Paste the URL of a recipe from any cooking website\n'
                        '2. We\'ll extract the recipe details automatically\n'
                        '3. Review and edit the imported recipe before saving',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // URL Input
              Text(
                'Recipe URL',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://example.com/recipe',
                  prefixIcon: const Icon(Icons.link),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: () async {
                      // Paste from clipboard
                      // final data = await Clipboard.getData('text/plain');
                      // if (data?.text != null) {
                      //   _urlController.text = data!.text!;
                      // }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe URL';
                  }
                  if (!Uri.tryParse(value)!.hasAbsolutePath == true) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _importRecipe(),
              ),

              const SizedBox(height: 24),

              // Supported Sites
              Text(
                'Popular supported sites',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          'AllRecipes.com',
                          'Food Network',
                          'NYT Cooking',
                          'Bon Appétit',
                          'Serious Eats',
                          'Epicurious',
                          'Taste of Home',
                          'BBC Good Food',
                        ]
                        .map(
                          (site) => Chip(
                            label: Text(site),
                            avatar: const Icon(Icons.check_circle, size: 16),
                          ),
                        )
                        .toList(),
              ),

              const Spacer(),

              // Import Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _importRecipe,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Importing Recipe...'),
                          ],
                        )
                      : const Text('Import Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _importRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful import
      final mockRecipeData = {
        'title': 'Classic Spaghetti Carbonara',
        'description':
            'A traditional Italian pasta dish with eggs, cheese, pancetta, and black pepper',
        'prepTime': '15 minutes',
        'cookTime': '20 minutes',
        'servings': 4,
        'ingredients': [
          '400g spaghetti',
          '150g pancetta, diced',
          '3 large eggs',
          '75g Pecorino Romano cheese, grated',
          '75g Parmesan cheese, grated',
          'Black pepper, freshly ground',
          'Salt for pasta water',
        ],
        'instructions': [
          'Bring a large pot of salted water to a boil. Cook spaghetti according to package directions until al dente.',
          'While pasta cooks, heat a large skillet over medium heat. Add pancetta and cook until crispy, about 5-7 minutes.',
          'In a bowl, whisk together eggs, Pecorino Romano, Parmesan, and a generous amount of black pepper.',
          'Reserve 1 cup of pasta cooking water, then drain the pasta.',
          'Add hot pasta to the skillet with pancetta. Remove from heat.',
          'Quickly add the egg mixture, tossing constantly. Add pasta water a little at a time until creamy.',
          'Serve immediately with extra cheese and black pepper.',
        ],
        'sourceUrl': _urlController.text,
        'sourceName': 'Example Recipe Site',
        'imageUrl': null,
      };

      setState(() {
        _isLoading = false;
      });

      // Navigate to review screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RecipeReviewScreen(recipeData: mockRecipeData, importType: 'URL'),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import recipe: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}

class RecipeReviewScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final String importType;

  const RecipeReviewScreen({
    super.key,
    required this.recipeData,
    required this.importType,
  });

  @override
  State<RecipeReviewScreen> createState() => _RecipeReviewScreenState();
}

class _RecipeReviewScreenState extends State<RecipeReviewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _instructionControllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.recipeData['title']);
    _descriptionController = TextEditingController(
      text: widget.recipeData['description'],
    );
    _prepTimeController = TextEditingController(
      text: widget.recipeData['prepTime'],
    );
    _cookTimeController = TextEditingController(
      text: widget.recipeData['cookTime'],
    );
    _servingsController = TextEditingController(
      text: widget.recipeData['servings'].toString(),
    );

    _ingredientControllers = (widget.recipeData['ingredients'] as List<String>)
        .map((ingredient) => TextEditingController(text: ingredient))
        .toList();

    _instructionControllers =
        (widget.recipeData['instructions'] as List<String>)
            .map((instruction) => TextEditingController(text: instruction))
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${widget.importType} Import'),
        actions: [
          TextButton(onPressed: _proceedToTagging, child: const Text('Next')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Import Success Banner
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recipe imported successfully!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'Review and edit the details below before saving.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Basic Info
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe Title',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prepTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Prep Time',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cookTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Cook Time',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _servingsController,
                            decoration: const InputDecoration(
                              labelText: 'Servings',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Ingredients
            _buildSectionHeader('Ingredients'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ..._ingredientControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeIngredient(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Ingredient'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            _buildSectionHeader('Instructions'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ..._instructionControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeInstruction(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: _addInstruction,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Step'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  void _proceedToTagging() {
    // Collect all the edited data
    final editedRecipeData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'prepTime': _prepTimeController.text,
      'cookTime': _cookTimeController.text,
      'servings': int.tryParse(_servingsController.text) ?? 1,
      'ingredients': _ingredientControllers.map((c) => c.text).toList(),
      'instructions': _instructionControllers.map((c) => c.text).toList(),
      'sourceUrl': widget.recipeData['sourceUrl'],
      'sourceName': widget.recipeData['sourceName'],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagProposalScreen(recipeData: editedRecipeData),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();

    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    for (final controller in _instructionControllers) {
      controller.dispose();
    }

    super.dispose();
  }
}

class TagProposalScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const TagProposalScreen({super.key, required this.recipeData});

  @override
  State<TagProposalScreen> createState() => _TagProposalScreenState();
}

class _TagProposalScreenState extends State<TagProposalScreen> {
  // Mock AI-suggested tags
  final Map<String, List<String>> _suggestedTags = {
    'Meal Type': ['Dinner'],
    'Diet Type': ['Meat'],
    'Supplemental': ['Italian', 'Pasta', 'Quick'],
  };

  final Map<String, Set<String>> _selectedTags = {
    'Meal Type': {'Dinner'},
    'Diet Type': {'Meat'},
    'Supplemental': {'Italian', 'Pasta'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Tags'),
        actions: [
          TextButton(onPressed: _saveRecipe, child: const Text('Save Recipe')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Suggestion Banner
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_fix_high,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI-Powered Tag Suggestions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                          Text(
                            'We\'ve analyzed your recipe and suggested relevant tags. Review and modify as needed.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tag Categories
            ..._suggestedTags.entries.map((categoryEntry) {
              final category = categoryEntry.key;
              final suggestions = categoryEntry.value;
              return _buildTagCategory(category, suggestions);
            }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTagCategory(String category, List<String> suggestions) {
    final availableTags = _getAvailableTagsForCategory(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Suggested tags (highlighted)
            if (suggestions.isNotEmpty) ...[
              const Text(
                'AI Suggestions:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag),
                        selected:
                            _selectedTags[category]?.contains(tag) ?? false,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags[category] =
                                  (_selectedTags[category] ?? {})..add(tag);
                            } else {
                              _selectedTags[category]?.remove(tag);
                            }
                          });
                        },
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        checkmarkColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // All available tags
            const Text(
              'All Options:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableTags
                  .map(
                    (tag) => FilterChip(
                      label: Text(tag),
                      selected: _selectedTags[category]?.contains(tag) ?? false,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags[category] =
                                (_selectedTags[category] ?? {})..add(tag);
                          } else {
                            _selectedTags[category]?.remove(tag);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableTagsForCategory(String category) {
    switch (category) {
      case 'Meal Type':
        return [
          'Breakfast',
          'Lunch',
          'Dinner',
          'Snacks & Apps',
          'Dessert',
          'Drinks',
        ];
      case 'Diet Type':
        return [
          'Vegetarian',
          'Meat',
          'Seafood',
          'Gluten-Free',
          'Mediterranean',
        ];
      case 'Supplemental':
        return [
          'Quick',
          'Healthy',
          'Grill',
          'Stovetop',
          'Oven',
          'Instant Pot',
          'Air Fryer',
          'Italian',
          'Pasta',
        ];
      default:
        return [];
    }
  }

  void _saveRecipe() {
    // Show final confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Recipe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipe: ${widget.recipeData['title']}'),
            const SizedBox(height: 8),
            const Text('Selected tags:'),
            ..._selectedTags.entries.map(
              (entry) => Text(
                '${entry.key}: ${entry.value.join(', ')}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              ); // Go back to main screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recipe saved successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
