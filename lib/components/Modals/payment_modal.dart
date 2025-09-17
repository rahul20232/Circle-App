// Replace your payment_modal.dart with this simplified version:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timeleft_clone/components/card_scanner.dart'; // Import the new component
import 'package:timeleft_clone/formatters/payment_formatter.dart';
import 'package:timeleft_clone/main.dart' show cameras;
import 'package:timeleft_clone/services/auth_service.dart';
import 'package:timeleft_clone/screens/Home/booking_success_screen.dart';

class PaymentModal extends StatefulWidget {
  final String price;
  final int selectedPlan;
  final dynamic selectedDinner;
  final VoidCallback? onPaymentSuccess;

  const PaymentModal({
    Key? key,
    required this.price,
    required this.selectedPlan,
    this.selectedDinner,
    this.onPaymentSuccess,
  }) : super(key: key);

  @override
  _PaymentModalState createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  String selectedCountry = 'India';
  bool showCardScanner = false;
  bool isProcessingPayment = false;

  final List<String> countries = [
    'India',
    'USA',
    'UK',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Japan',
    'Singapore',
    'UAE',
  ];

  void _showCardScanner() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      setState(() => showCardScanner = true);
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        setState(() => showCardScanner = true);
      } else {
        _showPermissionDialog();
      }
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text(
          'This app needs camera access to scan your credit card. Please grant permission or enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Permission.camera.request();
              if (result.isGranted) {
                setState(() => showCardScanner = true);
              } else {
                await openAppSettings();
              }
            },
            child: Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  void _onCardDetected(String cardNumber) {
    setState(() {
      _cardNumberController.text = cardNumber;
      showCardScanner = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card detected successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Map<String, dynamic> _getSubscriptionDetails() {
    DateTime now = DateTime.now();
    switch (widget.selectedPlan) {
      case 0:
        return {
          'startDate': now,
          'endDate': now.add(Duration(days: 30)),
          'subscriptionType': 'monthly',
          'planId': 'discover_1m',
        };
      case 1:
        return {
          'startDate': now,
          'endDate': now.add(Duration(days: 90)),
          'subscriptionType': '3_months',
          'planId': 'save_3m',
        };
      case 2:
        return {
          'startDate': now,
          'endDate': now.add(Duration(days: 180)),
          'subscriptionType': '6_months',
          'planId': 'save_6m',
        };
      default:
        return {
          'startDate': now,
          'endDate': now.add(Duration(days: 30)),
          'subscriptionType': 'monthly',
          'planId': 'discover_1m',
        };
    }
  }

  void _processPayment() async {
    if (_cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvcController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all card details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isProcessingPayment = true);

    try {
      final details = _getSubscriptionDetails();
      final success = await AuthService.activateSubscription(
        subscriptionType: details['subscriptionType'],
        subscriptionStart: details['startDate'],
        subscriptionEnd: details['endDate'],
        subscriptionPlanId: details['planId'],
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Payment processed successfully! Subscription activated.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        widget.onPaymentSuccess?.call();
        await Future.delayed(Duration(seconds: 1));

        if (!mounted) return;

        if (widget.selectedDinner != null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  BookingSuccessScreen(bookedDinner: widget.selectedDinner),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: Offset(0.0, 1.0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeInOut)),
                  ),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 800),
            ),
          );
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        throw Exception('Subscription activation failed');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenHeight < 650;
    final isSmallScreen = screenHeight < 700 || screenWidth < 375;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize:
              isVerySmallScreen ? 0.85 : (isSmallScreen ? 0.75 : 0.65),
          minChildSize: 0.5,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: [0.5, 0.75, 0.95],
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xFFFEF1DE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add card',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 24),
                          onPressed: isProcessingPayment
                              ? null
                              : () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card information header with scan button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Card information',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!isVerySmallScreen)
                                TextButton.icon(
                                  onPressed: isProcessingPayment
                                      ? null
                                      : () {
                                          setState(() {
                                            showCardScanner = true;
                                          });
                                        },
                                  icon: Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.blue,
                                    size: isSmallScreen ? 12 : 16,
                                  ),
                                  label: Text(
                                    'Scan',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: isSmallScreen ? 10 : 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: 8),

                          // Card input fields
                          _buildCardInputFields(
                              isVerySmallScreen, isSmallScreen),

                          SizedBox(height: 16),

                          // Show card scanner if enabled
                          if (showCardScanner && cameras.isNotEmpty) ...[
                            Container(
                              height: 250,
                              margin: EdgeInsets.only(bottom: 16),
                              child: CardScanner(
                                camera: cameras.first,
                                onCardDetected: _onCardDetected,
                                onClose: () =>
                                    setState(() => showCardScanner = false),
                              ),
                            ),
                          ],

                          // Billing address
                          Text(
                            'Billing address',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),

                          // Country dropdown
                          _buildCountryDropdown(
                              isVerySmallScreen, isSmallScreen),

                          SizedBox(height: 12),

                          // Terms text
                          if (!isVerySmallScreen)
                            Text(
                              'By providing your card information, you allow Timeleft to charge your card for future payments in accordance with their terms.',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  height: 1.2),
                            ),

                          SizedBox(height: 16),

                          // Pay button
                          _buildPayButton(isVerySmallScreen, isSmallScreen),

                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardInputFields(bool isVerySmallScreen, bool isSmallScreen) {
    return Column(
      children: [
        // Card number field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: TextField(
            controller: _cardNumberController,
            enabled: !isProcessingPayment,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            decoration: InputDecoration(
              hintText: 'Card number',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              suffixIcon: !isVerySmallScreen
                  ? Container(
                      width: 24,
                      height: 14,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: Text(
                          'VISA',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 6,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : null,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberInputFormatter(),
            ],
            textInputAction: TextInputAction.next,
          ),
        ),

        // Expiry and CVC fields
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(8)),
                ),
                child: TextField(
                  controller: _expiryController,
                  enabled: !isProcessingPayment,
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                  decoration: InputDecoration(
                    hintText: 'MM/YY',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ExpiryDateInputFormatter(),
                  ],
                  maxLength: 5,
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                    right: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(8)),
                ),
                child: TextField(
                  controller: _cvcController,
                  enabled: !isProcessingPayment,
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                  decoration: InputDecoration(
                    hintText: 'CVC',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 3,
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      null,
                  obscureText: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountryDropdown(bool isVerySmallScreen, bool isSmallScreen) {
    return GestureDetector(
      onTap: isProcessingPayment
          ? null
          : () {
              showCupertinoModalPopup<void>(
                context: context,
                builder: (context) => Container(
                  height: 300,
                  color: CupertinoColors.systemBackground,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text('Select Country',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            CupertinoButton(
                              child: Text('Done'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 32,
                          scrollController: FixedExtentScrollController(
                            initialItem: countries.indexOf(selectedCountry),
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() => selectedCountry = countries[index]);
                          },
                          children: countries
                              .map((country) => Center(child: Text(country)))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(selectedCountry,
                style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
            Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton(bool isVerySmallScreen, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessingPayment ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: isProcessingPayment ? Colors.grey : Colors.black,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isProcessingPayment
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 1.5),
                  ),
                  SizedBox(width: 8),
                  Text('Processing...',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: isSmallScreen ? 12 : 14),
                  SizedBox(width: 6),
                  Text('Pay ${widget.price}',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }
}
