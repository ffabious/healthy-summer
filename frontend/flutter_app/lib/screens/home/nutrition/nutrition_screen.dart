import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/stat_row.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final NutritionService _nutritionService = NutritionService();
  NutritionStats? _stats;
  List<PostMealResponseModel> _recentMeals = [];
  List<PostWaterIntakeResponseModel> _recentWaterEntries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Try to load meals and water entries
      GetMealsResponseModel? mealsResult;
      GetWaterEntriesResponseModel? waterResult;
      NutritionStats? statsResult;

      try {
        mealsResult = await _nutritionService.getMeals();
        debugPrint('Loaded ${mealsResult.meals.length} meals');
      } catch (e) {
        // Continue anyway, we'll show empty state
        debugPrint('Error loading meals: $e');
      }

      try {
        waterResult = await _nutritionService.getWaterEntries();
        debugPrint('Loaded ${waterResult.waterEntries.length} water entries');
      } catch (e) {
        // Continue anyway, we'll show empty state
        debugPrint('Error loading water entries: $e');
      }

      try {
        statsResult = await _nutritionService.getNutritionStats();
        debugPrint('Loaded nutrition stats');
      } catch (e) {
        // Continue anyway, we'll show empty stats
        debugPrint('Error loading stats: $e');
      }

      setState(() {
        _stats = statsResult;
        // Sort meals by timestamp and take the 3 most recent
        _recentMeals = (mealsResult?.meals ?? [])
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _recentMeals = _recentMeals.take(3).toList();
        // Sort water entries by timestamp and take the 3 most recent
        _recentWaterEntries = (waterResult?.waterEntries ?? [])
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _recentWaterEntries = _recentWaterEntries.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading nutrition data: $e'); // Debug logging
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNutritionData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNutritionData,
        child: _buildBody(),
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
              'Failed to load nutrition data',
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
              onPressed: _loadNutritionData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodaysSummary(),
          const SizedBox(height: 30),
          _buildQuickActions(),
          const SizedBox(height: 30),
          _buildRecentMeals(),
          const SizedBox(height: 30),
          _buildRecentWaterEntries(),
          const SizedBox(height: 30),
          _buildNutritionCharts(),
        ],
      ),
    );
  }

  Widget _buildTodaysSummary() {
    final today = _stats?.today;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (today != null) ...[
              AnimatedStatRow(
                label: 'Calories consumed',
                value: today.totalCalories,
                unit: 'kcal',
              ),
              AnimatedStatRow(
                label: 'Water intake',
                value: today.totalWaterL,
                unit: 'L',
              ),
              AnimatedStatRow(
                label: 'Protein intake',
                value: today.totalProtein.round(),
                unit: 'g',
              ),
              AnimatedStatRow(
                label: 'Carbohydrates',
                value: today.totalCarbs.round(),
                unit: 'g',
              ),
              AnimatedStatRow(
                label: 'Fats',
                value: today.totalFats.round(),
                unit: 'g',
              ),
              AnimatedStatRow(
                label: 'Meals logged',
                value: today.mealCount,
                unit: 'meals',
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Statistics will appear once you start logging meals',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
              title: const Text('Add Meal'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/add-meal',
                ).then((_) => _loadNutritionData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_drink, color: Colors.blue),
              title: const Text('Add Water Intake'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/add-water-intake',
                ).then((_) => _loadNutritionData());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMeals() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Recent Meals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/all-meals',
                      ).then((_) => _loadNutritionData());
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentMeals.isEmpty && !_isLoading) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No meals logged yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/add-meal',
                        ).then((_) => _loadNutritionData());
                      },
                      child: const Text('Add Your First Meal'),
                    ),
                  ],
                ),
              ),
            ] else if (_recentMeals.isNotEmpty) ...[
              ...(_recentMeals.map((meal) => _buildMealTile(meal)).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealTile(PostMealResponseModel meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: const Icon(Icons.restaurant, color: Colors.orange),
        ),
        title: Text(meal.name),
        subtitle: Text(
          '${meal.calories} kcal • P: ${meal.protein.toStringAsFixed(1)}g • C: ${meal.carbohydrates.toStringAsFixed(1)}g • F: ${meal.fats.toStringAsFixed(1)}g',
        ),
        trailing: Text(
          _formatTimeAgo(meal.timestamp),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildRecentWaterEntries() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Recent Water Entries',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/all-water-entries',
                      ).then((_) => _loadNutritionData());
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentWaterEntries.isEmpty && !_isLoading) ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.water_drop, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No water entries logged yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/add-water-intake',
                        ).then((_) => _loadNutritionData());
                      },
                      child: const Text('Add Water Entry'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ..._recentWaterEntries.map(_buildWaterEntryTile),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWaterEntryTile(PostWaterIntakeResponseModel waterEntry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: const Icon(Icons.water_drop, color: Colors.blue),
        ),
        title: Text('${waterEntry.volumeMl.toStringAsFixed(0)} ml'),
        subtitle: Text('${(waterEntry.volumeMl / 1000).toStringAsFixed(2)} L'),
        trailing: Text(
          _formatTimeAgo(waterEntry.timestamp),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildNutritionCharts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_stats != null) ...[
              _buildProgressCard('Week', _stats!.week),
              const SizedBox(height: 12),
              _buildProgressCard('Month', _stats!.month),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Weekly and monthly overview will appear once you start tracking your nutrition',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String period, NutritionPeriod data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('Calories', '${data.totalCalories}', 'kcal'),
              _buildMiniStat('Protein', '${data.totalProtein.round()}', 'g'),
              _buildMiniStat('Water', data.formattedWater, ''),
              _buildMiniStat('Meals', '${data.mealCount}', ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
