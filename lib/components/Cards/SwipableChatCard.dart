import 'package:flutter/material.dart';
import '../../models/chat_model.dart';

class SwipeableChatCard extends StatefulWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SwipeableChatCard({
    Key? key,
    required this.chat,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<SwipeableChatCard> createState() => _SwipeableChatCardState();
}

class _SwipeableChatCardState extends State<SwipeableChatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  double _dragExtent = 0.0;
  bool _isSwipedOpen = false;
  final double _maxSlideDistance = 80.0; // Maximum slide distance
  final double _snapThreshold = 40.0; // Threshold to snap to open/closed

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    // Stop any ongoing animation
    _animationController.stop();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final delta = details.delta.dx;

    // Only allow left swipe (negative values)
    if (delta < 0 || _dragExtent < 0) {
      setState(() {
        _dragExtent += delta;
        // Clamp the drag extent between 0 and -maxSlideDistance
        _dragExtent = _dragExtent.clamp(-_maxSlideDistance, 0.0);
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    // Determine whether to snap open or closed based on current position and velocity
    final velocity = details.velocity.pixelsPerSecond.dx;
    final shouldSnapOpen =
        _dragExtent.abs() > _snapThreshold || velocity < -500;

    if (shouldSnapOpen && !_isSwipedOpen) {
      _snapToOpen();
    } else if (!shouldSnapOpen && _isSwipedOpen) {
      _snapToClosed();
    } else if (shouldSnapOpen && _isSwipedOpen) {
      // Already open, keep it open
      _snapToOpen();
    } else {
      // Snap back to closed
      _snapToClosed();
    }
  }

  void _snapToOpen() {
    setState(() {
      _isSwipedOpen = true;
    });
    _animationController.forward().then((_) {
      setState(() {
        _dragExtent = -_maxSlideDistance;
      });
    });
  }

  void _snapToClosed() {
    setState(() {
      _isSwipedOpen = false;
    });
    _animationController.reverse().then((_) {
      setState(() {
        _dragExtent = 0.0;
      });
    });
  }

  void _handleTap() {
    if (_isSwipedOpen) {
      _snapToClosed();
    } else {
      widget.onTap();
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Conversation'),
          content: Text(
            'Are you sure you want to delete this conversation with ${widget.chat.otherUser.displayName}? This action cannot be undone and will remove the chat for both users.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRect(
        child: Stack(
          children: [
            // Delete button background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.red,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: _maxSlideDistance,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
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
            // Chat card with smooth transform
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                double translateX;
                if (_animationController.isAnimating) {
                  // During animation, interpolate between current drag and target
                  if (_isSwipedOpen) {
                    translateX = _dragExtent +
                        (_slideAnimation.value *
                            (-_maxSlideDistance - _dragExtent));
                  } else {
                    translateX = _dragExtent +
                        (_slideAnimation.value * (0 - _dragExtent));
                  }
                } else {
                  // When not animating, use the drag extent directly
                  translateX = _dragExtent;
                }

                return Transform.translate(
                  offset: Offset(translateX, 0),
                  child: GestureDetector(
                    onPanStart: _handlePanStart,
                    onPanUpdate: _handlePanUpdate,
                    onPanEnd: _handlePanEnd,
                    onTap: _handleTap,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      child: Stack(
                        children: <Widget>[
                          // Black border/background
                          Container(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.black,
                            ),
                          ),
                          // Inner white container
                          Positioned(
                            top: 2,
                            left: 2,
                            right: 2,
                            child: Container(
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                color: const Color.fromRGBO(250, 250, 250, 1),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Profile picture
                                  _buildProfilePicture(),
                                  const SizedBox(width: 30),
                                  // Chat content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Name and unread count row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                widget
                                                    .chat.otherUser.displayName,
                                                style: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 1),
                                                  fontFamily: 'Arial',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (widget.chat.unreadCount > 0)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF6B46C1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  widget.chat.unreadCount
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        // Last message preview
                                        if (widget.chat.lastMessage !=
                                            null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.chat.lastMessage!.content,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Delete button hitbox (invisible overlay when swiped)
            if (_isSwipedOpen)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _handleDelete,
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

  Widget _buildProfilePicture() {
    return CircleAvatar(
      radius: 25,
      backgroundColor: const Color(0xFF6B46C1),
      backgroundImage: widget.chat.otherUser.profilePictureUrl != null &&
              widget.chat.otherUser.profilePictureUrl!.isNotEmpty
          ? NetworkImage(widget.chat.otherUser.profilePictureUrl!)
          : null,
      child: widget.chat.otherUser.profilePictureUrl == null ||
              widget.chat.otherUser.profilePictureUrl!.isEmpty
          ? Text(
              widget.chat.otherUser.displayName.isNotEmpty
                  ? widget.chat.otherUser.displayName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          : null,
    );
  }
}
