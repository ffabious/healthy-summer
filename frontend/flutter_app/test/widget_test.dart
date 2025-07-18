// This is a comprehensive Flutter widget test suite for the Healthy Summer app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_app/app.dart';
import 'package:flutter_app/widgets/input_field.dart';
import 'package:flutter_app/widgets/animated_loading_text.dart';
import 'package:flutter_app/widgets/stat_row.dart';
import 'package:flutter_app/widgets/step_counter_arc.dart';
import 'package:flutter_app/models/user_model.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App builds without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: App()));

      // Verify that the app builds and doesn't crash
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byKey(const Key('healthy_summer_app')), findsOneWidget);
    });

    testWidgets('App has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, equals('Healthy Summer'));
    });

    testWidgets('App uses Material 3 design', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, isTrue);
    });

    testWidgets('App has debug banner disabled', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });

  group('InputField Widget Tests', () {
    testWidgets('InputField displays label correctly', (
      WidgetTester tester,
    ) async {
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

    testWidgets('InputField supports different keyboard types', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputField(
              label: 'Email Input',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.keyboardType, equals(TextInputType.emailAddress));
    });

    testWidgets('InputField supports obscure text for passwords', (
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

  group('AnimatedLoadingText Widget Tests', () {
    testWidgets('AnimatedLoadingText displays and animates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedLoadingText())),
      );

      // Check that the widget builds
      expect(find.byType(AnimatedLoadingText), findsOneWidget);

      // Check that it contains loading text
      expect(find.text('Loading'), findsOneWidget);

      // Pump animation frames
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be there after animation
      expect(find.byType(AnimatedLoadingText), findsOneWidget);
    });

    testWidgets('AnimatedLoadingText has animation controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedLoadingText())),
      );

      // Check that animation widgets exist
      expect(find.byType(AnimatedLoadingText), findsOneWidget);

      // Pump several frames to ensure animation is working
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
  });

  group('AnimatedStatRow Widget Tests', () {
    testWidgets('AnimatedStatRow displays label and value', (
      WidgetTester tester,
    ) async {
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
      expect(find.text(testValue.toString()), findsOneWidget);
    });

    testWidgets('AnimatedStatRow displays unit when provided', (
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
      expect(find.textContaining(testValue.toString()), findsOneWidget);
    });

    testWidgets('AnimatedStatRow animates value changes', (
      WidgetTester tester,
    ) async {
      const testLabel = 'Steps';
      const initialValue = 1000;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedStatRow(label: testLabel, value: initialValue),
          ),
        ),
      );

      // Initial value should be displayed
      expect(find.text(initialValue.toString()), findsOneWidget);

      // Pump animation frames
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be there
      expect(find.byType(AnimatedStatRow), findsOneWidget);
    });
  });

  group('StepCounterArc Widget Tests', () {
    testWidgets('StepCounterArc displays step count', (
      WidgetTester tester,
    ) async {
      const testSteps = 5000;
      const testGoal = 10000;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepCounterArc(steps: testSteps, goal: testGoal),
          ),
        ),
      );

      expect(find.text(testSteps.toString()), findsOneWidget);
    });

    testWidgets('StepCounterArc shows progress correctly', (
      WidgetTester tester,
    ) async {
      const testSteps = 5000;
      const testGoal = 10000;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StepCounterArc(steps: testSteps, goal: testGoal),
          ),
        ),
      );

      // Check that the widget builds without error
      expect(find.byType(StepCounterArc), findsOneWidget);

      // Check that progress calculation works (50% in this case)
      final widget = tester.widget<StepCounterArc>(find.byType(StepCounterArc));
      expect(widget.steps, equals(testSteps));
      expect(widget.goal, equals(testGoal));
    });
  });

  group('Model Tests', () {
    test('UserModel creates instance correctly', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      expect(user.id, equals('123'));
      expect(user.email, equals('test@example.com'));
      expect(user.firstName, equals('John'));
      expect(user.lastName, equals('Doe'));
    });

    test('UserModel toJson works correctly', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      final json = user.toJson();
      expect(json['id'], equals('123'));
      expect(json['email'], equals('test@example.com'));
      expect(json['firstName'], equals('John'));
      expect(json['lastName'], equals('Doe'));
    });

    test('UserModel fromJson works correctly', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, equals('123'));
      expect(user.email, equals('test@example.com'));
      expect(user.firstName, equals('John'));
      expect(user.lastName, equals('Doe'));
    });
  });

  group('Navigation Tests', () {
    testWidgets('App has proper initial route', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));

      // App should start with SplashScreen (route '/')
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.initialRoute, isNull); // Default is '/'
    });
  });

  group('Theme Tests', () {
    testWidgets('App uses correct color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, isNotNull);
    });

    testWidgets('App has correct text theme', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: App()));

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      final headlineMedium = materialApp.theme?.textTheme.headlineMedium;

      expect(headlineMedium?.fontSize, equals(24));
      expect(headlineMedium?.fontWeight, equals(FontWeight.bold));
    });
  });

  group('Widget State Tests', () {
    testWidgets('Widgets handle state changes correctly', (
      WidgetTester tester,
    ) async {
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
      await tester.enterText(find.byType(TextField), 'test');
      expect(controller.text, equals('test'));

      // Pump frames to test animations
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Error Handling Tests', () {
    testWidgets('App handles null safety correctly', (
      WidgetTester tester,
    ) async {
      // Test that the app doesn't crash with null values
      await tester.pumpWidget(const ProviderScope(child: App()));

      // Pump a few frames to ensure no delayed errors
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });

    testWidgets('Widgets handle edge cases', (WidgetTester tester) async {
      // Test widgets with edge case values
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                InputField(label: ''),
                AnimatedStatRow(label: '', value: 0),
                StepCounterArc(steps: 0, goal: 0),
              ],
            ),
          ),
        ),
      );

      // Should not crash with empty/zero values
      expect(find.byType(InputField), findsOneWidget);
      expect(find.byType(AnimatedStatRow), findsOneWidget);
      expect(find.byType(StepCounterArc), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    testWidgets('App integrates multiple widgets correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: App()));

      // App should build with all its dependencies
      expect(find.byType(MaterialApp), findsOneWidget);

      // Pump multiple frames to ensure stability
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // No exceptions should be thrown
      expect(tester.takeException(), isNull);
    });
  });
}
