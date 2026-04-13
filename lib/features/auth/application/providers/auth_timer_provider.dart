import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class AuthTimerState {
  final DateTime? sessionExpiry;
  final bool isPaused;
  final bool isExpired;

  const AuthTimerState({
    this.sessionExpiry,
    this.isPaused = false,
    this.isExpired = false,
  });

  AuthTimerState copyWith({
    DateTime? sessionExpiry,
    bool? isPaused,
    bool? isExpired,
  }) {
    return AuthTimerState(
      sessionExpiry: sessionExpiry ?? this.sessionExpiry,
      isPaused: isPaused ?? this.isPaused,
      isExpired: isExpired ?? this.isExpired,
    );
  }
}

class AuthTimerNotifier extends StateNotifier<AuthTimerState> {
  final Ref _ref;
  Timer? _timer;

  AuthTimerNotifier(this._ref) : super(const AuthTimerState());

  void startTimer(DateTime expiry) {
    _timer?.cancel();
    state = state.copyWith(sessionExpiry: expiry, isExpired: false);
    _checkExpiry();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPaused) {
        _checkExpiry();
      }
    });
  }

  void pauseTimer() {
    state = state.copyWith(isPaused: true);
  }

  void resumeTimer() {
    state = state.copyWith(isPaused: false);
    _checkExpiry();
  }

  void resetTimer() {
    _timer?.cancel();
    state = const AuthTimerState();
  }

  void _checkExpiry() {
    if (state.sessionExpiry != null && !state.isPaused) {
      if (DateTime.now().isAfter(state.sessionExpiry!)) {
        _timer?.cancel();
        state = state.copyWith(isExpired: true);
        _ref.read(authProvider.notifier).lockApp();
      }
    }
  }

  DateTime calculateExpiry(int durationMinutes) {
    return DateTime.now().add(Duration(minutes: durationMinutes));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final authTimerProvider =
    StateNotifierProvider<AuthTimerNotifier, AuthTimerState>((ref) {
      return AuthTimerNotifier(ref);
    });
