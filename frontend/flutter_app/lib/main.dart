import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  await _initializeServices();
  runApp(ProviderScope(child: App()));
}

Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    await Permission.activityRecognition.request();
  } else if (Platform.isIOS) {
    await Permission.sensors.request();
  }
}

Future<void> _initializeServices() async {
  try {
    await NotificationService().initialize();
    debugPrint('✅ All services initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing services: $e');
  }
}
