import 'dart:async';
import 'package:flutter/material.dart';
import '../models/admission_model.dart';
import '../services/Admission_firestore_sercice.dart';

class StudentWithContext {
  final AdmissionStudent student;
  final String admissionId;
  final AdmissionType admissionType;
  final String familyId;
  final String familyName;
  final String fatherName;
  final String fatherPhone;
  final String? fatherCnic;
  final String? fatherOccupation;
  final String motherName;
  final String? motherPhone;
  final String? motherCnic;
  final String? caste;
  final String? address;
  final DateTime admissionDate;
  final String inquiryOrRegId;

  const StudentWithContext({
    required this.student,
    required this.admissionId,
    required this.admissionType,
    required this.familyId,
    required this.familyName,
    required this.fatherName,
    required this.fatherPhone,
    this.fatherCnic,
    this.fatherOccupation,
    required this.motherName,
    this.motherPhone,
    this.motherCnic,
    this.caste,
    this.address,
    required this.admissionDate,
    required this.inquiryOrRegId,
  });
}

class StudentProvider extends ChangeNotifier {
  final AdmissionFirestoreService _service = AdmissionFirestoreService();

  List<StudentWithContext> _students = [];
  // ✅ explicitly typed + initialized — web DDC ke liye zaroori
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  StreamSubscription<List<AdmissionModel>>? _subscription;

  bool   get isLoading    => _isLoading;
  String? get error       => _error;
  String  get searchQuery => _searchQuery;

  List<StudentWithContext> get students {
    if (_searchQuery.trim().isEmpty) return List.unmodifiable(_students);
    final q = _searchQuery.toLowerCase();
    return _students.where((s) {
      return s.student.name.toLowerCase().contains(q) ||
          s.student.studentId.toLowerCase().contains(q) ||
          s.fatherName.toLowerCase().contains(q) ||
          (s.student.className?.toLowerCase().contains(q) ?? false) ||
          s.familyId.toLowerCase().contains(q);
    }).toList();
  }

  StudentProvider() {
    _startListening();
  }

  void _startListening() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
    // notifyListeners() constructor mein nahi — widget abhi mount nahi hua
    if (hasListeners) notifyListeners();

    _subscription = _service
        .getAdmissionsStream(filterType: AdmissionType.regular)
        .listen(
          (admissions) {
        final flat = <StudentWithContext>[];
        for (final a in admissions) {
          for (final s in a.students) {
            flat.add(StudentWithContext(
              student: s,
              admissionId: a.id ?? '',
              admissionType: a.type,
              familyId: a.familyId,
              familyName: a.familyName,
              fatherName: a.fatherName,
              fatherPhone: a.fatherPhone,
              fatherCnic: a.fatherCnic,
              fatherOccupation: a.fatherOccupation,
              motherName: a.motherName,
              motherPhone: a.motherPhone,
              motherCnic: a.motherCnic,
              caste: a.caste,
              address: a.address,
              admissionDate: a.admissionDate,
              inquiryOrRegId: a.inquiryOrRegId,
            ));
          }
        }
        flat.sort((a, b) => b.admissionDate.compareTo(a.admissionDate));
        _students = flat;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}