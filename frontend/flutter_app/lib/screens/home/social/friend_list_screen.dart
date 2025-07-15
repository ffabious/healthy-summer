import 'package:flutter/material.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/services/services.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final FriendService _friendService = FriendService();
  List<FriendModel> _friends = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      debugPrint('🔍 Loading friends...');
      final response = await _friendService.getFriends();
      debugPrint(
        '✅ Friends loaded successfully: ${response.friends.length} friends',
      );

      if (mounted) {
        setState(() {
          _friends = response.friends;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading friends: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Error details: ${e.toString()}');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/friend-requests',
              );
              // If friend requests were accepted, refresh the friends list
              if (result == true) {
                _loadFriends();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.pushNamed(context, '/find-friends');
        },
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Error loading friends',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(onPressed: _loadFriends, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Find friends to start connecting!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Find Friends'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/find-friends');
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return Card(
          color: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                friend.firstName.isNotEmpty ? friend.firstName[0] : '?',
                style: const TextStyle(color: Colors.deepPurple),
              ),
            ),
            title: Text(
              friend.fullName,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              friend.email,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.message, color: Colors.white),
              onPressed: () {
                // TODO: Implement chat functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat functionality coming soon!'),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
