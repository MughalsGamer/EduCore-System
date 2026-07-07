import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Save all records in a single batch transaction
  Future<void> saveAttendance(List<AttendanceRecord> records) async {
    final batch = _firestore.batch();

    for (final record in records) {
      final docRef = _firestore.collection('attendance').doc(record.id);
      final data = record.toMap();
      data['timestamp'] = FieldValue.serverTimestamp(); // Server time for tracking
      batch.set(docRef, data, SetOptions(merge: true));
    }

    await batch.commit();
  }
}