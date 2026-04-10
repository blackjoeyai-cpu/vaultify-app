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

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
