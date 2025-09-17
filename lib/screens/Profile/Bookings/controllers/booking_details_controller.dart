// lib/screens/Profile/Bookings/booking_details_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeleft_clone/models/dinner_model.dart';
import 'package:timeleft_clone/services/dinner_service.dart';
import 'package:timeleft_clone/screens/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class BookingDetailsController {
  final Map<String, dynamic> booking;
  final Dinner? dinner;
  final VoidCallback onStateChanged;

  GoogleMapController? _mapController;
  LatLng? _restaurantLocation;
  Set<Marker> _markers = {};

  BookingDetailsController({
    required this.booking,
    this.dinner,
    required this.onStateChanged,
  });

  // Getters
  GoogleMapController? get mapController => _mapController;
  LatLng? get restaurantLocation => _restaurantLocation;
  Set<Marker> get markers => _markers;

  bool get isPastDinner {
    if (dinner == null) return false;
    return dinner!.date.isBefore(DateTime.now());
  }

  String get displayStatus {
    if (isPastDinner) {
      return 'Past';
    }
    return booking['status']?.toString() ?? 'Unknown';
  }

  void dispose() {
    // No specific disposal needed for this controller
  }

  void initialize() {
    _initializeLocation();
  }

  void _initializeLocation() {
    if (dinner?.location != null) {
      // Use actual coordinates if available, otherwise default to Bengaluru
      if (dinner!.latitude != null && dinner!.longitude != null) {
        _restaurantLocation = LatLng(dinner!.latitude!, dinner!.longitude!);
      } else {
        // Fallback to default coordinates
        _restaurantLocation = LatLng(12.9716, 77.5946);
      }

      _markers.add(
        Marker(
          markerId: MarkerId('restaurant'),
          position: _restaurantLocation!,
          infoWindow: InfoWindow(
            title: dinner?.title ?? 'Restaurant',
            snippet: dinner?.location,
          ),
        ),
      );
    }
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  // Helper method to format date
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

  // Helper method to format time
  String formatTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Helper method to get status color
  Color getStatusColor(String status) {
    if (isPastDinner) {
      return Colors.orange.shade600; // Orange for past dinners
    }

    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void navigateToConnectScreen(BuildContext context) {
    final dinnerId = dinner?.id;
    if (dinnerId == null) return;

    // Navigate to MainScreen with Connect tab and pass dinner ID
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          initialIndex: 2, // Connect tab
          dinnerIdForAttendees: dinnerId,
        ),
      ),
      (route) => false, // Clear all previous routes
    );
  }

  void openInMaps() async {
    if (_restaurantLocation != null) {
      final lat = _restaurantLocation!.latitude;
      final lng = _restaurantLocation!.longitude;
      print('Opening maps for location: $lat, $lng');
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  Future<void> handleBookingCancellation(
    BuildContext context,
    NavigatorState? cachedNavigator,
  ) async {
    // Early exit if widget is disposed
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (cachedNavigator == null) return;

    // Show loading
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => Center(
          child: CircularProgressIndicator(),
        ),
      );
    } catch (e) {
      print('Error showing loading dialog: $e');
      return;
    }

    try {
      HapticFeedback.heavyImpact();

      await Future.delayed(Duration(seconds: 1));

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50); // Short 50ms buzz
      }

      final bookingId = booking['id'] as int;
      final success = await DinnerService.cancelBooking(bookingId);

      // Close loading dialog
      try {
        cachedNavigator.pop();
      } catch (e) {
        print('Error closing loading dialog: $e');
      }

      if (success) {
        // Return to bookings screen
        try {
          cachedNavigator.pop({'refreshNeeded': true});
        } catch (e) {
          print('Error navigating back: $e');
        }

        // Show success message
        try {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Booking cancelled successfully'),
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
              content: Text('Failed to cancel booking'),
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
        cachedNavigator.pop(); // Close loading
      } catch (navError) {
        print('Error closing loading on error: $navError');
      }

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

  // Action button visibility logic
  bool get shouldShowConnectButton {
    return isPastDinner &&
        booking['status']?.toString().toLowerCase() == 'confirmed';
  }

  bool get shouldShowCancelButton {
    return !isPastDinner &&
        booking['status']?.toString().toLowerCase() == 'confirmed';
  }

  // Validation helpers
  bool get hasValidLocation => _restaurantLocation != null;
  bool get hasMapData => _markers.isNotEmpty;

  String get bookingId => booking['id']?.toString() ?? 'N/A';
  String get dinnerTitle => dinner?.title ?? 'Dinner Booking';
  String get dinnerLocation => dinner?.location ?? 'Location not available';
  int get availableSpots => dinner?.availableSpots ?? 0;
}
