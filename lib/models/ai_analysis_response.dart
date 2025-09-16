import 'package:json_annotation/json_annotation.dart';
import 'food_item.dart';

part 'ai_analysis_response.g.dart';

@JsonSerializable()
class AiAnalysisResponse {
  final String foodName;
  final List<FoodItem> items;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fiber;
  final double fat;
  final String comment;
  final int mealScore; // Score 1-10 based on nutrition balance and user goals
  final String scoreReasoning; // Explanation of the score

  const AiAnalysisResponse({
    required this.foodName,
    required this.items,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fiber,
    required this.fat,
    required this.comment,
    required this.mealScore,
    required this.scoreReasoning,
  });

  factory AiAnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$AiAnalysisResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AiAnalysisResponseToJson(this);
}
