import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../../auth/application/providers/auth_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SettingsRepositoryImpl(secureStorage);
});

class SettingsState {
  final bool autoLockEnabled;
  final int autoLockDuration;
  final bool biometricEnabled;
  final bool isLoading;

  const SettingsState({
    this.autoLockEnabled = true,
    this.autoLockDuration = 5,
    this.biometricEnabled = false,
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? autoLockEnabled,
    int? autoLockDuration,
    bool? biometricEnabled,
    bool? isLoading,
  }) {
    return SettingsState(
      autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const SettingsState());

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      final autoLockEnabled = await _repository.isAutoLockEnabled();
      final autoLockDuration = await _repository.getAutoLockDuration();
      final biometricEnabled = await _repository.isBiometricEnabled();
      state = state.copyWith(
        autoLockEnabled: autoLockEnabled,
        autoLockDuration: autoLockDuration,
        biometricEnabled: biometricEnabled,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setAutoLockEnabled(bool enabled) async {
    await _repository.setAutoLockEnabled(enabled);
    state = state.copyWith(autoLockEnabled: enabled);
  }

  Future<void> setAutoLockDuration(int minutes) async {
    await _repository.setAutoLockDuration(minutes);
    state = state.copyWith(autoLockDuration: minutes);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _repository.setBiometricEnabled(enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final repository = ref.watch(settingsRepositoryProvider);
    return SettingsNotifier(repository);
  },
);
