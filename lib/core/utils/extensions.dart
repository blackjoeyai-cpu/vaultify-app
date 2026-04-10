import 'package:flutter/material.dart';

extension StringExtensions on String {
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  bool get isStrongPassword {
    if (length < 8) return false;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(this);
    final hasLower = RegExp(r'[a-z]').hasMatch(this);
    final hasNumber = RegExp(r'[0-9]').hasMatch(this);
    return hasUpper && hasLower && hasNumber;
  }

  int get passwordStrength {
    if (isEmpty) return 0;
    int strength = 0;
    if (length >= 8) strength++;
    if (length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(this)) strength++;
    if (RegExp(r'[a-z]').hasMatch(this)) strength++;
    if (RegExp(r'[0-9]').hasMatch(this)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(this)) strength++;
    return strength;
  }
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}

extension DateTimeExtensions on DateTime {
  String get formatted {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  String get timeFormatted {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
