import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/nutrition_entry.dart';

class WebStorageService {
  static const String _entriesKey = 'nutrition_entries';

  Future<List<NutritionEntry>> getEntriesForDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_entriesKey) ?? [];

      final allEntries = entriesJson
          .map((json) => NutritionEntry.fromJson(jsonDecode(json)))
          .toList();

      // Filter by date
      final dateString = _formatDate(date);
      return allEntries
          .where((entry) => _formatDate(entry.date) == dateString)
          .toList();
    } catch (e) {
      print('Error loading entries: $e');
      return [];
    }
  }

  Future<void> insertEntry(NutritionEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_entriesKey) ?? [];

      // Create a new entry with an ID
      final newEntry = NutritionEntry(
        id: DateTime.now().millisecondsSinceEpoch,
        foodName: entry.foodName,
        items: entry.items,
        calories: entry.calories,
        protein: entry.protein,
        carbohydrates: entry.carbohydrates,
        fiber: entry.fiber,
        fat: entry.fat,
        comment: entry.comment,
        mealType: entry.mealType,
        date: entry.date,
        imagePath: entry.imagePath,
        createdAt: entry.createdAt,
      );

      entriesJson.add(jsonEncode(newEntry.toJson()));
      await prefs.setStringList(_entriesKey, entriesJson);
    } catch (e) {
      print('Error saving entry: $e');
      rethrow;
    }
  }

  Future<void> deleteEntry(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_entriesKey) ?? [];

      entriesJson.removeWhere((json) {
        final entry = NutritionEntry.fromJson(jsonDecode(json));
        return entry.id == id;
      });

      await prefs.setStringList(_entriesKey, entriesJson);
    } catch (e) {
      print('Error deleting entry: $e');
      rethrow;
    }
  }

  Future<void> clearAllEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_entriesKey);
    } catch (e) {
      print('Error clearing entries: $e');
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
