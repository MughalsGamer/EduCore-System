import 'package:educoresystem/screens/register_user.dart';
import 'package:educoresystem/screens/subject_management/subject%20list.dart';
import 'package:educoresystem/screens/teacher_management/staff_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admission mangement/admission_list_screen.dart';
import 'student_management/student_list.dart';
import 'teacher_management/teacher_list.dart';
import 'class_management/class_list.dart';
import 'fee_management/fee_structure_screen.dart';
import 'fee_management/collect_fee.dart';
import 'fee_management/fee_receipts.dart';
import 'fee_management/student_ledger.dart';
import 'expense_management/add_expense.dart';
import 'expense_management/expense_list.dart';
import 'reports/fee_report.dart';
import 'reports/expense_report.dart';
import 'reports/profit_loss_report.dart';
import '../widgets/custom_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.role;

    // Based on role, decide which cards to show
    List<DashboardCard> cards;
    switch (role) {
      case 'admin':
        cards = [
          DashboardCard('Register User', Icons.person_add, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterUserScreen()));
          }),
          DashboardCard('Subject', Icons.view_module, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MuddulListScreen()));
          }),
          DashboardCard('Classes', Icons.class_, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassesListScreen()));
          }),
          DashboardCard('Admissions', Icons.how_to_reg, () {
            Navigator.push(context, MaterialPageRoute(
                builder: (_) => const AdmissionListScreen()));
          }),
          DashboardCard('Students', Icons.people, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen()));
          }),
          DashboardCard('Teachers', Icons.person, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherListScreen()));
          }),
          DashboardCard('Staff', Icons.personal_injury, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffListScreen()));
          }),
          DashboardCard('Fee Structure', Icons.money, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeStructureScreen()));
          }),
          // DashboardCard('Collect Fee', Icons.payment, () {
          //   Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectFeeScreen()));
          // }),
          DashboardCard('Fee Receipts', Icons.receipt_long, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeReceiptsScreen()));
          }),
          DashboardCard('Student Ledger', Icons.book, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLedgerScreen(studentId: 'studentId')));
          }),
          DashboardCard('Add Expense', Icons.money_off, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          }),
          DashboardCard('View Expenses', Icons.list, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen()));
          }),
          DashboardCard('Fee Report', Icons.receipt, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeReportScreen()));
          }),
          DashboardCard('Expense Report', Icons.bar_chart, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseReportScreen()));
          }),
          DashboardCard('Profit/Loss', Icons.trending_up, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitLossScreen()));
          }),
        ];
        break;
      case 'accountant':
        cards = [
          DashboardCard('Fee Structure', Icons.money, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeStructureScreen()));
          }),
          // DashboardCard('Collect Fee', Icons.payment, () {
          //   Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectFeeScreen()));
          // }),
          DashboardCard('Fee Receipts', Icons.receipt_long, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeReceiptsScreen()));
          }),
          DashboardCard('Student Ledger', Icons.book, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLedgerScreen(studentId: 'studentId')));
          }),
          DashboardCard('Add Expense', Icons.money_off, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          }),
          DashboardCard('View Expenses', Icons.list, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen()));
          }),
          DashboardCard('Fee Report', Icons.receipt, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeReportScreen()));
          }),
          DashboardCard('Expense Report', Icons.bar_chart, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseReportScreen()));
          }),
          DashboardCard('Profit/Loss', Icons.trending_up, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitLossScreen()));
          }),
        ];
        break;
      case 'teacher':
      default:
        cards = [
          DashboardCard('Students', Icons.people, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen()));
          }),
        ];
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // User welcome header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${auth.user?.email ?? 'User'}',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${role.toUpperCase()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) => cards[index].build(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  DashboardCard(this.title, this.icon, this.onTap);

  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF3F51B5)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}