// lib/controllers/home_screen_controller.dart
import 'package:flutter/material.dart';
import '../../../models/dinner_model.dart';
import '../../../models/rating_model.dart';
import '../../../services/dinner_service.dart';
import '../../Home/dinner_preferences_screen.dart';

class HomeScreenController extends ChangeNotifier {
  bool _disposed = false;

  // Dinner data
  List<Dinner> _availableDinners = [];
  Dinner? _selectedDinner;

  // Loading and error states
  bool _isLoading = true;
  String? _errorMessage;

  // Rating data
  List<Booking> _ratableBookings = [];
  bool _hasRatableBooking = false;
  int _currentRating = 0;
  bool _isSubmittingRating = false;

  // Callback for navigation
  final VoidCallback? onSwitchToConnect;

  HomeScreenController({this.onSwitchToConnect});

  // Getters
  List<Dinner> get availableDinners => _availableDinners;
  Dinner? get selectedDinner => _selectedDinner;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Booking> get ratableBookings => _ratableBookings;
  bool get hasRatableBooking => _hasRatableBooking;
  int get currentRating => _currentRating;
  bool get isSubmittingRating => _isSubmittingRating;

  // Computed properties
  String get availableDinnersText {
    if (_isLoading) return 'Loading available dinners...';
    if (_availableDinners.isEmpty) return 'No dinners available';
    return '${_availableDinners.length} dinner${_availableDinners.length == 1 ? '' : 's'} available';
  }

  String get headerTitle {
    return _hasRatableBooking
        ? 'Other available dinners'
        : 'Book your next event';
  }

  // Initialization
  Future<void> initialize() async {
    await Future.wait([
      loadAvailableDinners(),
      loadRatableBookings(),
    ]);
  }

  // Load available dinners
  Future<void> loadAvailableDinners() async {
    if (_disposed) return; // Add check

    _setLoading(true);
    _setError(null);

    try {
      final results = await Future.wait([
        DinnerService.getAvailableDinners(),
        DinnerService.getUserBookings(),
      ]);

      if (_disposed) return; // Add check after async

      final dinners = results[0] as List<Dinner>?;
      final userBookings = results[1] as List<Map<String, dynamic>>?;

      if (dinners != null) {
        final bookedDinnerIds = _getBookedDinnerIds(userBookings);
        final availableDinners = dinners
            .where((dinner) => !bookedDinnerIds.contains(dinner.id))
            .toList();

        _availableDinners = availableDinners;
        _updateSelectedDinner(availableDinners);

        if (availableDinners.isEmpty && dinners.isNotEmpty) {
          _setError("You have already booked all available dinners");
        } else if (dinners.isEmpty) {
          _setError("No dinners available at the moment");
        }
      } else {
        _availableDinners = [];
        _selectedDinner = null;
        _setError("No dinners available at the moment");
      }
    } catch (e) {
      if (!_disposed) {
        _setError("Failed to load dinners: ${e.toString()}");
      }
    } finally {
      if (!_disposed) {
        _setLoading(false);
      }
    }
  }

  // Load ratable bookings
  Future<void> loadRatableBookings() async {
    if (_disposed) return; // Add check

    try {
      final ratableBookings = await DinnerService.getRatableBookings();

      if (_disposed) return; // Add check after async

      _ratableBookings = ratableBookings ?? [];
      _hasRatableBooking = _ratableBookings.isNotEmpty;
      notifyListeners();
    } catch (e) {
      if (!_disposed) {
        _ratableBookings = [];
        _hasRatableBooking = false;
        notifyListeners();
      }
    }
  }

  // Helper method to get booked dinner IDs
  Set<int> _getBookedDinnerIds(List<Map<String, dynamic>>? userBookings) {
    final bookedDinnerIds = <int>{};
    if (userBookings != null) {
      for (var booking in userBookings) {
        final status = booking['status']?.toString().toLowerCase();
        if (status == 'confirmed' || status == 'pending') {
          bookedDinnerIds.add(booking['dinner_id'] as int);
        }
      }
    }
    return bookedDinnerIds;
  }

  // Helper method to update selected dinner
  void _updateSelectedDinner(List<Dinner> availableDinners) {
    if (availableDinners.isNotEmpty) {
      if (_selectedDinner == null ||
          !availableDinners.any((dinner) => dinner.id == _selectedDinner!.id)) {
        _selectedDinner = availableDinners.first;
      }
    } else {
      _selectedDinner = null;
    }
  }

  // Dinner selection
  void selectDinner(Dinner dinner) {
    _selectedDinner = dinner;
    notifyListeners();
  }

  // Rating methods
  void setRating(int rating) {
    _currentRating = rating;
    notifyListeners();
  }

  Future<void> submitRating() async {
    if (_currentRating == 0 || _ratableBookings.isEmpty) return;

    _setSubmittingRating(true);

    try {
      final firstRatableBooking = _ratableBookings.first;
      await DinnerService.rateDinner(
        bookingId: firstRatableBooking.bookingId,
        rating: _currentRating,
      );

      // Reload to hide the rating section
      await loadRatableBookings();
      _currentRating = 0;

      // Return success for UI to show snackbar
      return;
    } catch (e) {
      rethrow; // Let UI handle error display
    } finally {
      _setSubmittingRating(false);
    }
  }

  // Navigation methods
  void startConnecting() {
    onSwitchToConnect?.call();
  }

  Future<void> bookSelectedDinner(BuildContext context) async {
    if (_selectedDinner == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DinnerPreferencesScreen(
          selectedDinner: _selectedDinner!,
        ),
      ),
    );

    // Reload dinners after booking attempt
    await loadAvailableDinners();
  }

  // Refresh method
  Future<void> refresh() async {
    await initialize();
  }

  // Private state management methods
  void _setLoading(bool loading) {
    if (_disposed) return; // Add check
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    if (_disposed) return; // Add check
    _errorMessage = error;
    notifyListeners();
  }

  void _setSubmittingRating(bool submitting) {
    if (_disposed) return; // Add check
    _isSubmittingRating = submitting;
    notifyListeners();
  }

  // Validation
  bool get canBookDinner => _selectedDinner != null;

  String get bookButtonText {
    return _selectedDinner != null ? 'Book my seat' : 'Select a dinner to book';
  }

  // Get ratable booking for header
  Booking? get firstRatableBooking {
    return _ratableBookings.isNotEmpty ? _ratableBookings.first : null;
  }

  @override
  void dispose() {
    _disposed = true; // Set flag before disposing
    super.dispose();
  }
}
