// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionEntry _$NutritionEntryFromJson(Map<String, dynamic> json) =>
    NutritionEntry(
      id: (json['id'] as num?)?.toInt(),
      foodName: json['foodName'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      comment: json['comment'] as String,
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      date: DateTime.parse(json['date'] as String),
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NutritionEntryToJson(NutritionEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'foodName': instance.foodName,
      'items': instance.items,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbohydrates': instance.carbohydrates,
      'fiber': instance.fiber,
      'fat': instance.fat,
      'comment': instance.comment,
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'date': instance.date.toIso8601String(),
      'imagePath': instance.imagePath,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.morningSnack: 'morning_snack',
  MealType.middaySnack: 'midday_snack',
  MealType.afternoonSnack: 'afternoon_snack',
  MealType.eveningSnack: 'evening_snack',
};
