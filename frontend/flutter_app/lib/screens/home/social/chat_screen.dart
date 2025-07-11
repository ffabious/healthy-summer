import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String friendName;

  const ChatScreen({super.key, required this.friendName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friendName),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: dummyMessages.length,
              itemBuilder: (context, index) {
                final message = dummyMessages[dummyMessages.length - 1 - index];
                final isMe = message['isMe'] as bool;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.deepPurple : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          _MessageInput(),
        ],
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {}, // TODO: implement send logic
              icon: const Icon(Icons.send, color: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary dummy data
final List<Map<String, dynamic>> dummyMessages = [
  {'text': "Hey, how's the step challenge?", 'isMe': false},
  {'text': "Crushing it! You?", 'isMe': true},
  {'text': "Trying to catch up 😅", 'isMe': false},
  {'text': "Let's gooo 🔥", 'isMe': true},
];
