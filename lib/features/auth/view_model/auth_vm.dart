import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_security/core/auth_helpers.dart';
import 'package:flutter_security/core/secure_storage_helper.dart';
import 'package:flutter_security/core/validation_helper.dart';
import 'package:flutter_security/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationViewModel extends ChangeNotifier {
  final AuthenticationService _authService;
  String _email = '';
  String _password = '';
  String _userName = '';
  String _phone = '';
  String _errorMessage = '';
  UserModel? _user;
  String? _accessToken;
  String? _refreshToken;

  AuthenticationViewModel(this._authService) {
    _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        _user = UserModel(uid: firebaseUser.uid, email: firebaseUser.email);
        notifyListeners();
      }
    });
  }

  String get email => _email;
  String get password => _password;
  String get userName => _userName;
  String get phone => _phone;
  String get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isLoginFormValid => ValidationHelper.isValidUserName(_userName) && ValidationHelper.isValidPassword(_password);
  bool get isRegistrationFormValid =>
      ValidationHelper.isValidEmail(_email) &&
      ValidationHelper.isValidPassword(_password) &&
      ValidationHelper.isValidPhoneNumber(_phone) &&
      ValidationHelper.isValidUserName(_userName);

  void setEmail(String email) {
    _email = email;
    _errorMessage = '';
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    _errorMessage = '';
    notifyListeners();
  }

  void setUserName(String userName) {
    _userName = userName;
    _errorMessage = '';
    notifyListeners();
  }

  void setPhone(String phone) {
    _phone = phone;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> loginWithEmailAndPassword() async {
    try {
      final tokens = await _authService.loginWithEmailAndPassword(userName: _userName, password: _password);
      _accessToken = tokens['accessToken'];
      _refreshToken = tokens['refreshToken'];
      await SecureStorageHelper.storeToken('access_token', _accessToken!);
      await SecureStorageHelper.storeToken('refresh_token', _refreshToken!);
      _user = UserModel(uid: 'node_${_userName.hashCode}', userName: _userName);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> registerUser() async {
    try {
      final tokens = await _authService.registerUser(
        email: _email,
        password: _password,
        phone: _phone,
        userName: _userName,
      );
      _accessToken = tokens['accessToken'];
      _refreshToken = tokens['refreshToken'];
      await SecureStorageHelper.storeToken('access_token', _accessToken!);
      await SecureStorageHelper.storeToken('refresh_token', _refreshToken!);
      _user = UserModel(uid: 'node_${_userName.hashCode}', email: _email, userName: _userName);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      _user = UserModel(uid: userCredential.user!.uid, email: userCredential.user!.email);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    await SecureStorageHelper.deleteToken('access_token');
    await SecureStorageHelper.deleteToken('refresh_token');
    _email = '';
    _password = '';
    _userName = '';
    _phone = '';
    _errorMessage = '';
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  Future<String?> getAccessToken() async {
    _accessToken ??= await SecureStorageHelper.getToken('access_token');
    return _accessToken;
  }

  Future<void> refreshAccessToken() async {
    try {
      _refreshToken ??= await SecureStorageHelper.getToken('refresh_token');
      if (_refreshToken != null) {
        final newAccessToken = await _authService.refreshAccessToken(_refreshToken!);
        _accessToken = newAccessToken;
        await SecureStorageHelper.storeToken('access_token', _accessToken!);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Token refresh failed: $e';
      notifyListeners();
    }
  }
}