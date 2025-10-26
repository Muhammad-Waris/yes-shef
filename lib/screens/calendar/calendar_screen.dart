import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  final DateTime _today = DateTime.now();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<DateTime, List<Map<String, dynamic>>> _meals = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
    _focusedMonth = _selectedDate;
    _setupAnimation();
    _loadMealsFromFirestore();
  }

  void _setupAnimation() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // 🔥 Load all meals from Firestore
  Future<void> _loadMealsFromFirestore() async {
    final snapshot = await _firestore.collection('calendar_meals').get();
    final loadedMeals = <DateTime, List<Map<String, dynamic>>>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final dayKey = DateTime(date.year, date.month, date.day);
      loadedMeals.putIfAbsent(dayKey, () => []);
      loadedMeals[dayKey]!.add({
        'id': doc.id,
        'type': data['type'],
        'recipe': data['recipe'],
        'time': data['time'],
        'servings': data['servings'],
        'color': Color(data['color']),
      });
    }

    setState(() => _meals.addAll(loadedMeals));
  }

  // 💾 Save meal to Firestore
  Future<void> _saveMealToFirestore(
    DateTime date,
    Map<String, dynamic> meal,
  ) async {
    final doc = await _firestore.collection('calendar_meals').add({
      'date': date,
      'type': meal['type'],
      'recipe': meal['recipe'],
      'time': meal['time'],
      'servings': meal['servings'],
      'color': (meal['color'] as Color).value,
    });
    meal['id'] = doc.id;
  }

  // ❌ Delete meal from Firestore
  Future<void> _deleteMealFromFirestore(String id) async {
    await _firestore.collection('calendar_meals').doc(id).delete();
  }

  // 🧩 UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 110,
                backgroundColor: theme.colorScheme.primary,
                flexibleSpace: const FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: 16, bottom: 12),
                  title: Text(
                    'Meal Calendar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.today),
                    onPressed: () => setState(() {
                      _selectedDate = _today;
                      _focusedMonth = _today;
                    }),
                  ),
                ],
              ),
              SliverToBoxAdapter(child: _buildMonthHeader(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map(
                          (day) => Text(
                            day,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildCalendarGrid(context),
                ),
              ),
              SliverToBoxAdapter(child: _buildMealsSection(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    final theme = Theme.of(context);
    final month = DateFormat.MMMM().format(_focusedMonth);
    final year = _focusedMonth.year.toString();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month - 1,
              );
            }),
          ),
          Column(
            children: [
              Text(
                month,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                year,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 28),
            onPressed: () => setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month + 1,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final theme = Theme.of(context);

    return GridView.builder(
      itemCount: 42,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        final dayNum = index - firstWeekday + 1;
        final currentDate = DateTime(
          _focusedMonth.year,
          _focusedMonth.month,
          dayNum,
        );
        final isValid = dayNum > 0 && dayNum <= totalDays;
        final isSelected = _isSameDay(currentDate, _selectedDate);
        final isToday = _isSameDay(currentDate, _today);
        final meals = _getMealsForDate(currentDate);

        return isValid
            ? GestureDetector(
                onTap: () => setState(() => _selectedDate = currentDate),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : isToday
                        ? theme.colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        dayNum.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      if (meals.isNotEmpty)
                        Positioned(
                          bottom: 6,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: meals
                                .take(3)
                                .map(
                                  (m) => Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: m['color'] ?? theme.primaryColor,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildMealsSection(BuildContext context) {
    final meals = _getMealsForDate(_selectedDate);
    final theme = Theme.of(context);
    final dateText = DateFormat(
      'EEEE, MMM d, yyyy',
    ).format(_selectedDate).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                dateText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                onPressed: _showAddMealDialog,
                tooltip: 'Add Meal',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No meals planned for this day.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              itemCount: meals.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final meal = meals[i];
                return Dismissible(
                  key: ValueKey(meal['id'] ?? meal['recipe']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onDismissed: (_) async {
                    await _deleteMealFromFirestore(meal['id']);
                    setState(() => meals.removeAt(i));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meal deleted')),
                    );
                  },
                  child: _buildMealTile(meal),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMealTile(Map<String, dynamic> meal) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (meal['color'] as Color?)?.withValues(alpha: 0.2) ??
              Colors.grey[200],
          child: Icon(
            _getMealIcon(meal['type']),
            color: meal['color'] ?? Colors.blue,
          ),
        ),
        title: Text(
          '${meal['type']}: ${meal['recipe']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${meal['time']} • ${meal['servings']} servings'),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Map<String, dynamic>> _getMealsForDate(DateTime date) =>
      _meals[DateTime(date.year, date.month, date.day)] ?? [];

  IconData _getMealIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  // ➕ Add Meal Dialog
  void _showAddMealDialog() {
    final titleController = TextEditingController();
    final typeController = TextEditingController();
    final timeController = TextEditingController();
    final servingsController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Meal Type'),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Recipe Name'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Time (e.g. 7:00 PM)',
              ),
            ),
            TextField(
              controller: servingsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Servings'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  typeController.text.isEmpty ||
                  timeController.text.isEmpty)
                return;
              final dateKey = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
              );
              final newMeal = {
                'type': typeController.text,
                'recipe': titleController.text,
                'time': timeController.text,
                'servings': int.tryParse(servingsController.text) ?? 1,
                'color': Colors.blueAccent,
              };
              setState(() {
                _meals.putIfAbsent(dateKey, () => []);
                _meals[dateKey]!.add(newMeal);
              });
              await _saveMealToFirestore(dateKey, newMeal);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
