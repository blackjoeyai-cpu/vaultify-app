import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordGeneratorState {
  final String password;
  final int length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;
  final int strength;

  const PasswordGeneratorState({
    this.password = '',
    this.length = 16,
    this.includeUppercase = true,
    this.includeLowercase = true,
    this.includeNumbers = true,
    this.includeSymbols = true,
    this.strength = 0,
  });

  PasswordGeneratorState copyWith({
    String? password,
    int? length,
    bool? includeUppercase,
    bool? includeLowercase,
    bool? includeNumbers,
    bool? includeSymbols,
    int? strength,
  }) {
    return PasswordGeneratorState(
      password: password ?? this.password,
      length: length ?? this.length,
      includeUppercase: includeUppercase ?? this.includeUppercase,
      includeLowercase: includeLowercase ?? this.includeLowercase,
      includeNumbers: includeNumbers ?? this.includeNumbers,
      includeSymbols: includeSymbols ?? this.includeSymbols,
      strength: strength ?? this.strength,
    );
  }
}

class PasswordGeneratorNotifier extends StateNotifier<PasswordGeneratorState> {
  PasswordGeneratorNotifier() : super(const PasswordGeneratorState()) {
    generatePassword();
  }

  void generatePassword() {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    var chars = '';
    if (state.includeUppercase) chars += uppercase;
    if (state.includeLowercase) chars += lowercase;
    if (state.includeNumbers) chars += numbers;
    if (state.includeSymbols) chars += symbols;

    if (chars.isEmpty) {
      chars = lowercase + numbers;
    }

    final random = Random.secure();
    final password = List.generate(
      state.length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();

    final strength = _calculateStrength(password);

    state = state.copyWith(password: password, strength: strength);
  }

  int _calculateStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password))
      strength++;
    return strength;
  }

  void setLength(int length) {
    state = state.copyWith(length: length);
    generatePassword();
  }

  void toggleUppercase() {
    state = state.copyWith(includeUppercase: !state.includeUppercase);
    generatePassword();
  }

  void toggleLowercase() {
    state = state.copyWith(includeLowercase: !state.includeLowercase);
    generatePassword();
  }

  void toggleNumbers() {
    state = state.copyWith(includeNumbers: !state.includeNumbers);
    generatePassword();
  }

  void toggleSymbols() {
    state = state.copyWith(includeSymbols: !state.includeSymbols);
    generatePassword();
  }
}

final passwordGeneratorProvider =
    StateNotifierProvider<PasswordGeneratorNotifier, PasswordGeneratorState>((
      ref,
    ) {
      return PasswordGeneratorNotifier();
    });
