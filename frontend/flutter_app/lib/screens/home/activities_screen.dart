import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/widgets/widgets.dart';

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
              child: ListView.builder(
                itemCount: 3, // replace with your activity list length
                itemBuilder: (context, index) {
                  // Replace this with your actual ActivityModel
                  final activity = {
                    'type': 'Running',
                    'duration': '30 min',
                    'calories': '300 kcal',
                  };

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.directions_run),
                      title: Text(activity['type']!),
                      subtitle: Text(
                        '${activity['duration']} • ${activity['calories']}',
                      ),
                    ),
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
}
