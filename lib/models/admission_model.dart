import 'dart:convert';

class ParentModel {
  String fatherName;
  String fatherCNIC;
  String occupation;
  String phone;
  String motherName;
  String motherCNIC;
  String address;
  String city;

  ParentModel({
    this.fatherName = '',
    this.fatherCNIC = '',
    this.occupation = '',
    this.phone = '',
    this.motherName = '',
    this.motherCNIC = '',
    this.address = '',
    this.city = '',
  });

  Map<String, dynamic> toMap() => {
    'fatherName': fatherName,
    'fatherCNIC': fatherCNIC,
    'occupation': occupation,
    'phone': phone,
    'motherName': motherName,
    'motherCNIC': motherCNIC,
    'address': address,
    'city': city,
  };

  factory ParentModel.fromMap(Map<String, dynamic> map) => ParentModel(
    fatherName: map['fatherName'] ?? '',
    fatherCNIC: map['fatherCNIC'] ?? '',
    occupation: map['occupation'] ?? '',
    phone: map['phone'] ?? '',
    motherName: map['motherName'] ?? '',
    motherCNIC: map['motherCNIC'] ?? '',
    address: map['address'] ?? '',
    city: map['city'] ?? '',
  );
}

class StudentModel {
  String studentId; // auto-generated
  String rollNo;
  String studentName;
  String bFormCNIC;
  DateTime? dob;
  String studentClass;
  String section;
  // fees
  double monthlyFee;
  double booksCharges;
  double uniformCharges;
  double stationeryCharges;
  double transportFee;
  double securityFee;
  String? studentPictureBase64;

  StudentModel({
    this.studentId = '',
    this.rollNo = '',
    this.studentName = '',
    this.bFormCNIC = '',
    this.dob,
    this.studentClass = '',
    this.section = '',
    this.monthlyFee = 0.0,
    this.booksCharges = 0.0,
    this.uniformCharges = 0.0,
    this.stationeryCharges = 0.0,
    this.transportFee = 0.0,
    this.securityFee = 0.0,
    this.studentPictureBase64,
  });

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'rollNo': rollNo,
    'studentName': studentName,
    'bFormCNIC': bFormCNIC,
    'dob': dob?.toIso8601String(),
    'class': studentClass,
    'section': section,
    'monthlyFee': monthlyFee,
    'booksCharges': booksCharges,
    'uniformCharges': uniformCharges,
    'stationeryCharges': stationeryCharges,
    'transportFee': transportFee,
    'securityFee': securityFee,
    'studentPictureBase64': studentPictureBase64,
  };

  factory StudentModel.fromMap(Map<String, dynamic> map) => StudentModel(
    studentId: map['studentId'] ?? '',
    rollNo: map['rollNo'] ?? '',
    studentName: map['studentName'] ?? '',
    bFormCNIC: map['bFormCNIC'] ?? '',
    dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
    studentClass: map['class'] ?? '',
    section: map['section'] ?? '',
    monthlyFee: (map['monthlyFee'] ?? 0).toDouble(),
    booksCharges: (map['booksCharges'] ?? 0).toDouble(),
    uniformCharges: (map['uniformCharges'] ?? 0).toDouble(),
    stationeryCharges: (map['stationeryCharges'] ?? 0).toDouble(),
    transportFee: (map['transportFee'] ?? 0).toDouble(),
    securityFee: (map['securityFee'] ?? 0).toDouble(),
    studentPictureBase64: map['studentPictureBase64'],
  );
}

class AdmissionModel {
  String? id;
  String type; // 'family' or 'individual'
  String admissionNo;
  DateTime? admissionDate;
  String? previousClass;
  String? previousSchool;
  // family fields (only for type 'family')
  String? familyId;
  String? familyName;
  ParentModel parent;
  List<StudentModel> children;

  AdmissionModel({
    this.id,
    this.type = 'individual',
    this.admissionNo = '',
    this.admissionDate,
    this.previousClass,
    this.previousSchool,
    this.familyId,
    this.familyName,
    ParentModel? parent,
    List<StudentModel>? children,
  })  : parent = parent ?? ParentModel(),
        children = children ?? [];

  Map<String, dynamic> toMap() => {
    'type': type,
    'admissionNo': admissionNo,
    'admissionDate': admissionDate?.toIso8601String(),
    'previousClass': previousClass,
    'previousSchool': previousSchool,
    'familyId': familyId,
    'familyName': familyName,
    'parent': parent.toMap(),
    'children': children.map((e) => e.toMap()).toList(),
  };

  factory AdmissionModel.fromMap(Map<String, dynamic> map, {String? id}) =>
      AdmissionModel(
        id: id,
        type: map['type'] ?? 'individual',
        admissionNo: map['admissionNo'] ?? '',
        admissionDate: map['admissionDate'] != null
            ? DateTime.tryParse(map['admissionDate'])
            : null,
        previousClass: map['previousClass'],
        previousSchool: map['previousSchool'],
        familyId: map['familyId'],
        familyName: map['familyName'],
        parent: ParentModel.fromMap(map['parent'] ?? {}),
        children: (map['children'] as List<dynamic>?)
            ?.map((e) => StudentModel.fromMap(e as Map<String, dynamic>))
            .toList() ??
            [],
      );
}