// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => FoodItem(
  name: json['name'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  unit: json['unit'] as String,
);

Map<String, dynamic> _$FoodItemToJson(FoodItem instance) => <String, dynamic>{
  'name': instance.name,
  'quantity': instance.quantity,
  'unit': instance.unit,
};
