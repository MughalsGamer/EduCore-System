import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Expense> _expenses = [];
  bool _loading = false;

  List<Expense> get expenses => _expenses;
  bool get loading => _loading;

  Future<void> fetchExpenses() async {
    _loading = true;
    notifyListeners();
    _expenses = await _firestoreService.getExpenses();
    _loading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _firestoreService.addExpense(expense);
    await fetchExpenses();
  }
}