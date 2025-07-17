import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      await AwesomeNotifications().initialize(null, [
        NotificationChannel(
          channelKey: 'water_reminder',
          channelName: 'Water Reminder',
          channelDescription: 'Reminders to drink water',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableLights: true,
          enableVibration: true,
        ),
      ]);

      // Request notification permissions
      await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });

      _isInitialized = true;
    } on MissingPluginException catch (e) {
      debugPrint('Awesome Notifications plugin not available: $e');
      _isInitialized = false;
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      _isInitialized = false;
    }
  }

  Future<void> scheduleWaterReminders() async {
    if (!_isInitialized) {
      debugPrint('Notifications not initialized, skipping water reminders');
      return;
    }

    try {
      // Cancel existing water reminders
      await AwesomeNotifications().cancelNotificationsByChannelKey(
        'water_reminder',
      );

      // Schedule reminders every 2 hours from 8 AM to 10 PM
      final reminderTimes = [8, 10, 12, 14, 16, 18, 20, 22];

      for (int i = 0; i < reminderTimes.length; i++) {
        final hour = reminderTimes[i];

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1000 + i, // Unique ID for each reminder
            channelKey: 'water_reminder',
            title: '💧 Time to hydrate!',
            body: 'Don\'t forget to drink some water to stay healthy.',
            notificationLayout: NotificationLayout.Default,
            wakeUpScreen: true,
            category: NotificationCategory.Reminder,
          ),
          schedule: NotificationCalendar(
            hour: hour,
            minute: 0,
            second: 0,
            repeats: true, // Repeat daily
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to schedule water reminders: $e');
    }
  }

  Future<void> cancelWaterReminders() async {
    if (!_isInitialized) return;

    try {
      await AwesomeNotifications().cancelNotificationsByChannelKey(
        'water_reminder',
      );
    } catch (e) {
      debugPrint('Failed to cancel water reminders: $e');
    }
  }

  Future<void> showInstantWaterReminder() async {
    try {
      // Force request permissions first
      await AwesomeNotifications().requestPermissionToSendNotifications();

      // Simple notification without complex scheduling
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'water_reminder',
          title: '💧 Water Reminder',
          body: 'Time to drink some water!',
          notificationLayout: NotificationLayout.Default,
          displayOnBackground: true,
          displayOnForeground: true,
          wakeUpScreen: true,
        ),
      );
      debugPrint('Notification created successfully');
    } catch (e) {
      debugPrint('Failed to show notification: $e');
      rethrow;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) return false;

    try {
      return await AwesomeNotifications().isNotificationAllowed();
    } catch (e) {
      debugPrint('Failed to check notification permissions: $e');
      return false;
    }
  }

  Future<void> requestPermissions() async {
    if (!_isInitialized) return;

    try {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
    }
  }
}
