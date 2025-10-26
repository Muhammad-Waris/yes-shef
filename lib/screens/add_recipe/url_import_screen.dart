import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:cloud_firestore/cloud_firestore.dart';

class UrlImportScreen extends StatefulWidget {
  const UrlImportScreen({super.key});

  @override
  State<UrlImportScreen> createState() => _UrlImportScreenState();
}

class _UrlImportScreenState extends State<UrlImportScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _recipeData;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (compatible; YesChefBot/1.0; +https://yeschef.app)',
      },
    ),
  );

  Future<void> _importRecipe() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _recipeData = null;
    });

    try {
      final response = await _dio.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to load recipe');
      }

      final document = html_parser.parse(response.data);

      final title =
          document.querySelector('h1')?.text.trim() ??
          document.querySelector('title')?.text.trim() ??
          'Untitled Recipe';

      final description =
          document
              .querySelector('meta[name="description"]')
              ?.attributes['content']
              ?.trim() ??
          '';

      final ingredients = document
          .querySelectorAll('li, p, span')
          .where((e) {
            final t = e.text.toLowerCase();
            return t.contains('cup') ||
                t.contains('tsp') ||
                t.contains('tbsp') ||
                t.contains('oz') ||
                t.contains('gram') ||
                t.contains('ml') ||
                t.contains('kg');
          })
          .map((e) => e.text.trim())
          .where((text) => text.length > 3)
          .toSet()
          .toList();

      final steps = document
          .querySelectorAll('p, li')
          .where((e) {
            final t = e.text.toLowerCase();
            return t.contains('step') ||
                t.contains('mix') ||
                t.contains('bake') ||
                t.contains('cook') ||
                t.contains('heat') ||
                t.contains('serve');
          })
          .map((e) => e.text.trim())
          .where((text) => text.length > 3)
          .toSet()
          .toList();

      setState(() {
        _recipeData = {
          'title': title,
          'description': description,
          'ingredients': ingredients.take(20).toList(),
          'instructions': steps.take(20).toList(),
          'sourceUrl': url,
        };
      });
    } on DioException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to import recipe: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToFirestore() async {
    if (_recipeData == null) return;

    await FirebaseFirestore.instance.collection('recipes').add({
      'title': _recipeData!['title'],
      'description': _recipeData!['description'],
      'ingredients': _recipeData!['ingredients']
          .map((e) => {'name': e, 'isProminent': false})
          .toList(),
      'instructions': _recipeData!['instructions'],
      'sourceUrl': _recipeData!['sourceUrl'],
      'prepTime': 0,
      'cookTime': 0,
      'servings': 1,
      'originalYield': 1,
      'isCooked': false,
      'isFavorite': false,
      'rating': null,
      'mealTypeTags': [],
      'dietTypeTags': [],
      'supplementalTags': [],
      'allTags': [],
      'image': null,
      'cookbookTitle': null,
      'cookbookAuthor': null,
      'dateAdded': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How URL Import Works'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Paste a recipe URL from any website'),
            Text('• We’ll extract title, ingredients, and instructions'),
            Text('• Review details before saving to your cookbook'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Import Recipe from URL'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 24),
            _buildUrlInput(),
            const SizedBox(height: 24),
            _buildImportButton(),
            const SizedBox(height: 32),
            _buildSupportedSites(),
            if (_recipeData != null) ...[
              const SizedBox(height: 24),
              _buildPreviewCard(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Text(
                'How it works',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('1. Paste a recipe URL from any cooking site'),
          const Text('2. We’ll auto-extract ingredients and steps'),
          const Text('3. Review before saving to your recipe book'),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    return TextField(
      controller: _urlController,
      decoration: InputDecoration(
        labelText: 'Recipe URL',
        hintText: 'https://example.com/recipe',
        prefixIcon: const Icon(Icons.link),
        border: const OutlineInputBorder(),
        suffixIcon: _urlController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _urlController.clear();
                    _recipeData = null;
                  });
                },
              )
            : null,
      ),
      onChanged: (_) => setState(() {}),
      keyboardType: TextInputType.url,
    );
  }

  Widget _buildImportButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _urlController.text.isNotEmpty && !_isLoading
            ? _importRecipe
            : null,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.download),
        label: Text(_isLoading ? 'Importing...' : 'Import Recipe'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSupportedSites() {
    final sites = [
      'AllRecipes.com',
      'BBC Good Food',
      'Food Network',
      'Bon Appétit',
      'Serious Eats',
      'NYT Cooking',
      'Epicurious',
      'Taste of Home',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Supported Sites',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sites
              .map(
                (site) => Chip(
                  label: Text(site),
                  backgroundColor: Colors.orange.shade50,
                  side: BorderSide(color: Colors.orange.shade200),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _recipeData!['title'] ?? 'Untitled Recipe',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if ((_recipeData!['description'] ?? '').isNotEmpty)
              Text(_recipeData!['description']),
            const Divider(height: 24),
            Text(
              'Ingredients:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 4),
            ...(_recipeData!['ingredients'] as List)
                .take(10)
                .map((e) => Text('• $e')),
            const Divider(height: 24),
            Text(
              'Instructions:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 4),
            ...(_recipeData!['instructions'] as List)
                .asMap()
                .entries
                .take(10)
                .map((e) => Text('${e.key + 1}. ${e.value}')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save to My Recipes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveToFirestore,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
