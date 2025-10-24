import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/user_profile.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  ExerciseType _exerciseType = ExerciseType.gym;
  final _exerciseFrequencyController = TextEditingController();
  Goal _goal = Goal.maintain;

  @override
  void initState() {
    super.initState();

    // Add listeners to text controllers to update button state
    _heightController.addListener(() {
      setState(() {});
    });

    _weightController.addListener(() {
      setState(() {});
    });

    _ageController.addListener(() {
      setState(() {});
    });

    _exerciseFrequencyController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentPage + 1) / 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildHeightWeightPage(),
                  _buildActivityLevelPage(),
                  _buildExercisePage(),
                  _buildGoalPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 100,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to Nutrition Tracker',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'AI-powered calorie and nutrition tracking to help you reach your fitness goals.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          CustomButton(text: 'Get Started', onPressed: () => _nextPage()),
        ],
      ),
    );
  }

  Widget _buildHeightWeightPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
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
                      initialValue: _gender,
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
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _previousPage(),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Next',
                  onPressed: _canProceedFromHeightWeight()
                      ? () => _nextPage()
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Daily Activity Level',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Excluding gym/sports activities',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ..._buildActivityLevelOptions(),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _previousPage(),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(text: 'Next', onPressed: () => _nextPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActivityLevelOptions() {
    return ActivityLevel.values.map((level) {
      String title;
      String subtitle;

      switch (level) {
        case ActivityLevel.light:
          title = 'Light';
          subtitle = 'Office work, sitting most of the day';
          break;
        case ActivityLevel.moderate:
          title = 'Moderate';
          subtitle = 'Some walking, light physical activity';
          break;
        case ActivityLevel.heavy:
          title = 'Heavy';
          subtitle = 'Construction work, manual labor';
          break;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: RadioListTile<ActivityLevel>(
          title: Text(title),
          subtitle: Text(subtitle),
          value: level,
          groupValue: _activityLevel,
          onChanged: (value) {
            setState(() {
              _activityLevel = value!;
            });
          },
        ),
      );
    }).toList();
  }

  Widget _buildExercisePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Exercise Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          const Text(
            'Exercise Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ..._buildExerciseTypeOptions(),
          const SizedBox(height: 24),
          TextField(
            controller: _exerciseFrequencyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Exercise frequency per week',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _previousPage(),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Next',
                  onPressed: _canProceedFromExercise()
                      ? () => _nextPage()
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExerciseTypeOptions() {
    return ExerciseType.values.map((type) {
      String title;

      switch (type) {
        case ExerciseType.cardio:
          title = 'Cardio';
          break;
        case ExerciseType.gym:
          title = 'Gym';
          break;
        case ExerciseType.competitiveSports:
          title = 'Competitive Sports';
          break;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: RadioListTile<ExerciseType>(
          title: Text(title),
          value: type,
          groupValue: _exerciseType,
          onChanged: (value) {
            setState(() {
              _exerciseType = value!;
            });
          },
        ),
      );
    }).toList();
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'What\'s Your Goal?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ..._buildGoalOptions(),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _previousPage(),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(text: 'Next', onPressed: () => _nextPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGoalOptions() {
    return Goal.values.map((goal) {
      String title;
      String subtitle;

      switch (goal) {
        case Goal.maintain:
          title = 'Maintain Weight';
          subtitle = 'Keep your current weight';
          break;
        case Goal.bulking:
          title = 'Bulking';
          subtitle = 'Gain muscle mass';
          break;
        case Goal.cutting:
          title = 'Cutting';
          subtitle = 'Lose fat and get lean';
          break;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: RadioListTile<Goal>(
          title: Text(title),
          subtitle: Text(subtitle),
          value: goal,
          groupValue: _goal,
          onChanged: (value) {
            setState(() {
              _goal = value!;
            });
          },
        ),
      );
    }).toList();
  }

  Widget _buildSummaryPage() {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final age = int.tryParse(_ageController.text) ?? 0;
    final exerciseFreq = int.tryParse(_exerciseFrequencyController.text) ?? 0;

    final tempProfile = UserProfile(
      height: height,
      weight: weight,
      age: age,
      gender: _gender,
      activityLevel: _activityLevel,
      exerciseType: _exerciseType,
      exerciseFrequency: exerciseFreq,
      goal: _goal,
      createdAt: DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Summary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryRow('Height', '${height.toStringAsFixed(0)} cm'),
                  _buildSummaryRow('Weight', '${weight.toStringAsFixed(1)} kg'),
                  _buildSummaryRow('BMI', tempProfile.bmi.toStringAsFixed(1)),
                  _buildSummaryRow(
                    'TDEE',
                    '${tempProfile.tdee.toStringAsFixed(0)} kcal',
                  ),
                  _buildSummaryRow('Goal', _getGoalDisplayName(_goal)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _previousPage(),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Complete Setup',
                  onPressed: () => _completeOnboarding(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getGoalDisplayName(Goal goal) {
    switch (goal) {
      case Goal.maintain:
        return 'Maintain Weight';
      case Goal.bulking:
        return 'Bulking';
      case Goal.cutting:
        return 'Cutting';
    }
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedFromHeightWeight() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final age = int.tryParse(_ageController.text);
    return height != null &&
        height > 0 &&
        weight != null &&
        weight > 0 &&
        age != null &&
        age > 0;
  }

  bool _canProceedFromExercise() {
    final freq = int.tryParse(_exerciseFrequencyController.text);
    return freq != null && freq >= 0;
  }

  Future<void> _completeOnboarding() async {
    try {
      final settingsProvider = context.read<SettingsProvider>();

      final profile = UserProfile(
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        age: int.parse(_ageController.text),
        gender: _gender,
        activityLevel: _activityLevel,
        exerciseType: _exerciseType,
        exerciseFrequency: int.parse(_exerciseFrequencyController.text),
        goal: _goal,
        createdAt: DateTime.now(),
      );

      await settingsProvider.updateUserProfile(profile);
      await settingsProvider.completeOnboarding();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing setup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  @override
  void dispose() {
    _pageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _exerciseFrequencyController.dispose();
    super.dispose();
  }
}
