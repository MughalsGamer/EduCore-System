import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fee_provider.dart';
import '../../providers/expense_provider.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  @override
  void initState() {
    super.initState();
    final feeProv = Provider.of<FeeProvider>(context, listen: false);
    final expProv = Provider.of<ExpenseProvider>(context, listen: false);
    feeProv.fetchAllReceipts();
    expProv.fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final receipts = Provider.of<FeeProvider>(context).receipts;
    final expenses = Provider.of<ExpenseProvider>(context).expenses;
    double income = receipts.fold(0, (sum, r) => sum + r.amountPaid);
    double expense = expenses.fold(0, (sum, e) => sum + e.amount);
    double profit = income - expense;
    return Scaffold(
      appBar: AppBar(title: const Text('Profit & Loss')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Income: $income', style: const TextStyle(fontSize: 18)),
            Text('Total Expense: $expense', style: const TextStyle(fontSize: 18)),
            const Divider(),
            Text('Profit/Loss: $profit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: profit >= 0 ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}