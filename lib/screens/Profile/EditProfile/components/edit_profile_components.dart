// lib/screens/Profile/EditProfile/edit_profile_components.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/controllers/edit_profile_controller.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/account_details_screen.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/forgot_password_screen.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/identity_screen.dart';
import 'package:timeleft_clone/models/user_model.dart';

class EditProfileComponents {
  final EditProfileController controller;

  EditProfileComponents({required this.controller});

  Widget buildProfilePicture(BuildContext context, AppUser user) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: controller.profileImage != null
              ? FileImage(controller.profileImage!)
              : user.profilePictureUrl != null
                  ? NetworkImage(user.profilePictureUrl!)
                  : null,
          child:
              controller.profileImage == null && user.profilePictureUrl == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey.shade800)
                  : null,
        ),
        InkWell(
          onTap: controller.isUploadingImage
              ? null
              : () => controller.pickAndUploadImage(context),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: controller.isUploadingImage
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 16,
                  ),
          ),
        ),
      ],
    );
  }

  Widget buildBasicInfoSection(BuildContext context, AppUser user) {
    return Column(
      children: [
        buildSectionTitle("Basic Info"),
        buildEditableField(
          context,
          "First name",
          controller.nameController,
          user,
        ),
        buildStaticField("Email", user.email),
        buildEditableField(
          context,
          "Password",
          TextEditingController(text: "********"),
          user,
          isPassword: true,
        ),
        buildEditableField(
          context,
          "Phone number",
          controller.phoneController,
          user,
        ),
      ],
    );
  }

  Widget buildIdentitySection(BuildContext context, AppUser user) {
    return Column(
      children: [
        buildSectionTitle("Identity"),
        buildStaticField("How do you define yourself?", "Man"),
        buildIdentityField(
          context,
          "What is your relationship status?",
          controller.getIdentityValue("What is your relationship status?"),
        ),
        buildIdentityField(
          context,
          "Do you have children?",
          controller.getIdentityValue("Do you have children?"),
        ),
        buildIdentityField(
          context,
          "If you're working, what industry do you...",
          controller
              .getIdentityValue("If you're working, what industry do you..."),
        ),
        buildIdentityField(
          context,
          "What country are you from?",
          controller.getIdentityValue("What country are you from?"),
        ),
        buildStaticField("When is your birthday?", "1/1/2001"),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 20),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget buildEditableField(
    BuildContext context,
    String label,
    TextEditingController fieldController,
    AppUser user, {
    bool isPassword = false,
  }) {
    return GestureDetector(
      onTap: () =>
          _handleEditableFieldTap(context, label, fieldController, user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Text(
                "$label\n${fieldController.text}",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget buildIdentityField(BuildContext context, String label, String value) {
    return GestureDetector(
      onTap: () => _handleIdentityFieldTap(context, label, value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Text(
                "$label\n${value.isEmpty ? 'Not set' : value}",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget buildStaticField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label\n$value",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEditableFieldTap(
    BuildContext context,
    String label,
    TextEditingController fieldController,
    AppUser user,
  ) async {
    if (label == "Password") {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotPasswordScreen(email: user.email),
        ),
      );
    } else if (label == "First name" || label == "Phone number") {
      String? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccountDetailsScreen(
            title: "Account",
            question: _getQuestionForLabel(label),
            initialValue: fieldController.text,
            buttonText: "Confirm",
            inputType: controller.getInputTypeForLabel(label),
          ),
        ),
      );

      if (result != null) {
        bool success = await controller.updateBasicInfo(label, result);
        if (!success) {
          _showSnackBar(context, 'Failed to update $label');
        }
      }
    }
  }

  Future<void> _handleIdentityFieldTap(
    BuildContext context,
    String label,
    String currentValue,
  ) async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IdentityScreen(
          title: "Identity",
          question: label,
          initialValue: currentValue,
        ),
      ),
    );

    if (result != null) {
      // Update the field optimistically
      controller.updateIdentityField(label, result);

      // Try to save to backend
      bool success = await controller.saveIdentityPreferences();
      if (!success) {
        // Revert on failure
        controller.revertIdentityField(label, currentValue);
        _showSnackBar(context, 'Failed to save preferences');
      }
    }
  }

  String _getQuestionForLabel(String label) {
    switch (label) {
      case "First name":
        return "What's your first name?";
      case "Phone number":
        return "What's your phone number?";
      case "Password":
        return "Forgot password?";
      default:
        return label;
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Helper widget for loading states
  Widget buildLoadingOverlay({required bool isLoading, required Widget child}) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  // Helper widget for field groups
  Widget buildFieldGroup({
    required String title,
    required List<Widget> fields,
  }) {
    return Column(
      children: [
        buildSectionTitle(title),
        ...fields,
      ],
    );
  }
}
