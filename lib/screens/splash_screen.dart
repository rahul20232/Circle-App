// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Only fade out the logo, not the background
    _logoFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      await _controller.forward();
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedBuilder(
            animation: _logoFadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _logoFadeAnimation.value,
                // Wordmark: serif "circle" with a terracotta full stop.
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 72,
                      fontFamily: AppFonts.serif,
                      color: AppColors.ink,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                    children: [
                      TextSpan(text: 'circle'),
                      TextSpan(text: '.', style: TextStyle(color: AppColors.accent)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
