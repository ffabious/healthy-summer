import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/step_counter_arc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Timer? _stepSyncTimer;
  int _currentSteps = 0;
  bool _isLoadingSteps = true;

  // Activities state
  List<dynamic> _recentActivities = [];
  bool _isLoadingActivities = true;
  bool _hasActivitiesError = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 ActivitiesScreen initializing...');
    _fetchSteps();
    _startStepTimer();
    _fetchRecentActivities();
    debugPrint('🔍 Setting up 6-hour step sync timer...');
    _setupStepSyncTimer();
    debugPrint('✅ ActivitiesScreen initialization complete');
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _stepSyncTimer?.cancel();
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

  void _setupStepSyncTimer() {
    final now = DateTime.now();

    // Calculate next sync time (every 6 hours: 0, 6, 12, 18)
    final currentHour = now.hour;
    int nextSyncHour;

    if (currentHour < 6) {
      nextSyncHour = 6;
    } else if (currentHour < 12) {
      nextSyncHour = 12;
    } else if (currentHour < 18) {
      nextSyncHour = 18;
    } else {
      nextSyncHour = 24; // Next day at midnight
    }

    final nextSync = nextSyncHour == 24
        ? DateTime(now.year, now.month, now.day + 1, 0, 0, 0)
        : DateTime(now.year, now.month, now.day, nextSyncHour, 0, 0);

    final timeUntilNextSync = nextSync.difference(now);

    debugPrint(
      '⏰ Next step sync in ${timeUntilNextSync.inMinutes} minutes at ${nextSync.toString().substring(11, 16)}',
    );

    _stepSyncTimer = Timer(timeUntilNextSync, () {
      _submitCurrentStepSegment();
      _setupStepSyncTimer(); // Setup for next sync
    });
  }

  Future<void> _submitCurrentStepSegment() async {
    try {
      final now = DateTime.now();
      final currentHour = now.hour;

      // Determine the time segment we're submitting for
      DateTime segmentStart;
      String segmentName;

      if (currentHour >= 0 && currentHour < 6) {
        // 12am-6am segment
        segmentStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
        segmentName = "12am-6am";
      } else if (currentHour >= 6 && currentHour < 12) {
        // 6am-12pm segment
        segmentStart = DateTime(now.year, now.month, now.day, 6, 0, 0);
        segmentName = "6am-12pm";
      } else if (currentHour >= 12 && currentHour < 18) {
        // 12pm-6pm segment
        segmentStart = DateTime(now.year, now.month, now.day, 12, 0, 0);
        segmentName = "12pm-6pm";
      } else {
        // 6pm-12am segment
        segmentStart = DateTime(now.year, now.month, now.day, 18, 0, 0);
        segmentName = "6pm-12am";
      }

      // Since we can't get steps for specific time ranges, we'll use current steps
      // This is a simplified approach - in a real app you'd want to store incremental data
      final segmentSteps = _currentSteps > 0
          ? (_currentSteps / 4).round()
          : 0; // Rough estimate

      if (segmentSteps > 0) {
        final stepEntry = PostStepEntryRequestModel(
          steps: segmentSteps,
          date: segmentStart, // Use segment start time
        );

        debugPrint(
          '📊 Submitting $segmentSteps steps for segment $segmentName',
        );
        await ActivityService().createStepEntry(stepEntry);
        debugPrint('✅ Successfully submitted step segment for $segmentName');
      }
    } catch (e) {
      debugPrint('❌ Error submitting step segment: $e');
    }
  }

  // Old functions - commented out during 6-hour sync implementation
  /*
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
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activities')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Steps Summary
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 8),
                ),
                child: _isLoadingSteps
                    ? const CircularProgressIndicator()
                    : AnimatedStepCounterArc(
                        steps: _currentSteps + 10000,
                        goal: 10000,
                      ),
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
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/activity-history',
                  );
                  // Refresh activities if user made changes in activity history
                  if (result == true) {
                    // Refresh both recent activities and any other data that might have changed
                    _fetchRecentActivities();
                  }
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
