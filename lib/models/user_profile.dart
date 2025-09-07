import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

enum ActivityLevel {
  @JsonValue('light')
  light,
  @JsonValue('moderate')
  moderate,
  @JsonValue('heavy')
  heavy,
}

enum ExerciseType {
  @JsonValue('cardio')
  cardio,
  @JsonValue('gym')
  gym,
  @JsonValue('competitive_sports')
  competitiveSports,
}

enum Goal {
  @JsonValue('maintain')
  maintain,
  @JsonValue('bulking')
  bulking,
  @JsonValue('cutting')
  cutting,
}

@JsonSerializable()
class UserProfile {
  final double height; // in cm
  final double weight; // in kg
  final ActivityLevel activityLevel;
  final ExerciseType exerciseType;
  final int exerciseFrequency; // per week
  final Goal goal;
  final int calorieAdjustment; // -750 to +500
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.exerciseType,
    required this.exerciseFrequency,
    required this.goal,
    this.calorieAdjustment = 0,
    required this.createdAt,
    this.updatedAt,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  double get tdee {
    // Mifflin-St Jeor equation (assuming average gender for simplicity)
    double bmr = 10 * weight + 6.25 * height - 5 * 25 + 5; // Assuming age 25

    // Activity factor
    double activityFactor;
    switch (activityLevel) {
      case ActivityLevel.light:
        activityFactor = 1.2;
        break;
      case ActivityLevel.moderate:
        activityFactor = 1.55;
        break;
      case ActivityLevel.heavy:
        activityFactor = 1.9;
        break;
    }

    // Exercise factor
    double exerciseFactor = 1.0 + (exerciseFrequency * 0.1);

    return bmr * activityFactor * exerciseFactor;
  }

  double get targetCalories => tdee + calorieAdjustment;

  UserProfile copyWith({
    double? height,
    double? weight,
    ActivityLevel? activityLevel,
    ExerciseType? exerciseType,
    int? exerciseFrequency,
    Goal? goal,
    int? calorieAdjustment,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      exerciseType: exerciseType ?? this.exerciseType,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      goal: goal ?? this.goal,
      calorieAdjustment: calorieAdjustment ?? this.calorieAdjustment,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
