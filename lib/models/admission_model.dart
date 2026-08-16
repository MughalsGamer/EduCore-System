
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
//  Academy Model
// ─────────────────────────────────────────────
class Academy {
  final String id;
  final String name;
  Academy({required this.id, required this.name});

  factory Academy.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Academy(id: doc.id, name: data['name'] ?? '');
  }
}

// ─────────────────────────────────────────────
//  Admission Type Enum
// ─────────────────────────────────────────────
enum AdmissionType { preAdmission, regular }

extension AdmissionTypeExt on AdmissionType {
  String get label =>
      this == AdmissionType.preAdmission ? 'Pre-Admission' : 'Regular Admission';
  String get value =>
      this == AdmissionType.preAdmission ? 'pre_admission' : 'regular';

  static AdmissionType fromString(String v) =>
      v == 'pre_admission' ? AdmissionType.preAdmission : AdmissionType.regular;
}

// ─────────────────────────────────────────────
//  Student Status Enum (mirrors StaffMember's active/terminated pattern)
// ─────────────────────────────────────────────
enum StudentDeactivationReason { leftSchool, terminated }

extension StudentDeactivationReasonExt on StudentDeactivationReason {
  String get label => this == StudentDeactivationReason.leftSchool
      ? 'Left School'
      : 'Terminated';
  String get value => this == StudentDeactivationReason.leftSchool
      ? 'left_school'
      : 'terminated';

  static StudentDeactivationReason fromString(String? v) =>
      v == 'terminated'
          ? StudentDeactivationReason.terminated
          : StudentDeactivationReason.leftSchool;
}

// ─────────────────────────────────────────────
//  Student status history event (joined / deactivated / rejoined)
// ─────────────────────────────────────────────

class StudentStatusEvent {
  String type; // 'joined' | 'deactivated' | 'rejoined' | 'promoted' | 'demoted'
  String date;
  String? reason;
  String? note;
  String? fromClass;    // NEW
  String? toClass;      // NEW
  String? fromSection;  // NEW
  String? toSection;    // NEW

  StudentStatusEvent({
    required this.type,
    required this.date,
    this.reason,
    this.note,
    this.fromClass,
    this.toClass,
    this.fromSection,
    this.toSection,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'date': date,
    'reason': reason,
    'note': note,
    'fromClass': fromClass,
    'toClass': toClass,
    'fromSection': fromSection,
    'toSection': toSection,
  };

  factory StudentStatusEvent.fromMap(Map<String, dynamic> m) =>
      StudentStatusEvent(
        type: m['type'] ?? '',
        date: m['date'] ?? '',
        reason: m['reason'],
        note: m['note'],
        fromClass: m['fromClass'],
        toClass: m['toClass'],
        fromSection: m['fromSection'],
        toSection: m['toSection'],
      );
}

// class StudentStatusEvent {
//   String type; // 'joined' | 'deactivated' | 'rejoined'
//   String date; // ISO date string (yyyy-MM-dd)
//   String? reason; // only for 'deactivated' events
//   String? note;
//
//   StudentStatusEvent({
//     required this.type,
//     required this.date,
//     this.reason,
//     this.note,
//   });
//
//   Map<String, dynamic> toMap() => {
//     'type': type,
//     'date': date,
//     'reason': reason,
//     'note': note,
//   };
//
//   factory StudentStatusEvent.fromMap(Map<String, dynamic> m) =>
//       StudentStatusEvent(
//         type: m['type'] ?? '',
//         date: m['date'] ?? '',
//         reason: m['reason'],
//         note: m['note'],
//       );
// }


class AdmissionStudent {
  String studentId;
  String name;
  String? picBase64;
  String? classId;
  String? className;
  String? sectionId;
  String? sectionName;
  String? classRollNo;
  String? bFormCnic;
  DateTime? dob;
  double? annualFee;
  double? registrationFee;
  double? monthlyFee;

  // ─── Institution selections ───
  bool hasSchool;
  bool hasAcademy;

  // Academy
  String? academyId;
  String? academyName;
  double? academyFee;

  // ─── Status (active / deactivated) ───
  bool isActive;
  String? deactivationDate; // ISO date string
  String? deactivationReason; // 'left_school' | 'terminated'
  String? deactivationNote;
  List<StudentStatusEvent> statusHistory;
  bool rebillAnnualFeeOnce;


