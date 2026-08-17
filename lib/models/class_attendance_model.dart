import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent, leave, late, halfDay }

extension AttendanceStatusExt on AttendanceStatus {
  String get value {
    switch (this) {
      case AttendanceStatus.present: return 'present';
      case AttendanceStatus.absent: return 'absent';
      case AttendanceStatus.leave: return 'leave';
      case AttendanceStatus.late: return 'late';
      case AttendanceStatus.halfDay: return 'half_day';
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present: return 'Present';
      case AttendanceStatus.absent: return 'Absent';
      case AttendanceStatus.leave: return 'Leave';
      case AttendanceStatus.late: return 'Late';
      case AttendanceStatus.halfDay: return 'Half Day';
    }
  }

  static AttendanceStatus fromString(String v) {
    switch (v) {
      case 'absent': return AttendanceStatus.absent;
      case 'leave': return AttendanceStatus.leave;
      case 'late': return AttendanceStatus.late;
      case 'half_day': return AttendanceStatus.halfDay;
      default: return AttendanceStatus.present;
    }
  }
}

class AttendanceRecord {
  String studentId;
  String name;
  AttendanceStatus status;

  AttendanceRecord({
    required this.studentId,
    required this.name,
    this.status = AttendanceStatus.present,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'status': status.value,
  };

  factory AttendanceRecord.fromMap(String studentId, Map<String, dynamic> m) =>
      AttendanceRecord(
        studentId: studentId,
        name: m['name'] ?? '',
        status: AttendanceStatusExt.fromString(m['status'] ?? 'present'),
      );
}

// ─────────────────────────────────────────────
//  One document = one class+section+date's ENTIRE attendance.
//  Doc ID = "classId_sectionId_date"  → index-free, O(1) lookup for
//  "is this already marked" (no query needed, just a doc.get()).
// ─────────────────────────────────────────────
class ClassAttendanceModel {
  String? id;
  String classId;
  String className;
  String sectionId;
  String sectionName;
  String date; // yyyy-MM-dd
  bool locked;
  DateTime? markedAt;
  String? markedBy;
  Map<String, AttendanceRecord> records; // studentId -> record

  ClassAttendanceModel({
    this.id,
    required this.classId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
    required this.date,
    this.locked = false,
    this.markedAt,
    this.markedBy,
    Map<String, AttendanceRecord>? records,
  }) : records = records ?? {};

  static String buildDocId(String classId, String sectionId, String date) =>
      '${classId}_${sectionId}_$date';

  int get presentCount => records.values.where((r) => r.status == AttendanceStatus.present).length;
  int get absentCount => records.values.where((r) => r.status == AttendanceStatus.absent).length;
  int get leaveCount => records.values.where((r) => r.status == AttendanceStatus.leave).length;
  int get lateCount => records.values.where((r) => r.status == AttendanceStatus.late).length;
  int get halfDayCount => records.values.where((r) => r.status == AttendanceStatus.halfDay).length;
  int get totalCount => records.length;

  Map<String, dynamic> toMap() => {
    'classId': classId,
    'className': className,
    'sectionId': sectionId,
    'sectionName': sectionName,
    'date': date,
    'locked': locked,
    'markedBy': markedBy,
    'markedAt': FieldValue.serverTimestamp(),
    'records': records.map((studentId, r) => MapEntry(studentId, r.toMap())),
  };

  factory ClassAttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    final rawRecords = (m['records'] as Map<String, dynamic>?) ?? {};
    return ClassAttendanceModel(
      id: doc.id,
      classId: m['classId'] ?? '',
      className: m['className'] ?? '',
      sectionId: m['sectionId'] ?? '',
      sectionName: m['sectionName'] ?? '',
      date: m['date'] ?? '',
      locked: m['locked'] ?? false,
      markedBy: m['markedBy'],
      markedAt: m['markedAt'] is Timestamp ? (m['markedAt'] as Timestamp).toDate() : null,
      records: rawRecords.map(
            (studentId, v) => MapEntry(
          studentId,
          AttendanceRecord.fromMap(studentId, Map<String, dynamic>.from(v as Map)),
        ),
      ),
    );
  }
}