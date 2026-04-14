import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify/features/vault/application/providers/password_generator_provider.dart';

void main() {
  late PasswordGeneratorNotifier passwordGeneratorNotifier;

  setUp(() {
    passwordGeneratorNotifier = PasswordGeneratorNotifier();
  });

  group('PasswordGeneratorState', () {
    test('should have correct default values', () {
      const state = PasswordGeneratorState();

      expect(state.password, isEmpty);
      expect(state.length, equals(16));
      expect(state.includeUppercase, isTrue);
      expect(state.includeLowercase, isTrue);
      expect(state.includeNumbers, isTrue);
      expect(state.includeSymbols, isTrue);
      expect(state.strength, equals(0));
    });

    test('copyWith should create new state with updated values', () {
      const state = PasswordGeneratorState();

      final newState = state.copyWith(length: 20, includeNumbers: false);

      expect(newState.length, equals(20));
      expect(newState.includeNumbers, isFalse);
      expect(newState.includeUppercase, isTrue);
    });
  });

  group('PasswordGeneratorNotifier', () {
    group('initial state', () {
      test('should generate password on initialization', () {
        expect(passwordGeneratorNotifier.state.password.isNotEmpty, isTrue);
      });

      test('should have default length of 16', () {
        expect(passwordGeneratorNotifier.state.length, equals(16));
      });

      test('should have all character types enabled by default', () {
        expect(passwordGeneratorNotifier.state.includeUppercase, isTrue);
        expect(passwordGeneratorNotifier.state.includeLowercase, isTrue);
        expect(passwordGeneratorNotifier.state.includeNumbers, isTrue);
        expect(passwordGeneratorNotifier.state.includeSymbols, isTrue);
      });
    });

    group('generatePassword', () {
      test('should generate password with correct length', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(length: 20);
        passwordGeneratorNotifier.generatePassword();

        expect(passwordGeneratorNotifier.state.password.length, equals(20));
      });

      test('should generate different passwords each time', () {
        final password1 = passwordGeneratorNotifier.state.password;
        passwordGeneratorNotifier.generatePassword();
        final password2 = passwordGeneratorNotifier.state.password;

        expect(password1, isNot(equals(password2)));
      });

      test('should include uppercase letters when enabled', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: true,
              includeLowercase: false,
              includeNumbers: false,
              includeSymbols: false,
            );
        passwordGeneratorNotifier.generatePassword();

        final password = passwordGeneratorNotifier.state.password;
        expect(RegExp(r'[A-Z]').hasMatch(password), isTrue);
      });

      test('should include lowercase letters when enabled', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: false,
              includeLowercase: true,
              includeNumbers: false,
              includeSymbols: false,
            );
        passwordGeneratorNotifier.generatePassword();

        final password = passwordGeneratorNotifier.state.password;
        expect(RegExp(r'[a-z]').hasMatch(password), isTrue);
      });

      test('should include numbers when enabled', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: false,
              includeLowercase: false,
              includeNumbers: true,
              includeSymbols: false,
            );
        passwordGeneratorNotifier.generatePassword();

        final password = passwordGeneratorNotifier.state.password;
        expect(RegExp(r'[0-9]').hasMatch(password), isTrue);
      });

      test('should include symbols when enabled', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: false,
              includeLowercase: false,
              includeNumbers: false,
              includeSymbols: true,
            );
        passwordGeneratorNotifier.generatePassword();

        final password = passwordGeneratorNotifier.state.password;
        expect(
          RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password),
          isTrue,
        );
      });
    });

    group('setLength', () {
      test('should change password length', () {
        passwordGeneratorNotifier.setLength(24);

        expect(passwordGeneratorNotifier.state.length, equals(24));
      });

      test('should regenerate password when length changes', () {
        final oldPassword = passwordGeneratorNotifier.state.password;
        passwordGeneratorNotifier.setLength(24);

        expect(
          passwordGeneratorNotifier.state.password,
          isNot(equals(oldPassword)),
        );
      });

      test('should set custom length value', () {
        passwordGeneratorNotifier.setLength(32);

        expect(passwordGeneratorNotifier.state.length, equals(32));
      });
    });

    group('toggle options', () {
      test('should toggle uppercase', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: true,
              includeLowercase: true,
              includeNumbers: true,
              includeSymbols: true,
            );
        passwordGeneratorNotifier.toggleUppercase();

        expect(passwordGeneratorNotifier.state.includeUppercase, isFalse);
      });

      test('should toggle lowercase', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: true,
              includeLowercase: true,
              includeNumbers: true,
              includeSymbols: true,
            );
        passwordGeneratorNotifier.toggleLowercase();

        expect(passwordGeneratorNotifier.state.includeLowercase, isFalse);
      });

      test('should toggle numbers', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: true,
              includeLowercase: true,
              includeNumbers: true,
              includeSymbols: true,
            );
        passwordGeneratorNotifier.toggleNumbers();

        expect(passwordGeneratorNotifier.state.includeNumbers, isFalse);
      });

      test('should toggle symbols', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: true,
              includeLowercase: true,
              includeNumbers: true,
              includeSymbols: true,
            );
        passwordGeneratorNotifier.toggleSymbols();

        expect(passwordGeneratorNotifier.state.includeSymbols, isFalse);
      });

      test('should not disable last enabled option - uppercase', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: true,
              includeLowercase: false,
              includeNumbers: false,
              includeSymbols: false,
            );
        passwordGeneratorNotifier.toggleUppercase();

        expect(passwordGeneratorNotifier.state.includeUppercase, isTrue);
      });

      test('should not disable last enabled option - lowercase', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: false,
              includeLowercase: true,
              includeNumbers: false,
              includeSymbols: false,
            );
        passwordGeneratorNotifier.toggleLowercase();

        expect(passwordGeneratorNotifier.state.includeLowercase, isTrue);
      });

      test('should not disable last enabled option - numbers', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: false,
              includeLowercase: false,
              includeNumbers: true,
              includeSymbols: false,
            );
        passwordGeneratorNotifier.toggleNumbers();

        expect(passwordGeneratorNotifier.state.includeNumbers, isTrue);
      });

      test('should not disable last enabled option - symbols', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              includeUppercase: false,
              includeLowercase: false,
              includeNumbers: false,
              includeSymbols: true,
            );
        passwordGeneratorNotifier.toggleSymbols();

        expect(passwordGeneratorNotifier.state.includeSymbols, isTrue);
      });
    });

    group('password strength', () {
      test('should calculate strength for short password', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              length: 4,
              includeUppercase: true,
              includeLowercase: true,
              includeNumbers: false,
              includeSymbols: false,
            );
        passwordGeneratorNotifier.generatePassword();

        expect(passwordGeneratorNotifier.state.strength, lessThanOrEqualTo(3));
      });

      test('should calculate higher strength for longer password', () {
        passwordGeneratorNotifier.state = passwordGeneratorNotifier.state
            .copyWith(
              length: 20,
              includeUppercase: true,
              includeLowercase: true,
              includeNumbers: true,
              includeSymbols: true,
            );
        passwordGeneratorNotifier.generatePassword();

        expect(
          passwordGeneratorNotifier.state.strength,
          greaterThanOrEqualTo(4),
        );
      });
    });
  });
}
