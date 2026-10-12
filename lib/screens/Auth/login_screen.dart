// lib/screens/Auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Auth/controllers/login_controller.dart';
import 'package:circle_app/screens/Auth/components/login_components.dart';
import 'package:circle_app/screens/Onboarding/initial_onboarding_screen.dart';
import 'package:circle_app/screens/Profile/EditProfile/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const LoginScreen({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController _controller;
  late LoginComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = LoginController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = LoginComponents(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: AppColors.ink, size: 28),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      InitialOnboardingScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 300),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Add this
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ConstrainedBox(
              // Add this to maintain minimum height
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                // Add this
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: AppFonts.serif, fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _components.buildEmailInput(),
                    const SizedBox(height: 20),
                    _components.buildPasswordInput(),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          final email = _controller.emailController.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Please enter your email address first'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ForgotPasswordScreen(email: email),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.ink,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _components.buildSignInButton(context),
                    const SizedBox(height: 40),
                    _components.buildDivider(),
                    const SizedBox(height: 30),
                    _components.buildGoogleSignInButton(context),
                    const Spacer(), // This will push content up when needed
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
