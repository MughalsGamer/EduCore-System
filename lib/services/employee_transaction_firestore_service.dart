import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_trasaction_model.dart';

/// Handles all Firestore operations for the employee ledger
/// (expenses, loans, advances, repayments).
///
/// Node structure (top-level collection, fully independent from
/// `teachers` / `staff` / `salary_history` — zero risk of conflict):
///
/// employee_transactions/{autoId}
///   staffId               : String
///   staffName             : String  (denormalized)
///   staffType             : String  (denormalized: 'teacher' | 'staff')
///   type                  : String  ('expense' | 'loan' | 'advance' | 'repayment')
///   direction             : String  ('debit' | 'credit')
///   amount                : double
///   description           : String
///   date                  : String  (yyyy-MM-dd)
///   expenseKind           : String? ('company_expense' | 'deduction')
///   status                : String? ('pending' | 'partially_paid' | 'settled')
///   linkedTransactionId   : String? (repayment -> original loan/advance id)
///   createdAt             : Timestamp (server timestamp)
///
/// NOTE: All queries filter by `staffId` only and sort CLIENT-SIDE by
/// `createdAt`/`date`. This deliberately avoids needing a Firestore
/// composite index (staffId + orderBy), so the feature works with zero
/// Firebase console setup — same approach already used for salary_history.
class EmployeeTransactionFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('employee_transactions');

  /// Adds a new transaction (expense / loan / advance / repayment).
  /// Returns the new document's id (useful right after creating a loan,
  /// in case the caller wants it immediately).
  Future<String> addTransaction(EmployeeTransaction tx) async {
    final doc = await _collection.add(tx.toMap());
    return doc.id;
  }

  /// Updates an existing transaction's editable fields (createdAt is
  /// preserved).
  Future<void> updateTransaction(String id, EmployeeTransaction tx) async {
    await _collection.doc(id).update(tx.toUpdateMap());
  }

  /// Deletes a single transaction.
  Future<void> deleteTransaction(String id) async {
    await _collection.doc(id).delete();
  }

  /// Deletes a transaction AND, if other repayments reference it via
  /// [linkedTransactionId] (i.e. it was a loan/advance with repayments
  /// already made against it), also deletes those repayment rows —
  /// otherwise they'd be orphaned entries pointing at a non-existent
  /// loan. Done as a single batch so it's atomic.
  Future<void> deleteTransactionWithLinkedRepayments(String id) async {
    final linkedSnap = await _collection
        .where('linkedTransactionId', isEqualTo: id)
        .get();

    final batch = _firestore.batch();
    batch.delete(_collection.doc(id));
    for (final doc in linkedSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// All transactions for a single employee, most recent first
  /// (sorted client-side — see class doc comment for why).
  Future<List<EmployeeTransaction>> getTransactionsForStaff(
      String staffId) async {
    final snap =
    await _collection.where('staffId', isEqualTo: staffId).get();
    final list = snap.docs
        .map((doc) => EmployeeTransaction.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
    return list;
  }

  /// All repayments linked to a specific loan/advance transaction,
  /// most recent first.
  Future<List<EmployeeTransaction>> getRepaymentsFor(
      String linkedTransactionId) async {
    final snap = await _collection
        .where('linkedTransactionId', isEqualTo: linkedTransactionId)
        .get();
    final list = snap.docs
        .map((doc) => EmployeeTransaction.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
    return list;
  }

  /// Every transaction across all employees (used to build outstanding
  /// loans/advances summaries, and the employee-picker "has activity"
  /// indicator). Sorted client-side, most recent first.
  Future<List<EmployeeTransaction>> getAllTransactions() async {
    final snap = await _collection.get();
    final list = snap.docs
        .map((doc) => EmployeeTransaction.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
    return list;
  }
}