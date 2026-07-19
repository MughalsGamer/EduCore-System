//
//
// import 'package:flutter/foundation.dart';
// import '../models/salary_model.dart';
// import '../models/teacher.dart';
// import '../services/salary_firestore_service.dart';
// import '../services/attendance_firestore_service.dart';
// import '../services/firestore_service.dart';
//
// class SalaryProvider extends ChangeNotifier {
//   final SalaryFirestoreService _service = SalaryFirestoreService();
//   final AttendanceFirestoreService _attendanceService =
//   AttendanceFirestoreService();
//   // ★ NEW – used to reinstate an employee (flip isTerminated back to false)
//   // when their termination salary record is deleted from the Salary List.
//   final StaffFirestoreService _staffService = StaffFirestoreService();
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
//
//
//   Future<void> saveSalary(SalaryRecord record) async {
//     await _service.saveSalary(record);
//
//     if (record.isTerminated) {
//       await _markEmployeeTerminated(
//         record.employeeId,
//         true,
//         year: record.year,
//         month: record.month,
//         generatedDate: record.generatedDate, // ★ PASS the generated date
//       );
//     }
//   }
//   // Future<void> saveSalary(SalaryRecord record) async {
//   //   await _service.saveSalary(record);
//   //
//   //   // ★ NEW – if this salary was generated with termination marked on,
//   //   // flip the employee's isTerminated flag in Firestore so they
//   //   // immediately disappear from the regular Teachers/Staff lists.
//   //   // ★ FIX – also pass along the salary's year/month so the employee's
//   //   // terminationDate gets set correctly (previously only isTerminated was
//   //   // flipped, leaving terminationDate blank — that's why Staff Profile
//   //   // showed no "Terminated" date when termination happened from this
//   //   // screen, even though it worked fine from the list's Deactivate flow).
//   //   if (record.isTerminated) {
//   //     await _markEmployeeTerminated(
//   //       record.employeeId,
//   //       true,
//   //       year: record.year,
//   //       month: record.month,
//   //     );
//   //   }
//   // }
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
//         isTerminated: current.isTerminated,
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
//     bool? isTerminated,
//     DateTime? generatedDate, // ★ NEW
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
//     // ★ NEW: Update generatedDate if provided
//     if (generatedDate != null) {
//       updates['generatedDate'] = generatedDate.toIso8601String();
//     }
//     await _service.updateFullSalary(docId, updates);
//
//     // Update local list if present
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
//           generatedDate: generatedDate ?? current.generatedDate, // ★ PASS generated date
//         );
//       }
//
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
//         isTerminated: isTerminated ?? current.isTerminated,
//         generatedDate: generatedDate ?? current.generatedDate, // ★ NEW
//         createdAt: current.createdAt,
//         paidAt: current.paidAt,
//       );
//       notifyListeners();
//     }
//   }
//   // Future<void> updateFullSalary({
//   //   required String docId,
//   //   required double baseSalary,
//   //   required int totalDaysInMonth,
//   //   required int workingDays,
//   //   required int leaves,
//   //   required double perDayRate,
//   //   required double absentDeduction,
//   //   required double fine,
//   //   required double bonus,
//   //   required double netSalary,
//   //   String? note,
//   //   required String mode,
//   //   bool? isTerminated, // ★ NEW – optional, only passed when edit screen allows toggling it
//   // }) async
//   // {
//   //   final updates = <String, dynamic>{
//   //     'baseSalary': baseSalary,
//   //     'totalDaysInMonth': totalDaysInMonth,
//   //     'workingDays': workingDays,
//   //     'leaves': leaves,
//   //     'perDayRate': perDayRate,
//   //     'absentDeduction': absentDeduction,
//   //     'fine': fine,
//   //     'bonus': bonus,
//   //     'note': note,
//   //     'netSalary': netSalary,
//   //     'mode': mode,
//   //   };
//   //   if (isTerminated != null) {
//   //     updates['isTerminated'] = isTerminated;
//   //   }
//   //   await _service.updateFullSalary(docId, updates);
//   //
//   //   // Update local list if present
//   //   final index = _salaries.indexWhere((s) => s.id == docId);
//   //   if (index != -1) {
//   //     final current = _salaries[index];
//   //
//   //     // ★ NEW – keep the employee's termination flag in Firestore in sync
//   //     // with what was just saved on this record.
//   //     // ★ FIX – pass year/month here too, same reasoning as saveSalary()
//   //     // above: without this, editing a salary record to toggle
//   //     // "terminated" on would set isTerminated but leave terminationDate
//   //     // blank on the employee doc.
//   //     if (isTerminated != null && isTerminated != current.isTerminated) {
//   //       await _markEmployeeTerminated(
//   //         current.employeeId,
//   //         isTerminated,
//   //         year: current.year,
//   //         month: current.month,
//   //       );
//   //     }
//   //
//   //     _salaries[index] = SalaryRecord(
//   //       id: docId,
//   //       employeeId: current.employeeId,
//   //       employeeName: current.employeeName,
//   //       employeeType: current.employeeType,
//   //       designation: current.designation,
//   //       year: current.year,
//   //       month: current.month,
//   //       mode: mode,
//   //       baseSalary: baseSalary,
//   //       totalDaysInMonth: totalDaysInMonth,
//   //       workingDays: workingDays,
//   //       leaves: leaves,
//   //       perDayRate: perDayRate,
//   //       absentDeduction: absentDeduction,
//   //       fine: fine,
//   //       bonus: bonus,
//   //       note: note,
//   //       netSalary: netSalary,
//   //       status: current.status,
//   //       isTerminated: isTerminated ?? current.isTerminated,
//   //       createdAt: current.createdAt,
//   //       paidAt: current.paidAt,
//   //     );
//   //     notifyListeners();
//   //   }
//   // }
//
//   /// Delete a salary record permanently.
//   /// ★ CHANGED — if the record being deleted was a termination record,
//   /// the employee is automatically reinstated (isTerminated -> false),
//   /// exactly like they were before termination.
//   Future<void> deleteSalary(String docId) async {
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
//   }
//
//   // ────────────────────────────────────────────────────────────
//   //  Helper: flip the employee's isTerminated flag in Firestore.
//   //  Uses whichever collection (teachers/staff) currently holds the doc,
//   //  same as StaffFirestoreService.updateStaff already does internally.
//   //
//   //  ★ FIX — previously this only ever set `member.isTerminated`. It never
//   //  touched `member.terminationDate`, so terminating an employee from the
//   //  Generate Salary screen left that field empty in Firestore — that's
//   //  exactly why the Staff Profile "Terminated" date showed up fine when
//   //  deactivating from the Teacher/Staff list (that flow sets the date
//   //  itself) but stayed blank when terminating via salary generation.
//   //
//   //  Now: when `terminated == true`, we set terminationDate to the LAST
//   //  DAY of the salary's month/year if provided (since that's the final
//   //  month being paid out for), falling back to today's date if no
//   //  year/month was passed in (e.g. reinstating doesn't need a date at all
//   //  since it gets cleared anyway).
//   // ────────────────────────────────────────────────────────────
//
//   // In SalaryProvider, update the _markEmployeeTerminated method:
//
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
//         // ★ FIX: Add termination event to history
//         // Backfill 'joined' if history is empty
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
//         // Remove any existing 'terminated' event with same date to avoid duplicates
//         member.statusHistory.removeWhere((e) =>
//         e.type == 'terminated' && e.date == dateStr
//         );
//         member.statusHistory.add(
//           StatusEvent(type: 'terminated', date: dateStr, note: 'Terminated via salary generation'),
//         );
//       } else {
//         // ★ FIX: When reinstating, add 'rejoined' event
//         member.isTerminated = false;
//         member.isActive = true;
//         member.terminationDate = null;
//         member.terminationNote = null;
//
//         // Remove any existing 'rejoined' event with same date to avoid duplicates
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
//   // Future<void> _markEmployeeTerminated(
//   //     String employeeId,
//   //     bool terminated, {
//   //       int? year,
//   //       int? month,
//   //       DateTime? generatedDate,  // ★ NEW - pass the salary generation date
//   //     }) async
//   // {
//   //   try {
//   //     final teachers = await _staffService.getTeachers();
//   //     final staff = await _staffService.getStaffOnly();
//   //     final all = [...teachers, ...staff];
//   //
//   //     StaffMember? member;
//   //     for (final m in all) {
//   //       if (m.id == employeeId) {
//   //         member = m;
//   //         break;
//   //       }
//   //     }
//   //     if (member == null) return;
//   //
//   //     member.isTerminated = terminated;
//   //     if (terminated) {
//   //       // ★ FIX 2: Use generatedDate if provided, otherwise fallback to now
//   //       final DateTime effectiveDate = generatedDate ?? DateTime.now();
//   //       member.terminationDate = _fmt(effectiveDate);
//   //     } else {
//   //       member.terminationDate = null;
//   //       member.terminationNote = null;
//   //     }
//   //     await _staffService.updateStaff(employeeId, member);
//   //   } catch (e) {
//   //     debugPrint('Error syncing employee termination status: $e');
//   //   }
//   // }
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
import '../providers/employee_transaction_provider.dart'; // ★ Added
import 'package:intl/intl.dart'; // ★ Added

