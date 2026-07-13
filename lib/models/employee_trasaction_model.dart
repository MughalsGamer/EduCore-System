import 'package:cloud_firestore/cloud_firestore.dart';

/// One row in an employee's ledger.
///
/// Collection: `employee_transactions` (top-level, independent from
/// `teachers` / `staff` / `salary_history` — zero risk of conflicting
/// with any existing feature).
///
/// Supported `type` values (chosen from a single dropdown in one shared
/// form, as requested):
///   - 'expense'    : company gave/spent money on the employee, OR a
///                    deduction from the employee (see [expenseDirection])
///   - 'loan'       : company gave the employee a loan (debit — employee
///                    owes the company)
///   - 'advance'    : company gave the employee an advance salary
///                    (debit — employee owes the company)
///   - 'repayment'  : employee paid back part/all of a loan or advance.
///                    [linkedTransactionId] points at the original
///                    'loan' or 'advance' entry this repayment reduces.
///
/// Ledger math (per employee, running balance):
///   direction == 'debit'  → increases what the employee owes the company
///   direction == 'credit' → decreases what the employee owes the company
///
/// For 'loan' and 'advance' entries specifically, [status] tracks
/// repayment progress:
///   'pending'         → nothing repaid yet
///   'partially_paid'  → some repayments exist but not fully settled
///   'settled'         → fully repaid (remainingAmount <= 0)
/// [status] is null for 'expense' and 'repayment' types.
class EmployeeTransaction {
  String? id;
  final String staffId;
  final String staffName;
  final String staffType; // 'teacher' | 'staff' (denormalized)
  final String type; // 'expense' | 'loan' | 'advance' | 'repayment'
  final String direction; // 'debit' | 'credit'
  final double amount;
  final String description;
  final String date; // yyyy-MM-dd (effective date, user-editable)

  /// Only meaningful for type == 'expense'. Distinguishes whether the
  /// company spent FOR the employee (e.g. reimbursement — still a debit
  /// against the employee if it's something they must account for) or
  /// this was a deduction. Kept simple: this field is just a label for
  /// display; [direction] is what actually drives the ledger math.
  final String? expenseKind; // 'company_expense' | 'deduction' | null

  /// For 'loan' / 'advance': running status as repayments come in.
  final String? status; // 'pending' | 'partially_paid' | 'settled' | null

  /// For 'repayment': id of the 'loan' or 'advance' transaction this
  /// repayment is reducing. Null for all other types.
  final String? linkedTransactionId;

  final DateTime? createdAt;

  EmployeeTransaction({
    this.id,
    required this.staffId,
    required this.staffName,
    required this.staffType,
    required this.type,
    required this.direction,
    required this.amount,
    required this.description,
    required this.date,
    this.expenseKind,
    this.status,
    this.linkedTransactionId,
    this.createdAt,
  });

  bool get isDebit => direction == 'debit';
  bool get isCredit => direction == 'credit';

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'staffType': staffType,
      'type': type,
      'direction': direction,
      'amount': amount,
      'description': description,
      'date': date,
      'expenseKind': expenseKind,
      'status': status,
      'linkedTransactionId': linkedTransactionId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Used when we need to write createdAt manually is NOT needed for
  /// updates — Firestore keeps the original createdAt untouched because
  /// we never overwrite it after creation (see service.updateTransaction).
  Map<String, dynamic> toUpdateMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'staffType': staffType,
      'type': type,
      'direction': direction,
      'amount': amount,
      'description': description,
      'date': date,
      'expenseKind': expenseKind,
      'status': status,
      'linkedTransactionId': linkedTransactionId,
      // createdAt intentionally omitted so it never changes on edit
    };
  }

  factory EmployeeTransaction.fromMap(Map<String, dynamic> map, String id) {
    return EmployeeTransaction(
      id: id,
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      staffType: map['staffType'] ?? 'staff',
      type: map['type'] ?? 'expense',
      direction: map['direction'] ?? 'debit',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      expenseKind: map['expenseKind'] as String?,
      status: map['status'] as String?,
      linkedTransactionId: map['linkedTransactionId'] as String?,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  EmployeeTransaction copyWith({
    String? type,
    String? direction,
    double? amount,
    String? description,
    String? date,
    String? expenseKind,
    String? status,
  }) {
    return EmployeeTransaction(
      id: id,
      staffId: staffId,
      staffName: staffName,
      staffType: staffType,
      type: type ?? this.type,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      expenseKind: expenseKind ?? this.expenseKind,
      status: status ?? this.status,
      linkedTransactionId: linkedTransactionId,
      createdAt: createdAt,
    );
  }
}