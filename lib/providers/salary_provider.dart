//
// import 'package:flutter/foundation.dart';
// import '../models/salary_model.dart';
// import '../services/salary_firestore_service.dart';
// import '../services/attendance_firestore_service.dart';
//
// class SalaryProvider extends ChangeNotifier {
//   final SalaryFirestoreService _service = SalaryFirestoreService();
//   final AttendanceFirestoreService _attendanceService =
//   AttendanceFirestoreService();
//
//   // ───── Current calculation states (used by GenerateSalaryScreen) ─────
//   bool _calculating = false;
//   bool get calculating => _calculating;
//
//   int _lastPresentDays = 0;
//   int _lastHolidaysExcluded = 0;
//   int get lastPresentDays => _lastPresentDays;
//   int get lastHolidaysExcluded => _lastHolidaysExcluded;
//
//   static const int _kFixedMonthDays = 30;
//
//   // ───── Salary list states ─────
//   List<SalaryRecord> _salaries = [];
//   List<SalaryRecord> get salaries => _salaries;
//
//   bool _loadingSalaries = false;
//   bool get loadingSalaries => _loadingSalaries;
//
//   // ────────────────────────────────────────────────────────────
//   //  Attendance-based calculation (unchanged)
//   // ────────────────────────────────────────────────────────────
//   Future<Map<String, dynamic>> calculateAttendanceBased({
//     required String employeeId,
//     required double baseSalary,
//     required int year,
//     required int month,
//     double fine = 0,
//     double bonus = 0,
//   }) async {
//     _calculating = true;
//     notifyListeners();
//
//     try {
//       final monthStart = DateTime(year, month, 1);
//       final monthEnd = DateTime(year, month + 1, 0);
//
//       final startStr = _fmt(monthStart);
//       final endStr = _fmt(monthEnd);
//
//       final fetched = await _attendanceService.getAttendanceForStaffInRange(
//         staffId: employeeId,
//         startDate: startStr,
//         endDate: endStr,
//       );
//
//       final byDate = <String, String>{};
//       for (final rec in fetched) {
//         byDate[rec.date] = rec.status;
//       }
//
//       int absentCount = 0;
//       int presentCount = 0;
//       int holidayCount = 0;
//
//       var cursor = monthStart;
//       while (!cursor.isAfter(monthEnd)) {
//         final dateStr = _fmt(cursor);
//         final isSunday = cursor.weekday == DateTime.sunday;
//         final status = byDate[dateStr];
//
//         if (isSunday || status == 'holiday') {
//           holidayCount++;
//         } else if (status == null) {
//           absentCount++;
//         } else if (status == 'absent') {
//           absentCount++;
//         } else if (status == 'present') {
//           presentCount++;
//         } else {
//           presentCount++;
//         }
//
//         cursor = cursor.add(const Duration(days: 1));
//       }
//
//       _lastPresentDays = presentCount;
//       _lastHolidaysExcluded = holidayCount;
//
//       final perDayRate = baseSalary / _kFixedMonthDays;
//       final absentDeduction = perDayRate * absentCount;
//       final netSalary = baseSalary - absentDeduction - fine + bonus;
//
//       final result = <String, dynamic>{
//         'baseSalary': baseSalary,
//         'workingDays': _kFixedMonthDays,
//         'leaves': absentCount,
//         'perDayRate': perDayRate,
//         'absentDeduction': absentDeduction,
//         'fine': fine,
//         'bonus': bonus,
//         'netSalary': netSalary,
//       };
//
//       return result;
//     } finally {
//       _calculating = false;
//       notifyListeners();
//     }
//   }
//
//   // ────────────────────────────────────────────────────────────
//   //  Manual calculation — always uses fixed 30-day month
//   // ────────────────────────────────────────────────────────────
//   Map<String, dynamic> calculateManual({
//     required double baseSalary,
//     required int workingDays,
//     required int leaves,
//     double fine = 0,
//     double bonus = 0,
//   }) {
//     // Working days denominator is always fixed at 30, regardless of the
//     // actual calendar month length (28/29/30/31).
//     const safeWorkingDays = _kFixedMonthDays;
//     final perDayRate = baseSalary / safeWorkingDays;
//     final absentDeduction = perDayRate * leaves;
//     final netSalary = baseSalary - absentDeduction - fine + bonus;
//
//     return {
//       'baseSalary': baseSalary,
//       'workingDays': safeWorkingDays,
//       'leaves': leaves,
//       'perDayRate': perDayRate,
//       'absentDeduction': absentDeduction,
//       'fine': fine,
//       'bonus': bonus,
//       'netSalary': netSalary,
//     };
//   }
//
//   // ────────────────────────────────────────────────────────────
//   //  Duplicate check & save
//   // ────────────────────────────────────────────────────────────
//   Future<SalaryRecord?> checkAlreadyGenerated(
//       String employeeId, int year, int month) {
//     return _service.checkAlreadyGenerated(employeeId, year, month);
//   }
//
//   Future<void> saveSalary(SalaryRecord record) async {
//     await _service.saveSalary(record);
//   }
//
//   // ────────────────────────────────────────────────────────────
//   //  Salary list management
//   // ────────────────────────────────────────────────────────────
//   /// Load salaries for a specific month (used by list screen).
//   Future<void> fetchSalaries(int year, int month) async {
//     _loadingSalaries = true;
//     notifyListeners();
//
//     try {
//       _salaries = await _service.getSalariesByMonth(year, month);
//     } catch (e) {
//       _salaries = [];
//       debugPrint('Error fetching salaries: $e');
//     } finally {
//       _loadingSalaries = false;
//       notifyListeners();
//     }
//   }
//
//   /// Change status of a salary record (e.g., Pending -> Paid).
//   Future<void> updateSalaryStatus(String docId, String newStatus) async {
//     await _service.updateStatus(docId, newStatus);
//     // Update local list
//     final index = _salaries.indexWhere((s) => s.id == docId);
//     if (index != -1) {
//       _salaries[index] = SalaryRecord.fromMap(
//         {
//           ..._salaries[index].toMap(),
//           'status': newStatus,
//           if (newStatus == 'Paid') 'paidAt': DateTime.now(),
//         },
//         docId,
//       );
//       notifyListeners();
//     }
//   }
//
//   /// Update editable fields (fine, bonus, note) and optionally status.
//   Future<void> updateSalaryFields(
//       String docId, {
//         double? fine,
//         double? bonus,
//         String? note,
//         String? status,
//       }) async {
//     await _service.updateSalaryFields(
//       docId,
//       fine: fine,
//       bonus: bonus,
//       note: note,
//       status: status,
//     );
//     // Update local list
//     final index = _salaries.indexWhere((s) => s.id == docId);
//     if (index != -1) {
//       final current = _salaries[index];
//       // Recalculate net salary if fine or bonus changed
//       double newNet = current.netSalary;
//       if (fine != null || bonus != null) {
//         final f = fine ?? current.fine;
//         final b = bonus ?? current.bonus;
//         newNet = current.baseSalary - current.absentDeduction - f + b;
//       }
//       final updated = SalaryRecord(
//         id: docId,
//         employeeId: current.employeeId,
//         employeeName: current.employeeName,
//         employeeType: current.employeeType,
//         designation: current.designation,
//         year: current.year,
//         month: current.month,
//         mode: current.mode,
//         baseSalary: current.baseSalary,
//         totalDaysInMonth: current.totalDaysInMonth,
//         workingDays: current.workingDays,
//         leaves: current.leaves,
//         perDayRate: current.perDayRate,
//         absentDeduction: current.absentDeduction,
//         fine: fine ?? current.fine,
//         bonus: bonus ?? current.bonus,
//         note: note ?? current.note,
//         netSalary: newNet,
//         status: status ?? current.status,
//         createdAt: current.createdAt,
//         paidAt: status == 'Paid' ? DateTime.now() : current.paidAt,
//       );
//       _salaries[index] = updated;
//       notifyListeners();
//     }
//   }
//
//   /// Full record update — used by GenerateSalaryScreen's Edit Mode.
//   /// Recalculates workingDays/leaves/perDayRate/absentDeduction/netSalary
//   /// from the freshly-provided calculation result, but preserves the
//   /// original doc id, employee identity, month, status and createdAt.
//   Future<void> updateFullSalary({
//     required String docId,
//     required double baseSalary,
//     required int totalDaysInMonth,
//     required int workingDays,
//     required int leaves,
//     required double perDayRate,
//     required double absentDeduction,
//     required double fine,
//     required double bonus,
//     required double netSalary,
//     String? note,
//     required String mode,
//   }) async {
//     final updates = <String, dynamic>{
//       'baseSalary': baseSalary,
//       'totalDaysInMonth': totalDaysInMonth,
//       'workingDays': workingDays,
//       'leaves': leaves,
//       'perDayRate': perDayRate,
//       'absentDeduction': absentDeduction,
//       'fine': fine,
//       'bonus': bonus,
//       'note': note,
//       'netSalary': netSalary,
//       'mode': mode,
//     };
//     await _service.updateFullSalary(docId, updates);
//
//     // Update local list if present
//     final index = _salaries.indexWhere((s) => s.id == docId);
//     if (index != -1) {
//       final current = _salaries[index];
//       _salaries[index] = SalaryRecord(
//         id: docId,
//         employeeId: current.employeeId,
//         employeeName: current.employeeName,
//         employeeType: current.employeeType,
//         designation: current.designation,
//         year: current.year,
//         month: current.month,
//         mode: mode,
//         baseSalary: baseSalary,
//         totalDaysInMonth: totalDaysInMonth,
//         workingDays: workingDays,
//         leaves: leaves,
//         perDayRate: perDayRate,
//         absentDeduction: absentDeduction,
//         fine: fine,
//         bonus: bonus,
//         note: note,
//         netSalary: netSalary,
//         status: current.status,
//         createdAt: current.createdAt,
//         paidAt: current.paidAt,
//       );
//       notifyListeners();
//     }
//   }
//
//   /// Delete a salary record permanently.
//   Future<void> deleteSalary(String docId) async {
//     await _service.deleteSalary(docId);
//     _salaries.removeWhere((s) => s.id == docId);
//     notifyListeners();
//   }
//
//   // ────────────────────────────────────────────────────────────
//   //  Helper
//   // ────────────────────────────────────────────────────────────
//   String _fmt(DateTime d) =>
//       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
// }


