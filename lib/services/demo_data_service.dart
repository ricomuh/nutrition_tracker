import '../models/ai_analysis_response.dart';
import '../models/food_item.dart';

class DemoDataService {
  static const List<Map<String, dynamic>> _demoFoods = [
    {
      'foodName': 'Scrambled Eggs with Toast',
      'items': [
        {'name': 'eggs', 'quantity': 2.0, 'unit': ' large'},
        {'name': 'butter', 'quantity': 1.0, 'unit': ' tbsp'},
        {'name': 'whole wheat bread', 'quantity': 2.0, 'unit': ' slices'},
      ],
      'calories': 420.0,
      'protein': 18.5,
      'carbohydrates': 24.0,
      'fiber': 4.2,
      'fat': 28.0,
      'comment':
          'Great breakfast choice! High in protein and fiber to keep you satisfied.',
    },
    {
      'foodName': 'Grilled Chicken Salad',
      'items': [
        {'name': 'chicken breast', 'quantity': 150.0, 'unit': 'g'},
        {'name': 'mixed greens', 'quantity': 100.0, 'unit': 'g'},
        {'name': 'cherry tomatoes', 'quantity': 50.0, 'unit': 'g'},
        {'name': 'olive oil', 'quantity': 1.0, 'unit': ' tbsp'},
      ],
      'calories': 350.0,
      'protein': 35.0,
      'carbohydrates': 8.0,
      'fiber': 3.5,
      'fat': 18.0,
      'comment':
          'Excellent lean protein choice! Perfect for maintaining or cutting.',
    },
    {
      'foodName': 'Protein Smoothie',
      'items': [
        {'name': 'protein powder', 'quantity': 1.0, 'unit': ' scoop'},
        {'name': 'banana', 'quantity': 1.0, 'unit': ' medium'},
        {'name': 'almond milk', 'quantity': 250.0, 'unit': 'ml'},
        {'name': 'peanut butter', 'quantity': 1.0, 'unit': ' tbsp'},
      ],
      'calories': 380.0,
      'protein': 28.0,
      'carbohydrates': 32.0,
      'fiber': 6.0,
      'fat': 14.0,
      'comment':
          'Perfect post-workout fuel! Great balance of protein and carbs for recovery.',
    },
    {
      'foodName': 'Avocado Toast',
      'items': [
        {'name': 'sourdough bread', 'quantity': 2.0, 'unit': ' slices'},
        {'name': 'avocado', 'quantity': 1.0, 'unit': ' medium'},
        {'name': 'sea salt', 'quantity': 0.5, 'unit': ' tsp'},
        {'name': 'lime juice', 'quantity': 1.0, 'unit': ' tsp'},
      ],
      'calories': 320.0,
      'protein': 9.0,
      'carbohydrates': 42.0,
      'fiber': 14.0,
      'fat': 16.0,
      'comment':
          'Healthy fats and fiber galore! This will keep you full and energized.',
    },
    {
      'foodName': 'Greek Yogurt Bowl',
      'items': [
        {'name': 'Greek yogurt', 'quantity': 200.0, 'unit': 'g'},
        {'name': 'blueberries', 'quantity': 50.0, 'unit': 'g'},
        {'name': 'granola', 'quantity': 30.0, 'unit': 'g'},
        {'name': 'honey', 'quantity': 1.0, 'unit': ' tbsp'},
      ],
      'calories': 290.0,
      'protein': 20.0,
      'carbohydrates': 38.0,
      'fiber': 4.0,
      'fat': 6.0,
      'comment':
          'Probiotic powerhouse! Great for digestive health and muscle recovery.',
    },
  ];

  static AiAnalysisResponse getRandomDemoFood() {
    final random = _demoFoods[DateTime.now().millisecond % _demoFoods.length];

    return AiAnalysisResponse(
      foodName: random['foodName'],
      items: (random['items'] as List)
          .map(
            (item) => FoodItem(
              name: item['name'],
              quantity: item['quantity'].toDouble(),
              unit: item['unit'],
            ),
          )
          .toList(),
      calories: random['calories'].toDouble(),
      protein: random['protein'].toDouble(),
      carbohydrates: random['carbohydrates'].toDouble(),
      fiber: random['fiber'].toDouble(),
      fat: random['fat'].toDouble(),
      comment: random['comment'],
    );
  }

  static AiAnalysisResponse getDemoRecalculation(String input) {
    // Simple demo recalculation - just modify the first demo food
    final base = _demoFoods[0];

    return AiAnalysisResponse(
      foodName: 'Updated: ${base['foodName']}',
      items: (base['items'] as List)
          .map(
            (item) => FoodItem(
              name: item['name'],
              quantity: (item['quantity'].toDouble() * 1.2), // Increase by 20%
              unit: item['unit'],
            ),
          )
          .toList(),
      calories: (base['calories'].toDouble() * 1.2),
      protein: (base['protein'].toDouble() * 1.2),
      carbohydrates: (base['carbohydrates'].toDouble() * 1.2),
      fiber: (base['fiber'].toDouble() * 1.2),
      fat: (base['fat'].toDouble() * 1.2),
      comment: 'Updated portion sizes based on your input: $input',
    );
  }
}
