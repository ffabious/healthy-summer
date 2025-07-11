import 'package:flutter/material.dart';

class FriendChallenge {
  final String name;
  final String creator;
  final String description;
  final bool joined;
  final int? leaderboardPosition;

  FriendChallenge({
    required this.name,
    required this.creator,
    required this.description,
    this.joined = false,
    this.leaderboardPosition,
  });
}

class FriendsChallengesList extends StatelessWidget {
  final List<FriendChallenge> challenges = [
    FriendChallenge(
      name: "Weekend Water Warriors",
      creator: "Alice",
      description: "Drink 2L+ water each day over the weekend.",
      joined: true,
      leaderboardPosition: 2,
    ),
    FriendChallenge(
      name: "Step Showdown",
      creator: "You",
      description: "10,000+ steps daily for 3 days.",
      joined: false,
    ),
    FriendChallenge(
      name: "No Sugar Squad",
      creator: "Bob",
      description: "Avoid sugary snacks Mon–Fri!",
      joined: true,
      leaderboardPosition: 5,
    ),
  ];

  FriendsChallengesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: challenges.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return FriendChallengeCard(challenge: challenge);
        },
      ),
    );
  }
}

class FriendChallengeCard extends StatelessWidget {
  final FriendChallenge challenge;

  const FriendChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: challenge.joined ? Colors.deepPurple : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      elevation: challenge.joined ? 5 : 2,
      child: SizedBox(
        height: 155,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Created by ${challenge.creator}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    challenge.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (challenge.joined && challenge.leaderboardPosition != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "#${challenge.leaderboardPosition} on leaderboard",
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
