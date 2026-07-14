import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/employee_trasaction_model.dart';

/// Handles all Firestore CRUD for the standalone `staff_transactions`
/// collection used by the Advance / Loan / Expense / Fine / Reimbursement
/// tracking feature.
class StaffTransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection() =>
      _firestore.collection('staff_transactions');

  Future<String> addTransaction(StaffTransaction txn) async {
    final docRef = await _collection().add(txn.toMap());
    return docRef.id;
  }

  Future<void> updateTransaction(String id, StaffTransaction txn) =>
      _collection().doc(id).update(txn.toMap());

  Future<void> deleteTransaction(String id) => _collection().doc(id).delete();

  /// Fetch every transaction (used for an all-employees ledger/report view).
  Future<List<StaffTransaction>> getAllTransactions() async {
    final snap =
    await _collection().orderBy('date', descending: true).get();
    return snap.docs
        .map((doc) => StaffTransaction.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Fetch every transaction recorded against one specific employee —
  /// this is what a profile / ledger page uses to show that person's history.
  Future<List<StaffTransaction>> getTransactionsForEmployee(
      String employeeId) async {
    final snap = await _collection()
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((doc) => StaffTransaction.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Real-time stream variant, useful if a screen wants live updates
  /// for one employee's transaction history.
  Stream<List<StaffTransaction>> streamTransactionsForEmployee(
      String employeeId) {
    return _collection()
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => StaffTransaction.fromMap(doc.data(), doc.id))
        .toList());
  }
}