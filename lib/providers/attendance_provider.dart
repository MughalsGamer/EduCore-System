//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../models/attendance_model.dart';
// import '../models/teacher.dart';
// import '../providers/teacher_provider.dart';
// import '../services/attendance_firestore_service.dart';
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
//   // Separate state for the "Attendance History" screen
//   List<AttendanceRecord> _historyRecords = [];
//   bool _historyLoading = false;
//   String? _historyError;
//
//   List<AttendanceRecord> get historyRecords => _historyRecords;
//   bool get historyLoading => _historyLoading;
//   String? get historyError => _historyError;
//   bool _staffLoaded = false;
//
//   // Compute summary statistics for "By Person" report
//   Map<String, int> get monthSummary {
//     Map<String, int> counts = {
//       'total': _historyRecords.length,
//       'present': 0,
//       'absent': 0,
//       'leave': 0,
//       'late': 0,
//       'half_day': 0,
//       'holiday': 0,
//     };
//     for (final r in _historyRecords) {
//       if (counts.containsKey(r.status)) {
//         counts[r.status] = counts[r.status]! + 1;
//       }
//     }
//     return counts;
//   }
//
//   AttendanceProvider(this._staffProvider);
//
//   // ★ Small date helper: 'yyyy-MM-dd' with zero-padding.
//   String _fmt(DateTime d) =>
//       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
//
//   Future<void> loadData({String? typeFilter}) async {
//     _loading = true;
//     _filterType = typeFilter ?? _filterType;
//     notifyListeners();
//
//     await _staffProvider.fetchTeachers();
//     await _staffProvider.fetchStaffOnly();
//
//     final existingRecords = await _service.getAttendanceForDate(_selectedDate);
//
//     List<StaffMember> activeStaff = [];
//     if (_filterType == 'teacher') {
//       activeStaff = _staffProvider.teachers;
//     } else if (_filterType == 'staff') {
//       activeStaff = _staffProvider.staffOnly;
//     } else {
//       activeStaff = [..._staffProvider.teachers, ..._staffProvider.staffOnly];
//     }
//
//     // ★ Is the currently selected day a Sunday? If so, and no explicit
//     // record already exists for a staff member, default their status to
//     // 'holiday' instead of 'present'/'absent'.
//     final isSunday = DateTime.parse(_selectedDate).weekday == DateTime.sunday;
//
//     _records = activeStaff.map((staff) {
//       final matchingRecords =
//       existingRecords.where((r) => r.staffId == staff.id).toList();
//       final existing = matchingRecords.isNotEmpty ? matchingRecords.first : null;
//
//       return AttendanceRecord(
//         id: existing?.id ?? '${staff.id}_${_selectedDate}',
//         staffId: staff.id!,
//         staffName: staff.name,
//         photoBase64: staff.imageBase64,
//         type: staff.type,
//         date: _selectedDate,
//         status: existing?.status ?? (isSunday ? 'holiday' : 'present'),
//         remarks: existing?.remarks ?? '',
//         designation: staff.designation,
//         isSaved: existing != null,
//       );
//     }).toList();
//
//     _loading = false;
//     notifyListeners();
//   }
//
//   void changeDate(DateTime newDate) {
//     _selectedDate = newDate.toIso8601String().split('T')[0];
//     loadData();
//   }
//
//   void changeFilter(String newFilter) {
//     _filterType = newFilter;
//     loadData();
//   }
//
//   bool updateStatus(String staffId, String status, {bool isAdmin = false}) {
//     final index = _records.indexWhere((r) => r.staffId == staffId);
//     if (index == -1) return false;
//     if (_records[index].isSaved && !isAdmin) return false;
//     _records[index].status = status;
//     notifyListeners();
//     return true;
//   }
//
//   bool updateRemarks(String staffId, String remark, {bool isAdmin = false}) {
//     final index = _records.indexWhere((r) => r.staffId == staffId);
//     if (index == -1) return false;
//     if (_records[index].isSaved && !isAdmin) return false;
//     _records[index].remarks = remark;
//     notifyListeners();
//     return true;
//   }
//
//   int markAll(String status) {
//     int skipped = 0;
//     for (final record in _records) {
//       if (record.isSaved) {
//         skipped++;
//         continue;
//       }
//       record.status = status;
//     }
//     notifyListeners();
//     return skipped;
//   }
//
//   Future<void> saveAttendance() async {
//     await _service.saveAttendance(_records);
//     await loadData();
//   }
//
//   // ============================================================
//   // ATTENDANCE HISTORY
//   // ============================================================
//
//   // ★ FIXED: Removed improper type casting on results[0] / results[1]
//   // ★ FIXED: Sundays with no explicit Firestore record now default to
//   // 'holiday' instead of 'absent'.
//   Future<void> loadHistoryForDate(String date, {String typeFilter = 'all'}) async {
//     _historyLoading = true;
//     _historyError = null;
//     notifyListeners();
//
//     try {
//       // 1. Fetch staff & attendance in parallel properly
//       final attendanceFuture = _service.getAttendanceForDate(date);
//       final staffFetchFuture = Future.wait([
//         _staffProvider.fetchTeachers(),
//         _staffProvider.fetchStaffOnly(),
//       ]);
//
//       await staffFetchFuture; // Wait for staff fetch first
//       final existingRecords = await attendanceFuture; // Wait for attendance fetch
//
//       // 2. Access lists directly from provider (no type-casting errors here)
//       final teachers = _staffProvider.teachers;
//       final staffOnly = _staffProvider.staffOnly;
//
//       // 3. Build O(1) lookup map for existing records
//       final existingMap = <String, AttendanceRecord>{};
//       for (final rec in existingRecords) {
//         existingMap[rec.staffId] = rec;
//       }
//
//       // 4. Determine active staff list
//       List<StaffMember> activeStaff = [];
//       if (typeFilter == 'teacher') {
//         activeStaff = teachers;
//       } else if (typeFilter == 'staff') {
//         activeStaff = staffOnly;
//       } else {
//         activeStaff = [...teachers, ...staffOnly];
//       }
//
//       // 5. ★ Is this particular date a Sunday? If so, and there's no
//       // explicit saved record, default to 'holiday' rather than 'absent'.
//       bool isSunday = false;
//       try {
//         isSunday = DateTime.parse(date).weekday == DateTime.sunday;
//       } catch (_) {}
//
//       // 6. Map instantly using the lookup map
//       _historyRecords = activeStaff.map((staff) {
//         final existing = existingMap[staff.id];
//         return AttendanceRecord(
//           id: existing?.id ?? '${staff.id}_$date',
//           staffId: staff.id!,
//           staffName: staff.name,
//           photoBase64: staff.imageBase64,
//           type: staff.type,
//           date: date,
//           status: existing?.status ?? (isSunday ? 'holiday' : 'absent'),
//           remarks: existing?.remarks ?? '',
//           designation: staff.designation,
//           isSaved: existing != null,
//         );
//       }).toList();
//
//     } catch (e) {
//       _historyError = 'Failed to load attendance: $e';
//       _historyRecords = [];
//     } finally {
//       _historyLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // ★ FIXED / REWRITTEN:
//   // 1. Date range now stops at "today" when the requested month is the
//   //    current month, instead of always going to the end of the month —
//   //    e.g. selecting July 2026 on 16-Jul-2026 shows 1 Jul → 16 Jul only.
//   //    Past months still show the full month (1st → last day).
//   //    Future months yield an empty range (nothing to show yet).
//   // 2. Every day in that range is now included in the result, even if no
//   //    Firestore record exists for it — previously, days with no saved
//   //    attendance were silently skipped instead of showing as "absent".
//   // 3. Sundays with no explicit saved record default to 'holiday' instead
//   //    of 'absent'.
//   Future<void> loadHistoryForPerson({
//     required String staffId,
//     required int year,
//     required int month,
//   }) async {
//     _historyLoading = true;
//     _historyError = null;
//     notifyListeners();
//
//     try {
//       final now = DateTime.now();
//       final monthStart = DateTime(year, month, 1);
//       final monthEnd = DateTime(year, month + 1, 0); // last day of month
//
//       final isCurrentMonth = year == now.year && month == now.month;
//       final today = DateTime(now.year, now.month, now.day);
//
//       // If it's a future month entirely, there's nothing to show.
//       if (monthStart.isAfter(today)) {
//         _historyRecords = [];
//         _historyLoading = false;
//         notifyListeners();
//         return;
//       }
//
//       // Effective end date: today (if current month) else full month end.
//       final effectiveEnd = isCurrentMonth
//           ? (monthEnd.isBefore(today) ? monthEnd : today)
//           : monthEnd;
//
//       final startStr = _fmt(monthStart);
//       final endStr = _fmt(effectiveEnd);
//
//       final fetched = await _service.getAttendanceForStaffInRange(
//         staffId: staffId,
//         startDate: startStr,
//         endDate: endStr,
//       );
//
//       // Need staff meta (name/photo/type/designation) to fabricate
//       // placeholder records for days with no saved attendance.
//       final allStaff = [
//         ..._staffProvider.teachers,
//         ..._staffProvider.staffOnly,
//       ];
//       StaffMember? staffMeta;
//       final metaMatches = allStaff.where((s) => s.id == staffId);
//       if (metaMatches.isNotEmpty) staffMeta = metaMatches.first;
//
//       // Lookup map for O(1) access to existing Firestore records by date.
//       final existingByDate = <String, AttendanceRecord>{};
//       for (final rec in fetched) {
//         existingByDate[rec.date] = rec;
//       }
//
//       // Build one record per day in [monthStart, effectiveEnd], filling
//       // gaps with 'holiday' (Sunday) or 'absent' (any other day) when no
//       // explicit record was saved.
//       final results = <AttendanceRecord>[];
//       var cursor = monthStart;
//       while (!cursor.isAfter(effectiveEnd)) {
//         final dateStr = _fmt(cursor);
//         final existing = existingByDate[dateStr];
//         final isSunday = cursor.weekday == DateTime.sunday;
//
//         if (existing != null) {
//           results.add(existing);
//         } else {
//           results.add(AttendanceRecord(
//             id: '${staffId}_$dateStr',
//             staffId: staffId,
//             staffName: staffMeta?.name ?? '',
//             photoBase64: staffMeta?.imageBase64,
//             type: staffMeta?.type ?? 'staff',
//             date: dateStr,
//             status: isSunday ? 'holiday' : 'absent',
//             remarks: '',
//             designation: staffMeta?.designation,
//             isSaved: false,
//           ));
//         }
//         cursor = cursor.add(const Duration(days: 1));
//       }
//
//       _historyRecords = results;
//     } catch (e) {
//       _historyError = 'Failed to load history. If this is the first time '
//           'loading "By Person", Firestore may need a composite index '
//           '(staffId + date) — check console logs for a creation link.\n$e';
//       _historyRecords = [];
//     } finally {
//       _historyLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> adminUpdateHistoryRecord(
//       AttendanceRecord record, {
//         String? newStatus,
//         String? newRemarks,
//       }) async {
//     final index = _historyRecords.indexWhere((r) => r.id == record.id);
//     if (index == -1) return;
//
//     if (newStatus != null) _historyRecords[index].status = newStatus;
//     if (newRemarks != null) _historyRecords[index].remarks = newRemarks;
//     _historyRecords[index].isSaving = true;
//     notifyListeners();
//
//     try {
//       await _service.saveSingleRecord(_historyRecords[index]);
//       _historyRecords[index].isSaved = true;
//     } finally {
//       _historyRecords[index].isSaving = false;
//       notifyListeners();
//     }
//   }
//
//   // ─── Bulk attendance state ────────────────────────────────────────
//   List<AttendanceRecord> _bulkRecords = [];
//   bool _bulkLoading = false;
//   String? _bulkError;
//   int _bulkYear = DateTime.now().year;
//   int _bulkMonth = DateTime.now().month;
//   String _bulkFilter = 'all';
//
//   List<AttendanceRecord> get bulkRecords => _bulkRecords;
//   bool get bulkLoading => _bulkLoading;
//   String? get bulkError => _bulkError;
//
//   Future<void> loadBulkAttendance({
//     required int year,
//     required int month,
//     String typeFilter = 'all',
//   }) async {
//     _bulkYear = year;
//     _bulkMonth = month;
//     _bulkFilter = typeFilter;
//     _bulkLoading = true;
//     _bulkError = null;
//     notifyListeners();
//
//     try {
//       await _ensureStaffLoaded();
//
//       List<StaffMember> activeStaff;
//       switch (typeFilter) {
//         case 'teacher':
//           activeStaff = _staffProvider.teachers;
//           break;
//         case 'staff':
//           activeStaff = _staffProvider.staffOnly;
//           break;
//         default:
//           activeStaff = [..._staffProvider.teachers, ..._staffProvider.staffOnly];
//       }
//
//       final monthStart = DateTime(year, month, 1);
//       final monthEnd = DateTime(year, month + 1, 0);
//       final startStr = _fmt(monthStart);
//       final endStr = _fmt(monthEnd);
//
//       // Parallel fetch for all staff
//       final fetchFutures = activeStaff.map((s) =>
//           _service.getAttendanceForStaffInRange(
//             staffId: s.id!,
//             startDate: startStr,
//             endDate: endStr,
//           ));
//       final allResults = await Future.wait(fetchFutures);
//
//       // Build lookup map
//       final existingMap = <String, Map<String, AttendanceRecord>>{};
//       for (int i = 0; i < activeStaff.length; i++) {
//         final staff = activeStaff[i];
//         final fetched = allResults[i];
//         final dateMap = <String, AttendanceRecord>{};
//         for (final rec in fetched) {
//           dateMap[rec.date] = rec;
//         }
//         existingMap[staff.id!] = dateMap;
//       }
//
//       final result = <AttendanceRecord>[];
//       var cursor = monthStart;
//       while (!cursor.isAfter(monthEnd)) {
//         final dateStr = _fmt(cursor);
//         final isSunday = cursor.weekday == DateTime.sunday;
//
//         for (final staff in activeStaff) {
//           bool isBeforeJoin = false;
//           if (staff.joiningDate != null && staff.joiningDate!.isNotEmpty) {
//             try {
//               final joinDate = DateTime.parse(staff.joiningDate!);
//               if (joinDate.isAfter(cursor)) isBeforeJoin = true;
//             } catch (_) {}
//           }
//
//           final existing = existingMap[staff.id]?[dateStr];
//           if (existing != null) {
//             result.add(existing);
//           } else {
//             final defaultStatus = isSunday ? 'holiday' : 'present';
//             result.add(AttendanceRecord(
//               id: '${staff.id}_$dateStr',
//               staffId: staff.id!,
//               staffName: staff.name,
//               photoBase64: staff.imageBase64,
//               type: staff.type,
//               date: dateStr,
//               status: isBeforeJoin ? 'holiday' : defaultStatus,
//               remarks: isBeforeJoin ? 'Before joining' : '',
//               designation: staff.designation,
//               isSaved: isBeforeJoin,
//               isSaving: false,
//             ));
//           }
//         }
//         cursor = cursor.add(const Duration(days: 1));
//       }
//
//       result.sort((a, b) {
//         final nameComp = a.staffName.compareTo(b.staffName);
//         return nameComp != 0 ? nameComp : a.date.compareTo(b.date);
//       });
//
//       _bulkRecords = result;
//     } catch (e) {
//       _bulkError = 'Failed to load bulk attendance: $e';
//       _bulkRecords = [];
//     } finally {
//       _bulkLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> saveBulkAttendanceForStaff(String staffId) async {
//     final toSave = _bulkRecords.where(
//           (r) => r.staffId == staffId && !r.isSaved && r.status != 'holiday',
//     ).toList();
//
//     if (toSave.isEmpty) return;
//
//     // Use batch write if available, else fallback to single saves
//     await _service.saveAttendanceBatch(toSave); // Ensure this method exists
//
//     for (final rec in toSave) {
//       final idx = _bulkRecords.indexWhere(
//             (r) => r.staffId == rec.staffId && r.date == rec.date,
//       );
//       if (idx != -1) _bulkRecords[idx].isSaved = true;
//     }
//     notifyListeners();
//   }
//
//
//
//
// // Reload with the same parameters
//   Future<void> reloadBulk() =>
//       loadBulkAttendance(year: _bulkYear, month: _bulkMonth, typeFilter: _bulkFilter);
//
// // Update a single bulk record's status (called from UI)
//   void updateBulkStatus(String staffId, String date, String newStatus) {
//     final index = _bulkRecords.indexWhere(
//           (r) => r.staffId == staffId && r.date == date,
//     );
//     if (index == -1) return;
//     // Only allow changes if the record is not read‑only (holiday before join)
//     if (_bulkRecords[index].isSaved &&
//         _bulkRecords[index].remarks == 'Before joining') {
//       return;
//     }
//     _bulkRecords[index].status = newStatus;
//     // Mark as unsaved so it will be included in save
//     _bulkRecords[index].isSaved = false;
//     notifyListeners();
//   }
//
// // Save all unsaved bulk records (including updates to existing)
//   Future<void> saveBulkAttendance() async {
//     // Collect all records that are not read‑only and have changes
//     final toSave = _bulkRecords.where(
//           (r) => !r.isSaved && r.status != 'holiday',
//     ).toList();
//
//     if (toSave.isEmpty) {
//       // Optionally show a message
//       return;
//     }
//
//     for (final record in toSave) {
//       await _service.saveSingleRecord(record);
//       // Mark as saved in the list
//       final idx = _bulkRecords.indexWhere(
//             (r) => r.staffId == record.staffId && r.date == record.date,
//       );
//       if (idx != -1) {
//         _bulkRecords[idx].isSaved = true;
//       }
//     }
//     notifyListeners();
//   }
//
//
//   Future<void> _ensureStaffLoaded() async {
//     if (_staffLoaded) return;
//     await Future.wait([
//       _staffProvider.fetchTeachers(),
//       _staffProvider.fetchStaffOnly(),
//     ]);
//     _staffLoaded = true;
//   }
//
//   Future<void> refreshStaff() async {
//     _staffLoaded = false;
//     await _ensureStaffLoaded();
//   }
//
//
//
//
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../models/teacher.dart';
import '../providers/teacher_provider.dart';
import '../services/attendance_firestore_service.dart';

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

  // Separate state for the "Attendance History" screen
  List<AttendanceRecord> _historyRecords = [];
  bool _historyLoading = false;
  String? _historyError;

  List<AttendanceRecord> get historyRecords => _historyRecords;
  bool get historyLoading => _historyLoading;
  String? get historyError => _historyError;
  bool _staffLoaded = false;

  // Compute summary statistics for "By Person" report
  Map<String, int> get monthSummary {
    Map<String, int> counts = {
      'total': _historyRecords.length,
      'present': 0,
      'absent': 0,
      'leave': 0,
      'late': 0,
      'half_day': 0,
      'holiday': 0,
    };
    for (final r in _historyRecords) {
      if (counts.containsKey(r.status)) {
        counts[r.status] = counts[r.status]! + 1;
      }
    }
    return counts;
  }

  AttendanceProvider(this._staffProvider);

  // ★ Small date helper: 'yyyy-MM-dd' with zero-padding.
  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> loadData({String? typeFilter}) async {
    _loading = true;
    _filterType = typeFilter ?? _filterType;
    notifyListeners();

    await _staffProvider.fetchTeachers();
    await _staffProvider.fetchStaffOnly();

    final existingRecords = await _service.getAttendanceForDate(_selectedDate);

    List<StaffMember> activeStaff = [];
    if (_filterType == 'teacher') {
      activeStaff = _staffProvider.teachers;
    } else if (_filterType == 'staff') {
      activeStaff = _staffProvider.staffOnly;
    } else {
      activeStaff = [..._staffProvider.teachers, ..._staffProvider.staffOnly];
    }

    // ★ Is the currently selected day a Sunday? If so, and no explicit
    // record already exists for a staff member, default their status to
    // 'holiday' instead of 'present'/'absent'.
    final isSunday = DateTime.parse(_selectedDate).weekday == DateTime.sunday;

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
        status: existing?.status ?? (isSunday ? 'holiday' : 'present'),
        remarks: existing?.remarks ?? '',
        designation: staff.designation,
        isSaved: existing != null,
      );
    }).toList();

    _loading = false;
    notifyListeners();
  }

  void changeDate(DateTime newDate) {
    _selectedDate = newDate.toIso8601String().split('T')[0];
    loadData();
  }

  void changeFilter(String newFilter) {
    _filterType = newFilter;
    loadData();
  }

  bool updateStatus(String staffId, String status, {bool isAdmin = false}) {
    final index = _records.indexWhere((r) => r.staffId == staffId);
    if (index == -1) return false;
    if (_records[index].isSaved && !isAdmin) return false;
    _records[index].status = status;
    notifyListeners();
    return true;
  }

  bool updateRemarks(String staffId, String remark, {bool isAdmin = false}) {
    final index = _records.indexWhere((r) => r.staffId == staffId);
    if (index == -1) return false;
    if (_records[index].isSaved && !isAdmin) return false;
    _records[index].remarks = remark;
    notifyListeners();
    return true;
  }

  int markAll(String status) {
    int skipped = 0;
    for (final record in _records) {
      if (record.isSaved) {
        skipped++;
        continue;
      }
      record.status = status;
    }
    notifyListeners();
    return skipped;
  }

  Future<void> saveAttendance() async {
    await _service.saveAttendance(_records);
    await loadData();
  }

  // ============================================================
  // ATTENDANCE HISTORY
  // ============================================================

  // ★ FIXED: Removed improper type casting on results[0] / results[1]
  // ★ FIXED: Sundays with no explicit Firestore record now default to
  // 'holiday' instead of 'absent'.
  Future<void> loadHistoryForDate(String date, {String typeFilter = 'all'}) async {
    _historyLoading = true;
    _historyError = null;
    notifyListeners();

    try {
      // 1. Fetch staff & attendance in parallel properly
      final attendanceFuture = _service.getAttendanceForDate(date);
      final staffFetchFuture = Future.wait([
        _staffProvider.fetchTeachers(),
        _staffProvider.fetchStaffOnly(),
      ]);

      await staffFetchFuture; // Wait for staff fetch first
      final existingRecords = await attendanceFuture; // Wait for attendance fetch

      // 2. Access lists directly from provider (no type-casting errors here)
      final teachers = _staffProvider.teachers;
      final staffOnly = _staffProvider.staffOnly;

      // 3. Build O(1) lookup map for existing records
      final existingMap = <String, AttendanceRecord>{};
      for (final rec in existingRecords) {
        existingMap[rec.staffId] = rec;
      }

      // 4. Determine active staff list
      List<StaffMember> activeStaff = [];
      if (typeFilter == 'teacher') {
        activeStaff = teachers;
      } else if (typeFilter == 'staff') {
        activeStaff = staffOnly;
      } else {
        activeStaff = [...teachers, ...staffOnly];
      }

      // 5. ★ Is this particular date a Sunday? If so, and there's no
      // explicit saved record, default to 'holiday' rather than 'absent'.
      bool isSunday = false;
      try {
        isSunday = DateTime.parse(date).weekday == DateTime.sunday;
      } catch (_) {}

      // 6. Map instantly using the lookup map
      _historyRecords = activeStaff.map((staff) {
        final existing = existingMap[staff.id];
        return AttendanceRecord(
          id: existing?.id ?? '${staff.id}_$date',
          staffId: staff.id!,
          staffName: staff.name,
          photoBase64: staff.imageBase64,
          type: staff.type,
          date: date,
          status: existing?.status ?? (isSunday ? 'holiday' : 'absent'),
          remarks: existing?.remarks ?? '',
          designation: staff.designation,
          isSaved: existing != null,
        );
      }).toList();

    } catch (e) {
      _historyError = 'Failed to load attendance: $e';
      _historyRecords = [];
    } finally {
      _historyLoading = false;
      notifyListeners();
    }
  }

  // ★ FIXED / REWRITTEN:
  // 1. Date range now stops at "today" when the requested month is the
  //    current month, instead of always going to the end of the month —
  //    e.g. selecting July 2026 on 16-Jul-2026 shows 1 Jul → 16 Jul only.
  //    Past months still show the full month (1st → last day).
  //    Future months yield an empty range (nothing to show yet).
  // 2. Every day in that range is now included in the result, even if no
  //    Firestore record exists for it — previously, days with no saved
  //    attendance were silently skipped instead of showing as "absent".
  // 3. Sundays with no explicit saved record default to 'holiday' instead
  //    of 'absent'.
  Future<void> loadHistoryForPerson({
    required String staffId,
    required int year,
    required int month,
  }) async {
    _historyLoading = true;
    _historyError = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0); // last day of month

      final isCurrentMonth = year == now.year && month == now.month;
      final today = DateTime(now.year, now.month, now.day);

      // If it's a future month entirely, there's nothing to show.
      if (monthStart.isAfter(today)) {
        _historyRecords = [];
        _historyLoading = false;
        notifyListeners();
        return;
      }

      // Effective end date: today (if current month) else full month end.
      final effectiveEnd = isCurrentMonth
          ? (monthEnd.isBefore(today) ? monthEnd : today)
          : monthEnd;

      final startStr = _fmt(monthStart);
      final endStr = _fmt(effectiveEnd);

      final fetched = await _service.getAttendanceForStaffInRange(
        staffId: staffId,
        startDate: startStr,
        endDate: endStr,
      );

      // Need staff meta (name/photo/type/designation) to fabricate
      // placeholder records for days with no saved attendance.
      final allStaff = [
        ..._staffProvider.teachers,
        ..._staffProvider.staffOnly,
      ];
      StaffMember? staffMeta;
      final metaMatches = allStaff.where((s) => s.id == staffId);
      if (metaMatches.isNotEmpty) staffMeta = metaMatches.first;

      // Lookup map for O(1) access to existing Firestore records by date.
      final existingByDate = <String, AttendanceRecord>{};
      for (final rec in fetched) {
        existingByDate[rec.date] = rec;
      }

      // Build one record per day in [monthStart, effectiveEnd], filling
      // gaps with 'holiday' (Sunday) or 'absent' (any other day) when no
      // explicit record was saved.
      final results = <AttendanceRecord>[];
      var cursor = monthStart;
      while (!cursor.isAfter(effectiveEnd)) {
        final dateStr = _fmt(cursor);
        final existing = existingByDate[dateStr];
        final isSunday = cursor.weekday == DateTime.sunday;

        if (existing != null) {
          results.add(existing);
        } else {
          results.add(AttendanceRecord(
            id: '${staffId}_$dateStr',
            staffId: staffId,
            staffName: staffMeta?.name ?? '',
            photoBase64: staffMeta?.imageBase64,
            type: staffMeta?.type ?? 'staff',
            date: dateStr,
            status: isSunday ? 'holiday' : 'absent',
            remarks: '',
            designation: staffMeta?.designation,
            isSaved: false,
          ));
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      _historyRecords = results;
    } catch (e) {
      _historyError = 'Failed to load history. If this is the first time '
          'loading "By Person", Firestore may need a composite index '
          '(staffId + date) — check console logs for a creation link.\n$e';
      _historyRecords = [];
    } finally {
      _historyLoading = false;
      notifyListeners();
    }
  }

  Future<void> adminUpdateHistoryRecord(
      AttendanceRecord record, {
        String? newStatus,
        String? newRemarks,
      }) async {
    final index = _historyRecords.indexWhere((r) => r.id == record.id);
    if (index == -1) return;

    if (newStatus != null) _historyRecords[index].status = newStatus;
    if (newRemarks != null) _historyRecords[index].remarks = newRemarks;
    _historyRecords[index].isSaving = true;
    notifyListeners();

    try {
      await _service.saveSingleRecord(_historyRecords[index]);
      _historyRecords[index].isSaved = true;
    } finally {
      _historyRecords[index].isSaving = false;
      notifyListeners();
    }
  }

  // ─── Bulk attendance state ────────────────────────────────────────
  List<AttendanceRecord> _bulkRecords = [];
  bool _bulkLoading = false;
  String? _bulkError;
  int _bulkYear = DateTime.now().year;
  int _bulkMonth = DateTime.now().month;
  String _bulkFilter = 'all';

  List<AttendanceRecord> get bulkRecords => _bulkRecords;
  bool get bulkLoading => _bulkLoading;
  String? get bulkError => _bulkError;

  Future<void> loadBulkAttendance({
    required int year,
    required int month,
    String typeFilter = 'all',
  }) async {
    _bulkYear = year;
    _bulkMonth = month;
    _bulkFilter = typeFilter;
    _bulkLoading = true;
    _bulkError = null;
    notifyListeners();

    try {
      await _ensureStaffLoaded();

      List<StaffMember> activeStaff;
      switch (typeFilter) {
        case 'teacher':
          activeStaff = _staffProvider.teachers;
          break;
        case 'staff':
          activeStaff = _staffProvider.staffOnly;
          break;
        default:
          activeStaff = [..._staffProvider.teachers, ..._staffProvider.staffOnly];
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0);
      final startStr = _fmt(monthStart);
      final endStr = _fmt(monthEnd);

      // Parallel fetch for all staff
      final fetchFutures = activeStaff.map((s) =>
          _service.getAttendanceForStaffInRange(
            staffId: s.id!,
            startDate: startStr,
            endDate: endStr,
          ));
      final allResults = await Future.wait(fetchFutures);

      // Build lookup map
      final existingMap = <String, Map<String, AttendanceRecord>>{};
      for (int i = 0; i < activeStaff.length; i++) {
        final staff = activeStaff[i];
        final fetched = allResults[i];
        final dateMap = <String, AttendanceRecord>{};
        for (final rec in fetched) {
          dateMap[rec.date] = rec;
        }
        existingMap[staff.id!] = dateMap;
      }

      final result = <AttendanceRecord>[];
      var cursor = monthStart;
      while (!cursor.isAfter(monthEnd)) {
        final dateStr = _fmt(cursor);
        final isSunday = cursor.weekday == DateTime.sunday;
        final isFuture = cursor.isAfter(today);

        for (final staff in activeStaff) {
          bool isBeforeJoin = false;
          if (staff.joiningDate != null && staff.joiningDate!.isNotEmpty) {
            try {
              final joinDate = DateTime.parse(staff.joiningDate!);
              if (joinDate.isAfter(cursor)) isBeforeJoin = true;
            } catch (_) {}
          }

          final existing = existingMap[staff.id]?[dateStr];
          if (existing != null) {
            result.add(existing);
          } else {
            String defaultStatus;
            String defaultRemarks;
            bool defaultIsSaved;
            if (isFuture) {
              // Future dates are locked, cannot be changed
              defaultStatus = '';        // empty = unset / gray
              defaultRemarks = 'Future date';
              defaultIsSaved = true;     // treat as saved so UI knows it’s readonly
            } else if (isBeforeJoin) {
              defaultStatus = 'holiday';
              defaultRemarks = 'Before joining';
              defaultIsSaved = true;
            } else {
              defaultStatus = isSunday ? 'holiday' : 'present';
              defaultRemarks = '';
              defaultIsSaved = false;
            }
            result.add(AttendanceRecord(
              id: '${staff.id}_$dateStr',
              staffId: staff.id!,
              staffName: staff.name,
              photoBase64: staff.imageBase64,
              type: staff.type,
              date: dateStr,
              status: defaultStatus,
              remarks: defaultRemarks,
              designation: staff.designation,
              isSaved: defaultIsSaved,
              isSaving: false,
            ));
          }
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      result.sort((a, b) {
        final nameComp = a.staffName.compareTo(b.staffName);
        return nameComp != 0 ? nameComp : a.date.compareTo(b.date);
      });

      _bulkRecords = result;
    } catch (e) {
      _bulkError = 'Failed to load bulk attendance: $e';
      _bulkRecords = [];
    } finally {
      _bulkLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBulkAttendanceForStaff(String staffId) async {
    final toSave = _bulkRecords.where(
          (r) => r.staffId == staffId && !r.isSaved && r.status != 'holiday',
    ).toList();

    if (toSave.isEmpty) return;

    await _service.saveAttendanceBatch(toSave);

    for (final rec in toSave) {
      final idx = _bulkRecords.indexWhere(
            (r) => r.staffId == rec.staffId && r.date == rec.date,
      );
      if (idx != -1) _bulkRecords[idx].isSaved = true;
    }
    notifyListeners();
  }

  // Reload with the same parameters
  Future<void> reloadBulk() =>
      loadBulkAttendance(year: _bulkYear, month: _bulkMonth, typeFilter: _bulkFilter);

  // Update a single bulk record's status (called from UI)
  void updateBulkStatus(String staffId, String date, String newStatus) {
    final index = _bulkRecords.indexWhere(
          (r) => r.staffId == staffId && r.date == date,
    );
    if (index == -1) return;
    // Only allow changes if the record is not read‑only (future date / before joining)
    if (_bulkRecords[index].isSaved &&
        (_bulkRecords[index].remarks == 'Before joining' ||
            _bulkRecords[index].remarks == 'Future date')) {
      return;
    }
    _bulkRecords[index].status = newStatus;
    // Mark as unsaved so it will be included in save
    _bulkRecords[index].isSaved = false;
    notifyListeners();
  }

  // Save all unsaved bulk records (including updates to existing)
  Future<void> saveBulkAttendance() async {
    final toSave = _bulkRecords.where(
          (r) => !r.isSaved && r.status != 'holiday',
    ).toList();

    if (toSave.isEmpty) return;

    for (final record in toSave) {
      await _service.saveSingleRecord(record);
      final idx = _bulkRecords.indexWhere(
            (r) => r.staffId == record.staffId && r.date == record.date,
      );
      if (idx != -1) {
        _bulkRecords[idx].isSaved = true;
      }
    }
    notifyListeners();
  }

  Future<void> _ensureStaffLoaded() async {
    if (_staffLoaded) return;
    await Future.wait([
      _staffProvider.fetchTeachers(),
      _staffProvider.fetchStaffOnly(),
    ]);
    _staffLoaded = true;
  }

  Future<void> refreshStaff() async {
    _staffLoaded = false;
    await _ensureStaffLoaded();
  }
}