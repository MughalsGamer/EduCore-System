// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/auth_service.dart';
//
// class AuthProvider extends ChangeNotifier {
//   final AuthService _authService = AuthService();
//   User? _user;
//   String _role = 'teacher';
//
//   User? get user => _user;
//   String get role => _role;
//
//   Future<void> login(String email, String password) async {
//     _user = await _authService.signIn(email, password);
//     if (_user != null) {
//       _role = await _authService.getUserRole(_user!.uid);
//     }
//     notifyListeners();
//   }
//
//   Future<void> logout() async {
//     await _authService.signOut();
//     _user = null;
//     _role = 'teacher';
//     notifyListeners();
//   }
//
//   // For registration
//   Future<void> registerUser(String email, String password, String role) async {
//     await _authService.registerUser(email, password, role);
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String _role = 'teacher';
  bool _isLoading = true; // for showing splash/loading state

  User? get user => _user;
  String get role => _role;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  // ── Initialize: load user and role from Firebase + SharedPreferences ──
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = currentUser;
      // Load role from SharedPreferences
      _role = await _loadRoleFromPrefs() ?? 'teacher';
    } else {
      _user = null;
      _role = 'teacher';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load role from SharedPreferences ──
  Future<String?> _loadRoleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  // ── Save role to SharedPreferences ──
  Future<void> _saveRoleToPrefs(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
  }

  // ── Clear stored role ──
  Future<void> _clearRoleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
  }

  // ── Login ──
  Future<void> login(String email, String password) async {
    try {
      _user = await _authService.signIn(email, password);
      if (_user != null) {
        // Fetch role from Firestore (or other backend)
        _role = await _authService.getUserRole(_user!.uid);
        // Save role locally
        await _saveRoleToPrefs(_role);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ── Logout ──
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _role = 'teacher';
    await _clearRoleFromPrefs();
    notifyListeners();
  }

  // ── Register new user ──
  Future<void> registerUser(String email, String password, String role) async {
    await _authService.registerUser(email, password, role);
    // After registration, you might want to auto-login or just navigate to login.
    // Optionally, you could also save the role if you log them in automatically.
  }
}