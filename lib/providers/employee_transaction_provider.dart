import 'package:flutter/foundation.dart';

import '../models/employee_trasaction_model.dart';
import '../models/teacher.dart';
import '../services/employee_transaction_firestore_service.dart';
import '../services/firestore_service.dart';

/// One row in the rendered ledger — a transaction plus the running
/// balance immediately after it, computed oldest-to-newest.
class LedgerEntry {
  final EmployeeTransaction tx;
  final double runningBalance;
  const LedgerEntry({required this.tx, required this.runningBalance});
}

/// Summary for a single loan or advance: original amount, how much has
/// been repaid so far, and what's left.
class OutstandingItem {
  final EmployeeTransaction original; // the 'loan' or 'advance' entry
  final List<EmployeeTransaction> repayments;

  const OutstandingItem({required this.original, required this.repayments});

  double get totalRepaid =>
      repayments.fold(0.0, (sum, r) => sum + r.amount);

  double get remaining => (original.amount - totalRepaid).clamp(0, double.infinity);

  String get computedStatus {
    if (remaining <= 0) return 'settled';
    if (totalRepaid > 0) return 'partially_paid';
    return 'pending';
  }
}

/// Groups all ledger activity for one employee — used by the Employee
/// Picker / Ledger summary list, so employees with any expense, loan,
/// or advance activity show up with a quick balance snapshot.
class EmployeeLedgerSummary {
  final StaffMember staff;
  final List<EmployeeTransaction> transactions; // most recent first

  const EmployeeLedgerSummary({
    required this.staff,
    required this.transactions,
  });

  /// Net amount the employee currently owes the company
  /// (positive = employee owes company; can't go below 0 conceptually
  /// but we don't clamp here so any data anomaly is still visible).
  double get netBalance {
    double bal = 0;
    for (final t in transactions) {
      bal += t.isDebit ? t.amount : -t.amount;
    }
    return bal;
  }

  EmployeeTransaction? get latest =>
      transactions.isNotEmpty ? transactions.first : null;
}

class EmployeeTransactionProvider extends ChangeNotifier {
  final EmployeeTransactionFirestoreService _service =
  EmployeeTransactionFirestoreService();
  final StaffFirestoreService _staffService = StaffFirestoreService();

  bool _loading = false;
  bool get loading => _loading;

  // Full transaction list for whichever employee's ledger is open,
  // most recent first (as stored).
  List<EmployeeTransaction> _currentStaffTransactions = [];
  List<EmployeeTransaction> get currentStaffTransactions =>
      _currentStaffTransactions;

  // Same data, oldest-first, with running balance computed — this is
  // what the ledger UI actually renders (like a bank statement).
  List<LedgerEntry> _currentLedger = [];
  List<LedgerEntry> get currentLedger => _currentLedger;

  // Outstanding loans/advances for the currently open employee.
  List<OutstandingItem> _currentOutstanding = [];
  List<OutstandingItem> get currentOutstanding => _currentOutstanding;

  // Summaries for the ledger list/dashboard screen — only employees
  // with at least one transaction.
  List<EmployeeLedgerSummary> _summaries = [];
  List<EmployeeLedgerSummary> get summaries => _summaries;

  double get currentNetBalance {
    double bal = 0;
    for (final t in _currentStaffTransactions) {
      bal += t.isDebit ? t.amount : -t.amount;
    }
    return bal;
  }

  /// Loads everything needed to render one employee's full ledger:
  /// raw transactions, running-balance rows, and outstanding
  /// loans/advances with their repayment status.
  Future<void> loadLedgerForStaff(String staffId) async {
    _loading = true;
    notifyListeners();

    _currentStaffTransactions =
    await _service.getTransactionsForStaff(staffId);

    // Build running balance oldest -> newest, then keep it in that
    // order for display (classic ledger reading order).
    final oldestFirst = List<EmployeeTransaction>.from(
        _currentStaffTransactions)
        .reversed
        .toList();
    double running = 0;
    final ledger = <LedgerEntry>[];
    for (final tx in oldestFirst) {
      running += tx.isDebit ? tx.amount : -tx.amount;
      ledger.add(LedgerEntry(tx: tx, runningBalance: running));
    }
    _currentLedger = ledger;

    // Build outstanding items for every loan/advance belonging to this
    // employee, matched with their repayments.
    final loanAndAdvance = _currentStaffTransactions
        .where((t) => t.type == 'loan' || t.type == 'advance')
        .toList();
    final repayments = _currentStaffTransactions
        .where((t) => t.type == 'repayment')
        .toList();

    _currentOutstanding = loanAndAdvance.map((orig) {
      final linked =
      repayments.where((r) => r.linkedTransactionId == orig.id).toList();
      return OutstandingItem(original: orig, repayments: linked);
    }).toList();

    _loading = false;
    notifyListeners();
  }

