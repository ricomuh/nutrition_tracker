import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/user_profile.dart';
import '../widgets/custom_button.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final userProfile = settingsProvider.userProfile;

          if (userProfile == null) {
            return _buildNoProfileState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(userProfile),
                const SizedBox(height: 20),
                _buildBasicInfo(userProfile),
                const SizedBox(height: 20),
                _buildFitnessInfo(userProfile),
                const SizedBox(height: 20),
                _buildGoalsInfo(userProfile),
                const SizedBox(height: 20),
                _buildCalculatedValues(userProfile),
                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoProfileState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Profile Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your profile to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Create Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    final bmi =
        profile.weight / ((profile.height / 100) * (profile.height / 100));
    String bmiCategory;
    Color bmiColor;

    if (bmi < 18.5) {
      bmiCategory = 'Underweight';
      bmiColor = Colors.blue;
    } else if (bmi < 25) {
      bmiCategory = 'Normal';
      bmiColor = Colors.green;
    } else if (bmi < 30) {
      bmiCategory = 'Overweight';
      bmiColor = Colors.orange;
    } else {
      bmiCategory = 'Obese';
      bmiColor = Colors.red;
    }

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  profile.gender == Gender.male ? Icons.man : Icons.woman,
                  size: 50,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${profile.age} years old',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bmiColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'BMI: ${bmi.toStringAsFixed(1)} ($bmiCategory)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(UserProfile profile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.height,
              label: 'Height',
              value: '${profile.height.toStringAsFixed(0)} cm',
              color: Colors.blue,
            ),
            _buildInfoRow(
              icon: Icons.monitor_weight,
              label: 'Weight',
              value: '${profile.weight.toStringAsFixed(1)} kg',
              color: Colors.purple,
            ),
            _buildInfoRow(
              icon: profile.gender == Gender.male ? Icons.man : Icons.woman,
              label: 'Gender',
              value: profile.gender.name.toUpperCase(),
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessInfo(UserProfile profile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fitness Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.directions_run,
              label: 'Activity Level',
              value: profile.activityLevel.name.toUpperCase(),
              color: Colors.orange,
            ),
            _buildInfoRow(
              icon: Icons.fitness_center,
              label: 'Exercise Type',
              value: profile.exerciseType.name.toUpperCase(),
              color: Colors.red,
            ),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Exercise Frequency',
              value: '${profile.exerciseFrequency}x per week',
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsInfo(UserProfile profile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goals & Targets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.track_changes,
              label: 'Goal',
              value: profile.goal.name.toUpperCase(),
              color: Colors.teal,
            ),
            _buildInfoRow(
              icon: Icons.adjust,
              label: 'Calorie Adjustment',
              value:
                  '${profile.calorieAdjustment > 0 ? '+' : ''}${profile.calorieAdjustment} kcal',
              color: profile.calorieAdjustment > 0 ? Colors.green : Colors.red,
            ),
            _buildInfoRow(
              icon: Icons.local_fire_department,
              label: 'Target Calories',
              value: '${profile.targetCalories.toStringAsFixed(0)} kcal/day',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatedValues(UserProfile profile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calculated Values',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.whatshot,
              label: 'TDEE',
              value: '${profile.tdee.toStringAsFixed(0)} kcal/day',
              color: Colors.deepOrange,
            ),
            _buildInfoRow(
              icon: Icons.speed,
              label: 'BMR',
              value: '${(profile.weight * 22).toStringAsFixed(0)} kcal/day',
              color: Colors.cyan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Edit Profile',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            _showDeleteProfileDialog();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 8),
              Text('Reset Profile'),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Profile'),
          content: const Text(
            'Are you sure you want to reset your profile? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final settingsProvider = context.read<SettingsProvider>();
                await settingsProvider.resetProfile();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile has been reset'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
