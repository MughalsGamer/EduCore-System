import 'package:educoresystem/screens/register_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'fee_management/fee_receipts.dart';
import 'fee_management/student_ledger.dart';
import 'student_management/student_list.dart';
import 'teacher_management/teacher_list.dart';
import 'class_management/class_list.dart';
import 'fee_management/fee_structure_screen.dart';
import 'fee_management/collect_fee.dart';
import 'expense_management/add_expense.dart';
import 'expense_management/expense_list.dart';
import 'reports/fee_report.dart';
import 'reports/expense_report.dart';
import 'reports/profit_loss_report.dart';
import '../widgets/custom_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
        ),
      ]),
      drawer: const CustomDrawer(),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _dashboardCard('Register User', Icons.person_add, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterUserScreen()));
          }),
          _dashboardCard('Students', Icons.people, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen()))),
          _dashboardCard('Teachers', Icons.person, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherListScreen()))),
          _dashboardCard('Classes', Icons.class_, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassListScreen()))),
          _dashboardCard('Fee Structure', Icons.money, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeStructureScreen()))),
          _dashboardCard('Collect Fee', Icons.payment, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectFeeScreen()))),
          _dashboardCard('Fee Receipts', Icons.receipt_long, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeReceiptsScreen()));
          }),
          _dashboardCard('Student Ledger', Icons.book, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLedgerScreen(studentId: 'studentId',)));

          }),
          _dashboardCard('Add Expense', Icons.money_off, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()))),
          _dashboardCard('View Expenses', Icons.list, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen()))),
          _dashboardCard('Fee Report', Icons.receipt, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeReportScreen()))),
          _dashboardCard('Expense Report', Icons.bar_chart, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseReportScreen()))),
          _dashboardCard('Profit/Loss', Icons.trending_up, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitLossScreen()))),
        ],
      ),
    );
  }

  Widget _dashboardCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.indigo),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}