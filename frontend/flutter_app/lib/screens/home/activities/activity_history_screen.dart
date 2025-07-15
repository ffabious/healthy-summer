import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/services/activity_service.dart';
import 'package:flutter_app/models/models.dart';

class ActivityHistoryScreen extends ConsumerStatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  ConsumerState<ActivityHistoryScreen> createState() =>
      _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends ConsumerState<ActivityHistoryScreen> {
  String _searchQuery = '';
  String _selectedType = 'All';
  String _selectedIntensity = 'All';
  String _sortBy = 'timestamp'; // timestamp, calories, duration
  bool _sortAscending = false;
  bool _activitiesChanged = false; // Track if any changes were made

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _activitiesChanged);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity History'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _activitiesChanged);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {}),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search activities...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Filter and Sort Row
                  Row(
                    children: [
                      // Type Filter
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedType,
                          items: [
                            'All',
                            'Running',
                            'Walking',
                            'Cycling',
                            'Swimming',
                            'Gym',
                            'Yoga',
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                          hint: 'Type',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Intensity Filter
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedIntensity,
                          items: ['All', 'Low', 'Medium', 'High'],
                          onChanged: (value) {
                            setState(() {
                              _selectedIntensity = value!;
                            });
                          },
                          hint: 'Intensity',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sort Method Dropdown
                      Expanded(
                        child: _buildDropdown(
                          value: _sortBy == 'timestamp'
                              ? 'Time'
                              : _sortBy == 'calories'
                              ? 'Calories'
                              : 'Duration',
                          items: ['Time', 'Calories', 'Duration'],
                          onChanged: (value) {
                            setState(() {
                              switch (value) {
                                case 'Time':
                                  _sortBy = 'timestamp';
                                  break;
                                case 'Calories':
                                  _sortBy = 'calories';
                                  break;
                                case 'Duration':
                                  _sortBy = 'duration';
                                  break;
                              }
                            });
                          },
                          hint: 'Sort by',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sort Direction Button
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _sortAscending = !_sortAscending;
                            });
                          },
                          tooltip: _sortAscending ? 'Ascending' : 'Descending',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Activities List
            Expanded(
              child: FutureBuilder<GetActivitiesResponseModel>(
                future: _fetchAllActivities(),
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
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading activities',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final response = snapshot.data;
                  final filteredActivities = _getFilteredAndSortedActivities(
                    response?.activities ?? [],
                  );

                  if (filteredActivities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No activities found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters or add some activities',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Results Summary and Sort Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${filteredActivities.length} activities found',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                Text(
                                  'Sorted by ${_getSortDisplayName()} ${_sortAscending ? '↑' : '↓'}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                            if (filteredActivities.isNotEmpty)
                              _buildSummaryStats(filteredActivities),
                          ],
                        ),
                      ),
                      // Activities List
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: filteredActivities.length,
                          itemBuilder: (context, index) {
                            final activity = filteredActivities[index];
                            return _buildActivityCard(activity);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ), // Close Scaffold
    ); // Close WillPopScope
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          hint: Text(hint),
        ),
      ),
    );
  }

  Widget _buildSummaryStats(List<ActivityModel> activities) {
    final totalCalories = activities.fold(
      0,
      (sum, activity) => sum + activity.calories,
    );
    final totalDuration = activities.fold(
      0,
      (sum, activity) => sum + activity.durationMin,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$totalCalories kcal',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),
        Text(
          '$totalDuration min',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getActivityIcon(activity.type),
            const SizedBox(height: 4),
            _getIntensityIndicator(activity.intensity),
          ],
        ),
        title: Text(
          activity.type,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${activity.durationMin} min • ${activity.calories} kcal',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(activity.timestamp),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            if ((activity.location ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    activity.location ?? '-',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                // Navigate to edit screen
                final result = await Navigator.pushNamed(
                  context,
                  '/edit-activity',
                  arguments: activity,
                );
                // Refresh the list if the activity was updated
                if (result == true) {
                  setState(() {
                    _activitiesChanged = true;
                  });
                }
                break;
              case 'delete':
                _showDeleteDialog(activity);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return const Icon(Icons.directions_run, color: Colors.orange);
      case 'walking':
        return const Icon(Icons.directions_walk, color: Colors.green);
      case 'cycling':
        return const Icon(Icons.directions_bike, color: Colors.blue);
      case 'swimming':
        return const Icon(Icons.pool, color: Colors.cyan);
      case 'gym':
      case 'workout':
        return const Icon(Icons.fitness_center, color: Colors.red);
      case 'yoga':
        return const Icon(Icons.self_improvement, color: Colors.purple);
      default:
        return const Icon(Icons.directions_run, color: Colors.grey);
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
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Future<GetActivitiesResponseModel> _fetchAllActivities() async {
    try {
      final response = await ActivityService().getActivities();
      return GetActivitiesResponseModel.fromJson(response.toJson());
    } catch (e) {
      throw Exception('Failed to load activities: $e');
    }
  }

  List<ActivityModel> _getFilteredAndSortedActivities(
    List<ActivityModel> activities,
  ) {
    List<ActivityModel> filtered = activities;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((activity) {
        return activity.type.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (activity.location ?? '').toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Apply type filter
    if (_selectedType != 'All') {
      filtered = filtered.where((activity) {
        return activity.type.toLowerCase() == _selectedType.toLowerCase();
      }).toList();
    }

    // Apply intensity filter
    if (_selectedIntensity != 'All') {
      filtered = filtered.where((activity) {
        return activity.intensity.toLowerCase() ==
            _selectedIntensity.toLowerCase();
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'timestamp':
          comparison = a.timestamp.compareTo(b.timestamp);
          break;
        case 'calories':
          comparison = a.calories.compareTo(b.calories);
          // Secondary sort by timestamp for activities with same calories
          if (comparison == 0) {
            comparison = a.timestamp.compareTo(b.timestamp);
          }
          break;
        case 'duration':
          comparison = a.durationMin.compareTo(b.durationMin);
          // Secondary sort by timestamp for activities with same duration
          if (comparison == 0) {
            comparison = a.timestamp.compareTo(b.timestamp);
          }
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }

  String _getSortDisplayName() {
    switch (_sortBy) {
      case 'timestamp':
        return 'Time';
      case 'calories':
        return 'Calories';
      case 'duration':
        return 'Duration';
      default:
        return 'Time';
    }
  }

  void _showDeleteDialog(ActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text(
          'Are you sure you want to delete this ${activity.type.toLowerCase()} activity? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteActivity(activity);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteActivity(ActivityModel activity) async {
    try {
      await ActivityService().deleteActivity(activity.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${activity.type} activity deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the activities list and mark that changes were made
        setState(() {
          _activitiesChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete activity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
