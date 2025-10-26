import 'package:flutter/material.dart';
import 'package:yes_chef/screens/recipes/url_import_screen.dart';

class OCRImportScreen extends StatefulWidget {
  const OCRImportScreen({super.key});

  @override
  State<OCRImportScreen> createState() => _OCRImportScreenState();
}

class _OCRImportScreenState extends State<OCRImportScreen> {
  bool _isProcessing = false;
  // String? _selectedImagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Recipe Photo')),
      body: Padding(
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
                          Icons.camera_alt,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Photo Tips',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Ensure good lighting - avoid shadows\n'
                      '• Hold camera steady and straight\n'
                      '• Make sure text is clear and in focus\n'
                      '• Include the full recipe in the frame',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Image Capture Options
            Text(
              'Choose Image Source',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Camera Option
            Card(
              child: InkWell(
                onTap: _isProcessing ? null : () => _captureImage('camera'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Take Photo Now',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use your camera to capture a recipe',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Gallery Option
            Card(
              child: InkWell(
                onTap: _isProcessing ? null : () => _captureImage('gallery'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.photo_library,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload from Gallery',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose an existing photo from your device',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Processing Indicator
            if (_isProcessing) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Processing Image...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'Using OCR to extract recipe text',
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
            ],

            // Common Issues
            if (!_isProcessing) ...[
              Text(
                'Common Issues',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIssueItem(
                        Icons.warning_amber,
                        'Photo too blurry or dim',
                        'Take a new photo with better lighting',
                      ),
                      const SizedBox(height: 8),
                      _buildIssueItem(
                        Icons.text_fields,
                        'Handwritten text not recognized',
                        'Try printing the recipe if possible',
                      ),
                      const SizedBox(height: 8),
                      _buildIssueItem(
                        Icons.format_size,
                        'Small text hard to read',
                        'Get closer or crop to the recipe area',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIssueItem(IconData icon, String title, String solution) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                solution,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _captureImage(String source) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate image capture and OCR processing
      await Future.delayed(const Duration(seconds: 3));

      // Mock OCR confidence check
      final ocrConfidence = 0.75; // 75% confidence

      if (ocrConfidence < 0.6) {
        // Show retry dialog for low confidence
        _showRetryDialog();
        return;
      }

      // Mock successful OCR extraction
      final ocrResult = {
        'extractedText': {
          'title': 'Chocolate Chip Cookies',
          'ingredients': [
            '2 1/4 cups all-purpose flour',
            '1 tsp baking soda',
            '1 tsp salt',
            '1 cup butter, softened',
            '3/4 cup granulated sugar',
            '3/4 cup packed brown sugar',
            '2 large eggs',
            '2 tsp vanilla extract',
            '2 cups chocolate chips',
          ],
          'instructions': [
            'Preheat oven to 375°F.',
            'Mix flour, baking soda and salt in bowl.',
            'Beat butter and sugars until creamy.',
            'Add eggs and vanilla, beat well.',
            'Gradually blend in flour mixture.',
            'Stir in chocolate chips.',
            'Drop by rounded tablespoons onto ungreased cookie sheets.',
            'Bake 9-11 minutes until golden brown.',
          ],
          'cookbookTitle': 'Mom\'s Recipe Collection',
          'author': 'Betty Smith',
        },
        'confidenceMap': {
          'title': 0.95,
          'ingredients': [
            0.85,
            0.90,
            0.88,
            0.92,
            0.45,
            0.87,
            0.91,
            0.89,
            0.86,
          ], // Low confidence on brown sugar
          'instructions': [0.92, 0.85, 0.88, 0.90, 0.87, 0.89, 0.84, 0.86],
          'cookbookTitle': 0.78,
          'author': 0.82,
        },
        'originalImagePath': 'mock_image_path.jpg',
      };

      setState(() {
        _isProcessing = false;
      });

      // Navigate to OCR review screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OCRReviewScreen(ocrResult: ocrResult),
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process image: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showRetryDialog() {
    setState(() {
      _isProcessing = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Quality Issue'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The photo is too dim or blurry for accurate text recognition.',
            ),
            SizedBox(height: 16),
            Text('Tips for better results:'),
            Text('• Use brighter lighting'),
            Text('• Hold the camera steady'),
            Text('• Move closer to the text'),
            Text('• Ensure the text is in focus'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class OCRReviewScreen extends StatefulWidget {
  final Map<String, dynamic> ocrResult;

  const OCRReviewScreen({super.key, required this.ocrResult});

  @override
  State<OCRReviewScreen> createState() => _OCRReviewScreenState();
}

class _OCRReviewScreenState extends State<OCRReviewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _cookbookController;
  late TextEditingController _authorController;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _instructionControllers;
  late Map<String, double> _confidenceMap;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final extractedText = widget.ocrResult['extractedText'];
    _confidenceMap = Map<String, double>.from(
      widget.ocrResult['confidenceMap'],
    );

    _titleController = TextEditingController(text: extractedText['title']);
    _cookbookController = TextEditingController(
      text: extractedText['cookbookTitle'] ?? '',
    );
    _authorController = TextEditingController(
      text: extractedText['author'] ?? '',
    );

    _ingredientControllers = (extractedText['ingredients'] as List<String>)
        .map((ingredient) => TextEditingController(text: ingredient))
        .toList();

    _instructionControllers = (extractedText['instructions'] as List<String>)
        .map((instruction) => TextEditingController(text: instruction))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review OCR Results'),
        actions: [
          TextButton(
            onPressed: _proceedToFinalConfirmation,
            child: const Text('Next'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // OCR Success Banner
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Text Extracted Successfully!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'Review the extracted text below. Yellow highlighting indicates areas that need verification.',
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

            const SizedBox(height: 16),

            // Confidence Legend
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Confidence Legend',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.yellow..withValues(alpha:0.3),
                            border: Border.all(color: Colors.yellow),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Low confidence - please verify'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey..withValues(alpha:0.3),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Good confidence - but still editable'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            _buildSectionHeader('Recipe Title'),
            const SizedBox(height: 8),
            _buildConfidenceTextField(
              controller: _titleController,
              confidence: _confidenceMap['title'] ?? 1.0,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 24),

            // Cookbook Info
            _buildSectionHeader('Source Information'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildConfidenceTextField(
                      controller: _cookbookController,
                      confidence: _confidenceMap['cookbookTitle'] ?? 1.0,
                      decoration: const InputDecoration(
                        labelText: 'Cookbook Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildConfidenceTextField(
                      controller: _authorController,
                      confidence: _confidenceMap['author'] ?? 1.0,
                      decoration: const InputDecoration(
                        labelText: 'Author',
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
                  children: [
                    ..._ingredientControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      final ingredientConfidences =
                          _confidenceMap['ingredients'] as List<double>?;
                      final confidence = ingredientConfidences?[index] ?? 1.0;

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
                              child: _buildConfidenceTextField(
                                controller: controller,
                                confidence: confidence,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
                      final instructionConfidences =
                          _confidenceMap['instructions'] as List<double>?;
                      final confidence = instructionConfidences?[index] ?? 1.0;

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
                              child: _buildConfidenceTextField(
                                controller: controller,
                                confidence: confidence,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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

  Widget _buildConfidenceTextField({
    required TextEditingController controller,
    required double confidence,
    required InputDecoration decoration,
    int maxLines = 1,
  }) {
    final isLowConfidence = confidence < 0.7;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isLowConfidence ? Colors.yellow : Colors.grey..withValues(alpha:0.5),
          width: isLowConfidence ? 2 : 1,
        ),
        color: isLowConfidence
            ? Colors.yellow.withValues(alpha:0.1)
            : Colors.grey..withValues(alpha:0.05),
      ),
      child: TextFormField(
        controller: controller,
        decoration: decoration.copyWith(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: isLowConfidence
              ? Tooltip(
                  message: 'Low confidence: ${(confidence * 100).toInt()}%',
                  child: const Icon(Icons.warning, color: Colors.orange),
                )
              : null,
        ),
        maxLines: maxLines,
      ),
    );
  }

  void _proceedToFinalConfirmation() {
    // Collect all the reviewed data
    final reviewedRecipeData = {
      'title': _titleController.text,
      'cookbookTitle': _cookbookController.text,
      'author': _authorController.text,
      'ingredients': _ingredientControllers.map((c) => c.text).toList(),
      'instructions': _instructionControllers.map((c) => c.text).toList(),
      'originalImagePath': widget.ocrResult['originalImagePath'],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FinalConfirmationScreen(recipeData: reviewedRecipeData),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
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

class FinalConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> recipeData;

  const FinalConfirmationScreen({super.key, required this.recipeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Confirmation'),
        actions: [
          TextButton(
            onPressed: () => _proceedToTagging(context),
            child: const Text('Continue'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Final Review Banner
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.preview,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Final Recipe Preview',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                          ),
                          Text(
                            'Review your complete recipe before adding tags and saving.',
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

            // Recipe Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      recipeData['title'],
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    if (recipeData['cookbookTitle']?.isNotEmpty == true ||
                        recipeData['author']?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        'From: ${recipeData['cookbookTitle']} ${recipeData['author']?.isNotEmpty == true ? 'by ${recipeData['author']}' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Ingredients
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(recipeData['ingredients'] as List<String>)
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                    const SizedBox(height: 24),

                    // Instructions
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(recipeData['instructions'] as List<String>)
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${entry.key + 1}',
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
                                  child: Text(
                                    entry.value,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  void _proceedToTagging(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagProposalScreen(recipeData: recipeData),
      ),
    );
  }
}
