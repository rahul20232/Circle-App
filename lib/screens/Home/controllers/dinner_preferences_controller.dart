// lib/controllers/dinner_preferences_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/user_model.dart';
import '../../../models/dinner_model.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/dinner_service.dart';
import '../../../screens/Home/booking_success_screen.dart';
import '../../../screens/Profile/settings/subscription_screen.dart';
import 'package:vibration/vibration.dart';

class DinnerPreferencesController extends ChangeNotifier {
  // Data
  final Dinner selectedDinner;

  // Language preferences
  List<String> _selectedLanguages = [];
  final List<String> _availableLanguages = ['English'];

  // Budget preferences
  String? _selectedBudget;
  final List<String> _budgetOptions = ['\$', '\$\$', '\$\$\$'];

  // Dietary restrictions
  bool _hasDietaryRestrictions = false;
  List<String> _selectedDietaryOptions = [];
  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-free',
    'Halal',
    'Kosher'
  ];

  // State
  bool _isLoading = true;
  bool _showConfirmation = false;
  bool _isBooking = false;

  // Constructor
  DinnerPreferencesController({required this.selectedDinner});

  // Getters
  List<String> get selectedLanguages => _selectedLanguages;
  List<String> get availableLanguages => _availableLanguages;
  String? get selectedBudget => _selectedBudget;
  List<String> get budgetOptions => _budgetOptions;
  bool get hasDietaryRestrictions => _hasDietaryRestrictions;
  List<String> get selectedDietaryOptions => _selectedDietaryOptions;
  List<String> get dietaryOptions => _dietaryOptions;
  bool get isLoading => _isLoading;
  bool get showConfirmation => _showConfirmation;
  bool get isBooking => _isBooking;

  // Initialization
  Future<void> initialize() async {
    await loadPreferences();
  }

  // Load user preferences
  Future<void> loadPreferences() async {
    _setLoading(true);

    try {
      final userPrefs = await ApiService.getUserPreferences();
      if (userPrefs != null) {
        final user = AppUser.fromJson(userPrefs);
        _selectedLanguages = user.dinnerLanguages ?? [];
        _selectedBudget = user.dinnerBudget;
        _hasDietaryRestrictions = user.hasDietaryRestrictions;
        _selectedDietaryOptions = user.dietaryOptions ?? [];

        // Set showConfirmation based on complete preferences
        _showConfirmation =
            _selectedLanguages.isNotEmpty && _selectedBudget != null;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading preferences: $e');
      // Could add error state handling here
    }

    _setLoading(false);
  }

  // Save preferences
  Future<void> savePreferences() async {
    try {
      await ApiService.updateUserPreferences(
        dinnerLanguages: _selectedLanguages,
        dinnerBudget: _selectedBudget,
        hasDietaryRestrictions: _hasDietaryRestrictions,
        dietaryOptions: _selectedDietaryOptions,
      );
    } catch (e) {
      print('Error saving preferences: $e');
      rethrow; // Let UI handle the error display
    }
  }

  // Language selection methods
  void toggleLanguage(String language) {
    if (_selectedLanguages.contains(language)) {
      _selectedLanguages.remove(language);
    } else {
      _selectedLanguages.add(language);
    }
    notifyListeners();
  }

  // Budget selection methods
  void selectBudget(String budget) {
    if (_selectedBudget == budget) {
      _selectedBudget = null;
    } else {
      _selectedBudget = budget;
    }
    notifyListeners();
  }

  // Dietary restrictions methods
  void toggleDietaryRestrictions(bool value) {
    _hasDietaryRestrictions = value;
    if (!value) {
      _selectedDietaryOptions.clear();
    }
    notifyListeners();
  }

  void toggleDietaryOption(String option) {
    if (_selectedDietaryOptions.contains(option)) {
      _selectedDietaryOptions.remove(option);
    } else {
      _selectedDietaryOptions.add(option);
    }
    notifyListeners();
  }

  // View management
  Future<void> showPreferencesForm() async {
    _showConfirmation = false;
    notifyListeners();
    await savePreferences();
  }

  Future<void> showConfirmationView() async {
    if (canContinue()) {
      _showConfirmation = true;
      notifyListeners();
      await savePreferences();
    }
  }

  // Validation
  bool canContinue() {
    return _selectedLanguages.isNotEmpty && _selectedBudget != null;
  }

  // Booking process
  Future<void> confirmBooking(BuildContext context) async {
    if (_isBooking) return;

    _setBooking(true);

    // Haptic feedback
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(seconds: 1));

    // Vibration
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }

    try {
      // Save preferences first
      await savePreferences();

      // Check subscription status
      final subscriptionStatus = await AuthService.getSubscriptionStatus();
      await Future.delayed(const Duration(seconds: 1));

      final hasActiveSubscription =
          subscriptionStatus?['is_subscription_active'] ?? false;

      if (hasActiveSubscription) {
        await _processBookingWithSubscription(context);
      } else {
        await _navigateToSubscription(context);
      }
    } catch (e) {
      rethrow; // Let UI handle error display
    } finally {
      _setBooking(false);
    }
  }

  // Private booking methods
  Future<void> _processBookingWithSubscription(BuildContext context) async {
    await DinnerService.bookDinner(selectedDinner.id);
    await _navigateToSuccess(context);
  }

  Future<void> _navigateToSubscription(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      _buildPageRoute(
        SubscriptionScreen(
          onSubscribed: () async {
            await DinnerService.bookDinner(selectedDinner.id);
            await _navigateToSuccess(context);
          },
        ),
      ),
    );
  }

  Future<void> _navigateToSuccess(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      _buildPageRoute(BookingSuccessScreen(bookedDinner: selectedDinner)),
    );
  }

  PageRouteBuilder _buildPageRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 800),
    );
  }

  // Utility methods
  String getDietaryPreferencesText() {
    if (!_hasDietaryRestrictions || _selectedDietaryOptions.isEmpty) {
      return 'No restrictions';
    }
    return _selectedDietaryOptions.join(', ');
  }

  String getSelectedLanguagesText() {
    return _selectedLanguages.isNotEmpty
        ? _selectedLanguages.join(', ')
        : 'Not selected';
  }

  String getSelectedBudgetText() {
    return _selectedBudget ?? 'Not selected';
  }

  // Private state management methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setBooking(bool booking) {
    _isBooking = booking;
    notifyListeners();
  }
}
