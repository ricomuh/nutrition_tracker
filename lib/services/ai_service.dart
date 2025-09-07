import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/ai_analysis_response.dart';
import '../models/app_settings.dart';
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
      return DemoDataService.getRandomDemoFood();
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
      return DemoDataService.getRandomDemoFood();
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
      return DemoDataService.getRandomDemoFood();
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
      return DemoDataService.getRandomDemoFood();
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
      return DemoDataService.getRandomDemoFood();
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
      return DemoDataService.getRandomDemoFood();
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
      "unit": "String - unit of measurement"
    }
  ],
  "calories": number,
  "protein": number,
  "carbohydrates": number,
  "fiber": number,
  "fat": number,
  "comment": "String - positive, encouraging comment about the meal"
}

Be accurate with nutritional values and provide an encouraging comment about the meal choice.
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
      "unit": "String - unit of measurement"
    }
  ],
  "calories": number,
  "protein": number,
  "carbohydrates": number,
  "fiber": number,
  "fat": number,
  "comment": "String - positive, encouraging comment about the meal with a note that this is an estimate"
}

Be conservative with nutritional estimates and mention in the comment that this is an estimate without visual confirmation.
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
      "unit": "String - unit of measurement"
    }
  ],
  "calories": number,
  "protein": number,
  "carbohydrates": number,
  "fiber": number,
  "fat": number,
  "comment": "String - positive, encouraging comment about the meal"
}

Be accurate with nutritional values based on the updated breakdown.
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
      return DemoDataService.getRandomDemoFood();
    }
  }
}
