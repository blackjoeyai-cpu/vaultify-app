import 'package:uuid/uuid.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../../../../shared/services/encryption_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource _localDatasource;
  final EncryptionService _encryptionService;
  final _uuid = const Uuid();

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
    await _localDatasource.clearSession();
  }

  @override
  Future<bool> isOnboardingComplete() async {
    return await _localDatasource.isOnboardingComplete();
  }

  @override
  Future<void> completeOnboarding() async {
    await _localDatasource.setOnboardingComplete(true);
  }

  @override
  Future<void> saveSession(DateTime expiry) async {
    final token = _uuid.v4();
    await _localDatasource.saveSession(token, expiry);
  }

  @override
  Future<({String token, DateTime expiry})?> getSession() async {
    return await _localDatasource.getSession();
  }

  @override
  Future<void> clearSession() async {
    await _localDatasource.clearSession();
  }

  @override
  Future<void> saveBiometricCredential(String encryptedPassword) async {
    await _localDatasource.saveBiometricCredential(encryptedPassword);
  }

  @override
  Future<String?> getBiometricCredential() async {
    return await _localDatasource.getBiometricCredential();
  }

  @override
  Future<void> clearBiometricCredential() async {
    await _localDatasource.clearBiometricCredential();
  }
}
