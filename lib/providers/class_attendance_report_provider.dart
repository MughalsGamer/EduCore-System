//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../models/class_attendance_model.dart';
//
// // ─────────────────────────────────────────────
// //  Class Attendance REPORT Provider
// // ─────────────────────────────────────────────
//
// class StudentMonthStat {
//   final String studentId;
//   final String name;
//   int present = 0;
//   int absent = 0;
//   int leave = 0;
//   int late = 0;
//   int halfDay = 0;
//
//   StudentMonthStat({required this.studentId, required this.name});
//
//   int get markedDays => present + absent + leave + late + halfDay;
//
//   double get percentage {
//     if (markedDays == 0) return 0;
//     final effectivePresent = present + (halfDay * 0.5);
//     return (effectivePresent / markedDays) * 100;
//   }
//
//   void _apply(AttendanceStatus s) {
//     switch (s) {
//       case AttendanceStatus.present:
//         present++;
//         break;
//       case AttendanceStatus.absent:
//         absent++;
//         break;
//       case AttendanceStatus.leave:
//         leave++;
//         break;
//       case AttendanceStatus.late:
//         late++;
//         break;
//       case AttendanceStatus.halfDay:
//         halfDay++;
//         break;
//     }
//   }
// }
//
// class DayStatusEntry {
//   final DateTime date;
//   final AttendanceStatus status;
//   DayStatusEntry({required this.date, required this.status});
// }
//
// class ClassAttendanceReportProvider extends ChangeNotifier {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   static const String _collection = 'attendance';
//
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//
//   String? _error;
//   String? get error => _error;
//
//   String? _cacheKey;
//   List<ClassAttendanceModel> _monthDocs = [];
//
//   int _daysMarkedInMonth = 0;
//   int get daysMarkedInMonth => _daysMarkedInMonth;
//
//   List<StudentMonthStat> _studentStats = [];
//   List<StudentMonthStat> get studentStats => _studentStats;
//
//   // ---- All Classes — Today ----
//   bool _isLoadingToday = false;
//   bool get isLoadingToday => _isLoadingToday;
//
//   String? _todayError;
//   String? get todayError => _todayError;
//
//   List<ClassAttendanceModel> _todayDocs = [];
//   List<ClassAttendanceModel> get todayDocs => _todayDocs;
//
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
//
//   String _dateStr(DateTime d) =>
//       '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
//
//   Future<void> loadClassMonth({
//     required String classId,
//     required String sectionId,
//     required int year,
//     required int month,
//   }) async {
//     final key = '${classId}_${sectionId}_${year}_$month';
//     if (key == _cacheKey && !_isLoading) {
//       return;
//     }
//
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final firstDay = DateTime(year, month, 1);
//       final lastDay = DateTime(year, month + 1, 0);
//
//       final snap = await _db
//           .collection(_collection)
//           .where('classId', isEqualTo: classId)
//           .where('sectionId', isEqualTo: sectionId)
//           .where('date', isGreaterThanOrEqualTo: _dateStr(firstDay))
//           .where('date', isLessThanOrEqualTo: _dateStr(lastDay))
//           .get();
//
//       _monthDocs = snap.docs
//           .map((d) => ClassAttendanceModel.fromFirestore(d))
//           .toList()
//         ..sort((a, b) => a.date.compareTo(b.date));
//
//       _daysMarkedInMonth = _monthDocs.length;
//       _cacheKey = key;
//       _aggregateClassStats();
//     } catch (e) {
//       _error = 'Failed to load report: $e';
//       _monthDocs = [];
//       _studentStats = [];
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// Loads every class's attendance doc for today's date so the UI
//   /// can list present students across all classes at once.
//   Future<void> loadAllClassesToday() async {
//     _isLoadingToday = true;
//     _todayError = null;
//     notifyListeners();
//
//     try {
//       final today = _dateStr(DateTime.now());
//
//       final snap = await _db
//           .collection(_collection)
//           .where('date', isEqualTo: today)
//           .get();
//
//       _todayDocs = snap.docs
//           .map((d) => ClassAttendanceModel.fromFirestore(d))
//           .toList()
//         ..sort((a, b) {
//           final c = a.className.compareTo(b.className);
//           if (c != 0) return c;
//           return a.sectionName.compareTo(b.sectionName);
//         });
//     } catch (e) {
//       _todayError = 'Failed to load today\'s attendance: $e';
//       _todayDocs = [];
//     } finally {
//       _isLoadingToday = false;
//       notifyListeners();
//     }
//   }
//
//   void clearToday() {
//     _todayDocs = [];
//     _todayError = null;
//     notifyListeners();
//   }
//
//   void _aggregateClassStats() {
//     final Map<String, StudentMonthStat> stats = {};
//     for (final doc in _monthDocs) {
//       for (final rec in doc.records.values) {
//         final stat = stats.putIfAbsent(
//           rec.studentId,
//               () => StudentMonthStat(studentId: rec.studentId, name: rec.name),
//         );
//         stat._apply(rec.status);
//       }
//     }
//     _studentStats = stats.values.toList()
//       ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
//   }
//
//   List<DayStatusEntry> dayEntriesForStudent(String studentId) {
//     final List<DayStatusEntry> entries = [];
//     for (final doc in _monthDocs) {
//       final rec = doc.records[studentId];
//       if (rec == null) continue;
//       DateTime? d;
//       try {
//         d = DateTime.parse(doc.date);
//       } catch (_) {
//         continue;
//       }
//       entries.add(DayStatusEntry(date: d, status: rec.status));
//     }
//     entries.sort((a, b) => a.date.compareTo(b.date));
//     return entries;
//   }
//
//   StudentMonthStat? statFor(String studentId) {
//     try {
//       return _studentStats.firstWhere((s) => s.studentId == studentId);
//     } catch (_) {
//       return null;
//     }
//   }
//
//   void clear() {
//     _monthDocs = [];
//     _studentStats = [];
//     _cacheKey = null;
//     _daysMarkedInMonth = 0;
//     notifyListeners();
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/class_attendance_model.dart';

