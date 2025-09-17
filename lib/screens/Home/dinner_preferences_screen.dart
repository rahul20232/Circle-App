// lib/screens/Home/dinner_preferences_screen.dart
import 'package:flutter/material.dart';
import '../../models/dinner_model.dart';

import './controllers/dinner_preferences_controller.dart';
import './components/dinner_preferences_components.dart';

class DinnerPreferencesScreen extends StatefulWidget {
  final Dinner selectedDinner;

  const DinnerPreferencesScreen({
    Key? key,
    required this.selectedDinner,
  }) : super(key: key);

  @override
  State<DinnerPreferencesScreen> createState() =>
      _DinnerPreferencesScreenState();
}

class _DinnerPreferencesScreenState extends State<DinnerPreferencesScreen> {
  late DinnerPreferencesController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        DinnerPreferencesController(selectedDinner: widget.selectedDinner);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSaveError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to save preferences'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleBookingError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking failed: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleConfirmBooking() async {
    try {
      await _controller.confirmBooking(context);
    } catch (e) {
      _handleBookingError(e.toString());
    }
  }

  Future<void> _handleShowConfirmation() async {
    try {
      await _controller.showConfirmationView();
    } catch (e) {
      _handleSaveError();
    }
  }

  Future<void> _handleShowPreferences() async {
    try {
      await _controller.showPreferencesForm();
    } catch (e) {
      _handleSaveError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFFEF1DE),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFEF1DE),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFEF1DE),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Your Dinner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _controller.showConfirmation
                ? DinnerPreferencesComponents.buildConfirmationView(
                    dinner: _controller.selectedDinner,
                    budgetText: _controller.getSelectedBudgetText(),
                    dietaryText: _controller.getDietaryPreferencesText(),
                    languageText: _controller.getSelectedLanguagesText(),
                    onEditPreferences: _handleShowPreferences,
                    isBooking: _controller.isBooking,
                    onConfirmBooking:
                        _controller.isBooking ? null : _handleConfirmBooking,
                  )
                : DinnerPreferencesComponents.buildPreferencesForm(
                    dinner: _controller.selectedDinner,
                    availableLanguages: _controller.availableLanguages,
                    selectedLanguages: _controller.selectedLanguages,
                    onLanguageToggle: _controller.toggleLanguage,
                    budgetOptions: _controller.budgetOptions,
                    selectedBudget: _controller.selectedBudget,
                    onBudgetSelect: _controller.selectBudget,
                    hasDietaryRestrictions: _controller.hasDietaryRestrictions,
                    onDietaryToggle: _controller.toggleDietaryRestrictions,
                    dietaryOptions: _controller.dietaryOptions,
                    selectedDietaryOptions: _controller.selectedDietaryOptions,
                    onDietaryOptionToggle: _controller.toggleDietaryOption,
                    canContinue: _controller.canContinue(),
                    onContinue: _handleShowConfirmation,
                  ),
          ),
        );
      },
    );
  }
}
