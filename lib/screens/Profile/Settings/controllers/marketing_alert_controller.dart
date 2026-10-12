// lib/screens/Profile/Settings/marketing_alert_controller.dart
import 'package:flutter/material.dart';
import 'package:circle_app/theme/app_colors.dart';
import 'package:circle_app/models/user_model.dart';
import 'package:circle_app/services/api_service.dart';

class MarketingAlertController {
  final VoidCallback onStateChanged;

  bool _email = false;
  bool _isLoading = true;

  MarketingAlertController({required this.onStateChanged});

  // Getters
  bool get email => _email;
  bool get isLoading => _isLoading;

  void dispose() {
    // No controllers or streams to dispose in this case
  }

  void initialize() {
    _loadSettings();
  }

  void setEmail(bool value) {
    _email = value;
    onStateChanged();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    onStateChanged();
  }

  // Load saved settings from backend
  Future<void> _loadSettings() async {
    _setLoading(true);

    try {
      final userPrefs = await ApiService.getUserPreferences();
      if (userPrefs != null) {
        final user = AppUser.fromJson(userPrefs);
        _email = user.marketingEmail;
      }
    } catch (e) {
      print('Error loading settings: $e');
      // Set default if loading fails
      _email = true;
    }

    _setLoading(false);
  }

  // Save settings to backend
  Future<void> saveSettings(BuildContext context) async {
    try {
      await ApiService.updateUserPreferences(
        marketingEmail: _email,
      );

      _showSnackBar(context, 'Settings saved successfully', isError: false);
    } catch (e) {
      print('Error saving settings: $e');
      _showSnackBar(context, 'Failed to save settings');
    }
  }

  Future<void> saveAndNavigateBack(BuildContext context) async {
    if (!context.mounted) return;

    // Navigate back immediately (optimistic update)
    Navigator.pop(context);

    // Save in background
    try {
      await saveSettings(context);
    } catch (e) {
      print('Error saving settings: $e');
      // Could show a global notification here if you have that setup
    }
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

  // State checks
  bool get isEmailEnabled => _email;
  bool get isMarketingOptedIn => _email;

  // Toggle methods
  void toggleEmail() {
    _email = !_email;
    onStateChanged();
  }

  void optIntoMarketing() {
    _email = true;
    onStateChanged();
  }

  void optOutOfMarketing() {
    _email = false;
    onStateChanged();
  }

  // Helper method to get marketing status
  String getMarketingStatus() {
    return _email ? 'Marketing emails enabled' : 'Marketing emails disabled';
  }

  // Privacy-related helpers
  bool get hasMarketingConsent => _email;

  String getPrivacyStatus() {
    if (_email) {
      return 'You will receive marketing communications from Circle.';
    } else {
      return 'You will not receive marketing communications from Circle.';
    }
  }

  // Validation (for future use if other marketing channels are added)
  String? validateMarketingSettings() {
    // Currently no validation needed since email is optional
    return null;
  }
}
