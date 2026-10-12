// lib/screens/Onboarding/components/personality_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/components/Cards/IdentityCard.dart';
import 'package:circle_app/screens/Onboarding/controllers/personality_controller.dart';

class PersonalityComponents {
  final PersonalityController controller;

  PersonalityComponents({required this.controller});

  Widget buildQuestionText() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
      },
      child: Padding(
        key: ValueKey(controller.currentQuestionIndex),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          controller.currentQuestion,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize:
                controller.currentQuestionType == 'rating_scale' ? 26 : 24,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget buildQuestionContent(BuildContext context, VoidCallback? onComplete) {
    // Check question type and build appropriate content
    if (controller.currentQuestionType == 'rating_scale') {
      return buildRatingScale(context, onComplete);
    } else {
      return buildOptionsList(context, onComplete);
    }
  }

  Widget buildOptionsList(BuildContext context, VoidCallback? onComplete) {
    return Expanded(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.3, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            ),
          );
        },
        child: ListView.separated(
          key: ValueKey(controller.currentQuestionIndex),
          padding: EdgeInsets.zero,
          itemCount: controller.currentOptions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final option = controller.currentOptions[index];
            return AnimatedContainer(
              duration: Duration(
                  milliseconds: 200 + (index * 50)), // Staggered animation
              curve: Curves.easeOutBack,
              child: Identitycard(
                text: option,
                isSelected: controller.isSelected(option),
                onTap: () {
                  controller.selectOption(option);

                  // If this is the last question, call onComplete after delay
                  if (controller.isLastQuestion) {
                    Future.delayed(Duration(milliseconds: 300), () {
                      onComplete?.call();
                    });
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildRatingScale(BuildContext context, VoidCallback? onComplete) {
    return Expanded(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            ),
          );
        },
        child: Column(
          key: ValueKey(controller.currentQuestionIndex),
          children: [
            // Scale labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.currentLeftLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Rating buttons grid (1-5 on top row, 6-10 on bottom row)
            Column(
              children: [
                // Top row: 1-5
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final rating = index + 1;
                    return _buildRatingButton(
                      rating,
                      context,
                      onComplete,
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Bottom row: 6-10
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final rating = index + 6;
                    return _buildRatingButton(
                      rating,
                      context,
                      onComplete,
                    );
                  }),
                ),
              ],
            ),
            Expanded(
              child: Text(
                controller.currentRightLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton(
      int rating, BuildContext context, VoidCallback? onComplete) {
    final isSelected = controller.isRatingSelected(rating);

    return AnimatedContainer(
      duration:
          Duration(milliseconds: 200 + (rating * 20)), // Staggered animation
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: () {
          controller.selectRating(rating);

          // If this is the last question, call onComplete after delay
          if (controller.isLastQuestion) {
            Future.delayed(Duration(milliseconds: 300), () {
              onComplete?.call();
            });
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.ink : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.ink : AppColors.grey300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.ink.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              if (!isSelected)
                BoxShadow(
                  color: AppColors.ink.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
            ],
          ),
          child: Center(
            child: Text(
              rating.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.surface : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNavigationButtons(BuildContext context, VoidCallback? onNext) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          children: [
            // Back button with animation
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: !controller.isFirstQuestion ? null : 0,
              child: !controller.isFirstQuestion
                  ? Expanded(
                      child: OutlinedButton(
                        onPressed: controller.goToPreviousQuestion,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: AppColors.grey400),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),

            if (!controller.isFirstQuestion)
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 16,
              ),

            // Next/Continue button
            Expanded(
              flex: controller.isFirstQuestion ? 1 : 2,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: ElevatedButton(
                  key:
                      ValueKey(controller.isLastQuestion ? 'continue' : 'next'),
                  onPressed: controller.canGoNext()
                      ? () {
                          if (controller.isLastQuestion) {
                            onNext?.call();
                          } else {
                            controller.goToNextQuestion();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.surface,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    controller.isLastQuestion ? 'Continue' : 'Next',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionIndicator() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(controller.currentQuestionIndex),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${controller.currentQuestionIndex + 1} of ${controller.totalQuestions}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
      ),
    );
  }

  Widget buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.totalQuestions,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= controller.currentQuestionIndex
                ? (controller.currentQuestionType == 'rating_scale'
                    ? AppColors.warning
                    : AppColors.ink)
                : AppColors.grey300,
          ),
        ),
      ),
    );
  }

  Widget buildCompletionCard() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successSoft),
      ),
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 800),
            curve: Curves.bounceIn,
            child: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 48,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Personality Complete!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'ve answered all ${controller.totalQuestions} questions',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
