import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/nutrition_entry.dart';
import '../models/ai_analysis_response.dart';
import '../models/food_item.dart';
import '../providers/nutrition_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../widgets/custom_button.dart';

class AddFoodScreen extends StatefulWidget {
  final DateTime selectedDate;
  final MealType? selectedMealType;
  final VoidCallback? onSaveSuccess;

  const AddFoodScreen({
    super.key,
    required this.selectedDate,
    this.selectedMealType,
    this.onSaveSuccess,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final AiService _aiService = AiService();
  final TextEditingController _foodBreakdownController =
      TextEditingController();
  final TextEditingController _revisionController = TextEditingController();
  final FocusNode _revisionFocusNode = FocusNode();
  final TextEditingController _foodNameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _analysisResultsKey = GlobalKey();

  late TabController _tabController;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  MealType? _selectedMealType;
  AiAnalysisResponse? _aiResponse;
  bool _isAnalyzing = false;
  bool _isRevising = false;
  bool _showRevisionField = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedMealType =
        widget.selectedMealType ??
        NutritionEntry.getMealTypeFromTime(DateTime.now());

    // Add listener to revision controller to update button state
    _revisionController.addListener(() {
      setState(() {});
    });

    // Add listener to food name controller to update button state
    _foodNameController.addListener(() {
      setState(() {});
    });
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt), text: 'With Photo'),
            Tab(icon: Icon(Icons.text_fields), text: 'Text Only'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPhotoTab(), _buildTextTab()],
      ),
    );
  }

  Widget _buildPhotoTab() {
    return SingleChildScrollView(
      controller: _scrollController,
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
            Container(key: _analysisResultsKey, child: _buildAiResults()),
          ],
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMealTypeSelector(),
          const SizedBox(height: 24),
          _buildFoodNameSection(),
          const SizedBox(height: 24),
          _buildFoodBreakdownSection(),
          const SizedBox(height: 24),
          _buildAnalyzeButton(),
          if (_aiResponse != null) ...[
            const SizedBox(height: 24),
            Container(key: _analysisResultsKey, child: _buildAiResults()),
          ],
        ],
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

  Widget _buildFoodNameSection() {
    final bool isInputDisabled = _aiResponse != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Name',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _foodNameController,
          enabled: !isInputDisabled,
          decoration: InputDecoration(
            hintText: isInputDisabled
                ? 'Input locked after analysis'
                : 'e.g., Fried Rice with Chicken',
            border: const OutlineInputBorder(),
            fillColor: isInputDisabled ? Colors.grey.withOpacity(0.1) : null,
            filled: isInputDisabled,
            prefixIcon: isInputDisabled
                ? const Icon(Icons.lock, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    final bool isInputDisabled = _aiResponse != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Image',
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
            child: isInputDisabled
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock, color: Colors.white, size: 40),
                    ),
                  )
                : null,
          )
        else
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: isInputDisabled ? Colors.grey.withOpacity(0.1) : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isInputDisabled ? Icons.lock : Icons.image,
                    color: Colors.grey,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isInputDisabled
                        ? 'Image locked after analysis'
                        : 'No image selected',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Camera',
                onPressed: isInputDisabled
                    ? null
                    : () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Gallery',
                onPressed: isInputDisabled
                    ? null
                    : () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodBreakdownSection() {
    final bool isInputDisabled = _aiResponse != null;

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
          enabled: !isInputDisabled,
          maxLines: 3,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: isInputDisabled
                ? 'Input locked after analysis'
                : 'e.g., 2 eggs, 1 slice bread, 1 tbsp butter',
            fillColor: isInputDisabled ? Colors.grey.withOpacity(0.1) : null,
            filled: isInputDisabled,
            prefixIcon: isInputDisabled
                ? const Icon(Icons.lock, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    final settingsProvider = context.read<SettingsProvider>();
    final hasApiKey = settingsProvider.settings.hasValidApiKey;
    final isPhotoTab = _tabController.index == 0;
    final bool hasAnalysisResult = _aiResponse != null;

    // Determine if button should be enabled
    bool isEnabled;
    if (isPhotoTab) {
      isEnabled = _selectedImageBytes != null && !_isAnalyzing;
    } else {
      isEnabled =
          (_foodNameController.text.isNotEmpty ||
              _foodBreakdownController.text.isNotEmpty) &&
          !_isAnalyzing;
    }

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
        if (!hasAnalysisResult)
          CustomButton(
            text: hasApiKey
                ? (isPhotoTab ? 'Analyze Photo' : 'Analyze Text')
                : 'Demo Analysis',
            isLoading: _isAnalyzing,
            onPressed: isEnabled ? _analyzeFood : null,
          )
        else
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Start Over',
                  onPressed: _resetAnalysis,
                  backgroundColor: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Re-analyze',
                  isLoading: _isAnalyzing,
                  onPressed: isEnabled ? _analyzeFood : null,
                ),
              ),
            ],
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
                    if (_showRevisionField) {
                      _scrollToRevisionField();
                    }
                  },
                  child: const Text('Revise'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // AI Comment Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiResponse!.comment,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Food Name and Items
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aiResponse!.foodName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Food Items:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...(_aiResponse!.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            '${item.quantity}${item.unit} ${item.name}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildNutritionGrid(),
            const SizedBox(height: 20),
            _buildFoodItemsBreakdown(),
            const SizedBox(height: 16),
            if (_showRevisionField) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _revisionController,
                focusNode: _revisionFocusNode,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildNutritionItem(
                'Calories',
                '${_aiResponse!.calories.toStringAsFixed(0)} kcal',
                Colors.red,
              ),
              _buildNutritionItem(
                'Protein',
                '${_aiResponse!.protein.toStringAsFixed(1)} g',
                Colors.blue,
              ),
              _buildNutritionItem(
                'Carbs',
                '${_aiResponse!.carbohydrates.toStringAsFixed(1)} g',
                Colors.orange,
              ),
              _buildNutritionItem(
                'Fat',
                '${_aiResponse!.fat.toStringAsFixed(1)} g',
                Colors.purple,
              ),
              _buildNutritionItem(
                'Fiber',
                '${_aiResponse!.fiber.toStringAsFixed(1)} g',
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, [Color? color]) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (color ?? Colors.blue).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: (color ?? Colors.blue).withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemsBreakdown() {
    if (_aiResponse == null || _aiResponse!.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Food Items Breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_aiResponse!.items
              .map((item) => _buildFoodItemCard(item))
              .toList()),
        ],
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItem item) {
    // Use actual nutrition data per item if available, otherwise fall back to estimation
    final calories = item.nutritions.calories;
    final protein = item.nutritions.protein;
    final carbs = item.nutritions.carbohydrates;
    final fat = item.nutritions.fat;
    final fiber = item.nutritions.fiber;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.05),
            Colors.green.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fastfood, color: Colors.blue, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${item.quantity} ${item.unit} of ${item.name}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniNutritionInfo('Cal', calories, '', Colors.red),
              const SizedBox(width: 12),
              _buildMiniNutritionInfo('Protein', protein, 'g', Colors.blue),
              const SizedBox(width: 12),
              _buildMiniNutritionInfo('Carbs', carbs, 'g', Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMiniNutritionInfo('Fat', fat, 'g', Colors.purple),
              const SizedBox(width: 12),
              _buildMiniNutritionInfo('Fiber', fiber, 'g', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNutritionInfo(
    String label,
    double value,
    String unit, [
    Color? color,
  ]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? Colors.grey).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}$unit',
        style: TextStyle(
          fontSize: 12,
          color: color ?? Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
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
        final bytes = await image.readAsBytes();
        setState(() {
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
          _selectedImageBytes = bytes;
          _aiResponse = null; // Clear previous results
        });
      }
    } catch (e) {
      _showErrorMessage('Error picking image: $e');
    }
  }

  Future<void> _analyzeFood() async {
    final isPhotoTab = _tabController.index == 0;

    // Validate input based on tab
    if (isPhotoTab && _selectedImageBytes == null) return;
    if (!isPhotoTab &&
        _foodNameController.text.isEmpty &&
        _foodBreakdownController.text.isEmpty)
      return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final settings = settingsProvider.settings;
      final hasApiKey = settings.hasValidApiKey;

      AiAnalysisResponse response;

      if (isPhotoTab) {
        // Analyze with image
        response = await _aiService.analyzeFood(
          imageBytes: _selectedImageBytes!,
          provider: settings.aiProvider,
          apiKey: settings.currentApiKey ?? '',
          foodBreakdown: _foodBreakdownController.text.isNotEmpty
              ? _foodBreakdownController.text
              : null,
          demoMode: !hasApiKey,
        );
      } else {
        // Analyze text only
        final foodDescription = _foodNameController.text.isNotEmpty
            ? _foodNameController.text
            : _foodBreakdownController.text;

        response = await _aiService.analyzeTextOnly(
          foodName: foodDescription,
          provider: settings.aiProvider,
          apiKey: settings.currentApiKey ?? '',
          foodBreakdown: _foodBreakdownController.text.isNotEmpty
              ? _foodBreakdownController.text
              : null,
          demoMode: !hasApiKey,
        );
      }

      setState(() {
        _aiResponse = response;
      });

      // Auto-scroll to analysis results
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAnalysisResults();
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

      // Save the recalculated data as a new entry instead of overriding
      await _saveEntryFromResponse(response);

      setState(() {
        _showRevisionField = false;
        _revisionController.clear();
      });

      // Show success message and reset form instead of popping
      _showSuccessMessage('Recalculated entry saved successfully!');
      _resetAnalysis();
      _selectedImage = null;
      _selectedImageBytes = null;
      // Don't reset _selectedMealType so user can add more food to same meal

      // Navigate back to home tab
      if (widget.onSaveSuccess != null) {
        widget.onSaveSuccess!();
      }
    } catch (e) {
      _showErrorMessage('Error recalculating nutrition: $e');
    } finally {
      setState(() {
        _isRevising = false;
      });
    }
  }

  Future<void> _saveEntryFromResponse(AiAnalysisResponse response) async {
    if (_selectedMealType == null) return;

    try {
      final nutritionProvider = context.read<NutritionProvider>();

      final entry = NutritionEntry(
        foodName: response.foodName,
        items: response.items,
        calories: response.calories,
        protein: response.protein,
        carbohydrates: response.carbohydrates,
        fiber: response.fiber,
        fat: response.fat,
        comment: response.comment,
        mealType: _selectedMealType!,
        date: widget.selectedDate,
        imagePath: _selectedImage?.path,
        createdAt: DateTime.now(),
      );

      await nutritionProvider.addEntry(entry);
    } catch (e) {
      _showErrorMessage('Error saving entry: $e');
      rethrow;
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
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
        // Clear the form but keep meal type selected
        _resetAnalysis();
        _selectedImage = null;
        _selectedImageBytes = null;
        _aiResponse = null;
        // Don't reset _selectedMealType so user can add more food to same meal

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food entry saved successfully!')),
        );

        // Navigate back to home tab
        if (widget.onSaveSuccess != null) {
          widget.onSaveSuccess!();
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

  void _resetAnalysis() {
    setState(() {
      _aiResponse = null;
      _showRevisionField = false;
      _revisionController.clear();
      // Note: We don't clear the input fields to preserve user's work
      // but they become editable again
    });
  }

  void _scrollToAnalysisResults() {
    final context = _analysisResultsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToRevisionField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToAnalysisResults();
      // Focus on revision text field after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _revisionFocusNode.requestFocus();
        _revisionController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _revisionController.text.length,
        );
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _revisionFocusNode.dispose();
    _foodBreakdownController.dispose();
    _revisionController.dispose();
    _foodNameController.dispose();
    super.dispose();
  }
}
