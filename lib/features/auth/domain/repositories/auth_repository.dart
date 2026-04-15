abstract class AuthRepository {
  Future<bool> hasMasterPassword();
  Future<void> createMasterPassword(String password);
  Future<bool> verifyMasterPassword(String password);
  Future<void> logout();
  Future<bool> isOnboardingComplete();
  Future<void> completeOnboarding();
  Future<void> saveSession(DateTime expiry, {String? masterPassword});
  Future<({String token, DateTime expiry, String? masterPassword})?>
  getSession();
  Future<void> clearSession();
  Future<void> enableBiometric();
  Future<void> disableBiometric();
  Future<bool> isBiometricEnabled();
}
