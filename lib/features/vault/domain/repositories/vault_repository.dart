import '../entities/password_entry.dart';

abstract class VaultRepository {
  Future<List<PasswordEntry>> getAllPasswords();
  Future<PasswordEntry?> getPasswordById(String id);
  Future<void> savePassword(PasswordEntry entry);
  Future<void> updatePassword(PasswordEntry entry);
  Future<void> deletePassword(String id);
  Future<List<PasswordEntry>> getPasswordsByCategory(PasswordCategory category);
  Future<List<PasswordEntry>> searchPasswords(String query);
}
