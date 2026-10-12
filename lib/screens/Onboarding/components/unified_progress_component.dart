// lib/screens/Onboarding/components/unified_progress_component.dart
import 'package:flutter/material.dart';

class UnifiedProgressComponent extends StatefulWidget {
  final int totalPersonalityQuestions;
  final int answeredPersonalityQuestions;
  final int totalIdentityQuestions;
  final int answeredIdentityQuestions;
  final bool showGradient;

  const UnifiedProgressComponent({
    Key? key,
    required this.totalPersonalityQuestions,
    required this.answeredPersonalityQuestions,
    required this.totalIdentityQuestions,
    required this.answeredIdentityQuestions,
    this.showGradient = false,
  }) : super(key: key);

  @override
  _UnifiedProgressComponentState createState() =>
      _UnifiedProgressComponentState();
}

class _UnifiedProgressComponentState extends State<UnifiedProgressComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _lastProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    final initialProgress = _calculateProgress();
    _lastProgress = initialProgress;

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: initialProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(UnifiedProgressComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newProgress = _calculateProgress();
    final oldProgress = _calculateOldProgress(oldWidget);

    // Check if ANY of the input values changed, not just the calculated progress
    final valuesChanged = widget.answeredPersonalityQuestions !=
            oldWidget.answeredPersonalityQuestions ||
        widget.totalPersonalityQuestions !=
            oldWidget.totalPersonalityQuestions ||
        widget.answeredIdentityQuestions !=
            oldWidget.answeredIdentityQuestions ||
        widget.totalIdentityQuestions != oldWidget.totalIdentityQuestions;

    // Update if progress changed OR if any input values changed
    if ((newProgress - oldProgress).abs() > 0.001 || valuesChanged) {
      print('Progress update triggered:');
      print('- Old progress: $oldProgress');
      print('- New progress: $newProgress');
      print('- Values changed: $valuesChanged');
      _updateProgressAnimation(newProgress);
      _lastProgress = newProgress;
    }
  }

  double _calculateOldProgress(UnifiedProgressComponent oldWidget) {
    final totalQuestions =
        oldWidget.totalPersonalityQuestions + oldWidget.totalIdentityQuestions;
    final answeredQuestions = oldWidget.answeredPersonalityQuestions +
        oldWidget.answeredIdentityQuestions;

    if (totalQuestions == 0) return 0.0;
    return (answeredQuestions / totalQuestions).clamp(0.0, 1.0);
  }

  void _updateProgressAnimation(double targetProgress) {
    // Reset controller to 0 and create new animation from current value to target
    _animationController.reset();

    _progressAnimation = Tween<double>(
      begin: _lastProgress,
      end: targetProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  double _calculateProgress() {
    final totalQuestions =
        widget.totalPersonalityQuestions + widget.totalIdentityQuestions;
    final answeredQuestions =
        widget.answeredPersonalityQuestions + widget.answeredIdentityQuestions;

    if (totalQuestions == 0) return 0.0;
    return (answeredQuestions / totalQuestions).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.pink],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
