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
    return (
      token: token,
      expiry: DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr)),
    );
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: StorageKeys.sessionToken);
    await _secureStorage.delete(key: StorageKeys.sessionExpiry);
  }

  Future<void> saveBiometricCredential(String encryptedPassword) async {
    await _secureStorage.write(
      key: StorageKeys.biometricCredential,
      value: encryptedPassword,
    );
  }

  Future<String?> getBiometricCredential() async {
    return await _secureStorage.read(key: StorageKeys.biometricCredential);
  }

  Future<void> clearBiometricCredential() async {
    await _secureStorage.delete(key: StorageKeys.biometricCredential);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
