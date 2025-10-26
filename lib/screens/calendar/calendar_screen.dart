import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  final DateTime _today = DateTime.now();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  // Enhanced meal data with better structure
  final Map<DateTime, List<Map<String, dynamic>>> _meals = {};

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    final today = DateTime.now();

    // Today's meals
    _meals[DateTime(today.year, today.month, today.day)] = [
      {
        'id': '1',
        'type': 'Breakfast',
        'recipe': 'Avocado Toast',
        'servings': 2,
        'time': '08:00 AM',
        'isEvent': false,
        'color': Colors.orange,
      },
      {
        'id': '2',
        'type': 'Dinner',
        'recipe': 'Spaghetti Carbonara',
        'servings': 4,
        'time': '07:00 PM',
        'isEvent': true,
        'guests': 4,
        'eventTitle': 'Family Dinner',
        'dietaryRestrictions': ['Gluten-Free Available'],
        'color': Colors.purple,
      },
    ];

    // Tomorrow's meals
    _meals[DateTime(today.year, today.month, today.day + 1)] = [
      {
        'id': '3',
        'type': 'Lunch',
        'recipe': 'Caesar Salad',
        'servings': 2,
        'time': '12:30 PM',
        'isEvent': false,
        'color': Colors.green,
      },
      {
        'id': '4',
        'type': 'Snack',
        'recipe': 'Chocolate Chip Cookies',
        'servings': 6,
        'time': '03:00 PM',
        'isEvent': false,
        'color': Colors.brown,
      },
    ];

    // Day after tomorrow
    _meals[DateTime(today.year, today.month, today.day + 2)] = [
      {
        'id': '5',
        'type': 'Breakfast',
        'recipe': 'Pancakes & Syrup',
        'servings': 6,
        'time': '09:00 AM',
        'isEvent': true,
        'guests': 6,
        'eventTitle': 'Weekend Brunch',
        'color': Colors.amber,
      },
    ];

    // This weekend
    _meals[DateTime(today.year, today.month, today.day + 5)] = [
      {
        'id': '6',
        'type': 'Dinner',
        'recipe': 'BBQ Ribs',
        'servings': 8,
        'time': '06:00 PM',
        'isEvent': true,
        'guests': 8,
        'eventTitle': 'BBQ Party',
        'color': Colors.red,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: _fadeAnimation != null
            ? FadeTransition(
                opacity: _fadeAnimation!,
                child: _buildMainContent(),
              )
            : _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        // Modern App Bar
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              'Meal Calendar',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: .8),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                setState(() {
                  _selectedDate = _today;
                  _focusedDate = _today;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_view_month),
              onPressed: () => _showMonthPicker(),
            ),
          ],
        ),

        // Calendar Header with Month Navigation
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedDate =
                          DateTime(_focusedDate.year, _focusedDate.month - 1);
                    });
                  },
                  icon: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                GestureDetector(
                  onTap: _showMonthPicker,
                  child: Column(
                    children: [
                      Text(
                        _getMonthName(_focusedDate.month),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                      Text(
                        _focusedDate.year.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: .7),
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedDate =
                          DateTime(_focusedDate.year, _focusedDate.month + 1);
                    });
                  },
                  icon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Weekday Headers
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),

        // Calendar Grid
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: _buildCalendarGrid(),
          ),
        ),

        // Selected Date Section
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: .3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Date header with quick actions
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedDate.day.toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getDateString(_selectedDate),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _getDayOfWeek(_selectedDate),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.filled(
                                onPressed: () => _generateGroceryList(),
                                icon: const Icon(Icons.shopping_cart, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  minimumSize: const Size(40, 40),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: () => _showAddMealDialog(),
                                icon: const Icon(Icons.add, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  minimumSize: const Size(40, 40),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Meals list
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: _getMealsForDate(_selectedDate).isEmpty
                      ? _buildEmptyMealsState()
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: _getMealsForDate(_selectedDate).length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final meal = _getMealsForDate(_selectedDate)[index];
                            return _buildModernMealCard(meal);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 42, // 6 weeks × 7 days
        itemBuilder: (context, index) {
          final date = _getDateForIndex(index);
          final isToday = _isSameDay(date, _today);
          final isSelected = _isSameDay(date, _selectedDate);
          final mealsForDate = _getMealsForDate(date);
          final hasMeals = mealsForDate.isNotEmpty;
          final isCurrentMonth = date.month == _focusedDate.month;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : isToday
                        ? Theme.of(context).colorScheme.primaryContainer
                        : hasMeals && isCurrentMonth
                            ? Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: .3)
                            : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: hasMeals && isCurrentMonth && !isSelected
                    ? Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: .3),
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : !isCurrentMonth
                              ? Theme.of(context).colorScheme.outline
                              : isToday
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  if (hasMeals && isCurrentMonth) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0;
                            i < mealsForDate.length.clamp(0, 3);
                            i++)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            decoration: BoxDecoration(
                              color: mealsForDate[i]['color'] ??
                                  (isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.primary),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (mealsForDate.length > 3)
                          Text(
                            '+',
                            style: TextStyle(
                              fontSize: 8,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernMealCard(Map<String, dynamic> meal) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showMealDetails(meal),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Colored indicator and icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: meal['color']?.withOpacity(0.15) ??
                        Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getMealIcon(meal['type']),
                    color:
                        meal['color'] ?? Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Meal details - Fixed overflow issues
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with event badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${meal['type']}: ${meal['recipe']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (meal['isEvent'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: meal['color']?.withOpacity(0.2) ??
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'EVENT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: meal['color'] ??
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Time and servings row - Fixed overflow
                      Row(
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    meal['time'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${meal['servings']} servings',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Guests info if event
                      if (meal['isEvent'] == true &&
                          meal['guests'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${meal['guests']} guests expected',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Action button
                SizedBox(
                  width: 32,
                  child: PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('View Details'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Duplicate'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) =>
                        _handleMealAction(value.toString(), meal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMealsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              size: 40,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No meals planned',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first meal for this day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _showMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _focusedDate = picked;
        _selectedDate = picked;
      });
    }
  }

  void _showMealDetails(Map<String, dynamic> meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  meal['recipe'],
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${meal['type']} • ${meal['time']}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),

                // Details cards
                if (meal['isEvent'] == true) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event, color: meal['color']),
                              const SizedBox(width: 8),
                              Text(
                                'Event Details',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (meal['eventTitle'] != null)
                            Text('Title: ${meal['eventTitle']}'),
                          if (meal['guests'] != null)
                            Text('Guests: ${meal['guests']} expected'),
                          if (meal['dietaryRestrictions'] != null)
                            Text(
                                'Dietary Notes: ${meal['dietaryRestrictions'].join(", ")}'),
                        ],
                      ),
                    ),
                  ),
                ],

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.restaurant_menu),
                            const SizedBox(width: 8),
                            Text(
                              'Recipe Information',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Servings: ${meal['servings']}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Opening recipe details...')),
                            );
                          },
                          child: const Text('View Recipe'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMealAction(String action, Map<String, dynamic> meal) {
    switch (action) {
      case 'view':
        _showMealDetails(meal);
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit meal functionality coming soon!')),
        );
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal duplicated!')),
        );
        break;
      case 'delete':
        setState(() {
          _getMealsForDate(_selectedDate)
              .removeWhere((m) => m['id'] == meal['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal deleted')),
        );
        break;
    }
  }

  void _showAddMealDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add meal dialog coming soon!')),
    );
  }

  void _generateGroceryList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Generating grocery list for selected date!')),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  DateTime _getDateForIndex(int index) {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysDifference = index - firstDayWeekday;
    return firstDayOfMonth.add(Duration(days: daysDifference));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDateString(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[date.weekday % 7];
  }

  List<Map<String, dynamic>> _getMealsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _meals[dateKey] ?? [];
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
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
}
