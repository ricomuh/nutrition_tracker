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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${totalCalories.toStringAsFixed(0)} kcal',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
        Text(
          isOverTarget
              ? '${(-remaining).toStringAsFixed(0)} kcal over target'
              : '${remaining.toStringAsFixed(0)} kcal remaining',
          style: TextStyle(
            fontSize: 12,
            color: isOverTarget ? Colors.red : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMacronutrients() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final userProfile = settingsProvider.userProfile;
        final weight = userProfile?.weight ?? 70.0;

        // Calculate recommendations based on body weight
        final proteinTarget = _getProteinTarget(weight);
        final carbsTarget = _getCarbsTarget(weight, userProfile?.goal);
        final fatTarget = _getFatTarget(weight);
        final fiberTarget = _getFiberTarget();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMacroItem(
              'Protein',
              totalProtein,
              'g',
              Colors.blue,
              proteinTarget,
            ),
            _buildMacroItem(
              'Carbs',
              totalCarbs,
              'g',
              Colors.orange,
              carbsTarget,
            ),
            _buildMacroItem('Fat', totalFat, 'g', Colors.purple, fatTarget),
            _buildMacroItem(
              'Fiber',
              totalFiber,
              'g',
              Colors.green,
              fiberTarget,
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
    Color color,
    String target,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          'Target: $target',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
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

  String _getProteinTarget(double weight) {
    final minProtein = weight * 1.0; // 1g per kg (minimum)
    final maxProtein = weight * 2.0; // 2g per kg (active)
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
}
