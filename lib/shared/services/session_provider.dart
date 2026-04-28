import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionState {
  final String? masterPassword;
  final Uint8List? derivedKey;

  const SessionState({this.masterPassword, this.derivedKey});

  SessionState copyWith({String? masterPassword, Uint8List? derivedKey}) {
    return SessionState(
      masterPassword: masterPassword ?? this.masterPassword,
      derivedKey: derivedKey ?? this.derivedKey,
    );
  }

  bool get isUnlocked => masterPassword != null;
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState());

  void unlock(String masterPassword, {Uint8List? derivedKey}) {
    state = state.copyWith(
      masterPassword: masterPassword,
      derivedKey: derivedKey,
    );
  }

  void lock() {
    state = const SessionState();
  }

  String? getMasterPassword() => state.masterPassword;
  Uint8List? getDerivedKey() => state.derivedKey;
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((
  ref,
) {
  return SessionNotifier();
});