  /// Adds an Expense entry.
  /// [expenseKind] : 'company_expense' (company spent on/for employee)
  ///                 or 'deduction' (deducted from employee).
  /// Direction is derived automatically: company_expense -> debit
  /// (employee owes / accountable for it), deduction -> debit as well,
  /// since both reduce what the company owes the employee. If you ever
  /// need a credit-style expense (rare), pass direction explicitly via
  /// [addRawTransaction].
  Future<void> addExpense({
    required StaffMember staff,
    required double amount,
    required String description,
    required String date,
    required String expenseKind, // 'company_expense' | 'deduction'
  }) async {
    final tx = EmployeeTransaction(
      staffId: staff.id!,
      staffName: staff.name,
      staffType: staff.type,
      type: 'expense',
      direction: 'debit',
      amount: amount,
      description: description,
      date: date,
      expenseKind: expenseKind,
    );
    await _service.addTransaction(tx);
    await loadLedgerForStaff(staff.id!);
  }

  /// Adds a Loan given to the employee. Starts as 'pending'.
  Future<void> addLoan({
    required StaffMember staff,
    required double amount,
    required String description,
    required String date,
  }) async {
    final tx = EmployeeTransaction(
      staffId: staff.id!,
      staffName: staff.name,
      staffType: staff.type,
      type: 'loan',
      direction: 'debit',
      amount: amount,
      description: description,
      date: date,
      status: 'pending',
    );
    await _service.addTransaction(tx);
    await loadLedgerForStaff(staff.id!);
  }

  /// Adds an Advance Salary given to the employee. Starts as 'pending'.
  Future<void> addAdvance({
    required StaffMember staff,
    required double amount,
    required String description,
    required String date,
  }) async {
    final tx = EmployeeTransaction(
      staffId: staff.id!,
      staffName: staff.name,
      staffType: staff.type,
      type: 'advance',
      direction: 'debit',
      amount: amount,
      description: description,
      date: date,
      status: 'pending',
    );
    await _service.addTransaction(tx);
    await loadLedgerForStaff(staff.id!);
  }

  /// Records a repayment against an existing loan or advance
  /// ([original]). Automatically recalculates and persists the
  /// original's status (pending / partially_paid / settled).
  ///
  /// Guards against over-payment: if the entered amount would exceed
  /// the remaining balance, it throws so the UI can show a friendly
  /// error instead of silently creating a negative-remaining loan.
  Future<void> addRepayment({
    required StaffMember staff,
    required EmployeeTransaction original,
    required double amount,
    required String description,
    required String date,
  }) async {
    if (original.id == null) {
      throw Exception('Original loan/advance has no id.');
    }

    final existingRepayments =
    await _service.getRepaymentsFor(original.id!);
    final alreadyRepaid =
    existingRepayments.fold(0.0, (sum, r) => sum + r.amount);
    final remaining = original.amount - alreadyRepaid;

    if (amount <= 0) {
      throw Exception('Repayment amount must be greater than zero.');
    }
    if (amount > remaining + 0.01) {
      throw Exception(
          'Repayment (Rs ${amount.toStringAsFixed(0)}) exceeds remaining balance (Rs ${remaining.toStringAsFixed(0)}).');
    }

    final tx = EmployeeTransaction(
      staffId: staff.id!,
      staffName: staff.name,
      staffType: staff.type,
      type: 'repayment',
      direction: 'credit',
      amount: amount,
      description: description.trim().isEmpty
          ? 'Repayment for ${original.type} (${original.description})'
          : description,
      date: date,
      linkedTransactionId: original.id,
    );
    await _service.addTransaction(tx);

    await _recalculateAndPersistStatus(original.id!, staff.id!);
    await loadLedgerForStaff(staff.id!);
  }

