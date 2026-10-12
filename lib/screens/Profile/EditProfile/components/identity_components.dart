// lib/screens/Profile/EditProfile/identity_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/EditProfile/controllers/identity_controller.dart';
import 'package:circle_app/components/Cards/IdentityCard.dart';

class IdentityComponents {
  final IdentityController controller;

  IdentityComponents({required this.controller});

  Widget buildQuestionText(String question) {
    return Center(
      child: Text(
        question,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildOptionsList(BuildContext context, String question) {
    final options = controller.getOptionsForQuestion(question);

    if (options.isEmpty) {
      return buildEmptyState(question);
    }

    return Expanded(
      child: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final text = options[index];
          return Identitycard(
            text: text,
            isSelected: controller.isSelected(text),
            onTap: () => controller.handleOptionTap(context, text),
          );
        },
      ),
    );
  }

  Widget buildEmptyState(String question) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 64,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16),
            Text(
              'No options available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This question type is not supported yet.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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

  Widget buildQuestionWithCategory(String question) {
    final category = controller.getQuestionCategory(question);

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
        buildQuestionText(question),
      ],
    );
  }

  Widget buildProgressIndicator(int selectedIndex, int totalOptions) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalOptions,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 2),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  index <= selectedIndex ? AppColors.ink : AppColors.grey300,
            ),
          ),
        ),
      ),
    );
  }
}
