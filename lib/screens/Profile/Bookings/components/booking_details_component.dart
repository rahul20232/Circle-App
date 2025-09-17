// lib/screens/Profile/Bookings/booking_details_components.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeleft_clone/screens/Profile/Bookings/controllers/booking_details_controller.dart';

class BookingDetailsComponents {
  final BookingDetailsController controller;

  BookingDetailsComponents({required this.controller});

  Widget buildTitle() {
    return Text(
      controller.dinnerTitle,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: controller
            .getStatusColor(controller.displayStatus)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: controller.getStatusColor(controller.displayStatus),
          width: 1,
        ),
      ),
      child: Text(
        controller.displayStatus.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: controller.getStatusColor(controller.displayStatus),
        ),
      ),
    );
  }

  Widget buildDateTimeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.black87, size: 20),
              SizedBox(width: 8),
              Text(
                'Date & Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            controller.formatDate(controller.dinner!.date),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            controller.formatTime(controller.dinner!.date),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLocationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLocationHeader(),
          buildLocationAddress(),
          SizedBox(height: 16),
          buildMapSection(),
          buildDirectionsButton(),
        ],
      ),
    );
  }

  Widget buildLocationHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.red.shade400, size: 20),
          SizedBox(width: 8),
          Text(
            'Restaurant Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLocationAddress() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        controller.dinnerLocation,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget buildMapSection() {
    if (controller.restaurantLocation != null) {
      return Container(
        height: 200,
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GoogleMap(
            onMapCreated: controller.setMapController,
            initialCameraPosition: CameraPosition(
              target: controller.restaurantLocation!,
              zoom: 15.0,
            ),
            markers: controller.markers,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
          ),
        ),
      );
    } else {
      return buildMapFallback();
    }
  }

  Widget buildMapFallback() {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text(
              'Location not available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDirectionsButton() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: controller.hasValidLocation ? controller.openInMaps : null,
          icon: Icon(Icons.directions, size: 18),
          label: Text('Get Directions'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: Colors.blue, width: 1.5),
            foregroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAvailableSpotsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Colors.green.shade600, size: 20),
              SizedBox(width: 8),
              Text(
                'Available Spots',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '${controller.availableSpots} spots remaining',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBookingIdCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking ID',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            controller.bookingId,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons(
      BuildContext context, NavigatorState? cachedNavigator) {
    if (controller.shouldShowConnectButton) {
      return buildConnectButton(context);
    } else if (controller.shouldShowCancelButton) {
      return buildCancelButton(context, cachedNavigator);
    }
    return SizedBox.shrink();
  }

  Widget buildConnectButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => controller.navigateToConnectScreen(context),
        icon: Icon(Icons.people, size: 18),
        label: Text('Connect with Attendees'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Color(0xFF6B46C1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget buildCancelButton(
      BuildContext context, NavigatorState? cachedNavigator) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => showCancelBookingDialog(context, cachedNavigator),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Cancel Booking',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void showCancelBookingDialog(
      BuildContext context, NavigatorState? cachedNavigator) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFFFEF1DE),
          title: Text(
            'Cancel Booking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                try {
                  Navigator.pop(dialogContext);
                } catch (e) {
                  print('Error closing dialog: $e');
                }
              },
              child: Text(
                'Keep Booking',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _handleDialogCancellation(
                    context, dialogContext, cachedNavigator);
              },
              child: Text(
                'Cancel Booking',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDialogCancellation(
    BuildContext context,
    BuildContext dialogContext,
    NavigatorState? cachedNavigator,
  ) {
    // Close dialog immediately
    try {
      Navigator.pop(dialogContext);
    } catch (e) {
      print('Error closing dialog: $e');
    }

    // Handle the booking cancellation
    controller.handleBookingCancellation(context, cachedNavigator);
  }

  // Helper widgets for consistent styling
  Widget buildInfoCard({
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildSectionHeader({
    required String title,
    required IconData icon,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Colors.black87, size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