// ─────────────────────────────────────────────
//  Class Attendance REPORT Provider
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

class DayStatusEntry {
  final DateTime date;
  final AttendanceStatus status;
  DayStatusEntry({required this.date, required this.status});
}

/// One day's aggregated totals across the whole month, for a single
/// class+section — feeds the monthly trend line chart.
class DayAggregate {
  final DateTime date;
  final int present;
  final int absent;
  final int late;
  final int leave;
  final int halfDay;
  final int total;

  DayAggregate({
    required this.date,
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.halfDay,
    required this.total,
  });

  double get presentPct => total == 0 ? 0 : (present / total) * 100;
}

class ClassAttendanceReportProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'attendance';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _cacheKey;
  List<ClassAttendanceModel> _monthDocs = [];

  int _daysMarkedInMonth = 0;
  int get daysMarkedInMonth => _daysMarkedInMonth;

  List<StudentMonthStat> _studentStats = [];
  List<StudentMonthStat> get studentStats => _studentStats;

  /// Day-by-day totals for the currently loaded class+month — used by
  /// the monthly report's trend chart.
  List<DayAggregate> get monthDailyTrend => _monthDocs.map((doc) {
    DateTime d;
    try {
      d = DateTime.parse(doc.date);
    } catch (_) {
      d = DateTime.now();
    }
    return DayAggregate(
      date: d,
      present: doc.presentCount,
      absent: doc.absentCount,
      late: doc.lateCount,
      leave: doc.leaveCount,
      halfDay: doc.halfDayCount,
      total: doc.totalCount,
    );
  }).toList();

  // ---- All Classes — Today + 7-day trend ----
  bool _isLoadingToday = false;
  bool get isLoadingToday => _isLoadingToday;

  String? _todayError;
  String? get todayError => _todayError;

  List<ClassAttendanceModel> _todayDocs = [];
  List<ClassAttendanceModel> get todayDocs => _todayDocs;

  /// day -> {present, absent, late, leave, halfDay} summed across all classes
  List<MapEntry<DateTime, Map<String, int>>> _last7DaysTrend = [];
  List<MapEntry<DateTime, Map<String, int>>> get last7DaysTrend => _last7DaysTrend;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> loadClassMonth({
    required String classId,
    required String sectionId,
    required int year,
    required int month,
  }) async {
    final key = '${classId}_${sectionId}_${year}_$month';
    if (key == _cacheKey && !_isLoading) {
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

  /// Loads every class's attendance doc for today, PLUS the last 7 days
  /// (today included) across all classes, so the dashboard can show a
  /// trend line alongside today's snapshot.
  Future<void> loadAllClassesToday() async {
    _isLoadingToday = true;
    _todayError = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 6)); // 7 days inclusive

      final snap = await _db
          .collection(_collection)
          .where('date', isGreaterThanOrEqualTo: _dateStr(start))
          .where('date', isLessThanOrEqualTo: _dateStr(now))
          .get();

      final allDocs = snap.docs.map((d) => ClassAttendanceModel.fromFirestore(d)).toList();

      final todayStr = _dateStr(now);
      _todayDocs = allDocs.where((d) => d.date == todayStr).toList()
        ..sort((a, b) {
          final c = a.className.compareTo(b.className);
          if (c != 0) return c;
          return a.sectionName.compareTo(b.sectionName);
        });

      // Build the 7-day trend by summing every class's doc per day.
      final Map<String, Map<String, int>> byDay = {};
      for (final doc in allDocs) {
        final bucket = byDay.putIfAbsent(
          doc.date,
              () => {'present': 0, 'absent': 0, 'late': 0, 'leave': 0, 'halfDay': 0},
        );
        bucket['present'] = bucket['present']! + doc.presentCount;
        bucket['absent'] = bucket['absent']! + doc.absentCount;
        bucket['late'] = bucket['late']! + doc.lateCount;
        bucket['leave'] = bucket['leave']! + doc.leaveCount;
        bucket['halfDay'] = bucket['halfDay']! + doc.halfDayCount;
      }

      _last7DaysTrend = List.generate(7, (i) {
        final day = start.add(Duration(days: i));
        final key = _dateStr(day);
        final vals = byDay[key] ?? {'present': 0, 'absent': 0, 'late': 0, 'leave': 0, 'halfDay': 0};
        return MapEntry(day, vals);
      });
    } catch (e) {
      _todayError = 'Failed to load today\'s attendance: $e';
      _todayDocs = [];
      _last7DaysTrend = [];
    } finally {
      _isLoadingToday = false;
      notifyListeners();
    }
  }

  void clearToday() {
    _todayDocs = [];
    _last7DaysTrend = [];
    _todayError = null;
    notifyListeners();
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