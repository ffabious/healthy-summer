import 'package:flutter/material.dart';
import 'package:flutter_app/services/services.dart';

class WaterReminderSettingsScreen extends StatefulWidget {
  const WaterReminderSettingsScreen({super.key});

  @override
  State<WaterReminderSettingsScreen> createState() =>
      _WaterReminderSettingsScreenState();
}

class _WaterReminderSettingsScreenState
    extends State<WaterReminderSettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  bool _remindersEnabled = true;
  int _reminderInterval = 120; // minutes
  DateTime? _lastWaterIntake;
  bool _isLoading = true;
  bool _notificationServiceWorking = false;

  final List<Map<String, dynamic>> _intervalOptions = [
    {'label': '1 hour', 'minutes': 60},
    {'label': '1.5 hours', 'minutes': 90},
    {'label': '2 hours', 'minutes': 120},
    {'label': '2.5 hours', 'minutes': 150},
    {'label': '3 hours', 'minutes': 180},
    {'label': '4 hours', 'minutes': 240},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final enabled = await _notificationService.areWaterRemindersEnabled();
      final interval = await _notificationService.getReminderInterval();
      final lastIntake = await _notificationService.getLastWaterIntakeTime();
      final serviceWorking = await _notificationService
          .isNotificationServiceWorking();

      setState(() {
        _remindersEnabled = enabled;
        _reminderInterval = interval;
        _lastWaterIntake = lastIntake;
        _notificationServiceWorking = serviceWorking;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() {
        _isLoading = false;
        _notificationServiceWorking = false;
      });
    }
  }

  Future<void> _toggleReminders(bool enabled) async {
    setState(() {
      _remindersEnabled = enabled;
    });

    try {
      await _notificationService.setWaterRemindersEnabled(enabled);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled ? 'Water reminders enabled' : 'Water reminders disabled',
            ),
            backgroundColor: enabled ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling reminders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateInterval(int minutes) async {
    setState(() {
      _reminderInterval = minutes;
    });

    try {
      await _notificationService.setReminderInterval(minutes);

      if (mounted) {
        final label = _intervalOptions.firstWhere(
          (option) => option['minutes'] == minutes,
          orElse: () => {'label': '$minutes minutes'},
        )['label'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder interval updated to $label'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating interval: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating interval: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testNotification() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sending test notification...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    }

    try {
      debugPrint('Testing notification service...');

      // First check if the notification service is working
      final isWorking = await _notificationService
          .isNotificationServiceWorking();
      debugPrint('Notification service working: $isWorking');

      if (!isWorking) {
        throw Exception('Notification service is not properly initialized');
      }

      await _notificationService.showTestNotification();
      debugPrint('Test notification sent successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Test notification sent! Check your notification panel.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Failed to send test notification:\n${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _testNotification,
            ),
          ),
        );
      }
    }
  }

  String _formatLastIntake() {
    if (_lastWaterIntake == null) {
      return 'No water intake recorded yet';
    }

    final now = DateTime.now();
    final difference = now.difference(_lastWaterIntake!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Water Reminder Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Reminder Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Reminders Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Water Reminders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get notified when it\'s time to drink water',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Reminders'),
                    subtitle: Text(
                      _remindersEnabled
                          ? 'You will receive notifications to drink water'
                          : 'No notifications will be sent',
                    ),
                    value: _remindersEnabled,
                    onChanged: _toggleReminders,
                    activeColor: Colors.blue,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Reminder Interval
          if (_remindersEnabled) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Reminder Frequency',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'How often you want to be reminded',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ...(_intervalOptions.map((option) {
                      final minutes = option['minutes'] as int;
                      final label = option['label'] as String;

                      return RadioListTile<int>(
                        title: Text(label),
                        subtitle: Text('Every $minutes minutes'),
                        value: minutes,
                        groupValue: _reminderInterval,
                        onChanged: (value) {
                          if (value != null) {
                            _updateInterval(value);
                          }
                        },
                        activeColor: Colors.orange,
                        contentPadding: EdgeInsets.zero,
                      );
                    })),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],

          // Last Water Intake
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Last Water Intake',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _formatLastIntake(),
                    style: TextStyle(
                      fontSize: 16,
                      color: _lastWaterIntake == null
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                  ),
                  if (_lastWaterIntake != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'on ${_lastWaterIntake!.day}/${_lastWaterIntake!.month}/${_lastWaterIntake!.year} at ${_lastWaterIntake!.hour.toString().padLeft(2, '0')}:${_lastWaterIntake!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notification Service Status
          Card(
            color: _notificationServiceWorking
                ? Colors.green[50]
                : Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _notificationServiceWorking
                            ? Icons.check_circle
                            : Icons.error,
                        color: _notificationServiceWorking
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notification Service Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _notificationServiceWorking
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _notificationServiceWorking
                        ? 'Notifications are working properly'
                        : 'Notification service is not available or not properly configured',
                    style: TextStyle(
                      color: _notificationServiceWorking
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                  if (!_notificationServiceWorking) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await _loadSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry Initialization'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Test Notification
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bug_report, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Test Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Make sure notifications are working properly',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _notificationServiceWorking
                          ? _testNotification
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _notificationServiceWorking
                            ? Colors.green
                            : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _notificationServiceWorking
                            ? 'Send Test Notification'
                            : 'Notification Service Unavailable',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info Card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Notifications are sent only when you haven\'t logged water intake within the set interval\n'
                    '• Adding or updating water entries will reset the reminder timer\n'
                    '• Make sure notifications are enabled in your device settings',
                    style: TextStyle(color: Colors.blue[700], height: 1.4),
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
