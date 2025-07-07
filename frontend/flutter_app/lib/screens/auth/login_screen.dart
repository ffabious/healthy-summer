import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/widgets.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';

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

class LoginBody extends StatelessWidget {
  LoginBody({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              ElevatedButton(
                onPressed: () {
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

                  final request = LoginRequestModel(
                    email: email,
                    password: password,
                  );
                  AuthService()
                      .login(request)
                      .then((response) {
                        // TODO: Handle successful login
                        // For example, save the token and navigate to the home screen
                        // Here we just show a welcome message
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Welcome back, ${response.user.firstName}!',
                            ),
                          ),
                        );
                      })
                      .catchError((error) {
                        // TODO: Handle login error
                        // For example, show an error message
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: $error')),
                        );
                      });
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
