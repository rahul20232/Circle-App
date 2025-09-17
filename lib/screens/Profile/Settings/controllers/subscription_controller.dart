// lib/screens/Profile/Settings/subscription_controller.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/components/Modals/payment_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SubscriptionController {
  final VoidCallback? onSubscribed;
  final VoidCallback onStateChanged;

  int _selectedPlan = 1; // Default to middle plan (3 months)
  int _currentSlide = 0;

  SubscriptionController({
    this.onSubscribed,
    required this.onStateChanged,
  });

  // Getters
  int get selectedPlan => _selectedPlan;
  int get currentSlide => _currentSlide;

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
      'savePercentage': null,
    },
    {
      'title': 'Save 21%',
      'duration': '3 Months',
      'monthlyPrice': '₹866.33/m',
      'totalPrice': '₹2,599.00',
      'savePercentage': 21,
    },
    {
      'title': 'Save 47%',
      'duration': '6 Months',
      'monthlyPrice': '₹583.17/m',
      'totalPrice': '₹3,499.02',
      'savePercentage': 47,
    },
  ];

  void dispose() {
    // No controllers or streams to dispose in this case
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

  String get selectedPlanPrice => _planData[_selectedPlan]['totalPrice'];
  String get selectedPlanButtonText {
    final plan = _planData[_selectedPlan];
    return 'Get ${plan['duration'].toLowerCase()} for ${plan['totalPrice']}';
  }

  Map<String, dynamic> get selectedPlanData => _planData[_selectedPlan];

  void showPaymentModal(BuildContext context) {
    showCustomModalBottomSheet(
      context: context,
      duration: Duration(milliseconds: 600),
      animationCurve: Curves.easeInOut,
      isDismissible: true,
      builder: (context) => PaymentModal(
        price: selectedPlanPrice,
        selectedPlan: _selectedPlan,
        onPaymentSuccess: () {
          // Close the payment modal first
          Navigator.pop(context);

          if (onSubscribed != null) {
            onSubscribed!();
          }
          // Close the SubscriptionScreen (go back to settings)
          Navigator.pop(context);
        },
      ),
      containerWidget: (_, animation, child) => Material(
        color: Colors.transparent,
        child: child,
      ),
      enableDrag: false,
    );
  }

  // Helper methods for plan information
  String getPlanTitle(int index) => _planData[index]['title'];
  String getPlanDuration(int index) => _planData[index]['duration'];
  String getPlanMonthlyPrice(int index) => _planData[index]['monthlyPrice'];
  String getPlanTotalPrice(int index) => _planData[index]['totalPrice'];
  int? getPlanSavePercentage(int index) => _planData[index]['savePercentage'];

  bool isPlanSelected(int index) => _selectedPlan == index;

  // Validation
  bool get hasValidSelection =>
      _selectedPlan >= 0 && _selectedPlan < _planData.length;

  // Analytics helpers
  String get selectedPlanAnalytics {
    final plan = _planData[_selectedPlan];
    return '${plan['duration']}_${plan['totalPrice']}';
  }

  // Pricing calculations
  double get selectedPlanMonthlyCost {
    switch (_selectedPlan) {
      case 0:
        return 1099.00;
      case 1:
        return 866.33;
      case 2:
        return 583.17;
      default:
        return 1099.00;
    }
  }

  double get selectedPlanTotalCost {
    switch (_selectedPlan) {
      case 0:
        return 1099.00;
      case 1:
        return 2599.00;
      case 2:
        return 3499.02;
      default:
        return 1099.00;
    }
  }

  int get selectedPlanMonths {
    switch (_selectedPlan) {
      case 0:
        return 1;
      case 1:
        return 3;
      case 2:
        return 6;
      default:
        return 1;
    }
  }

  // Plan recommendation logic
  int get recommendedPlanIndex =>
      1; // Middle plan (3 months) as default recommendation

  bool get isRecommendedPlan => _selectedPlan == recommendedPlanIndex;

  // Terms and conditions text
  String get termsText =>
      'By selecting Subscribe, you will be charged, your subscription will auto-renew for the same price and package length until you cancel via settings, and you agree to our Terms. You also acknowledge the right to withdraw within 14 days for a pro-rated refund, with no refund available after 14 days.';
}
