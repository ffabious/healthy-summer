import 'package:flutter/material.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedType;
  final List<String> _activityTypes = [
    'Running',
    'Cycling',
    'Swimming',
    'Walking',
    'Other',
  ];

  int? _durationMin;
  String? _intensity;
  int? _calories;
  final _locationController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  int _calculateCalories(
    String activityType,
    String intensity,
    int durationMin,
  ) {
    // Base calories per minute for different activities (for average 70kg person)
    Map<String, double> activityCaloriesPerMin = {
      'Running': 12.0,
      'Cycling': 8.0,
      'Swimming': 11.0,
      'Walking': 4.0,
      'Other': 6.0,
    };

    // Intensity multipliers
    Map<String, double> intensityMultipliers = {
      'Low': 0.7,
      'Medium': 1.0,
      'High': 1.4,
    };

    double baseCaloriesPerMin = activityCaloriesPerMin[activityType] ?? 6.0;
    double intensityMultiplier = intensityMultipliers[intensity] ?? 1.0;

    return (baseCaloriesPerMin * intensityMultiplier * durationMin).round();
  }

  void _updateCaloriesEstimate() {
    if (_selectedType != null && _intensity != null && _durationMin != null) {
      final estimatedCalories = _calculateCalories(
        _selectedType!,
        _intensity!,
        _durationMin!,
      );
      setState(() {
        _calories = estimatedCalories;
        _caloriesController.text = estimatedCalories.toString();
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      // TODO: Send data to backend or provider
      // Example:
      // final newActivity = Activity(
      //   type: _selectedType!,
      //   durationMin: _durationMin!,
      //   intensity: _intensity!,
      //   calories: _calories!,
      //   location: _locationController.text,
      // );

      if (_selectedType == null ||
          _durationMin == null ||
          _intensity == null ||
          _calories == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

      final data = PostActivityRequestModel(
        type: _selectedType!,
        durationMin: _durationMin!,
        intensity: _intensity!.toLowerCase(),
        calories: _calories!,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        timestamp: DateTime.now().toUtc(),
      );

      debugPrint('Posting activity: ${data.toJson()}');

      final response = ActivityService().postActivity(data);
      response
          .then((value) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Activity added successfully')),
            );
            Navigator.pop(context);
          })
          .catchError((error) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add activity: $error')),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Activity')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Calorie Calculation Formula',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Calories = Base Rate × Intensity × Duration',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Base rates (cal/min): Running: 12, Cycling: 8, Swimming: 11, Walking: 4, Other: 6',
                        style: TextStyle(fontSize: 12),
                      ),
                      const Text(
                        'Intensity: Low: 0.7×, Medium: 1.0×, High: 1.4×',
                        style: TextStyle(fontSize: 12),
                      ),
                      const Text(
                        '* Based on average 70kg person. You can edit the calculated value.',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Activity Type'),
                items: _activityTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                value: _selectedType,
                onChanged: (value) {
                  setState(() => _selectedType = value);
                  _updateCaloriesEstimate();
                },
                validator: (value) =>
                    value == null ? 'Please select activity type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'e.g. 30',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final n = int.tryParse(value ?? '');
                  if (n == null || n <= 0) return 'Enter valid duration';
                  return null;
                },
                onChanged: (value) {
                  final duration = int.tryParse(value);
                  if (duration != null && duration > 0) {
                    _durationMin = duration;
                    _updateCaloriesEstimate();
                  }
                },
                onSaved: (value) => _durationMin = int.parse(value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Intensity'),
                items: ['Low', 'Medium', 'High']
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
                value: _intensity,
                onChanged: (value) {
                  setState(() => _intensity = value);
                  _updateCaloriesEstimate();
                },
                validator: (value) =>
                    value == null ? 'Please select intensity' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories Burned',
                  hintText: 'Auto-calculated (editable)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final n = int.tryParse(value ?? '');
                  if (n == null || n < 0) return 'Enter valid calories';
                  return null;
                },
                onChanged: (value) {
                  final calories = int.tryParse(value);
                  if (calories != null && calories >= 0) {
                    _calories = calories;
                  }
                },
                onSaved: (value) => _calories = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Add Activity'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
