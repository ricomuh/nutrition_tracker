import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/user_profile.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  AppSettings _settings = const AppSettings();
  UserProfile? _userProfile;
  bool _isLoading = false;

  AppSettings get settings => _settings;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isFirstRun => _settings.isFirstRun;
  bool get hasUserProfile => _userProfile != null;

  Future<void> loadSettings() async {
    _isLoading = true;
    // Don't notify listeners here to avoid setState during build

    try {
      _settings = await _settingsService.getSettings();
      _userProfile = await _settingsService.getUserProfile();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      // Only notify once loading is complete
      notifyListeners();
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      await _settingsService.saveSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving settings: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfile newProfile) async {
    try {
      await _settingsService.saveUserProfile(newProfile);
      _userProfile = newProfile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    final newSettings = _settings.copyWith(isFirstRun: false);
    await updateSettings(newSettings);
  }

  Future<void> resetApp() async {
    try {
      await _settingsService.clearAllData();
      _settings = const AppSettings();
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting app: $e');
      rethrow;
    }
  }
}
