import 'package:flutter/material.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';

class AddWaterIntakeScreen extends StatefulWidget {
  const AddWaterIntakeScreen({super.key});

  @override
  AddWaterIntakeScreenState createState() => AddWaterIntakeScreenState();
}

class AddWaterIntakeScreenState extends State<AddWaterIntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final NutritionService _nutritionService = NutritionService();
  bool _isLoading = false;

  // Quick add buttons for common water amounts
  final List<int> _quickAmounts = [250, 500, 750, 1000];

  void _setQuickAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  Future<void> _saveWaterIntake() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final amount = int.parse(_amountController.text.trim());
        final waterIntake = PostWaterIntakeRequestModel(amount: amount);

        await _nutritionService.postWaterIntake(waterIntake);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $amount ml of water!'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add water intake: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
      appBar: AppBar(title: const Text('Add Water Intake')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick amount buttons
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.speed, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              'Quick Add',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: _quickAmounts.map((amount) {
                            return FilterChip(
                              label: Text('${amount}ml'),
                              selected:
                                  _amountController.text == amount.toString(),
                              onSelected: (selected) {
                                if (selected) {
                                  _setQuickAmount(amount);
                                }
                              },
                              selectedColor: Colors.blue[100],
                              checkmarkColor: Colors.blue,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Custom amount input
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              'Custom Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount (ml)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.local_drink,
                              color: Colors.blue,
                            ),
                            suffixText: 'ml',
                            helperText: 'Enter the amount of water you drank',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter amount';
                            }
                            final intValue = int.tryParse(value);
                            if (intValue == null) return 'Enter a valid number';
                            if (intValue <= 0) return 'Amount must be positive';
                            if (intValue > 5000) {
                              return 'Amount seems too large';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveWaterIntake,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save),
                              SizedBox(width: 8),
                              Text(
                                'Save Water Intake',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tips card
                Card(
                  color: Colors.blue[25],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Hydration Tips',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Aim for 8 glasses (2L) of water daily\n'
                          '• Drink water before, during, and after exercise\n'
                          '• Track your intake throughout the day',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
