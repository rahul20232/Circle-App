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
    if (widget.inputType == TextInputType.phone) {
      // phone number validation: must be exactly 10 digits
      isValid = RegExp(r'^\d{10}$').hasMatch(text);
    }

    setState(() {
      _isButtonEnabled = isChanged && isValid;
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
      backgroundColor: Color(0xFFFEF1DE),
      appBar: AppBar(
        backgroundColor: Color(0xFFFEF1DE),
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.question,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: widget.inputType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 600),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isButtonEnabled ? Colors.black : Colors.grey.shade400,
                shape: StadiumBorder(),
                minimumSize: Size(double.infinity, 55),
              ),
              onPressed: _isButtonEnabled
                  ? () {
                      Navigator.pop(context, _controller.text.trim());
                    }
                  : null, // disables button
              child: Text(widget.buttonText,
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
