abstract class AuthRepository {
  Future<bool> hasMasterPassword();
  Future<void> createMasterPassword(String password);
  Future<bool> verifyMasterPassword(String password);
  Future<void> logout();
  Future<bool> isOnboardingComplete();
  Future<void> completeOnboarding();
}
