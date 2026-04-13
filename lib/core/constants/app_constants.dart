class AppConstants {
  AppConstants._();

  static const String appName = 'Vaultify';
  static const String appVersion = '1.0.0';

  static const int pbkdf2Iterations = 100000;
  static const int saltLength = 32;
  static const int ivLength = 12;
  static const int keyLength = 32;

  static const String biometricKey = 'vaultify_biometric_secure_key_2024';

  static const Duration autoLockDuration = Duration(minutes: 5);
  static const Duration splashDuration = Duration(seconds: 2);

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  static const List<String> onboardingTitles = [
    'Security First',
    'Powerful Features',
    'Get Started',
  ];

  static const List<String> onboardingDescriptions = [
    'Your passwords encrypted with AES-256-GCM, stored locally on your device. No cloud, no tracking, complete privacy.',
    'Generate strong passwords, organize with categories, quick search, and auto-lock for extra security.',
    'Create your master password - the only one you\'ll need to remember.',
  ];
}
