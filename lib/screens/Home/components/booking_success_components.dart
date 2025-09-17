// lib/components/booking_success_components.dart
import 'package:flutter/material.dart';
import '../../../models/dinner_model.dart';

class BookingSuccessComponents {
  // Success Icon Widget
  static Widget buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFF00C853),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  // Success Title Widget
  static Widget buildSuccessTitle() {
    return const Text(
      'Booking Confirmed!',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Success Message Widget
  static Widget buildSuccessMessage(String message) {
    return Text(
      message,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Dinner Details Card Widget
  static Widget buildDinnerDetailsCard(Dinner dinner) {
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
          const Text(
            'Dinner Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          buildDetailRow(
            Icons.event,
            'Event',
            dinner.title,
          ),
          const SizedBox(height: 12),
          buildDetailRow(
            Icons.access_time,
            'Date & Time',
            '${dinner.formattedDate} at ${dinner.formattedTime}',
          ),
          const SizedBox(height: 12),
          buildDetailRow(
            Icons.location_on_outlined,
            'Location',
            dinner.location,
          ),
        ],
      ),
    );
  }

  // Detail Row Widget
  static Widget buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Primary Action Button Widget
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
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
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Secondary Action Button Widget
  static Widget buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
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
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Action Buttons Column Widget
  static Widget buildActionButtons({
    required VoidCallback onViewBookings,
    required VoidCallback onBackToHome,
  }) {
    return Column(
      children: [
        buildPrimaryButton(
          text: 'View My Bookings',
          onPressed: onViewBookings,
        ),
        const SizedBox(height: 16),
        buildSecondaryButton(
          text: 'Back to Home',
          onPressed: onBackToHome,
        ),
      ],
    );
  }

  // Main Content Column Widget
  static Widget buildMainContent({
    required Dinner dinner,
    required String successMessage,
    required VoidCallback onViewBookings,
    required VoidCallback onBackToHome,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSuccessIcon(),
        const SizedBox(height: 40),
        buildSuccessTitle(),
        const SizedBox(height: 16),
        buildSuccessMessage(successMessage),
        const SizedBox(height: 40),
        buildDinnerDetailsCard(dinner),
        const Spacer(), // Push buttons to bottom when there's extra space
        const SizedBox(height: 40),
        buildActionButtons(
          onViewBookings: onViewBookings,
          onBackToHome: onBackToHome,
        ),
        const SizedBox(height: 20), // Bottom padding
      ],
    );
  }

  // Scrollable Container Widget
  static Widget buildScrollableContainer({
    required BuildContext context,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              40,
        ),
        child: IntrinsicHeight(
          child: child,
        ),
      ),
    );
  }
}
