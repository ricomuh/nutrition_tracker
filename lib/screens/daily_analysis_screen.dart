import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_analysis_provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/settings_provider.dart';
import '../models/daily_analysis.dart';
import '../models/user_profile.dart';
import '../widgets/custom_button.dart';

class DailyAnalysisScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const DailyAnalysisScreen({super.key, this.selectedDate});

  @override
  State<DailyAnalysisScreen> createState() => _DailyAnalysisScreenState();
}

class _DailyAnalysisScreenState extends State<DailyAnalysisScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DailyAnalysis? _analysis;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final date = widget.selectedDate ?? DateTime.now();
    final analysisProvider = context.read<DailyAnalysisProvider>();
    _analysis = analysisProvider.getAnalysisForDate(date);

    if (_analysis == null) {
      _generateAnalysis();
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _generateAnalysis() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final date = widget.selectedDate ?? DateTime.now();
      final nutritionProvider = context.read<NutritionProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final analysisProvider = context.read<DailyAnalysisProvider>();

      // Get daily data
      final dailyEntries = nutritionProvider.getEntriesForDate(date);
      final userProfile = settingsProvider.userProfile;

      if (userProfile == null) {
        throw Exception(
          'User profile not found. Please complete your profile first.',
        );
      }

      // Calculate totals
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalFiber = 0;

      final foodItems = <FoodItemAnalysis>[];

      for (final entry in dailyEntries) {
        for (final item in entry.items) {
          totalCalories += item.nutritions.calories;
          totalProtein += item.nutritions.protein;
          totalCarbs += item.nutritions.carbohydrates;
          totalFat += item.nutritions.fat;
          totalFiber += item.nutritions.fiber;

          foodItems.add(
            FoodItemAnalysis(
              name: item.name,
              quantity: item.quantity,
              unit: item.unit,
              nutritions: NutritionData(
                calories: item.nutritions.calories,
                protein: item.nutritions.protein,
                carbohydrates: item.nutritions.carbohydrates,
                fiber: item.nutritions.fiber,
                fat: item.nutritions.fat,
              ),
            ),
          );
        }
      }

      // Calculate targets (similar to daily_summary_card.dart)
      final weight = userProfile.weight;
      final proteinTarget = _getProteinTarget(
        weight,
        userProfile.activityLevel,
      );
      final carbsTarget = _getCarbsTarget(weight, userProfile.goal);
      final fatTarget = _getFatTarget(weight);
      const fiberTarget = '25-35g';

      // Calculate target calories
      final targetCalories = nutritionProvider.calculateDailyTarget(
        userProfile,
      );

      final request = DailyAnalysisRequest(
        stats: DailyStats(
          totalCalories: totalCalories,
          totalProtein: totalProtein,
          totalCarbs: totalCarbs,
          totalFat: totalFat,
          totalFiber: totalFiber,
          targetCalories: targetCalories,
          proteinTarget: proteinTarget,
          carbsTarget: carbsTarget,
          fatTarget: fatTarget,
          fiberTarget: fiberTarget,
        ),
        foodItems: foodItems,
        profile: UserProfileData(
          height: userProfile.height,
          weight: userProfile.weight,
          age: userProfile.age,
          gender: userProfile.gender.name,
          activityLevel: userProfile.activityLevel.name,
          exerciseType: userProfile.exerciseType.name,
          exerciseFrequency: userProfile.exerciseFrequency,
          goal: userProfile.goal.name,
          calorieAdjustment: userProfile.calorieAdjustment,
          tdee: userProfile.tdee,
          tdeeTarget: targetCalories,
        ),
      );

      _analysis = await analysisProvider.generateDailyAnalysis(request);
      setState(() {
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate analysis: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getProteinTarget(double weight, ActivityLevel? activityLevel) {
    double minMultiplier = 1.0;
    double maxMultiplier = 2.0;

    switch (activityLevel) {
      case ActivityLevel.light:
        minMultiplier = 1.0;
        maxMultiplier = 1.6;
        break;
      case ActivityLevel.moderate:
        minMultiplier = 1.2;
        maxMultiplier = 1.8;
        break;
      case ActivityLevel.heavy:
        minMultiplier = 1.6;
        maxMultiplier = 2.2;
        break;
      default:
        break;
    }

    final minProtein = weight * minMultiplier;
    final maxProtein = weight * maxMultiplier;
    return '${minProtein.toStringAsFixed(0)}-${maxProtein.toStringAsFixed(0)}g';
  }

  String _getCarbsTarget(double weight, Goal? goal) {
    double multiplier;
    switch (goal) {
      case Goal.cutting:
        multiplier = 1.5;
        break;
      case Goal.bulking:
        multiplier = 4.0;
        break;
      case Goal.maintain:
      default:
        multiplier = 3.0;
        break;
    }
    final target = weight * multiplier;
    return '${target.toStringAsFixed(0)}g';
  }

  String _getFatTarget(double weight) {
    final minFat = weight * 0.8;
    final maxFat = weight * 1.2;
    return '${minFat.toStringAsFixed(0)}-${maxFat.toStringAsFixed(0)}g';
  }

  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty || _analysis == null) return;

    _chatController.clear();
    final date = widget.selectedDate ?? DateTime.now();

    try {
      await context.read<DailyAnalysisProvider>().addChatMessage(date, message);
      _analysis = context.read<DailyAnalysisProvider>().getAnalysisForDate(
        date,
      );
      setState(() {});

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.selectedDate ?? DateTime.now();
    final isToday = DateTime.now().difference(date).inDays == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isToday
              ? 'Daily Analysis'
              : 'Analysis for ${date.day}/${date.month}/${date.year}',
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          if (_analysis != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _generateAnalysis,
              tooltip: 'Regenerate Analysis',
            ),
        ],
      ),
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your daily nutrition...'),
                  SizedBox(height: 8),
                  Text(
                    'This may take a few seconds',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _analysis == null
          ? _buildErrorState()
          : _buildAnalysisContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No analysis available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate analysis to get personalized insights',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          CustomButton(text: 'Generate Analysis', onPressed: _generateAnalysis),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent() {
    if (_analysis == null) return const SizedBox();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnalysisCard(
                  'Daily Summary',
                  _analysis!.summary,
                  Icons.summarize,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildAnalysisCard(
                  'Strengths',
                  _analysis!.strengths,
                  Icons.thumb_up,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildAnalysisCard(
                  'Areas to Improve',
                  _analysis!.weaknesses,
                  Icons.warning,
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildAnalysisCard(
                  'Recommendations',
                  _analysis!.recommendations,
                  Icons.lightbulb,
                  Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildAnalysisCard(
                  'Activity Integration',
                  _analysis!.activityIntegration,
                  Icons.fitness_center,
                  Colors.teal,
                ),
                const SizedBox(height: 16),
                if (_analysis!.chatHistory.isNotEmpty) ...[
                  _buildChatHistory(),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildAnalysisCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHistory() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.chat, color: Colors.indigo, size: 20),
                SizedBox(width: 8),
                Text(
                  'Conversation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._analysis!.chatHistory.map(
              (message) => _buildChatMessage(message),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            message.isUser ? Icons.person : Icons.psychology,
            size: 16,
            color: message.isUser ? Colors.blue : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.message,
              style: TextStyle(
                fontSize: 13,
                color: message.isUser ? Colors.blue[700] : Colors.green[700],
                fontWeight: message.isUser
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Consumer<DailyAnalysisProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: 'Ask about your nutrition...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !provider.isLoading,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: provider.isLoading ? null : _sendMessage,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                color: Colors.green[700],
              ),
            ],
          ),
        );
      },
    );
  }
}
