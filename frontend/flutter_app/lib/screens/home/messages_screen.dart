import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  final List<Conversation> conversations = [
    Conversation(
      friendName: "Lara",
      avatarUrl: null,
      lastMessage: "Let’s go hiking tomorrow!",
      timestamp: "10:42 AM",
      unread: true,
    ),
    Conversation(
      friendName: "Ben",
      avatarUrl: null,
      lastMessage: "Nice progress on your steps 👏",
      timestamp: "Yesterday",
      unread: false,
    ),
  ];

  MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final convo = conversations[index];

          return Dismissible(
            key: Key(convo.id), // Make sure each convo has a unique ID
            direction: DismissDirection.endToStart,
            background: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ),
            onDismissed: (direction) {
              // Handle delete action
              // setState(() => conversations.removeAt(index));
            },
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Conversation"),
                  content: const Text(
                    "Are you sure you want to delete this conversation?",
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text("Delete"),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    convo.friendName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  convo.friendName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  convo.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      convo.timestamp,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (convo.unread)
                      const Icon(
                        Icons.circle,
                        color: Colors.deepPurple,
                        size: 10,
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: convo.friendName,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class Conversation {
  final String id = UniqueKey().toString();
  final String friendName;
  final String? avatarUrl;
  final String lastMessage;
  final String timestamp;
  final bool unread;

  Conversation({
    required this.friendName,
    this.avatarUrl,
    required this.lastMessage,
    required this.timestamp,
    required this.unread,
  });
}
