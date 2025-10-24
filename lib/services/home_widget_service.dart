import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:home_widget/home_widget.dart';
import '../models/nutrition_entry.dart';
import '../models/user_profile.dart';

class HomeWidgetService {
  static const String _dailySummaryWidgetName = 'NutriFitDailySummaryWidget';
  static const String _quickCameraWidgetName = 'NutriFitQuickCameraWidget';
  static const String _iosWidgetName = 'NutriFitWidget';

  static Future<void> initialize() async {
    if (kIsWeb) return; // Skip widget initialization on web
    try {
      await HomeWidget.setAppGroupId('group.nutrifit.ai');
    } catch (e) {
      print('Home widget initialization failed: $e');
    }
  }

  static Future<void> updateNutritionWidget({
    required List<NutritionEntry> todayEntries,
    required UserProfile? userProfile,
  }) async {
    if (kIsWeb) return; // Skip widget updates on web

    try {
      // Calculate totals
      final totalCalories = todayEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.calories,
      );
      final totalProtein = todayEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.protein,
      );
      final totalCarbs = todayEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.carbohydrates,
      );
      final totalFat = todayEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.fat,
      );

      final targetCalories = userProfile?.targetCalories ?? 2000.0;
      final tdee = userProfile?.tdee ?? 2000.0;
      final goal = userProfile?.goal.toString().split('.').last ?? 'maintain';

      // Prepare widget data
      final widgetData = {
        'calories': totalCalories.toInt(),
        'target_calories': targetCalories.toInt(),
        'tdee': tdee.toInt(),
        'protein': totalProtein.toInt(),
        'carbs': totalCarbs.toInt(),
        'fat': totalFat.toInt(),
        'goal': goal,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      };

      // Update widget data
      await HomeWidget.saveWidgetData<int>(
        'calories',
        widgetData['calories'] as int,
      );
      await HomeWidget.saveWidgetData<int>(
        'target_calories',
        widgetData['target_calories'] as int,
      );
      await HomeWidget.saveWidgetData<int>('tdee', widgetData['tdee'] as int);
      await HomeWidget.saveWidgetData<int>(
        'protein',
        widgetData['protein'] as int,
      );
      await HomeWidget.saveWidgetData<int>('carbs', widgetData['carbs'] as int);
      await HomeWidget.saveWidgetData<int>('fat', widgetData['fat'] as int);
      await HomeWidget.saveWidgetData<String>(
        'goal',
        widgetData['goal'] as String,
      );
      await HomeWidget.saveWidgetData<int>(
        'last_updated',
        widgetData['last_updated'] as int,
      );

      // Update both widgets
      await HomeWidget.updateWidget(
        name: _dailySummaryWidgetName,
        androidName: _dailySummaryWidgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      print('Error updating home widget: $e');
    }
  }

  static Future<void> updateQuickCameraWidget() async {
    if (kIsWeb) return; // Skip widget updates on web

    try {
      await HomeWidget.saveWidgetData<String>('widget_type', 'quick_camera');
      await HomeWidget.saveWidgetData<String>('action_title', 'Quick Scan');
      await HomeWidget.saveWidgetData<String>(
        'action_subtitle',
        'Instant food analysis',
      );

      // Update camera widget
      await HomeWidget.updateWidget(
        name: _quickCameraWidgetName,
        androidName: _quickCameraWidgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      print('Error updating quick action widget: $e');
    }
  }

  static Future<void> updateAllWidgets({
    required List<NutritionEntry> todayEntries,
    required UserProfile? userProfile,
  }) async {
    if (kIsWeb) return;

    // Update both widgets
    await updateNutritionWidget(
      todayEntries: todayEntries,
      userProfile: userProfile,
    );
    await updateQuickCameraWidget();
  }

  static String getProgressText(double current, double target) {
    final percentage = ((current / target) * 100).clamp(0, 999).toInt();
    return '$percentage%';
  }

  static String getCalorieStatusText(
    double calories,
    double target,
    String goal,
  ) {
    final remaining = target - calories;
    if (remaining > 0) {
      return '${remaining.toInt()} left';
    } else {
      return '${(-remaining).toInt()} over';
    }
  }
}