  /// Recomputes a loan/advance's status from its current repayments and
  /// writes it back to Firestore so other screens (e.g. dashboard
  /// outstanding-loans widgets) reading raw data also see the right
  /// status without needing to replay this logic themselves.
  Future<void> _recalculateAndPersistStatus(
      String originalId, String staffId) async {
    // Fetch fresh copy of the original + its repayments.
    final allForStaff = await _service.getTransactionsForStaff(staffId);
    final original = allForStaff.firstWhere((t) => t.id == originalId);
    final repayments =
    allForStaff.where((t) => t.linkedTransactionId == originalId).toList();
    final totalRepaid = repayments.fold(0.0, (sum, r) => sum + r.amount);
    final remaining = original.amount - totalRepaid;

    final newStatus = remaining <= 0.01
        ? 'settled'
        : (totalRepaid > 0 ? 'partially_paid' : 'pending');

    if (newStatus != original.status) {
      final updated = original.copyWith(status: newStatus);
      await _service.updateTransaction(originalId, updated);
    }
  }

  /// Edits any existing transaction (expense, loan, advance, or
  /// repayment). If a loan/advance's `amount` is edited, or a
  /// repayment's `amount` is edited, status is recalculated afterward.
  Future<void> editTransaction({
    required StaffMember staff,
    required EmployeeTransaction updated,
  }) async {
    if (updated.id == null) {
      throw Exception('Transaction has no id.');
    }
    await _service.updateTransaction(updated.id!, updated);

    // Keep status correct after edits that could affect balances.
    if (updated.type == 'loan' || updated.type == 'advance') {
      await _recalculateAndPersistStatus(updated.id!, staff.id!);
    } else if (updated.type == 'repayment' &&
        updated.linkedTransactionId != null) {
      await _recalculateAndPersistStatus(
          updated.linkedTransactionId!, staff.id!);
    }

    await loadLedgerForStaff(staff.id!);
  }

  /// Deletes a transaction.
  /// - Deleting a 'repayment' just removes it, then recalculates the
  ///   parent loan/advance's status.
  /// - Deleting a 'loan'/'advance' also removes any repayments linked
  ///   to it (avoids orphaned rows referencing a deleted loan), via the
  ///   service's atomic batch delete.
  /// - Deleting an 'expense' just removes it — nothing else references it.
  Future<void> deleteTransaction({
    required StaffMember staff,
    required EmployeeTransaction tx,
  }) async {
    if (tx.id == null) return;

    if (tx.type == 'loan' || tx.type == 'advance') {
      await _service.deleteTransactionWithLinkedRepayments(tx.id!);
    } else if (tx.type == 'repayment') {
      await _service.deleteTransaction(tx.id!);
      if (tx.linkedTransactionId != null) {
        await _recalculateAndPersistStatus(
            tx.linkedTransactionId!, staff.id!);
      }
    } else {
      await _service.deleteTransaction(tx.id!);
    }

    await loadLedgerForStaff(staff.id!);
  }

  /// Loads all transactions, grouped by staffId and joined with current
  /// staff/teacher data — used by the "Employee Ledger" list/dashboard
  /// screen. Only employees with >=1 transaction are included.
  Future<void> loadAllSummaries() async {
    _loading = true;
    notifyListeners();

    final allTx = await _service.getAllTransactions();
    final allStaff = await _staffService.getAllStaff();
    final staffById = {for (final s in allStaff) if (s.id != null) s.id!: s};

    final Map<String, List<EmployeeTransaction>> grouped = {};
    for (final tx in allTx) {
      grouped.putIfAbsent(tx.staffId, () => []).add(tx);
    }

    final List<EmployeeLedgerSummary> result = [];
    grouped.forEach((staffId, txs) {
      final staff = staffById[staffId];
      if (staff != null) {
        // txs already come back most-recent-first from the service
        result.add(EmployeeLedgerSummary(staff: staff, transactions: txs));
      }
    });

    // Sort by most recent activity overall, newest first
    result.sort((a, b) {
      final aDate = a.latest?.createdAt ?? DateTime(2000);
      final bDate = b.latest?.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    _summaries = result;
    _loading = false;
    notifyListeners();
  }

  void clearCurrentLedger() {
    _currentStaffTransactions = [];
    _currentLedger = [];
    _currentOutstanding = [];
    notifyListeners();
  }
}