// lib/screens/Profile/Settings/update_subscription_controller.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/components/Modals/payment_modal.dart';
import 'package:timeleft_clone/services/auth_service.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class UpdateSubscriptionController {
  final VoidCallback onStateChanged;

  int _selectedPlan = 1; // Default to middle plan (3 months)
  int _currentSlide = 0;
  int? _currentUserPlanIndex; // Track user's current plan

  UpdateSubscriptionController({required this.onStateChanged});

  // Getters
  int get selectedPlan => _selectedPlan;
  int get currentSlide => _currentSlide;
  int? get currentUserPlanIndex => _currentUserPlanIndex;

  // Plan data
  final List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=2070&q=80',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=2070&q=80',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=2070&q=80',
  ];

  final List<Map<String, dynamic>> _planData = [
    {
      'title': 'Discover',
      'duration': '1 Month',
      'monthlyPrice': '₹1,099.00/m',
      'totalPrice': '₹1,099.00',
      'planId': 'discover_1m',
    },
    {
      'title': 'Save 21%',
      'duration': '3 Months',
      'monthlyPrice': '₹866.33/m',
      'totalPrice': '₹2,599.00',
      'planId': 'save_3m',
    },
    {
      'title': 'Save 47%',
      'duration': '6 Months',
      'monthlyPrice': '₹583.17/m',
      'totalPrice': '₹3,499.02',
      'planId': 'save_6m',
    },
  ];

  void dispose() {
    // No controllers or streams to dispose in this case
  }

  void initialize() {
    _loadUserSubscription();
  }

  void _loadUserSubscription() {
    final user = AuthService.currentUser;

    if (user == null) {
      print("⚠️ No user found in AuthService.currentUser");
      return;
    }

    // Debug logging
    print("📊 Full user object: ${user.toString()}");
    print("📊 User subscription details:");
    print("   - isSubscribed: ${user.isSubscribed}");
    print("   - subscriptionType: ${user.subscriptionType}");
    print("   - subscriptionPlanId: ${user.subscriptionPlanId}");

    String? planId = user.subscriptionPlanId;
    print("✅ Subscription Plan ID: $planId");

    // Map subscription plan ID to the correct index
    if (planId != null) {
      _currentUserPlanIndex = _mapPlanIdToIndex(planId);
      _selectedPlan = _currentUserPlanIndex ?? 1;
    } else {
      // No subscription plan, default to 3-month plan
      _selectedPlan = 1;
      _currentUserPlanIndex = null;
    }

    print("Selected Plan Index: $_selectedPlan");
    print("Current User Plan Index: $_currentUserPlanIndex");

    onStateChanged();
  }

  int? _mapPlanIdToIndex(String planId) {
    switch (planId) {
      case 'discover_1m':
        return 0;
      case 'save_3m':
        return 1;
      case 'save_6m':
        return 2;
      default:
        print("Unknown subscription plan ID: $planId");
        return null;
    }
  }

  List<String> get carouselImages => _carouselImages;
  List<Map<String, dynamic>> get planData => _planData;

  void selectPlan(int index) {
    if (index >= 0 && index < _planData.length) {
      _selectedPlan = index;
      onStateChanged();
    }
  }

  void setCurrentSlide(int index) {
    _currentSlide = index;
    onStateChanged();
  }

  bool get isButtonEnabled {
    // Enable button only if user selects a different plan than their current one
    return _currentUserPlanIndex == null ||
        _selectedPlan != _currentUserPlanIndex;
  }

  String get selectedPlanPrice => _planData[_selectedPlan]['totalPrice'];

  String get buttonText {
    return _currentUserPlanIndex == null
        ? 'Subscribe Now'
        : 'Update Subscription';
  }

  void showPaymentModal(BuildContext context) {
    if (!isButtonEnabled) return;

    showCustomModalBottomSheet(
      context: context,
      duration: Duration(milliseconds: 600),
      animationCurve: Curves.easeInOut,
      isDismissible: false, // Set to false to handle manually
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context), // Dismiss when tapping outside
        child: Container(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {}, // Prevent dismissal when tapping the modal content
            child: PaymentModal(
              price: selectedPlanPrice,
              selectedPlan: _selectedPlan,
              onPaymentSuccess: () {
                Navigator.pop(context);
                Navigator.pop(context);
                _updateCurrentUserPlan();
              },
            ),
          ),
        ),
      ),
      containerWidget: (_, animation, child) => Material(
        color: Colors.transparent,
        child: child,
      ),
      enableDrag: false,
    );
  }

  void _updateCurrentUserPlan() {
    _currentUserPlanIndex = _selectedPlan;
    onStateChanged();
  }

  // Helper methods for plan information
  String getPlanTitle(int index) => _planData[index]['title'];
  String getPlanDuration(int index) => _planData[index]['duration'];
  String getPlanMonthlyPrice(int index) => _planData[index]['monthlyPrice'];
  String getPlanTotalPrice(int index) => _planData[index]['totalPrice'];
  String getPlanId(int index) => _planData[index]['planId'];

  bool isPlanSelected(int index) => _selectedPlan == index;
  bool isCurrentUserPlan(int index) => _currentUserPlanIndex == index;

  // Plan comparison methods
  bool get hasActiveSubscription => _currentUserPlanIndex != null;
  bool get isUpgrade =>
      hasActiveSubscription && _selectedPlan > _currentUserPlanIndex!;
  bool get isDowngrade =>
      hasActiveSubscription && _selectedPlan < _currentUserPlanIndex!;
  bool get isSamePlan =>
      hasActiveSubscription && _selectedPlan == _currentUserPlanIndex;

  String get subscriptionActionType {
    if (!hasActiveSubscription) return 'subscribe';
    if (isUpgrade) return 'upgrade';
    if (isDowngrade) return 'downgrade';
    return 'current';
  }

  // Terms and conditions text
  String get termsText =>
      'By selecting Subscribe, you will be charged, your subscription will auto-renew for the same price and package length until you cancel via settings, and you agree to our Terms. You also acknowledge the right to withdraw within 14 days for a pro-rated refund, with no refund available after 14 days.';

  // User subscription info
  String? get currentPlanId =>
      _currentUserPlanIndex != null ? getPlanId(_currentUserPlanIndex!) : null;
  String? get currentPlanTitle => _currentUserPlanIndex != null
      ? getPlanTitle(_currentUserPlanIndex!)
      : null;
  String? get currentPlanDuration => _currentUserPlanIndex != null
      ? getPlanDuration(_currentUserPlanIndex!)
      : null;

  // Validation
  bool get hasValidSelection =>
      _selectedPlan >= 0 && _selectedPlan < _planData.length;
  bool get canUpdateSubscription => isButtonEnabled && hasValidSelection;
}
