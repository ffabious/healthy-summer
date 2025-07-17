import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications (non-blocking)
  try {
    await NotificationService().initialize();
    debugPrint('Notifications initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize notifications: $e');
  }

  await _requestPermissions();
  runApp(ProviderScope(child: App()));
}

Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    await Permission.activityRecognition.request();
    await Permission.notification.request();
  } else if (Platform.isIOS) {
    await Permission.sensors.request();
  }
}