  AdmissionStudent({
    this.studentId = '',
    this.name = '',
    this.picBase64,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.classRollNo,
    this.bFormCnic,
    this.dob,
    this.annualFee,
    this.registrationFee,
    this.monthlyFee,
    this.hasSchool = true,
    this.hasAcademy = false,
    this.academyId,
    this.academyName,
    this.academyFee,
    this.isActive = true,
    this.deactivationDate,
    this.deactivationReason,
    this.deactivationNote,
    List<StudentStatusEvent>? statusHistory,
    this.rebillAnnualFeeOnce = false,

  }) : statusHistory = statusHistory ?? [];

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'name': name,
    'picBase64': picBase64,
    'classId': classId,
    'className': className,
    'sectionId': sectionId,
    'sectionName': sectionName,
    'classRollNo': classRollNo,
    'bFormCnic': bFormCnic,
    'dob': dob?.toIso8601String(),
    'annualFee': annualFee,
    'registrationFee': registrationFee,
    'monthlyFee': monthlyFee,
    'hasSchool': hasSchool,
    'hasAcademy': hasAcademy,
    'academyId': academyId,
    'academyName': academyName,
    'academyFee': academyFee,
    'isActive': isActive,
    'deactivationDate': deactivationDate,
    'deactivationReason': deactivationReason,
    'deactivationNote': deactivationNote,
    'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
    'rebillAnnualFeeOnce': rebillAnnualFeeOnce,
  };

  factory AdmissionStudent.fromMap(Map<String, dynamic> m) => AdmissionStudent(
    studentId: m['studentId'] ?? '',
    name: m['name'] ?? '',
    picBase64: m['picBase64'],
    classId: m['classId'],
    className: m['className'],
    sectionId: m['sectionId'],
    sectionName: m['sectionName'],
    classRollNo: m['classRollNo'],
    bFormCnic: m['bFormCnic'],
    dob: m['dob'] != null ? DateTime.tryParse(m['dob']) : null,
    annualFee: m['annualFee']?.toDouble(),
    registrationFee: m['registrationFee']?.toDouble(),
    monthlyFee: m['monthlyFee']?.toDouble(),
    hasSchool: m['hasSchool'] ?? true,
    hasAcademy: m['hasAcademy'] ?? false,
    academyId: m['academyId'],
    academyName: m['academyName'],
    academyFee: m['academyFee']?.toDouble(),
    isActive: m['isActive'] ?? true,
    deactivationDate: m['deactivationDate'],
    deactivationReason: m['deactivationReason'],
    deactivationNote: m['deactivationNote'],
    statusHistory: (m['statusHistory'] as List<dynamic>?)
        ?.map((e) => StudentStatusEvent.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList() ??
        [],
    rebillAnnualFeeOnce: m['rebillAnnualFeeOnce'] ?? false,

  );

  AdmissionStudent copyWith({
    String? studentId,
    String? name,
    String? picBase64,
    String? classId,
    String? className,
    String? sectionId,
    String? sectionName,
    String? classRollNo,
    String? bFormCnic,
    DateTime? dob,
    double? annualFee,
    double? registrationFee,
    double? monthlyFee,
    bool? hasSchool,
    bool? hasAcademy,
    String? academyId,
    String? academyName,
    double? academyFee,
    bool? isActive,
    String? deactivationDate,
    String? deactivationReason,
    String? deactivationNote,
    List<StudentStatusEvent>? statusHistory,
    bool? rebillAnnualFeeOnce,

  }) =>
      AdmissionStudent(
        studentId: studentId ?? this.studentId,
        name: name ?? this.name,
        picBase64: picBase64 ?? this.picBase64,
        classId: classId ?? this.classId,
        className: className ?? this.className,
        sectionId: sectionId ?? this.sectionId,
        sectionName: sectionName ?? this.sectionName,
        classRollNo: classRollNo ?? this.classRollNo,
        bFormCnic: bFormCnic ?? this.bFormCnic,
        dob: dob ?? this.dob,
        annualFee: annualFee ?? this.annualFee,
        registrationFee: registrationFee ?? this.registrationFee,
        monthlyFee: monthlyFee ?? this.monthlyFee,
        hasSchool: hasSchool ?? this.hasSchool,
        hasAcademy: hasAcademy ?? this.hasAcademy,
        academyId: academyId ?? this.academyId,
        academyName: academyName ?? this.academyName,
        academyFee: academyFee ?? this.academyFee,
        isActive: isActive ?? this.isActive,
        deactivationDate: deactivationDate ?? this.deactivationDate,
        deactivationReason: deactivationReason ?? this.deactivationReason,
        deactivationNote: deactivationNote ?? this.deactivationNote,
        statusHistory: statusHistory ?? this.statusHistory,
        rebillAnnualFeeOnce: rebillAnnualFeeOnce ?? this.rebillAnnualFeeOnce,

      );
}

// ─────────────────────────────────────────────
//  Main Admission Model
// ─────────────────────────────────────────────
class AdmissionModel {
  String? id;
  AdmissionType type;
  String inquiryOrRegId;
  DateTime admissionDate;
  String? previousSchoolName;
  String? previousClassName;
  String? previousClassMarks;
  String familyDocId;
  String familyId;
  String familyName;
  String fatherName;
  String? fatherOccupation;
  String? fatherCnic;
  String fatherPhone;
  String motherName;
  String? motherCnic;
  String? motherPhone;
  String? caste;
  String? address;
  List<AdmissionStudent> students;

