// import 'package:flutter/foundation.dart';
//
// import '../models/employee_trasaction_model.dart';
// import '../services/employee_transaction_firestore_service.dart';
//
//
// class StaffTransactionProvider extends ChangeNotifier {
//   final StaffTransactionService _service = StaffTransactionService();
//
//   List<StaffTransaction> _allTransactions = [];
//   List<StaffTransaction> _employeeTransactions = [];
//   bool _loading = false;
//   bool _saving = false;
//
//   List<StaffTransaction> get allTransactions => _allTransactions;
//   List<StaffTransaction> get employeeTransactions => _employeeTransactions;
//   bool get loading => _loading;
//   bool get saving => _saving;
//
//   Future<void> fetchAll() async {
//     _loading = true;
//     notifyListeners();
//     _allTransactions = await _service.getAllTransactions();
//     _loading = false;
//     notifyListeners();
//   }
//
//   Future<void> fetchForEmployee(String employeeId) async {
//     _loading = true;
//     notifyListeners();
//     _employeeTransactions =
//     await _service.getTransactionsForEmployee(employeeId);
//     _loading = false;
//     notifyListeners();
//   }
//
//   Future<void> addTransaction(StaffTransaction txn) async {
//     _saving = true;
//     notifyListeners();
//     try {
//       await _service.addTransaction(txn);
//     } finally {
//       _saving = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> updateTransaction(String id, StaffTransaction txn) async {
//     _saving = true;
//     notifyListeners();
//     try {
//       await _service.updateTransaction(id, txn);
//     } finally {
//       _saving = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> deleteTransaction(String id) async {
//     await _service.deleteTransaction(id);
//     await fetchAll();
//   }
//
//   void clear() {
//     _allTransactions = [];
//     _employeeTransactions = [];
//     notifyListeners();
//   }
// }


import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_trasaction_model.dart';

class StaffTransactionProvider extends ChangeNotifier {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('staff_transactions');

  List<StaffTransaction> _allTransactions = [];
  List<StaffTransaction> _employeeTransactions = [];
  bool _loading = false;
  bool _saving = false;

  List<StaffTransaction> get allTransactions => _allTransactions;
  List<StaffTransaction> get employeeTransactions => _employeeTransactions;
  bool get loading => _loading;
  bool get saving => _saving;

