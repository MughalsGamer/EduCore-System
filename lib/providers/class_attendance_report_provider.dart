import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/class_attendance_model.dart';

// ─────────────────────────────────────────────
//  Class Attendance REPORT Provider
//
//  PERFORMANCE DESIGN
//  -------------------
//  - Attendance docs are stored one-per-class-per-section-per-day
//    (docId = classId_sectionId_date), so a whole month's report is
//    just every doc in that date range — no composite index needed,
//    just a range query on the deterministic 'date' field combined
//    with a classId/sectionId equality filter (single-field indexes
//    only).
//  - We fetch the whole month ONCE per class+section+month and then
//    do all aggregation (per-student counts, per-day grid, %) in
//    memory — this is what keeps switching between "Class report"
//    and "Student report" instant, since both read from the same
//    cached _monthRecords list.
//  - Student-wise report reuses the exact same cache: if the report
//    is for a student whose class+section+month was already loaded
//    for the class report, no extra Firestore read happens at all.
// ─────────────────────────────────────────────

class StudentMonthStat {
  final String studentId;
  final String name;
  int present = 0;
  int absent = 0;
  int leave = 0;
  int late = 0;
  int halfDay = 0;

  StudentMonthStat({required this.studentId, required this.name});

  int get markedDays => present + absent + leave + late + halfDay;

  /// Half-day counts as 0.5 present for the percentage.
  double get percentage {
    if (markedDays == 0) return 0;
    final effectivePresent = present + (halfDay * 0.5);
    return (effectivePresent / markedDays) * 100;
  }

  void _apply(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        present++;
        break;
      case AttendanceStatus.absent:
        absent++;
        break;
      case AttendanceStatus.leave:
        leave++;
        break;
      case AttendanceStatus.late:
        late++;
        break;
      case AttendanceStatus.halfDay:
        halfDay++;
        break;
    }
  }
}

/// One day's status for a single student — used for the day-by-day
/// breakdown table on the student report screen.
class DayStatusEntry {
  final DateTime date;
  final AttendanceStatus status;
  DayStatusEntry({required this.date, required this.status});
}

class ClassAttendanceReportProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'attendance';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Cache key so we don't re-fetch if the same class+section+month
  // is requested again (e.g. switching tabs).
  String? _cacheKey;
  List<ClassAttendanceModel> _monthDocs = [];

  int _daysMarkedInMonth = 0;
  int get daysMarkedInMonth => _daysMarkedInMonth;

  List<StudentMonthStat> _studentStats = [];
  List<StudentMonthStat> get studentStats => _studentStats;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Loads every attendance doc for a class+section within [year]/[month]
  /// and aggregates per-student stats.
  Future<void> loadClassMonth({
    required String classId,
    required String sectionId,
    required int year,
    required int month,
  }) async {
    final key = '${classId}_${sectionId}_${year}_$month';
    if (key == _cacheKey && !_isLoading) {
      // already loaded — nothing to do
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      final snap = await _db
          .collection(_collection)
          .where('classId', isEqualTo: classId)
          .where('sectionId', isEqualTo: sectionId)
          .where('date', isGreaterThanOrEqualTo: _dateStr(firstDay))
          .where('date', isLessThanOrEqualTo: _dateStr(lastDay))
          .get();

      _monthDocs = snap.docs
          .map((d) => ClassAttendanceModel.fromFirestore(d))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      _daysMarkedInMonth = _monthDocs.length;
      _cacheKey = key;
      _aggregateClassStats();
    } catch (e) {
      _error = 'Failed to load report: $e';
      _monthDocs = [];
      _studentStats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _aggregateClassStats() {
    final Map<String, StudentMonthStat> stats = {};
    for (final doc in _monthDocs) {
      for (final rec in doc.records.values) {
        final stat = stats.putIfAbsent(
          rec.studentId,
              () => StudentMonthStat(studentId: rec.studentId, name: rec.name),
        );
        stat._apply(rec.status);
      }
    }
    _studentStats = stats.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Day-by-day entries for one student, from the currently loaded month.
  /// Call loadClassMonth first (or it'll return an empty list).
  List<DayStatusEntry> dayEntriesForStudent(String studentId) {
    final List<DayStatusEntry> entries = [];
    for (final doc in _monthDocs) {
      final rec = doc.records[studentId];
      if (rec == null) continue;
      DateTime? d;
      try {
        d = DateTime.parse(doc.date);
      } catch (_) {
        continue;
      }
      entries.add(DayStatusEntry(date: d, status: rec.status));
    }
    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  StudentMonthStat? statFor(String studentId) {
    try {
      return _studentStats.firstWhere((s) => s.studentId == studentId);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _monthDocs = [];
    _studentStats = [];
    _cacheKey = null;
    _daysMarkedInMonth = 0;
    notifyListeners();
  }
}