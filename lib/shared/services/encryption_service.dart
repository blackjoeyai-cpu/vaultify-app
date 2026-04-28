import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
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

  static Uint8List _deriveKeySync(Map<String, dynamic> params) {
    final password = params['password'] as String;
    final salt = params['salt'] as Uint8List;
    final iterations = params['iterations'] as int;
    final keyLength = params['keyLength'] as int;

    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, iterations, keyLength));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  Future<Uint8List> deriveKey(String password) async {
    final salt = await _getSalt();
    return await compute(_deriveKeySync, {
      'password': password,
      'salt': salt,
      'iterations': AppConstants.pbkdf2Iterations,
      'keyLength': AppConstants.keyLength,
    });
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
    final key = await deriveKey(password);
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

  static Uint8List _encryptSync(Map<String, dynamic> params) {
    final plaintext = params['plaintext'] as String;
    final key = params['key'] as Uint8List;
    final iv = params['iv'] as Uint8List;

    final cipher = GCMBlockCipher(AESEngine());
    final aeadParams = AEADParameters(KeyParameter(key), 128, iv, Uint8List(0));
    cipher.init(true, aeadParams);

    final plaintextBytes = Uint8List.fromList(utf8.encode(plaintext));
    final ciphertext = cipher.process(plaintextBytes);

    final result = Uint8List(iv.length + ciphertext.length);
    result.setAll(0, iv);
    result.setAll(iv.length, ciphertext);

    return result;
  }

  Future<Uint8List> encryptWithKey(String plaintext, Uint8List key) async {
    final iv = _generateIV();
    return await compute(_encryptSync, {
      'plaintext': plaintext,
      'key': key,
      'iv': iv,
    });
  }

  static String _decryptSync(Map<String, dynamic> params) {
    final encryptedData = params['encryptedData'] as Uint8List;
    final key = params['key'] as Uint8List;
    final ivLength = params['ivLength'] as int;

    final iv = encryptedData.sublist(0, ivLength);
    final ciphertext = encryptedData.sublist(ivLength);

    final cipher = GCMBlockCipher(AESEngine());
    final aeadParams = AEADParameters(KeyParameter(key), 128, iv, Uint8List(0));
    cipher.init(false, aeadParams);

    final plaintext = cipher.process(ciphertext);
    return utf8.decode(plaintext);
  }

  Future<String> decryptWithKey(Uint8List encryptedData, Uint8List key) async {
    return await compute(_decryptSync, {
      'encryptedData': encryptedData,
      'key': key,
      'ivLength': AppConstants.ivLength,
    });
  }

  Future<Uint8List> encrypt(String plaintext, String password) async {
    final key = await deriveKey(password);
    return await encryptWithKey(plaintext, key);
  }

  Future<String> decrypt(Uint8List encryptedData, String password) async {
    final key = await deriveKey(password);
    return await decryptWithKey(encryptedData, key);
  }

  Future<bool> hasMasterPassword() async {
    final hash = await _secureStorage.read(key: StorageKeys.masterPasswordHash);
    return hash != null;
  }

  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
  }

  Future<String> encryptMap(
    Map<String, dynamic> data,
    String password, {
    Uint8List? key,
  }) async {
    final jsonString = jsonEncode(data);
    final encryptedBytes = key != null
        ? await encryptWithKey(jsonString, key)
        : await encrypt(jsonString, password);
    return base64Encode(encryptedBytes);
  }

  Future<Map<String, dynamic>> decryptMap(
    String encryptedData,
    String password, {
    Uint8List? key,
  }) async {
    final encryptedBytes = base64Decode(encryptedData);
    final decryptedString = key != null
        ? await decryptWithKey(encryptedBytes, key)
        : await decrypt(encryptedBytes, password);
    return jsonDecode(decryptedString) as Map<String, dynamic>;
  }
}
