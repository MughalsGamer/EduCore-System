
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Represents a single Advance / Loan / Expense / Fine / Reimbursement / Other
/// transaction recorded against a staff member or teacher.
///
/// Stored in the standalone Firestore collection: `staff_transactions`
class StaffTransaction {
  final String? id;
  final String employeeId;
  final String employeeName;
  final String employeeType; // 'teacher' or 'staff'
  final DateTime date;
  final String category; // Advance, Loan, Expense, Fine, Reimbursement, Others, SalaryDeduction
  final String? customCategory; // used only when category == 'Others'
  final double amount;
  final String? note;
  final DateTime createdAt;

  // ★ NEW: Transaction type for ledger
  final String transactionType; // 'debit' or 'credit'

  // ★ NEW: Reference to salary record (if this is from salary deduction)
  final String? salaryRecordId;

  // ★ NEW: Running balance after this transaction
  final double? runningBalance;

  StaffTransaction({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeType,
    required this.date,
    required this.category,
    this.customCategory,
    required this.amount,
    this.note,
    DateTime? createdAt,
    this.transactionType = 'debit',
    this.salaryRecordId,
    this.runningBalance,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Friendly label for UI — shows custom category text when 'Others' is picked.
  String get displayCategory {
    if (category == 'Others' &&
        customCategory != null &&
        customCategory!.trim().isNotEmpty) {
      return customCategory!.trim();
    }
    return category;
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeType': employeeType,
      'date': Timestamp.fromDate(date),
      'category': category,
      'customCategory': customCategory,
      'amount': amount,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'transactionType': transactionType,
      'salaryRecordId': salaryRecordId,
      'runningBalance': runningBalance,
    };
  }

  factory StaffTransaction.fromMap(Map<String, dynamic> map, String id) {
    return StaffTransaction(
      id: id,
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      employeeType: map['employeeType'] ?? 'staff',
      date: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate()
          : DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      category: map['category'] ?? 'Advance',
      customCategory: map['customCategory'],
      amount: (map['amount'] ?? 0).toDouble(),
      note: map['note'],
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      transactionType: map['transactionType'] ?? 'debit',
      salaryRecordId: map['salaryRecordId'] as String?,
      runningBalance: (map['runningBalance'] as num?)?.toDouble(),
    );
  }

  // ★ FIXED: added `id` as an optional named parameter so callers like
  // StaffTransactionProvider.updateTransaction() can reassign the id
  // (e.g. transaction.copyWith(runningBalance: newBalance, id: id)).
  StaffTransaction copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? employeeType,
    DateTime? date,
    String? category,
    String? customCategory,
    double? amount,
    String? note,
    String? transactionType,
    String? salaryRecordId,
    double? runningBalance,
  }) {
    return StaffTransaction(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeType: employeeType ?? this.employeeType,
      date: date ?? this.date,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt,
      transactionType: transactionType ?? this.transactionType,
      salaryRecordId: salaryRecordId ?? this.salaryRecordId,
      runningBalance: runningBalance ?? this.runningBalance,
    );
  }

  // ★ Helper to create a credit transaction from salary deduction
  factory StaffTransaction.fromSalaryDeduction({
    required String employeeId,
    required String employeeName,
    required String employeeType,
    required DateTime date,
    required double amount,
    required String? note,
    required String salaryRecordId,
  }) {
    return StaffTransaction(
      employeeId: employeeId,
      employeeName: employeeName,
      employeeType: employeeType,
      date: date,
      category: 'SalaryDeduction',
      amount: amount,
      note: note ?? 'Salary deduction for ${DateFormat('MMM yyyy').format(date)}',
      transactionType: 'credit', // Credit reduces what employee owes
      salaryRecordId: salaryRecordId,
    );
  }
}