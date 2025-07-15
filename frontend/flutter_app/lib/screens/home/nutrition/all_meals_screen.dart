import 'package:flutter/material.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';

class AllMealsScreen extends StatefulWidget {
  const AllMealsScreen({super.key});

  @override
  State<AllMealsScreen> createState() => _AllMealsScreenState();
}

class _AllMealsScreenState extends State<AllMealsScreen> {
  final NutritionService _nutritionService = NutritionService();
  List<PostMealResponseModel> _allMeals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllMeals();
  }

  Future<void> _loadAllMeals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final mealsResult = await _nutritionService.getMeals();
      setState(() {
        _allMeals = mealsResult.meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMeal(PostMealResponseModel meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${meal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _nutritionService.deleteMeal(meal.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${meal.name} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadAllMeals(); // Refresh the list
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete meal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editMeal(PostMealResponseModel meal) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditMealScreen(meal: meal),
      ),
    );

    if (result == true) {
      _loadAllMeals(); // Refresh the list if meal was updated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Meals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllMeals,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllMeals,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-meal').then((_) => _loadAllMeals());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load meals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllMeals,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allMeals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No meals logged yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-meal').then((_) => _loadAllMeals());
              },
              child: const Text('Add Your First Meal'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allMeals.length,
      itemBuilder: (context, index) {
        final meal = _allMeals[index];
        return _buildMealCard(meal);
      },
    );
  }

  Widget _buildMealCard(PostMealResponseModel meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: const Icon(Icons.restaurant, color: Colors.orange),
        ),
        title: Text(
          meal.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${meal.calories} kcal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              'Protein: ${meal.protein.toStringAsFixed(1)}g • Carbs: ${meal.carbohydrates.toStringAsFixed(1)}g • Fats: ${meal.fats.toStringAsFixed(1)}g',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateTime(meal.timestamp),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editMeal(meal);
            } else if (value == 'delete') {
              _deleteMeal(meal);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(mealDate).inDays;

    String dateStr;
    if (difference == 0) {
      dateStr = 'Today';
    } else if (difference == 1) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }
}

class EditMealScreen extends StatefulWidget {
  final PostMealResponseModel meal;

  const EditMealScreen({super.key, required this.meal});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final NutritionService _nutritionService = NutritionService();
  
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal.name);
    _caloriesController = TextEditingController(text: widget.meal.calories.toString());
    _proteinController = TextEditingController(text: widget.meal.protein.toStringAsFixed(1));
    _carbsController = TextEditingController(text: widget.meal.carbohydrates.toStringAsFixed(1));
    _fatsController = TextEditingController(text: widget.meal.fats.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _updateMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedMeal = PostMealRequestModel(
        name: _nameController.text.trim(),
        calories: int.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbohydrates: double.parse(_carbsController.text),
        fats: double.parse(_fatsController.text),
      );

      await _nutritionService.updateMeal(widget.meal.id, updatedMeal);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update meal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meal'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateMeal,
            child: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a meal name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(),
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter calories';
                }
                final calories = int.tryParse(value);
                if (calories == null || calories < 0) {
                  return 'Please enter a valid number of calories';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _proteinController,
              decoration: const InputDecoration(
                labelText: 'Protein',
                border: OutlineInputBorder(),
                suffixText: 'g',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter protein amount';
                }
                final protein = double.tryParse(value);
                if (protein == null || protein < 0) {
                  return 'Please enter a valid protein amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _carbsController,
              decoration: const InputDecoration(
                labelText: 'Carbohydrates',
                border: OutlineInputBorder(),
                suffixText: 'g',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter carbohydrates amount';
                }
                final carbs = double.tryParse(value);
                if (carbs == null || carbs < 0) {
                  return 'Please enter a valid carbohydrates amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fatsController,
              decoration: const InputDecoration(
                labelText: 'Fats',
                border: OutlineInputBorder(),
                suffixText: 'g',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter fats amount';
                }
                final fats = double.tryParse(value);
                if (fats == null || fats < 0) {
                  return 'Please enter a valid fats amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateMeal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Update Meal'),
            ),
          ],
        ),
      ),
    );
  }
}
