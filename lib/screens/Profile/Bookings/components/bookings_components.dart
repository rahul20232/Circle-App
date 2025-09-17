// lib/screens/Profile/Bookings/bookings_components.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/Bookings/controllers/bookings_controller.dart';
import 'package:timeleft_clone/components/Cards/SwipableBookingCard.dart';
import 'package:timeleft_clone/services/push_notification_service.dart';

class BookingsComponents {
  final BookingsController controller;

  BookingsComponents({required this.controller});

  Widget buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red.shade600,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.loadUserBookings,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: Colors.black,
            ),
            SizedBox(height: 24),
            Text(
              'No dinner yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You must have attended a first dinner to see your reservations appear.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.navigateToBookingScreen(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Book my seat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBookingsList(BuildContext context) {
    final filteredBookings = controller.filteredAndSortedBookings;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildBookingsHeader(filteredBookings.length),
          SizedBox(height: 20),
          ...filteredBookings
              .map((booking) => buildBookingCard(context, booking)),
          SizedBox(height: 30),
          buildBookAnotherButton(context),
        ],
      ),
    );
  }

  Widget buildBookingsHeader(int bookingCount) {
    return Column(
      children: [
        Text(
          'Your Bookings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '$bookingCount booking${bookingCount == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget buildBookingCard(BuildContext context, Map<String, dynamic> booking) {
    final dinnerDate = DateTime.parse(booking['dinner_date']);
    final isPastDinner = controller.isPastDinner(booking);
    final displayStatus = controller.getDisplayStatus(booking);
    final canCancel = controller.canCancelBooking(booking);

    return SwipeableBookingCard(
      title: booking['dinner_title'] ?? 'Dinner',
      date: controller.formatDate(dinnerDate),
      time: controller.formatTime(dinnerDate),
      location: booking['dinner_location'] ?? 'Location TBD',
      status: displayStatus,
      availableSpots: isPastDinner ? 0 : 6,
      isPastDinner: isPastDinner,
      canCancel: canCancel,
      onTap: () => controller.navigateToBookingDetail(context, booking),
      onCancel: () =>
          controller.handleBookingCancellation(booking['id'], context),
    );
  }

  Widget buildBookAnotherButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => controller.navigateToBookingScreen(context),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.black, width: 1.5),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Book another dinner',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void showNotificationTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications_outlined, size: 20),
              SizedBox(width: 8),
              Text('Test Notifications'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildNotificationStatus(),
              SizedBox(height: 16),
              buildIOSForegroundInfo(),
              SizedBox(height: 16),
              buildNotificationInstructions(),
            ],
          ),
          actions: [
            buildNotificationTestButtons(context),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget buildNotificationStatus() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notification Status:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
              'Initialized: ${PushNotificationService.isInitialized ? "✅" : "❌"}'),
          Text(
              'Remote: ${PushNotificationService.hasRemoteNotifications ? "✅" : "❌"}'),
        ],
      ),
    );
  }

  Widget buildIOSForegroundInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
              SizedBox(width: 4),
              Text('iOS Foreground Behavior',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Native notifications are suppressed when app is in foreground. This is normal iOS behavior.',
            style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose notification test:',
            style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Text('• Standard: In-app + native (may be suppressed)',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text('• Forced: Uses 100ms delay to bypass suppression',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text('• Smart: Adapts behavior based on app state',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget buildNotificationTestButtons(BuildContext context) {
    return Wrap(
      children: [
        buildNotificationButton(
          context,
          'Standard',
          Icons.notifications,
          Colors.blue,
          () => _testStandardNotification(context),
        ),
        buildNotificationButton(
          context,
          'Force',
          Icons.rocket_launch,
          Colors.purple,
          () => _testForcedNotification(context),
        ),
        buildNotificationButton(
          context,
          'Smart',
          Icons.psychology,
          Colors.teal,
          () => _testSmartNotification(context),
        ),
        buildNotificationButton(
          context,
          '3s Delay',
          Icons.schedule,
          Colors.grey,
          () => _testDelayedNotification(context),
        ),
        buildNotificationButton(
          context,
          'Dinner',
          Icons.restaurant,
          Colors.orange,
          () => _testDinnerReminder(context),
        ),
      ],
    );
  }

  Widget buildNotificationButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 8, bottom: 8),
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          onPressed();
        },
        icon: Icon(icon, size: 16),
        label: Text(text),
        style: TextButton.styleFrom(foregroundColor: color),
      ),
    );
  }

  Future<void> _testStandardNotification(BuildContext context) async {
    try {
      await PushNotificationService.testLocalNotification(
        title: 'Standard Test',
        body:
            'Shows in-app immediately. Native may be suppressed in foreground.',
      );
    } catch (e) {
      _showNotificationError(context, e.toString());
    }
  }

  Future<void> _testForcedNotification(BuildContext context) async {
    try {
      await PushNotificationService.testLocalNotification(
        title: 'Forced Test',
        body: 'Uses micro-delay to bypass foreground suppression!',
        forceForegroundNotification: true,
      );
    } catch (e) {
      _showNotificationError(context, e.toString());
    }
  }

  Future<void> _testSmartNotification(BuildContext context) async {
    try {
      await PushNotificationService.sendSmartNotification(
        title: 'Smart Test',
        body: 'Adapts to app state - immediate in-app, delayed native',
      );
    } catch (e) {
      _showNotificationError(context, e.toString());
    }
  }

  Future<void> _testDelayedNotification(BuildContext context) async {
    await PushNotificationService.testLocalNotification(
      title: 'Delayed Test',
      body: 'This notification was scheduled 3 seconds ago',
      scheduleAfterSeconds: 3,
    );
  }

  Future<void> _testDinnerReminder(BuildContext context) async {
    await PushNotificationService.scheduleDinnerReminder(
      dinnerTime: DateTime.now().add(Duration(seconds: 10)),
      restaurantName: 'Test Restaurant',
      hoursBeforeReminder: 0,
    );
  }

  void _showNotificationError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
