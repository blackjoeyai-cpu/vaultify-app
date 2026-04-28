import 'dart:typed_data';
import 'package:hive/hive.dart';
import '../../domain/entities/password_entry.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../shared/services/encryption_service.dart';

class VaultLocalDatasource {
  final EncryptionService _encryptionService;
  final String? Function() _getMasterPassword;
  final Uint8List? Function() _getDerivedKey;
  Box<String>? _passwordBox;

  VaultLocalDatasource(
    this._encryptionService,
    this._getMasterPassword,
    this._getDerivedKey,
  );

  Future<void> init([Box<String>? passwordBox]) async {
    _passwordBox =
        passwordBox ?? await Hive.openBox<String>(StorageKeys.passwordEntries);
  }

  Box<String> get _box {
    if (_passwordBox == null) {
      throw StateError(
        'VaultLocalDatasource not initialized. Call init() first.',
      );
    }
    return _passwordBox!;
  }

  String? get _masterPassword => _getMasterPassword();
  Uint8List? get _derivedKey => _getDerivedKey();

  Future<List<PasswordEntry>> getAllPasswords() async {
    final masterPassword = _masterPassword;
    final derivedKey = _derivedKey;
    if (masterPassword == null) {
      throw StateError('Session not unlocked. Master password required.');
    }

    final entries = <PasswordEntry>[];
    for (final key in _box.keys) {
      final encrypted = _box.get(key);
      if (encrypted != null) {
        entries.add(
          await _passwordEntryFromEncrypted(
            encrypted,
            masterPassword,
            key: derivedKey,
          ),
        );
      }
    }
    return entries;
  }

  Future<PasswordEntry?> getPasswordById(String id) async {
    final masterPassword = _masterPassword;
    final derivedKey = _derivedKey;
    if (masterPassword == null) {
      throw StateError('Session not unlocked. Master password required.');
    }

    final encrypted = _box.get(id);
    if (encrypted == null) return null;
    return _passwordEntryFromEncrypted(
      encrypted,
      masterPassword,
      key: derivedKey,
    );
  }

  Future<void> savePassword(PasswordEntry entry) async {
    final masterPassword = _masterPassword;
    final derivedKey = _derivedKey;
    if (masterPassword == null) {
      throw StateError('Session not unlocked. Master password required.');
    }

    final encrypted = await _passwordEntryToEncrypted(
      entry,
      masterPassword,
      key: derivedKey,
    );
    await _box.put(entry.id, encrypted);
  }

  Future<void> deletePassword(String id) async {
    await _box.delete(id);
  }

  Future<PasswordEntry> _passwordEntryFromEncrypted(
    String encrypted,
    String masterPassword, {
    Uint8List? key,
  }) async {
    final map = await _encryptionService.decryptMap(
      encrypted,
      masterPassword,
      key: key,
    );
    return PasswordEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      url: map['url'] as String?,
      notes: map['notes'] as String?,
      category: PasswordCategory.values[map['category'] as int],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  Future<String> _passwordEntryToEncrypted(
    PasswordEntry entry,
    String masterPassword, {
    Uint8List? key,
  }) async {
    final data = {
      'id': entry.id,
      'title': entry.title,
      'username': entry.username,
      'password': entry.password,
      'url': entry.url,
      'notes': entry.notes,
      'category': entry.category.index,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
      'isFavorite': entry.isFavorite,
    };
    return await _encryptionService.encryptMap(
      data,
      masterPassword,
      key: key,
    );
  }
}
