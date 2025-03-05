import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final String baseUrl = 'http://localhost:3000/auth';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, String>> loginWithEmailAndPassword({required String userName, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_name': userName, 'password': password}),
    );
    if (response.statusCode == 200) {
      return Map<String, String>.from(jsonDecode(response.body));
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, String>> registerUser({required String email, required String password, required String phone, required String userName}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'phone': phone, 'user_name': userName}),
    );
    if (response.statusCode == 201) {
      return Map<String, String>.from(jsonDecode(response.body));
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw 'Google Sign-In cancelled';
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['accessToken'];
    } else {
      throw Exception('Refresh token failed: ${response.body}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}