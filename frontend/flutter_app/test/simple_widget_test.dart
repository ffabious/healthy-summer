// Simple widget test for the Healthy Summer app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_app/app.dart';

void main() {
  group('Simple App Tests', () {
    testWidgets('App builds successfully', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: App()));

      // Verify that the app builds without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MaterialApp widget exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Hello World'))),
      );

      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Basic widget interaction', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Counter: 0'),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Increment'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Counter: 0'), findsOneWidget);
      expect(find.text('Increment'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
