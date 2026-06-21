import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../services/firestore_service.dart';

class ClassProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ClassModel> _classes = [];
  bool _loading = false;

  List<ClassModel> get classes => _classes;
  bool get loading => _loading;

  Future<void> fetchClasses() async {
    _loading = true;
    notifyListeners();
    _classes = await _firestoreService.getClasses();
    _loading = false;
    notifyListeners();
  }

  Future<void> addClass(ClassModel classModel) async {
    await _firestoreService.addClass(classModel);
    await fetchClasses();
  }
}