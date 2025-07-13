import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/stat_row.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AnimatedStatRow(
              label: 'Calories consumed',
              value: 1850,
              unit: 'kcal',
            ),
            AnimatedStatRow(label: 'Water intake', value: 1.50, unit: 'L'),
            AnimatedStatRow(label: 'Protein intake', value: 75, unit: 'g'),
            const SizedBox(height: 30),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
              title: const Text('Add Meal'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/add-meal');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_drink, color: Colors.blue),
              title: const Text('Add Water Intake'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/add-water-intake');
              },
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Center(
                child: Text(
                  'Weekly nutrition summary and charts will appear here.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
