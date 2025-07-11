import 'package:flutter/material.dart';

class Challenge {
  final String name;
  final String description;
  final int? leaderboardPosition;
  final int? totalParticipants;

  Challenge({
    required this.name,
    required this.description,
    this.leaderboardPosition,
    this.totalParticipants,
  });
}

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({super.key, required this.challenge});

  // Helper to get rank badge color & label by percentile
  Widget? _buildRankBadge(int? position, int totalParticipants) {
    if (position == null) return null;

    final percentile = position / totalParticipants;

    Color color;
    String label;

    if (percentile <= 0.05) {
      color = Colors.amber.shade700; // gold
      label = "Top 5%";
    } else if (percentile <= 0.15) {
      color = Colors.grey.shade400; // silver
      label = "Top 15%";
    } else if (percentile <= 0.40) {
      color = Colors.brown.shade400; // bronze
      label = "Top 40%";
    } else {
      return null; // no badge if below 50%
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Assume challenge.totalParticipants is available (you'll need to add this)
    final rankBadge = _buildRankBadge(
      challenge.leaderboardPosition,
      challenge.totalParticipants ?? 100,
    );

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: rankBadge != null ? Colors.deepPurple : Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      elevation: 2,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 120,
              child: Column(
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
                    challenge.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 16,
            right: 16,
            child: SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.deepPurple),
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.zero,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Learn More"),
                ),
              ),
            ),
          ),

          if (rankBadge != null)
            Positioned(bottom: 16, left: 16, child: rankBadge),
        ],
      ),
    );
  }
}