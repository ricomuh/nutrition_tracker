import 'package:flutter/foundation.dart';
import '../models/nutrition_entry.dart';
import '../services/database_service.dart';

class NutritionProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<NutritionEntry> _entries = [];
  Map<String, double> _dailyTotals = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<NutritionEntry> get entries => _entries;
  Map<String, double> get dailyTotals => _dailyTotals;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  double get totalCalories => _dailyTotals['calories'] ?? 0;
  double get totalProtein => _dailyTotals['protein'] ?? 0;
  double get totalCarbohydrates => _dailyTotals['carbohydrates'] ?? 0;
  double get totalFiber => _dailyTotals['fiber'] ?? 0;
  double get totalFat => _dailyTotals['fat'] ?? 0;

  Future<void> loadEntriesForDate(DateTime date) async {
    _isLoading = true;
    _selectedDate = date;
    notifyListeners();

    try {
      _entries = await _databaseService.getNutritionEntriesByDate(date);
      _dailyTotals = await _databaseService.getDailyTotals(date);
    } catch (e) {
      debugPrint('Error loading entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(NutritionEntry entry) async {
    try {
      final id = await _databaseService.insertNutritionEntry(entry);
      final newEntry = entry.copyWith(id: id);

      // Update local state
      _entries.add(newEntry);
      await _updateDailyTotals();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding entry: $e');
      rethrow;
    }
  }

  Future<void> updateEntry(NutritionEntry entry) async {
    try {
      await _databaseService.updateNutritionEntry(entry);

      // Update local state
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = entry;
        await _updateDailyTotals();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating entry: $e');
      rethrow;
    }
  }

  Future<void> deleteEntry(int id) async {
    try {
      await _databaseService.deleteNutritionEntry(id);

      // Update local state
      _entries.removeWhere((entry) => entry.id == id);
      await _updateDailyTotals();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting entry: $e');
      rethrow;
    }
  }

  Future<void> refreshCurrentDate() async {
    await loadEntriesForDate(_selectedDate);
  }

  Future<void> _updateDailyTotals() async {
    _dailyTotals = await _databaseService.getDailyTotals(_selectedDate);
  }

  List<NutritionEntry> getEntriesByMealType(MealType mealType) {
    return _entries.where((entry) => entry.mealType == mealType).toList();
  }
}
