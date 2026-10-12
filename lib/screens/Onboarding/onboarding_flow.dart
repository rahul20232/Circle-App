// Updated section of lib/screens/Onboarding/onboarding_flow.dart
import 'package:flutter/material.dart';
import 'package:circle_app/screens/Onboarding/personality_screen.dart';
import 'package:circle_app/screens/Onboarding/middle_screen.dart';
import 'package:circle_app/screens/Onboarding/onboarding_identity_screen.dart';
import 'package:circle_app/screens/Auth/login_screen.dart';
import 'package:circle_app/screens/Onboarding/initial_onboarding_screen.dart';
import 'package:circle_app/screens/Onboarding/onboarding_account_screen.dart';
import 'package:circle_app/screens/Onboarding/pre_registration_screen.dart';
import 'package:circle_app/services/onboarding_state_service.dart';

class OnboardingFlow extends StatefulWidget {
  final Map<String, String>? initialPersonalityData;
  final Map<String, String>? initialIdentityData;
  final int? initialStep;

  OnboardingFlow({
    this.initialPersonalityData,
    this.initialIdentityData,
    this.initialStep,
  });

  @override
  _OnboardingFlowState createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  Map<String, String> _personalityData = {};
  Map<String, String> _identityData = {};
  late PageController _pageController;

  // Store the screen states
  GlobalKey<PersonalityScreenState> _personalityScreenKey =
      GlobalKey<PersonalityScreenState>();
  GlobalKey<OnboardingIdentityScreenState> _identityScreenKey =
      GlobalKey<OnboardingIdentityScreenState>();

  // Define onboarding steps
  final List<String> _stepTitles = [
    'Personality Assessment',
    'Statistics',
    'Identity Assessment',
    'Pre-Registration',
    'Create Account',
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep ?? 0;
    _personalityData = widget.initialPersonalityData ?? {};
    _identityData = widget.initialIdentityData ?? {};

    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      OnboardingStateService.saveCurrentStep(_currentStep);
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handlePersonalityComplete(Map<String, String> personalityResponses) {
    _personalityData = personalityResponses;
    OnboardingStateService.savePersonalityData(_personalityData);
    OnboardingStateService.saveCurrentStep(1);
    _nextStep();
  }

  void _handleMiddleScreenNext() {
    print('Middle screen completed, proceeding to identity assessment');
    _nextStep();
  }

  void _handleMiddleScreenBack() {
    print('Middle screen back pressed, going to personality screen');
    _previousStep();
  }

  void _handleIdentityComplete(Map<String, String> identityResponses) {
    _identityData = identityResponses;
    OnboardingStateService.saveIdentityData(_identityData);
    OnboardingStateService.saveCurrentStep(3);
    _nextStep();
  }

  void _handlePreRegistrationEmailSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OnboardingAccountScreen(
          onCompleteWithData: _handleAccountComplete,
          onBack: () => Navigator.of(context).pop(),
          personalityData: _personalityData,
          identityData: _identityData,
        ),
      ),
    );
  }

  void _handleAccountComplete(Map<String, String> accountData) {
    print('Account creation complete: $accountData');
    Navigator.of(context).pop(); // Close account screen
    _nextStep(); // Proceed to final registration step
  }

  void _handlePhoneComplete(String phoneNumber) {
    print('Phone number collected: $phoneNumber');
    // Now proceed to registration
    Navigator.of(context).pop(); // Close phone screen
    _nextStep(); // Go to registration step
  }

  void _handlePreRegistrationGoogleSignup() {
    print('Google signup selected');
    // TODO: Implement Google signup logic
    // For now, proceed to registration
    _nextStep();
  }

  void _handleSwipeToStart() {
    print('Swiped to return to initial onboarding screen');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => InitialOnboardingScreen(),
      ),
    );
  }

  void _handlePersonalityBack() {
    print('Personality screen back pressed, going to initial screen');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            InitialOnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from left (reverse direction)
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          _previousStep();
          return false;
        }
        return true;
      },
      child: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable swipe navigation
        children: [
          // Step 0: Personality Assessment
          PersonalityScreen(
            key: _personalityScreenKey,
            onCompleteWithData: _handlePersonalityComplete,
            onBack: _handlePersonalityBack,
            personalityData: _personalityData,
            totalIdentityQuestions: 5, // Updated to include birthday question
          ),

          // Step 1: Statistics Screen
          MiddleScreen(
            onNext: _handleMiddleScreenNext,
            onBack: _handleMiddleScreenBack,
          ),

          // Step 2: Identity Assessment
          OnboardingIdentityScreen(
            key: _identityScreenKey,
            onCompleteWithData: _handleIdentityComplete,
            identityData: _identityData,
            personalityData: _personalityData,
          ),

          // Step 3: Pre-Registration Success Screen
          PreRegistrationScreen(
            onEmailSignup: _handlePreRegistrationEmailSignup,
            onGoogleSignup: _handlePreRegistrationGoogleSignup,
            personalityData: _personalityData, // Pass personality data
            identityData: _identityData,
          ),

          // Step 4: Registration
          LoginScreen(
            onClose: () {
              // Navigate back to initial onboarding screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => InitialOnboardingScreen(),
                ),
                (route) => false, // Remove all previous routes
              );
            },
          ),
        ],
      ),
    );
  }
}
