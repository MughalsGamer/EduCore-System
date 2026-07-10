
class AttendanceRecord {
  final String id; // Combines staffId + date: e.g., STD-001_2026-07-07
  final String staffId;
  final String staffName;
  final String? photoBase64;
  final String type; // 'teacher' or 'staff'
  final String date; // 'yyyy-MM-dd'
  String status; // present, absent, late, leave, half_day
  String remarks;
  final String? designation; // from StaffMember, shown under name
  bool isSaved; // true if this record already exists in Firestore for this date
  // ★ NEW: true only while a save/update network call for this specific
  // record is in-flight (used by the History screen's per-row spinner).
  bool isSaving;

  AttendanceRecord({
    required this.id,
    required this.staffId,
    required this.staffName,
    this.photoBase64,
    required this.type,
    required this.date,
    this.status = 'present',
    this.remarks = '',
    this.designation,
    this.isSaved = false,
    this.isSaving = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staffId': staffId,
      'staffName': staffName,
      'type': type,
      'date': date,
      'status': status,
      'remarks': remarks,
      // 'timestamp' will be added by Firestore service
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceRecord(
      id: id,
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      photoBase64: map['photoBase64'],
      type: map['type'] ?? 'staff',
      date: map['date'] ?? '',
      status: map['status'] ?? 'present',
      remarks: map['remarks'] ?? '',
      isSaved: true, // ★ anything coming FROM Firestore is, by definition, saved
    );
  }
}


