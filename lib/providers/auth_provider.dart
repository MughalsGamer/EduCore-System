import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String _role = 'teacher';

  User? get user => _user;
  String get role => _role;

  Future<void> login(String email, String password) async {
    _user = await _authService.signIn(email, password);
    if (_user != null) {
      _role = await _authService.getUserRole(_user!.uid);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _role = 'teacher';
    notifyListeners();
  }

  // For registration
  Future<void> registerUser(String email, String password, String role) async {
    await _authService.registerUser(email, password, role);
  }
}