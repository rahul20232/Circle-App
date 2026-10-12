import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OnboardingStateService {
  static const String _personalityDataKey = 'personality_data';
  static const String _identityDataKey = 'identity_data';
  static const String _currentStepKey = 'current_step';
  static const String _accountDataKey = 'account_data';
  static const String _completedDataKey = 'onboarding_completed';

  // Check if user has any saved progress
  static Future<bool> hasProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final personalityData = prefs.getString(_personalityDataKey);
    final identityData = prefs.getString(_identityDataKey);
    final accountData = prefs.getString(_accountDataKey);
    final currentStep = prefs.getInt(_currentStepKey);

    return (personalityData != null && personalityData.isNotEmpty) ||
        (identityData != null && identityData.isNotEmpty) ||
        (accountData != null && accountData.isNotEmpty) ||
        (currentStep != null && currentStep > 0);
  }

  // Save personality data
  static Future<void> savePersonalityData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_personalityDataKey, jsonEncode(data));
  }

  // Save identity data
  static Future<void> saveIdentityData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_identityDataKey, jsonEncode(data));
  }

  // Save current step
  static Future<void> saveCurrentStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentStepKey, step);
  }

  // Load personality data
  static Future<Map<String, String>> loadPersonalityData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_personalityDataKey);
    if (dataString != null) {
      return Map<String, String>.from(jsonDecode(dataString));
    }
    return {};
  }

  // Load identity data
  static Future<Map<String, String>> loadIdentityData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_identityDataKey);
    if (dataString != null) {
      return Map<String, String>.from(jsonDecode(dataString));
    }
    return {};
  }

  // Load current step
  static Future<int> loadCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStepKey) ?? 0;
  }

  static Future<void> saveAccountData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountDataKey, jsonEncode(data));
  }

  static Future<Map<String, String>> loadAccountData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_accountDataKey);
    if (dataString != null) {
      return Map<String, String>.from(jsonDecode(dataString));
    }
    return {};
  }

  // Clear all data (for restart)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_personalityDataKey);
    await prefs.remove(_identityDataKey);
    await prefs.remove(_accountDataKey);
    await prefs.remove(_currentStepKey);
    await prefs.remove(_completedDataKey);
  }

  static const String _phoneDataKey = 'phone_data';

  static Future<void> savePhoneData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneDataKey, jsonEncode(data));
  }

  static Future<Map<String, String>> loadPhoneData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_phoneDataKey);
    if (dataString != null) {
      return Map<String, String>.from(jsonDecode(dataString));
    }
    return {};
  }

  // Get saved data for continuation
  static Future<Map<String, dynamic>> getSavedData() async {
    return {
      'personalityData': await loadPersonalityData(),
      'identityData': await loadIdentityData(),
      'accountData': await loadAccountData(),
      'currentStep': await loadCurrentStep(),
    };
  }
}
