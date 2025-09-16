import '../models/ai_analysis_response.dart';
import '../models/food_item.dart';

class DemoDataService {
  static const List<Map<String, dynamic>> _demoFoods = [
    {
      'foodName': 'Scrambled Eggs with Toast',
      'items': [
        {
          'name': 'eggs',
          'quantity': 2.0,
          'unit': ' large',
          'nutritions': {
            'calories': 140.0,
            'protein': 12.0,
            'carbohydrates': 1.0,
            'fiber': 0.0,
            'fat': 10.0,
          },
        },
        {
          'name': 'butter',
          'quantity': 1.0,
          'unit': ' tbsp',
          'nutritions': {
            'calories': 100.0,
            'protein': 0.1,
            'carbohydrates': 0.0,
            'fiber': 0.0,
            'fat': 11.0,
          },
        },
        {
          'name': 'whole wheat bread',
          'quantity': 2.0,
          'unit': ' slices',
          'nutritions': {
            'calories': 180.0,
            'protein': 6.4,
            'carbohydrates': 23.0,
            'fiber': 4.2,
            'fat': 7.0,
          },
        },
      ],
      'calories': 420.0,
      'protein': 18.5,
      'carbohydrates': 24.0,
      'fiber': 4.2,
      'fat': 28.0,
      'comment':
          'Great breakfast choice! High in protein and fiber to keep you satisfied.',
      'mealScore': 8,
      'scoreReasoning':
          'High protein and fiber content with balanced macros. Good for sustained energy.',
    },
    {
      'foodName': 'Grilled Chicken Salad',
      'items': [
        {
          'name': 'chicken breast',
          'quantity': 150.0,
          'unit': 'g',
          'nutritions': {
            'calories': 248.0,
            'protein': 31.0,
            'carbohydrates': 0.0,
            'fiber': 0.0,
            'fat': 7.4,
          },
        },
        {
          'name': 'mixed greens',
          'quantity': 100.0,
          'unit': 'g',
          'nutritions': {
            'calories': 20.0,
            'protein': 2.0,
            'carbohydrates': 4.0,
            'fiber': 2.0,
            'fat': 0.2,
          },
        },
        {
          'name': 'cherry tomatoes',
          'quantity': 80.0,
          'unit': 'g',
          'nutritions': {
            'calories': 14.0,
            'protein': 0.7,
            'carbohydrates': 3.0,
            'fiber': 0.9,
            'fat': 0.2,
          },
        },
        {
          'name': 'olive oil',
          'quantity': 10.0,
          'unit': 'ml',
          'nutritions': {
            'calories': 81.0,
            'protein': 0.0,
            'carbohydrates': 0.0,
            'fiber': 0.0,
            'fat': 9.0,
          },
        },
      ],
      'calories': 363.0,
      'protein': 33.7,
      'carbohydrates': 7.0,
      'fiber': 2.9,
      'fat': 16.8,
      'comment':
          'Excellent lean protein source with fresh vegetables. Perfect for a healthy lunch!',
      'mealScore': 9,
      'scoreReasoning':
          'Excellent lean protein with lots of vegetables. Very nutrient-dense and low processed foods.',
    },
    {
      'foodName': 'Oatmeal with Berries',
      'items': [
        {
          'name': 'rolled oats',
          'quantity': 50.0,
          'unit': 'g',
          'nutritions': {
            'calories': 190.0,
            'protein': 6.5,
            'carbohydrates': 32.0,
            'fiber': 5.0,
            'fat': 3.5,
          },
        },
        {
          'name': 'mixed berries',
          'quantity': 100.0,
          'unit': 'g',
          'nutritions': {
            'calories': 57.0,
            'protein': 0.7,
            'carbohydrates': 14.0,
            'fiber': 2.4,
            'fat': 0.3,
          },
        },
        {
          'name': 'milk',
          'quantity': 200.0,
          'unit': 'ml',
          'nutritions': {
            'calories': 122.0,
            'protein': 6.4,
            'carbohydrates': 9.4,
            'fiber': 0.0,
            'fat': 6.8,
          },
        },
        {
          'name': 'honey',
          'quantity': 15.0,
          'unit': 'g',
          'nutritions': {
            'calories': 46.0,
            'protein': 0.1,
            'carbohydrates': 12.5,
            'fiber': 0.0,
            'fat': 0.0,
          },
        },
      ],
      'calories': 415.0,
      'protein': 13.7,
      'carbohydrates': 67.9,
      'fiber': 7.4,
      'fat': 10.6,
      'comment':
          'A nutritious breakfast high in fiber and antioxidants. Great way to start your day!',
      'mealScore': 8,
      'scoreReasoning':
          'High fiber and antioxidants from berries. Good complex carbs for sustained energy.',
    },
    {
      'foodName': 'Banana Smoothie',
      'items': [
        {
          'name': 'banana',
          'quantity': 1.0,
          'unit': ' medium',
          'nutritions': {
            'calories': 105.0,
            'protein': 1.3,
            'carbohydrates': 27.0,
            'fiber': 3.1,
            'fat': 0.4,
          },
        },
        {
          'name': 'yogurt',
          'quantity': 150.0,
          'unit': 'g',
          'nutritions': {
            'calories': 90.0,
            'protein': 15.0,
            'carbohydrates': 6.0,
            'fiber': 0.0,
            'fat': 0.8,
          },
        },
        {
          'name': 'milk',
          'quantity': 100.0,
          'unit': 'ml',
          'nutritions': {
            'calories': 61.0,
            'protein': 3.2,
            'carbohydrates': 4.7,
            'fiber': 0.0,
            'fat': 3.4,
          },
        },
      ],
      'calories': 256.0,
      'protein': 19.5,
      'carbohydrates': 37.7,
      'fiber': 3.1,
      'fat': 4.6,
      'comment':
          'Refreshing and protein-rich smoothie perfect for post-workout recovery!',
      'mealScore': 7,
      'scoreReasoning':
          'Good protein content but high in natural sugars. Great for post-workout but moderate for regular meals.',
    },
    {
      'foodName': 'Pasta with Marinara',
      'items': [
        {
          'name': 'whole grain pasta',
          'quantity': 80.0,
          'unit': 'g',
          'nutritions': {
            'calories': 280.0,
            'protein': 11.2,
            'carbohydrates': 56.0,
            'fiber': 6.4,
            'fat': 2.4,
          },
        },
        {
          'name': 'marinara sauce',
          'quantity': 120.0,
          'unit': 'g',
          'nutritions': {
            'calories': 36.0,
            'protein': 1.4,
            'carbohydrates': 8.4,
            'fiber': 1.2,
            'fat': 0.2,
          },
        },
        {
          'name': 'parmesan cheese',
          'quantity': 20.0,
          'unit': 'g',
          'nutritions': {
            'calories': 78.0,
            'protein': 7.0,
            'carbohydrates': 1.0,
            'fiber': 0.0,
            'fat': 5.3,
          },
        },
      ],
      'calories': 394.0,
      'protein': 19.6,
      'carbohydrates': 65.4,
      'fiber': 7.6,
      'fat': 7.9,
      'comment':
          'Classic comfort food with good fiber content from whole grain pasta!',
      'mealScore': 6,
      'scoreReasoning':
          'Decent fiber from whole grains but high in carbs and processed sauce. Moderate nutritional value.',
    },
  ];

