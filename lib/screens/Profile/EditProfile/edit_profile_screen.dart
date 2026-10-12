// lib/screens/Profile/EditProfile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/screens/Profile/EditProfile/controllers/edit_profile_controller.dart';
import 'package:circle_app/screens/Profile/EditProfile/components/edit_profile_components.dart';
import 'package:circle_app/models/user_model.dart';
import 'package:circle_app/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late EditProfileController _controller;
  late EditProfileComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = EditProfileComponents(controller: _controller);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<AppUser?>(
        valueListenable: AuthService.currentUserNotifier,
        builder: (context, user, _) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Update controller with latest user data
          _controller.updateUserData(user);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _components.buildProfilePicture(context, user),
                const SizedBox(height: 30),
                _components.buildBasicInfoSection(context, user),
                const SizedBox(height: 20),
                _components.buildIdentitySection(context, user),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
