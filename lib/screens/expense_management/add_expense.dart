import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _cat = TextEditingController();
  final _desc = TextEditingController();
  final _amount = TextEditingController();

  void _save() {
    final exp = Expense(
      category: _cat.text,
      description: _desc.text,
      amount: double.tryParse(_amount.text) ?? 0,
      date: DateTime.now(),
    );
    Provider.of<ExpenseProvider>(context, listen: false).addExpense(exp);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _cat, decoration: const InputDecoration(labelText: 'Category (Salary, Utility, etc.)')),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: _amount, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}