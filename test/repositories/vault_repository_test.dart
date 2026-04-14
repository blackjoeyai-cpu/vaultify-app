import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify/features/vault/data/datasources/vault_local_datasource.dart';
import 'package:vaultify/features/vault/data/repositories/vault_repository_impl.dart';
import 'package:vaultify/features/vault/domain/entities/password_entry.dart';
import 'package:vaultify/shared/services/encryption_service.dart';
import 'package:vaultify/shared/services/session_provider.dart';
import '../mocks/mock_hive_box.dart';
import '../mocks/mock_secure_storage.dart';

class MockEncryptionService extends EncryptionService {
  MockEncryptionService() : super(MockSecureStorage());

  @override
  Future<String> encryptMap(Map<String, dynamic> data, String password) async {
    final jsonString = jsonEncode(data);
    return base64Encode(utf8.encode(jsonString));
  }

  @override
  Future<Map<String, dynamic>> decryptMap(
    String encryptedData,
    String password,
  ) async {
    final decoded = utf8.decode(base64Decode(encryptedData));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}

void main() {
  late MockHiveBox<String> mockBox;
  late VaultLocalDatasource vaultLocalDatasource;
  late VaultRepositoryImpl vaultRepository;

  setUp(() {
    mockBox = MockHiveBox<String>();
    final sessionNotifier = SessionNotifier();
    sessionNotifier.unlock('testpassword');
    final mockEncryption = MockEncryptionService();
    vaultLocalDatasource = VaultLocalDatasource(
      mockEncryption,
      sessionNotifier,
    );
    vaultLocalDatasource.init(mockBox);
    vaultRepository = VaultRepositoryImpl(vaultLocalDatasource);
  });

  PasswordEntry createTestEntry({
    String id = 'test-id-1',
    String title = 'Test Entry',
    String username = 'testuser@example.com',
    String password = 'TestPassword456!',
    String? url = 'https://test.com',
    String? notes = 'Test notes for this entry',
    PasswordCategory category = PasswordCategory.social,
    bool isFavorite = false,
  }) {
    final now = DateTime.now();
    return PasswordEntry(
      id: id,
      title: title,
      username: username,
      password: password,
      url: url,
      notes: notes,
      category: category,
      createdAt: now,
      updatedAt: now,
      isFavorite: isFavorite,
    );
  }

  group('VaultRepository', () {
    group('getAllPasswords', () {
      test('should return empty list when no passwords exist', () async {
        final passwords = await vaultRepository.getAllPasswords();

        expect(passwords, isEmpty);
      });

      test('should return all password entries', () async {
        final entry1 = createTestEntry(id: 'test-id-1', title: 'Test Entry 1');
        final entry2 = createTestEntry(id: 'test-id-2', title: 'Test Entry 2');

        await vaultRepository.savePassword(entry1);
        await vaultRepository.savePassword(entry2);

        final passwords = await vaultRepository.getAllPasswords();

        expect(passwords.length, equals(2));
      });
    });

    group('getPasswordById', () {
      test('should return password entry when exists', () async {
        final entry = createTestEntry(id: 'test-id-1', title: 'Test Entry');
        await vaultRepository.savePassword(entry);

        final result = await vaultRepository.getPasswordById('test-id-1');

        expect(result, isNotNull);
        expect(result!.title, equals('Test Entry'));
      });

      test('should return null when password does not exist', () async {
        final result = await vaultRepository.getPasswordById('non-existent-id');

        expect(result, isNull);
      });
    });

    group('savePassword', () {
      test('should save new password entry', () async {
        final entry = createTestEntry(id: 'test-id-1', title: 'New Entry');

        await vaultRepository.savePassword(entry);

        final result = await vaultRepository.getPasswordById('test-id-1');
        expect(result, isNotNull);
        expect(result!.title, equals('New Entry'));
      });
    });

    group('updatePassword', () {
      test('should update existing password entry', () async {
        final entry = createTestEntry(id: 'test-id-1', title: 'Original Title');
        await vaultRepository.savePassword(entry);

        final updatedEntry = entry.copyWith(title: 'Updated Title');
        await vaultRepository.updatePassword(updatedEntry);

        final result = await vaultRepository.getPasswordById('test-id-1');
        expect(result!.title, equals('Updated Title'));
      });
    });

    group('deletePassword', () {
      test('should remove password entry from vault', () async {
        final entry = createTestEntry(id: 'test-id-1', title: 'Test Entry');
        await vaultRepository.savePassword(entry);

        await vaultRepository.deletePassword('test-id-1');

        final result = await vaultRepository.getPasswordById('test-id-1');
        expect(result, isNull);
      });
    });

    group('getPasswordsByCategory', () {
      test('should filter passwords by category', () async {
        final socialEntry = createTestEntry(
          id: 'test-id-1',
          category: PasswordCategory.social,
        );
        final financialEntry = createTestEntry(
          id: 'test-id-2',
          category: PasswordCategory.financial,
        );

        await vaultRepository.savePassword(socialEntry);
        await vaultRepository.savePassword(financialEntry);

        final socialPasswords = await vaultRepository.getPasswordsByCategory(
          PasswordCategory.social,
        );

        expect(socialPasswords.length, equals(1));
        expect(socialPasswords.first.category, equals(PasswordCategory.social));
      });

      test('should return empty list when no passwords in category', () async {
        final entry = createTestEntry(category: PasswordCategory.social);
        await vaultRepository.savePassword(entry);

        final financialPasswords = await vaultRepository.getPasswordsByCategory(
          PasswordCategory.financial,
        );

        expect(financialPasswords, isEmpty);
      });
    });

    group('searchPasswords', () {
      test('should search by title', () async {
        final entry = createTestEntry(title: 'Facebook Account');
        await vaultRepository.savePassword(entry);

        final results = await vaultRepository.searchPasswords('facebook');

        expect(results.length, equals(1));
        expect(results.first.title.toLowerCase(), contains('facebook'));
      });

      test('should search by username', () async {
        final entry = createTestEntry(username: 'johndoe@gmail.com');
        await vaultRepository.savePassword(entry);

        final results = await vaultRepository.searchPasswords('johndoe');

        expect(results.length, equals(1));
        expect(results.first.username.toLowerCase(), contains('johndoe'));
      });

      test('should search by URL', () async {
        final entry = createTestEntry(url: 'https://github.com');
        await vaultRepository.savePassword(entry);

        final results = await vaultRepository.searchPasswords('github');

        expect(results.length, equals(1));
        expect(results.first.url!.toLowerCase(), contains('github'));
      });

      test('should return empty list when no matches found', () async {
        final entry = createTestEntry(title: 'Test Entry');
        await vaultRepository.savePassword(entry);

        final results = await vaultRepository.searchPasswords('nonexistent');

        expect(results, isEmpty);
      });

      test('should be case insensitive', () async {
        final entry = createTestEntry(title: 'FACEBOOK');
        await vaultRepository.savePassword(entry);

        final results = await vaultRepository.searchPasswords('facebook');

        expect(results.length, equals(1));
      });
    });
  });
}
