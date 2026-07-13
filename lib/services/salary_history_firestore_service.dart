import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/salary_history.dart';
import '../models/teacher.dart';

/// Handles all Firestore operations for salary increment/decrement history.
///
/// Node structure (top-level collection, independent from `teachers` / `staff`):
///
/// salary_history/{autoId}
///   staffId       : String   -> links back to the StaffMember doc id
///   staffName     : String   -> denormalized, for display without extra lookups
///   staffType     : String   -> 'teacher' | 'staff' (denormalized)
///   changeType    : String   -> 'increment' | 'decrement'
///   oldSalary     : double
///   newSalary     : double
///   amount        : double   -> absolute difference
///   reason        : String
///   date          : String   -> yyyy-MM-dd (effective date)
///   createdAt     : Timestamp -> server timestamp
///
/// This collection never touches the existing `teachers` / `staff` documents
/// except for updating the single `salary` field on the StaffMember doc
/// (handled by StaffFirestoreService.updateStaff), so there is zero risk of
/// conflicting with any existing staff/teacher logic.
class SalaryHistoryFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('salary_history');

  /// Adds a new salary change record.
  Future<void> addSalaryChange(SalaryHistory record) async {
    await _collection.add(record.toMap());
  }

  /// Fetches full history for a single staff/teacher, most recent first.
  ///
  /// NOTE: Sorting is done client-side (not via Firestore `.orderBy`)
  /// specifically to avoid requiring a composite index for
  /// `where('staffId', ...) + orderBy('createdAt', ...)`. This keeps the
  /// feature working out-of-the-box with zero Firebase console setup.
  Future<List<SalaryHistory>> getHistoryForStaff(String staffId) async {
    final snap =
    await _collection.where('staffId', isEqualTo: staffId).get();
    final records = snap.docs
        .map((doc) => SalaryHistory.fromMap(doc.data(), doc.id))
        .toList();
    records.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate); // most recent first
    });
    return records;
  }

  /// Fetches ALL salary history records (used to build the "Salary
  /// Management" screen — only employees who have at least one record
  /// will show up there).
  ///
  /// Sorted client-side for the same reason as [getHistoryForStaff].
  Future<List<SalaryHistory>> getAllHistory() async {
    final snap = await _collection.get();
    final records = snap.docs
        .map((doc) => SalaryHistory.fromMap(doc.data(), doc.id))
        .toList();
    records.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate); // most recent first
    });
    return records;
  }

  /// Deletes a single history record (kept for completeness / corrections).
  Future<void> deleteHistoryRecord(String id) async {
    await _collection.doc(id).delete();
  }
}