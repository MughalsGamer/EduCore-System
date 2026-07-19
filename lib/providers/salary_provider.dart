
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

  // ★ MODIFIED: Accept transaction provider + custom ledger deduction amount.
  // ★ MODIFIED: transactionProvider is now optional, and recordInLedger
  // controls whether a ledger/credit transaction is created at all.
  // ★ NEW: ledgerDeductionAmount lets the caller deduct any custom amount
  // instead of always deducting the full net salary. Plain ledger
  // arithmetic is used — newBalance = currentBalance - deductionAmount —
  // with no cap, so the balance can go negative (meaning the school owes
  // the employee) if the deduction exceeds the current balance.
  // Falls back to record.netSalary if not provided, preserving old behavior.
  Future<void> saveSalary(
      SalaryRecord record, {
        StaffTransactionProvider? transactionProvider,
        bool recordInLedger = true,
        double? ledgerDeductionAmount, // ★ NEW
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
      // ★ NEW — use the custom amount if provided, otherwise default to
      // the full net salary (keeps backward compatibility for any other
      // callers that don't pass ledgerDeductionAmount).
      final amountToDeduct = ledgerDeductionAmount ?? record.netSalary;
      try {
        await transactionProvider.addSalaryDeduction(
          employeeId: record.employeeId,
          employeeName: record.employeeName,
          employeeType: record.employeeType,
          date: record.generatedDate,
          amount: amountToDeduct, // ★ CHANGED — was always record.netSalary
          note: 'Salary for ${DateFormat('MMM yyyy').format(DateTime(record.year, record.month))}',
          salaryRecordId: record.id!,
        );
      } catch (e) {
        debugPrint('Error adding salary deduction transaction: $e');
      }
    }
  }

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