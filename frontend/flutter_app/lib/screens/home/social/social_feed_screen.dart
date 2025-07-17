import 'package:flutter/material.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/services/services.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final SocialService _socialService = SocialService();
  List<FeedItem> feedItems = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await _socialService.getFeed();
      setState(() {
        feedItems = response.feedItems;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _getActivityText(FeedItem item) {
    switch (item.activityType) {
      case 'water_intake':
        final volumeMl = item.activityData['volume_ml'] as num? ?? 0;
        final volumeL = (volumeMl / 1000).toStringAsFixed(1);
        return 'Drank ${volumeL}L of water today';
      default:
        return 'Completed activity';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData getActivityIcon(String type) {
      switch (type) {
        case 'run':
          return Icons.directions_run;
        case 'water_intake':
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
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFeed),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFeed,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : feedItems.isEmpty
          ? const Center(
              child: Text(
                'No activities from friends yet.\nAdd friends to see their activities!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedItems.length,
              itemBuilder: (context, index) {
                final item = feedItems[index];

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
                                  item.userName.isNotEmpty
                                      ? item.userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                      getActivityIcon(item.activityType),
                                      color: Colors.deepPurple,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getActivityText(item),
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
                                    _getTimeAgo(item.createdAt),
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
