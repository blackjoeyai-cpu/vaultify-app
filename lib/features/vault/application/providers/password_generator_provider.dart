import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/password_strength.dart';

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

    final strength = PasswordStrengthUtil.calculate(password);

    state = state.copyWith(password: password, strength: strength);
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
