import 'package:flutter/material.dart';

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      {
        'name': 'Alice',
        'activity': 'Completed 5 km run',
        'time': '2h ago',
        'type': 'run',
      },
      {
        'name': 'Bob',
        'activity': 'Drank 2L of water today',
        'time': '4h ago',
        'type': 'water',
      },
      {
        'name': 'Charlie',
        'activity': 'Logged 8000 steps',
        'time': 'Yesterday',
        'type': 'steps',
      },
    ];

    IconData getActivityIcon(String type) {
      switch (type) {
        case 'run':
          return Icons.directions_run;
        case 'water':
          return Icons.water_drop;
        case 'steps':
          return Icons.directions_walk;
        default:
          return Icons.fitness_center;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];

          return AnimatedSocialCard(
            index: index,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  // Left: Purple side with avatar + name
                  Container(
                    width: 100,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            post['name']![0],
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Light section with icon on top, activity text, and timestamp bottom right
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                getActivityIcon(post['type']!),
                                color: Colors.deepPurple,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                post['activity']!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Text(
                              post['time']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedSocialCard extends StatefulWidget {
  final Widget child;
  final int index;
  const AnimatedSocialCard({
    required this.child,
    required this.index,
    super.key,
  });

  @override
  State<AnimatedSocialCard> createState() => _AnimatedSocialCardState();
}

class _AnimatedSocialCardState extends State<AnimatedSocialCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}
