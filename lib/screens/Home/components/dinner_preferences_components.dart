// lib/components/dinner_preferences_components.dart
import 'package:flutter/material.dart';
import '../../../models/dinner_model.dart';

class DinnerPreferencesComponents {
  // Dinner Info Card
  static Widget buildDinnerInfoCard(Dinner dinner) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Dinner',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dinner.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${dinner.formattedDate} at ${dinner.formattedTime}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  dinner.location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Header
  static Widget buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  // Required Label
  static Widget buildRequiredLabel() {
    return const Text(
      '(Required)',
      style: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    );
  }

  // Language Options Widget
  static Widget buildLanguageOptions({
    required List<String> availableLanguages,
    required List<String> selectedLanguages,
    required Function(String) onLanguageToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: availableLanguages.map((language) {
          bool isSelected = selectedLanguages.contains(language);
          return InkWell(
            onTap: () => onLanguageToggle(language),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  buildCheckbox(isSelected),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Budget Options Widget
  static Widget buildBudgetOptions({
    required List<String> budgetOptions,
    required String? selectedBudget,
    required Function(String) onBudgetSelect,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: budgetOptions.asMap().entries.map((entry) {
          int index = entry.key;
          String budget = entry.value;
          bool isSelected = selectedBudget == budget;
          bool isLast = index == budgetOptions.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => onBudgetSelect(budget),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        budget,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      buildCheckbox(isSelected),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Dietary Restrictions Toggle
  static Widget buildDietaryRestrictionsToggle({
    required bool hasDietaryRestrictions,
    required Function(bool) onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'I have dietary restrictions (Optional)',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            value: hasDietaryRestrictions,
            onChanged: onToggle,
            activeColor: Colors.white,
            activeTrackColor: Color(0xFF00C853),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // Dietary Options Widget
  static Widget buildDietaryOptions({
    required List<String> dietaryOptions,
    required List<String> selectedDietaryOptions,
    required Function(String) onDietaryOptionToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: dietaryOptions.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          bool isSelected = selectedDietaryOptions.contains(option);
          bool isLast = index == dietaryOptions.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => onDietaryOptionToggle(option),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      buildCheckbox(isSelected),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Checkbox Widget
  static Widget buildCheckbox(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
        color: isSelected ? Colors.black : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }

  // Continue Button
  static Widget buildContinueButton({
    required bool canContinue,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canContinue ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canContinue ? Colors.black : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Preferences Summary Card
  static Widget buildPreferencesSummaryCard({
    required String budgetText,
    required String dietaryText,
    required String languageText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPreferenceSection('Budget', budgetText),
          const SizedBox(height: 24),
          buildPreferenceSection('Dietary preferences', dietaryText),
          const SizedBox(height: 24),
          buildPreferenceSection('Language', languageText),
        ],
      ),
    );
  }

  // Preference Section
  static Widget buildPreferenceSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Edit Preferences Button
  static Widget buildEditPreferencesButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.black, width: 1.5),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Edit my preferences',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Confirm Booking Button
  static Widget buildConfirmBookingButton({
    required bool isBooking,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: isBooking
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Booking...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // Preferences Form Layout
  static Widget buildPreferencesForm({
    required Dinner dinner,
    required List<String> availableLanguages,
    required List<String> selectedLanguages,
    required Function(String) onLanguageToggle,
    required List<String> budgetOptions,
    required String? selectedBudget,
    required Function(String) onBudgetSelect,
    required bool hasDietaryRestrictions,
    required Function(bool) onDietaryToggle,
    required List<String> dietaryOptions,
    required List<String> selectedDietaryOptions,
    required Function(String) onDietaryOptionToggle,
    required bool canContinue,
    required VoidCallback onContinue,
  }) {
    return Column(
      key: const ValueKey('preferences'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDinnerInfoCard(dinner),
                const SizedBox(height: 30),
                buildSectionHeader(
                    'What language(s) are you willing to speak?'),
                buildRequiredLabel(),
                const SizedBox(height: 12),
                buildLanguageOptions(
                  availableLanguages: availableLanguages,
                  selectedLanguages: selectedLanguages,
                  onLanguageToggle: onLanguageToggle,
                ),
                const SizedBox(height: 40),
                buildSectionHeader('What are you willing to spend at dinner?'),
                buildRequiredLabel(),
                const SizedBox(height: 12),
                buildBudgetOptions(
                  budgetOptions: budgetOptions,
                  selectedBudget: selectedBudget,
                  onBudgetSelect: onBudgetSelect,
                ),
                const SizedBox(height: 40),
                buildDietaryRestrictionsToggle(
                  hasDietaryRestrictions: hasDietaryRestrictions,
                  onToggle: onDietaryToggle,
                ),
                if (hasDietaryRestrictions) ...[
                  const SizedBox(height: 20),
                  buildDietaryOptions(
                    dietaryOptions: dietaryOptions,
                    selectedDietaryOptions: selectedDietaryOptions,
                    onDietaryOptionToggle: onDietaryOptionToggle,
                  ),
                ],
              ],
            ),
          ),
        ),
        buildContinueButton(
          canContinue: canContinue,
          onPressed: onContinue,
        ),
      ],
    );
  }

  // Confirmation View Layout
  static Widget buildConfirmationView({
    required Dinner dinner,
    required String budgetText,
    required String dietaryText,
    required String languageText,
    required VoidCallback onEditPreferences,
    required bool isBooking,
    required VoidCallback? onConfirmBooking,
  }) {
    return Column(
      key: const ValueKey('confirmation'),
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                buildDinnerInfoCard(dinner),
                const SizedBox(height: 20),
                buildPreferencesSummaryCard(
                  budgetText: budgetText,
                  dietaryText: dietaryText,
                  languageText: languageText,
                ),
                const SizedBox(height: 40),
                buildEditPreferencesButton(onPressed: onEditPreferences),
              ],
            ),
          ),
        ),
        buildConfirmBookingButton(
          isBooking: isBooking,
          onPressed: onConfirmBooking,
        ),
      ],
    );
  }
}
