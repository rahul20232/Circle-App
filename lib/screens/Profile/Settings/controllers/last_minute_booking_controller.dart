// lib/screens/Profile/Settings/last_minute_booking_controller.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/models/user_model.dart';
import 'package:timeleft_clone/services/api_service.dart';

class LastMinuteBookingController {
  final VoidCallback onStateChanged;

  bool _pushNotifications = false;
  bool _sms = false;
  bool _email = false;
  bool _isLoading = true;

  LastMinuteBookingController({required this.onStateChanged});

  // Getters
  bool get pushNotifications => _pushNotifications;
  bool get sms => _sms;
  bool get email => _email;
  bool get isLoading => _isLoading;

  void dispose() {
    // No controllers or streams to dispose in this case
  }

  void initialize() {
    _loadSettings();
  }

  void setPushNotifications(bool value) {
    _pushNotifications = value;
    onStateChanged();
  }

  void setSms(bool value) {
    _sms = value;
    onStateChanged();
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
        _pushNotifications = user.lastminutePushNotifications;
        _sms = user.lastminuteSms;
        _email = user.lastminuteEmail;
      }
    } catch (e) {
      print('Error loading settings: $e');
      // Set defaults if loading fails
      _pushNotifications = true;
      _sms = true;
      _email = true;
    }

    _setLoading(false);
  }

  // Save settings to backend
  Future<void> saveSettings(BuildContext context) async {
    try {
      await ApiService.updateUserPreferences(
        lastminutePushNotifications: _pushNotifications,
        lastminuteSms: _sms,
        lastminuteEmail: _email,
      );

      _showSnackBar(context, 'Settings saved successfully', isError: false);
    } catch (e) {
      print('Error saving settings: $e');
      _showSnackBar(context, 'Failed to save settings');
    }
  }

  Future<void> saveAndNavigateBack(BuildContext context) async {
    await saveSettings(context);
    Navigator.pop(context);
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

  // Validation and state checks
  bool get hasAnyNotificationEnabled => _pushNotifications || _sms || _email;
  bool get hasAllNotificationsDisabled => !hasAnyNotificationEnabled;

  // Batch operations
  void enableAllNotifications() {
    _pushNotifications = true;
    _sms = true;
    _email = true;
    onStateChanged();
  }

  void disableAllNotifications() {
    _pushNotifications = false;
    _sms = false;
    _email = false;
    onStateChanged();
  }

  void resetToDefaults() {
    _pushNotifications = true;
    _sms = true;
    _email = true;
    onStateChanged();
  }

  // Helper method to get notification summary
  String getNotificationSummary() {
    final enabledTypes = <String>[];
    if (_pushNotifications) enabledTypes.add('Push');
    if (_sms) enabledTypes.add('SMS');
    if (_email) enabledTypes.add('Email');

    if (enabledTypes.isEmpty) return 'No notifications enabled';
    if (enabledTypes.length == 3) return 'All notifications enabled';
    return '${enabledTypes.join(', ')} enabled';
  }

  // Individual notification type checks
  bool get isPushEnabled => _pushNotifications;
  bool get isSmsEnabled => _sms;
  bool get isEmailEnabled => _email;

  // Validation specific to last-minute bookings
  bool get meetsMinimumRequirement => hasAnyNotificationEnabled;

  String? validateNotificationSettings() {
    if (!hasAnyNotificationEnabled) {
      return 'At least one notification type must be enabled to receive last-minute booking alerts.';
    }
    return null;
  }
}
