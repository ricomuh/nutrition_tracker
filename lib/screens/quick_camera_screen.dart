import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/nutrition_entry.dart';
import '../models/ai_analysis_response.dart';
import '../models/app_settings.dart';
import '../providers/nutrition_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../widgets/custom_button.dart';

class QuickCameraScreen extends StatefulWidget {
  final DateTime selectedDate;
  final MealType? selectedMealType;
  final VoidCallback? onSaveSuccess;

  const QuickCameraScreen({
    super.key,
    required this.selectedDate,
    this.selectedMealType,
    this.onSaveSuccess,
  });

  @override
  State<QuickCameraScreen> createState() => _QuickCameraScreenState();
}

class _QuickCameraScreenState extends State<QuickCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final AiService _aiService = AiService();

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  MealType? _selectedMealType;
  AiAnalysisResponse? _aiResponse;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType =
        widget.selectedMealType ??
        NutritionEntry.getMealTypeFromTime(DateTime.now());

    // Auto-open camera when screen loads (skip on web)
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openCamera();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Scan'),
        actions: [
          if (_aiResponse != null)
            TextButton(
              onPressed: _isAnalyzing ? null : _saveEntry,
              child: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMealTypeSelector(),
            const SizedBox(height: 24),
            _buildImageSection(),
            if (_aiResponse != null) ...[
              const SizedBox(height: 24),
              _buildAiResults(),
            ] else if (!_isAnalyzing && _selectedImageBytes == null) ...[
              const SizedBox(height: 24),
              _buildInstructions(),
            ],
          ],
        ),
      ),
      floatingActionButton: _selectedImageBytes == null
          ? FloatingActionButton(
              onPressed: _openCamera,
              backgroundColor: Colors.green[700],
              child: const Icon(Icons.camera_alt, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildMealTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<MealType>(
          value: _selectedMealType,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: MealType.values.map((mealType) {
            return DropdownMenuItem(
              value: mealType,
              child: Text(_getMealTypeDisplayName(mealType)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMealType = value;
            });
          },
        ),
      ],
    );
  }

  String _getMealTypeDisplayName(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.morningSnack:
        return 'Morning Snack';
      case MealType.middaySnack:
        return 'Midday Snack';
      case MealType.afternoonSnack:
        return 'Afternoon Snack';
      case MealType.eveningSnack:
        return 'Evening Snack';
    }
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_selectedImageBytes != null)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: kIsWeb
                    ? MemoryImage(_selectedImageBytes!)
                    : FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          )
        else if (_isAnalyzing)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your food...'),
                ],
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Tap camera button to capture food'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Quick Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('• Take a clear photo of your entire meal'),
            const Text('• Make sure food items are well-lit and visible'),
            const Text('• Analysis will start automatically after capture'),
            const Text('• You can retake the photo if needed'),
          ],
        ),
      ),
    );
  }

  Widget _buildAiResults() {
    if (_aiResponse == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Food name
            Text(
              _aiResponse!.foodName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Nutrition summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutritionItem('Cal', _aiResponse!.calories, Colors.red),
                _buildNutritionItem(
                  'Protein',
                  _aiResponse!.protein,
                  Colors.blue,
                ),
                _buildNutritionItem(
                  'Carbs',
                  _aiResponse!.carbohydrates,
                  Colors.orange,
                ),
                _buildNutritionItem('Fat', _aiResponse!.fat, Colors.purple),
              ],
            ),

            const SizedBox(height: 16),

            // AI Comment
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.smart_toy, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiResponse!.comment,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Retake Photo',
                    onPressed: _retakePhoto,
                    backgroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Save Entry',
                    onPressed: _saveEntry,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _openCamera() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        _showPermissionDeniedMessage('Camera');
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
          _selectedImageBytes = bytes;
          _aiResponse = null;
        });

        // Auto-analyze after capture
        await _analyzeFood();
      }
    } catch (e) {
      _showErrorMessage('Error capturing photo: $e');
    }
  }

  Future<void> _analyzeFood() async {
    if (_selectedImageBytes == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final settings = settingsProvider.settings;
      final hasApiKey = settings.hasValidApiKey;

      final response = await _aiService.analyzeFood(
        imageBytes: _selectedImageBytes!,
        provider: settings.aiProvider,
        apiKey: _getApiKeyForProvider(settings),
        demoMode: !hasApiKey,
        language: settings.responseLanguage,
        userGoal: settingsProvider.userProfile?.goal.toString().split('.').last,
      );

      setState(() {
        _aiResponse = response;
      });
    } catch (e) {
      _showErrorMessage('Error analyzing food: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  dynamic _getApiKeyForProvider(AppSettings settings) {
    switch (settings.aiProvider) {
      case AiProvider.gemini:
        return settings.geminiApiKey ?? '';
      case AiProvider.openai:
        return settings.openaiApiKey ?? '';
      case AiProvider.lunos:
        return settings.lunosApiKeys;
    }
  }

  void _retakePhoto() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
      _aiResponse = null;
    });
    _openCamera();
  }

  Future<void> _saveEntry() async {
    if (_aiResponse == null || _selectedMealType == null) return;

    try {
      final nutritionProvider = context.read<NutritionProvider>();

      final entry = NutritionEntry(
        foodName: _aiResponse!.foodName,
        items: _aiResponse!.items,
        calories: _aiResponse!.calories,
        protein: _aiResponse!.protein,
        carbohydrates: _aiResponse!.carbohydrates,
        fiber: _aiResponse!.fiber,
        fat: _aiResponse!.fat,
        comment: _aiResponse!.comment,
        mealScore: _aiResponse!.mealScore,
        scoreReasoning: _aiResponse!.scoreReasoning,
        mealType: _selectedMealType!,
        date: widget.selectedDate,
        imagePath: _selectedImage?.path,
        createdAt: DateTime.now(),
      );

      await nutritionProvider.addEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food entry saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Call onSaveSuccess or navigate back
        if (widget.onSaveSuccess != null) {
          widget.onSaveSuccess!();
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      _showErrorMessage('Error saving entry: $e');
    }
  }

  void _showPermissionDeniedMessage(String permission) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permission permission is required'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
