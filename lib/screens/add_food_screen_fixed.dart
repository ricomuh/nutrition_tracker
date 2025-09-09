import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../models/nutrition_entry.dart';
import '../models/ai_analysis_response.dart';
import '../providers/nutrition_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../widgets/custom_button.dart';

class AddFoodScreen extends StatefulWidget {
  final DateTime selectedDate;
  final MealType? selectedMealType;

  const AddFoodScreen({
    super.key,
    required this.selectedDate,
    this.selectedMealType,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final ImagePicker _picker = ImagePicker();
  final AiService _aiService = AiService();
  final TextEditingController _foodBreakdownController =
      TextEditingController();
  final TextEditingController _revisionController = TextEditingController();

  File? _selectedImage;
  MealType? _selectedMealType;
  AiAnalysisResponse? _aiResponse;
  bool _isAnalyzing = false;
  bool _isRevising = false;
  bool _showRevisionField = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType =
        widget.selectedMealType ??
        NutritionEntry.getMealTypeFromTime(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        actions: [
          if (_aiResponse != null)
            TextButton(
              onPressed: _isAnalyzing || _isRevising ? null : _saveEntry,
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
            const SizedBox(height: 24),
            _buildFoodBreakdownSection(),
            const SizedBox(height: 24),
            _buildAnalyzeButton(),
            if (_aiResponse != null) ...[
              const SizedBox(height: 24),
              _buildAiResults(),
            ],
          ],
        ),
      ),
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
          'Food Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_selectedImage != null)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
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
            ),
            child: const Center(
              child: Text(
                'No image selected',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Camera',
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Gallery',
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Breakdown (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _foodBreakdownController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'e.g., 2 eggs, 1 slice bread, 1 tbsp butter',
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    final settingsProvider = context.read<SettingsProvider>();
    final hasApiKey = settingsProvider.settings.hasValidApiKey;

    return Column(
      children: [
        if (!hasApiKey)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo mode: Using sample data. Configure API key in settings for real AI analysis.',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        CustomButton(
          text: hasApiKey ? 'Analyze Food' : 'Demo Analysis',
          isLoading: _isAnalyzing,
          onPressed: (_selectedImage != null && !_isAnalyzing)
              ? _analyzeFood
              : null,
        ),
      ],
    );
  }

  Widget _buildAiResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Analysis Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showRevisionField = !_showRevisionField;
                    });
                  },
                  child: const Text('Revise'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _aiResponse!.foodName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(_aiResponse!.items.map(
              (item) => Text(
                '• ${item.quantity}${item.unit} ${item.name}',
                style: const TextStyle(fontSize: 14),
              ),
            )),
            const SizedBox(height: 16),
            _buildNutritionGrid(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _aiResponse!.comment,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            if (_showRevisionField) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _revisionController,
                decoration: const InputDecoration(
                  labelText: 'Revise breakdown',
                  hintText: 'e.g., 3 eggs instead of 2 eggs',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Recalculate',
                isLoading: _isRevising,
                onPressed: _revisionController.text.isNotEmpty && !_isRevising
                    ? _recalculateNutrition
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildNutritionItem(
          'Calories',
          '${_aiResponse!.calories.toStringAsFixed(0)} kcal',
        ),
        _buildNutritionItem(
          'Protein',
          '${_aiResponse!.protein.toStringAsFixed(1)} g',
        ),
        _buildNutritionItem(
          'Carbs',
          '${_aiResponse!.carbohydrates.toStringAsFixed(1)} g',
        ),
        _buildNutritionItem('Fat', '${_aiResponse!.fat.toStringAsFixed(1)} g'),
        _buildNutritionItem(
          'Fiber',
          '${_aiResponse!.fiber.toStringAsFixed(1)} g',
        ),
      ],
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          _showPermissionDeniedMessage('Camera');
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _aiResponse = null; // Clear previous results
        });
      }
    } catch (e) {
      _showErrorMessage('Error picking image: $e');
    }
  }

  Future<void> _analyzeFood() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final settings = settingsProvider.settings;
      final hasApiKey = settings.hasValidApiKey;

      final response = await _aiService.analyzeFood(
        imageFile: _selectedImage!,
        provider: settings.aiProvider,
        apiKey: settings.currentApiKey ?? '',
        foodBreakdown: _foodBreakdownController.text.isNotEmpty
            ? _foodBreakdownController.text
            : null,
        demoMode: !hasApiKey,
        language: settings.responseLanguage,
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

  Future<void> _recalculateNutrition() async {
    setState(() {
      _isRevising = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final settings = settingsProvider.settings;
      final hasApiKey = settings.hasValidApiKey;

      final response = await _aiService.recalculateNutrition(
        updatedBreakdown: _revisionController.text,
        provider: settings.aiProvider,
        apiKey: settings.currentApiKey ?? '',
        demoMode: !hasApiKey,
      );

      setState(() {
        _aiResponse = response;
        _showRevisionField = false;
        _revisionController.clear();
      });
    } catch (e) {
      _showErrorMessage('Error recalculating nutrition: $e');
    } finally {
      setState(() {
        _isRevising = false;
      });
    }
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
        mealType: _selectedMealType!,
        date: widget.selectedDate,
        imagePath: _selectedImage?.path,
        createdAt: DateTime.now(),
      );

      await nutritionProvider.addEntry(entry);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food entry saved successfully!')),
        );
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
    _foodBreakdownController.dispose();
    _revisionController.dispose();
    super.dispose();
  }
}
