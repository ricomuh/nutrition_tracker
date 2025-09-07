enum AiProvider { gemini, openai }

class AppSettings {
  final AiProvider aiProvider;
  final String? geminiApiKey;
  final String? openaiApiKey;
  final bool isFirstRun;

  const AppSettings({
    this.aiProvider = AiProvider.gemini,
    this.geminiApiKey,
    this.openaiApiKey,
    this.isFirstRun = true,
  });

  AppSettings copyWith({
    AiProvider? aiProvider,
    String? geminiApiKey,
    String? openaiApiKey,
    bool? isFirstRun,
  }) {
    return AppSettings(
      aiProvider: aiProvider ?? this.aiProvider,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
      isFirstRun: isFirstRun ?? this.isFirstRun,
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
