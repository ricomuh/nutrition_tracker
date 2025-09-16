import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/user_profile.dart';

class DailySummaryCard extends StatelessWidget {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double targetCalories;

  const DailySummaryCard({
    super.key,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final progress = targetCalories > 0 ? totalCalories / targetCalories : 0.0;
    final remainingCalories = targetCalories - totalCalories;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCalorieProgress(context, progress, remainingCalories),
            const SizedBox(height: 16),
            _buildMacronutrients(),
            const SizedBox(height: 8),
            _buildGoalWarning(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieProgress(
    BuildContext context,
    double progress,
    double remaining,
  ) {
    final isOverTarget = remaining < 0;
    final progressColor = isOverTarget
        ? Colors.red
        : Theme.of(context).primaryColor;

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final userProfile = settingsProvider.userProfile;
        final calorieBalance = totalCalories - targetCalories;
        final balanceStatus = _getCalorieBalanceStatus(
          userProfile?.goal ?? Goal.maintain,
          calorieBalance,
        );

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${totalCalories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Target: ${targetCalories.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOverTarget
                      ? '${(-remaining).toStringAsFixed(0)} kcal over'
                      : '${remaining.toStringAsFixed(0)} kcal remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverTarget ? Colors.red : Colors.grey[600],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getBalanceColor(
                      userProfile?.goal ?? Goal.maintain,
                      calorieBalance,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getBalanceColor(
                        userProfile?.goal ?? Goal.maintain,
                        calorieBalance,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    balanceStatus,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getBalanceColor(
                        userProfile?.goal ?? Goal.maintain,
                        calorieBalance,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacronutrients() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final userProfile = settingsProvider.userProfile;
        final weight = userProfile?.weight ?? 70.0;

        // Calculate recommendations based on body weight and activity
        final proteinTarget = _getProteinTarget(
          weight,
          userProfile?.activityLevel,
        );
        final carbsTarget = _getCarbsTarget(weight, userProfile?.goal);
        final fatTarget = _getFatTarget(weight);
        final fiberTarget = _getFiberTarget();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildMacroItem(
                'Protein',
                totalProtein,
                'g',
                Colors.blue,
                proteinTarget,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroItem(
                'Carbs',
                totalCarbs,
                'g',
                Colors.orange,
                carbsTarget,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroItem(
                'Fat',
                totalFat,
                'g',
                Colors.purple,
                fatTarget,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroItem(
                'Fiber',
                totalFiber,
                'g',
                Colors.green,
                fiberTarget,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacroItem(
    String label,
    double value,
    String unit,
    Color baseColor,
    String targetText,
  ) {
    // Parse target values for progress calculation
    final targetValues = _parseTargetValues(targetText);
    final minTarget = targetValues['min'] ?? 0.0;
    final maxTarget = targetValues['max'] ?? minTarget;

    // Calculate progress (0.0 to 1.0+)
    final progress = maxTarget > 0 ? value / maxTarget : 0.0;

    // Determine progress bar color based on nutrient type and progress
    Color progressColor = _getProgressColor(label, value, minTarget, maxTarget);

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: baseColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // Progress bar
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.grey[300],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: progressColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          targetText,
          style: TextStyle(fontSize: 9, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Map<String, double> _parseTargetValues(String targetText) {
    // Parse "25-35g" or "100g" format
    final cleanText = targetText.replaceAll('g', '');
    if (cleanText.contains('-')) {
      final parts = cleanText.split('-');
      return {
        'min': double.tryParse(parts[0]) ?? 0.0,
        'max': double.tryParse(parts[1]) ?? 0.0,
      };
    } else {
      final value = double.tryParse(cleanText) ?? 0.0;
      return {'min': value, 'max': value};
    }
  }

  Color _getProgressColor(
    String label,
    double value,
    double minTarget,
    double maxTarget,
  ) {
    switch (label.toLowerCase()) {
      case 'protein':
      case 'fiber':
        // For protein and fiber: more is generally better
        if (value < minTarget * 0.7) {
          return Colors.red; // Very low
        } else if (value < minTarget) {
          return Colors.orange; // Below minimum
        } else if (value >= minTarget && value <= maxTarget) {
          return Colors.green; // In target range
        } else {
          return Colors.blue; // Above target (good for protein/fiber)
        }

      case 'carbs':
      case 'fat':
        // For carbs and fat: should stay within reasonable range
        if (value < minTarget * 0.5) {
          return Colors.orange; // Too low
        } else if (value >= minTarget && value <= maxTarget) {
          return Colors.green; // In target range
        } else if (value <= maxTarget * 1.2) {
          return Colors.orange; // Slightly over
        } else {
          return Colors.red; // Way over target
        }

      default:
        return Colors.blue;
    }
  }

  Widget _buildGoalWarning(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final userProfile = settingsProvider.userProfile;
        if (userProfile == null || userProfile.goal != Goal.cutting) {
          return const SizedBox.shrink();
        }

        final isOverTarget = totalCalories > targetCalories;
        if (!isOverTarget) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Warning: You\'ve exceeded your cutting target!',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getProteinTarget(double weight, ActivityLevel? activityLevel) {
    double minMultiplier = 1.0; // Base minimum
    double maxMultiplier = 2.0; // Base maximum

    // Adjust based on activity level
    switch (activityLevel) {
      case ActivityLevel.light:
        minMultiplier = 1.0;
        maxMultiplier = 1.6;
        break;
      case ActivityLevel.moderate:
        minMultiplier = 1.2;
        maxMultiplier = 1.8;
        break;
      case ActivityLevel.heavy:
        minMultiplier = 1.6;
        maxMultiplier = 2.2;
        break;
      default:
        // Keep default values
        break;
    }

    final minProtein = weight * minMultiplier;
    final maxProtein = weight * maxMultiplier;
    return '${minProtein.toStringAsFixed(0)}-${maxProtein.toStringAsFixed(0)}g';
  }

  String _getCarbsTarget(double weight, Goal? goal) {
    double multiplier;
    switch (goal) {
      case Goal.cutting:
        multiplier = 1.5; // Lower carbs for cutting
        break;
      case Goal.bulking:
        multiplier = 4.0; // Higher carbs for bulking
        break;
      case Goal.maintain:
      default:
        multiplier = 3.0; // Moderate carbs for maintenance
        break;
    }
    final target = weight * multiplier;
    return '${target.toStringAsFixed(0)}g';
  }

  String _getFatTarget(double weight) {
    final minFat = weight * 0.8; // 0.8g per kg (minimum)
    final maxFat = weight * 1.2; // 1.2g per kg (adequate)
    return '${minFat.toStringAsFixed(0)}-${maxFat.toStringAsFixed(0)}g';
  }

  String _getFiberTarget() {
    return '25-35g'; // Standard fiber recommendation
  }

  String _getCalorieBalanceStatus(Goal goal, double balance) {
    final absBalance = balance.abs();

    switch (goal) {
      case Goal.cutting:
        if (balance < -100) return 'Good deficit';
        if (balance < 0) return 'Small deficit';
        if (balance < 100) return 'Near target';
        return 'Over target';

      case Goal.bulking:
        if (balance > 200) return 'Good surplus';
        if (balance > 0) return 'Small surplus';
        if (balance > -100) return 'Near target';
        return 'Below target';

      case Goal.maintain:
        if (absBalance < 100) return 'Perfect balance';
        if (absBalance < 200) return 'Slight imbalance';
        return balance > 0 ? 'Over target' : 'Under target';
    }
  }

  Color _getBalanceColor(Goal goal, double balance) {
    switch (goal) {
      case Goal.cutting:
        if (balance < -100) return Colors.green;
        if (balance < 0) return Colors.lightGreen;
        if (balance < 100) return Colors.orange;
        return Colors.red;

      case Goal.bulking:
        if (balance > 200) return Colors.green;
        if (balance > 0) return Colors.lightGreen;
        if (balance > -100) return Colors.orange;
        return Colors.red;

      case Goal.maintain:
        final absBalance = balance.abs();
        if (absBalance < 100) return Colors.green;
        if (absBalance < 200) return Colors.orange;
        return Colors.red;
    }
  }
}
