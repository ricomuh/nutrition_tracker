enum AiProvider { gemini, openai }

enum ResponseLanguage { english, indonesian }

class AppSettings {
  final AiProvider aiProvider;
  final String? geminiApiKey;
  final String? openaiApiKey;
  final bool isFirstRun;
  final ResponseLanguage responseLanguage;

  const AppSettings({
    this.aiProvider = AiProvider.gemini,
    this.geminiApiKey,
    this.openaiApiKey,
    this.isFirstRun = true,
    this.responseLanguage = ResponseLanguage.english,
  });

  AppSettings copyWith({
    AiProvider? aiProvider,
    String? geminiApiKey,
    String? openaiApiKey,
    bool? isFirstRun,
    ResponseLanguage? responseLanguage,
  }) {
    return AppSettings(
      aiProvider: aiProvider ?? this.aiProvider,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
      isFirstRun: isFirstRun ?? this.isFirstRun,
      responseLanguage: responseLanguage ?? this.responseLanguage,
    );
  }

  String? get currentApiKey {
    switch (aiProvider) {
      case AiProvider.gemini:
        return geminiApiKey;
      case AiProvider.openai:
        return openaiApiKey;
    }
  }

  bool get hasValidApiKey {
    return currentApiKey != null && currentApiKey!.isNotEmpty;
  }
}
