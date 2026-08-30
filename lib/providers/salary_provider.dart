//
// import 'package:flutter/foundation.dart';
// import '../models/salary_model.dart';
// import '../models/teacher.dart';
// import '../services/salary_firestore_service.dart';
// import '../services/attendance_firestore_service.dart';
// import '../services/firestore_service.dart';
// import '../providers/employee_transaction_provider.dart';
// import 'package:intl/intl.dart';
//
// class SalaryProvider extends ChangeNotifier {
//   final SalaryFirestoreService _service = SalaryFirestoreService();
//   final AttendanceFirestoreService _attendanceService =
//   AttendanceFirestoreService();
//   final StaffFirestoreService _staffService = StaffFirestoreService();
//
//   // ───── Current calculation states ─────
//   bool _calculating = false;
//   bool get calculating => _calculating;
//
//   int _lastPresentDays = 0;
//   int _lastHolidaysExcluded = 0;
//   int get lastPresentDays => _lastPresentDays;
//   int get lastHolidaysExcluded => _lastHolidaysExcluded;
//   String _fetchMode = 'month';
//   String get fetchMode => _fetchMode;
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
//   //  Attendance-based calculation
//   // ────────────────────────────────────────────────────────────
//
//   // ────────────────────────────────────────────────────────────
// //  Attendance‑based calculation (FIXED)
// // ────────────────────────────────────────────────────────────
//   Future<Map<String, dynamic>> calculateAttendanceBased({
//     required String employeeId,
//     required double baseSalary,
//     required int year,
//     required int month,
//     String? joiningDate,
//     double fine = 0,
//     double bonus = 0,
//   }) async {
//     _calculating = true;
//     notifyListeners();
//
//     try {
//       final monthStart = DateTime(year, month, 1);
//       final monthEnd = DateTime(year, month + 1, 0);
//       final daysInMonth = monthEnd.day;
//
//       // ── Determine employment days (calendar days in this month) ──
//       int employmentDays = 30; // default full month
//       DateTime effectiveStart = monthStart;
//
//       if (joiningDate != null && joiningDate.isNotEmpty) {
//         try {
//           final jd = DateTime.parse(joiningDate);
//           if (jd.year == year && jd.month == month) {
//             effectiveStart = DateTime(year, month, jd.day);
//             employmentDays = daysInMonth - jd.day + 1;
//           }
//         } catch (_) {}
//       }
//
//       // ── Fetch attendance for the range ──
//       final startStr = _fmt(effectiveStart);
//       final endStr = _fmt(monthEnd);
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
//       int holidayCount = 0;
//       // presentCount not needed for salary, but we keep it for UI if desired
//
//       var cursor = effectiveStart;
//       while (!cursor.isAfter(monthEnd)) {
//         final dateStr = _fmt(cursor);
//         final isSunday = cursor.weekday == DateTime.sunday;
//         final status = byDate[dateStr];
//
//         if (isSunday || status == 'holiday') {
//           holidayCount++;
//         } else if (status == null || status == 'absent') {
//           absentCount++;
//         }
//         // else present → no deduction
//         cursor = cursor.add(const Duration(days: 1));
//       }
//
//       _lastHolidaysExcluded = holidayCount;
//       // We don't store presentCount globally; you can if needed
//
//       final perDayRate = baseSalary / 30; // fixed 30‑day rate
//       final grossSalary = perDayRate * employmentDays;
//       final absentDeduction = perDayRate * absentCount;
//       final netSalary = grossSalary - absentDeduction - fine + bonus;
//
//       final result = <String, dynamic>{
//         'baseSalary': baseSalary,
//         'workingDays': employmentDays,       // UI shows employment days
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
// // ────────────────────────────────────────────────────────────
// //  Manual calculation (FIXED)
// // ────────────────────────────────────────────────────────────
//   Map<String, dynamic> calculateManual({
//     required double baseSalary,
//     required int leaves,
//     required int year,
//     required int month,
//     String? joiningDate,
//     double fine = 0,
//     double bonus = 0,
//   }) {
//     int employmentDays = 30;
//
//     if (joiningDate != null && joiningDate.isNotEmpty) {
//       try {
//         final jd = DateTime.parse(joiningDate);
//         if (jd.year == year && jd.month == month) {
//           final monthEnd = DateTime(year, month + 1, 0);
//           employmentDays = monthEnd.day - jd.day + 1;
//         }
//       } catch (_) {}
//     }
//
//     final perDayRate = baseSalary / 30;
//     final grossSalary = perDayRate * employmentDays;
//     final absentDeduction = perDayRate * leaves;
//     final netSalary = grossSalary - absentDeduction - fine + bonus;
//
//     return {
//       'baseSalary': baseSalary,
//       'workingDays': employmentDays,
//       'leaves': leaves,
//       'perDayRate': perDayRate,
//       'absentDeduction': absentDeduction,
//       'fine': fine,
//       'bonus': bonus,
//       'netSalary': netSalary,
//     };
//   }
//
//
//
//   Future<SalaryRecord?> checkAlreadyGenerated(
//       String employeeId, int year, int month) {
//     return _service.checkAlreadyGenerated(employeeId, year, month);
//   }
//
//   // Ledger note format used consistently everywhere the salary-deduction
//   // ledger credit entry is created/updated (new record, edit, etc.).
//   String _salaryLedgerNote(int year, int month) {
//     return 'Salary for ${DateFormat('MMM yyyy').format(DateTime(year, month))}';
//   }
//
//   // ★ FIXED — Save a NEW salary record.
//   // Previously `_service.saveSalary(record)` returned void, so `record.id`
//   // stayed null and `record.id!` threw inside the try/catch when syncing
//   // the ledger — meaning the ledger credit entry was silently never
//   // created. Now we capture the real Firestore doc ID first, rebuild the
//   // record with that ID (and the deduction fields so they're persisted),
//   // save it into `_salaries`, and THEN sync the ledger using the real ID.
//   //
//   // Returns the saved record (with its real id) so the caller can use it
//   // if needed (e.g. to show a snackbar with the correct id).
//   Future<SalaryRecord> saveSalary(
//       SalaryRecord record, {
//         StaffTransactionProvider? transactionProvider,
//         bool recordInLedger = true,
//         double? ledgerDeductionAmount,
//       }) async {
//     final newId = await _service.saveSalary(record.copyWith(
//       recordInLedger: recordInLedger,
//       ledgerDeductionAmount: ledgerDeductionAmount ?? 0,
//     ));
//
//     final savedRecord = record.copyWith(
//       id: newId,
//       recordInLedger: recordInLedger,
//       ledgerDeductionAmount: ledgerDeductionAmount ?? 0,
//     );
//
//     if (savedRecord.isTerminated) {
//       await _markEmployeeTerminated(
//         savedRecord.employeeId,
//         true,
//         year: savedRecord.year,
//         month: savedRecord.month,
//         generatedDate: savedRecord.generatedDate,
//       );
//     }
//
//     if (transactionProvider != null) {
//       final amountToDeduct = ledgerDeductionAmount ?? savedRecord.netSalary;
//       try {
//         await transactionProvider.syncSalaryDeduction(
//           employeeId: savedRecord.employeeId,
//           employeeName: savedRecord.employeeName,
//           employeeType: savedRecord.employeeType,
//           salaryRecordId: newId,
//           recordInLedger: recordInLedger,
//           amount: amountToDeduct,
//           date: savedRecord.generatedDate,
//           note: _salaryLedgerNote(savedRecord.year, savedRecord.month),
//         );
//       } catch (e) {
//         debugPrint('Error syncing salary deduction transaction: $e');
//       }
//     }
//
//     return savedRecord;
//   }
//
//   // ────────────────────────────────────────────────────────────
//   //  Salary list management
//   // ────────────────────────────────────────────────────────────
//   Future<void> fetchSalaries(int year, int month) async {
//     _loadingSalaries = true;
//     notifyListeners();
//
//     try {
//       _salaries = await _service.getSalariesByMonth(year, month);
//       _fetchMode = 'month';
//     } catch (e) {
//       _salaries = [];
//       debugPrint('Error fetching salaries: $e');
//     } finally {
//       _loadingSalaries = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchSalariesByYear(int year) async {
//     _loadingSalaries = true;
//     notifyListeners();
//
//     try {
//       _salaries = await _service.getSalariesByYear(year);
//       _fetchMode = 'year';
//     } catch (e) {
//       _salaries = [];
//       debugPrint('Error fetching salaries by year: $e');
//     } finally {
//       _loadingSalaries = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchAllSalaries() async {
//     _loadingSalaries = true;
//     notifyListeners();
//
//     try {
//       _salaries = await _service.getAllSalaries();
//       _fetchMode = 'all';
//     } catch (e) {
//       _salaries = [];
//       debugPrint('Error fetching all salaries: $e');
//     } finally {
//       _loadingSalaries = false;
//       notifyListeners();
//     }
//   }
//
//
//
//   Future<void> updateSalaryStatus(String docId, String newStatus) async {
//     await _service.updateStatus(docId, newStatus);
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
//     final index = _salaries.indexWhere((s) => s.id == docId);
//     if (index != -1) {
//       final current = _salaries[index];
//       double newNet = current.netSalary;
//       if (fine != null || bonus != null) {
//         final f = fine ?? current.fine;
//         final b = bonus ?? current.bonus;
//         newNet = current.baseSalary - current.absentDeduction - f + b;
//       }
//       final updated = current.copyWith(
//         id: docId,
//         fine: fine,
//         bonus: bonus,
//         note: note,
//         netSalary: newNet,
//         status: status,
//         paidAt: status == 'Paid' ? DateTime.now() : current.paidAt,
//       );
//       _salaries[index] = updated;
//       notifyListeners();
//     }
//   }
//
//   // ★ UPDATED — now accepts the transaction provider + ledger toggle/amount
//   // so that editing a salary record keeps its linked ledger credit entry
//   // in sync, AND persists recordInLedger/ledgerDeductionAmount onto the
//   // salary record itself so the List/Detail screens can display it.
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
//     bool? isTerminated,
//     DateTime? generatedDate,
//     StaffTransactionProvider? transactionProvider,
//     bool? recordInLedger, // null means "don't touch the ledger toggle"
//     double? ledgerDeductionAmount,
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
//     if (isTerminated != null) {
//       updates['isTerminated'] = isTerminated;
//     }
//     if (generatedDate != null) {
//       updates['generatedDate'] = generatedDate.toIso8601String();
//     }
//     // ★ NEW — persist the deduction toggle/amount whenever the caller
//     // actually touched that section (recordInLedger != null). This is
//     // what makes the Salary List / Detail screens able to show the
//     // "Balance Deduction" figure after editing.
//     if (recordInLedger != null) {
//       updates['recordInLedger'] = recordInLedger;
//       updates['ledgerDeductionAmount'] =
//       recordInLedger ? (ledgerDeductionAmount ?? 0) : 0;
//     }
//
//     await _service.updateFullSalary(docId, updates);
//
//     final index = _salaries.indexWhere((s) => s.id == docId);
//     if (index != -1) {
//       final current = _salaries[index];
//
//       if (isTerminated != null && isTerminated != current.isTerminated) {
//         await _markEmployeeTerminated(
//           current.employeeId,
//           isTerminated,
//           year: current.year,
//           month: current.month,
//           generatedDate: generatedDate ?? current.generatedDate,
//         );
//       }
//
//       final updatedRecord = current.copyWith(
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
//         isTerminated: isTerminated,
//         generatedDate: generatedDate,
//         recordInLedger: recordInLedger,
//         ledgerDeductionAmount: recordInLedger != null
//             ? (recordInLedger ? (ledgerDeductionAmount ?? 0) : 0)
//             : current.ledgerDeductionAmount,
//       );
//
//       _salaries[index] = updatedRecord;
//       notifyListeners();
//
//       // Keep the ledger credit entry linked to this salary record in sync.
//       // recordInLedger == null means the caller didn't touch the
//       // deduction section at all, so we skip ledger sync entirely.
//       if (transactionProvider != null && recordInLedger != null) {
//         final amountToDeduct = ledgerDeductionAmount ?? netSalary;
//         try {
//           await transactionProvider.syncSalaryDeduction(
//             employeeId: updatedRecord.employeeId,
//             employeeName: updatedRecord.employeeName,
//             employeeType: updatedRecord.employeeType,
//             salaryRecordId: docId,
//             recordInLedger: recordInLedger,
//             amount: amountToDeduct,
//             date: updatedRecord.generatedDate,
//             note: _salaryLedgerNote(updatedRecord.year, updatedRecord.month),
//           );
//         } catch (e) {
//           debugPrint('Error syncing salary deduction transaction on edit: $e');
//         }
//       }
//     }
//   }
//
//   // Also removes the linked ledger credit entry (if any) when a salary
//   // record is deleted, so deleting salary always cleans up the ledger too.
//   Future<void> deleteSalary(
//       String docId, {
//         StaffTransactionProvider? transactionProvider,
//       }) async {
//     final index = _salaries.indexWhere((s) => s.id == docId);
//     final record = index != -1 ? _salaries[index] : null;
//
//     await _service.deleteSalary(docId);
//     _salaries.removeWhere((s) => s.id == docId);
//     notifyListeners();
//
//     if (record != null && record.isTerminated) {
//       await _markEmployeeTerminated(record.employeeId, false);
//     }
//
//     if (record != null && transactionProvider != null) {
//       try {
//         await transactionProvider.deleteSalaryDeductionForRecord(
//           employeeId: record.employeeId,
//           salaryRecordId: docId,
//         );
//       } catch (e) {
//         debugPrint('Error deleting linked ledger transaction: $e');
//       }
//     }
//   }
//
//   // ────────────────────────────────────────────────────────────
//   //  Helper: flip employee's isTerminated flag in Firestore
//   // ────────────────────────────────────────────────────────────
//   Future<void> _markEmployeeTerminated(
//       String employeeId,
//       bool terminated, {
//         int? year,
//         int? month,
//         DateTime? generatedDate,
//       }) async {
//     try {
//       final teachers = await _staffService.getTeachers();
//       final staff = await _staffService.getStaffOnly();
//       final all = [...teachers, ...staff];
//
//       StaffMember? member;
//       for (final m in all) {
//         if (m.id == employeeId) {
//           member = m;
//           break;
//         }
//       }
//       if (member == null) return;
//
//       final String dateStr = generatedDate != null
//           ? _fmt(generatedDate)
//           : DateTime.now().toIso8601String().split('T').first;
//
//       if (terminated) {
//         if (member.statusHistory.isEmpty) {
//           member.statusHistory.add(
//             StatusEvent(
//               type: 'joined',
//               date: (member.joiningDate != null && member.joiningDate!.isNotEmpty)
//                   ? member.joiningDate!
//                   : dateStr,
//             ),
//           );
//         }
//
//         member.isTerminated = true;
//         member.isActive = false;
//         member.terminationDate = dateStr;
//
//         member.statusHistory.removeWhere((e) =>
//         e.type == 'terminated' && e.date == dateStr
//         );
//         member.statusHistory.add(
//           StatusEvent(type: 'terminated', date: dateStr, note: 'Terminated via salary generation'),
//         );
//       } else {
//         member.isTerminated = false;
//         member.isActive = true;
//         member.terminationDate = null;
//         member.terminationNote = null;
//
//         member.statusHistory.removeWhere((e) =>
//         e.type == 'rejoined' && e.date == dateStr
//         );
//         member.statusHistory.add(
//           StatusEvent(type: 'rejoined', date: dateStr, note: 'Reinstated from salary record deletion'),
//         );
//       }
//
//       await _staffService.updateStaff(employeeId, member);
//     } catch (e) {
//       debugPrint('Error syncing employee termination status: $e');
//     }
//   }
//
//   String _fmt(DateTime d) =>
//       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
// }




