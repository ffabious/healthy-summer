import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/services/activity_service.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pedometer_2/pedometer_2.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  Timer? _stepTimer;
  Timer? _midnightTimer;
  int _currentSteps = 0;
  bool _isLoadingSteps = true;

  // Activities state
  List<dynamic> _recentActivities = [];
  bool _isLoadingActivities = true;
  bool _hasActivitiesError = false;

  // Daily step submission
  static const String _lastSubmissionDateKey = 'last_step_submission_date';
  static const _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 ActivitiesScreen initializing...');
    _fetchSteps();
    _startStepTimer();
    _fetchRecentActivities();
    debugPrint('🔍 Checking for previous day step submission...');
    _checkAndSubmitPreviousDaySteps();
    _setupMidnightTimer();
    debugPrint('✅ ActivitiesScreen initialization complete');
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _midnightTimer?.cancel();
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

  void _setupMidnightTimer() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    _midnightTimer = Timer(timeUntilMidnight, () {
      _submitPreviousDaySteps();
      _setupMidnightTimer(); // Setup for next day
    });
  }

  Future<void> _checkAndSubmitPreviousDaySteps() async {
    try {
      final lastSubmissionDateStr = await _secureStorage.read(
        key: _lastSubmissionDateKey,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (lastSubmissionDateStr == null) {
        // First time opening the app or after reset - submit yesterday's steps
        debugPrint(
          '🔄 No previous submission found. Submitting yesterday\'s steps...',
        );
        await _submitPreviousDaySteps();
        return;
      }

      final lastSubmissionDate = DateTime.parse(lastSubmissionDateStr);
      final lastSubmissionDay = DateTime(
        lastSubmissionDate.year,
        lastSubmissionDate.month,
        lastSubmissionDate.day,
      );

      // Check if we missed any days
      if (today.isAfter(lastSubmissionDay)) {
        debugPrint(
          '🔄 Missed day(s) detected. Last submission: ${lastSubmissionDay.day}/${lastSubmissionDay.month}/${lastSubmissionDay.year}',
        );
        await _submitPreviousDaySteps();
      } else {
        debugPrint('✅ Already submitted steps for previous day.');
      }
    } catch (e) {
      debugPrint('Error checking previous day steps: $e');
    }
  }

  Future<void> _submitPreviousDaySteps() async {
    try {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final startOfYesterday = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );
      final endOfYesterday = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        23,
        59,
        59,
      );

      debugPrint('📤 Auto-submitting previous day steps...');
      debugPrint(
        '  Date: ${yesterday.day}/${yesterday.month}/${yesterday.year}',
      );
      debugPrint('  Start time: ${startOfYesterday.toIso8601String()}');
      debugPrint('  End time: ${endOfYesterday.toIso8601String()}');

      // Get step count for previous day
      final yesterdaySteps = await Pedometer().getStepCount(
        from: startOfYesterday,
        to: endOfYesterday,
      );

      debugPrint('  Steps count: $yesterdaySteps');

      // Create step entry for previous day
      final stepEntry = PostStepEntryRequestModel(
        steps: yesterdaySteps,
        date: endOfYesterday,
      );

      debugPrint('  Submitting to API...');
      debugPrint('  Request JSON: ${stepEntry.toJson()}');

      // Submit to API
      final response = await ActivityService().createStepEntry(stepEntry);

      debugPrint('  ✅ Success! Response ID: ${response.id}');
      debugPrint('  Response data: ${response.toJson()}');

      // Update last submission date
      final today = DateTime(now.year, now.month, now.day);
      await _secureStorage.write(
        key: _lastSubmissionDateKey,
        value: today.toIso8601String(),
      );

      debugPrint(
        '  Updated last submission date to: ${today.toIso8601String()}',
      );
      debugPrint(
        'Successfully submitted $yesterdaySteps steps for ${yesterday.day}/${yesterday.month}/${yesterday.year}',
      );
    } catch (e) {
      debugPrint('❌ Error submitting previous day steps: $e');
      debugPrint('❌ Error details: ${e.toString()}');
      // Don't update last submission date if failed, so we can retry later
    }
  }

  Future<void> _testSubmitSteps() async {
    debugPrint('=== TESTING STEP SUBMISSION ===');

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get today's step count for testing
      debugPrint('Fetching today\'s step count...');
      final todaySteps = await Pedometer().getStepCount(
        from: today,
        to: now, // Up to current time
      );
      debugPrint('Today\'s steps so far: $todaySteps');

      // Create test step entry with today's data
      final stepEntry = PostStepEntryRequestModel(
        steps: todaySteps,
        date: now, // Current timestamp for testing
      );

      debugPrint('Preparing to submit step entry:');
      debugPrint('  Steps: $todaySteps');
      debugPrint('  Date: ${stepEntry.date.toIso8601String()}');
      debugPrint('  JSON: ${stepEntry.toJson()}');

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Testing step submission...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Submit to API
      debugPrint('Calling ActivityService.createStepEntry()...');
      final response = await ActivityService().createStepEntry(stepEntry);

      debugPrint('✅ SUCCESS! Step submission response:');
      debugPrint('  Response ID: ${response.id}');
      debugPrint('  User ID: ${response.userId}');
      debugPrint('  Steps: ${response.steps}');
      debugPrint('  Date: ${response.date}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Success! Submitted $todaySteps steps'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ERROR during step submission:');
      debugPrint('  Error type: ${e.runtimeType}');
      debugPrint('  Error message: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }

    debugPrint('=== END TEST ===');
  }

  Future<void> _resetSubmissionDate() async {
    try {
      // Check if there was a previous submission date
      final existingDate = await _secureStorage.read(
        key: _lastSubmissionDateKey,
      );

      await _secureStorage.delete(key: _lastSubmissionDateKey);

      debugPrint('🔄 Submission date reset!');
      debugPrint('  Previous date: ${existingDate ?? "None"}');
      debugPrint('  Next app restart will trigger step submission.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existingDate != null
                  ? '🔄 Reset complete! Had: ${DateTime.parse(existingDate).day}/${DateTime.parse(existingDate).month}. Restart to test.'
                  : '🔄 Reset complete! No previous date found. Restart to test.',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error resetting submission date: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
            // Debug buttons row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text('Test Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _testSubmitSteps,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Timer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _resetSubmissionDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
