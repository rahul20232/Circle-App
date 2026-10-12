// lib/screens/Profile/EditProfile/edit_profile_controller.dart
import 'dart:io';
import 'package:circle_app/utils/text_utils.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:circle_app/models/user_model.dart';
import 'package:circle_app/services/auth_service.dart';
import 'package:circle_app/services/api_service.dart';

class EditProfileController {
  final VoidCallback onStateChanged;

  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController relController = TextEditingController();
  final TextEditingController childController = TextEditingController();
  final TextEditingController workController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  // Image handling
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  // Identity values
  String? relationshipStatus;
  String? hasChildren;
  String? industry;
  String? country;
  DateTime? birthday;

  EditProfileController({required this.onStateChanged});

  // Getters
  File? get profileImage => _profileImage;
  bool get isUploadingImage => _isUploadingImage;

  void initialize() {
    _initializeControllers();
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    relController.dispose();
    childController.dispose();
    workController.dispose();
    countryController.dispose();
  }

  void _initializeControllers() {
    final user = AuthService.currentUserNotifier.value;
    if (user != null) {
      updateUserData(user);
    }
  }

  void updateUserData(AppUser user) {
    nameController.text = user.displayName;
    emailController.text = user.email;
    phoneController.text = user.phoneNumber ?? "";

    // Initialize identity fields from user model
    relationshipStatus = user.relationshipStatus ?? "";
    hasChildren = user.childrenStatus ?? "";
    industry = user.industry ?? "";
    country = stripEmoji(user.country ?? "");
    birthday = user.birthdate;

    relController.text = relationshipStatus ?? "";
    childController.text = hasChildren ?? "";
    workController.text = industry ?? "";
    countryController.text = country ?? "";
  }

  Future<bool> saveIdentityPreferences() async {
    try {
      final result = await ApiService.updateUserPreferences(
        relationshipStatus: relationshipStatus,
        childrenStatus: hasChildren,
        industry: industry,
        country: country,
      );

      if (result != null) {
        // Update the AuthService's current user with the new data
        final updatedUser = AppUser.fromJson(result);
        AuthService.currentUserNotifier.value = updatedUser;
        return true;
      }
      return false;
    } catch (e) {
      print('Error saving identity preferences: $e');
      return false;
    }
  }

  Future<void> pickAndUploadImage(BuildContext context) async {
    print("🔍 Starting image pick...");

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print("✅ Image picked: ${pickedFile.path}");

        _profileImage = File(pickedFile.path);
        _isUploadingImage = true;
        onStateChanged();

        try {
          print("🚀 Starting upload...");
          final imageUrl = await ApiService.uploadProfilePhoto(_profileImage!);
          print("✅ Upload successful. URL: $imageUrl");

          final currentUser = AuthService.currentUserNotifier.value;
          print(
              "🔄 Current user profile pic: ${currentUser?.profilePictureUrl}");

          _isUploadingImage = false;
          onStateChanged();

          _showSnackBar(context, 'Profile picture updated successfully',
              isError: false);
        } catch (e) {
          print("❌ Upload failed: $e");
          _isUploadingImage = false;
          onStateChanged();
          _showSnackBar(context, 'Failed to upload profile picture');
        }
      }
    } catch (e) {
      print("❌ Image pick failed: $e");
      _showSnackBar(context, 'Failed to pick image');
    }
  }

  Future<bool> updateBasicInfo(String label, String newValue) async {
    try {
      if (label == "First name") {
        return await AuthService.updateProfile(displayName: newValue);
      } else if (label == "Phone number") {
        return await AuthService.updateProfile(phoneNumber: newValue);
      }
      return false;
    } catch (e) {
      print('Error updating $label: $e');
      return false;
    }
  }

  void updateIdentityField(String label, String value) {
    switch (label) {
      case "What is your relationship status?":
        relationshipStatus = value;
        relController.text = value;
        break;
      case "Do you have children?":
        hasChildren = value;
        childController.text = value;
        break;
      case "If you're working, what industry do you...":
        industry = value;
        workController.text = value;
        break;
      case "What country are you from?":
        country = value;
        countryController.text = value;
        break;
    }
    onStateChanged();
  }

  void revertIdentityField(String label, String oldValue) {
    switch (label) {
      case "What is your relationship status?":
        relationshipStatus = oldValue;
        relController.text = oldValue;
        break;
      case "Do you have children?":
        hasChildren = oldValue;
        childController.text = oldValue;
        break;
      case "If you're working, what industry do you...":
        industry = oldValue;
        workController.text = oldValue;
        break;
      case "What country are you from?":
        country = oldValue;
        countryController.text = oldValue;
        break;
    }
    onStateChanged();
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  // Helper methods for getting field values
  String getIdentityValue(String label) {
    switch (label) {
      case "What is your relationship status?":
        return relationshipStatus ?? "";
      case "Do you have children?":
        return hasChildren ?? "";
      case "If you're working, what industry do you...":
        return industry ?? "";
      case "What country are you from?":
        return country ?? "";
      case "When is your birthday?":
        // Format birthday as DD-MM-YYYY
        if (birthday != null) {
          return DateFormat('dd-MM-yyyy').format(birthday!);
        }
        return "";
      default:
        return "";
    }
  }

  TextEditingController getControllerForLabel(String label) {
    switch (label) {
      case "First name":
        return nameController;
      case "Phone number":
        return phoneController;
      default:
        return nameController;
    }
  }

  TextInputType getInputTypeForLabel(String label) {
    switch (label) {
      case "Phone number":
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }
}
