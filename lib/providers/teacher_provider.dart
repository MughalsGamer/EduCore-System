//
// import 'package:flutter/foundation.dart';
//
// import '../models/teacher.dart';
// import '../services/firestore_service.dart';
//
//
// class StaffProvider extends ChangeNotifier {
//   final StaffFirestoreService _service = StaffFirestoreService();
//   List<StaffMember> _allStaff = [];
//   List<StaffMember> _teachers = [];
//   List<StaffMember> _staffOnly = [];
//   bool _loading = false;
//
//   List<StaffMember> get allStaff => _allStaff;
//
//   // ★ CHANGED — active lists now exclude deactivated members
//   List<StaffMember> get teachers =>
//       _teachers.where((s) => s.isActive).toList();
//   List<StaffMember> get staffOnly =>
//       _staffOnly.where((s) => s.isActive).toList();
//
//   // ★ NEW — deactivated members from both teacher & staff lists combined
//   List<StaffMember> get deactivatedMembers => [
//     ..._teachers.where((s) => !s.isActive),
//     ..._staffOnly.where((s) => !s.isActive),
//   ];
//
//   bool get loading => _loading;
//
//   Future<void> fetchAll() async {
//     _loading = true;
//     notifyListeners();
//     _allStaff = await _service.getAllStaff();
//     _loading = false;
//     notifyListeners();
//   }
//
//   Future<void> fetchTeachers() async {
//     _loading = true;
//     notifyListeners();
//     _teachers = await _service.getTeachers();
//     _loading = false;
//     notifyListeners();
//   }
//
//   Future<void> fetchStaffOnly() async {
//     _loading = true;
//     notifyListeners();
//     _staffOnly = await _service.getStaffOnly();
//     _loading = false;
//     notifyListeners();
//   }
//
//   Future<void> addStaff(StaffMember staff) async {
//     await _service.addStaff(staff);
//     await fetchAll(); // refresh main list
//   }
//
//   Future<void> updateStaff(String id, StaffMember staff) async {
//     await _service.updateStaff(id, staff);
//     await fetchAll();
//   }
//
//   Future<void> deleteStaff(String id) async {
//     await _service.deleteStaff(id);
//     await fetchTeachers();       // ← this is what the teacher list screen reads
//     await fetchStaffOnly();      // ← this is what the staff list screen reads
//     await fetchAll();
//   }
//
//   // ★ NEW — deactivate a teacher or staff member.
//   // Finds the existing record (from whichever list has it), flips isActive
//   // to false, and saves via the same updateStaff path the rest of the app
//   // already uses, then refreshes teachers/staffOnly/allStaff so every
//   // screen watching this provider updates automatically.
//   Future<void> deactivateStaff(String id) async {
//     final member = _findMember(id);
//     if (member == null) return;
//
//     member.isActive = false;
//     await _service.updateStaff(id, member);
//
//     await fetchTeachers();
//     await fetchStaffOnly();
//     await fetchAll();
//   }
//
//   // ★ NEW — reactivate a teacher or staff member.
//   Future<void> reactivateStaff(String id) async {
//     final member = _findMember(id);
//     if (member == null) return;
//
//     member.isActive = true;
//     await _service.updateStaff(id, member);
//
//     await fetchTeachers();
//     await fetchStaffOnly();
//     await fetchAll();
//   }
//
//   // ★ NEW — helper to locate a member by id across whichever cached list
//   // currently holds it (teachers, staffOnly, or allStaff).
//   StaffMember? _findMember(String id) {
//     for (final list in [_teachers, _staffOnly, _allStaff]) {
//       for (final m in list) {
//         if (m.id == id) return m;
//       }
//     }
//     return null;
//   }
//
//   // Optionally, clear and reload specific lists
//   void clear() {
//     _allStaff = [];
//     _teachers = [];
//     _staffOnly = [];
//     notifyListeners();
//   }
// }

import 'package:flutter/foundation.dart';

import '../models/teacher.dart';
import '../services/firestore_service.dart';


class StaffProvider extends ChangeNotifier {
  final StaffFirestoreService _service = StaffFirestoreService();
  List<StaffMember> _allStaff = [];
  List<StaffMember> _teachers = [];
  List<StaffMember> _staffOnly = [];
  bool _loading = false;

  List<StaffMember> get allStaff => _allStaff;

