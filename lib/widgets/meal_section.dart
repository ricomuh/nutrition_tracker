import 'package:flutter/material.dart';
import 'dart:io';
import '../models/nutrition_entry.dart';
import '../screens/entry_detail_screen.dart';

class MealSection extends StatelessWidget {
  final MealType mealType;
  final List<NutritionEntry> entries;
  final VoidCallback onAddFood;
  final Function(NutritionEntry) onEditEntry;
  final Function(NutritionEntry) onDeleteEntry;

  const MealSection({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddFood,
    required this.onEditEntry,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = entries.fold(
      0.0,
      (sum, entry) => sum + entry.calories,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getMealDisplayName(mealType),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${totalCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onAddFood,
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No food logged yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...entries.map((entry) => _buildFoodEntry(context, entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodEntry(BuildContext context, NutritionEntry entry) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EntryDetailScreen(entry: entry),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            if (entry.imagePath != null && _shouldShowImage(entry))
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(entry.imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.foodName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (entry.items.isNotEmpty)
                    Text(
                      entry.items
                          .map(
                            (item) =>
                                '${item.quantity}${item.unit} ${item.name}',
                          )
                          .join(', '),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Row(
                    children: [
                      _buildNutrientBadge(
                        '${entry.calories.toStringAsFixed(0)} kcal',
                        Colors.red,
                      ),
                      const SizedBox(width: 4),
                      _buildNutrientBadge(
                        'P: ${entry.protein.toStringAsFixed(1)}g',
                        Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      _buildNutrientBadge(
                        'C: ${entry.carbohydrates.toStringAsFixed(1)}g',
                        Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      _buildNutrientBadge(
                        'F: ${entry.fat.toStringAsFixed(1)}g',
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEditEntry(entry);
                    break;
                  case 'delete':
                    onDeleteEntry(entry);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getMealDisplayName(MealType mealType) {
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

  bool _shouldShowImage(NutritionEntry entry) {
    if (entry.imagePath == null) return false;

    // Show image only for today and last 3 days
    final now = DateTime.now();
    final entryDate = entry.date;
    final difference = now.difference(entryDate).inDays;

    return difference <= 3;
  }
}
