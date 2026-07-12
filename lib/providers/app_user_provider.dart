import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_user_Model.dart';
import '../services/app_user_firestore_service.dart';

class AppUserProvider extends ChangeNotifier {
  final AppUserFirestoreService _service = AppUserFirestoreService();

  List<AppUser> _users = [];
  List<AppUser> get users => _users;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  StreamSubscription<List<AppUser>>? _sub;

  void listenToUsers() {
    _loading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _service.watchUsers().listen((list) {
      _users = list;
      _loading = false;
      _error = null;
      notifyListeners();
    }, onError: (_) {
      _error = 'Failed to load users.';
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> loadUsersOnce() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _service.fetchUsers();
    } catch (e) {
      _error = 'Failed to load users.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(AppUser user) async {
    try {
      await _service.updateUser(user);
      final index = _users.indexWhere((u) => u.uid == user.uid);
      if (index != -1) {
        _users[index] = user;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update user.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> setActive(String uid, bool isActive) async {
    try {
      await _service.setActive(uid, isActive);
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isActive: isActive);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update status.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}