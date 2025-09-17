// lib/screens/Home/booking_success_screen.dart
import 'package:flutter/material.dart';
import '../../models/dinner_model.dart';
import './controllers/booking_success_controller.dart';
import './components/booking_success_components.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Dinner bookedDinner;

  const BookingSuccessScreen({
    Key? key,
    required this.bookedDinner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF1DE),
      body: SafeArea(
        child: BookingSuccessComponents.buildScrollableContainer(
          context: context,
          child: BookingSuccessComponents.buildMainContent(
            dinner: bookedDinner,
            successMessage: BookingSuccessController.getSuccessMessage(),
            onViewBookings: () =>
                BookingSuccessController.navigateToBookings(context),
            onBackToHome: () =>
                BookingSuccessController.navigateToHome(context),
          ),
        ),
      ),
    );
  }
}
