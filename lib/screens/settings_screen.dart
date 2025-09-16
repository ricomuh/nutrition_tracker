import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';
import '../models/user_profile.dart';
import '../widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _geminiApiKeyController = TextEditingController();
  final _openaiApiKeyController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _exerciseFrequencyController = TextEditingController();

  AiProvider _selectedAiProvider = AiProvider.gemini;
  ResponseLanguage _selectedLanguage = ResponseLanguage.english;
  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  ExerciseType _exerciseType = ExerciseType.gym;
  Goal _goal = Goal.maintain;
  int _calorieAdjustment = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsProvider = context.read<SettingsProvider>();
    final settings = settingsProvider.settings;
    final userProfile = settingsProvider.userProfile;

    // Load AI settings
    _selectedAiProvider = settings.aiProvider;
    _selectedLanguage = settings.responseLanguage;
    _geminiApiKeyController.text = settings.geminiApiKey ?? '';
    _openaiApiKeyController.text = settings.openaiApiKey ?? '';

    // Load user profile
    if (userProfile != null) {
      _heightController.text = userProfile.height.toString();
      _weightController.text = userProfile.weight.toString();
      _ageController.text = userProfile.age.toString();
      _gender = userProfile.gender;
      _exerciseFrequencyController.text = userProfile.exerciseFrequency
          .toString();
      _activityLevel = userProfile.activityLevel;
      _exerciseType = userProfile.exerciseType;
      _goal = userProfile.goal;
      _calorieAdjustment = userProfile.calorieAdjustment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(onPressed: _saveSettings, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAiConfigSection(),
            const SizedBox(height: 32),
            _buildUserProfileSection(),
            const SizedBox(height: 32),
            _buildGoalAdjustmentSection(),
            const SizedBox(height: 32),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildAiConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('AI Provider'),
            const SizedBox(height: 8),
            DropdownButtonFormField<AiProvider>(
              initialValue: _selectedAiProvider,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: AiProvider.values.map((provider) {
                String displayName;
                switch (provider) {
                  case AiProvider.gemini:
                    displayName = 'Google Gemini';
                    break;
                  case AiProvider.openai:
                    displayName = 'OpenAI GPT';
                    break;
                  case AiProvider.lunos:
                    displayName = 'Lunos.tech';
                    break;
                }
                return DropdownMenuItem(
                  value: provider,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAiProvider = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Response Language'),
            const SizedBox(height: 8),
            DropdownButtonFormField<ResponseLanguage>(
              value: _selectedLanguage,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ResponseLanguage.values.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(
                    language == ResponseLanguage.english
                        ? 'English'
                        : 'Bahasa Indonesia',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_selectedAiProvider != AiProvider.lunos) ...[
              TextField(
                controller: _geminiApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'Gemini API Key',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your Google Gemini API key',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _openaiApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'OpenAI API Key',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your OpenAI API key',
                ),
                obscureText: true,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lunos.tech API Ready',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, child) {
                              return Text(
                                'Round-robin load balancing with ${settingsProvider.settings.lunosApiKeys.length} API keys',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[600],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age (years)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gender'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Gender>(
                        value: _gender,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: Gender.values.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(_getGenderName(gender)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _gender = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Activity Level'),
            ...ActivityLevel.values.map(
              (level) => RadioListTile<ActivityLevel>(
                title: Text(_getActivityLevelName(level)),
                value: level,
                groupValue: _activityLevel,
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Exercise Type'),
            ...ExerciseType.values.map(
              (type) => RadioListTile<ExerciseType>(
                title: Text(_getExerciseTypeName(type)),
                value: type,
                groupValue: _exerciseType,
                onChanged: (value) {
                  setState(() {
                    _exerciseType = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _exerciseFrequencyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Exercise frequency per week',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalAdjustmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal & Calorie Adjustment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Goal'),
            ...Goal.values.map(
              (goal) => RadioListTile<Goal>(
                title: Text(_getGoalName(goal)),
                value: goal,
                groupValue: _goal,
                onChanged: (value) {
                  setState(() {
                    _goal = value!;
                    // Set appropriate default calorie adjustment based on goal
                    switch (_goal) {
                      case Goal.cutting:
                        _calorieAdjustment = -300; // Default 300 kcal deficit
                        break;
                      case Goal.bulking:
                        _calorieAdjustment = 250; // Default 250 kcal surplus
                        break;
                      case Goal.maintain:
                        _calorieAdjustment = 0; // No adjustment for maintenance
                        break;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_goal != Goal.maintain) ...[
              Text('Calorie ${_goal == Goal.cutting ? 'Deficit' : 'Surplus'}'),
              const SizedBox(height: 8),
              Slider(
                value: _calorieAdjustment.toDouble(),
                min: _goal == Goal.cutting ? -750 : 0,
                max: _goal == Goal.cutting ? 0 : 500,
                divisions: _goal == Goal.cutting ? 3 : 2,
                label:
                    '${_calorieAdjustment > 0 ? '+' : ''}$_calorieAdjustment kcal',
                onChanged: (value) {
                  setState(() {
                    _calorieAdjustment = value.round();
                  });
                },
              ),
              Text(
                '${_calorieAdjustment > 0 ? '+' : ''}$_calorieAdjustment kcal/day',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 16),
            _buildCalorieDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieDisplay() {
    final height = double.tryParse(_heightController.text) ?? 170;
    final weight = double.tryParse(_weightController.text) ?? 70;
    final age = int.tryParse(_ageController.text) ?? 25;
    final exerciseFreq = int.tryParse(_exerciseFrequencyController.text) ?? 3;

    final tempProfile = UserProfile(
      height: height,
      weight: weight,
      age: age,
      gender: _gender,
      activityLevel: _activityLevel,
      exerciseType: _exerciseType,
      exerciseFrequency: exerciseFreq,
      goal: _goal,
      calorieAdjustment: _calorieAdjustment,
      createdAt: DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BMI:'),
              Text(tempProfile.bmi.toStringAsFixed(1)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TDEE:'),
              Text('${tempProfile.tdee.toStringAsFixed(0)} kcal'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Target Calories:'),
              Text(
                '${tempProfile.targetCalories.toStringAsFixed(0)} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Reset All Data',
              backgroundColor: Colors.red,
              onPressed: _showResetDialog,
            ),
          ],
        ),
      ),
    );
  }

  String _getActivityLevelName(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.light:
        return 'Light (office work)';
      case ActivityLevel.moderate:
        return 'Moderate';
      case ActivityLevel.heavy:
        return 'Heavy (manual labor)';
    }
  }

  String _getExerciseTypeName(ExerciseType type) {
    switch (type) {
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.gym:
        return 'Gym';
      case ExerciseType.competitiveSports:
        return 'Competitive Sports';
    }
  }

  String _getGoalName(Goal goal) {
    switch (goal) {
      case Goal.maintain:
        return 'Maintain Weight';
      case Goal.bulking:
        return 'Bulking';
      case Goal.cutting:
        return 'Cutting';
    }
  }

  String _getGenderName(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settingsProvider = context.read<SettingsProvider>();

      // Save AI settings
      final newSettings = AppSettings(
        aiProvider: _selectedAiProvider,
        geminiApiKey: _geminiApiKeyController.text.isEmpty
            ? null
            : _geminiApiKeyController.text,
        openaiApiKey: _openaiApiKeyController.text.isEmpty
            ? null
            : _openaiApiKeyController.text,
        responseLanguage: _selectedLanguage,
        isFirstRun: settingsProvider.settings.isFirstRun,
      );

      await settingsProvider.updateSettings(newSettings);

      // Save user profile
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);
      final age = int.tryParse(_ageController.text);
      final exerciseFreq = int.tryParse(_exerciseFrequencyController.text);

      if (height != null &&
          weight != null &&
          age != null &&
          exerciseFreq != null) {
        final newProfile = UserProfile(
          height: height,
          weight: weight,
          age: age,
          gender: _gender,
          activityLevel: _activityLevel,
          exerciseType: _exerciseType,
          exerciseFrequency: exerciseFreq,
          goal: _goal,
          calorieAdjustment: _calorieAdjustment,
          createdAt: settingsProvider.userProfile?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await settingsProvider.updateUserProfile(newProfile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will delete all your data including nutrition entries, user profile, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    try {
      final settingsProvider = context.read<SettingsProvider>();
      await settingsProvider.resetApp();

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/onboarding', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _geminiApiKeyController.dispose();
    _openaiApiKeyController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _exerciseFrequencyController.dispose();
    super.dispose();
  }
}
