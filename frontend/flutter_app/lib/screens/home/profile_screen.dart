import 'package:flutter/material.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/core/secure_storage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 24)),
      ),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  const Text('Error loading profile data'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
          } else {
            final prefs = snapshot.data!;
            final firstName = prefs.getString('first_name');
            final lastName = prefs.getString('last_name');
            final username = firstName != null && lastName != null
                ? '$firstName $lastName'
                : 'Guest';
            final email = prefs.getString('email') ?? 'Not provided';
            return ProfileBody(username: username, email: email);
          }
        },
      ),
    );
  }
}

class ProfileBody extends ConsumerWidget {
  const ProfileBody({
    super.key,
    required String username,
    required String email,
  }) : _username = username,
       _email = email;

  final String _username;
  final String _email;

  void _logout(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await SecureStorage.deleteToken();
    ref.invalidate(authProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: Replace with actual user profile picture
          // For now, using a placeholder CircleAvatar
          // In a real app, you would fetch the user's profile picture from a server or local storage
          // and display it here.
          Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.teal, width: 4),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.teal[100],
              child: Text(
                _username[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Username: $_username',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text('Email: $_email', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          SizedBox(
            width: screenWidth * 0.7,
            child: ElevatedButton.icon(
              onPressed: () {}, // TODO: Implement edit profile functionality
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text(
                "Edit Profile",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: screenWidth * 0.7,
            child: OutlinedButton.icon(
              onPressed: () => _logout(ref),
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: BorderSide(color: Colors.teal, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
