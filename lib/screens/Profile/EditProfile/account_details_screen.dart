import 'package:flutter/material.dart';

class AccountDetailsScreen extends StatefulWidget {
  final String title; // AppBar title
  final String question; // Question text
  final String initialValue; // Current value
  final String buttonText; // Confirm / Reset button text
  final TextInputType inputType;

  const AccountDetailsScreen({
    Key? key,
    required this.title,
    required this.question,
    required this.initialValue,
    required this.buttonText,
    this.inputType = TextInputType.text,
  }) : super(key: key);

  @override
  _AccountDetailsScreenState createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late TextEditingController _controller;
  bool _isButtonEnabled = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);

    // Add listener to validate input on every change
    _controller.addListener(_validateInput);
  }

  void _validateInput() {
    String text = _controller.text.trim();

    // Remove +91 or 91 if present at the start
    if (text.startsWith('+91')) {
      text = text.substring(3);
    } else if (text.startsWith('91') && text.length > 10) {
      text = text.substring(2);
    }

    bool isChanged = text != widget.initialValue.trim();

    bool isValid = true;
    String? validationMsg;

    if (widget.inputType == TextInputType.phone) {
      // phone number validation: must be exactly 10 digits
      isValid = RegExp(r'^\d{10}$').hasMatch(text);
      if (!isValid && text.isNotEmpty) {
        validationMsg = "Phone number must be exactly 10 digits";
      }
    } else if (widget.inputType == TextInputType.emailAddress) {
      // Basic email validation
      isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text);
      if (!isValid && text.isNotEmpty) {
        validationMsg = "Please enter a valid email address";
      }
    }

    setState(() {
      _isButtonEnabled = isChanged && isValid && text.isNotEmpty;
      _validationMessage = validationMsg;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF1DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF1DE),
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Question text
              Text(
                widget.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Input field with validation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    keyboardType: widget.inputType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _validationMessage != null
                              ? Colors.red.shade300
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _validationMessage != null
                              ? Colors.red
                              : Colors.black,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      // Add prefix for phone numbers
                      prefixText: widget.inputType == TextInputType.phone
                          ? '+91 '
                          : null,
                      prefixStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Validation message
                  if (_validationMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _validationMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Help text for phone numbers
                  if (widget.inputType == TextInputType.phone) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Enter your 10-digit phone number without country code",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Spacer to push button to bottom
              const Spacer(),

              // Button at bottom with keyboard consideration
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom + 20
                      : 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled
                          ? Colors.black
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      minimumSize: const Size(double.infinity, 55),
                      elevation: _isButtonEnabled ? 2 : 0,
                    ),
                    onPressed: _isButtonEnabled
                        ? () {
                            String finalValue = _controller.text.trim();

                            // Clean phone number for return value
                            if (widget.inputType == TextInputType.phone) {
                              if (finalValue.startsWith('+91')) {
                                finalValue = finalValue.substring(3).trim();
                              } else if (finalValue.startsWith('91') &&
                                  finalValue.length > 10) {
                                finalValue = finalValue.substring(2).trim();
                              }
                            }

                            Navigator.pop(context, finalValue);
                          }
                        : null,
                    child: Text(
                      widget.buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
