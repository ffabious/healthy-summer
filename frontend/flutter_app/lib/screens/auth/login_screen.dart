import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/core/secure_storage.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: LoginBody(),
    );
  }
}

class LoginBody extends ConsumerWidget {
  LoginBody({super.key});

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
                'Welcome Back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
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
                  Navigator.of(context).pushReplacementNamed('/register');
                },
                child: Text("Don't have an account? Register"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                      ),
                    );
                    return;
                  }

                  try {
                    final response = await AuthService().login(
                      LoginRequestModel(email: email, password: password),
                    );

                    await SecureStorage.saveToken(response.token);

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      'first_name',
                      response.user.firstName,
                    );
                    await prefs.setString('last_name', response.user.lastName);
                    await prefs.setString('email', email);

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login successful')),
                    );

                    ref.invalidate(authProvider);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
