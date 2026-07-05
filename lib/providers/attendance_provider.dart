import 'package:flutter/foundation.dart';

import '../models/attendance_model.dart';
import '../services/attendance_firestore_service.dart';

/// Attendance state management, mirroring StaffProvider's ChangeNotifier
/// pattern so it plugs into the app the same way.
class AttendanceProvider extends ChangeNotifier {
  final AttendanceFirestoreService _service = AttendanceFirestoreService();

  bool _loading = false;
  bool get loading => _loading;

  bool _saving = false;
  bool get saving => _saving;

  String? _error;
  String? get error => _error;

  // ── View/Edit screen state ──
  List<AttendanceRecord> _byDateRecords = [];
  List<AttendanceRecord> get byDateRecords => _byDateRecords;

  List<AttendanceRecord> _byStaffRecords = [];
  List<AttendanceRecord> get byStaffRecords => _byStaffRecords;

  /// Marks a single attendance record.
  Future<bool> markAttendance(AttendanceRecord record) async {
    try {
      await _service.markAttendance(record);
      return true;
    } catch (e) {
      _error = 'Attendance save nahi ho saki: $e';
      notifyListeners();
      return false;
    }
  }

  /// Marks multiple attendance records at once (used by both Mode 1's
  /// multi-staff single-date save and Mode 2's multi-staff multi-date save).
  /// Returns true on success so calling screens can show the right feedback.
  Future<bool> markMultiple(List<AttendanceRecord> records) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _service.markMultiple(records);
      _saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _saving = false;
      _error = 'Records save karte waqt error aayi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Loads every attendance record for a given date (View/Edit → By Date).
  Future<void> fetchByDate(String date) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await _service.getByDate(date);
      results.sort((a, b) => a.staffName.compareTo(b.staffName));
      _byDateRecords = results;
    } catch (e) {
      _error = 'Attendance load nahi ho saki: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Loads every attendance record for a given staff member within a
  /// given month, formatted 'yyyy-MM' (View/Edit → By Staff).
  Future<void> fetchByStaffAndMonth(String staffId, String yearMonth) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _byStaffRecords =
      await _service.getByStaffAndMonth(staffId, yearMonth);
    } catch (e) {
      _error = 'Attendance load nahi ho saki: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Edits an already-marked record's status, then keeps whichever local
  /// cached list (by-date or by-staff) is showing it in sync so the UI
  /// updates immediately without a re-fetch.
  Future<bool> updateStatus(AttendanceRecord record, String newStatus) async {
    try {
      await _service.updateStatus(record, newStatus);

      final updated = record.copyWith(status: newStatus);

      final dateIndex =
      _byDateRecords.indexWhere((r) => r.docId == record.docId);
      if (dateIndex != -1) _byDateRecords[dateIndex] = updated;

      final staffIndex =
      _byStaffRecords.indexWhere((r) => r.docId == record.docId);
      if (staffIndex != -1) _byStaffRecords[staffIndex] = updated;

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Status update nahi ho saka: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes a single attendance record entirely.
  Future<bool> deleteRecord(AttendanceRecord record) async {
    try {
      await _service.deleteRecord(record.docId);
      _byDateRecords.removeWhere((r) => r.docId == record.docId);
      _byStaffRecords.removeWhere((r) => r.docId == record.docId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Record delete nahi ho saka: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    _byDateRecords = [];
    _byStaffRecords = [];
    _error = null;
    notifyListeners();
  }
}