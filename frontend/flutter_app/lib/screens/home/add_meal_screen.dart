import 'package:flutter/material.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  AddMealScreenState createState() => AddMealScreenState();
}

class AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      final mealName = _mealNameController.text.trim();
      final calories = int.parse(_caloriesController.text.trim());

      // TODO: Call your API or state management method to save meal

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meal "$mealName" with $calories kcal added!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Meal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _mealNameController,
                decoration: InputDecoration(
                  labelText: 'Meal Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter meal name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  labelText: 'Calories (kcal)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter calories';
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _saveMeal,
                  child: const Text('Save Meal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
