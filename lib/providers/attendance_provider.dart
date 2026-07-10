
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

  // Separate state for the "Attendance History" screen so it
  // doesn't interfere with the main day-entry screen above.
  List<AttendanceRecord> _historyRecords = [];
  bool _historyLoading = false;

  // ★ NEW: surfaces a readable error instead of an infinite spinner
  // when a history query fails (e.g. missing Firestore composite index).
  String? _historyError;
  String? get historyError => _historyError;

  List<AttendanceRecord> get historyRecords => _historyRecords;
  bool get historyLoading => _historyLoading;

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

    // 4. Merge into local records
    // NOTE: mark-attendance (today's entry) screen intentionally still
    // defaults new/unmarked rows to 'present' here — that's the daily
    // entry workflow and wasn't part of the reported bug. Only the
    // History "By Date" view (below) was asked to default to 'absent'.
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

  // Update single status — refuses to modify a record that is already
  // saved for this date, UNLESS an admin override is explicitly passed.
  // Returns true if the update happened, false if it was blocked.
  bool updateStatus(String staffId, String status, {bool isAdmin = false}) {
    final index = _records.indexWhere((r) => r.staffId == staffId);
    if (index == -1) return false;
    if (_records[index].isSaved && !isAdmin) return false; // locked for non-admins
    _records[index].status = status;
    notifyListeners();
    return true;
  }

  // Update single remark — same lock rule as updateStatus.
  bool updateRemarks(String staffId, String remark, {bool isAdmin = false}) {
    final index = _records.indexWhere((r) => r.staffId == staffId);
    if (index == -1) return false;
    if (_records[index].isSaved && !isAdmin) return false;
    _records[index].remarks = remark;
    notifyListeners();
    return true;
  }

  // Quick action: Mark all present/absent — skips any record that is
  // already saved for this date (bulk actions never silently overwrite
  // existing attendance, even for admins — admins edit one row at a time
  // via the History screen instead). Returns number of records skipped.
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

  // Save to Firestore
  Future<void> saveAttendance() async {
    await _service.saveAttendance(_records);
    // Optionally reload to ensure local data matches server state
    await loadData();
  }

  // ============================================================
  // ATTENDANCE HISTORY (used by AttendanceHistoryScreen)
  // ============================================================

  // "By Date" tab: reuses the same logic as loadData() but writes into
  // _historyRecords instead. For dates where no record exists yet it
  // still exposes a row so an admin can create it from the history
  // screen too.
  //
  // ★ FIX #1 (reported bug 1): unmarked staff now default to 'absent'
  // instead of 'present' — matches "agar kisi ki attendance ni lagi tu
  // us ka by default absent hi show" requirement.
  // ★ FIX #2: wrapped in try/catch + always resets _historyLoading in
  // a finally block, so a failed staff-fetch or query can never leave
  // the spinner stuck.
  Future<void> loadHistoryForDate(String date, {String typeFilter = 'all'}) async {
    _historyLoading = true;
    _historyError = null;
    notifyListeners();

    try {
      await _staffProvider.fetchTeachers();
      await _staffProvider.fetchStaffOnly();

      final existingRecords = await _service.getAttendanceForDate(date);

      List<StaffMember> activeStaff = [];
      if (typeFilter == 'teacher') {
        activeStaff = _staffProvider.teachers;
      } else if (typeFilter == 'staff') {
        activeStaff = _staffProvider.staffOnly;
      } else {
        activeStaff = [..._staffProvider.teachers, ..._staffProvider.staffOnly];
      }

      _historyRecords = activeStaff.map((staff) {
        final matching =
        existingRecords.where((r) => r.staffId == staff.id).toList();
        final existing = matching.isNotEmpty ? matching.first : null;

        return AttendanceRecord(
          id: existing?.id ?? '${staff.id}_$date',
          staffId: staff.id!,
          staffName: staff.name,
          photoBase64: staff.imageBase64,
          type: staff.type,
          date: date,
          // ★ default changed from 'present' -> 'absent'
          status: existing?.status ?? 'absent',
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

  // "By Person" tab: loads every saved record for one staff/teacher within
  // a given month (does NOT synthesize missing days — only real saved
  // records are shown, since showing 30 empty rows for a person isn't
  // useful history).
  //
  // ★ FIX (root cause of infinite spinner, reported bug 2): the
  // Firestore query in the service can throw `failed-precondition` if
  // the required composite index (staffId + date range) doesn't exist
  // yet. That exception was previously unhandled, so this function
  // never reached `_historyLoading = false`. Now wrapped in try/catch
  // with a finally block, and the error is exposed via `historyError`
  // so the screen can show a real message instead of spinning forever.
  Future<void> loadHistoryForPerson({
    required String staffId,
    required int year,
    required int month,
  }) async {
    _historyLoading = true;
    _historyError = null;
    notifyListeners();

    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0); // last day of month
      String fmt(DateTime d) =>
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final fetched = await _service.getAttendanceForStaffInRange(
        staffId: staffId,
        startDate: fmt(start),
        endDate: fmt(end),
      );

      _historyRecords = fetched;
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

  // Admin-only single-record edit used by the History screen. Updates
  // the in-memory row immediately (optimistic) then persists it, and
  // finally marks it as saved (in case it was a brand-new date row).
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
}
