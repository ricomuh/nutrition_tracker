import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_analysis_provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/settings_provider.dart';
import '../models/daily_analysis.dart';
import '../models/user_profile.dart';
import '../widgets/custom_button.dart';
import '../widgets/chat_bubble.dart';

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
      body: Container(
        color: Colors.grey[50], // Light background for chat
        child: _isGenerating
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
      ),
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
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // AI Analysis Messages
              ChatBubble(
                message: _analysis!.summary,
                isUser: false,
                title: 'Daily Summary',
                icon: Icons.summarize,
                accentColor: Colors.blue[700],
              ),
              const SizedBox(height: 12),
              ChatBubble(
                message: _analysis!.strengths,
                isUser: false,
                title: 'Strengths',
                icon: Icons.thumb_up,
                accentColor: Colors.green[700],
              ),
              const SizedBox(height: 12),
              ChatBubble(
                message: _analysis!.weaknesses,
                isUser: false,
                title: 'Areas to Improve',
                icon: Icons.warning,
                accentColor: Colors.orange[700],
              ),
              const SizedBox(height: 12),
              ChatBubble(
                message: _analysis!.recommendations,
                isUser: false,
                title: 'Recommendations',
                icon: Icons.lightbulb,
                accentColor: Colors.purple[700],
              ),
              const SizedBox(height: 12),
              ChatBubble(
                message: _analysis!.activityIntegration,
                isUser: false,
                title: 'Activity Integration',
                icon: Icons.fitness_center,
                accentColor: Colors.teal[700],
              ),

              // Chat History
              if (_analysis!.chatHistory.isNotEmpty) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: Colors.grey[300], thickness: 1),
                ),
                const SizedBox(height: 8),
                ..._analysis!.chatHistory.map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ChatBubble(
                      message: message.message,
                      isUser: message.isUser,
                      timestamp: message.timestamp,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
        _buildChatInput(),
      ],
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
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        hintText: 'Ask about your nutrition...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !provider.isLoading,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: provider.isLoading ? null : _sendMessage,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.send),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
