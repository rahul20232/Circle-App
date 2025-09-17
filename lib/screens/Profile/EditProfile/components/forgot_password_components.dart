// lib/screens/Auth/forgot_password_components.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/controllers/forgot_password_controller.dart';
import '../reset_password_screen.dart';

class ForgotPasswordComponents {
  final ForgotPasswordController controller;

  ForgotPasswordComponents({required this.controller});

  Widget buildInstructionText() {
    return const Text(
      "We will send a password reset link to your email",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget buildEmailField() {
    return TextField(
      readOnly: true,
      controller: controller.emailController,
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
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget buildSendResetButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            controller.isButtonEnabled ? Colors.black : Colors.grey.shade400,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        minimumSize: const Size(double.infinity, 55),
        elevation: controller.isButtonEnabled ? 2 : 0,
      ),
      onPressed: controller.isButtonEnabled
          ? () => controller.sendPasswordResetEmail(context)
          : null,
      child: controller.isButtonEnabled
          ? const Text(
              "Send reset link",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Sending...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildSuccessOverlay(BuildContext context) {
    return Positioned(
      top: 140,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "A reset link has been sent to your email.",
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _navigateToResetScreen(context),
                  child: Text(
                    "Enter reset token manually",
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => controller.retrySendEmail(context),
                  child: Text(
                    "Resend",
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHelpText() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade600,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Check your spam folder if you don't receive the email within a few minutes.",
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

  Widget buildEmailPreview() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.email,
            color: Colors.blue.shade600,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Reset link will be sent to:",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToResetScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(),
      ),
    );
  }

  // Helper widget for building status messages
  // Widget buildStatusMessage({
  //   required String message,
  //   required IconData icon,
  //   required Color color,
  //   VoidCallback? onAction,
  //   String? actionText,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: color.withOpacity(0.3)),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(icon, color: color, size: 20),
  //         SizedBox(width: 8),
  //         Expanded(
  //           child: Text(
  //             message,
  //             style: TextStyle(
  //               color: color.shade700,
  //               fontSize: 14,
  //             ),
  //           ),
  //         ),
  //         if (onAction != null && actionText != null)
  //           TextButton(
  //             onPressed: onAction,
  //             child: Text(
  //               actionText,
  //               style: TextStyle(
  //                 color: color.shade700,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }
}
