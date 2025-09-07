import 'package:json_annotation/json_annotation.dart';
import 'food_item.dart';

part 'nutrition_entry.g.dart';

enum MealType {
  @JsonValue('breakfast')
  breakfast,
  @JsonValue('lunch')
  lunch,
  @JsonValue('dinner')
  dinner,
  @JsonValue('morning_snack')
  morningSnack,
  @JsonValue('midday_snack')
  middaySnack,
  @JsonValue('afternoon_snack')
  afternoonSnack,
  @JsonValue('evening_snack')
  eveningSnack,
}

@JsonSerializable()
class NutritionEntry {
  final int? id;
  final String foodName;
  final List<FoodItem> items;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fiber;
  final double fat;
  final String comment;
  final MealType mealType;
  final DateTime date;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NutritionEntry({
    this.id,
    required this.foodName,
    required this.items,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fiber,
    required this.fat,
    required this.comment,
    required this.mealType,
    required this.date,
    this.imagePath,
    required this.createdAt,
    this.updatedAt,
  });

  static MealType getMealTypeFromTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 10) {
      return MealType.breakfast;
    } else if (hour >= 10 && hour < 12) {
      return MealType.morningSnack;
    } else if (hour >= 12 && hour < 15) {
      return MealType.lunch;
    } else if (hour >= 15 && hour < 17) {
      return MealType.middaySnack;
    } else if (hour >= 17 && hour < 19) {
      return MealType.afternoonSnack;
    } else if (hour >= 19 && hour < 22) {
      return MealType.dinner;
    } else {
      return MealType.eveningSnack;
    }
  }

  String get mealTypeDisplayName {
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

  NutritionEntry copyWith({
    int? id,
    String? foodName,
    List<FoodItem>? items,
    double? calories,
    double? protein,
    double? carbohydrates,
    double? fiber,
    double? fat,
    String? comment,
    MealType? mealType,
    DateTime? date,
    String? imagePath,
    DateTime? updatedAt,
  }) {
    return NutritionEntry(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      items: items ?? this.items,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fiber: fiber ?? this.fiber,
      fat: fat ?? this.fat,
      comment: comment ?? this.comment,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory NutritionEntry.fromJson(Map<String, dynamic> json) =>
      _$NutritionEntryFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionEntryToJson(this);
}