  static AiAnalysisResponse getRandomDemo() {
    final random = (_demoFoods..shuffle()).first;

    return AiAnalysisResponse(
      foodName: random['foodName'],
      items: (random['items'] as List)
          .map(
            (item) => FoodItem(
              name: item['name'],
              quantity: item['quantity'].toDouble(),
              unit: item['unit'],
              nutritions: FoodItemNutrition(
                calories: item['nutritions']['calories'].toDouble(),
                protein: item['nutritions']['protein'].toDouble(),
                carbohydrates: item['nutritions']['carbohydrates'].toDouble(),
                fiber: item['nutritions']['fiber'].toDouble(),
                fat: item['nutritions']['fat'].toDouble(),
              ),
            ),
          )
          .toList(),
      calories: random['calories'].toDouble(),
      protein: random['protein'].toDouble(),
      carbohydrates: random['carbohydrates'].toDouble(),
      fiber: random['fiber'].toDouble(),
      fat: random['fat'].toDouble(),
      comment: random['comment'],
      mealScore: random['mealScore'],
      scoreReasoning: random['scoreReasoning'],
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
              quantity: item['quantity'].toDouble(),
              unit: item['unit'],
              nutritions: FoodItemNutrition(
                calories: item['nutritions']['calories'].toDouble(),
                protein: item['nutritions']['protein'].toDouble(),
                carbohydrates: item['nutritions']['carbohydrates'].toDouble(),
                fiber: item['nutritions']['fiber'].toDouble(),
                fat: item['nutritions']['fat'].toDouble(),
              ),
            ),
          )
          .toList(),
      calories: (base['calories'].toDouble() * 1.2),
      protein: (base['protein'].toDouble() * 1.2),
      carbohydrates: (base['carbohydrates'].toDouble() * 1.2),
      fiber: (base['fiber'].toDouble() * 1.2),
      fat: (base['fat'].toDouble() * 1.2),
      comment: 'Updated portion sizes based on your input: $input',
      mealScore: base['mealScore'],
      scoreReasoning:
          'Score updated based on recalculated portions: ${base['scoreReasoning']}',
    );
  }
}