  Future<void> fetchAll() async {
    _loading = true;
    notifyListeners();
    try {
      final snap = await _collection
          .orderBy('date', descending: true)
          .get();
      _allTransactions = snap.docs.map((doc) {
        return StaffTransaction.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      _allTransactions = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchForEmployee(String employeeId) async {
    _loading = true;
    notifyListeners();
    try {
      final snap = await _collection
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('date', descending: false)
          .get();
      _employeeTransactions = snap.docs.map((doc) {
        return StaffTransaction.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching employee transactions: $e');
      _employeeTransactions = [];
    }
    _loading = false;
    notifyListeners();
  }

  // ★ NEW: Get employee ledger with running balance
  Future<Map<String, dynamic>> getEmployeeLedger(String employeeId) async {
    final transactions = await _getAllTransactionsForEmployee(employeeId);

    double balance = 0;
    final List<Map<String, dynamic>> ledgerEntries = [];

    for (var txn in transactions) {
      if (txn.transactionType == 'debit') {
        balance += txn.amount; // Debit increases what employee owes
      } else {
        balance -= txn.amount; // Credit decreases what employee owes
      }

      ledgerEntries.add({
        'transaction': txn,
        'runningBalance': balance,
      });
    }

    return {
      'transactions': transactions,
      'ledgerEntries': ledgerEntries,
      'balance': balance, // Positive = Employee owes, Negative = Company owes
    };
  }

  // ★ NEW: Get current balance for an employee
  Future<double> getEmployeeBalance(String employeeId) async {
    final result = await getEmployeeLedger(employeeId);
    return result['balance'] ?? 0;
  }

  // ★ NEW: Add transaction with balance calculation
  Future<void> addTransaction(StaffTransaction transaction) async {
    _saving = true;
    notifyListeners();

    try {
      // Get current balance for this employee
      final currentBalance = await getEmployeeBalance(transaction.employeeId);

      // Calculate new running balance
      double newBalance = currentBalance;
      if (transaction.transactionType == 'debit') {
        newBalance += transaction.amount;
      } else {
        newBalance -= transaction.amount;
      }

      // Create a copy with running balance
      final txnWithBalance = StaffTransaction(
        id: transaction.id,
        employeeId: transaction.employeeId,
        employeeName: transaction.employeeName,
        employeeType: transaction.employeeType,
        date: transaction.date,
        category: transaction.category,
        customCategory: transaction.customCategory,
        amount: transaction.amount,
        note: transaction.note,
        createdAt: transaction.createdAt,
        transactionType: transaction.transactionType,
        salaryRecordId: transaction.salaryRecordId,
        runningBalance: newBalance,
      );

      await _collection.add(txnWithBalance.toMap());
      await fetchAll();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  // ★ NEW: Add credit transaction from salary deduction
  Future<void> addSalaryDeduction({
    required String employeeId,
    required String employeeName,
    required String employeeType,
    required DateTime date,
    required double amount,
    required String? note,
    required String salaryRecordId,
  }) async {
    final transaction = StaffTransaction.fromSalaryDeduction(
      employeeId: employeeId,
      employeeName: employeeName,
      employeeType: employeeType,
      date: date,
      amount: amount,
      note: note,
      salaryRecordId: salaryRecordId,
    );
    await addTransaction(transaction);
  }

  Future<void> updateTransaction(String id, StaffTransaction transaction) async {
    _saving = true;
    notifyListeners();

    try {
      // Get all transactions for this employee (including the one being updated)
      final allTxns = await _getAllTransactionsForEmployee(transaction.employeeId);

      // Remove the transaction being updated
      final filtered = allTxns.where((t) => t.id != id).toList();

      // Recalculate balances from scratch
      double balance = 0;
      final List<StaffTransaction> updatedTxns = [];

      // Add all transactions in chronological order
      for (var t in filtered) {
        if (t.transactionType == 'debit') {
          balance += t.amount;
        } else {
          balance -= t.amount;
        }

        // Update the transaction with new running balance
        final updated = t.copyWith(runningBalance: balance);
        updatedTxns.add(updated);
      }

      // Now add the updated transaction at the right position
      // First, find where to insert based on date
      int insertIndex = updatedTxns.length;
      for (int i = 0; i < updatedTxns.length; i++) {
        if (updatedTxns[i].date.isAfter(transaction.date)) {
          insertIndex = i;
          break;
        }
      }

      // Calculate balance before insertion
      double balanceBefore = 0;
      if (insertIndex > 0) {
        balanceBefore = updatedTxns[insertIndex - 1].runningBalance ?? 0;
      }

      // Calculate new balance after insertion
      double newBalance = balanceBefore;
      if (transaction.transactionType == 'debit') {
        newBalance += transaction.amount;
      } else {
        newBalance -= transaction.amount;
      }

      // Create updated transaction with running balance
      final updatedTxn = transaction.copyWith(
        runningBalance: newBalance,
        id: id,
      );

      // Insert at correct position
      updatedTxns.insert(insertIndex, updatedTxn);

      // Update all subsequent balances
      for (int i = insertIndex + 1; i < updatedTxns.length; i++) {
        final prevBalance = updatedTxns[i - 1].runningBalance ?? 0;
        final current = updatedTxns[i];
        double newBal = prevBalance;
        if (current.transactionType == 'debit') {
          newBal += current.amount;
        } else {
          newBal -= current.amount;
        }
        updatedTxns[i] = current.copyWith(runningBalance: newBal);
      }

      // Update all documents in batch
      final batch = FirebaseFirestore.instance.batch();
      for (var t in updatedTxns) {
        if (t.id != null) {
          batch.update(_collection.doc(t.id!), t.toMap());
        }
      }
      await batch.commit();

      await fetchAll();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _saving = true;
    notifyListeners();

    try {
      // Get the transaction being deleted
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return;

      final txn = StaffTransaction.fromMap(doc.data() as Map<String, dynamic>, id);

      // Get all transactions for this employee
      final allTxns = await _getAllTransactionsForEmployee(txn.employeeId);

      // Remove the deleted transaction
      final filtered = allTxns.where((t) => t.id != id).toList();

      // Recalculate all balances
      double balance = 0;
      final List<StaffTransaction> updatedTxns = [];

      for (var t in filtered) {
        if (t.transactionType == 'debit') {
          balance += t.amount;
        } else {
          balance -= t.amount;
        }
        updatedTxns.add(t.copyWith(runningBalance: balance));
      }

      // Update all documents in batch
      final batch = FirebaseFirestore.instance.batch();
      for (var t in updatedTxns) {
        if (t.id != null) {
          batch.update(_collection.doc(t.id!), t.toMap());
        }
      }

      // Delete the original document
      batch.delete(_collection.doc(id));

      await batch.commit();
      await fetchAll();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  // Helper: get all transactions for an employee (without running balance)
  Future<List<StaffTransaction>> _getAllTransactionsForEmployee(String employeeId) async {
    try {
      final snap = await _collection
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('date', descending: false)
          .get();

      return snap.docs.map((doc) {
        return StaffTransaction.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching employee transactions: $e');
      return [];
    }
  }

  void clear() {
    _allTransactions = [];
    _employeeTransactions = [];
    notifyListeners();
  }
}