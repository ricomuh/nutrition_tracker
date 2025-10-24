import 'package:flutter/material.dart';
import '../models/daily_analysis.dart';
import '../models/app_settings.dart';
import '../services/ai_service.dart';
import '../services/settings_service.dart';

class DailyAnalysisProvider with ChangeNotifier {
  final AiService _aiService = AiService();
  final SettingsService _settingsService = SettingsService();

  final Map<String, DailyAnalysis> _analyses = {};
  bool _isLoading = false;
  String? _error;

  Map<String, DailyAnalysis> get analyses => _analyses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DailyAnalysis? getAnalysisForDate(DateTime date) {
    final dateKey = _getDateKey(date);
    return _analyses[dateKey];
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<DailyAnalysis> generateDailyAnalysis(
    DailyAnalysisRequest request,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final settings = await _settingsService.getSettings();

      final analysis = await _aiService.analyzeDailyNutrition(
        request: request,
        provider: settings.aiProvider,
        apiKey: _getApiKey(settings),
        demoMode: _isDemoMode(settings),
        language: settings.responseLanguage,
      );

      final dateKey = _getDateKey(analysis.date);
      _analyses[dateKey] = analysis;

      _isLoading = false;
      notifyListeners();
      return analysis;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addChatMessage(DateTime date, String message) async {
    final dateKey = _getDateKey(date);
    final analysis = _analyses[dateKey];

    if (analysis == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Add user message
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message,
        isUser: true,
        timestamp: DateTime.now(),
      );

      final updatedChatHistory = [...analysis.chatHistory, userMessage];

      // Get AI response
      final settings = await _settingsService.getSettings();
      final aiResponse = await _aiService.continueChat(
        message: message,
        analysis: analysis,
        provider: settings.aiProvider,
        apiKey: _getApiKey(settings),
        demoMode: _isDemoMode(settings),
        language: settings.responseLanguage,
      );

      // Update analysis with both messages
      final finalChatHistory = [...updatedChatHistory, aiResponse];
      _analyses[dateKey] = analysis.copyWith(
        chatHistory: finalChatHistory,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  dynamic _getApiKey(AppSettings settings) {
    switch (settings.aiProvider) {
      case AiProvider.gemini:
        return settings.geminiApiKey ?? '';
      case AiProvider.openai:
        return settings.openaiApiKey ?? '';
      case AiProvider.lunos:
        return settings.lunosApiKeys;
    }
  }

  bool _isDemoMode(AppSettings settings) {
    final apiKey = _getApiKey(settings);
    if (apiKey is String) {
      return apiKey.isEmpty;
    } else if (apiKey is List<String>) {
      return apiKey.isEmpty || apiKey.every((key) => key.isEmpty);
    }
    return true;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void loadStoredAnalyses() {
    // TODO: Implement loading from local storage
    // For now, this is just a placeholder
  }

  Future<void> saveAnalysis(DailyAnalysis analysis) async {
    // TODO: Implement saving to local storage
    // For now, just keep in memory
    final dateKey = _getDateKey(analysis.date);
    _analyses[dateKey] = analysis;
    notifyListeners();
  }

  void deleteAnalysis(DateTime date) {
    final dateKey = _getDateKey(date);
    _analyses.remove(dateKey);
    notifyListeners();
  }
}
