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
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
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
//       // createdAt is set server-side via FieldValue.serverTimestamp()
//       // by the Firestore service, matching the rest of the app's pattern.
//     };
//   }
//
//   factory SalaryRecord.fromMap(Map<String, dynamic> map, String id) {
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
//       createdAt: map['createdAt'] != null && map['createdAt'] is! String
//           ? (map['createdAt'].toDate())
//           : null,
//     );
//   }
// }

// models/salary_model.dart
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

  final DateTime? createdAt;

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
    this.createdAt,
  });

  /// Creates a copy with overridden fields – useful for editing
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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      // createdAt is set server‑side via FieldValue.serverTimestamp()
      // by the Firestore service, so we don't include it here.
    };
  }

  factory SalaryRecord.fromMap(Map<String, dynamic> map, String id) {
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
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'].toString()))
          : null,
    );
  }
}