import 'dart:math';
import 'package:flutter/material.dart';

class FlipCardWidget extends StatefulWidget {
  final Widget front; final Widget back;
  const FlipCardWidget({super.key, required this.front, required this.back});
  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller; late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _controller.isDismissed ? _controller.forward() : _controller.reverse(),
      child: AnimatedBuilder(animation: _animation, builder: (context, child) {
        final angle = _animation.value * pi;
        return Transform(
          transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
          alignment: Alignment.center,
          child: angle < pi / 2 ? widget.front : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi), child: widget.back),
        );
      }),
    );
  }
}
