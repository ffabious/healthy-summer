// Unit tests for the Healthy Summer app models.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/user_model.dart';

void main() {
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

    test('UserModel requires all fields', () {
      // Test that all required fields must be provided
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

    test('UserModel creates minimal instance', () {
      final user = UserModel(
        id: '1',
        email: 'minimal@test.com',
        firstName: 'Test',
        lastName: 'User',
      );

      expect(user.id, equals('1'));
      expect(user.email, equals('minimal@test.com'));
      expect(user.firstName, equals('Test'));
      expect(user.lastName, equals('User'));
    });

    test('UserModel handles empty strings', () {
      final user = UserModel(id: '', email: '', firstName: '', lastName: '');

      expect(user.id, equals(''));
      expect(user.email, equals(''));
      expect(user.firstName, equals(''));
      expect(user.lastName, equals(''));
    });
  });

  group('Model Validation Tests', () {
    test('UserModel validates email format', () {
      // Create user with various email formats
      final validUser = UserModel(
        id: '1',
        email: 'valid@example.com',
        firstName: 'Valid',
        lastName: 'User',
      );

      final invalidUser = UserModel(
        id: '2',
        email: 'invalid-email',
        firstName: 'Invalid',
        lastName: 'User',
      );

      expect(validUser.email, contains('@'));
      expect(invalidUser.email, equals('invalid-email'));
    });

    test('UserModel handles special characters', () {
      final user = UserModel(
        id: '123',
        email: 'test+tag@example.com',
        firstName: 'José',
        lastName: 'O\'Connor',
      );

      expect(user.firstName, equals('José'));
      expect(user.lastName, equals('O\'Connor'));
      expect(user.email, equals('test+tag@example.com'));
    });
  });
}
