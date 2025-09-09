import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/ai_analysis_response.dart';
import '../models/app_settings.dart';
import '../models/daily_analysis.dart';
import 'demo_data_service.dart';

class AiService {
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  static const String _openaiBaseUrl =
      'https://api.openai.com/v1/chat/completions';

  Future<AiAnalysisResponse> analyzeFood({
    required Uint8List imageBytes,
    required AiProvider provider,
    required String apiKey,
    String? foodBreakdown,
    bool demoMode = false,
  }) async {
    // Return demo data if no API key or demo mode enabled
    if (demoMode || apiKey.isEmpty) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      return DemoDataService.getRandomDemo();
    }

    switch (provider) {
      case AiProvider.gemini:
        return await _analyzeWithGemini(imageBytes, apiKey, foodBreakdown);
      case AiProvider.openai:
        return await _analyzeWithOpenAI(imageBytes, apiKey, foodBreakdown);
    }
  }

  Future<AiAnalysisResponse> analyzeTextOnly({
    required String foodName,
    required AiProvider provider,
    required String apiKey,
    String? foodBreakdown,
    bool demoMode = false,
  }) async {
    // Return demo data if no API key or demo mode enabled
    if (demoMode || apiKey.isEmpty) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      return DemoDataService.getRandomDemo();
    }

    switch (provider) {
      case AiProvider.gemini:
        return await _analyzeTextOnlyWithGemini(
          foodName,
          apiKey,
          foodBreakdown,
        );
      case AiProvider.openai:
        return await _analyzeTextOnlyWithOpenAI(
          foodName,
          apiKey,
          foodBreakdown,
        );
    }
  }

  Future<DailyAnalysis> analyzeDailyNutrition({
    required DailyAnalysisRequest request,
    required AiProvider provider,
    required String apiKey,
    bool demoMode = false,
  }) async {
    // Return demo data if no API key or demo mode enabled
    if (demoMode || apiKey.isEmpty) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 3));
      return _getDemoAnalysis(request);
    }

    switch (provider) {
      case AiProvider.gemini:
        return await _analyzeDailyWithGemini(request, apiKey);
      case AiProvider.openai:
        return await _analyzeDailyWithOpenAI(request, apiKey);
    }
  }

  Future<ChatMessage> continueChat({
    required String message,
    required DailyAnalysis analysis,
    required AiProvider provider,
    required String apiKey,
    bool demoMode = false,
  }) async {
    // Return demo data if no API key or demo mode enabled
    if (demoMode || apiKey.isEmpty) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      return _getDemoChatResponse(message);
    }

    switch (provider) {
      case AiProvider.gemini:
        return await _continuechatWithGemini(message, analysis, apiKey);
      case AiProvider.openai:
        return await _continueCharWithOpenAI(message, analysis, apiKey);
    }
  }

  Future<AiAnalysisResponse> recalculateNutrition({
    required String updatedBreakdown,
    required AiProvider provider,
    required String apiKey,
    bool demoMode = false,
  }) async {
    // Return demo data if no API key or demo mode enabled
    if (demoMode || apiKey.isEmpty) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      return DemoDataService.getDemoRecalculation(updatedBreakdown);
    }

    switch (provider) {
      case AiProvider.gemini:
        return await _recalculateWithGemini(updatedBreakdown, apiKey);
      case AiProvider.openai:
        return await _recalculateWithOpenAI(updatedBreakdown, apiKey);
    }
  }

  Future<AiAnalysisResponse> _analyzeWithGemini(
    Uint8List imageBytes,
    String apiKey,
    String? foodBreakdown,
  ) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final prompt = _buildAnalysisPrompt(foodBreakdown);

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
      };

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        return _parseAiResponse(text);
      } else {
        throw Exception('Failed to analyze food with Gemini: ${response.body}');
      }
    } catch (e) {
      print('Error in Gemini analysis: $e');
      // Return demo data as fallback
      return DemoDataService.getRandomDemo();
    }
  }

  Future<AiAnalysisResponse> _analyzeWithOpenAI(
    Uint8List imageBytes,
    String apiKey,
    String? foodBreakdown,
  ) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final prompt = _buildAnalysisPrompt(foodBreakdown);

      final body = {
        "model": "gpt-4-vision-preview",
        "messages": [
          {
            "role": "user",
            "content": [
              {"type": "text", "text": prompt},
              {
                "type": "image_url",
                "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
              },
            ],
          },
        ],
        "max_tokens": 1000,
      };

      final response = await http.post(
        Uri.parse(_openaiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text = responseData['choices'][0]['message']['content'];
        return _parseAiResponse(text);
      } else {
        throw Exception('Failed to analyze food with OpenAI: ${response.body}');
      }
    } catch (e) {
      print('Error in OpenAI analysis: $e');
      // Return demo data as fallback
      return DemoDataService.getRandomDemo();
    }
  }

  Future<AiAnalysisResponse> _analyzeTextOnlyWithGemini(
    String foodName,
    String apiKey,
    String? foodBreakdown,
  ) async {
    try {
      final prompt = _buildTextOnlyAnalysisPrompt(foodName, foodBreakdown);

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      };

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        return _parseAiResponse(text);
      } else {
        throw Exception('Failed to analyze food with Gemini: ${response.body}');
      }
    } catch (e) {
      print('Error in Gemini text-only analysis: $e');
      // Return demo data as fallback
      return DemoDataService.getRandomDemo();
    }
  }

  Future<AiAnalysisResponse> _analyzeTextOnlyWithOpenAI(
    String foodName,
    String apiKey,
    String? foodBreakdown,
  ) async {
    try {
      final prompt = _buildTextOnlyAnalysisPrompt(foodName, foodBreakdown);

      final body = {
        "model": "gpt-4",
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 1000,
      };

      final response = await http.post(
        Uri.parse(_openaiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text = responseData['choices'][0]['message']['content'];
        return _parseAiResponse(text);
      } else {
        throw Exception('Failed to analyze food with OpenAI: ${response.body}');
      }
    } catch (e) {
      print('Error in OpenAI text-only analysis: $e');
      // Return demo data as fallback
      return DemoDataService.getRandomDemo();
    }
  }

  Future<AiAnalysisResponse> _recalculateWithGemini(
    String updatedBreakdown,
    String apiKey,
  ) async {
    try {
      final prompt = _buildRecalculationPrompt(updatedBreakdown);

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      };

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        return _parseAiResponse(text);
      } else {
        throw Exception(
          'Failed to recalculate nutrition with Gemini: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in Gemini recalculation: $e');
      // Return demo data as fallback
      return DemoDataService.getDemoRecalculation(updatedBreakdown);
    }
  }

  Future<AiAnalysisResponse> _recalculateWithOpenAI(
    String updatedBreakdown,
    String apiKey,
  ) async {
    try {
      final prompt = _buildRecalculationPrompt(updatedBreakdown);

      final body = {
        "model": "gpt-4",
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 1000,
      };

      final response = await http.post(
        Uri.parse(_openaiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text = responseData['choices'][0]['message']['content'];
        return _parseAiResponse(text);
      } else {
        throw Exception(
          'Failed to recalculate nutrition with OpenAI: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in OpenAI recalculation: $e');
      // Return demo data as fallback
      return DemoDataService.getDemoRecalculation(updatedBreakdown);
    }
  }

  String _buildAnalysisPrompt(String? foodBreakdown) {
    String prompt =
        '''
Analyze this food image and provide nutritional information. ${foodBreakdown != null ? "The user has provided this breakdown: $foodBreakdown. Use this as a guide but verify against the image." : ""}

Return ONLY a valid JSON object with this exact structure:
{
  "foodName": "String - main name of the meal",
  "items": [
    {
      "name": "String - food item name",
      "quantity": number,
      "unit": "String - unit of measurement",
      "nutritions": {
        "calories": number,
        "protein": number,
        "carbohydrates": number,
        "fiber": number,
        "fat": number
      }
    }
  ],
  "calories": number,
  "protein": number,
  "carbohydrates": number,
  "fiber": number,
  "fat": number,
  "comment": "String - positive, encouraging comment about the meal"
}

Important:
- Provide accurate nutritional values for each individual food item
- The total nutrition values should be the sum of all individual items
- Be detailed and precise with portion sizes and nutritional breakdown
- Provide an encouraging comment about the meal choice
''';
    return prompt;
  }

  String _buildTextOnlyAnalysisPrompt(String foodName, String? foodBreakdown) {
    String prompt =
        '''
Analyze this food based on the name "${foodName}" and estimate nutritional information. ${foodBreakdown != null ? "The user has provided this breakdown: $foodBreakdown. Use this as additional information." : ""}

Note: This is a text-only analysis without an image, so provide your best estimate based on typical serving sizes and preparation methods.

Return ONLY a valid JSON object with this exact structure:
{
  "foodName": "String - main name of the meal",
  "items": [
    {
      "name": "String - food item name",
      "quantity": number,
      "unit": "String - unit of measurement",
      "nutritions": {
        "calories": number,
        "protein": number,
        "carbohydrates": number,
        "fiber": number,
        "fat": number
      }
    }
  ],
  "calories": number,
  "protein": number,
  "carbohydrates": number,
  "fiber": number,
  "fat": number,
  "comment": "String - positive, encouraging comment about the meal with a note that this is an estimate"
}

Important:
- Provide nutritional estimates for each individual food item
- The total nutrition values should be the sum of all individual items
- Be conservative with estimates and mention in the comment that this is an estimate without visual confirmation
''';
    return prompt;
  }

  String _buildRecalculationPrompt(String updatedBreakdown) {
    return '''
Recalculate the nutritional information for this updated food breakdown: $updatedBreakdown

Return ONLY a valid JSON object with this exact structure:
{
  "foodName": "String - main name of the meal",
  "items": [
    {
      "name": "String - food item name",
      "quantity": number,
      "unit": "String - unit of measurement",
      "nutritions": {
        "calories": number,
        "protein": number,
        "carbohydrates": number,
        "fiber": number,
        "fat": number
      }
    }
  ],
  "calories": number,
  "protein": number,
  "carbohydrates": number,
  "fiber": number,
  "fat": number,
  "comment": "String - positive comment about the updated nutritional information"
}

Important:
- Provide accurate nutritional values for each individual food item
- The total nutrition values should be the sum of all individual items
- Be precise with the updated quantities and nutritional breakdown
''';
  }

  AiAnalysisResponse _parseAiResponse(String responseText) {
    try {
      // Extract JSON from the response (sometimes AI adds extra text)
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        throw Exception('No valid JSON found in response');
      }

      final jsonString = responseText.substring(jsonStart, jsonEnd + 1);

      // Parse JSON with error handling
      Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid JSON format in AI response: $e');
      }

      // Validate required fields exist
      final requiredFields = [
        'foodName',
        'items',
        'calories',
        'protein',
        'carbohydrates',
        'fiber',
        'fat',
        'comment',
      ];
      for (final field in requiredFields) {
        if (!jsonData.containsKey(field)) {
          throw Exception('Missing required field: $field');
        }
      }

      return AiAnalysisResponse.fromJson(jsonData);
    } catch (e) {
      // If parsing fails, return demo data as fallback
      print('Failed to parse AI response: $e');
      print('Response text: $responseText');
      return DemoDataService.getRandomDemo();
    }
  }

  // Daily Analysis Methods
  Future<DailyAnalysis> _analyzeDailyWithGemini(
    DailyAnalysisRequest request,
    String apiKey,
  ) async {
    try {
      final prompt = _buildDailyAnalysisPrompt(request);

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      };

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        return _parseDailyAnalysisResponse(text);
      } else {
        throw Exception(
          'Failed to analyze daily nutrition with Gemini: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in Gemini daily analysis: $e');
      // Return demo data as fallback
      return _getDemoAnalysis(request);
    }
  }

  Future<DailyAnalysis> _analyzeDailyWithOpenAI(
    DailyAnalysisRequest request,
    String apiKey,
  ) async {
    try {
      final prompt = _buildDailyAnalysisPrompt(request);

      final body = {
        "model": "gpt-4",
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 2000,
      };

      final response = await http.post(
        Uri.parse(_openaiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text = responseData['choices'][0]['message']['content'];
        return _parseDailyAnalysisResponse(text);
      } else {
        throw Exception(
          'Failed to analyze daily nutrition with OpenAI: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in OpenAI daily analysis: $e');
      // Return demo data as fallback
      return _getDemoAnalysis(request);
    }
  }

  Future<ChatMessage> _continuechatWithGemini(
    String message,
    DailyAnalysis analysis,
    String apiKey,
  ) async {
    try {
      final prompt = _buildChatPrompt(message, analysis);

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      };

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: text.trim(),
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception(
          'Failed to continue chat with Gemini: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in Gemini chat: $e');
      return _getDemoChatResponse(message);
    }
  }

  Future<ChatMessage> _continueCharWithOpenAI(
    String message,
    DailyAnalysis analysis,
    String apiKey,
  ) async {
    try {
      final prompt = _buildChatPrompt(message, analysis);

      final body = {
        "model": "gpt-4",
        "messages": [
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 1000,
      };

      final response = await http.post(
        Uri.parse(_openaiBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text = responseData['choices'][0]['message']['content'];
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: text.trim(),
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception(
          'Failed to continue chat with OpenAI: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in OpenAI chat: $e');
      return _getDemoChatResponse(message);
    }
  }

  String _buildDailyAnalysisPrompt(DailyAnalysisRequest request) {
    final stats = request.stats;
    final profile = request.profile;
    final foods = request.foodItems;

    return '''
As a professional nutritionist and fitness coach, analyze this user's daily nutrition intake and provide comprehensive feedback.

USER PROFILE:
- Height: ${profile.height}cm, Weight: ${profile.weight}kg, Age: ${profile.age}, Gender: ${profile.gender}
- Activity Level: ${profile.activityLevel}
- Exercise: ${profile.exerciseType}, ${profile.exerciseFrequency}x per week
- Goal: ${profile.goal}
- TDEE: ${profile.tdee} kcal, Target: ${profile.tdeeTarget} kcal
- Calorie Adjustment: ${profile.calorieAdjustment} kcal

DAILY NUTRITION STATS:
- Total Calories: ${stats.totalCalories} / ${stats.targetCalories}
- Protein: ${stats.totalProtein}g (Target: ${stats.proteinTarget})
- Carbs: ${stats.totalCarbs}g (Target: ${stats.carbsTarget})
- Fat: ${stats.totalFat}g (Target: ${stats.fatTarget})
- Fiber: ${stats.totalFiber}g (Target: ${stats.fiberTarget})

FOODS CONSUMED TODAY:
${foods.map((food) => '- ${food.name} (${food.quantity} ${food.unit}): ${food.nutritions.calories} kcal, ${food.nutritions.protein}g protein, ${food.nutritions.carbohydrates}g carbs, ${food.nutritions.fat}g fat, ${food.nutritions.fiber}g fiber').join('\n')}

Return ONLY a valid JSON object with this exact structure:
{
  "summary": "Brief daily summary highlighting main achievements and gaps (e.g., 'Today you hit your protein target (124g) but fiber intake is low (16g vs 25-35g target).')",
  "strengths": "Highlight what they did well (e.g., 'Great job! Your protein intake is solid, supporting muscle recovery after gym sessions.')",
  "weaknesses": "Point out deficiencies or excess (e.g., 'Fat intake is slightly high, consider reducing fried foods tomorrow.')",
  "recommendations": "Actionable next steps (e.g., 'Tomorrow, add 1 serving of leafy greens or fruits to meet your fiber needs.')",
  "activityIntegration": "Connect nutrition with their fitness goals (e.g., 'With a 200 kcal deficit today, you're on track for fat loss. Ensure adequate energy for your next workout.')"
}

Keep the tone encouraging, professional, and actionable. Focus on practical advice aligned with their specific goals and activity level.
''';
  }

  String _buildChatPrompt(String userMessage, DailyAnalysis analysis) {
    return '''
You are a professional nutritionist continuing a conversation about today's nutrition analysis.

PREVIOUS ANALYSIS CONTEXT:
Summary: ${analysis.summary}
Strengths: ${analysis.strengths}
Weaknesses: ${analysis.weaknesses}
Recommendations: ${analysis.recommendations}
Activity Integration: ${analysis.activityIntegration}

USER'S NEW QUESTION/COMMENT: ${userMessage}

Respond naturally as a supportive nutritionist. Provide helpful, specific advice while maintaining context from the previous analysis. Keep responses concise but informative.
''';
  }

  DailyAnalysis _parseDailyAnalysisResponse(String responseText) {
    try {
      // Extract JSON from the response
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        throw Exception('No valid JSON found in response');
      }

      final jsonString = responseText.substring(jsonStart, jsonEnd + 1);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate required fields
      final requiredFields = [
        'summary',
        'strengths',
        'weaknesses',
        'recommendations',
        'activityIntegration',
      ];
      for (final field in requiredFields) {
        if (!jsonData.containsKey(field)) {
          throw Exception('Missing required field: $field');
        }
      }

      final now = DateTime.now();
      return DailyAnalysis(
        id: now.millisecondsSinceEpoch.toString(),
        date: DateTime(now.year, now.month, now.day),
        summary: jsonData['summary'] as String,
        strengths: jsonData['strengths'] as String,
        weaknesses: jsonData['weaknesses'] as String,
        recommendations: jsonData['recommendations'] as String,
        activityIntegration: jsonData['activityIntegration'] as String,
        chatHistory: [],
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      print('Failed to parse daily analysis response: $e');
      return _getDemoAnalysis(null);
    }
  }

  DailyAnalysis _getDemoAnalysis(DailyAnalysisRequest? request) {
    final now = DateTime.now();
    return DailyAnalysis(
      id: now.millisecondsSinceEpoch.toString(),
      date: DateTime(now.year, now.month, now.day),
      summary:
          "Today you've reached your protein target (124g) which is excellent for muscle recovery, but your fiber intake is below the recommended range (16g vs 25-35g target).",
      strengths:
          "Fantastic protein intake! You're hitting your targets perfectly, which will support muscle recovery after your gym sessions. Your calorie intake is also well-controlled.",
      weaknesses:
          "Your fiber intake needs attention - you're currently at 16g but should aim for 25-35g daily. This affects digestion and satiety.",
      recommendations:
          "Tomorrow, try adding a serving of leafy greens to your lunch and include some berries or an apple as a snack. This will help boost your fiber intake naturally.",
      activityIntegration:
          "With a 200-calorie deficit today, you're perfectly aligned with your fat loss goals. Make sure to maintain adequate energy for your next workout session.",
      chatHistory: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  ChatMessage _getDemoChatResponse(String message) {
    final responses = [
      "That's a great question! Based on your current intake, I'd recommend focusing on whole food sources for better nutrient density.",
      "I understand your concern. Let's work together to find sustainable solutions that fit your lifestyle.",
      "Your progress is looking good! Small, consistent changes often lead to the best long-term results.",
      "That's perfectly normal. Remember, nutrition is a journey, and every day is a fresh start to make better choices.",
      "I'm glad you asked! This shows you're really thinking about optimizing your nutrition for your goals.",
    ];

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: responses[DateTime.now().second % responses.length],
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
