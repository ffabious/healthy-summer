// Comprehensive Flutter tests for the Healthy Summer app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_app/app.dart';
import 'package:flutter_app/widgets/input_field.dart';
import 'package:flutter_app/widgets/animated_loading_text.dart';
import 'package:flutter_app/widgets/stat_row.dart';

void main() {
  group('App Tests', () {
    testWidgets('App builds successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, equals('Healthy Summer'));
    });
  });

  group('InputField Tests', () {
    testWidgets('InputField displays label', (WidgetTester tester) async {
      const testLabel = 'Test Label';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: InputField(label: testLabel)),
        ),
      );

      expect(find.text(testLabel), findsOneWidget);
    });

    testWidgets('InputField handles text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputField(label: 'Test Input', controller: controller),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test input');
      expect(controller.text, equals('test input'));
    });

    testWidgets('InputField supports password mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputField(label: 'Password', obscureText: true),
          ),
        ),
      );

      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });
  });

  group('AnimatedLoadingText Tests', () {
    testWidgets('AnimatedLoadingText displays', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedLoadingText())),
      );

      expect(find.byType(AnimatedLoadingText), findsOneWidget);
      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('AnimatedLoadingText animates', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedLoadingText())),
      );

      // Pump several animation frames
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(AnimatedLoadingText), findsOneWidget);
    });
  });

  group('AnimatedStatRow Tests', () {
    testWidgets('AnimatedStatRow displays data', (WidgetTester tester) async {
      const testLabel = 'Steps';
      const testValue = 10000;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedStatRow(label: testLabel, value: testValue),
          ),
        ),
      );

      expect(find.text(testLabel), findsOneWidget);

      // Wait for animation to complete
      await tester.pump(const Duration(seconds: 3));

      // Check for formatted value (10,000)
      expect(find.textContaining('10,000'), findsOneWidget);
    });

    testWidgets('AnimatedStatRow displays with unit', (
      WidgetTester tester,
    ) async {
      const testLabel = 'Calories';
      const testValue = 2000;
      const testUnit = 'kcal';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedStatRow(
              label: testLabel,
              value: testValue,
              unit: testUnit,
            ),
          ),
        ),
      );

      expect(find.text(testLabel), findsOneWidget);

      // Wait for animation to complete
      await tester.pump(const Duration(seconds: 3));

      // Check for formatted value with unit
      expect(find.textContaining('2,000 kcal'), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    testWidgets('Multiple widgets work together', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                InputField(label: 'Test Input', controller: controller),
                const AnimatedLoadingText(),
                const AnimatedStatRow(label: 'Test Stat', value: 100),
              ],
            ),
          ),
        ),
      );

      // Test that all widgets render
      expect(find.byType(InputField), findsOneWidget);
      expect(find.byType(AnimatedLoadingText), findsOneWidget);
      expect(find.byType(AnimatedStatRow), findsOneWidget);

      // Test input functionality
      await tester.enterText(find.byType(TextField), 'integration test');
      expect(controller.text, equals('integration test'));

      // Test animations work
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Widgets handle edge cases', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                InputField(label: ''),
                AnimatedStatRow(label: '', value: 0),
              ],
            ),
          ),
        ),
      );

      // Should not crash with empty/zero values
      expect(find.byType(InputField), findsOneWidget);
      expect(find.byType(AnimatedStatRow), findsOneWidget);
    });
  });
}
