// lib/screens/Auth/register_components.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Auth/controllers/register_controller.dart';

class RegisterComponents {
  final RegisterController controller;

  RegisterComponents({required this.controller});

  Widget buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.person_add,
          size: 64,
          color: Colors.green.shade600,
        ),
        SizedBox(height: 24),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Join us today',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget buildNameInput() {
    return _buildInputField(
      label: 'Full Name',
      controller: controller.nameController,
      hintText: 'Enter your full name',
      prefixIcon: Icons.person_outline,
    );
  }

  Widget buildEmailInput() {
    return _buildInputField(
      label: 'Email',
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      hintText: 'Enter your email',
      prefixIcon: Icons.email_outlined,
    );
  }

  Widget buildPasswordInput() {
    return _buildInputField(
      label: 'Password',
      controller: controller.passwordController,
      obscureText: true,
      hintText: 'Create a password',
      prefixIcon: Icons.lock_outline,
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green.shade600),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading
            ? null
            : () => controller.registerWithEmail(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: controller.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  // Commented out Google Sign-In Button for future use
  // Widget buildGoogleSignInButton(BuildContext context) {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: OutlinedButton.icon(
  //       onPressed: controller.isLoading ? null : () => controller.signInWithGoogle(context),
  //       icon: Icon(Icons.login, color: Colors.red.shade600),
  //       label: Text(
  //         'Continue with Google',
  //         style: TextStyle(
  //           color: Colors.red.shade600,
  //           fontWeight: FontWeight.w500,
  //           fontSize: 16,
  //         ),
  //       ),
  //       style: OutlinedButton.styleFrom(
  //         padding: EdgeInsets.symmetric(vertical: 16),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         side: BorderSide(color: Colors.red.shade600),
  //       ),
  //     ),
  //   );
  // }

  Widget buildBackToLoginButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () => controller.navigateToLogin(context),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
