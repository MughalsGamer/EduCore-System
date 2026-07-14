import 'package:flutter/foundation.dart';

import '../models/employee_trasaction_model.dart';
import '../services/employee_transaction_firestore_service.dart';


class StaffTransactionProvider extends ChangeNotifier {
  final StaffTransactionService _service = StaffTransactionService();

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
    _allTransactions = await _service.getAllTransactions();
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchForEmployee(String employeeId) async {
    _loading = true;
    notifyListeners();
    _employeeTransactions =
    await _service.getTransactionsForEmployee(employeeId);
    _loading = false;
    notifyListeners();
  }

  Future<void> addTransaction(StaffTransaction txn) async {
    _saving = true;
    notifyListeners();
    try {
      await _service.addTransaction(txn);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> updateTransaction(String id, StaffTransaction txn) async {
    _saving = true;
    notifyListeners();
    try {
      await _service.updateTransaction(id, txn);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _service.deleteTransaction(id);
    await fetchAll();
  }

  void clear() {
    _allTransactions = [];
    _employeeTransactions = [];
    notifyListeners();
  }
}