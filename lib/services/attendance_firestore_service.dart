import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_model.dart';

/// Firestore access layer for attendance, following the same pattern as
/// StaffFirestoreService: a thin service class the provider calls into.
///
/// Collection: `attendance` (top-level, NOT nested under staff docs).
/// Document ID: `{staffId}_{yyyy-MM-dd}` — this makes each staff/date
/// combination unique, so re-marking the same day overwrites cleanly
/// instead of creating duplicates.
class AttendanceFirestoreService {
  final CollectionReference _attendanceRef =
  FirebaseFirestore.instance.collection('attendance');

  /// Marks (creates or overwrites) a single attendance record.
  Future<void> markAttendance(AttendanceRecord record) async {
    await _attendanceRef.doc(record.docId).set(record.toMap());
  }

  /// Marks multiple attendance records in one batched write — used by
  /// both Mode 1 (quick) and Mode 2 (calendar) screens so that selecting
  /// several staff/dates at once results in a single network round trip.
  ///
  /// Firestore batches are capped at 500 writes, so records are chunked
  /// to stay safely under that limit for very large bulk saves.
  Future<void> markMultiple(List<AttendanceRecord> records) async {
    const chunkSize = 400;
    for (var i = 0; i < records.length; i += chunkSize) {
      final chunk = records.sublist(
        i,
        i + chunkSize > records.length ? records.length : i + chunkSize,
      );
      final batch = FirebaseFirestore.instance.batch();
      for (final record in chunk) {
        batch.set(_attendanceRef.doc(record.docId), record.toMap());
      }
      await batch.commit();
    }
  }

  /// Fetches every attendance record for a single date, across all staff.
  /// Used by the View/Edit screen's "By Date" mode.
  Future<List<AttendanceRecord>> getByDate(String date) async {
    final snapshot = await _attendanceRef.where('date', isEqualTo: date).get();
    return snapshot.docs
        .map((doc) =>
        AttendanceRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Fetches every attendance record for a single staff member within a
  /// given month (yyyy-MM prefix match on the date field). Used by the
  /// View/Edit screen's "By Staff" mode.
  Future<List<AttendanceRecord>> getByStaffAndMonth(
      String staffId, String yearMonth) async {
    // yearMonth format: 'yyyy-MM'. Firestore range query on a string date
    // field works because 'yyyy-MM-dd' sorts lexicographically by date.
    // The end boundary is computed as the actual last day of the month
    // (rather than a hardcoded '-31') so short months don't accidentally
    // include stray records from an adjacent month with the same prefix.
    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final lastDay = DateTime(year, month + 1, 0).day;

    final start = '$yearMonth-01';
    final end = '$yearMonth-${lastDay.toString().padLeft(2, '0')}';

    final snapshot = await _attendanceRef
        .where('staffId', isEqualTo: staffId)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();
    final list = snapshot.docs
        .map((doc) =>
        AttendanceRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Updates just the status of an already-marked record (View/Edit screen).
  Future<void> updateStatus(AttendanceRecord record, String newStatus) async {
    final updated = record.copyWith(status: newStatus);
    await _attendanceRef.doc(updated.docId).set(updated.toMap());
  }

  /// Deletes a single attendance record (in case a mistaken entry needs
  /// to be removed entirely rather than just re-statused).
  Future<void> deleteRecord(String docId) async {
    await _attendanceRef.doc(docId).delete();
  }
}