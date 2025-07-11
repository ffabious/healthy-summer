import 'package:flutter/material.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SocialCard(
        icon: Icons.people,
        label: 'Friends',
        onTap: () {
          Navigator.pushNamed(context, '/friend-list');
        },
      ),
      _SocialCard(
        icon: Icons.feed,
        label: 'Feed',
        onTap: () {
          Navigator.pushNamed(context, '/social-feed');
        },
      ),
      _SocialCard(
        icon: Icons.emoji_events,
        label: 'Challenges',
        onTap: () {
          Navigator.pushNamed(context, '/challenges');
        },
      ),
      _SocialCard(
        icon: Icons.chat,
        label: 'Messages',
        onTap: () {
          Navigator.pushNamed(context, '/messages');
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Social"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: cards,
        ),
      ),
      // floatingActionButton: SocialFAB(),
    );
  }
}

class _SocialCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialFAB extends StatefulWidget {
  const SocialFAB({super.key});

  @override
  State<SocialFAB> createState() => _SocialFABState();
}

class _SocialFABState extends State<SocialFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleFab() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Overlay background to dismiss FAB when tapping outside
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleFab,
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),
          ),

        // FAB Options
        Padding(
          padding: const EdgeInsets.only(bottom: 80, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AnimatedFabOption(
                isVisible: _isExpanded,
                delay: 0,
                icon: Icons.flag,
                label: "Create Challenge",
                onTap: () {
                  // Add navigation
                  _toggleFab();
                },
              ),
              _AnimatedFabOption(
                isVisible: _isExpanded,
                delay: 100,
                icon: Icons.person_add,
                label: "Invite Friend",
                onTap: () {
                  _toggleFab();
                },
              ),
              _AnimatedFabOption(
                isVisible: _isExpanded,
                delay: 200,
                icon: Icons.group,
                label: "Start Group Activity",
                onTap: () {
                  _toggleFab();
                },
              ),
            ],
          ),
        ),

        // Main FAB
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton(
            onPressed: _toggleFab,
            backgroundColor: Colors.deepPurple,
            child: Icon(_isExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}

class _AnimatedFabOption extends StatelessWidget {
  final bool isVisible;
  final int delay;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AnimatedFabOption({
    required this.isVisible,
    required this.delay,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 0.2),
      duration: Duration(milliseconds: 150 + delay),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: Duration(milliseconds: 300 + delay),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
          ),
        ),
      ),
    );
  }
}
