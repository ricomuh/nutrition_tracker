// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_analysis_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiAnalysisResponse _$AiAnalysisResponseFromJson(Map<String, dynamic> json) =>
    AiAnalysisResponse(
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
    );

Map<String, dynamic> _$AiAnalysisResponseToJson(AiAnalysisResponse instance) =>
    <String, dynamic>{
      'foodName': instance.foodName,
      'items': instance.items,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbohydrates': instance.carbohydrates,
      'fiber': instance.fiber,
      'fat': instance.fat,
      'comment': instance.comment,
    };
