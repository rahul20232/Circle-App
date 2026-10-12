// lib/screens/Onboarding/components/onboarding_identity_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:circle_app/screens/Onboarding/controllers/onboarding_identity_controller.dart';
import 'package:circle_app/components/Cards/IdentityCard.dart';

class OnboardingIdentityComponents {
  final OnboardingIdentityController controller;

  OnboardingIdentityComponents({required this.controller});

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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          controller.currentQuestion,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontFamily: AppFonts.serif, fontWeight: FontWeight.w400,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget buildQuestionContent(BuildContext context, VoidCallback? onComplete) {
    if (controller.isCurrentQuestionDatePicker) {
      return buildDatePicker(context, onComplete);
    } else {
      return buildOptionsList(context, onComplete);
    }
  }

  Widget buildDatePicker(BuildContext context, VoidCallback? onComplete) {
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
            const SizedBox(height: 40),
            // Date input field
            GestureDetector(
              onTap: () => _showDatePicker(context, onComplete),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: controller.hasAnsweredCurrent
                        ? AppColors.ink
                        : AppColors.grey300,
                    width: controller.hasAnsweredCurrent ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.hasAnsweredCurrent
                            ? controller.formattedBirthday ?? 'MM/DD/YYYY'
                            : 'MM/DD/YYYY',
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.hasAnsweredCurrent
                              ? AppColors.ink
                              : AppColors.grey500,
                          fontWeight: controller.hasAnsweredCurrent
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: controller.hasAnsweredCurrent
                          ? AppColors.ink
                          : AppColors.grey400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Confirm button (appears after date is selected)
            if (controller.hasAnsweredCurrent)
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.isLastQuestion) {
                        onComplete?.call();
                      } else {
                        controller.goToNextQuestion();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Confirm',
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

  void _showDatePicker(BuildContext context, VoidCallback? onComplete) {
    DateTime initialDate = DateTime.now()
        .subtract(Duration(days: 365 * 25)); // Default to 25 years ago
    DateTime minimumDate =
        DateTime.now().subtract(Duration(days: 365 * 100)); // 100 years ago
    DateTime maximumDate = DateTime.now()
        .subtract(Duration(days: 365 * 13)); // 13 years ago (minimum age)

    // Parse existing date if available
    if (controller.hasAnsweredCurrent) {
      try {
        final parts = controller.currentAnswer!.split('/');
        if (parts.length == 3) {
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          initialDate = DateTime(year, month, day);
        }
      } catch (e) {
        // Keep default date if parsing fails
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.grey200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        controller.selectDate(initialDate);

                        // If this is the last question, call onComplete after delay
                        if (controller.isLastQuestion) {
                          Future.delayed(Duration(milliseconds: 400), () {
                            onComplete?.call();
                          });
                        }
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Date picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: minimumDate,
                  maximumDate: maximumDate,
                  onDateTimeChanged: (DateTime date) {
                    initialDate = date;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
          separatorBuilder: (_, __) => const SizedBox(height: 15),
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
                    Future.delayed(Duration(milliseconds: 400), () {
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

  Widget buildProgressIndicator() {
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
      child: Column(
        key: ValueKey(controller.currentQuestionIndex),
        children: [
          // Progress bar showing unified progress across both assessments
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: controller.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
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
                ? AppColors.ink
                : AppColors.grey300,
          ),
        ),
      ),
    );
  }

  Widget buildNextButton(VoidCallback? onNext) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          controller.isLastQuestion ? 'Complete' : 'Next',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildSelectedIndicator(String selectedValue) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            selectedValue,
            style: TextStyle(
              color: AppColors.success,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuestionWithCategory() {
    final category = controller.currentCategory;

    return Column(
      children: [
        if (category != "unknown")
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.info,
              ),
            ),
          ),
        SizedBox(height: 8),
        buildQuestionText(),
      ],
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
            'Identity Complete!',
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
