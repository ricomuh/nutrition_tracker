import 'package:flutter/material.dart';

class AddFoodScreen extends StatefulWidget {
  final DateTime selectedDate;
  final dynamic selectedMealType;

  const AddFoodScreen({
    super.key,
    required this.selectedDate,
    this.selectedMealType,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
      body: const Center(child: Text('AddFoodScreen - Test')),
    );
  }
}
