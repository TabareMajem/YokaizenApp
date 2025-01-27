import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final Color dotColor;
  final double dotSize;
  final Duration duration;

  TypingIndicator({
    this.dotColor = Colors.grey,
    this.dotSize = 10.0,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _TypingDot(dotColor: dotColor, dotSize: dotSize, duration: duration),
          const SizedBox(width: 8),
          _TypingDot(dotColor: dotColor, dotSize: dotSize, duration: duration),
          const SizedBox(width: 8),
          _TypingDot(dotColor: dotColor, dotSize: dotSize, duration: duration),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final Color dotColor;
  final double dotSize;
  final Duration duration;

  _TypingDot(
      {required this.dotColor, required this.dotSize, required this.duration});

  @override
  _TypingDotState createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.6).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: widget.dotSize,
        height: widget.dotSize,
        decoration:
            BoxDecoration(color: widget.dotColor, shape: BoxShape.circle),
      ),
    );
  }
}
