import 'package:flutter/material.dart';

class AnimatedLoadingText extends StatefulWidget {
  const AnimatedLoadingText({super.key});

  @override
  AnimatedLoadingTextState createState() => AnimatedLoadingTextState();
}

class AnimatedLoadingTextState extends State<AnimatedLoadingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;
  bool _increasing = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reset();
              setState(() {
                if (_increasing) {
                  _dotCount++;
                  if (_dotCount >= 3) _increasing = false;
                } else {
                  _dotCount--;
                  if (_dotCount <= 0) _increasing = true;
                }
              });
              _controller.forward();
            }
          });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _dots => '.' * _dotCount;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Loading$_dots',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    );
  }
}
