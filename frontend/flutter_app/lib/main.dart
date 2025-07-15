import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  runApp(ProviderScope(child: App()));
}

Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    await Permission.activityRecognition.request();
  } else if (Platform.isIOS) {
    await Permission.sensors.request();
  }
}
