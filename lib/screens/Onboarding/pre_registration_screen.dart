// lib/screens/Onboarding/pre_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/screens/Onboarding/initial_onboarding_screen.dart';
import 'package:circle_app/screens/Onboarding/controllers/pre_registration_controller.dart';

class PreRegistrationScreen extends StatefulWidget {
  final VoidCallback? onEmailSignup;
  final VoidCallback? onGoogleSignup;
  final Map<String, String>? personalityData; // Add this
  final Map<String, String>? identityData;

  const PreRegistrationScreen({
    Key? key,
    this.onEmailSignup,
    this.onGoogleSignup,
    this.personalityData, // Add this
    this.identityData,
  }) : super(key: key);

  @override
  _PreRegistrationScreenState createState() => _PreRegistrationScreenState();
}

class _PreRegistrationScreenState extends State<PreRegistrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _swipeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _swipeAnimation;
  late PreRegistrationController _controller;

  double _dragOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    _controller = PreRegistrationController(
      context: context,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      personalityData: widget.personalityData, // ADD THIS LINE
      identityData: widget.identityData,
    );

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _swipeAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) {
      setState(() {
        _isDragging = true;
      });
    }

    final newOffset = _dragOffset + details.delta.dx;
    if (newOffset >= 0) {
      setState(() {
        _dragOffset = newOffset.clamp(0.0, MediaQuery.of(context).size.width);
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_dragOffset > threshold || (details.primaryVelocity ?? 0) > 500) {
      _swipeAnimationController.forward().then((_) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                InitialOnboardingScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      });
    } else {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InitialOnboardingScreen(),
        AnimatedBuilder(
          animation: _swipeAnimationController,
          builder: (context, child) {
            final swipeOffset =
                _swipeAnimation.value.dx * MediaQuery.of(context).size.width;
            final manualOffset = _dragOffset;
            final totalOffset = swipeOffset + manualOffset;

            return Transform.translate(
              offset: Offset(totalOffset, 0),
              child: GestureDetector(
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: const Color(0xFFF5F0E8),
                  child: Scaffold(
                    backgroundColor: const Color(0xFFF5F0E8),
                    body: Stack(
                      children: [
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32.0, vertical: 40.0),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Column(
                                  children: [
                                    if (_isDragging || _dragOffset > 0)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_back_ios,
                                              color: Colors.black54,
                                              size: 16,
                                            ),
                                            Text(
                                              'Swipe to start over',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const Spacer(flex: 2),
                                    _buildLogo(),
                                    const SizedBox(height: 80),
                                    _buildSuccessMessage(),
                                    const Spacer(flex: 3),
                                    _buildSignUpButtons(),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Loading overlay
                        if (_controller.isLoading)
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 800),
      curve: Curves.easeOut,
      child: Text(
        'circle',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: Colors.black,
          letterSpacing: -1.5,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      child: Column(
        children: [
          Text(
            'A table with 5 other participants was found!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButtons() {
    return Column(
      children: [
        _buildSignUpButton(
          onTap: _controller.isLoading
              ? null
              : () => _controller.handleGoogleSignUp(),
          backgroundColor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey.shade300,
          icon: _buildGoogleIcon(),
          text: 'Sign up with Google',
        ),
        const SizedBox(height: 16),
        _buildSignUpButton(
          onTap: _controller.isLoading ? null : widget.onEmailSignup,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          borderColor: Colors.black,
          icon: Icon(
            Icons.email_outlined,
            color: Colors.white,
            size: 20,
          ),
          text: 'Sign up with e-mail',
        ),
      ],
    );
  }

  Widget _buildSignUpButton({
    required VoidCallback? onTap,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required Widget icon,
    required String text,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            side: BorderSide(color: borderColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    paint.color = Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      -90 * 3.14159 / 180,
      90 * 3.14159 / 180,
      true,
      paint,
    );

    paint.color = Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      0,
      90 * 3.14159 / 180,
      true,
      paint,
    );

    paint.color = Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      90 * 3.14159 / 180,
      90 * 3.14159 / 180,
      true,
      paint,
    );

    paint.color = Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      180 * 3.14159 / 180,
      90 * 3.14159 / 180,
      true,
      paint,
    );

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.4, paint);

    paint.color = Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - radius * 0.2,
        radius * 0.6,
        radius * 0.4,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
