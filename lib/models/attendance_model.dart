
class AttendanceRecord {
  final String id; // Combines staffId + date: e.g., STD-001_2026-07-07
  final String staffId;
  final String staffName;
  final String? photoBase64;
  final String type; // 'teacher' or 'staff'
  final String date; // 'yyyy-MM-dd'

  // present, absent, late, leave, half_day, holiday
  // ★ 'holiday' is a new status used for Sundays (or any day marked as a
  // holiday) where no attendance is expected, so such days are never
  // auto-marked 'absent'.
  String status;
  String remarks;
  final String? designation; // from StaffMember, shown under name
  bool isSaved; // true if this record already exists in Firestore for this date
  // ★ true only while a save/update network call for this specific
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

  /// ★ True if [date] ('yyyy-MM-dd') falls on a Sunday.
  /// Used to auto-treat Sundays as holidays instead of "absent" whenever
  /// no explicit attendance record exists yet for that day.
  bool get isSunday {
    try {
      return DateTime.parse(date).weekday == DateTime.sunday;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staffId': staffId,
      'staffName': staffName,
      'photoBase64': photoBase64,
      'type': type,
      'date': date,
      'status': status,
      'remarks': remarks,
      'designation': designation,
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
      designation: map['designation'],
      isSaved: true, // ★ anything coming FROM Firestore is, by definition, saved
    );
  }
}