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

enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
}

@JsonSerializable()
class UserProfile {
  final double height; // in cm
  final double weight; // in kg
  final int age; // in years
  final Gender gender;
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
    required this.age,
    required this.gender,
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
    // Mifflin-St Jeor equation for BMR calculation
    double bmr;
    if (gender == Gender.male) {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Activity factor based on activity level and exercise frequency
    double activityFactor;
    switch (activityLevel) {
      case ActivityLevel.light:
        // Sedentary (desk job) with varying exercise frequency
        if (exerciseFrequency <= 1) {
          activityFactor = 1.2; // Little to no exercise
        } else if (exerciseFrequency <= 3) {
          activityFactor = 1.375; // Light exercise 1-3x/week
        } else {
          activityFactor = 1.55; // Moderate exercise 3-5x/week
        }
        break;
      case ActivityLevel.moderate:
        // Moderate activity (some standing/walking) with exercise
        if (exerciseFrequency <= 2) {
          activityFactor = 1.375; // Light exercise
        } else if (exerciseFrequency <= 4) {
          activityFactor = 1.55; // Moderate exercise 3-5x/week
        } else {
          activityFactor = 1.725; // Heavy exercise 6-7x/week
        }
        break;
      case ActivityLevel.heavy:
        // Very active (physical job) with exercise
        if (exerciseFrequency <= 3) {
          activityFactor = 1.55; // Moderate exercise
        } else if (exerciseFrequency <= 5) {
          activityFactor = 1.725; // Heavy exercise 6-7x/week
        } else {
          activityFactor = 1.9; // Very heavy exercise or 2x training
        }
        break;
    }

    return bmr * activityFactor;
  }

  double get targetCalories => tdee + calorieAdjustment;

  UserProfile copyWith({
    double? height,
    double? weight,
    int? age,
    Gender? gender,
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
      age: age ?? this.age,
      gender: gender ?? this.gender,
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
