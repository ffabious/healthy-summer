import 'package:flutter/material.dart';

class FriendListScreen extends StatelessWidget {
  const FriendListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friends = [
      {'name': 'Alice', 'status': 'Online'},
      {'name': 'Bob', 'status': 'Offline'},
      {'name': 'Charlie', 'status': 'Busy'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
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
                  friend['name']![0],
                  style: const TextStyle(color: Colors.deepPurple),
                ),
              ),
              title: Text(
                friend['name']!,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                friend['status']!,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.message, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/chat', arguments: friend['name']);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.pushNamed(context, '/find-friends');
        },
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}
