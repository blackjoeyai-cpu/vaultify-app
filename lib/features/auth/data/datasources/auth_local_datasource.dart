import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/storage_keys.dart';

class AuthLocalDatasource {
  final FlutterSecureStorage _secureStorage;

  AuthLocalDatasource(this._secureStorage);

  Future<bool> hasMasterPassword() async {
    final hash = await _secureStorage.read(key: StorageKeys.masterPasswordHash);
    return hash != null;
  }

  Future<void> saveMasterPasswordHash(String hash) async {
    await _secureStorage.write(
      key: StorageKeys.masterPasswordHash,
      value: hash,
    );
  }

  Future<String?> getMasterPasswordHash() async {
    return await _secureStorage.read(key: StorageKeys.masterPasswordHash);
  }

  Future<void> saveSalt(String salt) async {
    await _secureStorage.write(key: StorageKeys.encryptionSalt, value: salt);
  }

  Future<String?> getSalt() async {
    return await _secureStorage.read(key: StorageKeys.encryptionSalt);
  }

  Future<bool> isOnboardingComplete() async {
    final value = await _secureStorage.read(
      key: StorageKeys.hasCompletedOnboarding,
    );
    return value == 'true';
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _secureStorage.write(
      key: StorageKeys.hasCompletedOnboarding,
      value: complete.toString(),
    );
  }

  Future<void> saveSession(String token, DateTime expiry) async {
    await _secureStorage.write(key: StorageKeys.sessionToken, value: token);
    await _secureStorage.write(
      key: StorageKeys.sessionExpiry,
      value: expiry.millisecondsSinceEpoch.toString(),
    );
  }

  Future<({String token, DateTime expiry})?> getSession() async {
    final token = await _secureStorage.read(key: StorageKeys.sessionToken);
    final expiryStr = await _secureStorage.read(key: StorageKeys.sessionExpiry);
    if (token == null || expiryStr == null) return null;

    final expiryMs = int.tryParse(expiryStr);
    if (expiryMs == null) {
      await clearSession();
      return null;
    }

    return (
      token: token,
      expiry: DateTime.fromMillisecondsSinceEpoch(expiryMs),
    );
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: StorageKeys.sessionToken);
    await _secureStorage.delete(key: StorageKeys.sessionExpiry);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: StorageKeys.biometricEnabled,
      value: enabled.toString(),
    );
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: StorageKeys.biometricEnabled);
    return value == 'true';
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
