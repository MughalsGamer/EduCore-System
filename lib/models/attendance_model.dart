/// A single attendance record for one staff/teacher member on one date.
///
/// Firestore structure (confirmed):
///   Collection: `attendance` (top-level)
///   Document ID: `{staffId}_{yyyy-MM-dd}`  → unique per staff per day
///   Fields: staffId, staffName, staffType, date, status, markedAt
class AttendanceRecord {
  final String staffId;
  final String staffName;
  final String staffType; // 'teacher' or 'staff'
  final String date; // format: yyyy-MM-dd
  final String status; // 'Present' | 'Absent' | 'Leave' | 'Half Day'
  final DateTime? markedAt;

  AttendanceRecord({
    required this.staffId,
    required this.staffName,
    required this.staffType,
    required this.date,
    required this.status,
    this.markedAt,
  });

  /// Firestore document id: unique per staff per day.
  String get docId => '${staffId}_$date';

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'staffType': staffType,
      'date': date,
      'status': status,
      'markedAt':
      markedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      staffType: map['staffType'] ?? 'staff',
      date: map['date'] ?? '',
      status: map['status'] ?? 'Present',
      markedAt: map['markedAt'] != null
          ? DateTime.tryParse(map['markedAt'].toString())
          : null,
    );
  }

  /// Returns a copy of this record with an updated status (used when
  /// editing already-marked attendance from the View/Edit screen).
  AttendanceRecord copyWith({String? status}) {
    return AttendanceRecord(
      staffId: staffId,
      staffName: staffName,
      staffType: staffType,
      date: date,
      status: status ?? this.status,
      markedAt: DateTime.now(),
    );
  }

  /// Safely parses [date] (yyyy-MM-dd). Returns null instead of throwing
  /// if the stored value is ever malformed, so the UI can fall back
  /// gracefully instead of crashing the whole list.
  DateTime? get parsedDate => DateTime.tryParse(date);
}