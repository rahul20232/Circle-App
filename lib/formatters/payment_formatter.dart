import 'package:flutter/services.dart';

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any spaces
    String digitsOnly = newValue.text.replaceAll(' ', '');

    // Limit to 16 digits
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }

    // Add space every 4 digits
    String spaced = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      spaced += digitsOnly[i];
      if ((i + 1) % 4 == 0 && i + 1 != digitsOnly.length) {
        spaced += ' ';
      }
    }

    return TextEditingValue(
      text: spaced,
      selection: TextSelection.collapsed(offset: spaced.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');

    // Limit to 4 digits (MMYY)
    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    // Insert slash after 2 digits
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        formatted += '/';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
