
import 'package:cloud_firestore/cloud_firestore.dart';

class SalaryRecord {
  String? id;
  final String employeeId;
  final String employeeName;
  final String employeeType; // 'teacher' or 'staff'
  final String? designation;

  final int year;
  final int month; // 1-12

  final String mode; // 'attendance' or 'manual'

  final double baseSalary;
  final int totalDaysInMonth; // actual calendar days in the month (28-31)
  final int workingDays;      // days used as denominator (30 for attendance mode)
  final int leaves;           // absences deducted
  final double perDayRate;    // baseSalary / workingDays
  final double absentDeduction;

  final double fine;
  final double bonus;
  final String? note;

  final double netSalary;

  // 'Pending' | 'Paid' | 'Unpaid'
  final String status;

  // true when this salary was generated as (or marked as) the
  // employee's termination salary. Used to highlight/badge the record in
  // the Salary List, and to know that deleting this record should
  // automatically reinstate the employee.
  final bool isTerminated;

  // date when salary was generated
  final DateTime generatedDate;

  // ★ NEW — whether this salary had a "Deduct from Balance" ledger credit
  // recorded against it, and what that amount was. Persisted so the
  // Salary List / Detail screens can display it correctly, instead of it
  // only living transiently in GenerateSalaryScreen's form state.
  final bool recordInLedger;
  final double ledgerDeductionAmount;

  final DateTime? createdAt;
  final DateTime? paidAt;   // timestamp when marked as Paid

  SalaryRecord({
    this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeType,
    this.designation,
    required this.year,
    required this.month,
    required this.mode,
    required this.baseSalary,
    required this.totalDaysInMonth,
    required this.workingDays,
    required this.leaves,
    required this.perDayRate,
    required this.absentDeduction,
    this.fine = 0,
    this.bonus = 0,
    this.note,
    required this.netSalary,
    this.status = 'Pending',
    this.isTerminated = false,
    DateTime? generatedDate,
    this.recordInLedger = false, // ★ NEW
    this.ledgerDeductionAmount = 0, // ★ NEW
    this.createdAt,
    this.paidAt,
  }) : generatedDate = generatedDate ?? DateTime.now();

  // ★ NEW — the amount actually payable to the employee after subtracting
  // any balance deduction. Mirrors GenerateSalaryScreen's live preview
  // (_payableNetSalary), but computed from the persisted record so the
  // Salary List/Detail screens show the correct total too.
  double get payableNetSalary =>
      recordInLedger ? (netSalary - ledgerDeductionAmount) : netSalary;

  // ★ NEW — convenience copy method used by SalaryProvider to rebuild a
  // record with a fresh Firestore id and/or updated deduction fields
  // without re-typing every single field each time.
  SalaryRecord copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? employeeType,
    String? designation,
    int? year,
    int? month,
    String? mode,
    double? baseSalary,
    int? totalDaysInMonth,
    int? workingDays,
    int? leaves,
    double? perDayRate,
    double? absentDeduction,
    double? fine,
    double? bonus,
    String? note,
    double? netSalary,
    String? status,
    bool? isTerminated,
    DateTime? generatedDate,
    bool? recordInLedger,
    double? ledgerDeductionAmount,
    DateTime? createdAt,
    DateTime? paidAt,
  }) {
    return SalaryRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeType: employeeType ?? this.employeeType,
      designation: designation ?? this.designation,
      year: year ?? this.year,
      month: month ?? this.month,
      mode: mode ?? this.mode,
      baseSalary: baseSalary ?? this.baseSalary,
      totalDaysInMonth: totalDaysInMonth ?? this.totalDaysInMonth,
      workingDays: workingDays ?? this.workingDays,
      leaves: leaves ?? this.leaves,
      perDayRate: perDayRate ?? this.perDayRate,
      absentDeduction: absentDeduction ?? this.absentDeduction,
      fine: fine ?? this.fine,
      bonus: bonus ?? this.bonus,
      note: note ?? this.note,
      netSalary: netSalary ?? this.netSalary,
      status: status ?? this.status,
      isTerminated: isTerminated ?? this.isTerminated,
      generatedDate: generatedDate ?? this.generatedDate,
      recordInLedger: recordInLedger ?? this.recordInLedger,
      ledgerDeductionAmount: ledgerDeductionAmount ?? this.ledgerDeductionAmount,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeType': employeeType,
      'designation': designation,
      'year': year,
      'month': month,
      'mode': mode,
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
      'status': status,
      'isTerminated': isTerminated,
      'generatedDate': generatedDate.toIso8601String(),
      'recordInLedger': recordInLedger, // ★ NEW
      'ledgerDeductionAmount': ledgerDeductionAmount, // ★ NEW
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };

    if (paidAt != null) {
      map['paidAt'] = Timestamp.fromDate(paidAt!);
    }

    return map;
  }

  factory SalaryRecord.fromMap(Map<String, dynamic> map, String id) {
    DateTime? paid;
    if (map['paidAt'] != null) {
      if (map['paidAt'] is Timestamp) {
        paid = (map['paidAt'] as Timestamp).toDate();
      }
    }

    // Parse generatedDate
    DateTime generatedDate = DateTime.now();
    if (map['generatedDate'] != null) {
      try {
        if (map['generatedDate'] is String) {
          generatedDate = DateTime.parse(map['generatedDate']);
        } else if (map['generatedDate'] is Timestamp) {
          generatedDate = (map['generatedDate'] as Timestamp).toDate();
        }
      } catch (_) {}
    }

    return SalaryRecord(
      id: id,
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      employeeType: map['employeeType'] ?? 'staff',
      designation: map['designation'] as String?,
      year: (map['year'] ?? DateTime.now().year) as int,
      month: (map['month'] ?? DateTime.now().month) as int,
      mode: map['mode'] ?? 'attendance',
      baseSalary: (map['baseSalary'] ?? 0).toDouble(),
      totalDaysInMonth: (map['totalDaysInMonth'] ?? 30) as int,
      workingDays: (map['workingDays'] ?? 30) as int,
      leaves: (map['leaves'] ?? 0) as int,
      perDayRate: (map['perDayRate'] ?? 0).toDouble(),
      absentDeduction: (map['absentDeduction'] ?? 0).toDouble(),
      fine: (map['fine'] ?? 0).toDouble(),
      bonus: (map['bonus'] ?? 0).toDouble(),
      note: map['note'] as String?,
      netSalary: (map['netSalary'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pending',
      isTerminated: map['isTerminated'] ?? false,
      generatedDate: generatedDate,
      recordInLedger: map['recordInLedger'] ?? false, // ★ NEW
      ledgerDeductionAmount: (map['ledgerDeductionAmount'] ?? 0).toDouble(), // ★ NEW
      createdAt: map['createdAt'] != null && map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      paidAt: paid,
    );
  }
}