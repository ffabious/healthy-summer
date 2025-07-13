import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedStatRow extends StatefulWidget {
  final String label;
  final num value;
  final String unit; // e.g. "kcal", "g", "L"

  const AnimatedStatRow({
    required this.label,
    required this.value,
    this.unit = '',
    super.key,
  });

  @override
  State<AnimatedStatRow> createState() => _AnimatedStatRowState();
}

class _AnimatedStatRowState extends State<AnimatedStatRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<num> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<num>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedStatRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<num>(
        begin: 0,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatValue(num val) {
    if (val is int || val == val.roundToDouble()) {
      return NumberFormat.decimalPattern().format(val.round());
    } else {
      return val.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.label, style: const TextStyle(fontSize: 16)),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final displayValue = formatValue(_animation.value);
              return Text(
                '$displayValue ${widget.unit}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
