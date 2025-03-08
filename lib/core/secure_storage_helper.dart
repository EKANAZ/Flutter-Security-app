// core/secure_storage_helper.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureStorageHelper {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  static final _key = encrypt.Key.fromUtf8('your-32-char-key-here1234567890'); // Must be 32 characters
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  // Write a value to secure storage with encryption
  Future<void> write(String key, String value) async {
    try {
      final encryptedValue = _encrypter.encrypt(value, iv: _iv).base64;
      await _storage.write(key: key, value: encryptedValue);
    } catch (e) {
      throw Exception('Failed to write to secure storage: $e');
    }
  }

  // Read a value from secure storage and decrypt it
  Future<String?> read(String key) async {
    try {
      final encryptedValue = await _storage.read(key: key);
      if (encryptedValue == null) return null;
      return _encrypter.decrypt64(encryptedValue, iv: _iv);
    } catch (e) {
      throw Exception('Failed to read from secure storage: $e');
    }
  }

  // Delete a specific key from secure storage
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete from secure storage: $e');
    }
  }

  // Delete all keys from secure storage
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to delete all from secure storage: $e');
    }
  }

  // Check if a key exists in secure storage
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      throw Exception('Failed to check key in secure storage: $e');
    }
  }
}