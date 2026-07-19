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
//   // Active lists exclude deactivated (terminated) members
//   List<StaffMember> get teachers =>
//       _teachers.where((s) => s.isActive && !s.isTerminated).toList();
//   List<StaffMember> get staffOnly =>
//       _staffOnly.where((s) => s.isActive && !s.isTerminated).toList();
//
//   // Terminated members from both teacher & staff lists combined.
//   // (isActive=false is set together with isTerminated=true by terminateStaff,
//   // so this single flag drives the "Terminated" screen.)
//   List<StaffMember> get deactivatedMembers => [
//     ..._teachers.where((s) => s.isTerminated),
//     ..._staffOnly.where((s) => s.isTerminated),
//   ];
//
//   // Alias with clearer naming for new code — same data as deactivatedMembers.
//   List<StaffMember> get terminatedMembers => deactivatedMembers;
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
//   // Fetches everything the Terminated/active screens need in one call.
//   // Use this in initState() of any screen that reads teachers / staffOnly /
//   // deactivatedMembers, so the lists are never empty on first render.
//   Future<void> fetchAllLists() async {
//     _loading = true;
//     notifyListeners();
//     _teachers = await _service.getTeachers();
//     _staffOnly = await _service.getStaffOnly();
//     _allStaff = [..._teachers, ..._staffOnly];
//     _loading = false;
//     notifyListeners();
//   }
//
//   Future<void> addStaff(StaffMember staff) async {
//     // Log the initial joining event in history if one isn't already present.
//     if (staff.statusHistory.isEmpty && staff.joiningDate != null) {
//       staff.statusHistory.add(
//         StatusEvent(type: 'joined', date: staff.joiningDate!),
//       );
//     }
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
//   // ── Terminate a teacher or staff member (was "deactivate"). ──
//   // Sets both isActive=false and isTerminated=true, records the termination
//   // date + note, and appends a 'terminated' entry to statusHistory.
//   Future<void> terminateStaff(
//       String id, {
//         required String terminationDate,
//         String? note,
//       }) async {
//     final member = _findMember(id);
//     if (member == null) return;
//
//     // Backfill a missing 'joined' event for older records that were created
//     // before the history log existed — so the timeline always starts at
//     // Joined instead of jumping straight to Terminated/Rejoined.
//     if (member.statusHistory.isEmpty) {
//       member.statusHistory.add(
//         StatusEvent(
//           type: 'joined',
//           date: (member.joiningDate != null && member.joiningDate!.isNotEmpty)
//               ? member.joiningDate!
//               : terminationDate,
//         ),
//       );
//     }
//
//     member.isActive = false;
//     member.isTerminated = true;
//     member.terminationDate = terminationDate;
//     member.terminationNote = note;
//     member.statusHistory.add(
//       StatusEvent(type: 'terminated', date: terminationDate, note: note),
//     );
//
//     await _service.updateStaff(id, member);
//
//     await fetchTeachers();
//     await fetchStaffOnly();
//     await fetchAll();
//   }
//
//   // ── Rejoin (undo termination) a teacher or staff member (was "reactivate"). ──
//   // Requires a rejoining date + optional note, which are recorded in
//   // statusHistory so full history (join → terminate → rejoin → ...) is kept.
//   Future<void> rejoinStaff(
//       String id, {
//         required String rejoiningDate,
//         String? note,
//       }) async {
//     final member = _findMember(id);
//     if (member == null) return;
//
//     // Defensive fallback: if for any reason this member's history is empty
//     // (e.g. never went through terminateStaff), backfill 'joined' first so
//     // the timeline never starts at Rejoined.
//     if (member.statusHistory.isEmpty) {
//       member.statusHistory.add(
//         StatusEvent(
//           type: 'joined',
//           date: (member.joiningDate != null && member.joiningDate!.isNotEmpty)
//               ? member.joiningDate!
//               : rejoiningDate,
//         ),
//       );
//     }
//
//     member.isActive = true;
//     member.isTerminated = false;
//     member.terminationDate = null;
//     member.terminationNote = null;
//     member.statusHistory.add(
//       StatusEvent(type: 'rejoined', date: rejoiningDate, note: note),
//     );
//
//     await _service.updateStaff(id, member);
//
//     await fetchTeachers();
//     await fetchStaffOnly();
//     await fetchAll();
//   }
//
//   // Backward-compatible aliases (old call sites keep working).
//   Future<void> deactivateStaff(String id) =>
//       terminateStaff(id, terminationDate: DateTime.now().toIso8601String().split('T').first);
//
//   Future<void> reactivateStaff(String id) =>
//       rejoinStaff(id, rejoiningDate: DateTime.now().toIso8601String().split('T').first);
//
//   Future<void> reinstateStaff(String id) => reactivateStaff(id);
//
//   // quick lookup for UI (e.g. to know current termination state
//   // without waiting for a fresh fetch).
//   StaffMember? getMemberById(String id) => _findMember(id);
//
//   // helper to locate a member by id across whichever cached list
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

  // Active lists exclude deactivated (terminated) members
  List<StaffMember> get teachers =>
      _teachers.where((s) => s.isActive && !s.isTerminated).toList();
  List<StaffMember> get staffOnly =>
      _staffOnly.where((s) => s.isActive && !s.isTerminated).toList();

  // Terminated members from both teacher & staff lists combined.
  List<StaffMember> get deactivatedMembers => [
    ..._teachers.where((s) => s.isTerminated),
    ..._staffOnly.where((s) => s.isTerminated),
  ];

  List<StaffMember> get terminatedMembers => deactivatedMembers;

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

  Future<void> fetchAllLists() async {
    _loading = true;
    notifyListeners();
    _teachers = await _service.getTeachers();
    _staffOnly = await _service.getStaffOnly();
    _allStaff = [..._teachers, ..._staffOnly];
    _loading = false;
    notifyListeners();
  }

  Future<void> addStaff(StaffMember staff) async {
    // Log the initial joining event in history if one isn't already present.
    if (staff.statusHistory.isEmpty && staff.joiningDate != null) {
      staff.statusHistory.add(
        StatusEvent(type: 'joined', date: staff.joiningDate!),
      );
    }
    await _service.addStaff(staff);
    await fetchAll();
  }

  Future<void> updateStaff(String id, StaffMember staff) async {
    await _service.updateStaff(id, staff);
    await fetchAll();
  }

  Future<void> deleteStaff(String id) async {
    await _service.deleteStaff(id);
    await fetchTeachers();
    await fetchStaffOnly();
    await fetchAll();
  }

  // ── Terminate a teacher or staff member ──
  // Sets both isActive=false and isTerminated=true, records the termination
  // date + note, and appends a 'terminated' entry to statusHistory.
  Future<void> terminateStaff(
      String id, {
        required String terminationDate,
        String? note,
      }) async {
    final member = _findMember(id);
    if (member == null) return;

    // ★ FIX: Backfill missing 'joined' event if history is empty
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

    // ★ FIX: Always add termination event to history
    // Remove any existing 'terminated' event with same date to avoid duplicates
    member.statusHistory.removeWhere((e) =>
    e.type == 'terminated' && e.date == terminationDate
    );
    member.statusHistory.add(
      StatusEvent(type: 'terminated', date: terminationDate, note: note),
    );

    await _service.updateStaff(id, member);

    await fetchTeachers();
    await fetchStaffOnly();
    await fetchAll();
  }

  // ── Rejoin (undo termination) a teacher or staff member ──
  // Requires a rejoining date + optional note, which are recorded in
  // statusHistory so full history (join → terminate → rejoin → ...) is kept.
  Future<void> rejoinStaff(
      String id, {
        required String rejoiningDate,
        String? note,
      }) async {
    final member = _findMember(id);
    if (member == null) return;

    // ★ FIX: Backfill 'joined' if history is empty
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

    // ★ FIX: Always add rejoining event to history
    // Remove any existing 'rejoined' event with same date to avoid duplicates
    member.statusHistory.removeWhere((e) =>
    e.type == 'rejoined' && e.date == rejoiningDate
    );
    member.statusHistory.add(
      StatusEvent(type: 'rejoined', date: rejoiningDate, note: note),
    );

    await _service.updateStaff(id, member);

    await fetchTeachers();
    await fetchStaffOnly();
    await fetchAll();
  }

  // Backward-compatible aliases
  Future<void> deactivateStaff(String id) =>
      terminateStaff(id, terminationDate: DateTime.now().toIso8601String().split('T').first);

  Future<void> reactivateStaff(String id) =>
      rejoinStaff(id, rejoiningDate: DateTime.now().toIso8601String().split('T').first);

  Future<void> reinstateStaff(String id) => reactivateStaff(id);

  StaffMember? getMemberById(String id) => _findMember(id);

  StaffMember? _findMember(String id) {
    for (final list in [_teachers, _staffOnly, _allStaff]) {
      for (final m in list) {
        if (m.id == id) return m;
      }
    }
    return null;
  }

  void clear() {
    _allStaff = [];
    _teachers = [];
    _staffOnly = [];
    notifyListeners();
  }
}