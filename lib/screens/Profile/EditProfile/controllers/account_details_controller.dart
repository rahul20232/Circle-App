// lib/screens/Account/account_details_controller.dart
import 'package:flutter/material.dart';

class AccountDetailsController {
  final String initialValue;
  final TextInputType inputType;
  final VoidCallback onStateChanged;

  late TextEditingController _textController;
  bool _isButtonEnabled = false;

  AccountDetailsController({
    required this.initialValue,
    required this.inputType,
    required this.onStateChanged,
  });

  // Getters
  TextEditingController get textController => _textController;
  bool get isButtonEnabled => _isButtonEnabled;

  void initialize() {
    _textController = TextEditingController(text: initialValue);
    _textController.addListener(_validateInput);
  }

  void dispose() {
    _textController.removeListener(_validateInput);
    _textController.dispose();
  }

  void _validateInput() {
    String text = _textController.text.trim();
    String processedText = _processPhoneNumber(text);

    bool isChanged = processedText != initialValue.trim();
    bool isValid = _isInputValid(processedText);

    bool newButtonState = isChanged && isValid;

    if (_isButtonEnabled != newButtonState) {
      _isButtonEnabled = newButtonState;
      onStateChanged();
    }
  }

  String _processPhoneNumber(String text) {
    if (inputType != TextInputType.phone) return text;

    // Remove +91 or 91 if present at the start for phone numbers
    if (text.startsWith('+91')) {
      return text.substring(3);
    } else if (text.startsWith('91') && text.length > 10) {
      return text.substring(2);
    }
    return text;
  }

  bool _isInputValid(String text) {
    if (inputType == TextInputType.phone) {
      // Phone number validation: must be exactly 10 digits
      return RegExp(r'^\d{10}$').hasMatch(text);
    }

    // For other input types, basic validation
    switch (inputType) {
      case TextInputType.emailAddress:
        return _isValidEmail(text);
      case TextInputType.text:
        return text.isNotEmpty;
      default:
        return text.isNotEmpty;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String getCurrentValue() {
    return _textController.text.trim();
  }

  String getProcessedValue() {
    return _processPhoneNumber(_textController.text.trim());
  }

  void updateText(String newText) {
    _textController.text = newText;
  }

  void clearText() {
    _textController.clear();
  }

  // Validation helpers for different input types
  bool isValidPhoneNumber(String phone) {
    String processed = _processPhoneNumber(phone);
    return RegExp(r'^\d{10}$').hasMatch(processed);
  }

  bool hasChanges() {
    return getProcessedValue() != initialValue.trim();
  }
}
