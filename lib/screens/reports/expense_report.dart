import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;
    double total = expenses.fold(0, (sum, e) => sum + e.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Report')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total Expenses: $total', style: const TextStyle(fontSize: 20)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (ctx, i) {
                final e = expenses[i];
                return ListTile(
                  title: Text(e.category),
                  subtitle: Text(e.description),
                  trailing: Text('${e.amount}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}