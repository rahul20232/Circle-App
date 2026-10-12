// lib/screens/Home/home_screen_content.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/components/Cards/NewCard.dart';
import './controllers/home_screen_controller.dart';
import './components/home_screen_components.dart';

class HomeScreenContent extends StatefulWidget {
  final VoidCallback? onSwitchToConnect;
  const HomeScreenContent({Key? key, this.onSwitchToConnect}) : super(key: key);

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent>
    with TickerProviderStateMixin, RouteAware {
  late HomeScreenController _controller;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  double _dragOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller =
        HomeScreenController(onSwitchToConnect: widget.onSwitchToConnect);
    _controller.initialize();

    // Initialize bounce animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleRatingSuccess() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for rating your dinner experience!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleRatingError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit rating: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSubmitRating() async {
    try {
      await _controller.submitRating();
      _handleRatingSuccess();
    } catch (e) {
      _handleRatingError(e.toString());
    }
  }

  Future<void> _handleBookDinner() async {
    await _controller.bookSelectedDinner(context);
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _bounceController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _dragOffset += details.delta.dy;
        // Limit the drag distance for better control
        _dragOffset = _dragOffset.clamp(-200.0, 300.0);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;

    // Animate back to original position with bounce
    _bounceController.reset();
    _bounceController.forward();

    _bounceAnimation.addListener(() {
      setState(() {
        _dragOffset = _dragOffset * (1 - _bounceAnimation.value);
      });
    });
  }

  Widget _buildHeader() {
    if (_controller.hasRatableBooking &&
        _controller.firstRatableBooking != null) {
      return HomeScreenComponents.buildRatingHeader(
        ratableBooking: _controller.firstRatableBooking!,
        currentRating: _controller.currentRating,
        onRatingChanged: _controller.setRating,
        isSubmittingRating: _controller.isSubmittingRating,
        onSubmitRating: _handleSubmitRating,
        onStartConnecting: _controller.startConnecting,
      );
    } else {
      return HomeScreenComponents.buildLocationHeader();
    }
  }

