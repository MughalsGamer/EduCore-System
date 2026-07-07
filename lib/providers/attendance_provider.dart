// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/attendance_model.dart';
// import '../models/teacher.dart';
// import '../providers/teacher_provider.dart';
// import '../services/attendance_firestore_service.dart'; // Your existing provider
//
// class AttendanceProvider extends ChangeNotifier {
//   final StaffProvider _staffProvider;
//   final AttendanceFirestoreService _service = AttendanceFirestoreService();
//
//   List<AttendanceRecord> _records = [];
//   bool _loading = false;
//   String _selectedDate = DateTime.now().toIso8601String().split('T')[0];
//   String _filterType = 'all'; // 'all', 'teacher', 'staff'
//
//   List<AttendanceRecord> get records => _records;
//   bool get loading => _loading;
//   String get selectedDate => _selectedDate;
//   String get filterType => _filterType;
//
//   AttendanceProvider(this._staffProvider);
//
//   Future<void> loadData({String? typeFilter}) async {
//     _loading = true;
//     _filterType = typeFilter ?? _filterType;
//     notifyListeners();
//
//     // 1. Ensure StaffProvider has latest active data
//     await _staffProvider.fetchTeachers();
//     await _staffProvider.fetchStaffOnly();
//
//     // 2. Fetch existing attendance from Firestore
//     final existingRecords = await _service.getAttendanceForDate(_selectedDate);
//
//     // 3. Determine which staff to show based on filter
//     List<StaffMember> activeStaff = [];
//     if (_filterType == 'teacher') {
//       activeStaff = _staffProvider.teachers;
//     } else if (_filterType == 'staff') {
//       activeStaff = _staffProvider.staffOnly;
//     } else {
//       activeStaff = [..._staffProvider.teachers, ..._staffProvider.staffOnly];
//     }
//
//     // 4. Merge into local records (✅ FIXED HERE)
//     _records = activeStaff.map((staff) {
//       final matchingRecords = existingRecords.where((r) => r.staffId == staff.id).toList();
//       final existing = matchingRecords.isNotEmpty ? matchingRecords.first : null;
//
//       return AttendanceRecord(
//         id: existing?.id ?? '${staff.id}_${_selectedDate}',
//         staffId: staff.id!,
//         staffName: staff.name,
//         photoBase64: staff.imageBase64,
//         type: staff.type,
//         date: _selectedDate,
//         status: existing?.status ?? 'present',
//         remarks: existing?.remarks ?? '',
//       );
//     }).toList();
//
//     _loading = false;
//     notifyListeners();
//   }
//
//   // Change date and reload
//   void changeDate(DateTime newDate) {
//     _selectedDate = newDate.toIso8601String().split('T')[0];
//     loadData();
//   }
//
//   // Change filter and reload
//   void changeFilter(String newFilter) {
//     _filterType = newFilter;
//     loadData();
//   }
//
//   // Update single status
//   void updateStatus(String staffId, String status) {
//     final index = _records.indexWhere((r) => r.staffId == staffId);
//     if (index != -1) {
//       _records[index].status = status;
//       notifyListeners();
//     }
//   }
//
//   // Update single remark
//   void updateRemarks(String staffId, String remark) {
//     final index = _records.indexWhere((r) => r.staffId == staffId);
//     if (index != -1) {
//       _records[index].remarks = remark;
//       notifyListeners();
//     }
//   }
//
//   // Quick action: Mark all present/absent
//   void markAll(String status) {
//     for (final record in _records) {
//       record.status = status;
//     }
//     notifyListeners();
//   }
//
//   // Save to Firestore
//   Future<void> saveAttendance() async {
//     await _service.saveAttendance(_records);
//     // Optionally reload to ensure local data matches server state
//     await loadData();
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attendance_model.dart';
import '../models/teacher.dart';
import '../providers/teacher_provider.dart';
import '../services/attendance_firestore_service.dart'; // Your existing provider

class AttendanceProvider extends ChangeNotifier {
  final StaffProvider _staffProvider;
  final AttendanceFirestoreService _service = AttendanceFirestoreService();

  List<AttendanceRecord> _records = [];
  bool _loading = false;
  String _selectedDate = DateTime.now().toIso8601String().split('T')[0];
  String _filterType = 'all'; // 'all', 'teacher', 'staff'

  List<AttendanceRecord> get records => _records;
  bool get loading => _loading;
  String get selectedDate => _selectedDate;
  String get filterType => _filterType;

  AttendanceProvider(this._staffProvider);

  Future<void> loadData({String? typeFilter}) async {
    _loading = true;
    _filterType = typeFilter ?? _filterType;
    notifyListeners();

    // 1. Ensure StaffProvider has latest active data
    await _staffProvider.fetchTeachers();
    await _staffProvider.fetchStaffOnly();

    // 2. Fetch existing attendance from Firestore
    final existingRecords = await _service.getAttendanceForDate(_selectedDate);

    // 3. Determine which staff to show based on filter
    List<StaffMember> activeStaff = [];
    if (_filterType == 'teacher') {
      activeStaff = _staffProvider.teachers;
    } else if (_filterType == 'staff') {
      activeStaff = _staffProvider.staffOnly;
    } else {
      activeStaff = [..._staffProvider.teachers, ..._staffProvider.staffOnly];
    }

    // 4. Merge into local records (✅ FIXED HERE)
    _records = activeStaff.map((staff) {
      final matchingRecords =
      existingRecords.where((r) => r.staffId == staff.id).toList();
      final existing = matchingRecords.isNotEmpty ? matchingRecords.first : null;

      return AttendanceRecord(
        id: existing?.id ?? '${staff.id}_${_selectedDate}',
        staffId: staff.id!,
        staffName: staff.name,
        photoBase64: staff.imageBase64,
        type: staff.type,
        date: _selectedDate,
        status: existing?.status ?? 'present',
        remarks: existing?.remarks ?? '',
        designation: staff.designation,
        // ★ NEW – true means this staff already has an attendance record
        // saved in Firestore for the currently selected date.
        isSaved: existing != null,
      );
    }).toList();

    _loading = false;
    notifyListeners();
  }

  // Change date and reload
  void changeDate(DateTime newDate) {
    _selectedDate = newDate.toIso8601String().split('T')[0];
    loadData();
  }

  // Change filter and reload
  void changeFilter(String newFilter) {
    _filterType = newFilter;
    loadData();
  }

  // Update single status
  void updateStatus(String staffId, String status) {
    final index = _records.indexWhere((r) => r.staffId == staffId);
    if (index != -1) {
      _records[index].status = status;
      notifyListeners();
    }
  }

  // Update single remark
  void updateRemarks(String staffId, String remark) {
    final index = _records.indexWhere((r) => r.staffId == staffId);
    if (index != -1) {
      _records[index].remarks = remark;
      notifyListeners();
    }
  }

  // Quick action: Mark all present/absent
  void markAll(String status) {
    for (final record in _records) {
      record.status = status;
    }
    notifyListeners();
  }

  // Save to Firestore
  Future<void> saveAttendance() async {
    await _service.saveAttendance(_records);
    // Optionally reload to ensure local data matches server state
    await loadData();
  }
}