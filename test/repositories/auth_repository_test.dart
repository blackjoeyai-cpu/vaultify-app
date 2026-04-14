import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify/core/constants/storage_keys.dart';
import 'package:vaultify/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:vaultify/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vaultify/shared/services/encryption_service.dart';
import '../mocks/mock_secure_storage.dart';
import '../test_config.dart';

void main() {
  late MockSecureStorage mockStorage;
  late AuthLocalDatasource authLocalDatasource;
  late EncryptionService encryptionService;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockStorage = MockSecureStorage();
    authLocalDatasource = AuthLocalDatasource(mockStorage);
    encryptionService = EncryptionService(mockStorage);
    authRepository = AuthRepositoryImpl(authLocalDatasource, encryptionService);
  });

  group('AuthRepository', () {
    group('hasMasterPassword', () {
      test('should return true when master password hash exists', () async {
        await encryptionService.generateSalt();
        await encryptionService.saveMasterPasswordHash(
          TestConfig.correctPassword,
        );

        final result = await authRepository.hasMasterPassword();

        expect(result, isTrue);
      });

      test('should return false when no master password hash exists', () async {
        final result = await authRepository.hasMasterPassword();

        expect(result, isFalse);
      });
    });

    group('createMasterPassword', () {
      test('should generate salt and save password hash', () async {
        await authRepository.createMasterPassword(TestConfig.correctPassword);

        final salt = await mockStorage.read(key: StorageKeys.encryptionSalt);
        final hash = await mockStorage.read(
          key: StorageKeys.masterPasswordHash,
        );

        expect(salt, isNotNull);
        expect(hash, isNotNull);
      });
    });

    group('verifyMasterPassword', () {
      test('should return true for correct password', () async {
        await authRepository.createMasterPassword(TestConfig.correctPassword);

        final result = await authRepository.verifyMasterPassword(
          TestConfig.correctPassword,
        );

        expect(result, isTrue);
      });

      test('should return false for incorrect password', () async {
        await authRepository.createMasterPassword(TestConfig.correctPassword);

        final result = await authRepository.verifyMasterPassword(
          TestConfig.wrongPassword,
        );

        expect(result, isFalse);
      });
    });

    group('isOnboardingComplete', () {
      test('should return true when onboarding is complete', () async {
        await authLocalDatasource.setOnboardingComplete(true);

        final result = await authRepository.isOnboardingComplete();

        expect(result, isTrue);
      });

      test('should return false when onboarding is not complete', () async {
        final result = await authRepository.isOnboardingComplete();

        expect(result, isFalse);
      });
    });

    group('completeOnboarding', () {
      test('should set onboarding complete flag', () async {
        await authRepository.completeOnboarding();

        final result = await authRepository.isOnboardingComplete();

        expect(result, isTrue);
      });
    });

    group('saveSession', () {
      test('should save session token and expiry', () async {
        final expiry = DateTime.now().add(const Duration(minutes: 5));

        await authRepository.saveSession(expiry);

        final token = await mockStorage.read(key: StorageKeys.sessionToken);
        final expiryStr = await mockStorage.read(
          key: StorageKeys.sessionExpiry,
        );

        expect(token, isNotNull);
        expect(expiryStr, isNotNull);
      });
    });

    group('getSession', () {
      test('should return session when exists and not expired', () async {
        final expiry = DateTime.now().add(const Duration(minutes: 5));
        await authRepository.saveSession(expiry);

        final session = await authRepository.getSession();

        expect(session, isNotNull);
        expect(session!.token, isNotNull);
        expect(session.expiry.isAfter(DateTime.now()), isTrue);
      });

      test('should return session when exists but expired', () async {
        final expiry = DateTime.now().subtract(const Duration(minutes: 5));
        await authRepository.saveSession(expiry);

        final session = await authRepository.getSession();

        expect(session, isNotNull);
        expect(session!.token, isNotNull);
      });

      test('should return null when no session exists', () async {
        final session = await authRepository.getSession();

        expect(session, isNull);
      });
    });

    group('clearSession', () {
      test('should remove session token and expiry', () async {
        final expiry = DateTime.now().add(const Duration(minutes: 5));
        await authRepository.saveSession(expiry);

        await authRepository.clearSession();

        final token = await mockStorage.read(key: StorageKeys.sessionToken);
        final expiryStr = await mockStorage.read(
          key: StorageKeys.sessionExpiry,
        );

        expect(token, isNull);
        expect(expiryStr, isNull);
      });
    });

    group('biometric credentials', () {
      test('should save and retrieve biometric credential', () async {
        await authRepository.saveBiometricCredential(
          TestConfig.testBiometricCredential,
        );
        final result = await authRepository.getBiometricCredential();

        expect(result, equals(TestConfig.testBiometricCredential));
      });

      test('should return null when no biometric credential exists', () async {
        final result = await authRepository.getBiometricCredential();

        expect(result, isNull);
      });

      test('should clear biometric credential', () async {
        await authRepository.saveBiometricCredential(
          TestConfig.testBiometricCredential,
        );

        await authRepository.clearBiometricCredential();

        final result = await authRepository.getBiometricCredential();
        expect(result, isNull);
      });
    });
  });
}
