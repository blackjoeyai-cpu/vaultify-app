import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      // For Android, we need to check both canCheckBiometrics and isDeviceSupported
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      // On Android, we should also check available biometrics
      if (Platform.isAndroid) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        return availableBiometrics.isNotEmpty;
      }
      
      return canCheckBiometrics || isDeviceSupported;
    } on PlatformException catch (e) {
      debugPrint('Biometric availability check failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error checking biometric availability: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      debugPrint('Available biometrics: $biometrics');
      return biometrics;
    } on PlatformException catch (e) {
      debugPrint('Failed to get biometrics: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Unexpected error getting biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to unlock Vaultify',
  }) async {
    try {
      debugPrint('Starting biometric authentication with reason: $reason');
      
      // First check if biometric is available
      if (!await isAvailable()) {
        debugPrint('Biometric not available on device');
        return false;
      }

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
      
      debugPrint('Biometric authentication result: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication failed: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error during biometric authentication: $e');
      return false;
    }
  }

  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  Future<bool> hasFaceId() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  Future<bool> hasStrongBiometrics() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.strong) ||
        biometrics.contains(BiometricType.face) ||
        biometrics.contains(BiometricType.fingerprint);
  }
}
