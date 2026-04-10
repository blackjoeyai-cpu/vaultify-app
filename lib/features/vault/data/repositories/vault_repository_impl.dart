import '../../domain/entities/password_entry.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/vault_local_datasource.dart';

class VaultRepositoryImpl implements VaultRepository {
  final VaultLocalDatasource _localDatasource;

  VaultRepositoryImpl(this._localDatasource);

  @override
  Future<List<PasswordEntry>> getAllPasswords() async {
    return await _localDatasource.getAllPasswords();
  }

  @override
  Future<PasswordEntry?> getPasswordById(String id) async {
    return await _localDatasource.getPasswordById(id);
  }

  @override
  Future<void> savePassword(PasswordEntry entry) async {
    await _localDatasource.savePassword(entry);
  }

  @override
  Future<void> updatePassword(PasswordEntry entry) async {
    await _localDatasource.savePassword(entry);
  }

  @override
  Future<void> deletePassword(String id) async {
    await _localDatasource.deletePassword(id);
  }

  @override
  Future<List<PasswordEntry>> getPasswordsByCategory(
    PasswordCategory category,
  ) async {
    final passwords = await getAllPasswords();
    return passwords.where((p) => p.category == category).toList();
  }

  @override
  Future<List<PasswordEntry>> searchPasswords(String query) async {
    final passwords = await getAllPasswords();
    final lowerQuery = query.toLowerCase();
    return passwords.where((p) {
      return p.title.toLowerCase().contains(lowerQuery) ||
          p.username.toLowerCase().contains(lowerQuery) ||
          (p.url?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
