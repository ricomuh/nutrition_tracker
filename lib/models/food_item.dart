import 'package:json_annotation/json_annotation.dart';

part 'food_item.g.dart';

@JsonSerializable()
class FoodItem {
  final String name;
  final double quantity;
  final String unit;

  const FoodItem({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);
  Map<String, dynamic> toJson() => _$FoodItemToJson(this);
}
