import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../services/firestore_service.dart';

class ClassProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<SchoolClass> _classes = [];
  bool _isLoading = false;
  String? _error;

  List<SchoolClass> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ClassProvider() {
    loadClasses();
  }

  void loadClasses() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getClassesStream().listen((classes) {
      _classes = classes;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addClass(SchoolClass schoolClass) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.addClass(schoolClass);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateClass(SchoolClass schoolClass) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.updateClass(schoolClass.id!, schoolClass);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteClass(String classId, String className) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.deleteClassSafe(classId, className);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}