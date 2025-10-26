import 'package:flutter/material.dart';

class UrlImportScreen extends StatefulWidget {
  const UrlImportScreen({super.key});

  @override
  State<UrlImportScreen> createState() => _UrlImportScreenState();
}

class _UrlImportScreenState extends State<UrlImportScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from URL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('1. Paste a recipe URL from any website'),
                  const Text(
                      '2. We\'ll automatically extract the recipe details'),
                  const Text(
                      '3. Review and edit before saving to your library'),
                  const Text('4. Original photos and source info preserved'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // URL Input
            TextField(
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
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 24),

            // Import Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _urlController.text.isNotEmpty && !_isLoading
                    ? _importFromUrl
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Supported Sites
            Text(
              'Popular Supported Sites',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'AllRecipes.com',
                'Food Network',
                'BBC Good Food',
                'Serious Eats',
                'Bon Appétit',
                'NYT Cooking',
                'Epicurious',
                'Taste of Home',
              ]
                  .map((site) => Chip(
                        label: Text(site, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Demo placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.construction, color: Colors.orange, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Coming in Milestone 2!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'URL scraping with verification screens',
                    style: TextStyle(color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _importFromUrl() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Show coming soon message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL scraping will be implemented in Milestone 2!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('URL Import Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Works with most recipe websites'),
            Text('• Automatically extracts ingredients & instructions'),
            Text('• Preserves original photos and source info'),
            Text('• You can edit everything before saving'),
            Text('• Failed imports can be entered manually'),
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
}
