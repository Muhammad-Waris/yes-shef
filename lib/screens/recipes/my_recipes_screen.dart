import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yes_chef/screens/add_recipe/manual_entry_screen.dart';
import 'package:yes_chef/screens/add_recipe/ocr_scan.dart';
import 'package:yes_chef/screens/add_recipe/url_import_screen.dart';

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
  String _searchMode = 'general';

  final List<String> _filters = const [
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

  CollectionReference<Map<String, dynamic>> get _recipesCol =>
      FirebaseFirestore.instance.collection('recipes');

  Query<Map<String, dynamic>> _baseQueryForSelectedFilter() {
    Query<Map<String, dynamic>> q = _recipesCol.orderBy(
      'dateAdded',
      descending: true,
    );

    switch (_selectedFilter) {
      case 'Favorites':
        q = q.where('isFavorite', isEqualTo: true);
        break;
      case 'Cooked':
        q = q.where('isCooked', isEqualTo: true);
        break;
      case 'Recent':
        break;
      case 'All':
        break;
      default:
        q = q.where('allTags', arrayContains: _selectedFilter);
        break;
    }
    return q.limit(200);
  }

  List<Map<String, dynamic>> _applyLocalFilters(
    List<Map<String, dynamic>> recipes,
  ) {
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      recipes = recipes.where((r) {
        final title = (r['title'] ?? '').toString().toLowerCase();
        final ingredients = (r['ingredients'] as List? ?? [])
            .map((i) => (i['name'] ?? '').toString().toLowerCase())
            .join(' ');
        final author = (r['cookbookAuthor'] ?? '').toString().toLowerCase();
        final cookbook = (r['cookbookTitle'] ?? '').toString().toLowerCase();
        return title.contains(query) ||
            ingredients.contains(query) ||
            author.contains(query) ||
            cookbook.contains(query);
      }).toList();
    }

    if (_prominentIngredientController.text.isNotEmpty) {
      final query = _prominentIngredientController.text.toLowerCase();
      if (_searchMode == 'prominent') {
        recipes = recipes.where((r) {
          final prominent = (r['ingredients'] as List? ?? [])
              .where((i) => i is Map && i['isProminent'] == true)
              .map((i) => (i['name'] ?? '').toString().toLowerCase())
              .join(' ');
          return prominent.contains(query);
        }).toList();
      }
    }

    if (_cookbookController.text.isNotEmpty) {
      final query = _cookbookController.text.toLowerCase();
      recipes = recipes.where((r) {
        final author = (r['cookbookAuthor'] ?? '').toString().toLowerCase();
        final cookbook = (r['cookbookTitle'] ?? '').toString().toLowerCase();
        return author.contains(query) || cookbook.contains(query);
      }).toList();
    }

    if (_selectedFilter == 'Recent') {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      recipes = recipes.where((r) {
        final ts = r['dateAdded'];
        DateTime? when;
        if (ts is Timestamp) when = ts.toDate();
        if (ts is DateTime) when = ts;
        return (when ?? DateTime.fromMillisecondsSinceEpoch(0)).isAfter(cutoff);
      }).toList();
    }

    if (_prominentIngredientController.text.isNotEmpty &&
        _searchMode == 'prominent') {
      final query = _prominentIngredientController.text.toLowerCase();
      recipes.sort((a, b) {
        final aProm = ((a['ingredients'] as List? ?? []).where(
          (i) =>
              i is Map &&
              i['isProminent'] == true &&
              (i['name'] ?? '').toString().toLowerCase().contains(query),
        )).isNotEmpty;
        final bProm = ((b['ingredients'] as List? ?? []).where(
          (i) =>
              i is Map &&
              i['isProminent'] == true &&
              (i['name'] ?? '').toString().toLowerCase().contains(query),
        )).isNotEmpty;
        if (aProm && !bProm) return -1;
        if (!aProm && bProm) return 1;
        return 0;
      });
    }

    return recipes;
  }

  Future<void> _toggleFavorite(String docId, bool next) async {
    await _recipesCol.doc(docId).update({'isFavorite': next});
  }

  Future<void> _toggleCooked(String docId, bool next) async {
    await _recipesCol.doc(docId).update({'isCooked': next});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Recipes'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () => _showSearchDialog(context),
          //   tooltip: 'Advanced search',
          // ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filter & sort',
          ),
        ],
      ),
      body: Column(
        children: [
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
                fillColor: Colors.white,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
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
                    onSelected: (_) {
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
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _baseQueryForSelectedFilter().snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;

                final recipes = docs
                    .map<Map<String, dynamic>>((d) => {'id': d.id, ...d.data()})
                    .toList();

                final filtered = _applyLocalFilters(recipes);

                if (filtered.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final recipe = filtered[index];
                    return _buildRecipeCard(recipe);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final id = (recipe['id'] ?? '') as String;
    final prep = (recipe['prepTime'] ?? 0) as int;
    final cook = (recipe['cookTime'] ?? 0) as int;
    final totalTime = prep + cook;
    final isQuick = totalTime <= 30;
    final ingredients = (recipe['ingredients'] as List? ?? []);
    final prominentCount = ingredients
        .where((i) => i is Map && i['isProminent'] == true)
        .length;

    final isFavorite = recipe['isFavorite'] == true;
    final isCooked = recipe['isCooked'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(
                recipe: recipe,
                onToggleCooked: (next) => _toggleCooked(id, next),
                onToggleFavorite: (next) => _toggleFavorite(id, next),
              ),
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
                                (recipe['title'] ?? '') as String,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isQuick) _tinyPill('QUICK', Colors.green),
                            if (isCooked) ...[
                              const SizedBox(width: 6),
                              _tinyPill('COOKED', Colors.blue),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (recipe['description'] ?? '') as String,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
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
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  (recipe['cookbookTitle'] ?? 'Web Recipe')
                                      as String,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.black54,
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
                      if (recipe['rating'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFC107,
                            ).withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                recipe['rating'].toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => _toggleFavorite(id, !isFavorite),
                        tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.access_time, '$totalTime min'),
                  _buildInfoChip(
                    Icons.people,
                    'Serves ${recipe['originalYield'] ?? recipe['servings'] ?? '-'} (original)',
                  ),
                  _buildInfoChip(
                    Icons.star_outline,
                    '$prominentCount key ingredients',
                  ),
                  if (recipe['sourceUrl'] != null)
                    _buildInfoChip(Icons.link, 'Web'),
                  if (recipe['cookbookTitle'] != null)
                    _buildInfoChip(Icons.book, 'Cookbook'),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ...((recipe['mealTypeTags'] as List? ?? [])
                                .cast<String>())
                            .map(
                              (tag) => _tagChip(
                                tag,
                                Theme.of(context).colorScheme.primaryContainer,
                              ),
                            ),
                        ...((recipe['dietTypeTags'] as List? ?? [])
                                .cast<String>()
                                .take(1))
                            .map(
                              (tag) => _tagChip(
                                tag,
                                Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                              ),
                            ),
                        ...((recipe['supplementalTags'] as List? ?? [])
                                .cast<String>()
                                .take(1))
                            .map(
                              (tag) => _tagChip(
                                tag,
                                Theme.of(context).colorScheme.tertiaryContainer,
                              ),
                            ),
                      ],
                    ),
                  ),
                  if (isCooked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'COOKED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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

  Widget _tinyPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _tagChip(String tag, Color bg) {
    return Chip(
      label: Text(tag, style: const TextStyle(fontSize: 11)),
      backgroundColor: bg,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .04),
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
        children: const [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.black26),
          SizedBox(height: 16),
          Text('No recipes found', style: TextStyle(fontSize: 22)),
          SizedBox(height: 8),
          Text(
            'Start by adding your first recipe!',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // void _showSearchDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Colors.white,
  //       title: const Text('Advanced Search'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.symmetric(vertical: 8),
  //               child: Row(
  //                 children: [
  //                   const Text('Search Mode: '),
  //                   const SizedBox(width: 8),
  //                   ToggleButtons(
  //                     isSelected: [
  //                       _searchMode == 'general',
  //                       _searchMode == 'prominent',
  //                     ],
  //                     onPressed: (index) {
  //                       setState(() {
  //                         _searchMode = index == 0 ? 'general' : 'prominent';
  //                       });
  //                     },
  //                     children: const [
  //                       Padding(
  //                         padding: EdgeInsets.symmetric(horizontal: 12),
  //                         child: Text('General'),
  //                       ),
  //                       Padding(
  //                         padding: EdgeInsets.symmetric(horizontal: 12),
  //                         child: Text('Prominent'),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 16),

  //             TextField(
  //               controller: _searchController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Recipe name or general ingredient',
  //                 border: OutlineInputBorder(),
  //                 hintText: 'e.g., pasta, chicken',
  //               ),
  //             ),
  //             const SizedBox(height: 16),

  //             TextField(
  //               controller: _prominentIngredientController,
  //               decoration: InputDecoration(
  //                 labelText: _searchMode == 'prominent'
  //                     ? 'Prominent ingredients (priority search)'
  //                     : 'Prominent ingredients',
  //                 border: const OutlineInputBorder(),
  //                 hintText: 'e.g., garlic, tomatoes',
  //                 helperText:
  //                     'Searches ingredients marked as prominent in recipes',
  //               ),
  //             ),
  //             const SizedBox(height: 16),

  //             TextField(
  //               controller: _cookbookController,
  //               decoration: const InputDecoration(
  //                 labelText: 'Cookbook or Author',
  //                 border: OutlineInputBorder(),
  //                 hintText: 'e.g., Julia Child, Italian Classics',
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             setState(() {
  //               _searchController.clear();
  //               _prominentIngredientController.clear();
  //               _cookbookController.clear();
  //             });
  //           },
  //           child: const Text('Clear'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             setState(() {});
  //             Navigator.pop(context);
  //           },
  //           child: const Text('Search'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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

              const Text(
                'Meal Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                          'breakfast',
                          'dinner',
                          'snacks & apps',
                          'dessert',
                          'drinks',
                        ]
                        .map(
                          (type) => FilterChip(
                            label: Text(type),
                            selected: _selectedFilter == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = selected ? type : 'All';
                              });
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),

              const Text(
                'Diet Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                          'vegetarian',
                          'meat',
                          'seafood',
                          'gluten-free',
                          'mediterranean',
                        ]
                        .map(
                          (type) => FilterChip(
                            label: Text(type),
                            selected: _selectedFilter == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = selected ? type : 'All';
                              });
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),

              const Text(
                'Supplemental',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                          'quick',
                          'healthy',
                          'grill',
                          'stovetop',
                          'oven',
                          'InstantPot',
                          'air fryer',
                        ]
                        .map(
                          (type) => FilterChip(
                            label: Text(type),
                            selected: _selectedFilter == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = selected ? type : 'All';
                              });
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),

              const Text(
                'Cook Time Range',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RangeSlider(
                values: RangeValues(0, 60),
                max: 120,
                divisions: 12,
                labels: RangeLabels('0 min', '60 min'),
                onChanged: null,
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

  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Add New Recipe',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),

            // 1️⃣ Import from URL
            ListTile(
              leading: _buildIconTile(Icons.link, Colors.blue),
              title: const Text('Import from URL'),
              subtitle: const Text('Scrape recipe from website'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UrlImportScreen()),
                );
              },
            ),

            // 2️⃣ Scan Recipe (OCR)
            ListTile(
              leading: _buildIconTile(Icons.camera_alt, Colors.green),
              title: const Text('Scan Recipe (OCR)'),
              subtitle: const Text('Photo → editable text'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OCRScanScreen()),
                );
              },
            ),

            // 3️⃣ Manual Entry
            ListTile(
              leading: _buildIconTile(Icons.edit, Colors.purple),
              title: const Text('Enter Manually'),
              subtitle: const Text('Type recipe from scratch'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManualEntryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTile(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final Future<void> Function(bool next)? onToggleCooked;
  final Future<void> Function(bool next)? onToggleFavorite;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.onToggleCooked,
    this.onToggleFavorite,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final double _scaleFactor = 1.0;

  int get _scaledServings {
    final num base =
        ((widget.recipe['servings'] ?? widget.recipe['originalYield'] ?? 0)
                as num)
            .toDouble();
    return (base * _scaleFactor).round();
  }

  Future<void> _shareRecipe() async {
    final title = widget.recipe['title'] ?? 'Recipe';
    final desc = widget.recipe['description'] ?? '';
    final ingredients = ((widget.recipe['ingredients'] as List?) ?? [])
        .map((ing) {
          if (ing is Map) {
            return "${ing['amount'] ?? ''} ${ing['unit'] ?? ''} ${ing['name'] ?? ''}";
          } else {
            return ing.toString();
          }
        })
        .join('\n');

    final instructions = ((widget.recipe['instructions'] as List?) ?? [])
        .cast<String>()
        .map((s) => '• $s')
        .join('\n');

    final shareText =
        '''
$title

$desc

🕐 Prep: ${widget.recipe['prepTime'] ?? '-'} min
🔥 Cook: ${widget.recipe['cookTime'] ?? '-'} min
👨‍🍳 Serves: $_scaledServings

🥕 Ingredients:
$ingredients

📋 Instructions:
$instructions
''';

    try {
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          title: 'Recipe: $title',
          subject: 'Shared from YesChef App',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing recipe: $e')));
    }
  }

  // Edit recipe via bottom sheet
  void _editRecipe() {
    final titleCtrl = TextEditingController(text: widget.recipe['title'] ?? '');
    final descCtrl = TextEditingController(
      text: widget.recipe['description'] ?? '',
    );
    final prepCtrl = TextEditingController(
      text: widget.recipe['prepTime']?.toString() ?? '',
    );
    final cookCtrl = TextEditingController(
      text: widget.recipe['cookTime']?.toString() ?? '',
    );
    final servingsCtrl = TextEditingController(
      text: widget.recipe['servings']?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 10,
        ),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Recipe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: prepCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prep (min)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: cookCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cook (min)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: servingsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Servings',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.recipe['title'] = titleCtrl.text;
                      widget.recipe['description'] = descCtrl.text;
                      widget.recipe['prepTime'] = prepCtrl.text;
                      widget.recipe['cookTime'] = cookCtrl.text;
                      widget.recipe['servings'] = servingsCtrl.text;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recipe updated successfully!'),
                      ),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFav = widget.recipe['isFavorite'] == true;
    final cooked = widget.recipe['isCooked'] == true;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.recipe['title'] ?? 'Recipe'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Recipe',
            onPressed: _shareRecipe,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Recipe',
            onPressed: _editRecipe,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, size: 64),
            ),
            const SizedBox(height: 16),

            // Title, Description, Favorite
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe['title'] ?? '',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.recipe['description'] ?? '',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : theme.iconTheme.color,
                  ),
                  onPressed: () async {
                    final next = !isFav;
                    setState(() => widget.recipe['isFavorite'] = next);
                    if (widget.onToggleFavorite != null) {
                      await widget.onToggleFavorite!(next);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info cards
            Row(
              children: [
                _buildInfoCard(
                  Icons.access_time,
                  'Prep',
                  '${widget.recipe['prepTime'] ?? 0} min',
                ),
                const SizedBox(width: 12),
                _buildInfoCard(
                  Icons.schedule,
                  'Cook',
                  '${widget.recipe['cookTime'] ?? 0} min',
                ),
                const SizedBox(width: 12),
                _buildInfoCard(Icons.people, 'Serves', '$_scaledServings'),
              ],
            ),
            const SizedBox(height: 20),

            // Ingredients
            Text(
              'Ingredients',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: ((widget.recipe['ingredients'] as List?) ?? [])
                      .map<Widget>(
                        (i) => Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              i is Map
                                  ? "${i['amount'] ?? ''} ${i['unit'] ?? ''} ${i['name'] ?? ''}"
                                  : i.toString(),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Instructions
            Text(
              'Instructions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ((widget.recipe['instructions'] as List?) ?? [])
                      .cast<String>()
                      .asMap()
                      .entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('${e.key + 1}. ${e.value}'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () async {
            final next = !cooked;
            setState(() => widget.recipe['isCooked'] = next);
            if (widget.onToggleCooked != null) {
              await widget.onToggleCooked!(next);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  next
                      ? 'Recipe marked as cooked!'
                      : 'Recipe marked as not cooked.',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(cooked ? 'Mark as Not Cooked' : 'Mark as Cooked'),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 6),
              Text(label),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
