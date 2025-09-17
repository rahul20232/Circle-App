// lib/services/core/user_state_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

/// Centralized user state management
class UserStateManager {
  static UserStateManager? _instance;
  static UserStateManager get instance => _instance ??= UserStateManager._();
  UserStateManager._();

  AppUser? _currentUser;
  final ValueNotifier<AppUser?> _userNotifier = ValueNotifier(null);

  // Getters
  AppUser? get currentUser => _currentUser;
  ValueNotifier<AppUser?> get userNotifier => _userNotifier;
  bool get isLoggedIn => _currentUser != null;
  bool get isSubscribed => _currentUser?.isSubscribed ?? false;
  bool get hasActiveSubscription =>
      _currentUser?.hasActiveSubscription ?? false;
  bool get isSubscriptionExpiring =>
      _currentUser?.isSubscriptionExpiringSoon ?? false;
  String get subscriptionStatus =>
      _currentUser?.subscriptionStatusText ?? "Unknown";
  int? get currentUserId =>
      _currentUser != null ? int.tryParse(_currentUser!.id) : null;

  /// Update current user and notify listeners
  Future<void> updateUser(AppUser user) async {
    _currentUser = user;
    _userNotifier.value = user;
    await _saveUserToStorage(user);
  }

  /// Clear user state
  Future<void> clearUser() async {
    _currentUser = null;
    _userNotifier.value = null;
    await _clearUserFromStorage();
  }

  /// Load user from storage
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');
    final profilePic = prefs.getString('user_profile_pic');
    final phone = prefs.getString('user_phone');
    final isGoogleUser = prefs.getBool('is_google_user') ?? false;
    final isVerified = prefs.getBool('is_verified') ?? false;

    if (userId != null && email != null && name != null) {
      final user = AppUser(
        id: userId,
        email: email,
        displayName: name,
        profilePictureUrl: profilePic,
        phoneNumber: phone,
        isGoogleUser: isGoogleUser,
        isVerified: isVerified,
      );
      _currentUser = user;
      _userNotifier.value = user;
    }
  }

  /// Check if user is logged in by checking storage
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') != null;
  }

  /// Private method to save user to storage
  Future<void> _saveUserToStorage(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_name', user.displayName);

    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      await prefs.setString('user_phone', user.phoneNumber!);
    } else {
      await prefs.remove('user_phone');
    }

    if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
      await prefs.setString('user_profile_pic', user.profilePictureUrl!);
    } else {
      await prefs.remove('user_profile_pic');
    }

    await prefs.setBool('is_google_user', user.isGoogleUser);
    await prefs.setBool('is_verified', user.isVerified);
  }

  /// Private method to clear user from storage
  Future<void> _clearUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_profile_pic');
    await prefs.remove('is_google_user');
    await prefs.remove('is_verified');
  }
}
