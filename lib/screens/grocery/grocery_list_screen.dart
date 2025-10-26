import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  bool _shoppingMode = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, List<Map<String, dynamic>>> _groceryItems = {
    'Pantry Items': [],
    'To-Buy Items': [],
  };

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  /// 🔄 Load all grocery items from Firestore
  Future<void> _loadFromFirestore() async {
    final snapshot = await _firestore.collection('grocery_items').get();
    final items = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

    setState(() {
      _groceryItems['Pantry Items'] =
          items.where((i) => i['category'] == 'Pantry Items').toList();
      _groceryItems['To-Buy Items'] =
          items.where((i) => i['category'] == 'To-Buy Items').toList();
    });
  }

  /// 💾 Save or update a grocery item
  Future<void> _saveItem(Map<String, dynamic> item) async {
    if (item['id'] == null || item['id'].toString().isEmpty) {
      final docRef = await _firestore.collection('grocery_items').add(item);
      item['id'] = docRef.id;
    } else {
      await _firestore.collection('grocery_items').doc(item['id']).set(item);
    }
  }

  /// ❌ Delete grocery item
  Future<void> _deleteItem(Map<String, dynamic> item, String category) async {
    if (item['id'] != null) {
      await _firestore.collection('grocery_items').doc(item['id']).delete();
    }
    setState(() => _groceryItems[category]?.remove(item));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${item['name']} deleted')));
  }

  /// ✅ Move grocery item between categories
  Future<void> _moveItem(Map<String, dynamic> item, String category) async {
    final target = category == 'Pantry Items' ? 'To-Buy Items' : 'Pantry Items';
    setState(() {
      _groceryItems[category]?.remove(item);
      item['category'] = target;
      _groceryItems[target]?.add(item);
    });
    await _saveItem(item);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Moved to $target')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            icon: Icon(
              _shoppingMode ? Icons.list_alt : Icons.shopping_cart,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _shoppingMode = !_shoppingMode),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload from Firebase',
            onPressed: _loadFromFirestore,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate',
                child: ListTile(
                  leading: Icon(Icons.auto_awesome),
                  title: Text('Generate from Calendar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'inventory',
                child: ListTile(
                  leading: Icon(Icons.inventory_2_outlined),
                  title: Text('View Pantry Summary'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.cleaning_services_outlined),
                  title: Text('Clear Checked Items'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Grocery List'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_shoppingMode) _buildProgressBar(),
          Expanded(
            child: _groceryItems.values.every((list) => list.isEmpty)
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: _groceryItems.entries
                        .map((entry) =>
                            _buildCategorySection(entry.key, entry.value))
                        .toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'grocery_fab',
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🛒 Shopping progress
  Widget _buildProgressBar() {
    final total = _getTotalCount();
    final checked = _getCheckedCount();
    final progress = total == 0 ? 0.0 : checked / total;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.primaryContainer,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_basket_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Shopping Mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Text('$checked / $total',
                  style: TextStyle(color: theme.colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  // 📦 Category section
  Widget _buildCategorySection(String title, List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              title == 'Pantry Items'
                  ? Icons.kitchen_outlined
                  : Icons.shopping_basket_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _buildGroceryTile(item, title)),
        const SizedBox(height: 16),
      ],
    );
  }

  // 🧾 Grocery tile
  Widget _buildGroceryTile(Map<String, dynamic> item, String category) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(item['id']),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteItem(item, category),
      child: Card(
        child: ListTile(
          leading: _shoppingMode
              ? Checkbox(
                  value: item['checked'] ?? false,
                  onChanged: (v) {
                    setState(() => item['checked'] = v ?? false);
                    _saveItem(item);
                  },
                )
              : CircleAvatar(
                  backgroundColor: _getAisleColor(item['aisle']),
                  child: Icon(
                    _getAisleIcon(item['aisle']),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
          title: Text(
            item['name'],
            style: TextStyle(
              decoration: _shoppingMode && (item['checked'] ?? false)
                  ? TextDecoration.lineThrough
                  : null,
              color: _shoppingMode && (item['checked'] ?? false)
                  ? Colors.grey
                  : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text('${item['quantity']} • ${item['aisle']}'),
          trailing: !_shoppingMode
              ? PopupMenuButton<String>(
                  onSelected: (v) => _handleItemAction(v, item, category),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Item'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'move',
                      child: ListTile(
                        leading: Icon(Icons.swap_horiz),
                        title: Text('Move Category'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                )
              : ((item['checked'] ?? false)
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null),
        ),
      ),
    );
  }

  // 🧩 Helpers
  int _getCheckedCount() =>
      _groceryItems.values.expand((e) => e).where((i) => i['checked'] == true).length;

  int _getTotalCount() => _groceryItems.values.expand((e) => e).length;

  Color _getAisleColor(String aisle) {
    switch (aisle.toLowerCase()) {
      case 'produce':
        return Colors.green;
      case 'meat':
        return Colors.redAccent;
      case 'dairy':
        return Colors.blue;
      case 'bakery':
        return Colors.orange;
      case 'spices':
        return Colors.brown;
      case 'oils':
        return Colors.amber;
      case 'baking':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getAisleIcon(String aisle) {
    switch (aisle.toLowerCase()) {
      case 'produce':
        return Icons.eco;
      case 'meat':
        return Icons.set_meal;
      case 'dairy':
        return Icons.local_drink;
      case 'bakery':
        return Icons.bakery_dining;
      case 'spices':
        return Icons.grass;
      case 'oils':
        return Icons.water_drop;
      case 'baking':
        return Icons.cake;
      default:
        return Icons.shopping_basket;
    }
  }

  // ✏️ Edit Item
  void _editItem(Map<String, dynamic> item) {
    final nameCtrl = TextEditingController(text: item['name']);
    final qtyCtrl = TextEditingController(text: item['quantity']);
    String aisle = item['aisle'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: aisle,
                decoration: const InputDecoration(
                  labelText: 'Aisle',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  'Produce',
                  'Meat',
                  'Dairy',
                  'Bakery',
                  'Spices',
                  'Oils',
                  'Baking',
                ].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (v) => aisle = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item['name'] = nameCtrl.text;
                item['quantity'] = qtyCtrl.text;
                item['aisle'] = aisle;
              });
              _saveItem(item);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ➕ Add Item
  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: "1 unit");
    String aisle = 'Produce';
    String category = 'To-Buy Items';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add Grocery Item',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: aisle,
                  decoration: const InputDecoration(
                    labelText: 'Aisle',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    'Produce',
                    'Meat',
                    'Dairy',
                    'Bakery',
                    'Spices',
                    'Oils',
                    'Baking',
                  ].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                  onChanged: (v) => aisle = v!,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _groceryItems.keys
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => category = v!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;
                    final newItem = {
                      'id': '',
                      'name': nameCtrl.text,
                      'quantity': qtyCtrl.text,
                      'aisle': aisle,
                      'category': category,
                      'checked': false,
                    };
                    setState(() => _groceryItems[category]?.add(newItem));
                    _saveItem(newItem);
                    Navigator.pop(context);
                  },
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧠 Menu actions remain same
  void _handleMenuAction(String action) {
    switch (action) {
      case 'generate':
        _generateFromCalendar();
        break;
      case 'inventory':
        _showInventorySummary();
        break;
      case 'clear':
        _confirmClearChecked();
        break;
      case 'share':
        _simulateShare();
        break;
    }
  }

  void _generateFromCalendar() =>
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Generated grocery list from calendar (demo)'),
      ));

  void _showInventorySummary() {
    final total = _groceryItems['Pantry Items']?.length ?? 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pantry Summary'),
        content: Text('You currently have $total pantry items.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _confirmClearChecked() {
    final hasChecked = _getCheckedCount() > 0;
    if (!hasChecked) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No checked items to clear.')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Checked Items'),
        content: const Text('This will permanently remove all checked items.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (var cat in _groceryItems.values) {
                  cat.removeWhere((i) => i['checked'] == true);
                }
              });
              _firestore
                  .collection('grocery_items')
                  .where('checked', isEqualTo: true)
                  .get()
                  .then((snap) {
                for (var doc in snap.docs) {
                  doc.reference.delete();
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // 📤 Share grocery list via share_plus
  Future<void> _simulateShare() async {
    final buffer = StringBuffer();
    buffer.writeln('🛒 My Grocery List\n');
    _groceryItems.forEach((category, items) {
      if (items.isNotEmpty) {
        buffer.writeln('📂 $category');
        for (var item in items) {
          final checked = item['checked'] ? '✅' : '⬜';
          buffer.writeln(
            '$checked ${item['name']} — ${item['quantity']} (${item['aisle']})',
          );
        }
        buffer.writeln('');
      }
    });

    final listText = buffer.toString();

    try {
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text: listText,
          title: 'My Grocery List',
          subject: 'My Weekly Grocery List',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing list: $e')));
    }
  }

  // 🛍 Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text('No grocery items yet'),
            const SizedBox(height: 8),
            const Text('Tap + to start building your list.'),
          ],
        ),
      ),
    );
  }

  // 🛠️ Handle item popup menu actions
  void _handleItemAction(String action, Map<String, dynamic> item, String category) {
    switch (action) {
      case 'edit':
        _editItem(item);
        break;
      case 'move':
        _moveItem(item, category);
        break;
      case 'delete':
        _deleteItem(item, category);
        break;
    }
  }
}