  AdmissionModel({
    this.id,
    this.type = AdmissionType.preAdmission,
    this.inquiryOrRegId = '',
    DateTime? admissionDate,
    this.previousSchoolName,
    this.previousClassName,
    this.previousClassMarks,
    this.familyDocId = '',
    this.familyId = '',
    this.familyName = '',
    this.fatherName = '',
    this.fatherOccupation,
    this.fatherCnic,
    this.fatherPhone = '',
    this.motherName = '',
    this.motherCnic,
    this.motherPhone,
    this.caste,
    this.address,
    List<AdmissionStudent>? students,
  })  : admissionDate = admissionDate ?? DateTime.now(),
        students = students ?? [AdmissionStudent()];

  Map<String, dynamic> toMap() => {
    'type': type.value,
    'inquiryOrRegId': inquiryOrRegId,
    'admissionDate': admissionDate.toIso8601String(),
    'previousSchoolName': previousSchoolName,
    'previousClassName': previousClassName,
    'previousClassMarks': previousClassMarks,
    'familyDocId': familyDocId,
    'familyId': familyId,
    'familyName': familyName,
    'fatherName': fatherName,
    'fatherOccupation': fatherOccupation,
    'fatherCnic': fatherCnic,
    'fatherPhone': fatherPhone,
    'motherName': motherName,
    'motherCnic': motherCnic,
    'motherPhone': motherPhone,
    'caste': caste,
    'address': address,
    'students': students.map((s) => s.toMap()).toList(),
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory AdmissionModel.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return AdmissionModel(
      id: doc.id,
      type: AdmissionTypeExt.fromString(m['type'] ?? 'pre_admission'),
      inquiryOrRegId: m['inquiryOrRegId'] ?? '',
      admissionDate: m['admissionDate'] != null
          ? DateTime.tryParse(m['admissionDate']) ?? DateTime.now()
          : DateTime.now(),
      previousSchoolName: m['previousSchoolName'],
      previousClassName: m['previousClassName'],
      previousClassMarks: m['previousClassMarks'],
      familyDocId: m['familyDocId'] ?? '',
      familyId: m['familyId'] ?? '',
      familyName: m['familyName'] ?? '',
      fatherName: m['fatherName'] ?? '',
      fatherOccupation: m['fatherOccupation'],
      fatherCnic: m['fatherCnic'],
      fatherPhone: m['fatherPhone'] ?? '',
      motherName: m['motherName'] ?? '',
      motherCnic: m['motherCnic'],
      motherPhone: m['motherPhone'],
      caste: m['caste'],
      address: m['address'],
      students: (m['students'] as List<dynamic>?)
          ?.map((s) =>
          AdmissionStudent.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList() ??
          [AdmissionStudent()],
    );
  }
}