class DailyAnalysis {
  final String id;
  final DateTime date;
  final String summary;
  final String strengths;
  final String weaknesses;
  final String recommendations;
  final String activityIntegration;
  final List<ChatMessage> chatHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyAnalysis({
    required this.id,
    required this.date,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.activityIntegration,
    required this.chatHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyAnalysis.fromJson(Map<String, dynamic> json) {
    return DailyAnalysis(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      summary: json['summary'] as String,
      strengths: json['strengths'] as String,
      weaknesses: json['weaknesses'] as String,
      recommendations: json['recommendations'] as String,
      activityIntegration: json['activityIntegration'] as String,
      chatHistory: (json['chatHistory'] as List)
          .map((e) => ChatMessage.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'summary': summary,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
      'activityIntegration': activityIntegration,
      'chatHistory': chatHistory.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DailyAnalysis copyWith({
    String? id,
    DateTime? date,
    String? summary,
    String? strengths,
    String? weaknesses,
    String? recommendations,
    String? activityIntegration,
    List<ChatMessage>? chatHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyAnalysis(
      id: id ?? this.id,
      date: date ?? this.date,
      summary: summary ?? this.summary,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      recommendations: recommendations ?? this.recommendations,
      activityIntegration: activityIntegration ?? this.activityIntegration,
      chatHistory: chatHistory ?? this.chatHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      message: json['message'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class DailyAnalysisRequest {
  final DailyStats stats;
  final List<FoodItemAnalysis> foodItems;
  final UserProfileData profile;

  DailyAnalysisRequest({
    required this.stats,
    required this.foodItems,
    required this.profile,
  });

  factory DailyAnalysisRequest.fromJson(Map<String, dynamic> json) {
    return DailyAnalysisRequest(
      stats: DailyStats.fromJson(json['stats']),
      foodItems: (json['foodItems'] as List)
          .map((e) => FoodItemAnalysis.fromJson(e))
          .toList(),
      profile: UserProfileData.fromJson(json['profile']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'foodItems': foodItems.map((e) => e.toJson()).toList(),
      'profile': profile.toJson(),
    };
  }
}

class DailyStats {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final double targetCalories;
  final String proteinTarget;
  final String carbsTarget;
  final String fatTarget;
  final String fiberTarget;

  DailyStats({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.targetCalories,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.fiberTarget,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      totalCalories: json['totalCalories'] as double,
      totalProtein: json['totalProtein'] as double,
      totalCarbs: json['totalCarbs'] as double,
      totalFat: json['totalFat'] as double,
      totalFiber: json['totalFiber'] as double,
      targetCalories: json['targetCalories'] as double,
      proteinTarget: json['proteinTarget'] as String,
      carbsTarget: json['carbsTarget'] as String,
      fatTarget: json['fatTarget'] as String,
      fiberTarget: json['fiberTarget'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalFiber': totalFiber,
      'targetCalories': targetCalories,
      'proteinTarget': proteinTarget,
      'carbsTarget': carbsTarget,
      'fatTarget': fatTarget,
      'fiberTarget': fiberTarget,
    };
  }
}

class FoodItemAnalysis {
  final String name;
  final double quantity;
  final String unit;
  final NutritionData nutritions;

  FoodItemAnalysis({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.nutritions,
  });

  factory FoodItemAnalysis.fromJson(Map<String, dynamic> json) {
    return FoodItemAnalysis(
      name: json['name'] as String,
      quantity: json['quantity'] as double,
      unit: json['unit'] as String,
      nutritions: NutritionData.fromJson(json['nutritions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'nutritions': nutritions.toJson(),
    };
  }
}

class NutritionData {
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fiber;
  final double fat;

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fiber,
    required this.fat,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: json['calories'] as double,
      protein: json['protein'] as double,
      carbohydrates: json['carbohydrates'] as double,
      fiber: json['fiber'] as double,
      fat: json['fat'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fiber': fiber,
      'fat': fat,
    };
  }
}

class UserProfileData {
  final double height;
  final double weight;
  final int age;
  final String gender;
  final String activityLevel;
  final String exerciseType;
  final int exerciseFrequency;
  final String goal;
  final int calorieAdjustment;
  final double tdee;
  final double tdeeTarget;

  UserProfileData({
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.exerciseType,
    required this.exerciseFrequency,
    required this.goal,
    required this.calorieAdjustment,
    required this.tdee,
    required this.tdeeTarget,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      height: json['height'] as double,
      weight: json['weight'] as double,
      age: json['age'] as int,
      gender: json['gender'] as String,
      activityLevel: json['activityLevel'] as String,
      exerciseType: json['exerciseType'] as String,
      exerciseFrequency: json['exerciseFrequency'] as int,
      goal: json['goal'] as String,
      calorieAdjustment: json['calorieAdjustment'] as int,
      tdee: json['tdee'] as double,
      tdeeTarget: json['tdeeTarget'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'exerciseType': exerciseType,
      'exerciseFrequency': exerciseFrequency,
      'goal': goal,
      'calorieAdjustment': calorieAdjustment,
      'tdee': tdee,
      'tdeeTarget': tdeeTarget,
    };
  }
}
