import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/widgets.dart';

class CommunityChallengesList extends StatelessWidget {
  final List<Challenge> challenges = [
    Challenge(
      name: "🏃 Stepper Showdown",
      description:
          "Who takes the most steps this week? Walk, jog, or pace furiously.",
      leaderboardPosition: 3,
      totalParticipants: 150,
    ),
    Challenge(
      name: "🔥 Most Active Hours",
      description:
          "Rack up the most hours of activity this week. Hustle counts.",
      leaderboardPosition: 25,
      totalParticipants: 200,
    ),
    Challenge(
      name: "🚲 Tour de Living Room",
      description:
          "Who can ride the longest distance this week? Stationary bikes allowed!",
      leaderboardPosition: 50,
      totalParticipants: 100,
    ),
    Challenge(
      name: "💪 Rep It Out!",
      description:
          "Crank out the most strength workouts this week. Gym selfies optional.",
      leaderboardPosition: 30,
      totalParticipants: 80,
    ),
    Challenge(
      name: "🥤 Hydration Hero",
      description: "Most water logged this week. Stay hydrated, friends.",
      leaderboardPosition: null, // no rank yet
      totalParticipants: 120,
    ),
  ];

  CommunityChallengesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return ChallengeCard(challenge: challenge);
        },
      ),
    );
  }
}
