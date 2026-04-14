import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../../../shared/services/encryption_service.dart';
import '../../../../shared/services/biometric_service.dart';
import '../../../settings/application/providers/settings_provider.dart';
import 'auth_timer_provider.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return EncryptionService(secureStorage);
});

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthLocalDatasource(secureStorage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDatasource = ref.watch(authLocalDatasourceProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  return AuthRepositoryImpl(localDatasource, encryptionService);
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final bool hasMasterPassword;
  final bool isOnboardingComplete;
  final bool hasBiometricCredential;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.hasMasterPassword = false,
    this.isOnboardingComplete = false,
    this.hasBiometricCredential = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? hasMasterPassword,
    bool? isOnboardingComplete,
    bool? hasBiometricCredential,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      hasMasterPassword: hasMasterPassword ?? this.hasMasterPassword,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      hasBiometricCredential:
          hasBiometricCredential ?? this.hasBiometricCredential,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final hasMasterPassword = await _authRepository.hasMasterPassword();
      final isOnboardingComplete = await _authRepository.isOnboardingComplete();
      final biometricCred = await _authRepository.getBiometricCredential();
      final hasBiometricCred = biometricCred != null;

      await _ref.read(settingsProvider.notifier).loadSettings();

      if (!hasMasterPassword) {
        state = state.copyWith(
          hasMasterPassword: false,
          isOnboardingComplete: isOnboardingComplete,
          status: AuthStatus.initial,
        );
        return;
      }

      final session = await _authRepository.getSession();

      if (session != null && session.expiry.isAfter(DateTime.now())) {
        final settings = _ref.read(settingsProvider);
        if (settings.autoLockEnabled) {
          _ref.read(authTimerProvider.notifier).startTimer(session.expiry);
        }
        state = state.copyWith(
          hasMasterPassword: true,
          isOnboardingComplete: isOnboardingComplete,
          hasBiometricCredential: hasBiometricCred,
          status: AuthStatus.authenticated,
        );
      } else {
        state = state.copyWith(
          hasMasterPassword: true,
          isOnboardingComplete: isOnboardingComplete,
          hasBiometricCredential: hasBiometricCred,
          status: AuthStatus.unauthenticated,
        );
      }
    } catch (e) {
      final hasMasterPassword = await _authRepository.hasMasterPassword();
      final isOnboardingComplete = await _authRepository.isOnboardingComplete();
      state = state.copyWith(
        hasMasterPassword: hasMasterPassword,
        isOnboardingComplete: isOnboardingComplete,
        status: hasMasterPassword
            ? AuthStatus.unauthenticated
            : AuthStatus.initial,
        error: e.toString(),
      );
    }
  }

  Future<bool> createMasterPassword(String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.createMasterPassword(password);
      state = state.copyWith(
        hasMasterPassword: true,
        status: AuthStatus.authenticated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> login(String password, {bool saveSession = true}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final isValid = await _authRepository.verifyMasterPassword(password);
      if (isValid) {
        if (saveSession) {
          final settings = _ref.read(settingsProvider);
          final expiry = DateTime.now().add(
            Duration(minutes: settings.autoLockDuration),
          );
          await _authRepository.saveSession(expiry);
          if (settings.autoLockEnabled) {
            _ref.read(authTimerProvider.notifier).startTimer(expiry);
          }
        }
        state = state.copyWith(status: AuthStatus.authenticated);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Invalid password',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> verifyPassword(String password) async {
    try {
      return await _authRepository.verifyMasterPassword(password);
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginWithBiometric() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final biometricService = _ref.read(biometricServiceProvider);
      final authenticated = await biometricService.authenticate();

      if (!authenticated) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Biometric authentication failed',
        );
        return false;
      }

      final encryptedPassword = await _authRepository.getBiometricCredential();
      if (encryptedPassword == null) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'No biometric credential found',
        );
        return false;
      }

      final settings = _ref.read(settingsProvider);
      final expiry = DateTime.now().add(
        Duration(minutes: settings.autoLockDuration),
      );
      await _authRepository.saveSession(expiry);
      if (settings.autoLockEnabled) {
        _ref.read(authTimerProvider.notifier).startTimer(expiry);
      }

      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> saveBiometricCredential(String password) async {
    final encryptedPassword = await _ref
        .read(encryptionServiceProvider)
        .encryptForBiometric(password);
    await _authRepository.saveBiometricCredential(encryptedPassword);
    state = state.copyWith(hasBiometricCredential: true);
  }

  Future<void> clearBiometricCredential() async {
    await _authRepository.clearBiometricCredential();
    state = state.copyWith(hasBiometricCredential: false);
  }

  Future<void> refreshSession() async {
    final settings = _ref.read(settingsProvider);
    if (settings.autoLockEnabled) {
      final expiry = DateTime.now().add(
        Duration(minutes: settings.autoLockDuration),
      );
      await _authRepository.saveSession(expiry);
    }
  }

  Future<void> completeOnboarding() async {
    await _authRepository.completeOnboarding();
    state = state.copyWith(isOnboardingComplete: true);
  }

  void lockApp() {
    _ref.read(authTimerProvider.notifier).resetTimer();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<void> logout() async {
    await _authRepository.clearSession();
    _ref.read(authTimerProvider.notifier).resetTimer();
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});
