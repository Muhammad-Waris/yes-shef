import 'package:flutter/material.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  bool _shoppingMode = false;

  // Mock grocery data with complete pantry/to-buy logic
  final Map<String, List<Map<String, dynamic>>> _groceryItems = {
    'Pantry Items': [
      {
        'id': '1',
        'name': 'Salt',
        'quantity': '1 container',
        'aisle': 'Spices',
        'checked': false,
        'notes': 'Sea salt preferred',
        'excess': null,
      },
      {
        'id': '2',
        'name': 'All-Purpose Flour',
        'quantity': '5 lb bag',
        'aisle': 'Baking',
        'checked': true,
        'notes': '',
        'excess': '2 cups excess',
      },
      {
        'id': '3',
        'name': 'Olive Oil',
        'quantity': '1 bottle (500ml)',
        'aisle': 'Oils',
        'checked': false,
        'notes': 'Extra virgin',
        'excess': null,
      },
    ],
    'To-Buy Items': [
      {
        'id': '4',
        'name': 'Chicken Breast',
        'quantity': '2 lbs',
        'aisle': 'Meat',
        'checked': false,
        'notes': 'Organic preferred',
        'excess': null,
      },
      {
        'id': '5',
        'name': 'Roma Tomatoes',
        'quantity': '6 large (need 4)',
        'aisle': 'Produce',
        'checked': false,
        'notes': 'Ripe but firm',
        'excess': '2 tomatoes excess',
      },
      {
        'id': '6',
        'name': 'Whole Milk',
        'quantity': '1 gallon',
        'aisle': 'Dairy',
        'checked': true,
        'notes': '',
        'excess': null,
      },
      {
        'id': '7',
        'name': 'Sourdough Bread',
        'quantity': '1 loaf',
        'aisle': 'Bakery',
        'checked': false,
        'notes': 'Sliced',
        'excess': null,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Lists'),
        actions: [
          IconButton(
            icon: Icon(_shoppingMode ? Icons.list : Icons.shopping_cart),
            onPressed: () {
              setState(() {
                _shoppingMode = !_shoppingMode;
              });
            },
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
                  leading: Icon(Icons.inventory),
                  title: Text('Check Pantry'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear Checked'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share List'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Shopping Mode Header
          if (_shoppingMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Shopping Mode',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_getCheckedCount()}/${_getTotalCount()} items',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _getTotalCount() > 0
                        ? _getCheckedCount() / _getTotalCount()
                        : 0,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

          // Grocery Lists
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _groceryItems.entries.map((category) {
                return _buildCategorySection(category.key, category.value);
              }).toList(),
            ),
          ),
        ],
      ),
      // FIXED: Add unique hero tag to avoid conflicts
      floatingActionButton: FloatingActionButton(
        heroTag: "grocery_fab", // Fixed: Add unique hero tag
        onPressed: () => _showAddItemDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategorySection(
      String category, List<Map<String, dynamic>> items) {
    final checkedCount = items.where((item) => item['checked']).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(
                category == 'Pantry Items' ? Icons.home : Icons.shopping_basket,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (_shoppingMode)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: checkedCount == items.length
                        ? Colors.green
                        : Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$checkedCount/${items.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: checkedCount == items.length
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Category Description
        if (category == 'Pantry Items')
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Items typically found in inside aisles (spices, oils, flour, etc.)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),

        // Items
        ...items.map((item) => _buildGroceryItem(item, category)),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGroceryItem(Map<String, dynamic> item, String category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: item['checked'] && _shoppingMode ? 1 : 2,
      child: ListTile(
        leading: _shoppingMode
            ? Checkbox(
                value: item['checked'],
                onChanged: (value) {
                  setState(() {
                    item['checked'] = value ?? false;
                  });
                  if (value == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✓ ${item['name']} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAisleColor(item['aisle']),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAisleIcon(item['aisle']),
                  color: Colors.white,
                  size: 20,
                ),
              ),
        title: Text(
          item['name'],
          style: TextStyle(
            decoration: item['checked'] && _shoppingMode
                ? TextDecoration.lineThrough
                : null,
            color: item['checked'] && _shoppingMode
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(item['aisle']),
                const SizedBox(width: 12),
                Icon(Icons.shopping_bag,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(child: Text(item['quantity'])),
              ],
            ),
            if (item['excess'] != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Excess: ${item['excess']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (item['notes']?.isNotEmpty == true) ...[
              const SizedBox(height: 2),
              Text(
                'Note: ${item['notes']}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: !_shoppingMode
            ? PopupMenuButton<String>(
                onSelected: (value) => _handleItemAction(value, item, category),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'move',
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz),
                      title: Text('Move Category'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title:
                          Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              )
            : item['checked']
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
      ),
    );
  }

  // Helper methods
  Color _getAisleColor(String aisle) {
    switch (aisle.toLowerCase()) {
      case 'produce':
        return Colors.green;
      case 'meat':
        return Colors.red;
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
        return Theme.of(context).colorScheme.primary;
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

  int _getCheckedCount() {
    return _groceryItems.values
        .expand((items) => items)
        .where((item) => item['checked'])
        .length;
  }

  int _getTotalCount() {
    return _groceryItems.values.expand((items) => items).length;
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'generate':
        _showGenerateListDialog();
        break;
      case 'inventory':
        _showInventoryDialog();
        break;
      case 'clear':
        _clearCheckedItems();
        break;
      case 'share':
        _shareList();
        break;
    }
  }

  void _handleItemAction(
      String action, Map<String, dynamic> item, String category) {
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

  void _showGenerateListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Grocery List'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select date range from your meal calendar:'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'End Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Calendar integration coming in Milestone 2!')),
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showInventoryDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pantry inventory check coming soon!')),
    );
  }

  void _clearCheckedItems() {
    setState(() {
      for (var category in _groceryItems.values) {
        category.removeWhere((item) => item['checked']);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checked items cleared')),
    );
  }

  void _shareList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _editItem(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit item functionality coming soon!')),
    );
  }

  void _moveItem(Map<String, dynamic> item, String fromCategory) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Move item functionality coming soon!')),
    );
  }

  void _deleteItem(Map<String, dynamic> item, String category) {
    setState(() {
      _groceryItems[category]?.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} deleted')),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    String selectedCategory = 'To-Buy Items';
    String selectedAisle = 'Produce';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Grocery Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _groceryItems.keys
                    .map((category) => DropdownMenuItem(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => selectedCategory = value!);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedAisle,
                decoration: const InputDecoration(
                  labelText: 'Aisle',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Produce',
                  'Meat',
                  'Dairy',
                  'Bakery',
                  'Spices',
                  'Oils',
                  'Baking'
                ]
                    .map((aisle) =>
                        DropdownMenuItem(value: aisle, child: Text(aisle)))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => selectedAisle = value!);
                },
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
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _groceryItems[selectedCategory]?.add({
                      'id': '${DateTime.now().millisecondsSinceEpoch}',
                      'name': nameController.text,
                      'quantity': '1 item',
                      'aisle': selectedAisle,
                      'checked': false,
                      'notes': '',
                      'excess': null,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
