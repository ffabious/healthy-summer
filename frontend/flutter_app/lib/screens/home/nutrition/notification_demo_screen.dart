import 'package:flutter/material.dart';
import 'package:flutter_app/services/services.dart';

class NotificationDemoScreen extends StatefulWidget {
  const NotificationDemoScreen({super.key});

  @override
  State<NotificationDemoScreen> createState() => _NotificationDemoScreenState();
}

class _NotificationDemoScreenState extends State<NotificationDemoScreen> {
  final NotificationService _notificationService = NotificationService();

  bool _remindersEnabled = false;
  int _reminderInterval = 120;
  DateTime? _lastWaterIntake;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final enabled = await _notificationService.areWaterRemindersEnabled();
      final interval = await _notificationService.getReminderInterval();
      final lastIntake = await _notificationService.getLastWaterIntakeTime();

      setState(() {
        _remindersEnabled = enabled;
        _reminderInterval = interval;
        _lastWaterIntake = lastIntake;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testNotification() async {
    try {
      await _notificationService.showTestNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Test notification sent! Check your notification panel.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _testWaterReminder() async {
    try {
      await _notificationService.showWaterReminderNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Water reminder notification sent!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _recordWaterIntake() async {
    try {
      await _notificationService.recordWaterIntake();
      await _loadStatus(); // Reload status

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Water intake recorded! Timer reset.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _startReminders() async {
    try {
      await _notificationService.setWaterRemindersEnabled(true);
      await _loadStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Water reminders started!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _stopReminders() async {
    try {
      await _notificationService.setWaterRemindersEnabled(false);
      await _loadStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Water reminders stopped!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatLastIntake() {
    if (_lastWaterIntake == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(_lastWaterIntake!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification Demo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _remindersEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: _remindersEnabled ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reminders: ${_remindersEnabled ? "ON" : "OFF"}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _remindersEnabled
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Interval: ${(_reminderInterval / 60).toStringAsFixed(1)} hours',
                    ),
                    const SizedBox(height: 8),
                    Text('Last water intake: ${_formatLastIntake()}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Test Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _testNotification,
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Send Test Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: _testWaterReminder,
                      icon: const Icon(Icons.water_drop),
                      label: const Text('Send Water Reminder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: _recordWaterIntake,
                      icon: const Icon(Icons.check),
                      label: const Text('Record Water Intake'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Control Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Controls',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    if (!_remindersEnabled) ...[
                      ElevatedButton.icon(
                        onPressed: _startReminders,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Water Reminders'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: _stopReminders,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Water Reminders'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: _loadStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Info
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to test:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Enable reminders\n'
                      '2. Test notifications to ensure they work\n'
                      '3. Record water intake to reset timer\n'
                      '4. Wait for automatic reminders (or test manually)',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
