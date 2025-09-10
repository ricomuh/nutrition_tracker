import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';
import '../models/user_profile.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _userProfileKey = 'user_profile';

  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson == null) {
      return const AppSettings();
    }

    final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
    return AppSettings(
      aiProvider: AiProvider.values.firstWhere(
        (e) => e.name == settingsMap['aiProvider'],
        orElse: () => AiProvider.lunos,
      ),
      geminiApiKey: settingsMap['geminiApiKey'],
      openaiApiKey: settingsMap['openaiApiKey'],
      lunosApiKeys: settingsMap['lunosApiKeys'] != null
          ? List<String>.from(settingsMap['lunosApiKeys'])
          : [
              'sk-bf085f2850bf1ecb90f8010870ec7ae9c85933ad6a0be6d1',
              'sk-d09a43836a2ce97996e8eb808a6c480867583f71fe4b61f1',
              // Tambahkan API key lain di sini untuk fallback
            ],
      isFirstRun: settingsMap['isFirstRun'] ?? true,
      responseLanguage: ResponseLanguage.values.firstWhere(
        (e) => e.name == settingsMap['responseLanguage'],
        orElse: () => ResponseLanguage.english,
      ),
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsMap = {
      'aiProvider': settings.aiProvider.name,
      'geminiApiKey': settings.geminiApiKey,
      'openaiApiKey': settings.openaiApiKey,
      'lunosApiKeys': settings.lunosApiKeys,
      'isFirstRun': settings.isFirstRun,
      'responseLanguage': settings.responseLanguage.name,
    };

    await prefs.setString(_settingsKey, jsonEncode(settingsMap));
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_userProfileKey);

    if (profileJson == null) {
      return null;
    }

    final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
    return UserProfile.fromJson(profileMap);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
  }
}
