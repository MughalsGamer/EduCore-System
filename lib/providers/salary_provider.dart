import 'package:flutter/foundation.dart';

import '../models/salary_model.dart';
import '../services/salary_firestore_service.dart';
import '../services/attendance_firestore_service.dart';

class SalaryProvider extends ChangeNotifier {
  final SalaryFirestoreService _service = SalaryFirestoreService();
  final AttendanceFirestoreService _attendanceService =
  AttendanceFirestoreService();

  bool _calculating = false;
  bool get calculating => _calculating;

  // Informational stats from the last attendance-based calculation,
  // surfaced by the screen's "Present / Holidays" mini-stats row.
  int _lastPresentDays = 0;
  int _lastHolidaysExcluded = 0;
  int get lastPresentDays => _lastPresentDays;
  int get lastHolidaysExcluded => _lastHolidaysExcluded;

  static const int _kFixedMonthDays = 30;

  // ────────────────────────────────────────────────────────────
  //  OPTION A — Attendance-based calculation
  //
  //  Rules:
  //  - Every month is treated as a fixed 30-day month for the purpose
  //    of the per-day rate, regardless of the actual calendar length
  //    (28/29/30/31 days).
  //  - Sundays (and any day marked 'holiday') are excluded entirely —
  //    they never count as absent, and are not part of the deduction
  //    calculation either way.
  //  - Only a status of exactly 'absent' counts as a deduction day.
  //    'late', 'half_day', and 'leave' are treated as full pay (no
  //    deduction) — per explicit instruction.
  //  - Any calendar day (non-Sunday) in the month with NO Firestore
  //    attendance record at all is treated as 'absent' — whether that's
  //    because a single day was never marked, or because attendance was
  //    never taken for the whole month.
  // ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> calculateAttendanceBased({
    required String employeeId,
    required double baseSalary,
    required int year,
    required int month,
    double fine = 0,
    double bonus = 0,
  }) async {
    _calculating = true;
    notifyListeners();

    try {
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0); // last calendar day

      final startStr = _fmt(monthStart);
      final endStr = _fmt(monthEnd);

      // Reuse the existing service method — same one used by
      // AttendanceProvider.loadHistoryForPerson.
      final fetched = await _attendanceService.getAttendanceForStaffInRange(
        staffId: employeeId,
        startDate: startStr,
        endDate: endStr,
      );

      final byDate = <String, String>{}; // date -> status
      for (final rec in fetched) {
        byDate[rec.date] = rec.status;
      }

      int absentCount = 0;
      int presentCount = 0;
      int holidayCount = 0;

      var cursor = monthStart;
      while (!cursor.isAfter(monthEnd)) {
        final dateStr = _fmt(cursor);
        final isSunday = cursor.weekday == DateTime.sunday;
        final status = byDate[dateStr];

        if (isSunday || status == 'holiday') {
          holidayCount++;
        } else if (status == null) {
          // No record at all for this day → absent, per rule.
          absentCount++;
        } else if (status == 'absent') {
          absentCount++;
        } else if (status == 'present') {
          presentCount++;
        } else {
          // late / half_day / leave → full pay, no deduction.
          presentCount++;
        }

        cursor = cursor.add(const Duration(days: 1));
      }

      _lastPresentDays = presentCount;
      _lastHolidaysExcluded = holidayCount;

      final perDayRate = baseSalary / _kFixedMonthDays;
      final absentDeduction = perDayRate * absentCount;
      final netSalary = baseSalary - absentDeduction - fine + bonus;

      final result = <String, dynamic>{
        'baseSalary': baseSalary,
        'workingDays': _kFixedMonthDays,
        'leaves': absentCount,
        'perDayRate': perDayRate,
        'absentDeduction': absentDeduction,
        'fine': fine,
        'bonus': bonus,
        'netSalary': netSalary,
      };

      return result;
    } finally {
      _calculating = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────────────────
  //  OPTION B — Manual entry calculation
  //  User supplies working days & leaves directly; same per-day-rate
  //  formula, denominator is whatever the user entered (defaults to 30).
  // ────────────────────────────────────────────────────────────
  Map<String, dynamic> calculateManual({
    required double baseSalary,
    required int workingDays,
    required int leaves,
    double fine = 0,
    double bonus = 0,
  }) {
    final safeWorkingDays = workingDays <= 0 ? 30 : workingDays;
    final perDayRate = baseSalary / safeWorkingDays;
    final absentDeduction = perDayRate * leaves;
    final netSalary = baseSalary - absentDeduction - fine + bonus;

    return {
      'baseSalary': baseSalary,
      'workingDays': safeWorkingDays,
      'leaves': leaves,
      'perDayRate': perDayRate,
      'absentDeduction': absentDeduction,
      'fine': fine,
      'bonus': bonus,
      'netSalary': netSalary,
    };
  }

  // ────────────────────────────────────────────────────────────
  //  Duplicate-generation guard: one record per employee+year+month.
  // ────────────────────────────────────────────────────────────
  Future<SalaryRecord?> checkAlreadyGenerated(
      String employeeId, int year, int month) {
    return _service.checkAlreadyGenerated(employeeId, year, month);
  }

  Future<void> saveSalary(SalaryRecord record) async {
    await _service.saveSalary(record);
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}