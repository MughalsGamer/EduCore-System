

import 'package:flutter/foundation.dart';
import '../models/teacher.dart';
import '../services/firestore_service.dart';

class StaffProvider extends ChangeNotifier {
  final StaffFirestoreService _service = StaffFirestoreService();

  List<StaffMember> _allStaff = [];
  List<StaffMember> _teachers = [];
  List<StaffMember> _schoolStaff = [];
  List<StaffMember> _academyStaff = [];

  bool _loading = false;

  // ─── Combined list ────────────────────────────────────────────
  List<StaffMember> get allStaff => _allStaff;

  // ─── Active (non‑terminated) lists ──────────────────────────
  List<StaffMember> get teachers =>
      _teachers.where((s) => s.isActive && !s.isTerminated).toList();

  List<StaffMember> get schoolStaff =>
      _schoolStaff.where((s) => s.isActive && !s.isTerminated).toList();

  List<StaffMember> get academyStaff =>
      _academyStaff.where((s) => s.isActive && !s.isTerminated).toList();

  // ─── Backward‑compatible alias for old callers ──────────────
  List<StaffMember> get staffOnly => schoolStaff;

  // ─── Terminated members from all three lists ────────────────
  List<StaffMember> get deactivatedMembers => [
    ..._teachers.where((s) => s.isTerminated),
    ..._schoolStaff.where((s) => s.isTerminated),
    ..._academyStaff.where((s) => s.isTerminated),
  ];

  List<StaffMember> get terminatedMembers => deactivatedMembers;

  bool get loading => _loading;

  // ─── Load all staff (combines all three categories) ──────────
  Future<void> fetchAllStaff() async {
    await fetchAllLists();
  }

  // ─── Individual category fetches ─────────────────────────────
  Future<void> fetchTeachers() async {
    _loading = true;
    notifyListeners();
    _teachers = await _service.getTeachers();
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchSchoolStaff() async {
    _loading = true;
    notifyListeners();
    _schoolStaff = await _service.getSchoolStaff();
    _loading = false;
    notifyListeners();
  }

  // Backward‑compatible alias
  Future<void> fetchStaffOnly() => fetchSchoolStaff();

  Future<void> fetchAcademyStaff() async {
    _loading = true;
    notifyListeners();
    _academyStaff = await _service.getAcademyStaff();
    _loading = false;
    notifyListeners();
  }

  // ─── Fetch all three lists and combine them ──────────────────
  Future<void> fetchAllLists() async {
    _loading = true;
    notifyListeners();
    _teachers = await _service.getTeachers();
    _schoolStaff = await _service.getSchoolStaff();
    _academyStaff = await _service.getAcademyStaff();
    _allStaff = [..._teachers, ..._schoolStaff, ..._academyStaff];
    _loading = false;
    notifyListeners();
  }

  // ─── Legacy fetchAll (uses the service’s getAllStaff – keep if needed) ──
  Future<void> fetchAll() async {
    _loading = true;
    notifyListeners();
    _allStaff = await _service.getAllStaff();
    _loading = false;
    notifyListeners();
  }

  // ─── CRUD operations ──────────────────────────────────────────
  Future<void> addStaff(StaffMember staff) async {
    if (staff.statusHistory.isEmpty && staff.joiningDate != null) {
      staff.statusHistory.add(
        StatusEvent(type: 'joined', date: staff.joiningDate!),
      );
    }
    await _service.addStaff(staff);
    await fetchAllStaff();
  }

  Future<void> updateStaff(String id, StaffMember staff) async {
    await _service.updateStaff(id, staff);
    await fetchAllStaff();
  }

  Future<void> deleteStaff(String id) async {
    await _service.deleteStaff(id);
    await fetchAllStaff();
  }

  // ─── Termination / Rejoining ──────────────────────────────────
  Future<void> terminateStaff(
      String id, {
        required String terminationDate,
        String? note,
      }) async {
    final member = _findMember(id);
    if (member == null) return;

    // Backfill joining event if missing
    if (member.statusHistory.isEmpty) {
      member.statusHistory.add(
        StatusEvent(
          type: 'joined',
          date: (member.joiningDate != null && member.joiningDate!.isNotEmpty)
              ? member.joiningDate!
              : terminationDate,
        ),
      );
    }

    member.isActive = false;
    member.isTerminated = true;
    member.terminationDate = terminationDate;
    member.terminationNote = note;

    member.statusHistory.removeWhere(
            (e) => e.type == 'terminated' && e.date == terminationDate);
    member.statusHistory.add(
      StatusEvent(type: 'terminated', date: terminationDate, note: note),
    );

    await _service.updateStaff(id, member);
    await fetchAllStaff();
  }

  Future<void> rejoinStaff(
      String id, {
        required String rejoiningDate,
        String? note,
      }) async {
    final member = _findMember(id);
    if (member == null) return;

    if (member.statusHistory.isEmpty) {
      member.statusHistory.add(
        StatusEvent(
          type: 'joined',
          date: (member.joiningDate != null && member.joiningDate!.isNotEmpty)
              ? member.joiningDate!
              : rejoiningDate,
        ),
      );
    }

    member.isActive = true;
    member.isTerminated = false;
    member.terminationDate = null;
    member.terminationNote = null;

    member.statusHistory.removeWhere(
            (e) => e.type == 'rejoined' && e.date == rejoiningDate);
    member.statusHistory.add(
      StatusEvent(type: 'rejoined', date: rejoiningDate, note: note),
    );

    await _service.updateStaff(id, member);
    await fetchAllStaff();
  }

  // ─── Backward‑compatible aliases ──────────────────────────────
  Future<void> deactivateStaff(String id) =>
      terminateStaff(id, terminationDate: DateTime.now().toIso8601String().split('T').first);

  Future<void> reactivateStaff(String id) =>
      rejoinStaff(id, rejoiningDate: DateTime.now().toIso8601String().split('T').first);

  Future<void> reinstateStaff(String id) => reactivateStaff(id);

  // ─── Helpers ───────────────────────────────────────────────────
  StaffMember? getMemberById(String id) => _findMember(id);

  StaffMember? _findMember(String id) {
    for (final list in [_teachers, _schoolStaff, _academyStaff, _allStaff]) {
      for (final m in list) {
        if (m.id == id) return m;
      }
    }
    return null;
  }

  void clear() {
    _allStaff = [];
    _teachers = [];
    _schoolStaff = [];
    _academyStaff = [];
    notifyListeners();
  }
}