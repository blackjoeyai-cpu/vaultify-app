import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify/core/constants/storage_keys.dart';
import 'package:vaultify/shared/services/encryption_service.dart';
import '../mocks/mock_secure_storage.dart';

void main() {
  late MockSecureStorage mockStorage;
  late EncryptionService encryptionService;

  setUp(() {
    mockStorage = MockSecureStorage();
    encryptionService = EncryptionService(mockStorage);
  });

  group('EncryptionService', () {
    group('generateSalt', () {
      test('should generate and store salt', () async {
        await encryptionService.generateSalt();

        final salt = await mockStorage.read(key: StorageKeys.encryptionSalt);
        expect(salt, isNotNull);
        expect(salt!.isNotEmpty, isTrue);
      });
    });

    group('hashMasterPassword', () {
      test('should generate hash from password', () async {
        await encryptionService.generateSalt();

        final hash = await encryptionService.hashMasterPassword(
          'TestPassword123!',
        );

        expect(hash, isNotNull);
        expect(hash.isNotEmpty, isTrue);
      });

      test('should generate consistent hash for same password', () async {
        await encryptionService.generateSalt();

        final hash1 = await encryptionService.hashMasterPassword(
          'TestPassword123!',
        );
        final hash2 = await encryptionService.hashMasterPassword(
          'TestPassword123!',
        );

        expect(hash1, equals(hash2));
      });

      test('should generate different hash for different passwords', () async {
        await encryptionService.generateSalt();

        final hash1 = await encryptionService.hashMasterPassword(
          'TestPassword123!',
        );
        final hash2 = await encryptionService.hashMasterPassword(
          'DifferentPassword456!',
        );

        expect(hash1, isNot(equals(hash2)));
      });
    });

    group('saveMasterPasswordHash', () {
      test('should save hash to storage', () async {
        await encryptionService.generateSalt();
        await encryptionService.saveMasterPasswordHash('TestPassword123!');

        final storedHash = await mockStorage.read(
          key: StorageKeys.masterPasswordHash,
        );
        expect(storedHash, isNotNull);
        expect(storedHash!.isNotEmpty, isTrue);
      });
    });

    group('verifyMasterPassword', () {
      test('should return true for correct password', () async {
        await encryptionService.generateSalt();
        await encryptionService.saveMasterPasswordHash('TestPassword123!');

        final isValid = await encryptionService.verifyMasterPassword(
          'TestPassword123!',
        );

        expect(isValid, isTrue);
      });

      test('should return false for incorrect password', () async {
        await encryptionService.generateSalt();
        await encryptionService.saveMasterPasswordHash('TestPassword123!');

        final isValid = await encryptionService.verifyMasterPassword(
          'WrongPassword456!',
        );

        expect(isValid, isFalse);
      });

      test('should return false when no password hash exists', () async {
        final isValid = await encryptionService.verifyMasterPassword(
          'TestPassword123!',
        );

        expect(isValid, isFalse);
      });
    });

    group('encrypt and decrypt', () {
      test('should encrypt plaintext and return encrypted data', () async {
        await encryptionService.generateSalt();

        final encrypted = await encryptionService.encrypt(
          'TestSecretData',
          'TestPassword123!',
        );

        expect(encrypted, isNotNull);
        expect(encrypted.isNotEmpty, isTrue);
      });

      test('should decrypt encrypted data back to original', () async {
        await encryptionService.generateSalt();

        const plaintext = 'TestSecretData';
        final encrypted = await encryptionService.encrypt(
          plaintext,
          'TestPassword123!',
        );
        final decrypted = await encryptionService.decrypt(
          encrypted,
          'TestPassword123!',
        );

        expect(decrypted, equals(plaintext));
      });

      test(
        'should produce different ciphertext for same plaintext (different IV)',
        () async {
          await encryptionService.generateSalt();

          const plaintext = 'TestSecretData';
          final encrypted1 = await encryptionService.encrypt(
            plaintext,
            'TestPassword123!',
          );
          final encrypted2 = await encryptionService.encrypt(
            plaintext,
            'TestPassword123!',
          );

          expect(encrypted1, isNot(equals(encrypted2)));
        },
      );

      test('should fail to decrypt with wrong password', () async {
        await encryptionService.generateSalt();

        const plaintext = 'TestSecretData';
        final encrypted = await encryptionService.encrypt(
          plaintext,
          'TestPassword123!',
        );

        expect(
          () => encryptionService.decrypt(encrypted, 'WrongPassword456!'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('hasMasterPassword', () {
      test('should return true when hash exists', () async {
        await encryptionService.generateSalt();
        await encryptionService.saveMasterPasswordHash('TestPassword123!');

        final hasPassword = await encryptionService.hasMasterPassword();

        expect(hasPassword, isTrue);
      });

      test('should return false when no hash exists', () async {
        final hasPassword = await encryptionService.hasMasterPassword();

        expect(hasPassword, isFalse);
      });
    });

    group('clearAllData', () {
      test('should clear all stored data', () async {
        await encryptionService.generateSalt();
        await encryptionService.saveMasterPasswordHash('TestPassword123!');

        await encryptionService.clearAllData();

        final salt = await mockStorage.read(key: StorageKeys.encryptionSalt);
        final hash = await mockStorage.read(
          key: StorageKeys.masterPasswordHash,
        );

        expect(salt, isNull);
        expect(hash, isNull);
      });
    });

    group('biometric encryption', () {
      test('should encrypt password for biometric storage', () async {
        final encrypted = await encryptionService.encryptForBiometric(
          'TestPassword123!',
        );

        expect(encrypted, isNotNull);
        expect(encrypted.isNotEmpty, isTrue);
      });

      test('should decrypt biometric encrypted password', () async {
        const password = 'TestPassword123!';
        final encrypted = await encryptionService.encryptForBiometric(password);
        final decrypted = await encryptionService.decryptForBiometric(
          encrypted,
        );

        expect(decrypted, equals(password));
      });
    });
  });
}