import 'package:flutter/foundation.dart';
import '../models/salary_model.dart';
import '../models/teacher.dart';
import '../services/salary_firestore_service.dart';
import '../services/attendance_firestore_service.dart';
import '../services/firestore_service.dart';

class SalaryProvider extends ChangeNotifier {
  final SalaryFirestoreService _service = SalaryFirestoreService();
  final AttendanceFirestoreService _attendanceService =
  AttendanceFirestoreService();
  // ★ NEW – used to reinstate an employee (flip isTerminated back to false)
  // when their termination salary record is deleted from the Salary List.
  final StaffFirestoreService _staffService = StaffFirestoreService();

  // ───── Current calculation states (used by GenerateSalaryScreen) ─────
  bool _calculating = false;
  bool get calculating => _calculating;

  int _lastPresentDays = 0;
  int _lastHolidaysExcluded = 0;
  int get lastPresentDays => _lastPresentDays;
  int get lastHolidaysExcluded => _lastHolidaysExcluded;

  static const int _kFixedMonthDays = 30;

  // ───── Salary list states ─────
  List<SalaryRecord> _salaries = [];
  List<SalaryRecord> get salaries => _salaries;

  bool _loadingSalaries = false;
  bool get loadingSalaries => _loadingSalaries;

  // ────────────────────────────────────────────────────────────
  //  Attendance-based calculation (unchanged)
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
      final monthEnd = DateTime(year, month + 1, 0);

