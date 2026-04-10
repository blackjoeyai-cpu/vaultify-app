import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../../../../shared/services/encryption_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource _localDatasource;
  final EncryptionService _encryptionService;

  AuthRepositoryImpl(this._localDatasource, this._encryptionService);

  @override
  Future<bool> hasMasterPassword() async {
    return await _localDatasource.hasMasterPassword();
  }

  @override
  Future<void> createMasterPassword(String password) async {
    await _encryptionService.generateSalt();
    await _encryptionService.saveMasterPasswordHash(password);
  }

  @override
  Future<bool> verifyMasterPassword(String password) async {
    return await _encryptionService.verifyMasterPassword(password);
  }

  @override
  Future<void> logout() async {
    // For security, we don't clear data on logout
    // Just update the last unlock time
  }

  @override
  Future<bool> isOnboardingComplete() async {
    return await _localDatasource.isOnboardingComplete();
  }

  @override
  Future<void> completeOnboarding() async {
    await _localDatasource.setOnboardingComplete(true);
  }
}
