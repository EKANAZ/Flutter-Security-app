import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthenticationService {
  final String baseUrl = 'https://test.ekanas.com/auth';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, String>> loginWithEmailAndPassword({required String userName, required String password}) async {
    final response = await http.post(Uri.parse('$baseUrl/login'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'user_name': userName, 'password': password}));
    if (response.statusCode == 200) {
      final tokens = Map<String, String>.from(jsonDecode(response.body));
      await _storage.write(key: 'access_token', value: EncryptionHelper.encryptText(tokens['accessToken']!));
      await _storage.write(key: 'refresh_token', value: EncryptionHelper.encryptText(tokens['refreshToken']!));
      return tokens;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign-In cancelled by user');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final String? idToken = await userCredential.user!.getIdToken();
      if (idToken == null) throw Exception('Failed to retrieve Firebase ID token');
      final response = await http.post(Uri.parse('$baseUrl/oauth-login'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'idToken': idToken}));
      if (response.statusCode == 200) {
        final tokens = Map<String, String>.from(jsonDecode(response.body));
        await _storage.write(key: 'access_token', value: EncryptionHelper.encryptText(tokens['accessToken']!));
        await _storage.write(key: 'refresh_token', value: EncryptionHelper.encryptText(tokens['refreshToken']!));
        return {'tokens': tokens, 'email': googleUser.email, 'name': googleUser.displayName ?? 'Google User'};
      } else {
        throw Exception('OAuth login failed: ${response.body}');
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    final encryptedToken = await _storage.read(key: 'access_token');
    return encryptedToken != null ? EncryptionHelper.decryptText(encryptedToken) : null;
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await http.post(Uri.parse('$baseUrl/refresh-token'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'refreshToken': refreshToken}));
    if (response.statusCode == 200) {
      final newToken = jsonDecode(response.body)['accessToken'];
      await _storage.write(key: 'access_token', value: EncryptionHelper.encryptText(newToken));
      return newToken;
    } else {
      throw Exception('Refresh token failed: ${response.body}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await _storage.deleteAll();
  }
}

class EncryptionHelper {
  // This key is 32 characters (32 bytes = 256 bits)
  static final _key = encrypt.Key.fromUtf8('A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6');
  static final _iv = encrypt.IV.fromLength(16); // 16 bytes for AES
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

  // Encrypt a plaintext string
  static String encryptText(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Decrypt an encrypted string
  static String decryptText(String encryptedText) {
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
}