  Widget _buildStretchyBackground() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        // Calculate stretch effect based on drag offset
        final stretchFactor = (_dragOffset / 100).clamp(-2.0, 3.0);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF6B46C1), // Purple
                const Color(0xFF9333EA), // Lighter purple
              ],
              // Adjust gradient stops based on stretch
              stops: [
                0.0,
                (0.8 + stretchFactor * 0.05).clamp(0.5, 1.0),
              ],
            ),
          ),
          // Apply transform for stretch effect
          transform: Matrix4.identity()
            ..scale(1.0, 1.0 + stretchFactor * 0.05)
            ..translate(0.0, _dragOffset * 0.1),
          child: SafeArea(
            child: Column(
              children: [
                Transform.translate(
                  offset: Offset(0, _dragOffset * 0.2),
                  child: _buildHeader(),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableBottomSheet() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        final stretchFactor = (_dragOffset / 100).clamp(-2.0, 3.0);

        return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFEF1DE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24 + stretchFactor.abs() * 2),
                topRight: Radius.circular(24 + stretchFactor.abs() * 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.1 + stretchFactor.abs() * 0.05),
                  blurRadius: 15 + stretchFactor.abs() * 5,
                  offset: Offset(0, -8 + _dragOffset * 0.02),
                ),
              ],
            ),
            child: Column(
              children: [
                // DRAGGABLE HEADER SECTION ONLY
                GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                        30, 12, 30, 0), // Increased bottom padding
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          margin: const EdgeInsets.only(
                              bottom: 10), // Increased margin
                          width: 40 + stretchFactor.abs() * 5,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Header content
                        HomeScreenComponents.buildContentHeader(
                          title: _controller.headerTitle,
                          subtitle: _controller.availableDinnersText,
                        ),
                        // Extra space to expand draggable area
                        const SizedBox(height: 0),
                      ],
                    ),
                  ),
                ),

                // SCROLLABLE CONTENT SECTION (NOT DRAGGABLE)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_controller.isLoading)
                          Container(
                            height: 200,
                            child: HomeScreenComponents.buildLoadingState(),
                          )
                        else if (_controller.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: HomeScreenComponents.buildErrorState(
                              errorMessage: _controller.errorMessage!,
                              onRetry: _controller.refresh,
                            ),
                          )
                        else if (_controller.availableDinners.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: _controller.availableDinners.length,
                              itemBuilder: (context, index) {
                                final dinner = _controller.availableDinners[index];
                                final isSelected = _controller.selectedDinner?.id == dinner.id;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: NewCard(
                                    date: dinner.formattedDate,
                                    time: dinner.formattedTime,
                                    isSelected: isSelected,
                                    availableSpots: dinner.availableSpots,
                                    location: dinner.location,
                                    onTap: () => _controller.selectDinner(dinner),
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            height: 200,
                            child: HomeScreenComponents.buildEmptyState(),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // STICKY BOOK BUTTON
                if (!_controller.isLoading && _controller.errorMessage == null && _controller.availableDinners.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
                    child: HomeScreenComponents.buildBookButton(
                      canBook: _controller.canBookDinner,
                      buttonText: _controller.bookButtonText,
                      onPressed: _controller.canBookDinner ? _handleBookDinner : null,
                    ),
                  ),
              ],
            ),
          );
      },
    );
  }

  Widget _buildRubberBandConnection() {
    if (_dragOffset.abs() < 10) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: RubberBandPainter(
              stretchAmount: _dragOffset,
              color: const Color(0xFF9333EA).withOpacity(0.4),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final initialBottomSheetHeight = screenHeight * 0.72;
        final sheetTop = (screenHeight - initialBottomSheetHeight + _dragOffset).clamp(0.0, screenHeight * 0.6);

        return Scaffold(
          body: Stack(
            children: [
              // Stretchy background with header
              _buildStretchyBackground(),

              // Rubber band connection visual
              _buildRubberBandConnection(),

              // Draggable bottom sheet
              Positioned(
                top: sheetTop,
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildDraggableBottomSheet(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom painter for the rubber band connection effect
class RubberBandPainter extends CustomPainter {
  final double stretchAmount;
  final Color color;

  RubberBandPainter({
    required this.stretchAmount,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Calculate connection points
    final topPoint = Offset(size.width / 2, size.height * 0.55);
    final bottomPoint =
        Offset(size.width / 2, size.height * 0.75 + stretchAmount * 0.3);

    // Create curved rubber band effect
    final controlPoint1 = Offset(
      topPoint.dx + stretchAmount.abs() * 0.2,
      topPoint.dy + (bottomPoint.dy - topPoint.dy) * 0.3,
    );

    final controlPoint2 = Offset(
      bottomPoint.dx - stretchAmount.abs() * 0.2,
      bottomPoint.dy - (bottomPoint.dy - topPoint.dy) * 0.3,
    );

    path.moveTo(topPoint.dx, topPoint.dy);
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      bottomPoint.dx,
      bottomPoint.dy,
    );

    canvas.drawPath(path, paint);

    // Add side strands for rubber band effect
    if (stretchAmount.abs() > 30) {
      paint.strokeWidth = 1.0;
      paint.color = color.withOpacity(0.6);

      // Left strand
      final leftPath = Path();
      leftPath.moveTo(topPoint.dx - 15, topPoint.dy + 5);
      leftPath.quadraticBezierTo(
        bottomPoint.dx - 15 + stretchAmount * 0.1,
        (topPoint.dy + bottomPoint.dy) / 2,
        bottomPoint.dx - 15,
        bottomPoint.dy - 5,
      );

      // Right strand
      final rightPath = Path();
      rightPath.moveTo(topPoint.dx + 15, topPoint.dy + 5);
      rightPath.quadraticBezierTo(
        bottomPoint.dx + 15 - stretchAmount * 0.1,
        (topPoint.dy + bottomPoint.dy) / 2,
        bottomPoint.dx + 15,
        bottomPoint.dy - 5,
      );

      canvas.drawPath(leftPath, paint);
      canvas.drawPath(rightPath, paint);
    }
  }

  @override
  bool shouldRepaint(RubberBandPainter oldDelegate) {
    return oldDelegate.stretchAmount != stretchAmount ||
        oldDelegate.color != color;
  }
}
