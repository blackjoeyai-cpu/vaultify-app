import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../../../shared/services/encryption_service.dart';

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

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final bool hasMasterPassword;
  final bool isOnboardingComplete;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.hasMasterPassword = false,
    this.isOnboardingComplete = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? hasMasterPassword,
    bool? isOnboardingComplete,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      hasMasterPassword: hasMasterPassword ?? this.hasMasterPassword,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final hasMasterPassword = await _authRepository.hasMasterPassword();
      final isOnboardingComplete = await _authRepository.isOnboardingComplete();
      state = state.copyWith(
        hasMasterPassword: hasMasterPassword,
        isOnboardingComplete: isOnboardingComplete,
        status: hasMasterPassword
            ? AuthStatus.unauthenticated
            : AuthStatus.initial,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.initial, error: e.toString());
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

  Future<bool> login(String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final isValid = await _authRepository.verifyMasterPassword(password);
      if (isValid) {
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

  Future<void> completeOnboarding() async {
    await _authRepository.completeOnboarding();
    state = state.copyWith(isOnboardingComplete: true);
  }

  void logout() {
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
