import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../services/firestore_service.dart';

class TeacherProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Teacher> _teachers = [];
  bool _loading = false;

  List<Teacher> get teachers => _teachers;
  bool get loading => _loading;

  Future<void> fetchTeachers() async {
    _loading = true;
    notifyListeners();
    _teachers = await _firestoreService.getTeachers();
    _loading = false;
    notifyListeners();
  }

  Future<void> addTeacher(Teacher teacher) async {
    await _firestoreService.addTeacher(teacher);
    await fetchTeachers();
  }

  Future<void> updateTeacher(String id, Teacher teacher) async {
    await _firestoreService.updateTeacher(id, teacher);
    await fetchTeachers();
  }

  Future<void> deleteTeacher(String id) async {
    await _firestoreService.deleteTeacher(id);
    await fetchTeachers();
  }
}