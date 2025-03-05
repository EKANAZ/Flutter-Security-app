import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureStorageHelper {
  static final _storage = FlutterSecureStorage();
  static final _key = encrypt.Key.fromLength(32); // 256-bit key
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static Future<void> storeToken(String key, String value) async {
    final encryptedValue = _encrypter.encrypt(value, iv: _iv).base64;
    await _storage.write(key: key, value: encryptedValue);
  }

  static Future<String?> getToken(String key) async {
    final encryptedValue = await _storage.read(key: key);
    if (encryptedValue != null) {
      return _encrypter.decrypt64(encryptedValue, iv: _iv);
    }
    return null;
  }

  static Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }
}
