abstract class SettingsRepository {
  Future<bool> isAutoLockEnabled();
  Future<void> setAutoLockEnabled(bool enabled);
  Future<int> getAutoLockDuration();
  Future<void> setAutoLockDuration(int minutes);
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
}
