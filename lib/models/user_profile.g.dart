// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  height: (json['height'] as num).toDouble(),
  weight: (json['weight'] as num).toDouble(),
  age: (json['age'] as num).toInt(),
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  activityLevel: $enumDecode(_$ActivityLevelEnumMap, json['activityLevel']),
  exerciseType: $enumDecode(_$ExerciseTypeEnumMap, json['exerciseType']),
  exerciseFrequency: (json['exerciseFrequency'] as num).toInt(),
  goal: $enumDecode(_$GoalEnumMap, json['goal']),
  calorieAdjustment: (json['calorieAdjustment'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'height': instance.height,
      'weight': instance.weight,
      'age': instance.age,
      'gender': _$GenderEnumMap[instance.gender]!,
      'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel]!,
      'exerciseType': _$ExerciseTypeEnumMap[instance.exerciseType]!,
      'exerciseFrequency': instance.exerciseFrequency,
      'goal': _$GoalEnumMap[instance.goal]!,
      'calorieAdjustment': instance.calorieAdjustment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};

const _$ActivityLevelEnumMap = {
  ActivityLevel.light: 'light',
  ActivityLevel.moderate: 'moderate',
  ActivityLevel.heavy: 'heavy',
};

const _$ExerciseTypeEnumMap = {
  ExerciseType.cardio: 'cardio',
  ExerciseType.gym: 'gym',
  ExerciseType.competitiveSports: 'competitive_sports',
};

const _$GoalEnumMap = {
  Goal.maintain: 'maintain',
  Goal.bulking: 'bulking',
  Goal.cutting: 'cutting',
};
