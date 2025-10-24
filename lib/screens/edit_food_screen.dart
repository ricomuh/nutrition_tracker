import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nutrition_entry.dart';
import '../models/food_item.dart';
import '../models/ai_analysis_response.dart';
import '../providers/nutrition_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../widgets/custom_button.dart';

class EditFoodScreen extends StatefulWidget {
  final NutritionEntry entry;

  const EditFoodScreen({super.key, required this.entry});

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _revisionController = TextEditingController();

  late MealType _selectedMealType;
  late List<FoodItemController> _foodItemControllers;
  bool _isReanalyzing = false;
  bool _showRevisionField = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _foodNameController.text = widget.entry.foodName;
    _commentController.text = widget.entry.comment;
    _selectedMealType = widget.entry.mealType;

    _foodItemControllers = widget.entry.items.map((item) {
      return FoodItemController(
        nameController: TextEditingController(text: item.name),
        quantityController: TextEditingController(
          text: item.quantity.toString(),
        ),
        unitController: TextEditingController(text: item.unit),
        caloriesController: TextEditingController(
          text: item.nutritions.calories.toStringAsFixed(1),
        ),
        proteinController: TextEditingController(
          text: item.nutritions.protein.toStringAsFixed(1),
        ),
        carbsController: TextEditingController(
          text: item.nutritions.carbohydrates.toStringAsFixed(1),
        ),
        fatController: TextEditingController(
          text: item.nutritions.fat.toStringAsFixed(1),
        ),
        fiberController: TextEditingController(
          text: item.nutritions.fiber.toStringAsFixed(1),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _commentController.dispose();
    _revisionController.dispose();
    for (final controller in _foodItemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Food Entry'),
        actions: [
          TextButton(
            onPressed: _isReanalyzing ? null : _saveChanges,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildMealTypeSelector(),
            const SizedBox(height: 24),
            _buildFoodItemsSection(),
            const SizedBox(height: 24),
            _buildRevisionSection(),
            const SizedBox(height: 24),
            _buildCommentSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Food Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter food name',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((mealType) {
                return ChoiceChip(
                  label: Text(_getMealTypeName(mealType)),
                  selected: _selectedMealType == mealType,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMealType = mealType;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemsSection() {
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
                  'Food Items & Nutrition',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addFoodItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._foodItemControllers.asMap().entries.map((entry) {
              return _buildFoodItemEditor(entry.key, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemEditor(int index, FoodItemController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Item',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Qty',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              if (_foodItemControllers.length > 1)
                IconButton(
                  onPressed: () => _removeFoodItem(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Nutrition per item:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.proteinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Protein (g)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.carbsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Carbs (g)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.fatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fat (g)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.fiberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fiber (g)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Expanded(child: SizedBox()), // Empty space for alignment
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevisionSection() {
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
                  'AI Re-analysis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRevisionField = !_showRevisionField;
                    });
                  },
                  icon: Icon(
                    _showRevisionField ? Icons.expand_less : Icons.expand_more,
                  ),
                  label: Text(_showRevisionField ? 'Hide' : 'Show'),
                ),
              ],
            ),
            if (_showRevisionField) ...[
              const SizedBox(height: 16),
              const Text(
                'Describe changes to recalculate nutrition:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _revisionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      'e.g., "Change to 3 eggs instead of 2, add 1 slice of cheese"',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isReanalyzing
                      ? 'Re-analyzing...'
                      : 'Re-analyze with AI',
                  onPressed: _isReanalyzing ? null : _reanalyzeWithAI,
                  isLoading: _isReanalyzing,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add any additional notes...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addFoodItem() {
    setState(() {
      _foodItemControllers.add(FoodItemController.empty());
    });
  }

  void _removeFoodItem(int index) {
    if (_foodItemControllers.length > 1) {
      setState(() {
        _foodItemControllers[index].dispose();
        _foodItemControllers.removeAt(index);
      });
    }
  }

  Future<void> _reanalyzeWithAI() async {
    if (_revisionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the changes first')),
      );
      return;
    }

    setState(() {
      _isReanalyzing = true;
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

      // Update the form with AI response
      _updateFromAIResponse(response);

      setState(() {
        _showRevisionField = false;
        _revisionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Re-analysis complete! Review and save changes.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during re-analysis: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isReanalyzing = false;
      });
    }
  }

  void _updateFromAIResponse(AiAnalysisResponse response) {
    setState(() {
      _foodNameController.text = response.foodName;
      _commentController.text = response.comment;

      // Dispose old controllers
      for (final controller in _foodItemControllers) {
        controller.dispose();
      }

      // Create new controllers from AI response
      _foodItemControllers = response.items.map((item) {
        return FoodItemController(
          nameController: TextEditingController(text: item.name),
          quantityController: TextEditingController(
            text: item.quantity.toString(),
          ),
          unitController: TextEditingController(text: item.unit),
          caloriesController: TextEditingController(
            text: item.nutritions.calories.toStringAsFixed(1),
          ),
          proteinController: TextEditingController(
            text: item.nutritions.protein.toStringAsFixed(1),
          ),
          carbsController: TextEditingController(
            text: item.nutritions.carbohydrates.toStringAsFixed(1),
          ),
          fatController: TextEditingController(
            text: item.nutritions.fat.toStringAsFixed(1),
          ),
          fiberController: TextEditingController(
            text: item.nutritions.fiber.toStringAsFixed(1),
          ),
        );
      }).toList();
    });
  }

  Future<void> _saveChanges() async {
    try {
      final nutritionProvider = context.read<NutritionProvider>();

      // Calculate totals from individual items
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalFiber = 0;

      final updatedItems = <FoodItem>[];

      for (final controller in _foodItemControllers) {
        final calories =
            double.tryParse(controller.caloriesController.text) ?? 0;
        final protein = double.tryParse(controller.proteinController.text) ?? 0;
        final carbs = double.tryParse(controller.carbsController.text) ?? 0;
        final fat = double.tryParse(controller.fatController.text) ?? 0;
        final fiber = double.tryParse(controller.fiberController.text) ?? 0;
        final quantity =
            double.tryParse(controller.quantityController.text) ?? 1;

        totalCalories += calories * quantity;
        totalProtein += protein * quantity;
        totalCarbs += carbs * quantity;
        totalFat += fat * quantity;
        totalFiber += fiber * quantity;

        updatedItems.add(
          FoodItem(
            name: controller.nameController.text,
            quantity: quantity,
            unit: controller.unitController.text,
            nutritions: FoodItemNutrition(
              calories: calories,
              protein: protein,
              carbohydrates: carbs,
              fiber: fiber,
              fat: fat,
            ),
          ),
        );
      }

      final updatedEntry = widget.entry.copyWith(
        foodName: _foodNameController.text,
        items: updatedItems,
        calories: totalCalories,
        protein: totalProtein,
        carbohydrates: totalCarbs,
        fiber: totalFiber,
        fat: totalFat,
        comment: _commentController.text,
        mealType: _selectedMealType,
        updatedAt: DateTime.now(),
      );

      await nutritionProvider.updateEntry(updatedEntry);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getMealTypeName(MealType mealType) {
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
}

class FoodItemController {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;
  final TextEditingController fiberController;

  FoodItemController({
    required this.nameController,
    required this.quantityController,
    required this.unitController,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatController,
    required this.fiberController,
  });

  factory FoodItemController.empty() {
    return FoodItemController(
      nameController: TextEditingController(),
      quantityController: TextEditingController(text: '1'),
      unitController: TextEditingController(text: 'piece'),
      caloriesController: TextEditingController(text: '0'),
      proteinController: TextEditingController(text: '0'),
      carbsController: TextEditingController(text: '0'),
      fatController: TextEditingController(text: '0'),
      fiberController: TextEditingController(text: '0'),
    );
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    fiberController.dispose();
  }
}
