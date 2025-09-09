import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nutrition_provider.dart';
import '../providers/settings_provider.dart';
import '../models/nutrition_entry.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/meal_section.dart';
import 'add_food_screen.dart';

class HomeScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime)? onDateChanged;

  const HomeScreen({super.key, this.selectedDate, this.onDateChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  bool _isDateChanging = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null &&
        widget.selectedDate != oldWidget.selectedDate) {
      final newDate = widget.selectedDate!;
      if (newDate != _selectedDate) {
        _selectedDate = newDate;
        _loadData();
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isDateChanging = true;
    });

    try {
      final nutritionProvider = context.read<NutritionProvider>();
      await nutritionProvider.loadEntriesForDate(_selectedDate);
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDateChanging = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Overview'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<NutritionProvider>(
        builder: (context, nutritionProvider, child) {
          if (nutritionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => nutritionProvider.refreshCurrentDate(),
            child: Column(
              children: [
                _buildDateSelector(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      DailySummaryCard(
                        totalCalories: nutritionProvider.totalCalories,
                        totalProtein: nutritionProvider.totalProtein,
                        totalCarbs: nutritionProvider.totalCarbohydrates,
                        totalFat: nutritionProvider.totalFat,
                        totalFiber: nutritionProvider.totalFiber,
                        targetCalories: _getTargetCalories(),
                      ),
                      const SizedBox(height: 16),
                      ..._buildMealSections(nutritionProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _isDateChanging ? null : () => _changeDate(-1),
            icon: _isDateChanging
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_left),
          ),
          TextButton(
            onPressed: _isDateChanging ? null : () => _selectDate(),
            child: Text(
              _formatDate(_selectedDate),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDateChanging ? Colors.grey : null,
              ),
            ),
          ),
          IconButton(
            onPressed: (_isToday() || _isDateChanging)
                ? null
                : () => _changeDate(1),
            icon: _isDateChanging
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMealSections(NutritionProvider nutritionProvider) {
    final mealTypes = [
      MealType.breakfast,
      MealType.morningSnack,
      MealType.lunch,
      MealType.middaySnack,
      MealType.afternoonSnack,
      MealType.dinner,
      MealType.eveningSnack,
    ];

    return mealTypes.map((mealType) {
      final entries = nutritionProvider.getEntriesByMealType(mealType);
      return MealSection(
        mealType: mealType,
        entries: entries,
        onAddFood: () => _addFoodForMeal(mealType),
        onEditEntry: (entry) => _editEntry(entry),
        onDeleteEntry: (entry) => _deleteEntry(entry),
      );
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  bool _isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return selectedDay == today;
  }

  void _changeDate(int days) async {
    final newDate = _selectedDate.add(Duration(days: days));
    setState(() {
      _selectedDate = newDate;
    });
    // Notify parent and load data
    widget.onDateChanged?.call(newDate);
    await _loadData();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateChanged?.call(picked);
      _loadData();
    }
  }

  void _addFoodForMeal(MealType mealType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(
          selectedDate: _selectedDate,
          selectedMealType: mealType,
        ),
      ),
    );
  }

  void _editEntry(NutritionEntry entry) {
    // TODO: Implement edit entry functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _deleteEntry(NutritionEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${entry.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDelete(entry);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(NutritionEntry entry) async {
    try {
      final nutritionProvider = context.read<NutritionProvider>();
      await nutritionProvider.deleteEntry(entry.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double _getTargetCalories() {
    final settingsProvider = context.read<SettingsProvider>();
    return settingsProvider.userProfile?.targetCalories ?? 2000;
  }
}
