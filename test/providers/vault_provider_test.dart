import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vaultify/features/vault/application/providers/vault_provider.dart';
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
  late VaultNotifier vaultNotifier;
  late SessionNotifier sessionNotifier;

  setUp(() {
    mockBox = MockHiveBox<String>();
    sessionNotifier = SessionNotifier();
    sessionNotifier.unlock('testpassword');
    final mockEncryption = MockEncryptionService();
    vaultLocalDatasource = VaultLocalDatasource(
      mockEncryption,
      sessionNotifier,
    );
    vaultLocalDatasource.init(mockBox);
    vaultRepository = VaultRepositoryImpl(vaultLocalDatasource);
    vaultNotifier = VaultNotifier(vaultRepository);
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

  group('VaultState', () {
    test('should have correct default values', () {
      const state = VaultState();

      expect(state.passwords, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.selectedCategory, isNull);
      expect(state.searchQuery, isEmpty);
    });

    test('copyWith should create new state with updated values', () {
      const state = VaultState();
      final entries = [createTestEntry()];

      final newState = state.copyWith(passwords: entries, isLoading: true);

      expect(newState.passwords.length, equals(1));
      expect(newState.isLoading, isTrue);
      expect(newState.searchQuery, isEmpty);
    });

    test('copyWith should preserve unchanged values', () {
      final entries = [createTestEntry()];
      const state = VaultState(isLoading: true, searchQuery: 'test');

      final newState = state.copyWith(passwords: entries);

      expect(newState.passwords.length, equals(1));
      expect(newState.isLoading, isTrue);
      expect(newState.searchQuery, equals('test'));
    });

    test('copyWith with clearCategory should set category to null', () {
      const state = VaultState(selectedCategory: PasswordCategory.social);

      final newState = state.copyWith(clearCategory: true);

      expect(newState.selectedCategory, isNull);
    });
  });

  group('VaultNotifier', () {
    group('loadPasswords', () {
      test('should return empty list when vault is empty', () async {
        await vaultNotifier.loadPasswords();

        expect(vaultNotifier.state.passwords, isEmpty);
        expect(vaultNotifier.state.isLoading, isFalse);
      });

      test('should load all password entries', () async {
        final entry1 = createTestEntry(id: 'test-id-1', title: 'Entry 1');
        final entry2 = createTestEntry(id: 'test-id-2', title: 'Entry 2');
        await vaultRepository.savePassword(entry1);
        await vaultRepository.savePassword(entry2);

        await vaultNotifier.loadPasswords();

        expect(vaultNotifier.state.passwords.length, equals(2));
        expect(vaultNotifier.state.isLoading, isFalse);
      });
    });

    group('addPassword', () {
      test('should add new password to vault', () async {
        final entry = createTestEntry(id: 'test-id-1', title: 'New Entry');

        await vaultNotifier.addPassword(entry);

        expect(vaultNotifier.state.passwords.length, equals(1));
        expect(vaultNotifier.state.passwords.first.title, equals('New Entry'));
      });
    });

    group('updatePassword', () {
      test('should update existing password', () async {
        final entry = createTestEntry(id: 'test-id-1', title: 'Original');
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        final updatedEntry = entry.copyWith(title: 'Updated');
        await vaultNotifier.updatePassword(updatedEntry);

        expect(vaultNotifier.state.passwords.first.title, equals('Updated'));
      });
    });

    group('deletePassword', () {
      test('should remove password from vault', () async {
        final entry = createTestEntry(id: 'test-id-1', title: 'Test');
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        await vaultNotifier.deletePassword('test-id-1');

        expect(vaultNotifier.state.passwords, isEmpty);
      });
    });

    group('toggleFavorite', () {
      test('should toggle favorite status', () async {
        final entry = createTestEntry(id: 'test-id-1', isFavorite: false);
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        await vaultNotifier.toggleFavorite('test-id-1');

        expect(vaultNotifier.state.passwords.first.isFavorite, isTrue);
      });

      test('should toggle favorite back to false', () async {
        final entry = createTestEntry(id: 'test-id-1', isFavorite: true);
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        await vaultNotifier.toggleFavorite('test-id-1');

        expect(vaultNotifier.state.passwords.first.isFavorite, isFalse);
      });

      test('should do nothing for non-existent id', () async {
        final entry = createTestEntry(id: 'test-id-1', isFavorite: false);
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        await vaultNotifier.toggleFavorite('non-existent-id');

        expect(vaultNotifier.state.passwords.first.isFavorite, isFalse);
      });
    });

    group('setCategory', () {
      test('should filter by category', () async {
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
        await vaultNotifier.loadPasswords();

        vaultNotifier.setCategory(PasswordCategory.social);

        expect(
          vaultNotifier.state.selectedCategory,
          equals(PasswordCategory.social),
        );
        expect(vaultNotifier.state.filteredPasswords.length, equals(1));
      });

      test('should clear category when same category is selected', () async {
        final entry = createTestEntry(category: PasswordCategory.social);
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        vaultNotifier.setCategory(PasswordCategory.social);
        vaultNotifier.setCategory(PasswordCategory.social);

        expect(vaultNotifier.state.selectedCategory, isNull);
      });
    });

    group('setSearchQuery', () {
      test('should filter by search query', () async {
        final entry = createTestEntry(title: 'Facebook Account');
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        vaultNotifier.setSearchQuery('facebook');

        expect(vaultNotifier.state.searchQuery, equals('facebook'));
        expect(vaultNotifier.state.filteredPasswords.length, equals(1));
      });

      test('should return empty when no matches', () async {
        final entry = createTestEntry(title: 'Test Entry');
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        vaultNotifier.setSearchQuery('nonexistent');

        expect(vaultNotifier.state.filteredPasswords, isEmpty);
      });
    });

    group('clearFilters', () {
      test('should reset all filters', () async {
        final entry = createTestEntry(title: 'Test');
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        vaultNotifier.setCategory(PasswordCategory.social);
        vaultNotifier.setSearchQuery('test');
        vaultNotifier.clearFilters();

        expect(vaultNotifier.state.selectedCategory, isNull);
        expect(vaultNotifier.state.searchQuery, isEmpty);
        expect(vaultNotifier.state.filteredPasswords.length, equals(1));
      });
    });

    group('filteredPasswords', () {
      test('should sort favorites first', () async {
        final favoriteEntry = createTestEntry(
          id: 'test-id-1',
          title: 'Favorite Entry',
          isFavorite: true,
        );
        final normalEntry = createTestEntry(
          id: 'test-id-2',
          title: 'Normal Entry',
          isFavorite: false,
        );
        await vaultRepository.savePassword(favoriteEntry);
        await vaultRepository.savePassword(normalEntry);
        await vaultNotifier.loadPasswords();

        final filtered = vaultNotifier.state.filteredPasswords;

        expect(filtered.first.isFavorite, isTrue);
      });

      test('should filter by category', () async {
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
        await vaultNotifier.loadPasswords();

        vaultNotifier.setCategory(PasswordCategory.social);

        final filtered = vaultNotifier.state.filteredPasswords;

        expect(filtered.length, equals(1));
        expect(filtered.first.category, equals(PasswordCategory.social));
      });

      test('should filter by search query in title', () async {
        final entry = createTestEntry(title: 'My Facebook Account');
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        vaultNotifier.setSearchQuery('facebook');

        expect(vaultNotifier.state.filteredPasswords.length, equals(1));
      });

      test('should filter by search query in username', () async {
        final entry = createTestEntry(username: 'johndoe@gmail.com');
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        vaultNotifier.setSearchQuery('johndoe');

        expect(vaultNotifier.state.filteredPasswords.length, equals(1));
      });

      test('should filter by search query in URL', () async {
        final entry = createTestEntry(url: 'https://github.com');
        await vaultRepository.savePassword(entry);
        await vaultNotifier.loadPasswords();

        vaultNotifier.setSearchQuery('github');

        expect(vaultNotifier.state.filteredPasswords.length, equals(1));
      });
    });
  });
}
