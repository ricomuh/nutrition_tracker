import 'package:json_annotation/json_annotation.dart';

part 'food_item.g.dart';

@JsonSerializable()
class FoodItemNutrition {
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fiber;
  final double fat;

  const FoodItemNutrition({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fiber,
    required this.fat,
  });

  factory FoodItemNutrition.fromJson(Map<String, dynamic> json) =>
      _$FoodItemNutritionFromJson(json);
  Map<String, dynamic> toJson() => _$FoodItemNutritionToJson(this);
}

@JsonSerializable()
class FoodItem {
  final String name;
  final double quantity;
  final String unit;
  final FoodItemNutrition nutritions;

  const FoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.nutritions,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);
  Map<String, dynamic> toJson() => _$FoodItemToJson(this);
}
