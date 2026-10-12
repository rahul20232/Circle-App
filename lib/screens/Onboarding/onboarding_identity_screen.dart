// lib/screens/Onboarding/onboarding_identity_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Onboarding/controllers/onboarding_identity_controller.dart';
import 'package:circle_app/screens/Onboarding/components/onboarding_identity_components.dart';
import 'package:circle_app/screens/Onboarding/components/unified_progress_component.dart';

class OnboardingIdentityScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(Map<String, String>)? onCompleteWithData;
  final Map<String, String>? identityData;
  final Map<String, String>? personalityData;

  const OnboardingIdentityScreen({
    Key? key,
    this.onComplete,
    this.onCompleteWithData,
    this.identityData,
    this.personalityData,
  }) : super(key: key);

  @override
  OnboardingIdentityScreenState createState() =>
      OnboardingIdentityScreenState();
}

class OnboardingIdentityScreenState extends State<OnboardingIdentityScreen>
    with TickerProviderStateMixin {
  late OnboardingIdentityController _controller;
  late OnboardingIdentityComponents _components;

  @override
  void initState() {
    super.initState();

    final personalityData = widget.personalityData ?? {};
    final personalityQuestionsCount = 21;
    final personalityAnsweredCount = personalityData.length;

    _controller = OnboardingIdentityController(
      initialData: widget.identityData ?? {},
      personalityQuestionsCount: personalityQuestionsCount,
      personalityAnsweredCount: personalityAnsweredCount,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    _components = OnboardingIdentityComponents(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleComplete() {
    final identityResults = _controller.getAllResponses();

    print('Identity Assessment Complete!');
    print('Results: $identityResults');

    if (widget.onCompleteWithData != null) {
      widget.onCompleteWithData!(identityResults);
    } else if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalityData = widget.personalityData ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Identity',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
        leading: _controller.isFirstQuestion
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                onPressed: _controller.goToPreviousQuestion,
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Unified Progress indicator
            UnifiedProgressComponent(
              totalPersonalityQuestions: 21,
              answeredPersonalityQuestions: personalityData.length,
              totalIdentityQuestions: _controller.totalQuestions,
              answeredIdentityQuestions: _controller.identityResponses.length,
              showGradient: false,
            ),
            const SizedBox(height: 30),

            // Question text
            _components.buildQuestionText(),
            const SizedBox(height: 30),

            // Dynamic content (options list or date picker)
            _components.buildQuestionContent(context, _handleComplete),

            // // Navigation buttons only show for manual navigation on non-auto-advance questions
            // if (!_controller.isLastQuestion &&
            //     _controller.hasAnsweredCurrent &&
            //     !_controller.isCurrentQuestionDatePicker)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 20),
            //     child: _components.buildNextButton(_handleComplete),
            //   ),
          ],
        ),
      ),
    );
  }
}
