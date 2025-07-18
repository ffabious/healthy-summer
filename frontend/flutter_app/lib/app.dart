import 'package:flutter/material.dart';
import 'package:flutter_app/screens/home/home.dart';
import 'package:flutter_app/screens/auth/splash_screen.dart';
import 'package:flutter_app/screens/home/nutrition/all_meals_screen.dart';
import 'package:flutter_app/screens/home/nutrition/all_water_entries_screen.dart';
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
        '/activity-history': (context) => const ActivityHistoryScreen(),
        '/add-activity': (context) => const AddActivityScreen(),
        '/edit-activity': (context) => const EditActivityScreen(),
        '/add-meal': (context) => const AddMealScreen(),
        '/add-water-intake': (context) => const AddWaterIntakeScreen(),
        '/all-meals': (context) => const AllMealsScreen(),
        '/all-water-entries': (context) => const AllWaterEntriesScreen(),
        '/friend-list': (context) => const FriendListScreen(),
        '/find-friends': (context) => const FindFriendsScreen(),
        '/friend-requests': (context) => const FriendRequestsScreen(),
        '/social-feed': (context) => const SocialFeedScreen(),
        '/challenges': (context) => ChallengesScreen(),
        '/chat': (context) {
          final friendName =
              ModalRoute.of(context)?.settings.arguments as String?;
          return ChatScreen(friendName: friendName ?? 'Unknown');
        },
        '/messages': (context) => MessagesScreen(),
        '/edit-profile': (context) => EditProfileScreen(),
      },
    );
  }
}
