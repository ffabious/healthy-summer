import 'package:flutter/material.dart';
import 'package:flutter_app/screens/home/home.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Challenges'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Information'),
                      content: const Text(
                        'Community challenges are weekly events that reset every Monday at midnight,'
                        ' where everyone competes to reach top leaderboard positions.\n\n'
                        'Friend challenges are fun, customizable contests created by you '
                        'and your friends to motivate each other and track progress together anytime.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Community'),
              Tab(text: 'Friends'),
            ],
          ),
        ),
        body: TabBarView(
          children: [CommunityChallengesList(), FriendsChallengesList()],
        ),
      ),
    );
  }
}
