import 'package:flutter/material.dart';

class AddWaterIntakeScreen extends StatefulWidget {
  const AddWaterIntakeScreen({super.key});

  @override
  AddWaterIntakeScreenState createState() => AddWaterIntakeScreenState();
}

class AddWaterIntakeScreenState extends State<AddWaterIntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  void _saveWaterIntake() {
    if (_formKey.currentState!.validate()) {
      final amount = int.parse(_amountController.text.trim());

      // TODO: Save the water intake amount via API or state management

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $amount ml of water!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Water Intake'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (ml)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _saveWaterIntake,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
