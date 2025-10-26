import 'dart:io';
import 'package:flutter/material.dart';

class FinalConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final File? imageFile;

  const FinalConfirmationScreen({
    super.key,
    required this.recipe,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review & Save')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageFile != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(imageFile!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              recipe['title'] ?? 'Untitled',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              recipe['sourceUrl'] ?? 'No source',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Ingredients',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...(recipe['ingredients'] as List<dynamic>? ?? [])
                .map((i) => Text('- $i'))
                ,
            const SizedBox(height: 12),
            const Text(
              'Instructions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...(recipe['instructions'] as List<dynamic>? ?? [])
                .map((s) => Text(s))
                ,
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipe saved locally (mock).')),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const SizedBox(
                width: double.infinity,
                child: Center(child: Text('Save Recipe')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
