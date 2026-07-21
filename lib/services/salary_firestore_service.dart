//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/salary_model.dart';
//
// class SalaryFirestoreService {
//   final CollectionReference _collection =
//   FirebaseFirestore.instance.collection('salaries');
//
//   /// Check if a salary already generated for a given employee in a month.
//   Future<SalaryRecord?> checkAlreadyGenerated(
//       String employeeId, int year, int month) async {
//     final snap = await _collection
//         .where('employeeId', isEqualTo: employeeId)
//         .where('year', isEqualTo: year)
//         .where('month', isEqualTo: month)
//         .limit(1)
//         .get();
//
//     if (snap.docs.isEmpty) return null;
//     final doc = snap.docs.first;
//     return SalaryRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//   }
//
//   /// Fetch all salary records for a specific year and month.
//   /// We use this as the base query, then apply client‑side filters.
//   Future<List<SalaryRecord>> getSalariesByMonth(int year, int month) async {
//     final snap = await _collection
//         .where('year', isEqualTo: year)
//         .where('month', isEqualTo: month)
//         .get();
//
//     return snap.docs.map((doc) {
//       return SalaryRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//     }).toList();
//   }
//
//   /// Save a new salary record.
//   Future<void> saveSalary(SalaryRecord record) async {
//     final data = record.toMap();
//     // createdAt is set via FieldValue.serverTimestamp() in toMap()
//     await _collection.add(data);
//   }
//
//   /// Update the status of a salary record.
//   /// If status is 'Paid', also set paidAt timestamp.
//   Future<void> updateStatus(String docId, String newStatus) async {
//     final updates = <String, dynamic>{'status': newStatus};
//     if (newStatus == 'Paid') {
//       updates['paidAt'] = FieldValue.serverTimestamp();
//     } else {
//       // If status goes back to something else, remove paidAt? Let's keep it.
//       // We'll just not touch it.
//     }
//     await _collection.doc(docId).update(updates);
//   }
//
//   /// Update adjustable fields (fine, bonus, note, status) and optionally paidAt.
//   Future<void> updateSalaryFields(
//       String docId, {
//         double? fine,
//         double? bonus,
//         String? note,
//         String? status,
//       }) async {
//     final updates = <String, dynamic>{};
//     if (fine != null) updates['fine'] = fine;
//     if (bonus != null) updates['bonus'] = bonus;
//     if (note != null) updates['note'] = note;
//     if (status != null) {
//       updates['status'] = status;
//       if (status == 'Paid') {
//         updates['paidAt'] = FieldValue.serverTimestamp();
//       }
//     }
//     if (updates.isNotEmpty) {
//       await _collection.doc(docId).update(updates);
//     }
//   }
//
//   /// Update a full salary record (used when editing via GenerateSalaryScreen's
//   /// edit mode). Accepts a pre-built map of fields to overwrite.
//   Future<void> updateFullSalary(
//       String docId, Map<String, dynamic> updates) async {
//     // Firestore doesn't accept explicit `null` removal via update() the same
//     // way as set(merge:true) for some SDKs, but null values ARE allowed as
//     // field values in update() — they just set the field to null.
//     await _collection.doc(docId).update(updates);
//   }
//
//   /// Delete a salary record completely.
//   Future<void> deleteSalary(String docId) async {
//     await _collection.doc(docId).delete();
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/salary_model.dart';

class SalaryFirestoreService {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('salaries');

  /// Check if a salary already generated for a given employee in a month.
  Future<SalaryRecord?> checkAlreadyGenerated(
      String employeeId, int year, int month) async {
    final snap = await _collection
        .where('employeeId', isEqualTo: employeeId)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return SalaryRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Fetch all salary records for a specific year and month.
  /// We use this as the base query, then apply client‑side filters.
  Future<List<SalaryRecord>> getSalariesByMonth(int year, int month) async {
    final snap = await _collection
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .get();

    return snap.docs.map((doc) {
      return SalaryRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  /// Save a new salary record.
  /// ★ FIXED — now returns the newly created Firestore document ID.
  /// Previously this returned void, so callers (SalaryProvider.saveSalary)
  /// had no way to know the real doc ID and record.id stayed null,
  /// causing `record.id!` to throw when syncing the ledger credit entry
  /// (silently swallowed by the try/catch, so the ledger entry never got
  /// created).
  Future<String> saveSalary(SalaryRecord record) async {
    final data = record.toMap();
    // createdAt is set via FieldValue.serverTimestamp() in toMap()
    final docRef = await _collection.add(data);
    return docRef.id;
  }

  /// Update the status of a salary record.
  /// If status is 'Paid', also set paidAt timestamp.
  Future<void> updateStatus(String docId, String newStatus) async {
    final updates = <String, dynamic>{'status': newStatus};
    if (newStatus == 'Paid') {
      updates['paidAt'] = FieldValue.serverTimestamp();
    } else {
      // If status goes back to something else, remove paidAt? Let's keep it.
      // We'll just not touch it.
    }
    await _collection.doc(docId).update(updates);
  }

  /// Update adjustable fields (fine, bonus, note, status) and optionally paidAt.
  Future<void> updateSalaryFields(
      String docId, {
        double? fine,
        double? bonus,
        String? note,
        String? status,
      }) async {
    final updates = <String, dynamic>{};
    if (fine != null) updates['fine'] = fine;
    if (bonus != null) updates['bonus'] = bonus;
    if (note != null) updates['note'] = note;
    if (status != null) {
      updates['status'] = status;
      if (status == 'Paid') {
        updates['paidAt'] = FieldValue.serverTimestamp();
      }
    }
    if (updates.isNotEmpty) {
      await _collection.doc(docId).update(updates);
    }
  }

  /// Update a full salary record (used when editing via GenerateSalaryScreen's
  /// edit mode). Accepts a pre-built map of fields to overwrite.
  Future<void> updateFullSalary(
      String docId, Map<String, dynamic> updates) async {
    // Firestore doesn't accept explicit `null` removal via update() the same
    // way as set(merge:true) for some SDKs, but null values ARE allowed as
    // field values in update() — they just set the field to null.
    await _collection.doc(docId).update(updates);
  }

  /// Delete a salary record completely.
  Future<void> deleteSalary(String docId) async {
    await _collection.doc(docId).delete();
  }
}