// lib/screens/Account/account_details_components.dart
import 'package:flutter/material.dart';
import 'package:circle_app/screens/Profile/EditProfile/controllers/account_details_controller.dart';

class AccountDetailsComponents {
  final AccountDetailsController controller;

  AccountDetailsComponents({required this.controller});

  Widget buildQuestionText(String question) {
    return Text(
      question,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget buildInputField(TextInputType inputType, {String? prefixText}) {
    return TextField(
      controller: controller.textController,
      keyboardType: inputType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget buildConfirmButton(
    BuildContext context,
    String buttonText, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              controller.isButtonEnabled ? Colors.black : Colors.grey.shade400,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          minimumSize: const Size(double.infinity, 55),
          elevation: controller.isButtonEnabled ? 2 : 0,
        ),
        onPressed: controller.isButtonEnabled ? onPressed : null,
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildValidationMessage(String message, {bool isError = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red.shade600 : Colors.green.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red.shade700 : Colors.green.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputWithValidation(
    TextInputType inputType, {
    String? validationMessage,
    bool showValidation = false,
    String? prefixText,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildInputField(inputType, prefixText: prefixText),
        if (showValidation && validationMessage != null) ...[
          const SizedBox(height: 8),
          buildValidationMessage(validationMessage),
        ],
        if (helpText != null) ...[
          const SizedBox(height: 8),
          buildHelpText(helpText),
        ],
      ],
    );
  }

  Widget buildHelpText(String helpText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              helpText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New responsive layout widget
  Widget buildResponsiveLayout({
    required BuildContext context,
    required String question,
    required TextInputType inputType,
    required String buttonText,
    required VoidCallback onButtonPressed,
    String? validationMessage,
    String? helpText,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildQuestionText(question),
        const SizedBox(height: 20),

        buildInputWithValidation(
          inputType,
          validationMessage: validationMessage,
          showValidation: validationMessage != null,
          prefixText: prefixText,
          helpText: helpText,
        ),

        const Spacer(),

        // Button with keyboard-aware padding
        Padding(
          padding: const EdgeInsets.only(
            bottom: 20,
          ),
          child: buildConfirmButton(
            context,
            buttonText,
            onPressed: onButtonPressed,
          ),
        ),
      ],
    );
  }

  // Widget for building the entire screen with SafeArea
  Widget buildScreenLayout({
    required BuildContext context,
    required String question,
    required TextInputType inputType,
    required String buttonText,
    required VoidCallback onButtonPressed,
    String? validationMessage,
    String? helpText,
    String? prefixText,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: buildResponsiveLayout(
          context: context,
          question: question,
          inputType: inputType,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
          validationMessage: validationMessage,
          helpText: helpText,
          prefixText: prefixText,
        ),
      ),
    );
  }
}
