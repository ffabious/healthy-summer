import 'package:flutter/material.dart';
import 'package:flutter_app/screens/auth/splash_screen.dart';
import 'screens/auth/auth.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: const Key('healthy_summer_app'),
      debugShowCheckedModeBanner: false,
      title: 'Healthy Summer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
