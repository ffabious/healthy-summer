import 'package:flutter/material.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  AddMealScreenState createState() => AddMealScreenState();
}

class AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbohydratesController =
      TextEditingController();
  final TextEditingController _fatsController = TextEditingController();

  final NutritionService _nutritionService = NutritionService();
  bool _isLoading = false;

  // Preset meals with nutritional values
  static const List<PresetMeal> _presetMeals = [
    PresetMeal(
      name: "Grilled Chicken Breast",
      calories: 165,
      protein: 31.0,
      carbohydrates: 0.0,
      fats: 3.6,
    ),
    PresetMeal(
      name: "Oatmeal with Banana",
      calories: 300,
      protein: 10.0,
      carbohydrates: 54.0,
      fats: 6.0,
    ),
    PresetMeal(
      name: "Greek Yogurt",
      calories: 150,
      protein: 20.0,
      carbohydrates: 9.0,
      fats: 4.0,
    ),
    PresetMeal(
      name: "Salmon Fillet",
      calories: 280,
      protein: 25.0,
      carbohydrates: 0.0,
      fats: 18.0,
    ),
    PresetMeal(
      name: "Avocado Toast",
      calories: 320,
      protein: 8.0,
      carbohydrates: 30.0,
      fats: 20.0,
    ),
    PresetMeal(
      name: "Brown Rice Bowl",
      calories: 250,
      protein: 6.0,
      carbohydrates: 50.0,
      fats: 2.0,
    ),
    PresetMeal(
      name: "Mixed Nuts (30g)",
      calories: 180,
      protein: 6.0,
      carbohydrates: 6.0,
      fats: 16.0,
    ),
    PresetMeal(
      name: "Protein Smoothie",
      calories: 220,
      protein: 25.0,
      carbohydrates: 15.0,
      fats: 8.0,
    ),
  ];

  void _fillFromPreset(PresetMeal preset) {
    setState(() {
      _mealNameController.text = preset.name;
      _caloriesController.text = preset.calories.toString();
      _proteinController.text = preset.protein.toString();
      _carbohydratesController.text = preset.carbohydrates.toString();
      _fatsController.text = preset.fats.toString();
    });
  }

  void _showPresetMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select a Preset Meal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _presetMeals.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final meal = _presetMeals[index];
                    return ListTile(
                      title: Text(
                        meal.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${meal.calories} kcal • P: ${meal.protein}g • C: ${meal.carbohydrates}g • F: ${meal.fats}g',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        _fillFromPreset(meal);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final meal = PostMealRequestModel(
          name: _mealNameController.text.trim(),
          calories: int.parse(_caloriesController.text.trim()),
          protein: double.parse(_proteinController.text.trim()),
          carbohydrates: double.parse(_carbohydratesController.text.trim()),
          fats: double.parse(_fatsController.text.trim()),
        );

        await _nutritionService.postMeal(meal);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Meal "${meal.name}" added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add meal: ${e.toString()}'),
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
    _mealNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbohydratesController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: _showPresetMenu,
            tooltip: 'Preset Meals',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fastfood, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text(
                              'Meal Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _showPresetMenu,
                              icon: const Icon(Icons.menu_book, size: 16),
                              label: const Text('Presets'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _mealNameController,
                          decoration: const InputDecoration(
                            labelText: 'Meal Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.label),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Enter meal name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _caloriesController,
                          decoration: const InputDecoration(
                            labelText: 'Calories (kcal)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_fire_department),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter calories';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              'Macronutrients',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _proteinController,
                                decoration: const InputDecoration(
                                  labelText: 'Protein (g)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.fitness_center,
                                    color: Colors.red,
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter protein';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Enter valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _carbohydratesController,
                                decoration: const InputDecoration(
                                  labelText: 'Carbs (g)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.grain,
                                    color: Colors.amber,
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter carbs';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Enter valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fatsController,
                          decoration: const InputDecoration(
                            labelText: 'Fats (g)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.opacity,
                              color: Colors.green,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter fats';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
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
                        : const Text(
                            'Save Meal',
                            style: TextStyle(fontSize: 16),
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
