import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/nutrition_entry.dart';
import '../models/food_item.dart';
import 'web_storage_service.dart';

class DatabaseService {
  static Database? _database;
  static WebStorageService? _webStorage;
  static const String _databaseName = 'nutrition_tracker.db';
  static const int _databaseVersion = 2;

  static const String _nutritionEntriesTable = 'nutrition_entries';

  Future<List<NutritionEntry>> getEntriesForDate(DateTime date) async {
    if (kIsWeb) {
      _webStorage ??= WebStorageService();
      return await _webStorage!.getEntriesForDate(date);
    } else {
      final db = await database;
      final dateString = _formatDate(date);
      final List<Map<String, dynamic>> maps = await db.query(
        _nutritionEntriesTable,
        where: 'date LIKE ?',
        whereArgs: ['$dateString%'],
        orderBy: 'created_at ASC',
      );

      return maps.map((map) => _nutritionEntryFromMap(map)).toList();
    }
  }

  Future<void> insertEntry(NutritionEntry entry) async {
    if (kIsWeb) {
      _webStorage ??= WebStorageService();
      await _webStorage!.insertEntry(entry);
    } else {
      final db = await database;
      final map = _nutritionEntryToMap(entry);
      await db.insert(
        _nutritionEntriesTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteEntry(int id) async {
    if (kIsWeb) {
      _webStorage ??= WebStorageService();
      await _webStorage!.deleteEntry(id);
    } else {
      final db = await database;
      await db.delete(_nutritionEntriesTable, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> clearAllEntries() async {
    if (kIsWeb) {
      _webStorage ??= WebStorageService();
      await _webStorage!.clearAllEntries();
    } else {
      final db = await database;
      await db.delete(_nutritionEntriesTable);
    }
  }

  Future<int> insertNutritionEntry(NutritionEntry entry) async {
    if (kIsWeb) {
      _webStorage ??= WebStorageService();
      await _webStorage!.insertEntry(entry);
      return 0; // Web storage doesn't return an actual ID
    } else {
      final db = await database;
      final map = _nutritionEntryToMap(entry);
      return await db.insert(_nutritionEntriesTable, map);
    }
  }

  Future<List<NutritionEntry>> getNutritionEntriesByDate(DateTime date) async {
    return await getEntriesForDate(date);
  }

  Future<void> updateNutritionEntry(NutritionEntry entry) async {
    if (kIsWeb) {
      _webStorage ??= WebStorageService();
      await _webStorage!.insertEntry(entry); // Web storage replaces by ID
    } else {
      final db = await database;
      final map = _nutritionEntryToMap(entry);

      await db.update(
        _nutritionEntriesTable,
        map,
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    }
  }

  Future<void> deleteNutritionEntry(int id) async {
    await deleteEntry(id);
  }

  Future<Map<String, double>> getDailyTotals(DateTime date) async {
    final entries = await getEntriesForDate(date);

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFiber = 0;
    double totalFat = 0;

    for (final entry in entries) {
      totalCalories += entry.calories;
      totalProtein += entry.protein;
      totalCarbs += entry.carbohydrates;
      totalFiber += entry.fiber;
      totalFat += entry.fat;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbohydrates': totalCarbs,
      'fiber': totalFiber,
      'fat': totalFat,
    };
  }

  Future<Database> get database async {
    if (kIsWeb) {
      // Return a dummy database for web, actual storage handled by WebStorageService
      throw UnsupportedError('Database not supported on web');
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_nutritionEntriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_name TEXT NOT NULL,
        items TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbohydrates REAL NOT NULL,
        fiber REAL NOT NULL,
        fat REAL NOT NULL,
        comment TEXT NOT NULL,
        meal_score INTEGER NOT NULL DEFAULT 5,
        score_reasoning TEXT NOT NULL DEFAULT '',
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Add meal_score and score_reasoning columns for version 2
      await db.execute('''
        ALTER TABLE $_nutritionEntriesTable ADD COLUMN meal_score INTEGER NOT NULL DEFAULT 5
      ''');
      await db.execute('''
        ALTER TABLE $_nutritionEntriesTable ADD COLUMN score_reasoning TEXT NOT NULL DEFAULT ''
      ''');
    }
  }

  Map<String, dynamic> _nutritionEntryToMap(NutritionEntry entry) {
    return {
      'food_name': entry.foodName,
      'items': jsonEncode(entry.items.map((item) => item.toJson()).toList()),
      'calories': entry.calories,
      'protein': entry.protein,
      'carbohydrates': entry.carbohydrates,
      'fiber': entry.fiber,
      'fat': entry.fat,
      'comment': entry.comment,
      'meal_score': entry.mealScore,
      'score_reasoning': entry.scoreReasoning,
      'meal_type': entry.mealType.name,
      'date': entry.date.toIso8601String(),
      'image_path': entry.imagePath,
      'created_at': entry.createdAt.toIso8601String(),
    };
  }

  NutritionEntry _nutritionEntryFromMap(Map<String, dynamic> map) {
    final itemsJson = jsonDecode(map['items']) as List;
    final items = itemsJson.map((item) => FoodItem.fromJson(item)).toList();

    return NutritionEntry(
      id: map['id'],
      foodName: map['food_name'],
      items: items,
      calories: map['calories'],
      protein: map['protein'],
      carbohydrates: map['carbohydrates'],
      fiber: map['fiber'],
      fat: map['fat'],
      comment: map['comment'],
      mealScore: map['meal_score'] ?? 5, // Default to 5 for existing entries
      scoreReasoning: map['score_reasoning'] ?? '', // Default to empty string
      mealType: MealType.values.firstWhere((e) => e.name == map['meal_type']),
      date: DateTime.parse(map['date']),
      imagePath: map['image_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }
}
