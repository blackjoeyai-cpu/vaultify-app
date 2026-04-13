class PasswordStrengthUtil {
  static const String _symbols = r'!@#$%^&*()_+-=[]{}|;:,.<>?';

  static int calculate(String password) {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(_symbols).hasMatch(password)) strength++;
    return strength;
  }
}
