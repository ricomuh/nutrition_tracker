import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/nutrition_entry.dart';
import '../models/food_item.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/full_screen_image_viewer.dart';
import 'edit_food_screen.dart';

class EntryDetailScreen extends StatelessWidget {
  final NutritionEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.foodName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editEntry(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.imagePath != null && _shouldShowImage()) ...[
              _buildImageSection(),
              const SizedBox(height: 16),
            ],
            _buildMealTypeInfo(),
            const SizedBox(height: 16),
            _buildMealScoreSection(),
            const SizedBox(height: 16),
            _buildNutritionSummary(),
            const SizedBox(height: 16),
            _buildFoodItemsBreakdown(),
            const SizedBox(height: 16),
            if (entry.comment.isNotEmpty) ...[
              _buildCommentSection(),
              const SizedBox(height: 16),
            ],
            _buildTimestampInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _openImageViewer(context),
        child: Hero(
          tag: 'entry_detail_image_${entry.id}',
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    File(entry.imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Add fullscreen indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext context) {
    if (entry.imagePath != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FullScreenImageViewer(
            imagePath: entry.imagePath,
            heroTag: 'entry_detail_image_${entry.id}',
          ),
        ),
      );
    }
  }

  Widget _buildMealTypeInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Builder(
          builder: (context) => Row(
            children: [
              Icon(
                _getMealTypeIcon(entry.mealType),
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getMealTypeName(entry.mealType),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    entry.foodName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealScoreSection() {
    final score = entry.mealScore;
    final reasoning = entry.scoreReasoning;

    // Color coding based on score
    Color scoreColor;
    Color backgroundColor;
    Color borderColor;
    IconData scoreIcon;
    String scoreLabel;

    if (score >= 8) {
      scoreColor = Colors.green[700]!;
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green.withOpacity(0.3);
      scoreIcon = Icons.sentiment_very_satisfied;
      scoreLabel = 'Excellent';
    } else if (score >= 6) {
      scoreColor = Colors.blue[700]!;
      backgroundColor = Colors.blue.withOpacity(0.1);
      borderColor = Colors.blue.withOpacity(0.3);
      scoreIcon = Icons.sentiment_satisfied;
      scoreLabel = 'Good';
    } else if (score >= 4) {
      scoreColor = Colors.orange[700]!;
      backgroundColor = Colors.orange.withOpacity(0.1);
      borderColor = Colors.orange.withOpacity(0.3);
      scoreIcon = Icons.sentiment_neutral;
      scoreLabel = 'Fair';
    } else {
      scoreColor = Colors.red[700]!;
      backgroundColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.red.withOpacity(0.3);
      scoreIcon = Icons.sentiment_dissatisfied;
      scoreLabel = 'Poor';
    }

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: scoreColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Meal Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(scoreIcon, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$score/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scoreLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
            if (reasoning.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                reasoning,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Score breakdown visualization
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: List.generate(10, (index) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: 8,
                          decoration: BoxDecoration(
                            color: index < score
                                ? scoreColor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  scoreLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: scoreColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Nutrition Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildNutritionItem(
                'Calories',
                '${entry.calories.toStringAsFixed(0)} kcal',
                Colors.red,
              ),
              _buildNutritionItem(
                'Protein',
                '${entry.protein.toStringAsFixed(1)} g',
                Colors.blue,
              ),
              _buildNutritionItem(
                'Carbs',
                '${entry.carbohydrates.toStringAsFixed(1)} g',
                Colors.orange,
              ),
              _buildNutritionItem(
                'Fat',
                '${entry.fat.toStringAsFixed(1)} g',
                Colors.purple,
              ),
              _buildNutritionItem(
                'Fiber',
                '${entry.fiber.toStringAsFixed(1)} g',
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, [Color? color]) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (color ?? Colors.blue).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: (color ?? Colors.blue).withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemsBreakdown() {
    if (entry.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Food Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...entry.items.map((item) => _buildFoodItemCard(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItem item) {
    // Use actual nutrition data per item
    final calories = item.nutritions.calories;
    final protein = item.nutritions.protein;
    final carbs = item.nutritions.carbohydrates;
    final fat = item.nutritions.fat;
    final fiber = item.nutritions.fiber;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.quantity} ${item.unit} of ${item.name}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildMiniNutritionInfo('Cal', calories, ''),
              _buildMiniNutritionInfo('Protein', protein, 'g'),
              _buildMiniNutritionInfo('Carbs', carbs, 'g'),
              _buildMiniNutritionInfo('Fat', fat, 'g'),
              _buildMiniNutritionInfo('Fiber', fiber, 'g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNutritionInfo(String label, double value, String unit) {
    return Text(
      '$label: ${value.toStringAsFixed(1)}$unit',
      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
    );
  }

  Widget _buildCommentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Comment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              entry.comment,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timestamps',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Added:'),
                Text(
                  _formatDateTime(entry.createdAt),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (entry.updatedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Updated:'),
                  Text(
                    _formatDateTime(entry.updatedAt!),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getMealTypeIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.wb_sunny;
      case MealType.lunch:
        return Icons.wb_sunny_outlined;
      case MealType.dinner:
        return Icons.nightlight_round;
      case MealType.morningSnack:
      case MealType.middaySnack:
      case MealType.afternoonSnack:
      case MealType.eveningSnack:
        return Icons.local_cafe;
    }
  }

  String _getMealTypeName(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.morningSnack:
        return 'Morning Snack';
      case MealType.middaySnack:
        return 'Midday Snack';
      case MealType.afternoonSnack:
        return 'Afternoon Snack';
      case MealType.eveningSnack:
        return 'Evening Snack';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _shouldShowImage() {
    if (entry.imagePath == null) return false;

    try {
      // Check if file exists
      final file = File(entry.imagePath!);
      if (!file.existsSync()) return false;

      // Show image only for today and last 3 days
      final now = DateTime.now();
      final entryDate = entry.date;
      final difference = now.difference(entryDate).inDays;

      return difference <= 3;
    } catch (e) {
      return false;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEntry(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(BuildContext context) async {
    try {
      final nutritionProvider = context.read<NutritionProvider>();
      await nutritionProvider.deleteEntry(entry.id!);

      Navigator.of(context).pop(); // Go back to previous screen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editEntry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditFoodScreen(entry: entry)),
    );
  }
}
