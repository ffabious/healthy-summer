import 'package:flutter/material.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/core/secure_storage.dart';
import 'package:flutter_app/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfileData();
  }

  Future<ProfileModel> _fetchProfileData() async {
    final token = await SecureStorage.getToken();
    return await AuthService().getProfile(token ?? '');
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProfile,
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: FutureBuilder<ProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
          } else if (snapshot.hasData) {
            var firstName = snapshot.data!.firstName;
            var lastName = snapshot.data!.lastName;
            final String username = '$firstName $lastName';
            final String email = snapshot.data!.email;
            return ProfileBody(
              username: username,
              email: email,
              onRefresh: _refreshProfile,
            );
          } else {
            return const Center(child: Text('No profile data found.'));
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
    this.onRefresh,
  }) : _username = username,
       _email = email;

  final String _username;
  final String _email;
  final VoidCallback? onRefresh;

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
          Text(_username, style: Theme.of(context).textTheme.headlineLarge),
          Text('Email: $_email', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          SizedBox(
            width: screenWidth * 0.7,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(
                  context,
                ).pushNamed('/edit-profile');
                if (result == true && onRefresh != null) {
                  onRefresh!(); // Refresh the profile data
                }
              },
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
