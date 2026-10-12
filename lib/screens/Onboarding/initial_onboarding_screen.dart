// lib/screens/Onboarding/initial_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'dart:ui';
import 'package:circle_app/components/Modals/onboarding_modal.dart';
import 'package:circle_app/screens/Onboarding/onboarding_flow.dart';
import 'package:circle_app/screens/Auth/login_screen.dart';
import 'package:circle_app/services/onboarding_state_service.dart';

class InitialOnboardingScreen extends StatefulWidget {
  final bool clearProgress;

  const InitialOnboardingScreen({
    Key? key,
    this.clearProgress = false,
  }) : super(key: key);

  @override
  _InitialOnboardingScreenState createState() =>
      _InitialOnboardingScreenState();
}

class _InitialOnboardingScreenState extends State<InitialOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.clearProgress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        OnboardingStateService.clearAllData();
      });
    }
  }

  void _showContinuationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) => OnboardingModal(
        onContinue: () async {
          Navigator.of(context).pop();
          await _continueOnboarding();
        },
        onRestart: () async {
          Navigator.of(context).pop();
          await _restartOnboarding();
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _continueOnboarding() async {
    final savedData = await OnboardingStateService.getSavedData();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OnboardingFlow(
          initialPersonalityData: savedData['personalityData'],
          initialIdentityData: savedData['identityData'],
          initialStep: savedData['currentStep'],
        ),
      ),
    );
  }

  Future<void> _restartOnboarding() async {
    await OnboardingStateService.clearAllData();
    _startFreshOnboarding();
  }

  void _startFreshOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OnboardingFlow(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.grey300,
                  child: Icon(Icons.people,
                      size: 100, color: AppColors.grey400),
                );
              },
            ),
          ),

          // Gradient overlay for better text visibility at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.ink.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom content with blur effect
          // Replace the entire bottom content section in your build method:

// Bottom content with extended blur effect
          // Bottom content with proper blur layers
          // Bottom content with minimal blur
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Very subtle blur zone - only at the bottom
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Single light blur layer
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 150, // Increased from 120
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.surface.withOpacity(0.3),
                                AppColors.surface.withOpacity(0.5),
                                AppColors.surface.withOpacity(0.7),
                                AppColors.surface.withOpacity(0.85),
                                AppColors.surface,
                              ],
                              stops: [0.0, 0.4, 0.6, 0.75, 0.9, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Text overlaid
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Your weekly dose of\ntogetherness.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontFamily: AppFonts.serif, fontWeight: FontWeight.w400,
                              color: AppColors.ink,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Solid white buttons section
                Container(
                  color: AppColors.surface,
                  padding: EdgeInsets.fromLTRB(32, 24, 32, 40),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _startOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ink,
                            foregroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Get started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            foregroundColor: AppColors.ink,
                            side: BorderSide(
                                color: AppColors.grey300, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'I already have an account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey600,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: 'By signing up you agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: AppColors.grey700,
                              ),
                            ),
                            TextSpan(text: ', '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: AppColors.grey700,
                              ),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Community Guidelines',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: AppColors.grey700,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startOnboarding() async {
    print('Checking for existing progress...');
    final hasProgress = await OnboardingStateService.hasProgress();
    print('Has progress: $hasProgress');

    if (hasProgress) {
      _showContinuationModal();
    } else {
      _startFreshOnboarding();
    }
  }
}
