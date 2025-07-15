import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/services/activity_service.dart';
import 'package:flutter_app/models/models.dart';
import 'package:pedometer_2/pedometer_2.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  Timer? _stepTimer;
  int _currentSteps = 0;
  bool _isLoadingSteps = true;

  // Activities state
  List<dynamic> _recentActivities = [];
  bool _isLoadingActivities = true;
  bool _hasActivitiesError = false;

  @override
  void initState() {
    super.initState();
    _fetchSteps();
    _startStepTimer();
    _fetchRecentActivities();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  void _startStepTimer() {
    _stepTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchSteps();
    });
  }

  Future<void> _fetchSteps() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    try {
      final steps = await Pedometer().getStepCount(
        from: startOfDay,
        to: endOfDay,
      );
      if (mounted) {
        setState(() {
          _currentSteps = steps;
          _isLoadingSteps = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching steps: $e');
      if (mounted) {
        setState(() {
          _currentSteps = 0;
          _isLoadingSteps = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activities'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Steps Summary
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: _isLoadingSteps
                    ? const CircularProgressIndicator()
                    : AnimatedStepCounterArc(steps: _currentSteps, goal: 10000),
              ),
            ),
            const SizedBox(height: 24),
            // Add Activity Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Activity'),
                onPressed: () {
                  Navigator.pushNamed(context, '/add-activity');
                },
              ),
            ),
            const SizedBox(height: 16),
            // Recent Activities
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildActivitiesList()),
            // View All Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/activity-history');
                },
                child: const Text('View All'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchRecentActivities() async {
    try {
      setState(() {
        _isLoadingActivities = true;
        _hasActivitiesError = false;
      });

      // Fetch activities from your endpoint
      final response = await ActivityService().getActivities();

      // Parse the response using the model
      final activitiesResponse = GetActivitiesResponseModel.fromJson(
        response.toJson(),
      );
      final activities = activitiesResponse.getRecentActivities();

      if (mounted) {
        setState(() {
          _recentActivities = activities;
          _isLoadingActivities = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load activities: $e');
      if (mounted) {
        setState(() {
          _hasActivitiesError = true;
          _isLoadingActivities = false;
        });
      }
    }
  }

  Widget _buildActivitiesList() {
    if (_isLoadingActivities) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasActivitiesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Error loading activities',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _fetchRecentActivities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_recentActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No activities yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first activity to get started!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _recentActivities.length,
      itemBuilder: (context, index) {
        final activity = _recentActivities[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: _getActivityIcon(activity.type),
            title: Text(activity.type),
            subtitle: Text(
              '${activity.durationMin} min • ${activity.calories} kcal',
            ),
            trailing: _getIntensityIndicator(activity.intensity),
          ),
        );
      },
    );
  }

  Widget _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return const Icon(Icons.directions_run);
      case 'walking':
        return const Icon(Icons.directions_walk);
      case 'cycling':
        return const Icon(Icons.directions_bike);
      case 'swimming':
        return const Icon(Icons.pool);
      case 'gym':
      case 'workout':
        return const Icon(Icons.fitness_center);
      case 'yoga':
        return const Icon(Icons.self_improvement);
      default:
        return const Icon(Icons.directions_run);
    }
  }

  Widget _getIntensityIndicator(String intensity) {
    Color color;
    switch (intensity.toLowerCase()) {
      case 'low':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'high':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
