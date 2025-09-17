// lib/screens/Profile/Settings/settings_controller.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/Settings/delete_account_confirm_screen.dart';
import 'package:timeleft_clone/screens/Profile/Settings/last_minute_booking_preferences_screen.dart';
import 'package:timeleft_clone/screens/Auth/login_screen.dart';
import 'package:timeleft_clone/screens/Profile/Settings/marketing_preferences_screen.dart';
import 'package:timeleft_clone/screens/Profile/Settings/private_policy_screen.dart';
import 'package:timeleft_clone/screens/Profile/Settings/update_subscription_screen.dart';
import 'package:timeleft_clone/services/auth_service.dart';
import '../subscription_screen.dart';
import '../event_alert_screen.dart';

class SettingsController {
  final VoidCallback onStateChanged;

  bool _isLoading = false;
  String _appVersion = "v3.5.2";

  SettingsController({required this.onStateChanged});

  // Getters
  bool get isLoading => _isLoading;
  String get appVersion => _appVersion;
  String get currentUser =>
      AuthService.currentUser?.toString() ?? "Unknown User";

  void dispose() {
    // No controllers or streams to dispose in this case
  }

  void initialize() {
    // Settings screen initialization if needed
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    onStateChanged();
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Navigation methods for settings items
  Future<void> navigateToSettingsItem(
      BuildContext context, String title) async {
    switch (title) {
      case "Privacy Policy":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
        );
        break;
      case "Dinner Alerts":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventAlertScreen()),
        );
        break;
      case "Last-Minute Booking":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LastMinuteBookingScreen()),
        );
        break;
      case "Marketing":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MarketingAlertScreen()),
        );
        break;
      default:
        _showSnackBar(context, '$title tapped!', isError: false);
        break;
    }
  }

  // Subscription navigation with status check
  Future<void> navigateToSubscription(BuildContext context) async {
    _setLoading(true);

    try {
      final subscriptionStatus = await AuthService.getSubscriptionStatus();
      print("STATUS ${subscriptionStatus}");

      final hasActiveSubscription =
          subscriptionStatus?['is_subscription_active'] ?? false;
      final targetScreen = hasActiveSubscription
          ? UpdateSubscriptionScreen()
          : SubscriptionScreen();

      _setLoading(false);

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Start from bottom
            const end = Offset.zero; // End at center
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 800),
          reverseTransitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      _setLoading(false);
      print('Error checking subscription status: $e');
      _showSnackBar(context, 'Failed to check subscription status');
    }
  }

  // Logout functionality
  Future<void> logout(BuildContext context) async {
    _setLoading(true);

    try {
      await AuthService.signOut();

      _setLoading(false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      _setLoading(false);
      print('Error during logout: $e');
      _showSnackBar(context, 'Failed to log out');
    }
  }

  // Navigate to delete account screen
  void navigateToDeleteAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteAccountScreen(),
      ),
    );
  }

  // Settings sections data
  List<String> get notificationItems => [
        "Dinner Alerts",
        "Last-Minute Booking",
        "Marketing",
      ];

  List<String> get subscriptionItems => [
        "Subscribe to Timeleft",
      ];

  List<String> get legalItems => [
        "Privacy Policy",
        "Terms & Conditions",
        "Community Guidelines",
      ];

  // Helper methods for section management
  bool hasNotificationSettings() {
    return notificationItems.isNotEmpty;
  }

  bool hasSubscriptionSettings() {
    return subscriptionItems.isNotEmpty;
  }

  bool hasLegalSettings() {
    return legalItems.isNotEmpty;
  }

  // Version management
  void updateAppVersion(String version) {
    _appVersion = version;
    onStateChanged();
  }

  String getFormattedVersion() {
    return _appVersion;
  }

  // User state checks
  bool get isUserLoggedIn => AuthService.currentUser != null;

  // Navigation helpers
  Future<void> handleSettingsNavigation(
    BuildContext context,
    String section,
    String item,
  ) async {
    switch (section) {
      case 'notifications':
        await navigateToSettingsItem(context, item);
        break;
      case 'subscription':
        await navigateToSubscription(context);
        break;
      case 'legal':
        await navigateToSettingsItem(context, item);
        break;
      default:
        _showSnackBar(context, 'Unknown section: $section');
    }
  }
}
