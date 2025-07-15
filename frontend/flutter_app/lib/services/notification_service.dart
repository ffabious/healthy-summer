import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _lastWaterIntakeKey = 'last_water_intake_time';
  static const String _notificationsEnabledKey = 'water_notifications_enabled';
  static const String _reminderIntervalKey = 'water_reminder_interval';

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _waterReminderTimer;
  bool _isInitialized = false;

  // Water reminder notification IDs
  static const int _waterReminderNotificationId = 1001;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      final bool? initialized = await _flutterLocalNotificationsPlugin
          .initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: _onNotificationTapped,
          );

      if (initialized != true) {
        debugPrint('⚠️ Failed to initialize local notifications');
        return;
      }

      // Request permissions for iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      // Request permissions for Android 13+
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        await androidImplementation?.requestNotificationsPermission();
      }

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');

      // Start water reminders if enabled
      if (await areWaterRemindersEnabled()) {
        await startWaterReminders();
      }
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');

    if (notificationResponse.id == _waterReminderNotificationId) {
      // Handle water reminder notification tap
      // You could navigate to the water intake screen here
      debugPrint('Water reminder notification tapped');
    }
  }

  // Water intake reminder methods
  Future<void> startWaterReminders() async {
    if (!_isInitialized) await initialize();

    _waterReminderTimer?.cancel();

    final intervalMinutes = await getReminderInterval();
    final isEnabled = await areWaterRemindersEnabled();

    if (!isEnabled) {
      debugPrint('Water reminders are disabled');
      return;
    }

    debugPrint(
      'Starting water reminders with $intervalMinutes minute interval',
    );

    _waterReminderTimer = Timer.periodic(Duration(minutes: intervalMinutes), (
      timer,
    ) async {
      await _checkAndShowWaterReminder();
    });

    // Also check immediately
    await _checkAndShowWaterReminder();
  }

  Future<void> stopWaterReminders() async {
    _waterReminderTimer?.cancel();
    if (_isInitialized) {
      try {
        await _flutterLocalNotificationsPlugin.cancel(
          _waterReminderNotificationId,
        );
        debugPrint('Water reminders stopped and notification cancelled');
      } catch (e) {
        debugPrint('Warning: Failed to cancel water reminder notification: $e');
      }
    } else {
      debugPrint(
        'Water reminders stopped (notification service not initialized)',
      );
    }
  }

  Future<void> _checkAndShowWaterReminder() async {
    try {
      final lastWaterIntakeStr = await _secureStorage.read(
        key: _lastWaterIntakeKey,
      );
      final now = DateTime.now();
      final intervalMinutes = await getReminderInterval();

      if (lastWaterIntakeStr == null) {
        // No previous water intake recorded, show reminder
        await showWaterReminderNotification();
        return;
      }

      final lastWaterIntake = DateTime.parse(lastWaterIntakeStr);
      final timeSinceLastIntake = now.difference(lastWaterIntake);

      // Show reminder if it's been longer than the interval since last water intake
      if (timeSinceLastIntake.inMinutes >= intervalMinutes) {
        await showWaterReminderNotification();
      } else {
        debugPrint(
          'Water intake within interval. Next reminder in ${intervalMinutes - timeSinceLastIntake.inMinutes} minutes',
        );
      }
    } catch (e) {
      debugPrint('Error checking water reminder: $e');
    }
  }

  Future<void> showWaterReminderNotification() async {
    final motivationalMessages = [
      '💧 Time to hydrate! Your body needs water.',
      '🚰 Don\'t forget to drink water - stay healthy!',
      '💦 Hydration reminder: Drink some water now!',
      '🌊 Your daily water intake is calling!',
      '💧 Keep yourself hydrated! Time for some water.',
      '🚿 Water break time! Your body will thank you.',
      '💦 Stay refreshed - have a glass of water!',
      '🌊 Hydration is key to feeling great!',
    ];

    final random = Random();
    final message =
        motivationalMessages[random.nextInt(motivationalMessages.length)];

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'water_reminders',
          'Water Intake Reminders',
          channelDescription: 'Notifications to remind you to drink water',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      _waterReminderNotificationId,
      'Water Reminder',
      message,
      platformChannelSpecifics,
      payload: 'water_reminder',
    );

    debugPrint('Water reminder notification shown: $message');
  }

  // Called when user logs water intake
  Future<void> recordWaterIntake() async {
    try {
      final now = DateTime.now();
      await _secureStorage.write(
        key: _lastWaterIntakeKey,
        value: now.toIso8601String(),
      );
      debugPrint('Water intake recorded at: ${now.toIso8601String()}');

      // Only try to cancel notification if the service is initialized and available
      if (_isInitialized) {
        try {
          // Check if the plugin is actually available before calling cancel
          final pendingNotifications = await _flutterLocalNotificationsPlugin
              .pendingNotificationRequests();
          if (pendingNotifications.any(
            (notification) => notification.id == _waterReminderNotificationId,
          )) {
            await _flutterLocalNotificationsPlugin.cancel(
              _waterReminderNotificationId,
            );
            debugPrint('Cancelled water reminder notification');
          }
        } catch (e) {
          debugPrint(
            'Warning: Failed to cancel notification (plugin may not be available): $e',
          );
          // Don't throw, this is not critical - water intake recording should still work
        }
      }
    } catch (e) {
      debugPrint('Error recording water intake: $e');
      // Still try to record the time even if notification operations fail
      try {
        final now = DateTime.now();
        await _secureStorage.write(
          key: _lastWaterIntakeKey,
          value: now.toIso8601String(),
        );
      } catch (storageError) {
        debugPrint(
          'Critical error: Failed to save water intake time: $storageError',
        );
        rethrow;
      }
    }
  }

  // Settings methods
  Future<bool> areWaterRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ??
        true; // Default to enabled
  }

  Future<void> setWaterRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (enabled) {
      await startWaterReminders();
    } else {
      await stopWaterReminders();
    }
  }

  Future<int> getReminderInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reminderIntervalKey) ??
        120; // Default to 2 hours (120 minutes)
  }

  Future<void> setReminderInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderIntervalKey, minutes);

    // Restart reminders with new interval if they're enabled
    if (await areWaterRemindersEnabled()) {
      await startWaterReminders();
    }
  }

  // Get the last water intake time for display purposes
  Future<DateTime?> getLastWaterIntakeTime() async {
    final lastWaterIntakeStr = await _secureStorage.read(
      key: _lastWaterIntakeKey,
    );
    if (lastWaterIntakeStr == null) return null;

    try {
      return DateTime.parse(lastWaterIntakeStr);
    } catch (e) {
      debugPrint('Error parsing last water intake time: $e');
      return null;
    }
  }

  // Test notification method
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      debugPrint('Initializing NotificationService for test notification...');
      await initialize();
    }

    if (!_isInitialized) {
      throw Exception('Failed to initialize notification service');
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'test_notifications',
            'Test Notifications',
            channelDescription: 'Test notifications for debugging',
            importance: Importance.high,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        999,
        'Test Notification',
        'This is a test notification to verify the setup works!',
        platformChannelSpecifics,
      );

      debugPrint('✅ Test notification sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending test notification: $e');
      rethrow;
    }
  }

  void dispose() {
    _waterReminderTimer?.cancel();
  }

  // Method to check if notifications are properly working
  Future<bool> isNotificationServiceWorking() async {
    if (!_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        debugPrint('Failed to initialize notification service: $e');
        return false;
      }
    }

    try {
      // Check Android notification permissions
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidImplementation != null) {
          final bool? permissionGranted = await androidImplementation
              .areNotificationsEnabled();
          debugPrint('Android notifications enabled: $permissionGranted');

          if (permissionGranted == false) {
            debugPrint('Android notification permissions not granted');
            return false;
          }
        }
      }

      // Try to get pending notifications to verify the plugin is working
      await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      debugPrint('Notification service working properly');
      return true;
    } catch (e) {
      debugPrint('Notification service not working properly: $e');
      return false;
    }
  }
}
