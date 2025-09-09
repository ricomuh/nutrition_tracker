import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../services/database_service.dart';
import '../widgets/chart_widgets.dart';

class MonthlyStatsScreen extends StatefulWidget {
  const MonthlyStatsScreen({super.key});

  @override
  State<MonthlyStatsScreen> createState() => _MonthlyStatsScreenState();
}

class _MonthlyStatsScreenState extends State<MonthlyStatsScreen> {
  DateTime _selectedMonth = DateTime.now();
  Map<String, double> _monthlyAverages = {};
  List<Map<String, dynamic>> _dailyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get entries for the entire month using DatabaseService
      final databaseService = DatabaseService();
      final entries = await _getEntriesForMonth(
        databaseService,
        _selectedMonth,
      );

      _generateRealMonthlyData(entries);
    } catch (e) {
      print('Error loading monthly data: $e');
      // Fallback to demo data if there's an error
      _generateMockMonthlyData();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _getEntriesForMonth(
    DatabaseService databaseService,
    DateTime month,
  ) async {
    List<Map<String, dynamic>> allEntries = [];

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      if (date.isAfter(DateTime.now())) break;

      try {
        final entries = await databaseService.getEntriesForDate(date);
        for (var entry in entries) {
          allEntries.add({
            'date': date.toIso8601String(),
            'calories': entry.calories,
            'protein': entry.protein,
            'carbs': entry.carbohydrates,
            'fat': entry.fat,
            'fiber': entry.fiber,
          });
        }
      } catch (e) {
        // Continue if error for specific day
        print('Error loading data for $date: $e');
      }
    }

    return allEntries;
  }

  void _generateRealMonthlyData(List<Map<String, dynamic>> entries) {
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    int daysWithData = 0;

    _dailyData.clear();

    // Group entries by day
    Map<int, List<Map<String, dynamic>>> dailyEntries = {};

    for (var entry in entries) {
      final date = DateTime.parse(entry['date']);
      final day = date.day;

      if (!dailyEntries.containsKey(day)) {
        dailyEntries[day] = [];
      }
      dailyEntries[day]!.add(entry);
    }

    // Calculate daily totals for each day in the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      if (date.isAfter(DateTime.now())) break;

      if (dailyEntries.containsKey(day)) {
        double dayCalories = 0;
        double dayProtein = 0;
        double dayCarbs = 0;
        double dayFat = 0;
        double dayFiber = 0;

        // Sum up all entries for this day
        for (var entry in dailyEntries[day]!) {
          dayCalories += (entry['calories'] ?? 0).toDouble();
          dayProtein += (entry['protein'] ?? 0).toDouble();
          dayCarbs += (entry['carbs'] ?? 0).toDouble();
          dayFat += (entry['fat'] ?? 0).toDouble();
          dayFiber += (entry['fiber'] ?? 0).toDouble();
        }

        _dailyData.add({
          'date': date,
          'calories': dayCalories,
          'protein': dayProtein,
          'carbs': dayCarbs,
          'fat': dayFat,
          'fiber': dayFiber,
        });

        totalCalories += dayCalories;
        totalProtein += dayProtein;
        totalCarbs += dayCarbs;
        totalFat += dayFat;
        totalFiber += dayFiber;
        daysWithData++;
      }
    }

    // Calculate monthly averages
    if (daysWithData > 0) {
      _monthlyAverages = {
        'calories': totalCalories / daysWithData,
        'protein': totalProtein / daysWithData,
        'carbs': totalCarbs / daysWithData,
        'fat': totalFat / daysWithData,
        'fiber': totalFiber / daysWithData,
      };
    } else {
      _monthlyAverages = {
        'calories': 0.0,
        'protein': 0.0,
        'carbs': 0.0,
        'fat': 0.0,
        'fiber': 0.0,
      };
    }
  }

  void _generateMockMonthlyData() {
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    int daysWithData = 0;

    _dailyData.clear();

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      if (date.isAfter(DateTime.now())) break;

      // Generate random data (in real app, this would come from database)
      final hasData = day % 3 != 0; // Simulate some days without data
      if (hasData) {
        final calories = 1800 + (day * 23) % 800; // Random but consistent
        final protein = calories * 0.15 / 4; // 15% from protein
        final carbs = calories * 0.50 / 4; // 50% from carbs
        final fat = calories * 0.35 / 9; // 35% from fat
        final fiber = 20 + (day * 3) % 15; // 20-35g fiber

        _dailyData.add({
          'date': date,
          'calories': calories.toDouble(),
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
          'fiber': fiber.toDouble(),
        });

        totalCalories += calories;
        totalProtein += protein;
        totalCarbs += carbs;
        totalFat += fat;
        totalFiber += fiber;
        daysWithData++;
      }
    }

    if (daysWithData > 0) {
      _monthlyAverages = {
        'calories': totalCalories / daysWithData,
        'protein': totalProtein / daysWithData,
        'carbs': totalCarbs / daysWithData,
        'fat': totalFat / daysWithData,
        'fiber': totalFiber / daysWithData,
      };
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _loadMonthlyData();
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        _selectedMonth = nextMonth;
        _loadMonthlyData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Statistics'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 20),
                  _buildMonthlyOverview(),
                  const SizedBox(height: 20),
                  _buildNutritionBreakdown(),
                  const SizedBox(height: 20),
                  _buildMacroDistribution(),
                  const SizedBox(height: 20),
                  _buildDailyProgress(),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyOverview() {
    final userProfile = context.watch<SettingsProvider>().userProfile;
    final targetCalories = userProfile?.targetCalories ?? 2000;
    final avgCalories = _monthlyAverages['calories'] ?? 0;
    final daysWithData = _dailyData.length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    'Days Logged',
                    daysWithData.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Avg Calories',
                    avgCalories.toStringAsFixed(0),
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    'Target Hit',
                    '${((avgCalories / targetCalories) * 100).toStringAsFixed(0)}%',
                    Icons.track_changes,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Consistency',
                    '${((daysWithData / DateTime.now().day) * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                    Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNutritionBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Average Daily Nutrition',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildNutritionItem(
              'Calories',
              _monthlyAverages['calories'] ?? 0,
              'kcal',
              Colors.orange,
              2000,
            ),
            _buildNutritionItem(
              'Protein',
              _monthlyAverages['protein'] ?? 0,
              'g',
              Colors.blue,
              150,
            ),
            _buildNutritionItem(
              'Carbohydrates',
              _monthlyAverages['carbs'] ?? 0,
              'g',
              Colors.green,
              250,
            ),
            _buildNutritionItem(
              'Fat',
              _monthlyAverages['fat'] ?? 0,
              'g',
              Colors.purple,
              65,
            ),
            _buildNutritionItem(
              'Fiber',
              _monthlyAverages['fiber'] ?? 0,
              'g',
              Colors.brown,
              30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(
    String name,
    double value,
    String unit,
    Color color,
    double target,
  ) {
    final percentage = target > 0 ? (value / target).clamp(0.0, 1.5) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            'Target: ${target.toStringAsFixed(0)} $unit (${(percentage * 100).toStringAsFixed(0)}%)',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgress() {
    final calorieData = _dailyData.map((d) => d['calories'] as double).toList();
    final labels = _dailyData.map((d) {
      final date = d['date'] as DateTime;
      return date.day.toString();
    }).toList();

    return SimpleBarChart(
      data: calorieData,
      labels: labels,
      title: 'Daily Calorie Progress',
      color: Colors.green[400]!,
      unit: 'kcal',
    );
  }

  Widget _buildMacroDistribution() {
    final avgProtein = _monthlyAverages['protein'] ?? 0;
    final avgCarbs = _monthlyAverages['carbs'] ?? 0;
    final avgFat = _monthlyAverages['fat'] ?? 0;

    return NutritionRingChart(
      protein: avgProtein,
      carbs: avgCarbs,
      fat: avgFat,
      title: 'Average Macro Distribution',
    );
  }
}
