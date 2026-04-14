import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify/core/constants/storage_keys.dart';
import 'package:vaultify/shared/services/encryption_service.dart';
import '../mocks/mock_secure_storage.dart';
import '../test_config.dart';

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
          TestConfig.correctPassword,
        );

        expect(hash, isNotNull);
        expect(hash.isNotEmpty, isTrue);
      });

      test('should generate consistent hash for same password', () async {
        await encryptionService.generateSalt();

        final hash1 = await encryptionService.hashMasterPassword(
          TestConfig.correctPassword,
        );
        final hash2 = await encryptionService.hashMasterPassword(
          TestConfig.correctPassword,
        );

        expect(hash1, equals(hash2));
      });

      test('should generate different hash for different passwords', () async {
        await encryptionService.generateSalt();

        final hash1 = await encryptionService.hashMasterPassword(
          TestConfig.correctPassword,
        );
        final hash2 = await encryptionService.hashMasterPassword(
          TestConfig.differentPassword,
        );

        expect(hash1, isNot(equals(hash2)));
      });
    });

    group('saveMasterPasswordHash', () {
      test('should save hash to storage', () async {
        await encryptionService.generateSalt();
        await encryptionService.saveMasterPasswordHash(
          TestConfig.correctPassword,
        );

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
        await encryptionService.saveMasterPasswordHash(
          TestConfig.correctPassword,
        );

        final isValid = await encryptionService.verifyMasterPassword(
          TestConfig.correctPassword,
        );

        expect(isValid, isTrue);
      });

      test('should return false for incorrect password', () async {
        await encryptionService.generateSalt();
        await encryptionService.saveMasterPasswordHash(
          TestConfig.correctPassword,
        );

        final isValid = await encryptionService.verifyMasterPassword(
          TestConfig.wrongPassword,
        );

        expect(isValid, isFalse);
      });

      test('should return false when no password hash exists', () async {
        final isValid = await encryptionService.verifyMasterPassword(
          TestConfig.correctPassword,
        );

        expect(isValid, isFalse);
      });
    });

    group('encrypt and decrypt', () {
      test('should encrypt plaintext and return encrypted data', () async {
        await encryptionService.generateSalt();

        final encrypted = await encryptionService.encrypt(
          TestConfig.testSecretData,
          TestConfig.correctPassword,
        );

        expect(encrypted, isNotNull);
        expect(encrypted.isNotEmpty, isTrue);
      });

      test('should decrypt encrypted data back to original', () async {
        await encryptionService.generateSalt();

        final encrypted = await encryptionService.encrypt(
          TestConfig.testSecretData,
          TestConfig.correctPassword,
        );
        final decrypted = await encryptionService.decrypt(
          encrypted,
          TestConfig.correctPassword,
        );

        expect(decrypted, equals(TestConfig.testSecretData));
      });

      test(
        'should produce different ciphertext for same plaintext (different IV)',
        () async {
          await encryptionService.generateSalt();

          final encrypted1 = await encryptionService.encrypt(
            TestConfig.testSecretData,
            TestConfig.correctPassword,
          );
          final encrypted2 = await encryptionService.encrypt(
            TestConfig.testSecretData,
            TestConfig.correctPassword,
          );

          expect(encrypted1, isNot(equals(encrypted2)));
        },
      );

      test('should fail to decrypt with wrong password', () async {
        await encryptionService.generateSalt();

        final encrypted = await encryptionService.encrypt(
          TestConfig.testSecretData,
          TestConfig.correctPassword,
        );

        expect(
          () => encryptionService.decrypt(encrypted, TestConfig.wrongPassword),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('hasMasterPassword', () {
      test('should return true when hash exists', () async {
        await encryptionService.generateSalt();
        await encryptionService.saveMasterPasswordHash(
          TestConfig.correctPassword,
        );

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
        await encryptionService.saveMasterPasswordHash(
          TestConfig.correctPassword,
        );

        await encryptionService.clearAllData();

        final salt = await mockStorage.read(key: StorageKeys.encryptionSalt);
        final hash = await mockStorage.read(
          key: StorageKeys.masterPasswordHash,
        );

        expect(salt, isNull);
        expect(hash, isNull);
      });
    });
  });
}
