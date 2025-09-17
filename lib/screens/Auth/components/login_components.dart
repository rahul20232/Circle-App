// lib/screens/Auth/login_components.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Auth/controllers/login_controller.dart';
import '../register_screen.dart';

class LoginComponents {
  final LoginController controller;

  LoginComponents({required this.controller});

  Widget buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.login,
          size: 64,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: 24),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
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
      hintText: 'Enter your password',
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
              borderSide: BorderSide(
                  color: Colors
                      .blue), // Using a fixed color since we don't have context here
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading
            ? null
            : () => controller.loginWithEmail(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
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
                'Sign In',
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

  Widget buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterScreen()),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(color: Theme.of(context).primaryColor),
        ),
        child: Text(
          'Create New Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
