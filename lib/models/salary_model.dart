//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class SalaryRecord {
//   String? id;
//   final String employeeId;
//   final String employeeName;
//   final String employeeType; // 'teacher' or 'staff'
//   final String? designation;
//
//   final int year;
//   final int month; // 1-12
//
//   final String mode; // 'attendance' or 'manual'
//
//   final double baseSalary;
//   final int totalDaysInMonth; // actual calendar days in the month (28-31)
//   final int workingDays;      // days used as denominator (30 for attendance mode)
//   final int leaves;           // absences deducted
//   final double perDayRate;    // baseSalary / workingDays
//   final double absentDeduction;
//
//   final double fine;
//   final double bonus;
//   final String? note;
//
//   final double netSalary;
//
//   // 'Pending' | 'Paid' | 'Unpaid'
//   final String status;
//
//   final DateTime? createdAt;
//   final DateTime? paidAt;   // timestamp when marked as Paid
//
//   SalaryRecord({
//     this.id,
//     required this.employeeId,
//     required this.employeeName,
//     required this.employeeType,
//     this.designation,
//     required this.year,
//     required this.month,
//     required this.mode,
//     required this.baseSalary,
//     required this.totalDaysInMonth,
//     required this.workingDays,
//     required this.leaves,
//     required this.perDayRate,
//     required this.absentDeduction,
//     this.fine = 0,
//     this.bonus = 0,
//     this.note,
//     required this.netSalary,
//     this.status = 'Pending',
//     this.createdAt,
//     this.paidAt,
//   });
//
//   Map<String, dynamic> toMap() {
//     final map = <String, dynamic>{
//       'employeeId': employeeId,
//       'employeeName': employeeName,
//       'employeeType': employeeType,
//       'designation': designation,
//       'year': year,
//       'month': month,
//       'mode': mode,
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
//       'status': status,
//       'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
//     };
//
//     if (paidAt != null) {
//       map['paidAt'] = Timestamp.fromDate(paidAt!);
//     }
//
//     return map;
//   }
//
//   factory SalaryRecord.fromMap(Map<String, dynamic> map, String id) {
//     DateTime? paid;
//     if (map['paidAt'] != null) {
//       if (map['paidAt'] is Timestamp) {
//         paid = (map['paidAt'] as Timestamp).toDate();
//       }
//     }
//
//     return SalaryRecord(
//       id: id,
//       employeeId: map['employeeId'] ?? '',
//       employeeName: map['employeeName'] ?? '',
//       employeeType: map['employeeType'] ?? 'staff',
//       designation: map['designation'] as String?,
//       year: (map['year'] ?? DateTime.now().year) as int,
//       month: (map['month'] ?? DateTime.now().month) as int,
//       mode: map['mode'] ?? 'attendance',
//       baseSalary: (map['baseSalary'] ?? 0).toDouble(),
//       totalDaysInMonth: (map['totalDaysInMonth'] ?? 30) as int,
//       workingDays: (map['workingDays'] ?? 30) as int,
//       leaves: (map['leaves'] ?? 0) as int,
//       perDayRate: (map['perDayRate'] ?? 0).toDouble(),
//       absentDeduction: (map['absentDeduction'] ?? 0).toDouble(),
//       fine: (map['fine'] ?? 0).toDouble(),
//       bonus: (map['bonus'] ?? 0).toDouble(),
//       note: map['note'] as String?,
//       netSalary: (map['netSalary'] ?? 0).toDouble(),
//       status: map['status'] ?? 'Pending',
//       createdAt: map['createdAt'] != null && map['createdAt'] is Timestamp
//           ? (map['createdAt'] as Timestamp).toDate()
//           : null,
//       paidAt: paid,
//     );
//   }
// }


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

  // ★ NEW – true when this salary was generated as (or marked as) the
  // employee's termination salary. Used to highlight/badge the record in
  // the Salary List, and to know that deleting this record should
  // automatically reinstate the employee.
  final bool isTerminated;

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
    this.isTerminated = false,   // ★ NEW default: not a termination record
    this.createdAt,
    this.paidAt,
  });

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
      'isTerminated': isTerminated, // ★ NEW
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
      // ★ NEW – default false so existing old records stay non-terminated
      isTerminated: map['isTerminated'] ?? false,
      createdAt: map['createdAt'] != null && map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      paidAt: paid,
    );
  }
}