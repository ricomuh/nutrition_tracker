import 'package:flutter/material.dart';
import '../models/nutrition_entry.dart';
import '../models/user_profile.dart';
import '../services/home_widget_service.dart';
import '../services/notification_service.dart';

class AppLifecycleProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;
  bool _notificationsEnabled = true;
  bool _widgetsEnabled = true;

  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get widgetsEnabled => _widgetsEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize notification service
    await _notificationService.initialize();

    // Initialize home widget service
    await HomeWidgetService.initialize();

    _isInitialized = true;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void setWidgetsEnabled(bool enabled) {
    _widgetsEnabled = enabled;
    notifyListeners();
  }

  Future<void> updateAppData({
    required List<NutritionEntry> entries,
    required UserProfile? userProfile,
    required DateTime date,
  }) async {
    if (!_isInitialized) return;

    // Get today's entries only
    final todayEntries = entries
        .where(
          (entry) =>
              entry.date.year == date.year &&
              entry.date.month == date.month &&
              entry.date.day == date.day,
        )
        .toList();

    // Update widgets if enabled
    if (_widgetsEnabled) {
      await HomeWidgetService.updateAllWidgets(
        todayEntries: todayEntries,
        userProfile: userProfile,
      );
    }

    // Check for notifications if enabled
    if (_notificationsEnabled) {
      await _checkAndSendNotifications(
        entries: todayEntries,
        userProfile: userProfile,
        date: date,
      );
    }
  }

  Future<void> _checkAndSendNotifications({
    required List<NutritionEntry> entries,
    required UserProfile? userProfile,
    required DateTime date,
  }) async {
    if (userProfile == null) return;

    final now = DateTime.now();
    final currentHour = now.hour;

    // Only check during specific hours (9 AM and 10 PM)
    if (currentHour != 9 && currentHour != 22) return;

    // Calculate current calories for the day
    final totalCalories = entries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.calories,
    );

    final tdee = userProfile.tdee;
    final targetCalories = userProfile.targetCalories;
    final goal = _getGoalString(userProfile.goal);

    await _evaluateAndNotify(
      totalCalories: totalCalories,
      targetCalories: targetCalories,
      tdee: tdee,
      goal: goal,
      currentHour: currentHour,
    );
  }

  String _getGoalString(Goal goal) {
    switch (goal) {
      case Goal.maintain:
        return 'maintenance';
      case Goal.bulking:
        return 'bulking';
      case Goal.cutting:
        return 'cutting';
    }
  }

  Future<void> _evaluateAndNotify({
    required double totalCalories,
    required double targetCalories,
    required double tdee,
    required String goal,
    required int currentHour,
  }) async {
    String? title;
    String? body;

    // Morning check (9 AM)
    if (currentHour == 9) {
      if (goal == 'bulking') {
        if (totalCalories < targetCalories * 0.3) {
          // Less than 30% of target by 9 AM
          title = 'Fuel Up for the Day! 💪';
          body =
              'You need ${(targetCalories - totalCalories).toInt()} more calories today. Start with a nutritious breakfast!';
        }
      } else if (goal == 'cutting') {
        if (totalCalories > targetCalories * 0.4) {
          // More than 40% of target by 9 AM
          title = 'Watch Your Portions 🥗';
          body =
              'You\'ve already consumed ${totalCalories.toInt()} calories. Be mindful of portions for the rest of the day.';
        }
      }
    }
    // Evening check (10 PM)
    else if (currentHour == 22) {
      if (goal == 'bulking') {
        if (totalCalories < targetCalories - 200) {
          if (totalCalories < tdee) {
            title = 'Time for a Late Snack! 🍌';
            body =
                'You\'re ${(targetCalories - totalCalories).toInt()} calories under target and below your TDEE. Consider a healthy snack.';
          } else {
            title = 'Almost There! 📈';
            body =
                'You\'re ${(targetCalories - totalCalories).toInt()} calories under target but above TDEE. You\'re still on track!';
          }
        }
      } else if (goal == 'cutting') {
        if (totalCalories > targetCalories + 100) {
          title = 'Calorie Goal Exceeded 📊';
          body =
              'You\'ve exceeded your target by ${(totalCalories - targetCalories).toInt()} calories today. Tomorrow is a fresh start!';
        } else if (totalCalories <= targetCalories + 200 &&
            totalCalories >= targetCalories - 200) {
          title = 'Perfect Balance! ⚖️';
          body =
              'You\'re within your calorie range. Great job staying on track with your goals!';
        }
      } else if (goal == 'maintenance') {
        if ((totalCalories - targetCalories).abs() <= 100) {
          title = 'Maintenance Mode! 🎯';
          body =
              'Perfect balance today! You\'re maintaining your weight goal beautifully.';
        } else if (totalCalories > targetCalories + 200) {
          title = 'Slight Surplus 📈';
          body =
              'You\'re ${(totalCalories - targetCalories).toInt()} calories over target. Balance it out tomorrow.';
        } else if (totalCalories < targetCalories - 200) {
          title = 'Slight Deficit 📉';
          body =
              'You\'re ${(targetCalories - totalCalories).toInt()} calories under target. Add a healthy snack if you\'re hungry.';
        }
      }
    }

    // Send notification if we have a message
    if (title != null && body != null) {
      await _notificationService.showNotification(title: title, body: body);
    }
  }

  Future<void> scheduleReminders() async {
    if (!_notificationsEnabled || !_isInitialized) return;

    // Schedule daily reminder at 9 AM
    await _notificationService.scheduleDailyNotification(
      id: 1,
      title: 'Good Morning! 🌅',
      body: 'Ready to track your nutrition today? Let\'s make it a great day!',
      hour: 9,
      minute: 0,
    );

    // Schedule daily reminder at 10 PM
    await _notificationService.scheduleDailyNotification(
      id: 2,
      title: 'Day Review 🌙',
      body:
          'How did your nutrition go today? Check your progress in NutriFit AI!',
      hour: 22,
      minute: 0,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}
