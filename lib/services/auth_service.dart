// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_service.dart';
import 'core/token_manager.dart';
import 'core/user_state_manager.dart';

/// Authentication service - handles auth logic and user state management
class AuthService {
  static final TokenManager _tokenManager = TokenManager.instance;
  static final UserStateManager _userManager = UserStateManager.instance;

  // ================== Getters (Delegated to UserStateManager) ==================

  static AppUser? get currentUser => _userManager.currentUser;
  static ValueNotifier<AppUser?> get currentUserNotifier =>
      _userManager.userNotifier;
  static bool get isSubscribed => _userManager.isSubscribed;
  static bool get hasActiveSubscription => _userManager.hasActiveSubscription;
  static bool get isSubscriptionExpiring => _userManager.isSubscriptionExpiring;
  static String get subscriptionStatus => _userManager.subscriptionStatus;
  static int? get currentUserId => _userManager.currentUserId;

  /// Get current user ID (async version for backwards compatibility)
  static Future<int?> getCurrentUserId() async {
    // First try to get from current user in memory
    if (_userManager.currentUser != null) {
      return int.tryParse(_userManager.currentUser!.id);
    }

    // Fallback: load from SharedPreferences if not in memory
    await _userManager.loadUserFromStorage();
    if (_userManager.currentUser != null) {
      return int.tryParse(_userManager.currentUser!.id);
    }

    return null;
  }

  // ================== Authentication Methods ==================

  static Future<String?> registerWithEmail(
    String email,
    String password,
    String displayName, {
    String? phoneNumber,
    Map<String, String>? personalityData,
    Map<String, String>? identityData,
  }) async {
    try {
      return await ApiService.registerWithEmail(
        email,
        password,
        displayName,
        phoneNumber: phoneNumber,
        personalityData: personalityData,
        identityData: identityData,
      );
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  static Future<AppUser> loginWithEmail(String email, String password) async {
    try {
      final result = await ApiService.loginWithEmail(email, password);

      // Save token and user state
      await _tokenManager.saveToken(result.token);
      await _userManager.updateUser(result.user);

      return result.user;
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  static Future<bool> checkUserExists(String email) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/auth/check-user-exists?email=${Uri.encodeComponent(email)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] == true;
      } else {
        throw Exception('Failed to check user existence');
      }
    } catch (e) {
      print('Error checking user existence: $e');
      throw Exception('Failed to check if user exists');
    }
  }

  static Future<void> signUpWithGoogleAndOnboardingData({
    required String email,
    required String displayName,
    required String googleId,
    String? photoUrl,
    required Map<String, String> personalityData,
    required Map<String, String> identityData,
  }) async {
    try {
      print(
          'DEBUG: AuthService - calling API with personality data size: ${personalityData.length}');
      print(
          'DEBUG: AuthService - calling API with identity data size: ${identityData.length}');

      await ApiService.signUpWithGoogleAndOnboardingData(
        email: email,
        displayName: displayName,
        googleId: googleId,
        photoUrl: photoUrl,
        personalityData: personalityData,
        identityData: identityData,
      );

      print('DEBUG: AuthService - API call completed successfully');
    } catch (e) {
      print('DEBUG: AuthService error: $e');
      throw AuthException(
          'Google sign up with onboarding data failed: ${e.toString()}');
    }
  }

  static Future<AppUser> authenticateWithGoogle(String email,
      String displayName, String googleId, String? photoUrl) async {
    try {
      final result = await ApiService.authenticateWithGoogle(
          email, displayName, googleId, photoUrl);

      // Save token and user state (similar to email login)
      await _tokenManager.saveToken(result.token);
      await _userManager.updateUser(result.user);

      return result.user;
    } catch (e) {
      throw AuthException('Google authentication failed: ${e.toString()}');
    }
  }

  static Future<void> signOut() async {
    await _tokenManager.clearToken();
    await _userManager.clearUser();
  }

  static Future<bool> isLoggedIn() async {
    return await _userManager.checkLoginStatus();
  }

  static Future<void> loadUserSession() async {
    await _userManager.loadUserFromStorage();
  }

  static Future<String?> getToken() async {
    return await _tokenManager.getToken();
  }

  // ================== Profile Management ==================

  static Future<bool> updateProfile(
      {String? displayName, String? phoneNumber}) async {
    try {
      final updatedUser = await ApiService.updateUserProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
      );
      await _userManager.updateUser(updatedUser);
      return true;
    } catch (e) {
      throw AuthException('Profile update failed: ${e.toString()}');
    }
  }

  static Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final photoUrl = await ApiService.uploadProfilePhoto(imageFile);

      // Update current user with new photo URL
      final currentUser = _userManager.currentUser;
      if (currentUser != null) {
        final updatedUser = AppUser(
          id: currentUser.id,
          email: currentUser.email,
          displayName: currentUser.displayName,
          profilePictureUrl: photoUrl,
          phoneNumber: currentUser.phoneNumber,
          isGoogleUser: currentUser.isGoogleUser,
          isVerified: currentUser.isVerified,
          // Copy other properties as needed
        );
        await _userManager.updateUser(updatedUser);
      }

