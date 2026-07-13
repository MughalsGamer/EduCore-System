
class StaffMember {
  String? id;
  String type; // 'teacher' or 'staff'
  String name;
  String fatherOrHusbandName;
  String cnic;
  String dob;
  String gender;
  String maritalStatus;
  String? bloodGroup;
  String religion;
  String nationality;
  String address;
  String phone;
  String emergencyPhone;
  String employmentType;
  double salary;
  String? reference;
  String? note;
  String? imageBase64;
  List<String> assignedClasses;         // ★ existing
  List<String> assignedSections;        // ★ existing – stores full section names
  List<String> subjects;                // ★ existing
  final String? designation;
  final String? joiningDate;            // format "yyyy-MM-dd"
  bool isActive;                        // ★ NEW – false = deactivated

  StaffMember({
    this.id,
    required this.type,
    required this.name,
    required this.fatherOrHusbandName,
    required this.cnic,
    required this.dob,
    required this.gender,
    required this.maritalStatus,
    this.bloodGroup,
    required this.religion,
    required this.nationality,
    required this.address,
    required this.phone,
    required this.emergencyPhone,
    required this.employmentType,
    required this.salary,
    this.reference,
    this.note,
    this.imageBase64,
    this.assignedClasses = const [],
    this.assignedSections = const [],
    this.subjects = const [],
    this.designation,
    this.joiningDate,
    this.isActive = true,               // ★ NEW default: active
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'fatherOrHusbandName': fatherOrHusbandName,
      'cnic': cnic,
      'dob': dob,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'bloodGroup': bloodGroup,
      'religion': religion,
      'nationality': nationality,
      'address': address,
      'phone': phone,
      'emergencyPhone': emergencyPhone,
      'employmentType': employmentType,
      'salary': salary,
      'reference': reference,
      'note': note,
      'imageBase64': imageBase64,
      'assignedClasses': assignedClasses,
      'assignedSections': assignedSections,
      'subjects': subjects,
      'designation': designation,
      'joiningDate': joiningDate,
      'isActive': isActive,             // ★ NEW
    };
  }

  factory StaffMember.fromMap(Map<String, dynamic> map, String id) {
    return StaffMember(
      id: id,
      type: map['type'] ?? 'staff',
      name: map['name'] ?? '',
      fatherOrHusbandName: map['fatherOrHusbandName'] ?? '',
      cnic: map['cnic'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? 'Male',
      maritalStatus: map['maritalStatus'] ?? 'Single',
      bloodGroup: map['bloodGroup'],
      religion: map['religion'] ?? '',
      nationality: map['nationality'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      emergencyPhone: map['emergencyPhone'] ?? '',
      employmentType: map['employmentType'] ?? 'Regular',
      salary: (map['salary'] ?? 0).toDouble(),
      reference: map['reference'],
      note: map['note'],
      imageBase64: map['imageBase64'],
      assignedClasses: List<String>.from(map['assignedClasses'] ?? []),
      assignedSections: List<String>.from(map['assignedSections'] ?? []),
      subjects: List<String>.from(map['subjects'] ?? []),
      designation: map['designation'] as String?,
      joiningDate: map['joiningDate'] as String?,
      // ★ NEW – default true so existing old records (without this field) stay Active
      isActive: map['isActive'] ?? true,
    );
  }
}