// lib/screens/Profile/EditProfile/identity_controller.dart
import 'package:flutter/material.dart';
import 'package:circle_app/utils/text_utils.dart';

class IdentityController {
  final String initialValue;
  final VoidCallback onStateChanged;

  String? _selectedValue;

  IdentityController({
    required this.initialValue,
    required this.onStateChanged,
  }) {
    _selectedValue = initialValue.isEmpty ? null : stripEmoji(initialValue);
  }

  // Getters
  String? get selectedValue => _selectedValue;

  // Options lists
  final List<String> relationshipOptions = [
    'Single',
    'Married',
    "It's Complicated",
    'In a relationship',
    "I'd prefer not to say"
  ];

  final List<String> childrenOptions = [
    'No',
    'Yes',
    "I'd prefer not to say",
  ];

  final List<String> industryOptions = [
    'Not working',
    'Healthcare',
    "Technology",
    "Manual Labor",
    "Retail",
    "Food",
    "Services",
    "Arts",
    "Politics"
  ];

  final List<String> countryOptions = [
    'India',
    'USA',
    "Australia",
    "Canada",
    "UK",
    "Germany",
    "France",
    "Italy",
    "Spain",
    "Japan",
    "China",
  ];

  void dispose() {
    // No controllers or resources to dispose in this case
  }

  List<String> getOptionsForQuestion(String question) {
    switch (question) {
      case "What is your relationship status?":
        return relationshipOptions;
      case "Do you have children?":
        return childrenOptions;
      case "If you're working, what industry do you...":
        return industryOptions;
      case "What country are you from?":
        return countryOptions;
      default:
        return [];
    }
  }

  void selectValue(String value) {
    _selectedValue = value;
    onStateChanged();
  }

  bool isSelected(String value) {
    return _selectedValue == value;
  }

  Future<void> handleOptionTap(BuildContext context, String value) async {
    selectValue(value);

    // Add a small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 200));

    Navigator.pop(context, _selectedValue);
  }

  // Helper method to check if question has options
  bool hasOptionsForQuestion(String question) {
    return getOptionsForQuestion(question).isNotEmpty;
  }

  // Get the category type for the question
  String getQuestionCategory(String question) {
    switch (question) {
      case "What is your relationship status?":
        return "relationship";
      case "Do you have children?":
        return "children";
      case "If you're working, what industry do you...":
        return "industry";
      case "What country are you from?":
        return "country";
      default:
        return "unknown";
    }
  }

  // Validation helper
  bool isValidSelection(String value) {
    if (_selectedValue == null) return false;
    return _selectedValue!.isNotEmpty;
  }
}
