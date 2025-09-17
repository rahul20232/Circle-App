// lib/components/Cards/SwipeableNotificationCard.dart
import 'package:flutter/material.dart';

class SwipeableNotificationCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onClear;
  final double clearThreshold;

  const SwipeableNotificationCard({
    Key? key,
    required this.child,
    required this.onClear,
    this.clearThreshold = 0.5,
  }) : super(key: key);

  @override
  _SwipeableNotificationCardState createState() =>
      _SwipeableNotificationCardState();
}

class _SwipeableNotificationCardState extends State<SwipeableNotificationCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _clearController;
  late Animation<double> _slideAnimation;
  late Animation<double> _clearAnimation;

  double _dragExtent = 0;
  bool _dragUnderway = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _clearController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _clearAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _clearController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _clearController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    if (_slideController.isAnimating) {
      _slideController.stop();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway) return;

    final delta = details.primaryDelta!;
    final oldDragExtent = _dragExtent;

    // Only allow left swipe (negative delta)
    if (delta < 0) {
      _dragExtent += delta;
    } else if (_dragExtent < 0) {
      // Allow dragging back to center
      _dragExtent = (_dragExtent + delta).clamp(-double.infinity, 0.0);
    }

    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(() {});
    }

    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway) return;

    _dragUnderway = false;
    final velocity = details.primaryVelocity ?? 0.0;

    // Use a default card width for percentage calculations during drag end
    const defaultCardWidth = 300.0;
    final swipePercentage = (-_dragExtent / defaultCardWidth).clamp(0.0, 1.0);

    if (swipePercentage >= widget.clearThreshold || velocity < -1000) {
      // Clear the notification
      _clearNotification();
    } else {
      // Snap back to original position
      _slideController.animateTo(0.0).then((_) {
        setState(() {
          _dragExtent = 0;
        });
      });
    }
  }

  void _clearNotification() async {
    // Animate the card sliding out completely
    await _clearController.forward();
    widget.onClear();
  }

  double _getClearButtonWidth(double cardWidth) {
    final swipePercentage = (-_dragExtent / cardWidth).clamp(0.0, 1.0);

    if (swipePercentage <= 0.25) {
      // Phase 1: Small clear button appears (0-25%)
      return (swipePercentage / 0.25) * 60; // Max 60px width
    } else {
      // Phase 2: Clear button expands (25-50%+)
      final expansionProgress =
          ((swipePercentage - 0.25) / 0.25).clamp(0.0, 1.0);
      return 60 + (expansionProgress * (-_dragExtent - 60));
    }
  }

  Color _getClearButtonColor(double cardWidth) {
    final swipePercentage = (-_dragExtent / cardWidth).clamp(0.0, 1.0);

    if (swipePercentage >= widget.clearThreshold) {
      return Colors.red.shade600;
    } else {
      return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _clearAnimation]),
      builder: (context, child) {
        final clearProgress = _clearAnimation.value;

        return Transform.translate(
          offset: Offset(-400 * clearProgress, 0), // Slide out animation
          child: Opacity(
            opacity: 1.0 - clearProgress,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                final clearButtonWidth = _getClearButtonWidth(cardWidth);
                final clearButtonColor = _getClearButtonColor(cardWidth);

                return GestureDetector(
                  onHorizontalDragStart: _handleDragStart,
                  onHorizontalDragUpdate: _handleDragUpdate,
                  onHorizontalDragEnd: _handleDragEnd,
                  child: Stack(
                    children: [
                      // Background clear button
                      if (_dragExtent < 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: clearButtonWidth,
                            margin: EdgeInsets.only(bottom: 20, top: 0),
                            decoration: BoxDecoration(
                              color: clearButtonColor,
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(15),
                                left: clearButtonWidth > 60
                                    ? Radius.circular(15)
                                    : Radius.zero,
                              ),
                            ),
                            child: Center(
                              child: clearButtonWidth > 30
                                  ? Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                      size: clearButtonWidth > 100 ? 24 : 20,
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ),
                        ),

                      // Main notification card
                      Transform.translate(
                        offset: Offset(_dragExtent, 0),
                        child: widget.child,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
