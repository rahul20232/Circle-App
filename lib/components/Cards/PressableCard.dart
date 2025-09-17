import 'package:flutter/material.dart';

class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const PressableCard({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // ensures whole area is tappable
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0, // deeper press
        duration: _isPressed
            ? const Duration(milliseconds: 70) // instant shrink
            : const Duration(milliseconds: 140), // snappy release
        curve: _isPressed ? Curves.easeOutCubic : Curves.elasticOut,
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.85 : 1.0, // subtle dim
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}
