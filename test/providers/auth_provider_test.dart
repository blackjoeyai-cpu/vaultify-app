import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify/features/auth/application/providers/auth_provider.dart';
import 'package:vaultify/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:vaultify/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vaultify/features/auth/domain/repositories/auth_repository.dart';
import 'package:vaultify/shared/services/encryption_service.dart';
import '../mocks/mock_secure_storage.dart';
import '../test_config.dart';

void main() {
  late MockSecureStorage mockStorage;
  late AuthLocalDatasource authLocalDatasource;
  late EncryptionService encryptionService;
  late AuthRepository authRepository;

  setUp(() {
    mockStorage = MockSecureStorage();
    authLocalDatasource = AuthLocalDatasource(mockStorage);
    encryptionService = EncryptionService(mockStorage);
    authRepository = AuthRepositoryImpl(authLocalDatasource, encryptionService);
  });

  group('AuthState', () {
    test('should have correct default values', () {
      const state = AuthState();

      expect(state.status, equals(AuthStatus.initial));
      expect(state.hasMasterPassword, isFalse);
      expect(state.isOnboardingComplete, isFalse);
      expect(state.hasBiometricCredential, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith should create new state with updated values', () {
      const state = AuthState();

      final newState = state.copyWith(
        hasMasterPassword: true,
        status: AuthStatus.authenticated,
      );

      expect(newState.hasMasterPassword, isTrue);
      expect(newState.status, equals(AuthStatus.authenticated));
      expect(newState.isOnboardingComplete, isFalse);
    });

    test('copyWith should preserve unchanged values', () {
      const state = AuthState(
        hasMasterPassword: true,
        isOnboardingComplete: true,
      );

      final newState = state.copyWith(status: AuthStatus.authenticated);

      expect(newState.hasMasterPassword, isTrue);
      expect(newState.isOnboardingComplete, isTrue);
      expect(newState.status, equals(AuthStatus.authenticated));
    });
  });

  group('AuthStatus enum', () {
    test('should have all expected values', () {
      expect(AuthStatus.values.length, equals(4));
      expect(AuthStatus.values, contains(AuthStatus.initial));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.loading));
    });
  });

  group('AuthRepository integration', () {
    group('createMasterPassword', () {
      test('should create master password successfully', () async {
        await authRepository.createMasterPassword(TestConfig.correctPassword);

        final hasMasterPassword = await authRepository.hasMasterPassword();
        expect(hasMasterPassword, isTrue);
      });
    });

    group('login flow', () {
      test('should verify correct password', () async {
        await authRepository.createMasterPassword(TestConfig.correctPassword);

        final isValid = await authRepository.verifyMasterPassword(
          TestConfig.correctPassword,
        );

        expect(isValid, isTrue);
      });

      test('should reject incorrect password', () async {
        await authRepository.createMasterPassword(TestConfig.correctPassword);

        final isValid = await authRepository.verifyMasterPassword(
          TestConfig.wrongPassword,
        );

        expect(isValid, isFalse);
      });
    });

    group('session management', () {
      test('should save session with expiry', () async {
        final expiry = DateTime.now().add(const Duration(minutes: 5));

        await authRepository.saveSession(expiry);

        final session = await authRepository.getSession();
        expect(session, isNotNull);
        expect(session!.expiry.isAfter(DateTime.now()), isTrue);
      });

      test('should clear session', () async {
        final expiry = DateTime.now().add(const Duration(minutes: 5));
        await authRepository.saveSession(expiry);

        await authRepository.clearSession();

        final session = await authRepository.getSession();
        expect(session, isNull);
      });
    });

    group('onboarding', () {
      test('should complete onboarding', () async {
        await authRepository.completeOnboarding();

        final isComplete = await authRepository.isOnboardingComplete();
        expect(isComplete, isTrue);
      });
    });

    group('biometric credentials', () {
      test('should save and retrieve biometric credential', () async {
        await authRepository.saveBiometricCredential(
          TestConfig.testBiometricCredential,
        );

        final retrieved = await authRepository.getBiometricCredential();
        expect(retrieved, equals(TestConfig.testBiometricCredential));
      });

      test('should clear biometric credential', () async {
        await authRepository.saveBiometricCredential(
          TestConfig.testBiometricCredential,
        );

        await authRepository.clearBiometricCredential();

        final retrieved = await authRepository.getBiometricCredential();
        expect(retrieved, isNull);
      });
    });
  });
}
