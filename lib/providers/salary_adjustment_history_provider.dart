import 'package:flutter/foundation.dart';

import '../models/salary_adjustment_history.dart';
import '../models/teacher.dart';
import '../services/salary_adjustment_history_service.dart';
import '../services/firestore_service.dart';

/// Groups all salary_history records for one employee, together with
/// that employee's current live record, so the "Salary Management"
/// list screen can show name/current-salary/last-change at a glance.
class EmployeeSalarySummary {
  final StaffMember staff;
  final List<SalaryHistory> history; // most recent first

  const EmployeeSalarySummary({
    required this.staff,
    required this.history,
  });

  SalaryHistory get latestChange => history.first;
}

class SalaryHistoryProvider extends ChangeNotifier {
  final SalaryHistoryFirestoreService _historyService =
  SalaryHistoryFirestoreService();
  final StaffFirestoreService _staffService = StaffFirestoreService();

  bool _loading = false;
  bool get loading => _loading;

  // History for whichever single employee's profile/dialog is currently open
  List<SalaryHistory> _currentStaffHistory = [];
  List<SalaryHistory> get currentStaffHistory => _currentStaffHistory;

  // Summaries used by the "Salary Management" list screen —
  // only employees who have at least one salary_history record.
  List<EmployeeSalarySummary> _summaries = [];
  List<EmployeeSalarySummary> get summaries => _summaries;

  /// Loads history for a single staff/teacher (e.g. when opening the
  /// increment/decrement dialog from the Staff/Teacher list).
  Future<void> loadHistoryForStaff(String staffId) async {
    _loading = true;
    notifyListeners();
    _currentStaffHistory = await _historyService.getHistoryForStaff(staffId);
    _loading = false;
    notifyListeners();
  }

  /// Applies a salary increment or decrement:
  /// 1. Writes a new record to `salary_history`.
  /// 2. Updates the `salary` field on the StaffMember doc (via existing
  ///    StaffFirestoreService.updateStaff — no schema change needed there).
  /// 3. Refreshes the in-memory history for that staff member.
  Future<void> applySalaryChange({
    required StaffMember staff,
    required String changeType, // 'increment' or 'decrement'
    required double newSalary,
    required String reason,
    required String date,
  }) async {
    final oldSalary = staff.salary;
    final amount = (newSalary - oldSalary).abs();

    final record = SalaryHistory(
      staffId: staff.id!,
      staffName: staff.name,
      staffType: staff.type,
      changeType: changeType,
      oldSalary: oldSalary,
      newSalary: newSalary,
      amount: amount,
      reason: reason,
      date: date,
    );

    // 1. Save history record (independent collection — no conflicts)
    await _historyService.addSalaryChange(record);

    // 2. Update current salary on the staff/teacher doc
    await _updateStaffSalary(staff, newSalary);

    // 3. Refresh history for this employee
    await loadHistoryForStaff(staff.id!);
  }

  /// Deletes a single salary_history record for [staff].
  ///
  /// Rules:
  /// - If the deleted record is the LATEST one (i.e. it currently drives
  ///   the employee's live `salary` field), the employee's current salary
  ///   is reverted back to that record's `oldSalary` — undoing the mistaken
  ///   entry completely.
  /// - If the deleted record is NOT the latest one (an older entry in the
  ///   middle of the history), the current salary is left untouched,
  ///   because reverting it would silently make the newer records'
  ///   oldSalary/newSalary chain inconsistent. Only the record itself is
  ///   removed in that case.
  ///
  /// Returns true if the employee's current salary was reverted, false
  /// otherwise — the UI can use this to tell the user what happened.
  Future<bool> deleteHistoryRecord({
    required StaffMember staff,
    required SalaryHistory record,
  }) async {
    _loading = true;
    notifyListeners();

    bool reverted = false;
    try {
      // Determine if this is the latest record for this staff member
      // BEFORE deleting it, using the already-loaded currentStaffHistory
      // (most-recent-first) when available and matching this staff.
      List<SalaryHistory> history = _currentStaffHistory;
      if (history.isEmpty || history.first.staffId != staff.id) {
        history = await _historyService.getHistoryForStaff(staff.id!);
      }

      final isLatest =
          history.isNotEmpty && history.first.id == record.id;

      // Delete the record itself
      await _historyService.deleteHistoryRecord(record.id!);

      // If it was the latest one, revert the live salary back to
      // what it was before this record was applied.
      if (isLatest) {
        await _updateStaffSalary(staff, record.oldSalary);
        reverted = true;
      }

      // Refresh in-memory history for this employee
      _currentStaffHistory =
      await _historyService.getHistoryForStaff(staff.id!);
    } finally {
      _loading = false;
      notifyListeners();
    }

    return reverted;
  }

  /// Shared helper: writes a new `salary` value onto the StaffMember doc
  /// without touching any other field.
  Future<void> _updateStaffSalary(StaffMember staff, double newSalary) async {
    final updatedStaff = StaffMember(
      id: staff.id,
      type: staff.type,
      name: staff.name,
      fatherOrHusbandName: staff.fatherOrHusbandName,
      cnic: staff.cnic,
      dob: staff.dob,
      gender: staff.gender,
      maritalStatus: staff.maritalStatus,
      bloodGroup: staff.bloodGroup,
      religion: staff.religion,
      nationality: staff.nationality,
      address: staff.address,
      phone: staff.phone,
      emergencyPhone: staff.emergencyPhone,
      employmentType: staff.employmentType,
      salary: newSalary,
      reference: staff.reference,
      note: staff.note,
      imageBase64: staff.imageBase64,
      assignedClasses: staff.assignedClasses,
      assignedSections: staff.assignedSections,
      subjects: staff.subjects,
      designation: staff.designation,
      joiningDate: staff.joiningDate,
      isActive: staff.isActive,
    );
    await _staffService.updateStaff(staff.id!, updatedStaff);
  }

  /// Loads all salary_history records, groups them by staffId, and joins
  /// with current staff/teacher data — used by the "Salary Management"
  /// screen. Only employees with >=1 history record are included.
  Future<void> loadAllSummaries() async {
    _loading = true;
    notifyListeners();

    final allHistory = await _historyService.getAllHistory();
    final allStaff = await _staffService.getAllStaff();
    final staffById = {for (final s in allStaff) if (s.id != null) s.id!: s};

    final Map<String, List<SalaryHistory>> grouped = {};
    for (final record in allHistory) {
      grouped.putIfAbsent(record.staffId, () => []).add(record);
    }

    final List<EmployeeSalarySummary> result = [];
    grouped.forEach((staffId, records) {
      final staff = staffById[staffId];
      if (staff != null) {
        // records already come back most-recent-first from the service
        result.add(EmployeeSalarySummary(staff: staff, history: records));
      }
    });

    // Sort by most recent change overall, newest first
    result.sort((a, b) {
      final aDate = a.latestChange.createdAt ?? DateTime(2000);
      final bDate = b.latestChange.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    _summaries = result;
    _loading = false;
    notifyListeners();
  }

  void clearCurrentStaffHistory() {
    _currentStaffHistory = [];
    notifyListeners();
  }
}