
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

  // ★ CHANGED — active lists now exclude deactivated members
  List<StaffMember> get teachers =>
      _teachers.where((s) => s.isActive).toList();
  List<StaffMember> get staffOnly =>
      _staffOnly.where((s) => s.isActive).toList();

  // ★ NEW — deactivated members from both teacher & staff lists combined
  List<StaffMember> get deactivatedMembers => [
    ..._teachers.where((s) => !s.isActive),
    ..._staffOnly.where((s) => !s.isActive),
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

  // ★ NEW — deactivate a teacher or staff member.
  // Finds the existing record (from whichever list has it), flips isActive
  // to false, and saves via the same updateStaff path the rest of the app
  // already uses, then refreshes teachers/staffOnly/allStaff so every
  // screen watching this provider updates automatically.
  Future<void> deactivateStaff(String id) async {
    final member = _findMember(id);
    if (member == null) return;

    member.isActive = false;
    await _service.updateStaff(id, member);

    await fetchTeachers();
    await fetchStaffOnly();
    await fetchAll();
  }

  // ★ NEW — reactivate a teacher or staff member.
  Future<void> reactivateStaff(String id) async {
    final member = _findMember(id);
    if (member == null) return;

    member.isActive = true;
    await _service.updateStaff(id, member);

    await fetchTeachers();
    await fetchStaffOnly();
    await fetchAll();
  }

  // ★ NEW — helper to locate a member by id across whichever cached list
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