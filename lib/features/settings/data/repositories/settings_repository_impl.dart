import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/constants/storage_keys.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FlutterSecureStorage _secureStorage;

  SettingsRepositoryImpl(this._secureStorage);

  @override
  Future<bool> isAutoLockEnabled() async {
    final value = await _secureStorage.read(key: StorageKeys.autoLockEnabled);
    return value == 'true';
  }

  @override
  Future<void> setAutoLockEnabled(bool enabled) async {
    await _secureStorage.write(
      key: StorageKeys.autoLockEnabled,
      value: enabled.toString(),
    );
  }

  @override
  Future<int> getAutoLockDuration() async {
    final value = await _secureStorage.read(key: StorageKeys.autoLockDuration);
    return int.tryParse(value ?? '5') ?? 5;
  }

  @override
  Future<void> setAutoLockDuration(int minutes) async {
    await _secureStorage.write(
      key: StorageKeys.autoLockDuration,
      value: minutes.toString(),
    );
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: StorageKeys.biometricEnabled);
    return value == 'true';
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: StorageKeys.biometricEnabled,
      value: enabled.toString(),
    );
  }

  @override
  Future<bool> isClipboardAutoClearEnabled() async {
    final value = await _secureStorage.read(
      key: StorageKeys.clipboardAutoClearEnabled,
    );
    return value == 'true';
  }

  @override
  Future<void> setClipboardAutoClearEnabled(bool enabled) async {
    await _secureStorage.write(
      key: StorageKeys.clipboardAutoClearEnabled,
      value: enabled.toString(),
    );
  }
}
