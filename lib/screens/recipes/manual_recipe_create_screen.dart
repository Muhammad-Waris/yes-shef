import 'package:flutter/material.dart';

class ManualRecipeCreateScreen extends StatefulWidget {
  const ManualRecipeCreateScreen({super.key});

  @override
  State<ManualRecipeCreateScreen> createState() =>
      _ManualRecipeCreateScreenState();
}

class _ManualRecipeCreateScreenState extends State<ManualRecipeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _cookbookController = TextEditingController();
  final _authorController = TextEditingController();

  final List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _instructionControllers = [
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
        actions: [
          TextButton(onPressed: _saveRecipe, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Create Your Recipe',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fill in the details below to create your recipe from scratch. All fields with * are required.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Basic Information
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
                          labelText: 'Recipe Title *',
                          hintText:
                              'e.g., Grandmother\'s Chocolate Chip Cookies',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a recipe title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Brief description of the recipe...',
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
                                hintText: '15 minutes',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cookTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Cook Time',
                                hintText: '30 minutes',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _servingsController,
                              decoration: const InputDecoration(
                                labelText: 'Servings *',
                                hintText: '4',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Enter a number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Source Information
              _buildSectionHeader('Source Information (Optional)'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _cookbookController,
                        decoration: const InputDecoration(
                          labelText: 'Cookbook/Source',
                          hintText: 'e.g., Joy of Cooking, Family Recipe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          labelText: 'Author/Chef',
                          hintText: 'e.g., Julia Child, Mom',
                          border: OutlineInputBorder(),
                        ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'List ingredients with quantities (e.g., "2 cups flour", "1 tsp salt")',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
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
                                  decoration: InputDecoration(
                                    hintText: index == 0
                                        ? '2 cups all-purpose flour'
                                        : 'Next ingredient...',
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  validator: (value) {
                                    if (index == 0 &&
                                        (value == null || value.isEmpty)) {
                                      return 'At least one ingredient is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (_ingredientControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _removeIngredient(index),
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Write step-by-step instructions for your recipe',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
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
                                  decoration: InputDecoration(
                                    hintText: index == 0
                                        ? 'Preheat oven to 350°F...'
                                        : 'Next step...',
                                    border: const OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                  validator: (value) {
                                    if (index == 0 &&
                                        (value == null || value.isEmpty)) {
                                      return 'At least one instruction is required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (_instructionControllers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _removeInstruction(index),
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _addInstruction,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Step'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Photo Section
              _buildSectionHeader('Recipe Photo (Optional)'),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  onTap: _addPhoto,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add a photo',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          'Show off your delicious creation!',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Create Recipe'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
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
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstruction(int index) {
    if (_instructionControllers.length > 1) {
      setState(() {
        _instructionControllers[index].dispose();
        _instructionControllers.removeAt(index);
      });
    }
  }

  void _addPhoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Recipe Photo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // Implement camera functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Implement gallery selection
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveRecipe() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Filter out empty ingredients and instructions
    final ingredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final instructions = _instructionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one instruction')),
      );
      return;
    }

    // Create recipe data
    final recipeData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'prepTime': _prepTimeController.text.trim(),
      'cookTime': _cookTimeController.text.trim(),
      'servings': int.tryParse(_servingsController.text) ?? 1,
      'cookbookTitle': _cookbookController.text.trim(),
      'author': _authorController.text.trim(),
      'ingredients': ingredients,
      'instructions': instructions,
    };

    // Navigate to tag proposal screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TagProposalScreen(recipeData: recipeData),
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
    _cookbookController.dispose();
    _authorController.dispose();

    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    for (final controller in _instructionControllers) {
      controller.dispose();
    }

    super.dispose();
  }
}

// Reuse TagProposalScreen from url_import_screen.dart
class TagProposalScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const TagProposalScreen({super.key, required this.recipeData});

  @override
  State<TagProposalScreen> createState() => _TagProposalScreenState();
}

class _TagProposalScreenState extends State<TagProposalScreen> {
  // Mock AI-suggested tags based on recipe content
  Map<String, List<String>> get _suggestedTags {
    final title = widget.recipeData['title']?.toString().toLowerCase() ?? '';
    final ingredients = widget.recipeData['ingredients'] as List<String>? ?? [];
    final allText = '$title ${ingredients.join(' ')}'.toLowerCase();

    final suggestions = <String, List<String>>{
      'Meal Type': <String>[],
      'Diet Type': <String>[],
      'Supplemental': <String>[],
    };

    // Basic meal type detection
    if (title.contains('cookie') ||
        title.contains('cake') ||
        title.contains('pie')) {
      suggestions['Meal Type']!.add('Dessert');
    } else if (title.contains('breakfast') ||
        allText.contains('pancake') ||
        allText.contains('cereal')) {
      suggestions['Meal Type']!.add('Breakfast');
    } else {
      suggestions['Meal Type']!.add('Dinner');
    }

    // Basic diet type detection
    if (allText.contains('meat') ||
        allText.contains('chicken') ||
        allText.contains('beef')) {
      suggestions['Diet Type']!.add('Meat');
    } else if (allText.contains('fish') ||
        allText.contains('salmon') ||
        allText.contains('shrimp')) {
      suggestions['Diet Type']!.add('Seafood');
    } else {
      suggestions['Diet Type']!.add('Vegetarian');
    }

    // Cook time detection
    final prepTime = widget.recipeData['prepTime']?.toString() ?? '';
    final cookTime = widget.recipeData['cookTime']?.toString() ?? '';
    if (prepTime.contains('min') || cookTime.contains('min')) {
      final totalMinutes =
          _extractMinutes(prepTime) + _extractMinutes(cookTime);
      if (totalMinutes <= 30) {
        suggestions['Supplemental']!.add('Quick');
      }
    }

    return suggestions;
  }

  int _extractMinutes(String timeString) {
    final match = RegExp(r'(\d+)').firstMatch(timeString);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  final Map<String, Set<String>> _selectedTags = <String, Set<String>>{};

  @override
  void initState() {
    super.initState();
    // Initialize selected tags with suggestions
    for (final entry in _suggestedTags.entries) {
      _selectedTags[entry.key] = entry.value.toSet();
    }
  }

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
                const SnackBar(content: Text('Recipe created successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
