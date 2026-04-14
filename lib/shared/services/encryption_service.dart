import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/storage_keys.dart';

class EncryptionService {
  final FlutterSecureStorage _secureStorage;

  EncryptionService(this._secureStorage);

  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Uint8List _deriveKey(String password, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(
      Pbkdf2Parameters(
        salt,
        AppConstants.pbkdf2Iterations,
        AppConstants.keyLength,
      ),
    );
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  Future<void> generateSalt() async {
    final salt = _generateRandomBytes(AppConstants.saltLength);
    await _secureStorage.write(
      key: StorageKeys.encryptionSalt,
      value: base64Encode(salt),
    );
  }

  Future<Uint8List> _getSalt() async {
    final saltString = await _secureStorage.read(
      key: StorageKeys.encryptionSalt,
    );
    if (saltString == null) {
      throw Exception('Salt not found');
    }
    return base64Decode(saltString);
  }

  Future<String> hashMasterPassword(String password) async {
    final salt = await _getSalt();
    final key = _deriveKey(password, salt);
    final digest = SHA256Digest();
    final hash = digest.process(key);
    return base64Encode(hash);
  }

  Future<void> saveMasterPasswordHash(String password) async {
    final hash = await hashMasterPassword(password);
    await _secureStorage.write(
      key: StorageKeys.masterPasswordHash,
      value: hash,
    );
  }

  Future<bool> verifyMasterPassword(String password) async {
    final storedHash = await _secureStorage.read(
      key: StorageKeys.masterPasswordHash,
    );
    if (storedHash == null) {
      return false;
    }
    final inputHash = await hashMasterPassword(password);
    return storedHash == inputHash;
  }

  Uint8List _generateIV() {
    return _generateRandomBytes(AppConstants.ivLength);
  }

  Future<Uint8List> encrypt(String plaintext, String password) async {
    final salt = await _getSalt();
    final key = _deriveKey(password, salt);
    final iv = _generateIV();

    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(KeyParameter(key), 128, iv, Uint8List(0));
    cipher.init(true, params);

    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    final ciphertext = cipher.process(plaintextBytes);

    final result = Uint8List(iv.length + ciphertext.length);
    result.setAll(0, iv);
    result.setAll(iv.length, ciphertext);

    return result;
  }

  Future<String> decrypt(Uint8List encryptedData, String password) async {
    final salt = await _getSalt();
    final key = _deriveKey(password, salt);

    final iv = encryptedData.sublist(0, AppConstants.ivLength);
    final ciphertext = encryptedData.sublist(AppConstants.ivLength);

    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(KeyParameter(key), 128, iv, Uint8List(0));
    cipher.init(false, params);

    final plaintext = cipher.process(ciphertext);
    return utf8.decode(plaintext);
  }

  Future<bool> hasMasterPassword() async {
    final hash = await _secureStorage.read(key: StorageKeys.masterPasswordHash);
    return hash != null;
  }

  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
  }

  Future<String> _getBiometricEncryptionKey() async {
    var key = await _secureStorage.read(
      key: StorageKeys.biometricEncryptionKey,
    );
    if (key == null) {
      key = base64Encode(_generateRandomBytes(AppConstants.keyLength));
      await _secureStorage.write(
        key: StorageKeys.biometricEncryptionKey,
        value: key,
      );
    }
    return key;
  }

  Future<Uint8List> _encryptWithKey(String plaintext, Uint8List key) async {
    final iv = _generateRandomBytes(AppConstants.ivLength);

    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(KeyParameter(key), 128, iv, Uint8List(0));
    cipher.init(true, params);

    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    final ciphertext = cipher.process(plaintextBytes);

    final result = Uint8List(iv.length + ciphertext.length);
    result.setAll(0, iv);
    result.setAll(iv.length, ciphertext);

    return result;
  }

  Future<String> _decryptWithKey(Uint8List encryptedData, Uint8List key) async {
    final iv = encryptedData.sublist(0, AppConstants.ivLength);
    final ciphertext = encryptedData.sublist(AppConstants.ivLength);

    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(KeyParameter(key), 128, iv, Uint8List(0));
    cipher.init(false, params);

    final plaintext = cipher.process(ciphertext);
    return utf8.decode(plaintext);
  }

  Future<String> encryptForBiometric(String password) async {
    final keyString = await _getBiometricEncryptionKey();
    final key = base64Decode(keyString);
    final encrypted = await _encryptWithKey(password, key);
    return base64Encode(encrypted);
  }

  Future<String> decryptForBiometric(String encryptedPassword) async {
    final keyString = await _getBiometricEncryptionKey();
    final key = base64Decode(keyString);
    final encryptedData = base64Decode(encryptedPassword);
    return await _decryptWithKey(encryptedData, key);
  }
}
