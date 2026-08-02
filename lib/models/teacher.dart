//
//
// /// A single entry in a staff member's employment history —
// /// e.g. Joined / Terminated / Rejoined — with the date and an optional note.
// class StatusEvent {
//   final String type;   // 'joined' | 'terminated' | 'rejoined'
//   final String date;   // format "yyyy-MM-dd"
//   final String? note;
//
//   StatusEvent({
//     required this.type,
//     required this.date,
//     this.note,
//   });
//
//   Map<String, dynamic> toMap() => {
//     'type': type,
//     'date': date,
//     'note': note,
//   };
//
//   factory StatusEvent.fromMap(Map<String, dynamic> map) => StatusEvent(
//     type: map['type'] ?? '',
//     date: map['date'] ?? '',
//     note: map['note'] as String?,
//   );
// }
//
// class StaffMember {
//   String? id;
//   String type; // 'teacher' or 'staff'
//   String name;
//   String fatherOrHusbandName;
//   String cnic;
//   String dob;
//   String gender;
//   String maritalStatus;
//   String? bloodGroup;
//   String religion;
//   String nationality;
//   String address;
//   String phone;
//   String emergencyPhone;
//   String employmentType;
//   double salary;
//   String? reference;
//   String? note;
//   String? imageBase64;
//   List<String> assignedClasses;
//   List<String> assignedSections;
//   List<String> subjects;
//   final String? designation;
//   final String? joiningDate;
//   bool isActive;
//   bool isTerminated;
//   String? terminationDate;
//   String? terminationNote;
//   List<StatusEvent> statusHistory;
//
//
//   // ─── Add this getter here ───
//   String? get effectiveJoiningDate {
//     // Collect all 'joined' or 'rejoined' events from statusHistory
//     final events = statusHistory
//         .where((e) => e.type == 'joined' || e.type == 'rejoined')
//         .toList();
//
//     if (events.isNotEmpty) {
//       // Sort by date descending (most recent first)
//       events.sort((a, b) => b.date.compareTo(a.date));
//       return events.first.date;
//     }
//
//     // Fallback to the original joining date if no history exists
//     return joiningDate;
//   }
//
//
//   StaffMember({
//     this.id,
//     required this.type,
//     required this.name,
//     required this.fatherOrHusbandName,
//     required this.cnic,
//     required this.dob,
//     required this.gender,
//     required this.maritalStatus,
//     this.bloodGroup,
//     required this.religion,
//     required this.nationality,
//     required this.address,
//     required this.phone,
//     required this.emergencyPhone,
//     required this.employmentType,
//     required this.salary,
//     this.reference,
//     this.note,
//     this.imageBase64,
//     this.assignedClasses = const [],
//     this.assignedSections = const [],
//     this.subjects = const [],
//     this.designation,
//     this.joiningDate,
//     this.isActive = true,
//     this.isTerminated = false,
//     this.terminationDate,
//     this.terminationNote,
//     List<StatusEvent>? statusHistory,
//   }) : statusHistory = statusHistory ?? [];
//
//   Map<String, dynamic> toMap() {
//     return {
//       'type': type,
//       'name': name,
//       'fatherOrHusbandName': fatherOrHusbandName,
//       'cnic': cnic,
//       'dob': dob,
//       'gender': gender,
//       'maritalStatus': maritalStatus,
//       'bloodGroup': bloodGroup,
//       'religion': religion,
//       'nationality': nationality,
//       'address': address,
//       'phone': phone,
//       'emergencyPhone': emergencyPhone,
//       'employmentType': employmentType,
//       'salary': salary,
//       'reference': reference,
//       'note': note,
//       'imageBase64': imageBase64,
//       'assignedClasses': assignedClasses,
//       'assignedSections': assignedSections,
//       'subjects': subjects,
//       'designation': designation,
//       'joiningDate': joiningDate,
//       'isActive': isActive,
//       'isTerminated': isTerminated,
//       'terminationDate': terminationDate,
//       'terminationNote': terminationNote,
//       'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
//     };
//   }
//
//   factory StaffMember.fromMap(Map<String, dynamic> map, String id) {
//     return StaffMember(
//       id: id,
//       type: map['type'] ?? 'staff',
//       name: map['name'] ?? '',
//       fatherOrHusbandName: map['fatherOrHusbandName'] ?? '',
//       cnic: map['cnic'] ?? '',
//       dob: map['dob'] ?? '',
//       gender: map['gender'] ?? 'Male',
//       maritalStatus: map['maritalStatus'] ?? 'Single',
//       bloodGroup: map['bloodGroup'],
//       religion: map['religion'] ?? '',
//       nationality: map['nationality'] ?? '',
//       address: map['address'] ?? '',
//       phone: map['phone'] ?? '',
//       emergencyPhone: map['emergencyPhone'] ?? '',
//       employmentType: map['employmentType'] ?? 'Regular',
//       salary: (map['salary'] ?? 0).toDouble(),
//       reference: map['reference'],
//       note: map['note'],
//       imageBase64: map['imageBase64'],
//       assignedClasses: List<String>.from(map['assignedClasses'] ?? []),
//       assignedSections: List<String>.from(map['assignedSections'] ?? []),
//       subjects: List<String>.from(map['subjects'] ?? []),
//       designation: map['designation'] as String?,
//       joiningDate: map['joiningDate'] as String?,
//       isActive: map['isActive'] ?? true,
//       isTerminated: map['isTerminated'] ?? false,
//       terminationDate: map['terminationDate'] as String?,
//       terminationNote: map['terminationNote'] as String?,
//       statusHistory: (map['statusHistory'] as List<dynamic>? ?? [])
//           .map((e) => StatusEvent.fromMap(Map<String, dynamic>.from(e)))
//           .toList(),
//     );
//   }
// }
//


