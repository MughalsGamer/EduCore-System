import 'package:cloud_firestore/cloud_firestore.dart';

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
//  Student Entry (per student inside one admission)
// ─────────────────────────────────────────────
class AdmissionStudent {
  String studentId;       // Auto-generated 6-digit
  String name;
  String? picBase64;
  String? classId;
  String? className;
  String? sectionId;
  String? sectionName;
  String? classRollNo;
  String? bFormCnic;      // Optional in Pre-Admission
  DateTime? dob;
  double? annualFee;
  double? registrationFee;
  double? monthlyFee;

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
  });

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
      );
}

// ─────────────────────────────────────────────
//  Main Admission Model
// ─────────────────────────────────────────────
class AdmissionModel {
  String? id;
  AdmissionType type;

  // Auto-generated IDs
  String inquiryOrRegId;   // Inquiry ID (Pre) / Registration ID (Regular)
  DateTime admissionDate;  // Inquiry date / Registration date

  // Previous school info
  String? previousSchoolName;
  String? previousClassName;
  String? previousClassMarks;

  // Family
  String familyId;         // Auto-generated: first3(familyName) + 0001
  String familyName;       // Used to generate familyId

  // Parent Details
  String fatherName;
  String? fatherOccupation; // Optional in Pre-Admission
  String? fatherCnic;       // Optional in Pre-Admission
  String fatherPhone;
  String motherName;
  String? motherCnic;
  String? motherPhone;
  String? caste;
  String? address;

  // Students list (1 or more)
  List<AdmissionStudent> students;

  AdmissionModel({
    this.id,
    this.type = AdmissionType.preAdmission,
    this.inquiryOrRegId = '',
    DateTime? admissionDate,
    this.previousSchoolName,
    this.previousClassName,
    this.previousClassMarks,
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
          ?.map((s) => AdmissionStudent.fromMap(s as Map<String, dynamic>))
          .toList() ??
          [AdmissionStudent()],
    );
  }
}