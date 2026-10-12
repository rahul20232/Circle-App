// lib/screens/Profile/Settings/delete_account_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/Settings/controllers/delete_account_controller.dart';

class DeleteAccountComponents {
  final DeleteAccountController controller;

  DeleteAccountComponents({required this.controller});

  Widget buildWarningSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dangerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: AppColors.danger),
              const SizedBox(width: 8),
              Text(
                "Warning",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "This action cannot be undone. Deleting your account will permanently remove:\n\n• Your profile and all personal information\n• Your booking history\n• Your preferences and settings\n• All associated data",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.danger,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordField() {
    // Don't show password field for Google users
    if (controller.isGoogleUser) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter your password to confirm:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller.passwordController,
          obscureText: !controller.showPassword,
          decoration: InputDecoration(
            hintText: "Password",
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.ink),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.showPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: AppColors.grey600,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildConfirmationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type "delete my account" to confirm:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller.confirmationController,
          decoration: InputDecoration(
            hintText: "delete my account",
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.ink),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDeleteButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () => controller.deleteAccount(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: controller.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : Text(
                      "Delete Account Permanently",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surface,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildValidationMessage(String message, {bool isError = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isError ? AppColors.dangerSoft : AppColors.successSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? AppColors.dangerSoft : AppColors.successSoft,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppColors.danger : AppColors.success,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? AppColors.danger : AppColors.success,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSecurityInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.infoSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              SizedBox(width: 8),
              Text(
                'Security Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Account deletion requires your password for security verification. This ensures only you can delete your account.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFieldWithValidation({
    required Widget field,
    String? validationMessage,
    bool showValidation = false,
  }) {
    return Column(
      children: [
        field,
        if (showValidation && validationMessage != null) ...[
          SizedBox(height: 8),
          buildValidationMessage(validationMessage),
        ],
      ],
    );
  }

  Widget buildConfirmationStatus() {
    final isCorrect = controller.isConfirmationTextCorrect;
    final hasInput = controller.hasConfirmationInput;

    if (!hasInput) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? AppColors.success : AppColors.danger,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            isCorrect
                ? 'Confirmation text is correct'
                : 'Please type exactly: "${controller.requiredConfirmationText}"',
            style: TextStyle(
              color: isCorrect ? AppColors.success : AppColors.danger,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDeleteConfirmationDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(
        'Final Confirmation',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.danger,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you absolutely sure you want to delete your account?',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            'This will permanently delete all your data and cannot be reversed.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            controller.deleteAccount(context);
          },
          child: Text(
            'Delete Forever',
            style: TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