import 'package:flutter/foundation.dart';
import '../models/salary_model.dart';
import '../models/teacher.dart';
import '../services/salary_firestore_service.dart';
import '../services/attendance_firestore_service.dart';
import '../services/firestore_service.dart';
import '../providers/employee_transaction_provider.dart';
import 'package:intl/intl.dart';

class SalaryProvider extends ChangeNotifier {
  final SalaryFirestoreService _service = SalaryFirestoreService();
  final AttendanceFirestoreService _attendanceService =
  AttendanceFirestoreService();
  final StaffFirestoreService _staffService = StaffFirestoreService();

  // ───── Current calculation states ─────
  bool _calculating = false;
  bool get calculating => _calculating;

  int _lastPresentDays = 0;
  int _lastHolidaysExcluded = 0;
  int get lastPresentDays => _lastPresentDays;
  int get lastHolidaysExcluded => _lastHolidaysExcluded;

  // ★ NEW — tracks which fetch mode is currently active, so the UI can
  // know whether the list came from a specific month, a whole year
  // ("All Months"), or everything ("Overall").
  String _fetchMode = 'month';
  String get fetchMode => _fetchMode;

  static const int _kFixedMonthDays = 30;

  // ───── Salary list states ─────
  List<SalaryRecord> _salaries = [];
  List<SalaryRecord> get salaries => _salaries;

