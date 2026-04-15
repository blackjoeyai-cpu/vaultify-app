import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionState {
  final String? masterPassword;

  const SessionState({this.masterPassword});

  SessionState copyWith({String? masterPassword}) {
    return SessionState(masterPassword: masterPassword ?? this.masterPassword);
  }

  bool get isUnlocked => masterPassword != null;
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState());

  void unlock(String masterPassword) {
    state = state.copyWith(masterPassword: masterPassword);
  }

  void lock() {
    state = const SessionState();
  }

  String? getMasterPassword() => state.masterPassword;
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((
  ref,
) {
  return SessionNotifier();
});
