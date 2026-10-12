// Updated personality_screen.dart
// lib/screens/Onboarding/personality_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Onboarding/controllers/personality_controller.dart';
import 'package:timeleft_clone/screens/Onboarding/components/personality_components.dart';
import 'package:timeleft_clone/screens/Onboarding/components/unified_progress_component.dart';

class PersonalityScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final Function(Map<String, String>)? onCompleteWithData;
  final VoidCallback? onBack;
  final Map<String, String>? personalityData;
  final Map<String, String>? identityData;
  final int totalIdentityQuestions; // Add this parameter

  const PersonalityScreen({
    Key? key,
    this.onComplete,
    this.onCompleteWithData,
    this.onBack,
    this.personalityData,
    this.identityData,
    this.totalIdentityQuestions =
        5, // Default value based on your identity questions
  }) : super(key: key);

  @override
  PersonalityScreenState createState() => PersonalityScreenState();
}

class PersonalityScreenState extends State<PersonalityScreen>
    with TickerProviderStateMixin {
  late PersonalityController _controller;
  late PersonalityComponents _components;

  @override
  void initState() {
    super.initState();

    _controller = PersonalityController(
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    // Restore previous state if data exists
    if (widget.personalityData != null && widget.personalityData!.isNotEmpty) {
      _controller.restoreState(widget.personalityData!);
    }

    _components = PersonalityComponents(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleComplete() {
    final personalityResults = _controller.getSummary();

    print('Personality Assessment Complete!');
    print('Results: $personalityResults');

    if (widget.onCompleteWithData != null) {
      widget.onCompleteWithData!(personalityResults);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.psychology, color: Colors.purple, size: 28),
            SizedBox(width: 12),
            Text('Personality Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your personality profile has been saved. Here\'s what we learned:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ..._controller
                .getSummary()
                .entries
                .map((entry) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: '${entry.key}\n',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                    text: int.tryParse(entry.value) != null
                                        ? '${entry.value}/10'
                                        : entry.value,
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onComplete?.call();
            },
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRatingScale = _controller.currentQuestionType == 'rating_scale';
    final backgroundColor = const Color(0xFFFEF1DE);

    print('Building PersonalityScreen:');
    print('- Current index: ${_controller.currentQuestionIndex}');
    print('- Total questions: ${_controller.totalQuestions}');
    print('- Answered questions: ${_controller.personalityResponses.length}');
    print(
        '- Progress calculation: ${_controller.personalityResponses.length / _controller.totalQuestions}');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Personality',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            print('Back button pressed');
            if (_controller.isFirstQuestion) {
              // Call the callback to go back to initial screen
              widget.onBack?.call();
            } else if (!_controller.isAnimating) {
              // Go to previous question within personality assessment
              print('Not animating, calling goToPreviousQuestion');
              _controller.goToPreviousQuestion();
            } else {
              print('Currently animating, ignoring back press');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isRatingScale ? 24 : 30),
          child: Column(
            children: [
              // Unified Progress bar
              UnifiedProgressComponent(
                totalPersonalityQuestions: _controller.totalQuestions,
                answeredPersonalityQuestions:
                    _controller.personalityResponses.length,
                totalIdentityQuestions: widget.totalIdentityQuestions,
                answeredIdentityQuestions: widget.identityData?.length ??
                    0, // Use actual identity data
                showGradient: isRatingScale,
              ),
              SizedBox(height: isRatingScale ? 60 : 40),

              // Animated Question text
              _components.buildQuestionText(),
              SizedBox(height: isRatingScale ? 60 : 40),

              // Dynamic question content
              _components.buildQuestionContent(context, _handleComplete),
            ],
          ),
        ),
      ),
    );
  }
}
