import 'package:cloud_firestore/cloud_firestore.dart';
import 'admission_model.dart';

// ─────────────────────────────────────────────
//  Lightweight reference to a student inside a family
// ─────────────────────────────────────────────
class FamilyStudentRef {
  String studentId;
  String name;
  String admissionId;      // Firestore doc id of the admission record
  String inquiryOrRegId;   // Human-readable INQ-0001 / REG-0001
  AdmissionType type;      // preAdmission / regular — updated on conversion

  FamilyStudentRef({
    required this.studentId,
    required this.name,
    required this.admissionId,
    required this.inquiryOrRegId,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'name': name,
    'admissionId': admissionId,
    'inquiryOrRegId': inquiryOrRegId,
    'type': type.value,
  };

  factory FamilyStudentRef.fromMap(Map<String, dynamic> m) => FamilyStudentRef(
    studentId: m['studentId'] ?? '',
    name: m['name'] ?? '',
    admissionId: m['admissionId'] ?? '',
    inquiryOrRegId: m['inquiryOrRegId'] ?? '',
    type: AdmissionTypeExt.fromString(m['type'] ?? 'pre_admission'),
  );
}

// ─────────────────────────────────────────────
//  Family Model — stored in its own `families` collection
// ─────────────────────────────────────────────
class FamilyModel {
  String? docId;          // Firestore auto doc ID (internal, unique)
  String familyId;        // Human-readable ID shown in UI, e.g. KHA-0001
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

  List<FamilyStudentRef> students;

  FamilyModel({
    this.docId,
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
    List<FamilyStudentRef>? students,
  }) : students = students ?? [];

  Map<String, dynamic> toMap() => {
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
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory FamilyModel.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return FamilyModel(
      docId: doc.id,
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
          ?.map((s) => FamilyStudentRef.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList() ??
          [],
    );
  }

  /// Number of pre-admission students currently linked to this family.
  int get preAdmissionCount =>
      students.where((s) => s.type == AdmissionType.preAdmission).length;

  /// Number of regular-admission students currently linked to this family.
  int get regularCount =>
      students.where((s) => s.type == AdmissionType.regular).length;
}

