// lib/screens/Profile/Bookings/bookings_controller.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/Bookings/bookings_detail_screen.dart';
import 'package:timeleft_clone/services/dinner_service.dart';
import 'package:timeleft_clone/models/dinner_model.dart';
import '../../../../screens/main_screen.dart';

class BookingsController {
  final VoidCallback onStateChanged;

  List<Map<String, dynamic>> _userBookings = [];
  List<Dinner> _allDinners = []; // To get dinner details
  bool _isLoading = true;
  String? _errorMessage;

  BookingsController({required this.onStateChanged});

  // Getters
  List<Map<String, dynamic>> get userBookings => _userBookings;
  List<Dinner> get allDinners => _allDinners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> get displayableBookings {
    return _userBookings.where((booking) {
      final dinnerDate = DateTime.parse(booking['dinner_date']);
      final isPastDinner = dinnerDate.isBefore(DateTime.now());
      final isConfirmed =
          booking['status']?.toString().toLowerCase() == 'confirmed';

      return !isPastDinner || (isPastDinner && isConfirmed);
    }).toList();
  }

  List<Map<String, dynamic>> get filteredAndSortedBookings {
    final filteredBookings = displayableBookings;

    // Custom sorting: 'confirmed' first, then 'cancelled', then 'past ones'
    filteredBookings.sort((a, b) {
      final dateA = DateTime.parse(a['dinner_date']);
      final dateB = DateTime.parse(b['dinner_date']);
      final isPastA = dateA.isBefore(DateTime.now());
      final isPastB = dateB.isBefore(DateTime.now());
      final statusA = a['status']?.toString().toLowerCase() ?? '';
      final statusB = b['status']?.toString().toLowerCase() ?? '';

      // Get priority for each booking (lower number = higher priority)
      int priorityA = _getBookingPriority(isPastA, statusA);
      int priorityB = _getBookingPriority(isPastB, statusB);

      // First sort by priority
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      // If same priority, sort by date (newest first within each category)
      return dateB.compareTo(dateA);
    });

    return filteredBookings;
  }

  void dispose() {
    // No controllers or streams to dispose in this case
  }

  void initialize() {
    loadUserBookings();
  }

  Future<void> loadUserBookings() async {
    _isLoading = true;
    _errorMessage = null;
    onStateChanged();

    try {
      // Load user bookings only - we'll use the dinner data from the booking response
      final bookings = await DinnerService.getUserBookings();

      _userBookings = bookings ?? [];
      _isLoading = false;
      onStateChanged();
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to load bookings: ${e.toString()}";
      onStateChanged();
    }
  }

  int _getBookingPriority(bool isPast, String status) {
    if (!isPast) {
      // Future bookings
      switch (status) {
        case 'confirmed':
          return 1; // Highest priority
        case 'pending':
          return 2;
        case 'cancelled':
          return 3;
        default:
          return 4;
      }
    } else {
      // Past bookings - lowest priority
      return 5; // All past bookings get same priority since you only show confirmed past ones
    }
  }

  Future<void> handleBookingCancellation(
      int bookingId, BuildContext context) async {
    // Store references before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final success = await DinnerService.removeBookingFromHistory(bookingId);

      if (success) {
        // Refresh the bookings list
        await loadUserBookings();

        // Show success message
        try {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Booking removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print('Error showing success message: $e');
        }
      } else {
        // Show error message
        try {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Failed to remove booking'),
              backgroundColor: Colors.red,
            ),
          );
        } catch (e) {
          print('Error showing error message: $e');
        }
      }
    } catch (e) {
      // Handle API errors
      try {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (snackError) {
        print('Error showing error snackbar: $snackError');
      }
    }
  }

  Future<void> navigateToBookingDetail(
    BuildContext context,
    Map<String, dynamic> booking,
  ) async {
    final dinnerDate = DateTime.parse(booking['dinner_date']);
    final isPastDinner = dinnerDate.isBefore(DateTime.now());

    // Create a temporary dinner object from booking data
    final tempDinner = Dinner(
      id: booking['dinner_id'],
      title: booking['dinner_title'],
      date: dinnerDate,
      location: booking['dinner_location'],
      latitude: booking['dinner_latitude'],
      longitude: booking['dinner_longitude'],
      availableSpots: isPastDinner ? 0 : 6, // No spots for past dinners
      currentAttendees: 0,
      isFull: isPastDinner,
      maxAttendees: 6,
      isActive: !isPastDinner,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(
          booking: booking,
          dinner: tempDinner,
        ),
      ),
    );

    if (result != null && result['refreshNeeded'] == true) {
      loadUserBookings();
    }
  }

  void navigateToMainScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainScreen(initialIndex: 0), // ensure home tab
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0); // slide from left
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
      (route) => false, // clear stack
    );
  }

  void navigateToBookingScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  // Helper methods for formatting
  String formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String formatTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String getDisplayStatus(Map<String, dynamic> booking) {
    final dinnerDate = DateTime.parse(booking['dinner_date']);
    final isPastDinner = dinnerDate.isBefore(DateTime.now());
    final bookingStatus = booking['status']?.toString() ?? 'Unknown';

    return isPastDinner ? 'Past' : bookingStatus;
  }

  bool canCancelBooking(Map<String, dynamic> booking) {
    final dinnerDate = DateTime.parse(booking['dinner_date']);
    final isPastDinner = dinnerDate.isBefore(DateTime.now());
    final bookingStatus = booking['status']?.toString() ?? '';

    return isPastDinner || bookingStatus.toLowerCase() == 'cancelled';
  }

  bool isPastDinner(Map<String, dynamic> booking) {
    final dinnerDate = DateTime.parse(booking['dinner_date']);
    return dinnerDate.isBefore(DateTime.now());
  }
}
