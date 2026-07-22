
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

// In AttendanceFirestoreService.dart
  Future<void> saveAttendanceBatch(List<AttendanceRecord> records) async {
    if (records.isEmpty) return;

    // Same chunking logic as saveAttendance (max 450 per batch)
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
        data['timestamp'] = FieldValue.serverTimestamp(); // ✅ add timestamp
        batch.set(docRef, data, SetOptions(merge: true)); // ✅ merge to preserve existing fields
      }
      await batch.commit();
    }
  }

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