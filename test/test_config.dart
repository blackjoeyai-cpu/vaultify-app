import 'dart:io';

class TestConfig {
  static String get correctPassword =>
      Platform.environment['TEST_CORRECT_PASSWORD'] ?? 'TestPassword123!';

  static String get wrongPassword =>
      Platform.environment['TEST_WRONG_PASSWORD'] ?? 'WrongPassword456!';

  static String get differentPassword =>
      Platform.environment['TEST_DIFFERENT_PASSWORD'] ??
      'DifferentPassword456!';

  static String get testSecretData =>
      Platform.environment['TEST_SECRET_DATA'] ?? 'TestSecretData';

  static String get testBiometricCredential =>
      Platform.environment['TEST_BIOMETRIC_CREDENTIAL'] ??
      'encryptedBiometricPassword123';
}
