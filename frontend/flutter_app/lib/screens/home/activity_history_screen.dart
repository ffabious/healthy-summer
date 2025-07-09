import 'package:flutter/material.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with your actual activity data source
    final activities = [
      {
        'type': 'Running',
        'date': '2025-07-08',
        'duration': '30 min',
        'calories': '300 kcal',
      },
      {
        'type': 'Cycling',
        'date': '2025-07-07',
        'duration': '45 min',
        'calories': '420 kcal',
      },
      {
        'type': 'Swimming',
        'date': '2025-07-06',
        'duration': '20 min',
        'calories': '220 kcal',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(activity['type']!),
              subtitle: Text(
                '${activity['date']} • ${activity['duration']} • ${activity['calories']}',
              ),
            ),
          );
        },
      ),
    );
  }
}
