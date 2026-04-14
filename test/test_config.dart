import 'dart:io';

class TestConfig {
  static String get correctPassword =>
      Platform.environment['TEST_CORRECT_PASSWORD'] ??
      (throw StateError('TEST_CORRECT_PASSWORD not set'));

  static String get wrongPassword =>
      Platform.environment['TEST_WRONG_PASSWORD'] ??
      (throw StateError('TEST_WRONG_PASSWORD not set'));

  static String get differentPassword =>
      Platform.environment['TEST_DIFFERENT_PASSWORD'] ??
      (throw StateError('TEST_DIFFERENT_PASSWORD not set'));

  static String get testSecretData =>
      Platform.environment['TEST_SECRET_DATA'] ??
      (throw StateError('TEST_SECRET_DATA not set'));
}
