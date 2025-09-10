enum AiProvider { gemini, openai, lunos }

enum ResponseLanguage { english, indonesian }

class AppSettings {
  final AiProvider aiProvider;
  final String? geminiApiKey;
  final String? openaiApiKey;
  final List<String> lunosApiKeys;
  final bool isFirstRun;
  final ResponseLanguage responseLanguage;

  const AppSettings({
    this.aiProvider = AiProvider.lunos,
    this.geminiApiKey,
    this.openaiApiKey,
    this.lunosApiKeys = const [
      'sk-bf085f2850bf1ecb90f8010870ec7ae9c85933ad6a0be6d1',
      // Tambahkan API key lain di sini untuk fallback
    ],
    this.isFirstRun = true,
    this.responseLanguage = ResponseLanguage.english,
  });

  AppSettings copyWith({
    AiProvider? aiProvider,
    String? geminiApiKey,
    String? openaiApiKey,
    List<String>? lunosApiKeys,
    bool? isFirstRun,
    ResponseLanguage? responseLanguage,
  }) {
    return AppSettings(
      aiProvider: aiProvider ?? this.aiProvider,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
      lunosApiKeys: lunosApiKeys ?? this.lunosApiKeys,
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
      case AiProvider.lunos:
        return lunosApiKeys.isNotEmpty ? lunosApiKeys.first : null;
    }
  }

  bool get hasValidApiKey {
    switch (aiProvider) {
      case AiProvider.gemini:
        return geminiApiKey != null && geminiApiKey!.isNotEmpty;
      case AiProvider.openai:
        return openaiApiKey != null && openaiApiKey!.isNotEmpty;
      case AiProvider.lunos:
        return lunosApiKeys.isNotEmpty &&
            lunosApiKeys.any((key) => key.isNotEmpty);
    }
  }
}
