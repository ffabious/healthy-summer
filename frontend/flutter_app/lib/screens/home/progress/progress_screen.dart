import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/services/activity_service.dart';
import 'package:flutter_app/models/activity_model.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final ActivityService _activityService = ActivityService();

  ActivityStatsModel? _activityStats;
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> tabs = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _fetchActivityStats();
  }

  Future<void> _fetchActivityStats() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final stats = await _activityService.getActivityStats();

      if (mounted) {
        setState(() {
          _activityStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load progress data: ${e.toString()}';
        });
      }
    }
  }

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
    required ActivityPeriodModel data,
  }) {
    // Calculate progress as percentage based on average daily achievement
    final stepsGoal = 10000;
    final caloriesGoal = 1000;
    final activeMinGoal = 60;

    // Determine the number of days for averaging
    int days;
    switch (type) {
      case 'Daily':
        days = 1;
        break;
      case 'Weekly':
        days = 7;
        break;
      case 'Monthly':
        days = 30; // Approximate
        break;
      default:
        days = 1;
    }

    // Calculate average daily values
    final avgDailySteps = data.steps / days;
    final avgDailyCalories = data.calories / days;
    final avgDailyMinutes = data.durationMin / days;

    // Calculate progress based on average daily achievement
    final stepsProgress = (avgDailySteps / stepsGoal).clamp(0.0, 1.0);
    final calProgress = (avgDailyCalories / caloriesGoal).clamp(0.0, 1.0);
    final minProgress = (avgDailyMinutes / activeMinGoal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                title: 'Steps',
                value: '${data.steps}',
                progress: stepsProgress,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Calories',
                value: '${data.calories} kcal',
                progress: calProgress,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                title: 'Active Min',
                value: '${data.durationMin}',
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
            child: StepChart(initialPeriod: tabs[_currentPage]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchActivityStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading progress',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchActivityStats,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _activityStats == null
          ? const Center(child: Text('No data available'))
          : Column(
              children: [
                const SizedBox(height: 12),
                _buildTabBar(),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    children: [
                      _buildProgressContent(
                        type: 'Daily',
                        data: _activityStats!.today,
                      ),
                      _buildProgressContent(
                        type: 'Weekly',
                        data: _activityStats!.week,
                      ),
                      _buildProgressContent(
                        type: 'Monthly',
                        data: _activityStats!.month,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class StepChart extends StatefulWidget {
  final String? initialPeriod;

  const StepChart({super.key, this.initialPeriod});

  @override
  State<StepChart> createState() => _StepChartState();
}

class _StepChartState extends State<StepChart> {
  final ActivityService _activityService = ActivityService();
  List<StepEntryModel> _stepEntries = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPeriod = 'Daily'; // Daily, Weekly, Monthly

  @override
  void initState() {
    super.initState();
    _fetchStepEntries();
  }

  Future<void> _fetchStepEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch step entries for the last 30 days to have enough data for all chart types
      final stepEntries = await _activityService.getStepEntries(days: 30);

      if (mounted) {
        setState(() {
          _stepEntries = stepEntries;
          _selectedPeriod =
              widget.initialPeriod ?? _determineOptimalChartPeriod();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load step data: ${e.toString()}';
        });
      }
    }
  }

  String _determineOptimalChartPeriod() {
    if (_stepEntries.isEmpty) return 'Daily';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Count entries from different time periods
    final todayEntries = _stepEntries.where((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }).length;

    final thisWeekEntries = _stepEntries.where((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      return entryDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          entryDate.isBefore(today.add(const Duration(days: 1)));
    }).length;

    final thisMonthEntries = _stepEntries.where((entry) {
      return entry.date.year == now.year && entry.date.month == now.month;
    }).length;

    // Auto-select based on data availability and time of day
    final currentHour = now.hour;

    // If it's early in the day (before 10 AM) and we have recent data, show daily
    if (currentHour < 10 && todayEntries > 0) {
      return 'Daily';
    }

    // If we have good data for today (4+ entries = at least one per 6-hour segment), show daily
    if (todayEntries >= 4) {
      return 'Daily';
    }

    // If we have good weekly data (7+ entries), show weekly
    if (thisWeekEntries >= 7) {
      return 'Weekly';
    }

    // If we have monthly data, show monthly
    if (thisMonthEntries >= 4) {
      return 'Monthly';
    }

    // Default to daily if we have any data, otherwise weekly for empty state
    return todayEntries > 0 ? 'Daily' : 'Weekly';
  }

  List<FlSpot> _getChartData() {
    if (_stepEntries.isEmpty) return [];

    switch (_selectedPeriod) {
      case 'Daily':
        return _getDailyChartData();
      case 'Weekly':
        return _getWeeklyChartData();
      case 'Monthly':
        return _getMonthlyChartData();
      default:
        return _getDailyChartData();
    }
  }

  List<FlSpot> _getDailyChartData() {
    // Group by 6-hour segments for today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayEntries = _stepEntries.where((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }).toList();

    // Determine how many segments to show based on current time
    final currentHour = now.hour;
    int maxSegments;
    if (currentHour < 6) {
      maxSegments = 1; // Only show 12am-6am segment
    } else if (currentHour < 12) {
      maxSegments = 2; // Show up to 6am-12pm segment
    } else if (currentHour < 18) {
      maxSegments = 3; // Show up to 12pm-6pm segment
    } else {
      maxSegments = 4; // Show up to 6pm-12am segment
    }

    // Create spots for 6-hour segments: 0am, 6am, 12pm, 6pm, 12am
    final spots = <FlSpot>[];
    int cumulativeSteps = 0;

    for (int i = 0; i < maxSegments; i++) {
      final segmentHour = i * 6;

      // Find entries for this time segment
      final segmentEntries = todayEntries.where((entry) {
        final hour = entry.date.hour;
        if (i == 4) {
          // Last segment: 18:00-23:59 (6pm to 11:59pm)
          return hour >= 18 && hour <= 23;
        } else {
          // Regular segments: 0-5, 6-11, 12-17
          return hour >= segmentHour && hour < segmentHour + 6;
        }
      }).toList();

      // Add steps from this segment
      final segmentSteps = segmentEntries.fold(
        0,
        (sum, entry) => sum + entry.steps,
      );
      cumulativeSteps += segmentSteps;

      spots.add(FlSpot(i.toDouble(), cumulativeSteps.toDouble()));
    }

    return spots.isNotEmpty ? spots : [FlSpot(0, 0)];
  }

  List<FlSpot> _getWeeklyChartData() {
    // Show 6-hour segments (12am, 6am, 12pm, 6pm, 12am) with averages across the week
    final now = DateTime.now();
    final spots = <FlSpot>[];

    // Calculate the last 7 days
    final weekDays = List.generate(
      7,
      (i) => now.subtract(Duration(days: 6 - i)),
    );

    // For each 6-hour segment, calculate average across the week
    for (int segmentIndex = 0; segmentIndex < 5; segmentIndex++) {
      final segmentHour = segmentIndex * 6;
      double totalStepsForSegment = 0;
      int daysWithData = 0;

      // Check each day of the week for this time segment
      for (final day in weekDays) {
        final dayStart = DateTime(day.year, day.month, day.day);

        // Find entries for this day and this time segment
        final segmentEntries = _stepEntries.where((entry) {
          final entryDate = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
          );
          final hour = entry.date.hour;

          bool isCorrectDay = entryDate.isAtSameMomentAs(dayStart);
          bool isCorrectTimeSegment;

          if (segmentIndex == 4) {
            // Last segment: 18:00-23:59 (6pm to 11:59pm)
            isCorrectTimeSegment = hour >= 18 && hour <= 23;
          } else {
            // Regular segments: 0-5, 6-11, 12-17
            isCorrectTimeSegment =
                hour >= segmentHour && hour < segmentHour + 6;
          }

          return isCorrectDay && isCorrectTimeSegment;
        }).toList();

        if (segmentEntries.isNotEmpty) {
          final daySegmentSteps = segmentEntries.fold(
            0,
            (sum, entry) => sum + entry.steps,
          );
          totalStepsForSegment += daySegmentSteps;
          daysWithData++;
        }
      }

      // Calculate average for this time segment across the week
      final averageSteps = daysWithData > 0
          ? totalStepsForSegment / daysWithData
          : 0;
      spots.add(FlSpot(segmentIndex.toDouble(), averageSteps.toDouble()));
    }

    return spots.isNotEmpty
        ? spots
        : List.generate(5, (i) => FlSpot(i.toDouble(), 0));
  }

  List<FlSpot> _getMonthlyChartData() {
    // Show 6-hour segments (12am, 6am, 12pm, 6pm, 12am) with averages across the month
    final now = DateTime.now();
    final spots = <FlSpot>[];

    // Calculate the last 30 days
    final monthDays = List.generate(
      30,
      (i) => now.subtract(Duration(days: 29 - i)),
    );

    // For each 6-hour segment, calculate average across the month
    for (int segmentIndex = 0; segmentIndex < 5; segmentIndex++) {
      final segmentHour = segmentIndex * 6;
      double totalStepsForSegment = 0;
      int daysWithData = 0;

      // Check each day of the month for this time segment
      for (final day in monthDays) {
        final dayStart = DateTime(day.year, day.month, day.day);

        // Find entries for this day and this time segment
        final segmentEntries = _stepEntries.where((entry) {
          final entryDate = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
          );
          final hour = entry.date.hour;

          bool isCorrectDay = entryDate.isAtSameMomentAs(dayStart);
          bool isCorrectTimeSegment;

          if (segmentIndex == 4) {
            // Last segment: 18:00-23:59 (6pm to 11:59pm)
            isCorrectTimeSegment = hour >= 18 && hour <= 23;
          } else {
            // Regular segments: 0-5, 6-11, 12-17
            isCorrectTimeSegment =
                hour >= segmentHour && hour < segmentHour + 6;
          }

          return isCorrectDay && isCorrectTimeSegment;
        }).toList();

        if (segmentEntries.isNotEmpty) {
          final daySegmentSteps = segmentEntries.fold(
            0,
            (sum, entry) => sum + entry.steps,
          );
          totalStepsForSegment += daySegmentSteps;
          daysWithData++;
        }
      }

      // Calculate average for this time segment across the month
      final averageSteps = daysWithData > 0
          ? totalStepsForSegment / daysWithData
          : 0;
      spots.add(FlSpot(segmentIndex.toDouble(), averageSteps.toDouble()));
    }

    return spots.isNotEmpty
        ? spots
        : List.generate(5, (i) => FlSpot(i.toDouble(), 0));
  }

  String _getBottomTitle(int value) {
    // All chart types now show 6-hour segments
    switch (value) {
      case 0:
        return '12am';
      case 1:
        return '6am';
      case 2:
        return '12pm';
      case 3:
        return '6pm';
      case 4:
        return '12am';
      default:
        return '';
    }
  }

  double _getMaxY() {
    final spots = _getChartData();
    if (spots.isEmpty) return 10000.0;
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    // Ensure maxY is never 0 and add 20% padding
    final result = maxY == 0 ? 10000.0 : (maxY * 1.2).ceilToDouble();
    return result.toDouble();
  }

  String _getChartDescription() {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'Daily':
        final todayEntries = _stepEntries.where((entry) {
          final entryDate = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
          );
          final today = DateTime(now.year, now.month, now.day);
          return entryDate.isAtSameMomentAs(today);
        }).length;

        if (todayEntries == 0) {
          return 'Today\'s step progress - updates every 6 hours';
        } else {
          return 'Today\'s cumulative steps across 6-hour intervals';
        }

      case 'Weekly':
        return 'Average steps per time period over the last 7 days';

      case 'Monthly':
        return 'Average steps per time period over the last 30 days';

      default:
        return 'Step tracking with 6-hour intervals';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector and auto-selection indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Step Chart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description with smart text
          Text(
            _getChartDescription(),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 4, // Always show all time segments (0-4)
                      minY: 0,
                      maxY: _getMaxY(),

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
                              return Text(_getBottomTitle(value.toInt()));
                            },
                            interval: 1,
                          ),
                        ),
                      ),

                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: (_getMaxY() / 4).clamp(
                          1.0,
                          double.infinity,
                        ),
                      ),
                      borderData: FlBorderData(show: true),

                      // Add horizontal line at 10k steps
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: 10000,
                            color: Colors.green,
                            strokeWidth: 2,
                            dashArray: [5, 5],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              labelResolver: (line) => '10k Goal',
                            ),
                          ),
                        ],
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          spots: _getChartData(),
                          isCurved: false,
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
          ),
        ],
      ),
    );
  }
}
