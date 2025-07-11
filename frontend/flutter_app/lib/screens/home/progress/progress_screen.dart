import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> tabs = ['Daily', 'Weekly', 'Monthly'];

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(tabs.length, (index) {
        final isActive = _currentPage == index;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tabs[index],
              style: TextStyle(
                color: isActive ? Colors.white : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Make column shrink to content height
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Use FittedBox to avoid wrapping
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressContent({
    required String type,
    required String steps,
    required String calories,
    required String activeMinutes,
    required double stepsProgress,
    required double calProgress,
    required double minProgress,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                title: 'Steps',
                value: steps,
                progress: stepsProgress,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Calories',
                value: calories,
                progress: calProgress,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Active Min',
                value: activeMinutes,
                progress: minProgress,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: StepChart(),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              title: Text('$type Goal'),
              subtitle: const LinearProgressIndicator(
                value: 0.7,
                color: Colors.blue,
              ),
              trailing: const Text('7,000 / 10,000'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildTabBar(),
          const SizedBox(height: 12),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildProgressContent(
                  type: 'Daily',
                  steps: '8,520',
                  calories: '470 kcal',
                  activeMinutes: '45',
                  stepsProgress: 0.85,
                  calProgress: 0.47,
                  minProgress: 0.75,
                ),
                _buildProgressContent(
                  type: 'Weekly',
                  steps: '53,300',
                  calories: '3,200 kcal',
                  activeMinutes: '280',
                  stepsProgress: 0.76,
                  calProgress: 0.64,
                  minProgress: 0.80,
                ),
                _buildProgressContent(
                  type: 'Monthly',
                  steps: '210,000',
                  calories: '12,000 kcal',
                  activeMinutes: '1,150',
                  stepsProgress: 0.67,
                  calProgress: 0.60,
                  minProgress: 0.72,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StepChart extends StatelessWidget {
  const StepChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 4,
          minY: 0,
          maxY: 10000,

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: const Text('Steps'),
              axisNameSize: 28,
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              axisNameWidget: const Text('Time'),
              axisNameSize: 28,
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('12am');
                    case 1:
                      return const Text('6am');
                    case 2:
                      return const Text('12pm');
                    case 3:
                      return const Text('6pm');
                    case 4:
                      return const Text('12am');
                    default:
                      return const SizedBox.shrink();
                  }
                },
                interval: 1,
              ),
            ),
          ),

          gridData: FlGridData(show: true, horizontalInterval: 2500),
          borderData: FlBorderData(show: true),

          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 500),
                FlSpot(1, 2500),
                FlSpot(2, 6000),
                FlSpot(3, 8000),
                FlSpot(4, 10000),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
