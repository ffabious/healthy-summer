import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/services/activity_service.dart';
import 'package:flutter_app/models/models.dart';

class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                child: AnimatedStepCounterArc(steps: 6900, goal: 10000),
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
            Expanded(
              child: FutureBuilder<GetActivitiesResponseModel>(
                future: _fetchRecentActivities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading activities',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // Trigger rebuild to retry
                              (context as Element).markNeedsBuild();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final response = snapshot.data;
                  final recentActivities =
                      response?.getRecentActivities() ?? [];

                  if (recentActivities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No activities yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first activity to get started!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: recentActivities.length,
                    itemBuilder: (context, index) {
                      final activity = recentActivities[index];
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
                },
              ),
            ),
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

  Future<GetActivitiesResponseModel> _fetchRecentActivities() async {
    try {
      // Fetch activities from your endpoint
      final response = await ActivityService().getActivities(
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      );

      // Parse the response using the model
      return GetActivitiesResponseModel.fromJson(response.toJson());
    } catch (e) {
      // Re-throw the error to be handled by FutureBuilder
      throw Exception('Failed to load activities: $e');
    }
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