      final startStr = _fmt(monthStart);
      final endStr = _fmt(monthEnd);

      final fetched = await _attendanceService.getAttendanceForStaffInRange(
        staffId: employeeId,
        startDate: startStr,
        endDate: endStr,
      );

      final byDate = <String, String>{};
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
          absentCount++;
        } else if (status == 'absent') {
          absentCount++;
        } else if (status == 'present') {
          presentCount++;
        } else {
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
  //  Manual calculation — always uses fixed 30-day month
  // ────────────────────────────────────────────────────────────
  Map<String, dynamic> calculateManual({
    required double baseSalary,
    required int workingDays,
    required int leaves,
    double fine = 0,
    double bonus = 0,
  }) {
    // Working days denominator is always fixed at 30, regardless of the
    // actual calendar month length (28/29/30/31).
    const safeWorkingDays = _kFixedMonthDays;
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
  //  Duplicate check & save
  // ────────────────────────────────────────────────────────────
  Future<SalaryRecord?> checkAlreadyGenerated(
      String employeeId, int year, int month) {
    return _service.checkAlreadyGenerated(employeeId, year, month);
  }

  Future<void> saveSalary(SalaryRecord record) async {
    await _service.saveSalary(record);

    // ★ NEW – if this salary was generated with termination marked on,
    // flip the employee's isTerminated flag in Firestore so they
    // immediately disappear from the regular Teachers/Staff lists.
    if (record.isTerminated) {
      await _markEmployeeTerminated(record.employeeId, true);
    }
  }

  // ────────────────────────────────────────────────────────────
  //  Salary list management
  // ────────────────────────────────────────────────────────────
  /// Load salaries for a specific month (used by list screen).
  Future<void> fetchSalaries(int year, int month) async {
    _loadingSalaries = true;
    notifyListeners();

    try {
      _salaries = await _service.getSalariesByMonth(year, month);
    } catch (e) {
      _salaries = [];
      debugPrint('Error fetching salaries: $e');
    } finally {
      _loadingSalaries = false;
      notifyListeners();
    }
  }

  /// Change status of a salary record (e.g., Pending -> Paid).
  Future<void> updateSalaryStatus(String docId, String newStatus) async {
    await _service.updateStatus(docId, newStatus);
    // Update local list
    final index = _salaries.indexWhere((s) => s.id == docId);
    if (index != -1) {
      _salaries[index] = SalaryRecord.fromMap(
        {
          ..._salaries[index].toMap(),
          'status': newStatus,
          if (newStatus == 'Paid') 'paidAt': DateTime.now(),
        },
        docId,
      );
      notifyListeners();
    }
  }

  /// Update editable fields (fine, bonus, note) and optionally status.
  Future<void> updateSalaryFields(
      String docId, {
        double? fine,
        double? bonus,
        String? note,
        String? status,
      }) async {
    await _service.updateSalaryFields(
      docId,
      fine: fine,
      bonus: bonus,
      note: note,
      status: status,
    );
    // Update local list
    final index = _salaries.indexWhere((s) => s.id == docId);
    if (index != -1) {
      final current = _salaries[index];
      // Recalculate net salary if fine or bonus changed
      double newNet = current.netSalary;
      if (fine != null || bonus != null) {
        final f = fine ?? current.fine;
        final b = bonus ?? current.bonus;
        newNet = current.baseSalary - current.absentDeduction - f + b;
      }
      final updated = SalaryRecord(
        id: docId,
        employeeId: current.employeeId,
        employeeName: current.employeeName,
        employeeType: current.employeeType,
        designation: current.designation,
        year: current.year,
        month: current.month,
        mode: current.mode,
        baseSalary: current.baseSalary,
        totalDaysInMonth: current.totalDaysInMonth,
        workingDays: current.workingDays,
        leaves: current.leaves,
        perDayRate: current.perDayRate,
        absentDeduction: current.absentDeduction,
        fine: fine ?? current.fine,
        bonus: bonus ?? current.bonus,
        note: note ?? current.note,
        netSalary: newNet,
        status: status ?? current.status,
        isTerminated: current.isTerminated,
        createdAt: current.createdAt,
        paidAt: status == 'Paid' ? DateTime.now() : current.paidAt,
      );
      _salaries[index] = updated;
      notifyListeners();
    }
  }

  /// Full record update — used by GenerateSalaryScreen's Edit Mode.
  /// Recalculates workingDays/leaves/perDayRate/absentDeduction/netSalary
  /// from the freshly-provided calculation result, but preserves the
  /// original doc id, employee identity, month, status and createdAt.
  Future<void> updateFullSalary({
    required String docId,
    required double baseSalary,
    required int totalDaysInMonth,
    required int workingDays,
    required int leaves,
    required double perDayRate,
    required double absentDeduction,
    required double fine,
    required double bonus,
    required double netSalary,
    String? note,
    required String mode,
    bool? isTerminated, // ★ NEW – optional, only passed when edit screen allows toggling it
  }) async {
    final updates = <String, dynamic>{
      'baseSalary': baseSalary,
      'totalDaysInMonth': totalDaysInMonth,
      'workingDays': workingDays,
      'leaves': leaves,
      'perDayRate': perDayRate,
      'absentDeduction': absentDeduction,
      'fine': fine,
      'bonus': bonus,
      'note': note,
      'netSalary': netSalary,
      'mode': mode,
    };
    if (isTerminated != null) {
      updates['isTerminated'] = isTerminated;
    }
    await _service.updateFullSalary(docId, updates);

    // Update local list if present
    final index = _salaries.indexWhere((s) => s.id == docId);
    if (index != -1) {
      final current = _salaries[index];

      // ★ NEW – keep the employee's termination flag in Firestore in sync
      // with what was just saved on this record.
      if (isTerminated != null && isTerminated != current.isTerminated) {
        await _markEmployeeTerminated(current.employeeId, isTerminated);
      }

      _salaries[index] = SalaryRecord(
        id: docId,
        employeeId: current.employeeId,
        employeeName: current.employeeName,
        employeeType: current.employeeType,
        designation: current.designation,
        year: current.year,
        month: current.month,
        mode: mode,
        baseSalary: baseSalary,
        totalDaysInMonth: totalDaysInMonth,
        workingDays: workingDays,
        leaves: leaves,
        perDayRate: perDayRate,
        absentDeduction: absentDeduction,
        fine: fine,
        bonus: bonus,
        note: note,
        netSalary: netSalary,
        status: current.status,
        isTerminated: isTerminated ?? current.isTerminated,
        createdAt: current.createdAt,
        paidAt: current.paidAt,
      );
      notifyListeners();
    }
  }

  /// Delete a salary record permanently.
  /// ★ CHANGED — if the record being deleted was a termination record,
  /// the employee is automatically reinstated (isTerminated -> false),
  /// exactly like they were before termination.
  Future<void> deleteSalary(String docId) async {
    final index = _salaries.indexWhere((s) => s.id == docId);
    final record = index != -1 ? _salaries[index] : null;

    await _service.deleteSalary(docId);
    _salaries.removeWhere((s) => s.id == docId);
    notifyListeners();

    if (record != null && record.isTerminated) {
      await _markEmployeeTerminated(record.employeeId, false);
    }
  }

  // ────────────────────────────────────────────────────────────
  //  Helper: flip the employee's isTerminated flag in Firestore.
  //  Uses whichever collection (teachers/staff) currently holds the doc,
  //  same as StaffFirestoreService.updateStaff already does internally.
  // ────────────────────────────────────────────────────────────
  Future<void> _markEmployeeTerminated(String employeeId, bool terminated) async {
    try {
      final teachers = await _staffService.getTeachers();
      final staff = await _staffService.getStaffOnly();
      final all = [...teachers, ...staff];

      StaffMember? member;
      for (final m in all) {
        if (m.id == employeeId) {
          member = m;
          break;
        }
      }
      if (member == null) return;

      member.isTerminated = terminated;
      if (!terminated) {
        member.terminationDate = null;
        member.terminationNote = null;
      }
      await _staffService.updateStaff(employeeId, member);
    } catch (e) {
      debugPrint('Error syncing employee termination status: $e');
    }
  }

  // ────────────────────────────────────────────────────────────
  //  Helper
  // ────────────────────────────────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
