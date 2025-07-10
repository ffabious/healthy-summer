import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/animated_loading_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/screens/auth/auth.dart';
import 'package:flutter_app/screens/home/home_tabs_screen.dart';
import 'package:flutter_app/screens/error/error_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) => user != null ? HomeTabsScreen() : LoginScreen(),
      loading: () => LoadingScreen(),
      error: (e, _) => ErrorScreen(error: e.toString()),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const AnimatedLoadingText(),
          ],
        ),
      ),
    );
  }
}