  List<SalaryRecord> get pendingSalaries =>
      _salaries.where((s) => s.status == 'Pending').toList();

  bool _loadingSalaries = false;
  bool get loadingSalaries => _loadingSalaries;

  // ────────────────────────────────────────────────────────────
  //  Attendance-based calculation
  // ────────────────────────────────────────────────────────────

  // ────────────────────────────────────────────────────────────
//  Attendance‑based calculation (FIXED)
// ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> calculateAttendanceBased({
    required String employeeId,
    required double baseSalary,
    required int year,
    required int month,
    String? joiningDate,
    double fine = 0,
    double bonus = 0,
  }) async {
    _calculating = true;
    notifyListeners();

    try {
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0);
      final daysInMonth = monthEnd.day;

      // ── Determine employment days (calendar days in this month) ──
      int employmentDays = 30; // default full month
      DateTime effectiveStart = monthStart;

      if (joiningDate != null && joiningDate.isNotEmpty) {
        try {
          final jd = DateTime.parse(joiningDate);
          if (jd.year == year && jd.month == month) {
            effectiveStart = DateTime(year, month, jd.day);
            employmentDays = daysInMonth - jd.day + 1;
          }
        } catch (_) {}
      }

      // ── Fetch attendance for the range ──
      final startStr = _fmt(effectiveStart);
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
      int holidayCount = 0;
      // presentCount not needed for salary, but we keep it for UI if desired

      var cursor = effectiveStart;
      while (!cursor.isAfter(monthEnd)) {
        final dateStr = _fmt(cursor);
        final isSunday = cursor.weekday == DateTime.sunday;
        final status = byDate[dateStr];

        if (isSunday || status == 'holiday') {
          holidayCount++;
        } else if (status == null || status == 'absent') {
          absentCount++;
        }
        // else present → no deduction
        cursor = cursor.add(const Duration(days: 1));
      }

      _lastHolidaysExcluded = holidayCount;
      // We don't store presentCount globally; you can if needed

      final perDayRate = baseSalary / 30; // fixed 30‑day rate
      final grossSalary = perDayRate * employmentDays;
      final absentDeduction = perDayRate * absentCount;
      final netSalary = grossSalary - absentDeduction - fine + bonus;

      final result = <String, dynamic>{
        'baseSalary': baseSalary,
        'workingDays': employmentDays,       // UI shows employment days
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
//  Manual calculation (FIXED)
// ────────────────────────────────────────────────────────────
  Map<String, dynamic> calculateManual({
    required double baseSalary,
    required int leaves,
    required int year,
    required int month,
    String? joiningDate,
    double fine = 0,
    double bonus = 0,
  }) {
    int employmentDays = 30;

    if (joiningDate != null && joiningDate.isNotEmpty) {
      try {
        final jd = DateTime.parse(joiningDate);
        if (jd.year == year && jd.month == month) {
          final monthEnd = DateTime(year, month + 1, 0);
          employmentDays = monthEnd.day - jd.day + 1;
        }
      } catch (_) {}
    }

    final perDayRate = baseSalary / 30;
    final grossSalary = perDayRate * employmentDays;
    final absentDeduction = perDayRate * leaves;
    final netSalary = grossSalary - absentDeduction - fine + bonus;

    return {
      'baseSalary': baseSalary,
      'workingDays': employmentDays,
      'leaves': leaves,
      'perDayRate': perDayRate,
      'absentDeduction': absentDeduction,
      'fine': fine,
      'bonus': bonus,
      'netSalary': netSalary,
    };
  }

  Future<SalaryRecord?> checkAlreadyGenerated(
      String employeeId, int year, int month) {
    return _service.checkAlreadyGenerated(employeeId, year, month);
  }

  // Ledger note format used consistently everywhere the salary-deduction
  // ledger credit entry is created/updated (new record, edit, etc.).
  String _salaryLedgerNote(int year, int month) {
    return 'Salary for ${DateFormat('MMM yyyy').format(DateTime(year, month))}';
  }

  // ★ FIXED — Save a NEW salary record.
  // Previously `_service.saveSalary(record)` returned void, so `record.id`
  // stayed null and `record.id!` threw inside the try/catch when syncing
  // the ledger — meaning the ledger credit entry was silently never
  // created. Now we capture the real Firestore doc ID first, rebuild the
  // record with that ID (and the deduction fields so they're persisted),
  // save it into `_salaries`, and THEN sync the ledger using the real ID.
  //
  // Returns the saved record (with its real id) so the caller can use it
  // if needed (e.g. to show a snackbar with the correct id).
  Future<SalaryRecord> saveSalary(
      SalaryRecord record, {
        StaffTransactionProvider? transactionProvider,
        bool recordInLedger = true,
        double? ledgerDeductionAmount,
      }) async {
    final newId = await _service.saveSalary(record.copyWith(
      recordInLedger: recordInLedger,
      ledgerDeductionAmount: ledgerDeductionAmount ?? 0,
    ));

    final savedRecord = record.copyWith(
      id: newId,
      recordInLedger: recordInLedger,
      ledgerDeductionAmount: ledgerDeductionAmount ?? 0,
    );

    if (savedRecord.isTerminated) {
      await _markEmployeeTerminated(
        savedRecord.employeeId,
        true,
        year: savedRecord.year,
        month: savedRecord.month,
        generatedDate: savedRecord.generatedDate,
      );
    }

    if (transactionProvider != null) {
      final amountToDeduct = ledgerDeductionAmount ?? savedRecord.netSalary;
      try {
        await transactionProvider.syncSalaryDeduction(
          employeeId: savedRecord.employeeId,
          employeeName: savedRecord.employeeName,
          employeeType: savedRecord.employeeType,
          salaryRecordId: newId,
          recordInLedger: recordInLedger,
          amount: amountToDeduct,
          date: savedRecord.generatedDate,
          note: _salaryLedgerNote(savedRecord.year, savedRecord.month),
        );
      } catch (e) {
        debugPrint('Error syncing salary deduction transaction: $e');
      }
    }

    return savedRecord;
  }

  // ────────────────────────────────────────────────────────────
  //  Salary list management
  // ────────────────────────────────────────────────────────────

  /// Fetch salaries for a specific year + month (existing behavior).
  Future<void> fetchSalaries(int year, int month) async {
    _loadingSalaries = true;
    notifyListeners();

    try {
      _salaries = await _service.getSalariesByMonth(year, month);
      _fetchMode = 'month';
    } catch (e) {
      _salaries = [];
      debugPrint('Error fetching salaries: $e');
    } finally {
      _loadingSalaries = false;
      notifyListeners();
    }
  }

  /// ★ NEW — Fetch salaries for "All Months" within a specific year.
  /// Year filter still applies; month is ignored.
  Future<void> fetchSalariesByYear(int year) async {
    _loadingSalaries = true;
    notifyListeners();

    try {
      _salaries = await _service.getSalariesByYear(year);
      _fetchMode = 'year';
    } catch (e) {
      _salaries = [];
      debugPrint('Error fetching salaries by year: $e');
    } finally {
      _loadingSalaries = false;
      notifyListeners();
    }
  }

  /// ★ NEW — Fetch every salary record across all years and months.
  /// Used by the "Overall" button, bypassing year/month filters entirely.
  Future<void> fetchAllSalaries() async {
    _loadingSalaries = true;
    notifyListeners();

    try {
      _salaries = await _service.getAllSalaries();
      _fetchMode = 'all';
    } catch (e) {
      _salaries = [];
      debugPrint('Error fetching all salaries: $e');
    } finally {
      _loadingSalaries = false;
      notifyListeners();
    }
  }

  Future<void> updateSalaryStatus(String docId, String newStatus) async {
    await _service.updateStatus(docId, newStatus);
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
    final index = _salaries.indexWhere((s) => s.id == docId);
    if (index != -1) {
      final current = _salaries[index];
      double newNet = current.netSalary;
      if (fine != null || bonus != null) {
        final f = fine ?? current.fine;
        final b = bonus ?? current.bonus;
        newNet = current.baseSalary - current.absentDeduction - f + b;
      }
      final updated = current.copyWith(
        id: docId,
        fine: fine,
        bonus: bonus,
        note: note,
        netSalary: newNet,
        status: status,
        paidAt: status == 'Paid' ? DateTime.now() : current.paidAt,
      );
      _salaries[index] = updated;
      notifyListeners();
    }
  }

  // ★ UPDATED — now accepts the transaction provider + ledger toggle/amount
  // so that editing a salary record keeps its linked ledger credit entry
  // in sync, AND persists recordInLedger/ledgerDeductionAmount onto the
  // salary record itself so the List/Detail screens can display it.
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
    bool? isTerminated,
    DateTime? generatedDate,
    StaffTransactionProvider? transactionProvider,
    bool? recordInLedger, // null means "don't touch the ledger toggle"
    double? ledgerDeductionAmount,
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
    if (generatedDate != null) {
      updates['generatedDate'] = generatedDate.toIso8601String();
    }
    // ★ NEW — persist the deduction toggle/amount whenever the caller
    // actually touched that section (recordInLedger != null). This is
    // what makes the Salary List / Detail screens able to show the
    // "Balance Deduction" figure after editing.
    if (recordInLedger != null) {
      updates['recordInLedger'] = recordInLedger;
      updates['ledgerDeductionAmount'] =
      recordInLedger ? (ledgerDeductionAmount ?? 0) : 0;
    }

    await _service.updateFullSalary(docId, updates);

    final index = _salaries.indexWhere((s) => s.id == docId);
    if (index != -1) {
      final current = _salaries[index];

      if (isTerminated != null && isTerminated != current.isTerminated) {
        await _markEmployeeTerminated(
          current.employeeId,
          isTerminated,
          year: current.year,
          month: current.month,
          generatedDate: generatedDate ?? current.generatedDate,
        );
      }

      final updatedRecord = current.copyWith(
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
        isTerminated: isTerminated,
        generatedDate: generatedDate,
        recordInLedger: recordInLedger,
        ledgerDeductionAmount: recordInLedger != null
            ? (recordInLedger ? (ledgerDeductionAmount ?? 0) : 0)
            : current.ledgerDeductionAmount,
      );

      _salaries[index] = updatedRecord;
      notifyListeners();

      // Keep the ledger credit entry linked to this salary record in sync.
      // recordInLedger == null means the caller didn't touch the
      // deduction section at all, so we skip ledger sync entirely.
      if (transactionProvider != null && recordInLedger != null) {
        final amountToDeduct = ledgerDeductionAmount ?? netSalary;
        try {
          await transactionProvider.syncSalaryDeduction(
            employeeId: updatedRecord.employeeId,
            employeeName: updatedRecord.employeeName,
            employeeType: updatedRecord.employeeType,
            salaryRecordId: docId,
            recordInLedger: recordInLedger,
            amount: amountToDeduct,
            date: updatedRecord.generatedDate,
            note: _salaryLedgerNote(updatedRecord.year, updatedRecord.month),
          );
        } catch (e) {
          debugPrint('Error syncing salary deduction transaction on edit: $e');
        }
      }
    }
  }

  // Also removes the linked ledger credit entry (if any) when a salary
  // record is deleted, so deleting salary always cleans up the ledger too.
  Future<void> deleteSalary(
      String docId, {
        StaffTransactionProvider? transactionProvider,
      }) async {
    final index = _salaries.indexWhere((s) => s.id == docId);
    final record = index != -1 ? _salaries[index] : null;

    await _service.deleteSalary(docId);
    _salaries.removeWhere((s) => s.id == docId);
    notifyListeners();

    if (record != null && record.isTerminated) {
      await _markEmployeeTerminated(record.employeeId, false);
    }

    if (record != null && transactionProvider != null) {
      try {
        await transactionProvider.deleteSalaryDeductionForRecord(
          employeeId: record.employeeId,
          salaryRecordId: docId,
        );
      } catch (e) {
        debugPrint('Error deleting linked ledger transaction: $e');
      }
    }
  }

  // ────────────────────────────────────────────────────────────
  //  Helper: flip employee's isTerminated flag in Firestore
  // ────────────────────────────────────────────────────────────
  Future<void> _markEmployeeTerminated(
      String employeeId,
      bool terminated, {
        int? year,
        int? month,
        DateTime? generatedDate,
      }) async {
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

      final String dateStr = generatedDate != null
          ? _fmt(generatedDate)
          : DateTime.now().toIso8601String().split('T').first;

      if (terminated) {
        if (member.statusHistory.isEmpty) {
          member.statusHistory.add(
            StatusEvent(
              type: 'joined',
              date: (member.joiningDate != null && member.joiningDate!.isNotEmpty)
                  ? member.joiningDate!
                  : dateStr,
            ),
          );
        }

        member.isTerminated = true;
        member.isActive = false;
        member.terminationDate = dateStr;

        member.statusHistory.removeWhere((e) =>
        e.type == 'terminated' && e.date == dateStr
        );
        member.statusHistory.add(
          StatusEvent(type: 'terminated', date: dateStr, note: 'Terminated via salary generation'),
        );
      } else {
        member.isTerminated = false;
        member.isActive = true;
        member.terminationDate = null;
        member.terminationNote = null;

        member.statusHistory.removeWhere((e) =>
        e.type == 'rejoined' && e.date == dateStr
        );
        member.statusHistory.add(
          StatusEvent(type: 'rejoined', date: dateStr, note: 'Reinstated from salary record deletion'),
        );
      }

      await _staffService.updateStaff(employeeId, member);
    } catch (e) {
      debugPrint('Error syncing employee termination status: $e');
    }
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}