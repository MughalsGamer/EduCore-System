import 'dart:async';
import 'package:flutter/material.dart';
import '../models/school_setting_model.dart';
import '../services/school_setting_firestore.dart';


class SchoolSettingsProvider extends ChangeNotifier {
  final SchoolSettingsFirestoreService _service =
  SchoolSettingsFirestoreService();

  SchoolSettings _settings = const SchoolSettings();
  SchoolSettings get settings => _settings;

  bool _loading = false;
  bool get loading => _loading;

  bool _saving = false;
  bool get saving => _saving;

  String? _error;
  String? get error => _error;

  StreamSubscription<SchoolSettings?>? _sub;

  Future<void> loadSettings() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _service.fetchSettings();
      if (result != null) _settings = result;
    } catch (e) {
      _error = 'Failed to load school settings.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Optional: keep settings live-synced across the app.
  void listenToSettings() {
    _sub?.cancel();
    _sub = _service.watchSettings().listen((result) {
      if (result != null) {
        _settings = result;
        notifyListeners();
      }
    });
  }

  Future<bool> saveSettings(SchoolSettings updated) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _service.saveSettings(updated);
      _settings = updated;
      _saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save school settings.';
      _saving = false;
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