import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/firestore_service.dart';

class StudentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Student> _students = [];
  bool _loading = false;

  List<Student> get students => _students;
  bool get loading => _loading;

  Future<void> fetchStudents() async {
    _loading = true;
    notifyListeners();
    _students = await _firestoreService.getStudents();
    _loading = false;
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    await _firestoreService.addStudent(student);
    await fetchStudents();
  }

  Future<void> updateStudent(String id, Student student) async {
    await _firestoreService.updateStudent(id, student);
    await fetchStudents();
  }

  Future<void> deleteStudent(String id) async {
    await _firestoreService.deleteStudent(id);
    await fetchStudents();
  }
}