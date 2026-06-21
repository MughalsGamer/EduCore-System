import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.expenses.length,
        itemBuilder: (ctx, i) {
          final e = provider.expenses[i];
          return ListTile(
            title: Text(e.category),
            subtitle: Text('${e.description} - ${e.amount}'),
            trailing: Text(e.date.toString().substring(0, 10)),
          );
        },
      ),
    );
  }
}