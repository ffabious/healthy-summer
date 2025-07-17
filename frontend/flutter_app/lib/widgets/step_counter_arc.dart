import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedStepCounterArc extends StatefulWidget {
  final int steps;
  final int goal;

  const AnimatedStepCounterArc({
    required this.steps,
    required this.goal,
    super.key,
  });

  @override
  AnimatedStepCounterArcState createState() => AnimatedStepCounterArcState();
}

class AnimatedStepCounterArcState extends State<AnimatedStepCounterArc>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    final progress = (widget.steps / widget.goal).clamp(0.0, 1.0);

    _animation =
        Tween<double>(begin: 0, end: progress).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        )..addListener(() {
          setState(() {});
        });

    _celebrationAnimation =
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _celebrationController, curve: Curves.linear),
        )..addListener(() {
          setState(() {});
        });

    _controller.forward().then((_) {
      // Check if goal is exceeded after the main animation completes
      if (widget.steps >= widget.goal) {
        setState(() {
          _showCelebration = true;
        });
        _celebrationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(120, 120),
          painter: _StepArcPainter(_animation.value),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.steps}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/${widget.goal}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Steps Today',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
        if (_showCelebration)
          AnimatedBuilder(
            animation: _celebrationAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(200, 200),
                painter: _FireworksPainter(_celebrationAnimation.value),
              );
            },
          ),
      ],
    );
  }
}

class StepCounterArc extends StatelessWidget {
  final int steps;
  final int goal;

  const StepCounterArc({required this.steps, required this.goal, super.key});

  @override
  Widget build(BuildContext context) {
    final progress = (steps / goal).clamp(0.0, 1.0);

    return CustomPaint(
      size: Size(120, 120),
      painter: _StepArcPainter(progress),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$steps',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  '/$goal',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Steps',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _FireworksPainter extends CustomPainter {
  final double progress;

  _FireworksPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = Random(42); // Fixed seed for consistent animation

    // Create multiple firework bursts
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + (progress * 2 * pi);
      final burstProgress = (progress * 3).clamp(0.0, 1.0);

      // Create particles for each burst
      for (int j = 0; j < 8; j++) {
        final particleAngle = angle + (j * pi / 4);
        final distance = burstProgress * (80 + random.nextDouble() * 60);
        final x = center.dx + cos(particleAngle) * distance;
        final y = center.dy + sin(particleAngle) * distance;

        // Fade out particles over time
        final opacity = (1 - burstProgress).clamp(0.0, 1.0);

        // Different colors for variety
        final colors = [
          Colors.orange,
          Colors.yellow,
          Colors.red,
          Colors.pink,
          Colors.purple,
          Colors.blue,
        ];

        final paint = Paint()
          ..color = colors[i % colors.length].withValues(alpha: opacity)
          ..style = PaintingStyle.fill;

        // Draw particle as small circle
        canvas.drawCircle(
          Offset(x, y),
          6 - (burstProgress * 3), // Shrink particles over time
          paint,
        );

        // Add trailing effect
        if (burstProgress > 0.3) {
          final trailPaint = Paint()
            ..color = colors[i % colors.length].withValues(alpha: opacity * 0.3)
            ..style = PaintingStyle.fill;

          final trailDistance = distance * 0.7;
          final trailX = center.dx + cos(particleAngle) * trailDistance;
          final trailY = center.dy + sin(particleAngle) * trailDistance;

          canvas.drawCircle(Offset(trailX, trailY), 3, trailPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StepArcPainter extends CustomPainter {
  final double progress;

  _StepArcPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    final startAngle = -5 * pi / 4;
    final sweepAngle = 3 * pi / 2;

    // Background arc (gray)
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Foreground arc (progress)
    final foregroundPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StepArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
