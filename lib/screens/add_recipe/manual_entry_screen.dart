import 'package:flutter/material.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Recipe Manually'),
        actions: [
          TextButton(
            onPressed: () => _saveRecipe(),
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Info Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Title *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Chocolate Chip Cookies',
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Title is required' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Brief description of the recipe',
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Timing & Servings
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Prep Time (min)',
                        border: OutlineInputBorder(),
                        hintText: '15',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cookTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Cook Time (min)',
                        border: OutlineInputBorder(),
                        hintText: '30',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(
                        labelText: 'Servings',
                        border: OutlineInputBorder(),
                        hintText: '4',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Ingredients Section
              _buildSectionHeader('Ingredients'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients *',
                  border: OutlineInputBorder(),
                  hintText:
                      'Enter each ingredient on a new line:\n2 cups flour\n1 tsp salt\n1 cup sugar',
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) =>
                    value?.isEmpty == true ? 'Ingredients are required' : null,
              ),

              const SizedBox(height: 24),

              // Instructions Section
              _buildSectionHeader('Instructions'),
              const SizedBox(height: 12),

              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions *',
                  border: OutlineInputBorder(),
                  hintText:
                      'Enter each step on a new line:\n1. Preheat oven to 350°F\n2. Mix dry ingredients\n3. Add wet ingredients',
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) =>
                    value?.isEmpty == true ? 'Instructions are required' : null,
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _saveRecipe(),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Recipe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Coming Soon Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.construction,
                        color: Colors.orange, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      'Manual Entry - Milestone 2',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Full manual entry with auto-tagging coming soon!',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  void _saveRecipe() {
    if (_formKey.currentState?.validate() == true) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Manual recipe entry will be implemented in Milestone 2!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
