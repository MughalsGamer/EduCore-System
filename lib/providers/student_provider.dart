//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../models/admission_model.dart';
// import '../services/Admission_firestore_sercice.dart';
//
// class StudentWithContext {
//   final AdmissionStudent student;
//   final String admissionId;
//   final AdmissionType admissionType;
//   final String familyId;
//   final String familyName;
//   final String fatherName;
//   final String fatherPhone;
//   final String? fatherCnic;
//   final String? fatherOccupation;
//   final String motherName;
//   final String? motherPhone;
//   final String? motherCnic;
//   final String? caste;
//   final String? address;
//   final DateTime admissionDate;
//   final String inquiryOrRegId;
//
//   const StudentWithContext({
//     required this.student,
//     required this.admissionId,
//     required this.admissionType,
//     required this.familyId,
//     required this.familyName,
//     required this.fatherName,
//     required this.fatherPhone,
//     this.fatherCnic,
//     this.fatherOccupation,
//     required this.motherName,
//     this.motherPhone,
//     this.motherCnic,
//     this.caste,
//     this.address,
//     required this.admissionDate,
//     required this.inquiryOrRegId,
//   });
// }
//
// class StudentProvider extends ChangeNotifier {
//   final AdmissionFirestoreService _service = AdmissionFirestoreService();
//
//   List<StudentWithContext> _students = [];
//   bool _isLoading = true;
//   String? _error;
//
//   // ── Filters ──
//   String _searchQuery = '';
//   String? _selectedFamilyId;   // null = all families
//   String? _selectedClassName;  // null = all classes
//
//   StreamSubscription<List<AdmissionModel>>? _subscription;
//
//   // ── Getters ──
//   bool    get isLoading       => _isLoading;
//   String? get error           => _error;
//   String  get searchQuery     => _searchQuery;
//   String? get selectedFamilyId   => _selectedFamilyId;
//   String? get selectedClassName  => _selectedClassName;
//
//   // ── Unique family list for filter dropdown ──
//   List<MapEntry<String, String>> get allFamilies {
//     final seen = <String>{};
//     final result = <MapEntry<String, String>>[];
//     for (final s in _students) {
//       if (s.familyId.isNotEmpty && seen.add(s.familyId)) {
//         result.add(MapEntry(s.familyId, s.familyName));
//       }
//     }
//     result.sort((a, b) => a.value.compareTo(b.value));
//     return result;
//   }
//
//   // ── Unique class list for filter dropdown ──
//   List<String> get allClassNames {
//     final names = _students
//         .map((s) => s.student.className ?? '')
//         .where((c) => c.isNotEmpty)
//         .toSet()
//         .toList();
//     names.sort();
//     return names;
//   }
//
//   // ── Filtered students ──
//   List<StudentWithContext> get students {
//     var list = _students;
//
//     // Family filter
//     if (_selectedFamilyId != null) {
//       list = list.where((s) => s.familyId == _selectedFamilyId).toList();
//     }
//
//     // Class filter
//     if (_selectedClassName != null) {
//       list = list
//           .where((s) => s.student.className == _selectedClassName)
//           .toList();
//     }
//
//     // Search
//     if (_searchQuery.trim().isNotEmpty) {
//       final q = _searchQuery.toLowerCase();
//       list = list.where((s) {
//         return s.student.name.toLowerCase().contains(q) ||
//             s.student.studentId.toLowerCase().contains(q) ||
//             s.fatherName.toLowerCase().contains(q) ||
//             (s.student.className?.toLowerCase().contains(q) ?? false) ||
//             s.familyId.toLowerCase().contains(q) ||
//             s.familyName.toLowerCase().contains(q);
//       }).toList();
//     }
//
//     return list;
//   }
//
//   StudentProvider() {
//     _startListening();
//   }
//
//   void _startListening() {
//     _subscription?.cancel();
//     _isLoading = true;
//     _error = null;
//     if (hasListeners) notifyListeners();
//
//     _subscription = _service
//         .getAdmissionsStream(filterType: AdmissionType.regular)
//         .listen(
//           (admissions) {
//         final flat = <StudentWithContext>[];
//         for (final a in admissions) {
//           for (final s in a.students) {
//             flat.add(StudentWithContext(
//               student: s,
//               admissionId: a.id ?? '',
//               admissionType: a.type,
//               familyId: a.familyId,
//               familyName: a.familyName,
//               fatherName: a.fatherName,
//               fatherPhone: a.fatherPhone,
//               fatherCnic: a.fatherCnic,
//               fatherOccupation: a.fatherOccupation,
//               motherName: a.motherName,
//               motherPhone: a.motherPhone,
//               motherCnic: a.motherCnic,
//               caste: a.caste,
//               address: a.address,
//               admissionDate: a.admissionDate,
//               inquiryOrRegId: a.inquiryOrRegId,
//             ));
//           }
//         }
//         flat.sort((a, b) => b.admissionDate.compareTo(a.admissionDate));
//         _students = flat;
//         _isLoading = false;
//         notifyListeners();
//       },
//       onError: (e) {
//         _error = e.toString();
//         _isLoading = false;
//         notifyListeners();
//       },
//     );
//   }
//
//   void setSearch(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }
//
//   void setFamilyFilter(String? familyId) {
//     _selectedFamilyId = familyId;
//     notifyListeners();
//   }
//
//   void setClassFilter(String? className) {
//     _selectedClassName = className;
//     notifyListeners();
//   }
//
//   void clearAllFilters() {
//     _searchQuery = '';
//     _selectedFamilyId = null;
//     _selectedClassName = null;
//     notifyListeners();
//   }
//
//   bool get hasActiveFilters =>
//       _searchQuery.isNotEmpty ||
//           _selectedFamilyId != null ||
//           _selectedClassName != null;
//
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }
// }

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
  bool _isLoading = true;
  String? _error;

  // ── Filters ──
  String  _searchQuery        = '';
  String? _selectedFamilyId;
  String? _selectedClassName;
  String? _selectedSectionName; // ← NEW

  StreamSubscription<List<AdmissionModel>>? _subscription;

  // ── Getters ──
  bool    get isLoading            => _isLoading;
  String? get error                => _error;
  String  get searchQuery          => _searchQuery;
  String? get selectedFamilyId     => _selectedFamilyId;
  String? get selectedClassName    => _selectedClassName;
  String? get selectedSectionName  => _selectedSectionName; // ← NEW

  // ── Unique family list ──
  List<MapEntry<String, String>> get allFamilies {
    final seen   = <String>{};
    final result = <MapEntry<String, String>>[];
    for (final s in _students) {
      if (s.familyId.isNotEmpty && seen.add(s.familyId)) {
        result.add(MapEntry(s.familyId, s.familyName));
      }
    }
    result.sort((a, b) => a.value.compareTo(b.value));
    return result;
  }

  // ── Unique class list ──
  List<String> get allClassNames {
    final names = _students
        .map((s) => s.student.className ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    names.sort();
    return names;
  }

  // ── Sections for a specific class ── (NEW)
  // Returns only sections that actually exist for that class.
  // Empty list means the class has no sections → hide the section filter row.
  List<String> sectionsForClass(String className) {
    final secs = _students
        .where((s) => s.student.className == className)
        .map((s) => s.student.sectionName ?? '')
        .where((sec) => sec.isNotEmpty)
        .toSet()
        .toList();
    secs.sort();
    return secs;
  }

  // ── Filtered students ──
  List<StudentWithContext> get students {
    var list = _students;

    // Family filter
    if (_selectedFamilyId != null) {
      list = list.where((s) => s.familyId == _selectedFamilyId).toList();
    }

    // Class filter
    if (_selectedClassName != null) {
      list = list
          .where((s) => s.student.className == _selectedClassName)
          .toList();
    }

    // Section filter (NEW)
    if (_selectedSectionName != null) {
      list = list
          .where((s) => s.student.sectionName == _selectedSectionName)
          .toList();
    }

    // Search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) {
        return s.student.name.toLowerCase().contains(q) ||
            s.student.studentId.toLowerCase().contains(q) ||
            s.fatherName.toLowerCase().contains(q) ||
            (s.student.className?.toLowerCase().contains(q) ?? false) ||
            (s.student.sectionName?.toLowerCase().contains(q) ?? false) ||
            s.familyId.toLowerCase().contains(q) ||
            s.familyName.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  StudentProvider() {
    _startListening();
  }

  void _startListening() {
    _subscription?.cancel();
    _isLoading = true;
    _error = null;
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

  // ── Filter setters ──

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFamilyFilter(String? familyId) {
    _selectedFamilyId = familyId;
    notifyListeners();
  }

  /// Class change always resets section so stale section data never leaks.
  void setClassFilter(String? className) {
    _selectedClassName  = className;
    _selectedSectionName = null; // ← reset section when class changes
    notifyListeners();
  }

  /// NEW: set section filter independently.
  void setSectionFilter(String? sectionName) {
    _selectedSectionName = sectionName;
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery         = '';
    _selectedFamilyId    = null;
    _selectedClassName   = null;
    _selectedSectionName = null; // ← NEW
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
          _selectedFamilyId    != null ||
          _selectedClassName   != null ||
          _selectedSectionName != null; // ← NEW

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