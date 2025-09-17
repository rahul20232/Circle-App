import 'package:flutter/material.dart';

class SwipeableBookingCard extends StatefulWidget {
  final String title;
  final String date;
  final String time;
  final String location;
  final String status;
  final int availableSpots;
  final bool isPastDinner;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  final bool canCancel;

  const SwipeableBookingCard({
    Key? key,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    required this.availableSpots,
    required this.onTap,
    required this.onCancel,
    this.isPastDinner = false,
    this.canCancel = false,
  }) : super(key: key);

  @override
  State<SwipeableBookingCard> createState() => _SwipeableBookingCardState();
}

class _SwipeableBookingCardState extends State<SwipeableBookingCard>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late AnimationController _pressAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pressOffsetAnimation;
  late Animation<double> _pressScaleAnimation;
  late Animation<double> _shadowAnimation;

  double _dragExtent = 0.0;
  bool _isSwipedOpen = false;
  bool _isPressed = false;
  final double _maxSlideDistance = 80.0;
  final double _snapThreshold = 40.0;

  @override
  void initState() {
    super.initState();

    // Slide animation controller (for swipe functionality)
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOut,
    ));

    // Press animation controller (for tactile keypad effect)
    _pressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // White card offset animation (moves down when pressed)
    _pressOffsetAnimation = Tween<double>(
      begin: 2.0, // Normal elevated position
      end: 0.0, // Pressed down position (flush with black border)
    ).animate(CurvedAnimation(
      parent: _pressAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Scale animation for additional tactile feedback
    _pressScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _pressAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Shadow animation (reduces shadow when pressed)
    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _pressAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _pressAnimationController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    _slideAnimationController.stop();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.canCancel) return;

    final delta = details.delta.dx;
    if (delta < 0 || _dragExtent < 0) {
      setState(() {
        _dragExtent += delta;
        _dragExtent = _dragExtent.clamp(-_maxSlideDistance, 0.0);
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.canCancel) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final shouldSnapOpen =
        _dragExtent.abs() > _snapThreshold || velocity < -500;

    if (shouldSnapOpen && !_isSwipedOpen) {
      _snapToOpen();
    } else if (!shouldSnapOpen && _isSwipedOpen) {
      _snapToClosed();
    } else if (shouldSnapOpen && _isSwipedOpen) {
      _snapToOpen();
    } else {
      _snapToClosed();
    }
  }

  void _snapToOpen() {
    setState(() => _isSwipedOpen = true);
    _slideAnimationController.forward().then((_) {
      setState(() => _dragExtent = -_maxSlideDistance);
    });
  }

  void _snapToClosed() {
    setState(() => _isSwipedOpen = false);
    _slideAnimationController.reverse().then((_) {
      setState(() => _dragExtent = 0.0);
    });
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressAnimationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    setState(() => _isPressed = false);
    // Create a bounce-back effect
    _pressAnimationController.reverse().then((_) {
      // Add a subtle bounce at the end
      _pressAnimationController.forward(from: 0.0);
      _pressAnimationController.reverse();
    });

    // Delayed tap action to feel more tactile
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_isSwipedOpen) {
        _snapToClosed();
      } else {
        widget.onTap();
      }
    });
  }

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFEF1DE),
          title: const Text('Remove Booking'),
          content: Text(
            'Are you sure you want to remove your booking for "${widget.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Keep Booking',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancel();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Remove Booking',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Color get _statusColor {
    if (widget.isPastDinner) return Colors.orange.shade600;
    switch (widget.status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String get _statusText {
    if (widget.isPastDinner) return 'Past';
    switch (widget.status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return widget.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRect(
        child: Stack(
          children: [
            // Cancel background
            if (widget.canCancel)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.red,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: _maxSlideDistance,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isPastDinner ||
                                    widget.status.toLowerCase() == 'cancelled'
                                ? Icons.delete_outline
                                : Icons.cancel_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isPastDinner ||
                                    widget.status.toLowerCase() == 'cancelled'
                                ? 'Remove'
                                : 'Cancel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Booking card with tactile animation
            AnimatedBuilder(
              animation: Listenable.merge(
                  [_slideAnimation, _pressAnimationController]),
              builder: (context, child) {
                // Calculate slide position
                double translateX;
                if (_slideAnimationController.isAnimating) {
                  if (_isSwipedOpen) {
                    translateX = _dragExtent +
                        (_slideAnimation.value *
                            (-_maxSlideDistance - _dragExtent));
                  } else {
                    translateX = _dragExtent +
                        (_slideAnimation.value * (0 - _dragExtent));
                  }
                } else {
                  translateX = _dragExtent;
                }

                return Transform.translate(
                  offset: Offset(translateX, 0),
                  child: Transform.scale(
                    scale: _pressScaleAnimation.value,
                    child: GestureDetector(
                      onPanStart: widget.canCancel ? _handlePanStart : null,
                      onPanUpdate: widget.canCancel ? _handlePanUpdate : null,
                      onPanEnd: widget.canCancel ? _handlePanEnd : null,
                      onTapDown: _handleTapDown,
                      onTapUp: _handleTapUp,
                      onTapCancel: _handleTapCancel,
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        child: Stack(
                          children: <Widget>[
                            // Black border/shadow (stays in place)
                            Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.black,
                                // Add shadow effect that changes with press
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.1 * _shadowAnimation.value),
                                    blurRadius: 8 * _shadowAnimation.value,
                                    offset:
                                        Offset(0, 4 * _shadowAnimation.value),
                                  ),
                                ],
                              ),
                            ),

                            // White card (moves down when pressed)
                            AnimatedBuilder(
                              animation: _pressOffsetAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: _pressOffsetAnimation.value,
                                  left: 2,
                                  right: 2,
                                  child: Container(
                                    height:
                                        126 + (2 - _pressOffsetAnimation.value),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(13),
                                      color: widget.isPastDinner
                                          ? const Color.fromRGBO(
                                              250, 248, 245, 1)
                                          : const Color.fromRGBO(
                                              250, 250, 250, 1),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 16, 16, 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  widget.title,
                                                  style: TextStyle(
                                                    color: widget.isPastDinner
                                                        ? Colors.grey.shade700
                                                        : Colors.black,
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _statusColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: _statusColor,
                                                      width: 1),
                                                ),
                                                child: Text(
                                                  _statusText,
                                                  style: TextStyle(
                                                    color: _statusColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 30),
                                          Text(
                                            '${widget.date} at ${widget.time}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontFamily: 'Inter',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  widget.location,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontFamily: 'Inter',
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Cancel overlay
            if (_isSwipedOpen && widget.canCancel)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _handleCancel,
                  child: Container(
                    width: _maxSlideDistance,
                    color: Colors.transparent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