      return photoUrl;
    } catch (e) {
      throw AuthException('Photo upload failed: ${e.toString()}');
    }
  }

  // ================== Password Management ==================

  static Future<String> sendPasswordResetEmail(String email) async {
    try {
      return await ApiService.sendPasswordResetEmail(email);
    } catch (e) {
      throw AuthException('Password reset email failed: ${e.toString()}');
    }
  }

  static Future<bool> resetPassword(String token, String newPassword) async {
    try {
      await ApiService.resetPassword(token, newPassword);
      return true;
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  // ================== Subscription Management ==================

  static Future<bool> activateSubscription({
    required String subscriptionType,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    String? subscriptionPlanId,
  }) async {
    try {
      final updatedUser = await ApiService.activateSubscription(
        subscriptionType: subscriptionType,
        subscriptionStart: subscriptionStart,
        subscriptionEnd: subscriptionEnd,
        subscriptionPlanId: subscriptionPlanId,
      );
      await _userManager.updateUser(updatedUser);
      return true;
    } catch (e) {
      throw AuthException('Subscription activation failed: ${e.toString()}');
    }
  }

  static Future<void> updateSubscription({
    bool? isSubscribed,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    String? subscriptionType,
    String? subscriptionPlanId,
  }) async {
    try {
      final updatedUser = await ApiService.updateSubscription(
        isSubscribed: isSubscribed,
        subscriptionStart: subscriptionStart,
        subscriptionEnd: subscriptionEnd,
        subscriptionType: subscriptionType,
        subscriptionPlanId: subscriptionPlanId,
      );
      await _userManager.updateUser(updatedUser);
    } catch (e) {
      throw AuthException('Subscription update failed: ${e.toString()}');
    }
  }

  static Future<String> cancelSubscription() async {
    try {
      final message = await ApiService.cancelSubscription();
      // Refresh user data to get updated subscription status
      await refreshUserData();
      return message;
    } catch (e) {
      throw AuthException('Subscription cancellation failed: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      return await ApiService.getSubscriptionStatus();
    } catch (e) {
      throw AuthException('Failed to get subscription status: ${e.toString()}');
    }
  }

  // ================== User Preferences ==================

  static Future<void> updateUserPreferences({
    String? relationshipStatus,
    String? childrenStatus,
    String? industry,
    String? country,
    List<String>? dinnerLanguages,
    String? dinnerBudget,
    bool? hasDietaryRestrictions,
    List<String>? dietaryOptions,
    bool? eventPushNotifications,
    bool? eventSms,
    bool? eventEmail,
    bool? lastminutePushNotifications,
    bool? lastminuteSms,
    bool? lastminuteEmail,
    bool? marketingEmail,
  }) async {
    try {
      final updatedData = await ApiService.updateUserPreferences(
        relationshipStatus: relationshipStatus,
        childrenStatus: childrenStatus,
        industry: industry,
        country: country,
        dinnerLanguages: dinnerLanguages,
        dinnerBudget: dinnerBudget,
        hasDietaryRestrictions: hasDietaryRestrictions,
        dietaryOptions: dietaryOptions,
        eventPushNotifications: eventPushNotifications,
        eventSms: eventSms,
        eventEmail: eventEmail,
        lastminutePushNotifications: lastminutePushNotifications,
        lastminuteSms: lastminuteSms,
        lastminuteEmail: lastminuteEmail,
        marketingEmail: marketingEmail,
      );

      // Update user with new preferences
      final updatedUser = AppUser.fromJson(updatedData);
      await _userManager.updateUser(updatedUser);
    } catch (e) {
      throw AuthException('Preferences update failed: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      return await ApiService.getUserPreferences();
    } catch (e) {
      throw AuthException('Failed to get user preferences: ${e.toString()}');
    }
  }

  // ================== Account Management ==================

  static Future<bool> deleteAccount(
      String password, String confirmationText) async {
    try {
      await ApiService.deleteAccount(password, confirmationText);
      await signOut(); // Clear all local user data
      return true; // Success
    } catch (e) {
      throw AuthException('Account deletion failed: ${e.toString()}');
    }
  }

  // ================== Utility Methods ==================

  static Future<void> refreshUserData() async {
    try {
      final userPrefs = await ApiService.getUserPreferences();
      final updatedUser = AppUser.fromJson(userPrefs);
      await _userManager.updateUser(updatedUser);
    } catch (e) {
      throw AuthException('Failed to refresh user data: ${e.toString()}');
    }
  }

  static Future<bool> updateFCMToken(String token) async {
    try {
      return await ApiService.updateFCMToken(token);
    } catch (e) {
      return false;
    }
  }

  /// Manually update current user (use sparingly - prefer API calls)
  static void updateCurrentUser(AppUser updatedUser) {
    _userManager.updateUser(updatedUser);
  }
}

// ================== Exception Classes ==================

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
