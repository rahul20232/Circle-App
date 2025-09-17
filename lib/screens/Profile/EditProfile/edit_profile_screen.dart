// lib/screens/Profile/EditProfile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/controllers/edit_profile_controller.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/components/edit_profile_components.dart';
import 'package:timeleft_clone/models/user_model.dart';
import 'package:timeleft_clone/services/auth_service.dart';

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
      backgroundColor: const Color(0xFFFEF1DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF1DE),
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
