// lib/controllers/booking_success_controller.dart
import 'package:flutter/material.dart';
import '../../../models/dinner_model.dart';
import '../../../screens/bookings_screen.dart';
import '../../../screens/main_screen.dart';

class BookingSuccessController {
  // Navigation methods
  static void navigateToBookings(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BookingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Start from right
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
      (route) => false, // Remove all previous routes
    );
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0); // Start from left
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
      (route) => false, // Remove all previous routes
    );
  }

  // Data formatting methods
  static String getFormattedDateTime(Dinner dinner) {
    return '${dinner.formattedDate} at ${dinner.formattedTime}';
  }

  static String getSuccessMessage() {
    return 'Your dinner reservation has been successfully booked. You\'ll receive a confirmation email shortly.';
  }
}
