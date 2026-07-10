
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/attendance_model.dart';

class AttendanceFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch attendance for a specific date
  Future<List<AttendanceRecord>> getAttendanceForDate(String date) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('date', isEqualTo: date)
        .get();

    return snapshot.docs.map((doc) {
      return AttendanceRecord.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // Fetch all attendance records for one staff/teacher within a
  // given month. `startDate`/`endDate` are 'yyyy-MM-dd' strings
  // (inclusive), used with a simple string range query since `date` is
  // stored as a sortable 'yyyy-MM-dd' string.
  //
  // ★ FIX (root cause of the infinite "By Person" spinner):
  // This query combines an equality filter (staffId) with a range
  // filter (date >= / date <=) on TWO different fields. Firestore
  // requires a composite index for that combination — without it the
  // query throws `failed-precondition` the very first time it runs.
  // The old code had no try/catch anywhere in the call chain, so the
  // exception was silently swallowed by the Future and
  // `_historyLoading = false` never ran → spinner span forever.
  //
  // Fixes applied here:
  //   1. try/catch so a failure is never silent again.
  //   2. `.orderBy` removed from the query itself (we already sort
  //      client-side below) to avoid requiring an even bigger composite
  //      index — matches the pattern already used elsewhere in this
  //      codebase (admissions module) to dodge composite-index errors.
  //   3. On error, rethrow a clear message so the provider can surface
  //      it instead of hanging.
  //
  // NOTE: You still need ONE composite index for staffId + date range.
  // On first run, check your debug console — Firestore prints a direct
  // link to auto-create it. Or create manually in Firebase Console:
  // Collection: attendance | Fields: staffId (Asc), date (Asc)
  Future<List<AttendanceRecord>> getAttendanceForStaffInRange({
    required String staffId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('staffId', isEqualTo: staffId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      final records = snapshot.docs.map((doc) {
        return AttendanceRecord.fromMap(doc.data(), doc.id);
      }).toList();

      records.sort((a, b) => a.date.compareTo(b.date));
      return records;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('getAttendanceForStaffInRange failed: $e\n$st');
      }
      // Rethrow so the provider's try/catch can stop the loading
      // spinner and the UI can show a real error instead of hanging.
      rethrow;
    }
  }

  // Save all records in a single batch transaction
  Future<void> saveAttendance(List<AttendanceRecord> records) async {
    // ★ FIX: chunk into batches of 450 (Firestore hard limit is 500
    // writes per batch) so this doesn't silently fail/truncate once a
    // school has more than ~500 staff+teachers combined.
    const chunkSize = 450;
    for (var i = 0; i < records.length; i += chunkSize) {
      final chunk = records.sublist(
        i,
        (i + chunkSize > records.length) ? records.length : i + chunkSize,
      );
      final batch = _firestore.batch();
      for (final record in chunk) {
        final docRef = _firestore.collection('attendance').doc(record.id);
        final data = record.toMap();
        data['timestamp'] = FieldValue.serverTimestamp();
        batch.set(docRef, data, SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  // Save/update a single attendance record directly. Used by the
  // Attendance History screen when an admin edits one existing record
  // (by date or by person), so we don't need to reload/rebuild the
  // whole day's record set just to change one entry.
  Future<void> saveSingleRecord(AttendanceRecord record) async {
    final docRef = _firestore.collection('attendance').doc(record.id);
    final data = record.toMap();
    data['timestamp'] = FieldValue.serverTimestamp();
    await docRef.set(data, SetOptions(merge: true));
  }
}