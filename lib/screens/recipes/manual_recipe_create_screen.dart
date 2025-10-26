import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _photoFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Recipe'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroCard(context),
              const SizedBox(height: 24),
              _buildBasicInfoCard(),
              const SizedBox(height: 24),
              _buildSourceCard(),
              const SizedBox(height: 24),
              _buildIngredientsCard(),
              const SizedBox(height: 24),
              _buildInstructionsCard(),
              const SizedBox(height: 24),
              _buildPhotoCard(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  label: const Text('Create Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Fill in the details below to create your recipe from scratch. '
                'All fields with * are required.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildSection(
      'Basic Information',
      Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Recipe Title *',
              hintText: 'e.g., Chocolate Chip Cookies',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Brief description of the recipe',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _prepTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Prep Time (min)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cookTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Cook Time (min)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _servingsController,
                  decoration: const InputDecoration(
                    labelText: 'Servings *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard() {
    return _buildSection(
      'Source Information (Optional)',
      Column(
        children: [
          TextFormField(
            controller: _cookbookController,
            decoration: const InputDecoration(
              labelText: 'Cookbook / Source',
              hintText: 'e.g., Joy of Cooking',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: 'Author / Chef',
              hintText: 'e.g., Julia Child',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return _buildSection(
      'Ingredients',
      Column(
        children: [
          ..._ingredientControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Ingredient ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (index == 0 && (v == null || v.isEmpty)) {
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
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Ingredient'),
            onPressed: _addIngredient,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return _buildSection(
      'Instructions',
      Column(
        children: [
          ..._instructionControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${index + 1}. ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: index == 0
                            ? 'Preheat oven to 350°F...'
                            : 'Next step...',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (index == 0 && (v == null || v.isEmpty)) {
                          return 'At least one step is required';
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
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Step'),
            onPressed: _addInstruction,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return _buildSection(
      'Recipe Photo (Optional)',
      InkWell(
        onTap: _addPhoto,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _photoFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_photoFile!, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tap to add a photo'),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ],
    );
  }

  void _addIngredient() {
    setState(() => _ingredientControllers.add(TextEditingController()));
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addInstruction() {
    setState(() => _instructionControllers.add(TextEditingController()));
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  void _saveRecipe() {
    if (!_formKey.currentState!.validate()) return;

    final ingredients = _ingredientControllers
        .map((e) => e.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final instructions = _instructionControllers
        .map((e) => e.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final recipeData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'prepTime': _prepTimeController.text.trim(),
      'cookTime': _cookTimeController.text.trim(),
      'servings': int.tryParse(_servingsController.text) ?? 1,
      'cookbookTitle': _cookbookController.text.trim(),
      'cookbookAuthor': _authorController.text.trim(),
      'ingredients': ingredients,
      'instructions': instructions,
      'image': _photoFile?.path,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TagProposalScreen(recipeData: recipeData),
      ),
    );
  }
}

// TagProposalScreen (same as before)
class TagProposalScreen extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  const TagProposalScreen({super.key, required this.recipeData});

  @override
  State<TagProposalScreen> createState() => _TagProposalScreenState();
}

class _TagProposalScreenState extends State<TagProposalScreen> {
  final Map<String, Set<String>> _selectedTags = {};

  Map<String, List<String>> get _suggestedTags {
    final title = widget.recipeData['title']?.toLowerCase() ?? '';
    final ingredients = (widget.recipeData['ingredients'] as List?) ?? [];
    final allText = '$title ${ingredients.join(' ')}'.toLowerCase();

    final tags = {
      'Meal Type': <String>[],
      'Diet Type': <String>[],
      'Supplemental': <String>[],
    };

    if (title.contains('cake') || title.contains('cookie')) {
      tags['Meal Type']!.add('Dessert');
    } else if (allText.contains('egg') || allText.contains('pancake')) {
      tags['Meal Type']!.add('Breakfast');
    } else {
      tags['Meal Type']!.add('Dinner');
    }

    if (allText.contains('chicken') || allText.contains('beef')) {
      tags['Diet Type']!.add('Meat');
    } else if (allText.contains('fish')) {
      tags['Diet Type']!.add('Seafood');
    } else {
      tags['Diet Type']!.add('Vegetarian');
    }

    tags['Supplemental']!.add('Quick');
    return tags;
  }

  @override
  void initState() {
    super.initState();
    for (final e in _suggestedTags.entries) {
      _selectedTags[e.key] = e.value.toSet();
    }
  }

  void _saveToFirestore() async {
    final data = widget.recipeData;
    await FirebaseFirestore.instance.collection('recipes').add({
      ...data,
      'isFavorite': false,
      'isCooked': false,
      'dateAdded': FieldValue.serverTimestamp(),
      'mealTypeTags': _selectedTags['Meal Type']?.toList() ?? [],
      'dietTypeTags': _selectedTags['Diet Type']?.toList() ?? [],
      'supplementalTags': _selectedTags['Supplemental']?.toList() ?? [],
      'allTags': _selectedTags.values.expand((e) => e).toList(),
    });

    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe created successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Tags'),
        actions: [
          TextButton(
            onPressed: _saveToFirestore,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _suggestedTags.entries.map((entry) {
          final category = entry.key;
          final allOptions = _getAllTags(category);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: allOptions.map((tag) {
                      final selected =
                          _selectedTags[category]?.contains(tag) ?? false;
                      return FilterChip(
                        label: Text(tag),
                        selected: selected,
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _selectedTags[category]!.add(tag);
                            } else {
                              _selectedTags[category]!.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<String> _getAllTags(String category) {
    switch (category) {
      case 'Meal Type':
        return ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Dessert', 'Drinks'];
      case 'Diet Type':
        return ['Vegetarian', 'Meat', 'Seafood', 'Gluten-Free', 'Vegan'];
      case 'Supplemental':
        return ['Quick', 'Healthy', 'Grill', 'Oven', 'Stovetop', 'Air Fryer'];
      default:
        return [];
    }
  }
}