class SalaryProvider extends ChangeNotifier {
  final SalaryFirestoreService _service = SalaryFirestoreService();
  final AttendanceFirestoreService _attendanceService =
  AttendanceFirestoreService();
  final StaffFirestoreService _staffService = StaffFirestoreService();

  // ★ NEW: Reference to transaction provider (injected or accessed via context)
  // We'll pass it via a method parameter or use a global service locator.
  // For simplicity, we'll accept it as a parameter in saveSalary and updateFullSalary.
  // But since these methods are called from UI, we can get the provider via context.
  // However, SalaryProvider is a ChangeNotifier, not a widget. So we'll use a callback.
  // Better: we'll use a function parameter to pass the transaction provider instance.
  // We'll modify saveSalary and updateFullSalary to accept a transaction provider.

  // ───── Current calculation states ─────
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
  //  Attendance-based calculation
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
  //  Manual calculation
  // ────────────────────────────────────────────────────────────
  Map<String, dynamic> calculateManual({
    required double baseSalary,
    required int workingDays,
    required int leaves,
    double fine = 0,
    double bonus = 0,
  }) {
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

  // ★ MODIFIED: Accept transaction provider
  // ★ MODIFIED: transactionProvider is now optional, and recordInLedger
  // controls whether a ledger/credit transaction is created at all.
  Future<void> saveSalary(
      SalaryRecord record, {
        StaffTransactionProvider? transactionProvider,
        bool recordInLedger = true,
      }) async {
    await _service.saveSalary(record);

    if (record.isTerminated) {
      await _markEmployeeTerminated(
        record.employeeId,
        true,
        year: record.year,
        month: record.month,
        generatedDate: record.generatedDate,
      );
    }

    if (recordInLedger && transactionProvider != null) {
      try {
        await transactionProvider.addSalaryDeduction(
          employeeId: record.employeeId,
          employeeName: record.employeeName,
          employeeType: record.employeeType,
          date: record.generatedDate,
          amount: record.netSalary,
          note: 'Salary for ${DateFormat('MMM yyyy').format(DateTime(record.year, record.month))}',
          salaryRecordId: record.id!,
        );
      } catch (e) {
        debugPrint('Error adding salary deduction transaction: $e');
      }
    }
  }
  // Future<void> saveSalary(
  //     SalaryRecord record,
  //     StaffTransactionProvider transactionProvider, // ★ NEW
  //     ) async
  // {
  //   await _service.saveSalary(record);
  //
  //   if (record.isTerminated) {
  //     await _markEmployeeTerminated(
  //       record.employeeId,
  //       true,
  //       year: record.year,
  //       month: record.month,
  //       generatedDate: record.generatedDate,
  //     );
  //   }
  //
  //   // ★ NEW: Add salary deduction as credit transaction
  //   try {
  //     await transactionProvider.addSalaryDeduction(
  //       employeeId: record.employeeId,
  //       employeeName: record.employeeName,
  //       employeeType: record.employeeType,
  //       date: record.generatedDate,
  //       amount: record.netSalary,
  //       note: 'Salary for ${DateFormat('MMM yyyy').format(DateTime(record.year, record.month))}',
  //       salaryRecordId: record.id!,
  //     );
  //   } catch (e) {
  //     debugPrint('Error adding salary deduction transaction: $e');
  //     // Don't fail the salary save if transaction fails
  //   }
  // }

  // ────────────────────────────────────────────────────────────
  //  Salary list management
  // ────────────────────────────────────────────────────────────
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
        generatedDate: generatedDate ?? current.generatedDate,
        createdAt: current.createdAt,
        paidAt: current.paidAt,
      );
      notifyListeners();
    }
  }

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