import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single salary increment/decrement record for a staff/teacher.
/// Stored in a standalone top-level Firestore collection: `salary_history`.
/// This is completely independent from the `teachers` / `staff` collections,
/// so it never conflicts with StaffMember documents. Each record links back
/// via `staffId`.
class SalaryHistory {
  final String? id;
  final String staffId;
  final String staffName;   // denormalized for easy display without extra lookups
  final String staffType;   // 'teacher' or 'staff' — denormalized too
  final String changeType;  // 'increment' or 'decrement'
  final double oldSalary;
  final double newSalary;
  final double amount;      // absolute difference between old & new
  final String reason;
  final String date;        // yyyy-MM-dd (the effective date entered by user)
  final DateTime? createdAt; // server timestamp of when the record was created

  const SalaryHistory({
    this.id,
    required this.staffId,
    required this.staffName,
    required this.staffType,
    required this.changeType,
    required this.oldSalary,
    required this.newSalary,
    required this.amount,
    required this.reason,
    required this.date,
    this.createdAt,
  });

  bool get isIncrement => changeType == 'increment';

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'staffType': staffType,
      'changeType': changeType,
      'oldSalary': oldSalary,
      'newSalary': newSalary,
      'amount': amount,
      'reason': reason,
      'date': date,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory SalaryHistory.fromMap(Map<String, dynamic> map, String id) {
    DateTime? created;
    final rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    }

    return SalaryHistory(
      id: id,
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      staffType: map['staffType'] ?? 'staff',
      changeType: map['changeType'] ?? 'increment',
      oldSalary: (map['oldSalary'] ?? 0).toDouble(),
      newSalary: (map['newSalary'] ?? 0).toDouble(),
      amount: (map['amount'] ?? 0).toDouble(),
      reason: map['reason'] ?? '',
      date: map['date'] ?? '',
      createdAt: created,
    );
  }
}