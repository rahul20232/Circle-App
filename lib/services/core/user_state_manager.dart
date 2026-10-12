// lib/services/core/user_state_manager.dart
import 'dart:convert';

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
    final userDataJson = prefs.getString('user_data');

    if (userDataJson != null) {
      try {
        final userMap = jsonDecode(userDataJson) as Map<String, dynamic>;
        _currentUser = AppUser.fromJson(userMap);
        _userNotifier.value = _currentUser;
      } catch (e) {
        print("Error loading user from storage: $e");
        await clearUser();
      }
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
    // Save the complete user object as JSON
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    // Keep user_id for quick checks
    await prefs.setString('user_id', user.id);
  }

  /// Private method to clear user from storage
  Future<void> _clearUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('user_id');
    // Remove old individual keys if they exist
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_profile_pic');
    await prefs.remove('is_google_user');
    await prefs.remove('is_verified');
  }
}