  // Active lists now exclude deactivated AND terminated members
  List<StaffMember> get teachers =>
      _teachers.where((s) => s.isActive && !s.isTerminated).toList();
  List<StaffMember> get staffOnly =>
      _staffOnly.where((s) => s.isActive && !s.isTerminated).toList();

  // Deactivated members from both teacher & staff lists combined
  List<StaffMember> get deactivatedMembers => [
    ..._teachers.where((s) => !s.isActive && !s.isTerminated),
    ..._staffOnly.where((s) => !s.isActive && !s.isTerminated),
  ];

  // ★ NEW — terminated members from both teacher & staff lists combined
  // (Used by the future "Terminated Employees" screen.)
  List<StaffMember> get terminatedMembers => [
    ..._teachers.where((s) => s.isTerminated),
    ..._staffOnly.where((s) => s.isTerminated),
  ];

  bool get loading => _loading;

  Future<void> fetchAll() async {
    _loading = true;
    notifyListeners();
    _allStaff = await _service.getAllStaff();
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchTeachers() async {
    _loading = true;
    notifyListeners();
    _teachers = await _service.getTeachers();
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchStaffOnly() async {
    _loading = true;
    notifyListeners();
    _staffOnly = await _service.getStaffOnly();
    _loading = false;
    notifyListeners();
  }

  Future<void> addStaff(StaffMember staff) async {
    await _service.addStaff(staff);
    await fetchAll(); // refresh main list
  }

  Future<void> updateStaff(String id, StaffMember staff) async {
    await _service.updateStaff(id, staff);
    await fetchAll();
  }

  Future<void> deleteStaff(String id) async {
    await _service.deleteStaff(id);
    await fetchTeachers();       // ← this is what the teacher list screen reads
    await fetchStaffOnly();      // ← this is what the staff list screen reads
    await fetchAll();
  }

  // Deactivate a teacher or staff member.
  Future<void> deactivateStaff(String id) async {
    final member = _findMember(id);
    if (member == null) return;

    member.isActive = false;
    await _service.updateStaff(id, member);

    await fetchTeachers();
    await fetchStaffOnly();
    await fetchAll();
  }

  // Reactivate a teacher or staff member.
  Future<void> reactivateStaff(String id) async {
    final member = _findMember(id);
    if (member == null) return;

    member.isActive = true;
    await _service.updateStaff(id, member);

    await fetchTeachers();
    await fetchStaffOnly();
    await fetchAll();
  }

  // ★ NEW — Terminate a teacher or staff member (e.g. from Generate Salary
  // screen at the time of generating their final salary). This removes
  // them from the regular teachers/staffOnly lists (via the getters above)
  // so they no longer show up in day-to-day employee lists.
  Future<void> terminateStaff(
      String id, {
        String? terminationDate,
        String? note,
      }) async {
    final member = _findMember(id);
    if (member == null) return;

    member.isTerminated = true;
    member.terminationDate = terminationDate;
    member.terminationNote = note;
    await _service.updateStaff(id, member);

    await fetchTeachers();
    await fetchStaffOnly();
    await fetchAll();
  }

  // ★ NEW — Reinstate (undo termination) a teacher or staff member. This is
  // what happens automatically when a terminated salary record is deleted
  // from the Salary List, or manually from the future Terminated Employees
  // screen ("rejoining").
  Future<void> reinstateStaff(String id) async {
    final member = _findMember(id);
    if (member == null) return;

    member.isTerminated = false;
    member.terminationDate = null;
    member.terminationNote = null;
    await _service.updateStaff(id, member);

    await fetchTeachers();
    await fetchStaffOnly();
    await fetchAll();
  }

  // ★ NEW — quick lookup for UI (e.g. to know current termination state
  // without waiting for a fresh fetch).
  StaffMember? getMemberById(String id) => _findMember(id);

  // helper to locate a member by id across whichever cached list
  // currently holds it (teachers, staffOnly, or allStaff).
  StaffMember? _findMember(String id) {
    for (final list in [_teachers, _staffOnly, _allStaff]) {
      for (final m in list) {
        if (m.id == id) return m;
      }
    }
    return null;
  }

  // Optionally, clear and reload specific lists
  void clear() {
    _allStaff = [];
    _teachers = [];
    _staffOnly = [];
    notifyListeners();
  }
}