/// A single entry in a staff member's employment history —
/// e.g. Joined / Terminated / Rejoined — with the date and an optional note.
class StatusEvent {
  final String type;   // 'joined' | 'terminated' | 'rejoined'
  final String date;   // format "yyyy-MM-dd"
  final String? note;

  StatusEvent({
    required this.type,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'date': date,
    'note': note,
  };

  factory StatusEvent.fromMap(Map<String, dynamic> map) => StatusEvent(
    type: map['type'] ?? '',
    date: map['date'] ?? '',
    note: map['note'] as String?,
  );
}

class StaffMember {
  String? id;
  String type; // 'teacher' | 'school_staff' | 'academy_staff'
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
  List<String> assignedClasses;
  List<String> assignedSections;
  List<String> subjects;
  final String? designation;
  final String? joiningDate;
  bool isActive;
  bool isTerminated;
  String? terminationDate;
  String? terminationNote;
  List<StatusEvent> statusHistory;


  // ─── Add this getter here ───
  String? get effectiveJoiningDate {
    // Collect all 'joined' or 'rejoined' events from statusHistory
    final events = statusHistory
        .where((e) => e.type == 'joined' || e.type == 'rejoined')
        .toList();

    if (events.isNotEmpty) {
      // Sort by date descending (most recent first)
      events.sort((a, b) => b.date.compareTo(a.date));
      return events.first.date;
    }

    // Fallback to the original joining date if no history exists
    return joiningDate;
  }


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
    this.isActive = true,
    this.isTerminated = false,
    this.terminationDate,
    this.terminationNote,
    List<StatusEvent>? statusHistory,
  }) : statusHistory = statusHistory ?? [];

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
      'isActive': isActive,
      'isTerminated': isTerminated,
      'terminationDate': terminationDate,
      'terminationNote': terminationNote,
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
    };
  }

  factory StaffMember.fromMap(Map<String, dynamic> map, String id) {
    return StaffMember(
      id: id,
      type: map['type'] ?? 'school_staff',
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
      isActive: map['isActive'] ?? true,
      isTerminated: map['isTerminated'] ?? false,
      terminationDate: map['terminationDate'] as String?,
      terminationNote: map['terminationNote'] as String?,
      statusHistory: (map['statusHistory'] as List<dynamic>? ?? [])
          .map((e) => StatusEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
