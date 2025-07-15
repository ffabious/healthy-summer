import 'package:flutter/material.dart';
import 'package:flutter_app/services/services.dart';

class WaterReminderStatusWidget extends StatefulWidget {
  const WaterReminderStatusWidget({super.key});

  @override
  State<WaterReminderStatusWidget> createState() =>
      _WaterReminderStatusWidgetState();
}

class _WaterReminderStatusWidgetState extends State<WaterReminderStatusWidget> {
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

      if (mounted) {
        setState(() {
          _remindersEnabled = enabled;
          _reminderInterval = interval;
          _lastWaterIntake = lastIntake;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading reminder status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getStatusText() {
    if (!_remindersEnabled) {
      return 'Water reminders are disabled';
    }

    if (_lastWaterIntake == null) {
      return 'Reminders active • No water logged yet';
    }

    final now = DateTime.now();
    final timeSinceLastIntake = now.difference(_lastWaterIntake!);
    final intervalDuration = Duration(minutes: _reminderInterval);

    if (timeSinceLastIntake < intervalDuration) {
      final remainingTime = intervalDuration - timeSinceLastIntake;
      final hours = remainingTime.inHours;
      final minutes = remainingTime.inMinutes % 60;

      if (hours > 0) {
        return 'Next reminder in ${hours}h ${minutes}m';
      } else {
        return 'Next reminder in ${minutes}m';
      }
    } else {
      return 'Reminder overdue • Time to drink water!';
    }
  }

  Color _getStatusColor() {
    if (!_remindersEnabled) {
      return Colors.grey;
    }

    if (_lastWaterIntake == null) {
      return Colors.blue;
    }

    final now = DateTime.now();
    final timeSinceLastIntake = now.difference(_lastWaterIntake!);
    final intervalDuration = Duration(minutes: _reminderInterval);

    if (timeSinceLastIntake < intervalDuration) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    if (!_remindersEnabled) {
      return Icons.notifications_off;
    }

    if (_lastWaterIntake == null) {
      return Icons.notifications_active;
    }

    final now = DateTime.now();
    final timeSinceLastIntake = now.difference(_lastWaterIntake!);
    final intervalDuration = Duration(minutes: _reminderInterval);

    if (timeSinceLastIntake < intervalDuration) {
      return Icons.notifications_active;
    } else {
      return Icons.notification_important;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading reminder status...'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_remindersEnabled && _lastWaterIntake != null) ...[
              const SizedBox(width: 8),
              Text(
                '${(_reminderInterval / 60).toStringAsFixed(_reminderInterval % 60 == 0 ? 0 : 1)}h interval',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
