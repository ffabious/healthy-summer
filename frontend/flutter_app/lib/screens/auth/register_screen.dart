import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/core/secure_storage.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: RegisterBody(),
    );
  }
}

class RegisterBody extends ConsumerWidget {
  RegisterBody({super.key});

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create an Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              InputField(label: 'First Name', controller: _firstNameController),
              InputField(label: 'Last Name', controller: _lastNameController),
              InputField(
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              InputField(
                label: 'Password',
                obscureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: Text("Already have an account? Login"),
              ),
              ElevatedButton(
                onPressed: () {
                  final firstName = _firstNameController.text.trim();
                  final lastName = _lastNameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  if (firstName.isEmpty ||
                      lastName.isEmpty ||
                      email.isEmpty ||
                      password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                      ),
                    );
                    return;
                  }

                  final user = RegisterRequestModel(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password,
                  );
                  try {
                    final response = AuthService().register(user);
                    response.then((value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('first_name', value.user.firstName);
                      await prefs.setString('last_name', value.user.lastName);
                      await prefs.setString('email', value.user.email);

                      await SecureStorage.saveToken(value.token);

                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacementNamed('/');

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registration successful'),
                        ),
                      );

                      ref.invalidate(authProvider);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Registration failed: $e')),
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
