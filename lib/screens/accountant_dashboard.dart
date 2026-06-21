import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'fee_management/fee_structure_screen.dart';
import 'fee_management/collect_fee.dart';
import 'expense_management/add_expense.dart';
import 'expense_management/expense_list.dart';
import 'reports/fee_report.dart';
import 'reports/expense_report.dart';
import 'reports/profit_loss_report.dart';
import '../widgets/custom_drawer.dart';

class AccountantDashboard extends StatelessWidget {
  const AccountantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accountant Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout()),
      ]),
      drawer: const CustomDrawer(),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _card('Fee Structure', Icons.money, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeStructureScreen()))),
          _card('Collect Fee', Icons.payment, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectFeeScreen()))),
          _card('Add Expense', Icons.money_off, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()))),
          _card('View Expenses', Icons.list, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen()))),
          _card('Fee Report', Icons.receipt, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeReportScreen()))),
          _card('Expense Report', Icons.bar_chart, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseReportScreen()))),
          _card('Profit/Loss', Icons.trending_up, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitLossScreen()))),
        ],
      ),
    );
  }

  Widget _card(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 40, color: Colors.indigo),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}