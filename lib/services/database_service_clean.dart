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
  static const int _databaseVersion = 1;

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
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');
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
