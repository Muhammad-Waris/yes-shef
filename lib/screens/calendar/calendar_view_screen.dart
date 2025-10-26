// import 'package:flutter/material.dart';

// class CalendarViewScreen extends StatefulWidget {
//   const CalendarViewScreen({super.key});

//   @override
//   State<CalendarViewScreen> createState() => _CalendarViewScreenState();
// }

// class _CalendarViewScreenState extends State<CalendarViewScreen> {
//   DateTime _selectedDate = DateTime.now();
//   DateTime _focusedDate = DateTime.now();

//   // Mock meal/event data
//   final Map<DateTime, List<Map<String, dynamic>>> _mealEvents = {
//     DateTime.now(): [
//       {
//         'type': 'meal',
//         'mealType': 'Breakfast',
//         'recipeName': 'Avocado Toast',
//         'time': '8:00 AM',
//       },
//       {
//         'type': 'event',
//         'title': 'Family Dinner',
//         'recipeName': 'Spaghetti Carbonara',
//         'time': '7:00 PM',
//         'guests': 6,
//         'dietaryNotes': 'No allergies',
//       },
//     ],
//     DateTime.now().add(const Duration(days: 1)): [
//       {
//         'type': 'meal',
//         'mealType': 'Lunch',
//         'recipeName': 'Caesar Salad',
//         'time': '12:30 PM',
//       },
//     ],
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Meal Calendar'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.today),
//             onPressed: () {
//               setState(() {
//                 _selectedDate = DateTime.now();
//                 _focusedDate = DateTime.now();
//               });
//             },
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'export') {
//                 _showExportDialog(context);
//               } else if (value == 'shopping_day') {
//                 _markShoppingDay(context);
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'export',
//                 child: Row(
//                   children: [
//                     Icon(Icons.calendar_month),
//                     SizedBox(width: 8),
//                     Text('Export to Calendar'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'shopping_day',
//                 child: Row(
//                   children: [
//                     Icon(Icons.shopping_cart),
//                     SizedBox(width: 8),
//                     Text('Mark Shopping Day'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Custom Calendar Widget - More Compact
//             Card(
//               margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   children: [
//                     // Month Navigation
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               _focusedDate = DateTime(
//                                 _focusedDate.year,
//                                 _focusedDate.month - 1,
//                               );
//                             });
//                           },
//                           icon: const Icon(Icons.chevron_left),
//                           iconSize: 20,
//                         ),
//                         Text(
//                           _getMonthYearString(_focusedDate),
//                           style: Theme.of(context).textTheme.titleMedium
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               _focusedDate = DateTime(
//                                 _focusedDate.year,
//                                 _focusedDate.month + 1,
//                               );
//                             });
//                           },
//                           icon: const Icon(Icons.chevron_right),
//                           iconSize: 20,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     // Calendar Grid
//                     _buildCalendarGrid(),
//                   ],
//                 ),
//               ),
//             ),

//             // Selected Date Info
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Row(
//                 children: [
//                   Text(
//                     _getSelectedDateString(),
//                     style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   TextButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               AddMealEventScreen(selectedDate: _selectedDate),
//                         ),
//                       );
//                     },
//                     icon: const Icon(Icons.add, size: 16),
//                     label: const Text('Add', style: TextStyle(fontSize: 12)),
//                   ),
//                 ],
//               ),
//             ),

//             // Meals/Events for Selected Date
//             Expanded(child: _buildMealEventsList()),

//             // Generate Grocery List Button - More Compact
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
//               child: ElevatedButton.icon(
//                 onPressed: () => _showGroceryListGenerator(context),
//                 icon: const Icon(Icons.shopping_cart, size: 16),
//                 label: const Text(
//                   'Generate Grocery List',
//                   style: TextStyle(fontSize: 13),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCalendarGrid() {
//     final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
//     final lastDayOfMonth = DateTime(
//       _focusedDate.year,
//       _focusedDate.month + 1,
//       0,
//     );
//     final firstDayWeekday = firstDayOfMonth.weekday % 7;
//     final daysInMonth = lastDayOfMonth.day;

//     // Days of week header
//     const daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

//     return Column(
//       children: [
//         // Header row
//         Row(
//           children: daysOfWeek
//               .map(
//                 (day) => Expanded(
//                   child: Center(
//                     child: Text(
//                       day,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//               .toList(),
//         ),
//         const SizedBox(height: 8),

//         // Calendar days - only generate needed weeks
//         ...(() {
//           final totalDays = daysInMonth + firstDayWeekday;
//           final weeksNeeded = (totalDays / 7).ceil();
//           return List.generate(weeksNeeded, (weekIndex) {
//             return Row(
//               children: List.generate(7, (dayIndex) {
//                 final dayNumber =
//                     weekIndex * 7 + dayIndex - firstDayWeekday + 1;
//                 if (dayNumber < 1 || dayNumber > daysInMonth) {
//                   return const Expanded(child: SizedBox(height: 28));
//                 }

//                 final date = DateTime(
//                   _focusedDate.year,
//                   _focusedDate.month,
//                   dayNumber,
//                 );
//                 final isSelected = _isSameDay(date, _selectedDate);
//                 final isToday = _isSameDay(date, DateTime.now());
//                 final hasMeals =
//                     _mealEvents.containsKey(date) &&
//                     _mealEvents[date]!.isNotEmpty;

//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedDate = date;
//                       });
//                     },
//                     child: Container(
//                       height: 28,
//                       margin: const EdgeInsets.all(0.5),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? Theme.of(context).colorScheme.primary
//                             : isToday
//                             ? Theme.of(context).colorScheme.primaryContainer
//                             : null,
//                         borderRadius: BorderRadius.circular(4),
//                         border: hasMeals
//                             ? Border.all(
//                                 color: Theme.of(context).colorScheme.secondary,
//                                 width: 1,
//                               )
//                             : null,
//                       ),
//                       child: Center(
//                         child: Text(
//                           dayNumber.toString(),
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: isSelected
//                                 ? Theme.of(context).colorScheme.onPrimary
//                                 : isToday
//                                 ? Theme.of(
//                                     context,
//                                   ).colorScheme.onPrimaryContainer
//                                 : null,
//                             fontWeight: isSelected || isToday
//                                 ? FontWeight.bold
//                                 : null,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             );
//           });
//         })(),
//       ],
//     );
//   }

//   Widget _buildMealEventsList() {
//     final mealsForDate = _mealEvents[_selectedDate] ?? [];

//     if (mealsForDate.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.restaurant,
//                 size: 48,
//                 color: Theme.of(context).colorScheme.outline,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'No meals planned',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Tap + to add a meal or event',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//       itemCount: mealsForDate.length,
//       itemBuilder: (context, index) {
//         final mealEvent = mealsForDate[index];
//         return _buildMealEventCard(mealEvent);
//       },
//     );
//   }

//   Widget _buildMealEventCard(Map<String, dynamic> mealEvent) {
//     final isEvent = mealEvent['type'] == 'event';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: () {
//           // Navigate to edit meal/event
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isEvent
//                           ? Theme.of(context).colorScheme.secondary
//                           : Theme.of(context).colorScheme.primary,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       isEvent ? 'EVENT' : mealEvent['mealType'].toUpperCase(),
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: isEvent
//                             ? Theme.of(context).colorScheme.onSecondary
//                             : Theme.of(context).colorScheme.onPrimary,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     mealEvent['time'],
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.more_vert),
//                     onPressed: () => _showMealEventOptions(context, mealEvent),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               if (isEvent) ...[
//                 Text(
//                   mealEvent['title'],
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//               ],
//               Text(
//                 mealEvent['recipeName'],
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                   fontWeight: isEvent ? null : FontWeight.bold,
//                 ),
//               ),
//               if (isEvent) ...[
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.people,
//                       size: 16,
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       '${mealEvent['guests']} guests',
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                     const SizedBox(width: 16),
//                     Icon(
//                       Icons.note,
//                       size: 16,
//                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                     ),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         mealEvent['dietaryNotes'],
//                         style: Theme.of(context).textTheme.bodySmall,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _getMonthYearString(DateTime date) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return '${months[date.month - 1]} ${date.year}';
//   }

//   String _getSelectedDateString() {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
//   }

//   bool _isSameDay(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   void _showMealEventOptions(
//     BuildContext context,
//     Map<String, dynamic> mealEvent,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text('Edit'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.content_copy),
//               title: const Text('Duplicate'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete),
//               title: const Text('Delete'),
//               onTap: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showExportDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Export to Calendar'),
//         content: const Text('Export your meal plan to your device calendar?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Calendar exported successfully!'),
//                 ),
//               );
//             },
//             child: const Text('Export'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _markShoppingDay(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Mark Shopping Day'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Select a date for your shopping day:'),
//             const SizedBox(height: 16),
//             // Date picker would go here
//             Text(_getSelectedDateString()),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Shopping day marked! You\'ll get a reminder.'),
//                 ),
//               );
//             },
//             child: const Text('Mark'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showGroceryListGenerator(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Generate Grocery List',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             const Text('Select date range:'),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {},
//                     child: const Text('From: Today'),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {},
//                     child: const Text('To: Next Week'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             CheckboxListTile(
//               title: const Text('Include all meals in range'),
//               value: true,
//               onChanged: (value) {},
//             ),
//             CheckboxListTile(
//               title: const Text('Check pantry items'),
//               value: true,
//               onChanged: (value) {},
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const GroceryListGeneratorScreen(),
//                     ),
//                   );
//                 },
//                 child: const Text('Generate List'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AddMealEventScreen extends StatefulWidget {
//   final DateTime? selectedDate;

//   const AddMealEventScreen({super.key, this.selectedDate});

//   @override
//   State<AddMealEventScreen> createState() => _AddMealEventScreenState();
// }

// class _AddMealEventScreenState extends State<AddMealEventScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _timeController = TextEditingController();
//   // final _guestsController = TextEditingController();
//   final _dietaryNotesController = TextEditingController();

//   String _selectedType = 'meal';
//   String _selectedMealType = 'Breakfast';
//   String? _selectedRecipe;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Meal/Event'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               if (_formKey.currentState!.validate()) {
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Meal/Event added successfully!'),
//                   ),
//                 );
//               }
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Type Selection
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Type',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       SegmentedButton<String>(
//                         segments: const [
//                           ButtonSegment(
//                             value: 'meal',
//                             label: Text('Simple Meal'),
//                           ),
//                           ButtonSegment(value: 'event', label: Text('Event')),
//                         ],
//                         selected: {_selectedType},
//                         onSelectionChanged: (Set<String> newSelection) {
//                           setState(() {
//                             _selectedType = newSelection.first;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Event Title (only for events)
//               if (_selectedType == 'event') ...[
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: TextFormField(
//                       controller: _titleController,
//                       decoration: const InputDecoration(
//                         labelText: 'Event Title',
//                         hintText: 'e.g., Family Dinner, Birthday Party',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (_selectedType == 'event' &&
//                             (value == null || value.isEmpty)) {
//                           return 'Please enter an event title';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//               ],

//               // Meal Type Selection
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Meal Type',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       DropdownButtonFormField<String>(
//                         initialValue: _selectedMealType,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                         ),
//                         items:
//                             ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert']
//                                 .map(
//                                   (type) => DropdownMenuItem(
//                                     value: type,
//                                     child: Text(type),
//                                   ),
//                                 )
//                                 .toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedMealType = value!;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Recipe Selection
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Recipe',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),
//                       ListTile(
//                         title: Text(_selectedRecipe ?? 'Select a recipe'),
//                         trailing: const Icon(Icons.arrow_forward_ios),
//                         onTap: () => _showRecipeSelector(context),
//                         shape: RoundedRectangleBorder(
//                           side: BorderSide(
//                             color: Theme.of(context).colorScheme.outline,
//                           ),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Time
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: TextFormField(
//                     controller: _timeController,
//                     decoration: const InputDecoration(
//                       labelText: 'Time',
//                       hintText: '7:00 PM',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.access_time),
//                     ),
//                     onTap: () => _selectTime(context),
//                     readOnly: true,
//                   ),
//                 ),
//               ),

//               // Event-specific fields
//               if (_selectedType == 'event') ...[
//                 const SizedBox(height: 16),

//                 // Guest Count
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Guests',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 decoration: const InputDecoration(
//                                   labelText: 'Adults',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 keyboardType: TextInputType.number,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: TextFormField(
//                                 decoration: const InputDecoration(
//                                   labelText: 'Kids',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 keyboardType: TextInputType.number,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Dietary Restrictions
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Dietary Restrictions',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         Wrap(
//                           spacing: 8,
//                           children:
//                               [
//                                     'Vegetarian',
//                                     'Gluten-Free',
//                                     'Dairy-Free',
//                                     'Nut-Free',
//                                   ]
//                                   .map(
//                                     (restriction) => FilterChip(
//                                       label: Text(restriction),
//                                       selected: false,
//                                       onSelected: (selected) {},
//                                     ),
//                                   )
//                                   .toList(),
//                         ),
//                         const SizedBox(height: 8),
//                         TextFormField(
//                           controller: _dietaryNotesController,
//                           decoration: const InputDecoration(
//                             labelText: 'Additional Notes',
//                             hintText: 'Other dietary considerations...',
//                             border: OutlineInputBorder(),
//                           ),
//                           maxLines: 2,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _timeController.text = picked.format(context);
//       });
//     }
//   }

//   void _showRecipeSelector(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Select Recipe',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             ListTile(
//               title: const Text('Spaghetti Carbonara'),
//               subtitle: const Text('Italian • 35 min'),
//               onTap: () {
//                 setState(() {
//                   _selectedRecipe = 'Spaghetti Carbonara';
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Chocolate Chip Cookies'),
//               subtitle: const Text('Dessert • 22 min'),
//               onTap: () {
//                 setState(() {
//                   _selectedRecipe = 'Chocolate Chip Cookies';
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Avocado Toast'),
//               subtitle: const Text('Breakfast • 10 min'),
//               onTap: () {
//                 setState(() {
//                   _selectedRecipe = 'Avocado Toast';
//                 });
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class GroceryListGeneratorScreen extends StatelessWidget {
//   const GroceryListGeneratorScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Grocery List Generator')),
//       body: const Center(
//         child: Text('Grocery List Generator will be implemented here'),
//       ),
//     );
//   }
// }
