import 'package:flutter/material.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';

class EditActivityScreen extends StatefulWidget {
  const EditActivityScreen({super.key});

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late ActivityModel _activity;
  bool _isInitialized = false;

  String? _selectedType;
  final List<String> _activityTypes = [
    'Running',
    'Cycling',
    'Swimming',
    'Walking',
    'Gym',
    'Yoga',
    'Other',
  ];

  int? _durationMin;
  String? _intensity;
  int? _calories;
  final _locationController = TextEditingController();
  final _caloriesController = TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // Get the activity from route arguments
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is ActivityModel) {
        _activity = args;
        _initializeFields();
        _isInitialized = true;
      }
    }
  }

  void _initializeFields() {
    _selectedType = _activity.type;
    _durationMin = _activity.durationMin;
    _intensity = _activity.intensity;
    _calories = _activity.calories;
    _locationController.text = _activity.location ?? '';
    _caloriesController.text = _activity.calories.toString();

    // Ensure we have proper capitalization for intensity display
    if (_intensity != null) {
      _intensity =
          _intensity![0].toUpperCase() + _intensity!.substring(1).toLowerCase();
    }
  }

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
      'Gym': 8.0,
      'Yoga': 3.0,
      'Other': 6.0,
    };

    // Intensity multipliers
    Map<String, double> intensityMultipliers = {
      'low': 0.7,
      'medium': 1.0,
      'high': 1.4,
    };

    double baseCaloriesPerMin = activityCaloriesPerMin[activityType] ?? 6.0;
    double intensityMultiplier =
        intensityMultipliers[intensity.toLowerCase()] ?? 1.0;

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
        // Update the controller text without triggering onChanged
        _caloriesController.value = _caloriesController.value.copyWith(
          text: estimatedCalories.toString(),
          selection: TextSelection.collapsed(
            offset: estimatedCalories.toString().length,
          ),
        );
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      if (_selectedType == null ||
          _durationMin == null ||
          _intensity == null ||
          _calories == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final updateRequest = UpdateActivityRequestModel(
          type: _selectedType!,
          durationMin: _durationMin!,
          intensity: _intensity!.toLowerCase(),
          calories: _calories!,
          location: _locationController.text.isEmpty
              ? null
              : _locationController.text,
        );

        await ActivityService().updateActivity(_activity.id, updateRequest);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activity updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update activity: $e'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Activity'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Info Card
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
                                  'Editing Activity',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_isInitialized)
                              Text(
                                'Original date: ${_formatDate(_activity.timestamp)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            const SizedBox(height: 4),
                            const Text(
                              'Calories will be recalculated based on your changes',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Activity Type',
                      ),
                      items: _activityTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
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
                      initialValue: _durationMin?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        hintText: 'e.g., 30',
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
                            (intensity) => DropdownMenuItem(
                              value: intensity,
                              child: Text(intensity),
                            ),
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
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
