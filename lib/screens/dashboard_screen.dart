
import 'package:educoresystem/screens/register_user.dart';
import 'package:educoresystem/screens/subject_management/subject%20list.dart';
import 'package:educoresystem/screens/teacher_management/add_teacher.dart';
import 'package:educoresystem/screens/teacher_management/staff_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admission mangement/admission_list_screen.dart';
import 'family_management/family management.dart';
import 'student_management/student_list.dart';
import 'teacher_management/teacher_list.dart';
import 'class_management/class_list.dart';
import 'fee_management/fee_structure_screen.dart';
import 'fee_management/fee_receipts.dart';
import 'fee_management/student_ledger.dart';
import 'expense_management/add_expense.dart';
import 'expense_management/expense_list.dart';
import 'reports/fee_report.dart';
import 'reports/expense_report.dart';
import 'reports/profit_loss_report.dart';
import 'class_management/add_class.dart';
import 'subject_management/add_edit_subject.dart';
import 'admission mangement/add_admission_screen.dart';

// ─────────────────────────────────────────────
//  Model
// ─────────────────────────────────────────────
class _NavItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  const _NavItem(this.label, this.icon, this.onTap, {this.badge});
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  const _StatItem(this.label, this.value, this.icon, this.iconBg, this.iconColor);
}

class _QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.onTap);
}

// ─────────────────────────────────────────────
//  Constants
// ─────────────────────────────────────────────
const _purple = Color(0xFF534AB7);
const _purpleLight = Color(0xFFEEEDFE);

// ─────────────────────────────────────────────
//  Dashboard
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _mobileNavIndex = 0;

  // ── Wide screen content ──
  Widget? _mainContentWidget;
  String? _selectedLabel;
  Widget? _rightPanelWidget;

  // ── Builders for every screen we can show ──
  late final Map<String, Widget Function()> _screenBuilders;

  @override
  void initState() {
    super.initState();
    _mainContentWidget = _buildDashboardContent();
    _selectedLabel = 'Dashboard';

    _screenBuilders = {
      'Dashboard': () => _buildDashboardContent(),
      'Subjects': () => const MuddulListScreen(showAppBar: false, showFAB: false),
      'Classes': () => const ClassesListScreen(showAppBar: false, showFAB: false),
      'Admissions': () => const AdmissionListScreen(showAppBar: false, showFAB: false),
      'Students': () => const StudentListScreen(),
      'Teachers': () => const TeacherListScreen(),
      'Staff': () => const StaffListScreen(),
      'Family': () => const FamilyManagementScreen(),
      'Fee Structure': () => const FeeStructureScreen(),
      'Fee Receipts': () => const FeeReceiptsScreen(),
      'Student Ledger': () => StudentLedgerScreen(studentId: 'studentId'),
      'Add Expense': () => const AddExpenseScreen(),
      'Expenses': () => const ExpenseListScreen(),
      'Fee Report': () => const FeeReportScreen(),
      'Expense Report': () => const ExpenseReportScreen(),
      'Profit / Loss': () => const ProfitLossScreen(),
      'Register User': () => const RegisterUserScreen(),
      // Quick actions (only used in right panel)
      'Add Subject': () => AddEditMuddulScreen(
        showAppBar: false,
        onSaved: () => _closeRightPanel(),
      ),
      'Add Class': () => AddEditClassScreen(
        showAppBar: false,
        onSaved: () => _closeRightPanel(),
      ),
      'New Admission': () => AdmissionFormScreen(
        showAppBar: false,
        onSaved: () => _closeRightPanel(),
      ),
      // ← NEW quick action for Staff/Teacher
      'Add Staff/Teacher': () => AddEditStaffScreen(
        showAppBar: false,
        onSaved: () => _closeRightPanel(),
      ),
    };
  }

  // ── Navigation items (all visible for now) ──
  List<_NavItem> _navItems(String role) {
    VoidCallback go(String label) => () {
      if (MediaQuery.of(context).size.width >= 700) {
        setState(() {
          _mainContentWidget = _screenBuilders[label]!();
          _selectedLabel = label;
          _rightPanelWidget = null;
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _screenBuilders[label]!()),
        );
      }
    };

    final all = <_NavItem>[
      _NavItem('Dashboard', Icons.dashboard_rounded, go('Dashboard')),
      _NavItem('Register User', Icons.person_add_rounded, go('Register User')),
      _NavItem('Subjects', Icons.view_module_rounded, go('Subjects')),
      _NavItem('Classes', Icons.class_rounded, go('Classes')),
      _NavItem('Admissions', Icons.how_to_reg_rounded, go('Admissions'), badge: 3),
      _NavItem('Family', Icons.family_restroom_rounded, go('Family')),
      _NavItem('Students', Icons.people_rounded, go('Students')),
      _NavItem('Teachers', Icons.person_rounded, go('Teachers')),
      _NavItem('Staff', Icons.badge_rounded, go('Staff')),
      _NavItem('Fee Structure', Icons.monetization_on_rounded, go('Fee Structure')),
      _NavItem('Fee Receipts', Icons.receipt_long_rounded, go('Fee Receipts')),
      _NavItem('Student Ledger', Icons.book_rounded, go('Student Ledger')),
      _NavItem('Add Expense', Icons.money_off_rounded, go('Add Expense')),
      _NavItem('Expenses', Icons.list_alt_rounded, go('Expenses')),
      _NavItem('Fee Report', Icons.receipt_rounded, go('Fee Report')),
      _NavItem('Expense Report', Icons.bar_chart_rounded, go('Expense Report')),
      _NavItem('Profit / Loss', Icons.trending_up_rounded, go('Profit / Loss')),
    ];

    return all;
  }

  // ── Quick actions ──
  List<_QuickAction> _quickActions() {
    return [
      _QuickAction('Add Subject', Icons.book_rounded,
              () => _openQuickAction('Add Subject')),
      _QuickAction('Add Class', Icons.class_rounded,
              () => _openQuickAction('Add Class')),
      _QuickAction('New Admission', Icons.person_add_rounded,
              () => _openQuickAction('New Admission')),
      // ← NEW quick action for Staff/Teacher
      _QuickAction('Add Staff/Teacher', Icons.person_add_rounded,
              () => _openQuickAction('Add Staff/Teacher')),
    ];
  }

  void _openQuickAction(String key) {
    if (MediaQuery.of(context).size.width >= 700) {
      setState(() {
        _rightPanelWidget = _screenBuilders[key]!();
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _screenBuilders[key]!()),
      );
    }
  }

  void _closeRightPanel() {
    setState(() {
      _rightPanelWidget = null;
    });
  }

  // ── Stats ──
  static const _stats = <_StatItem>[
    _StatItem('Total Students', '36', Icons.people_rounded,
        Color(0xFFE6F1FB), Color(0xFF185FA5)),
    _StatItem('Total Teachers', '8', Icons.person_rounded,
        Color(0xFFEAF3DE), Color(0xFF3B6D11)),
    _StatItem('Total Staff', '1', Icons.badge_rounded,
        Color(0xFFE1F5EE), Color(0xFF0F6E56)),
    _StatItem('Classes', '13', Icons.class_rounded,
        Color(0xFFFAEEDA), Color(0xFF854F0B)),
    _StatItem('Attendance', '92%', Icons.check_circle_rounded,
        Color(0xFFEEEDFE), Color(0xFF534AB7)),
    _StatItem("Today's Fee", 'Rs 30,200', Icons.wallet_rounded,
        Color(0xFFFAECE7), Color(0xFF993C1D)),
    _StatItem('Pending Fees', 'Rs 71,000', Icons.warning_amber_rounded,
        Color(0xFFFBEAF0), Color(0xFF993556)),
    _StatItem('Monthly Revenue', 'Rs 87,400', Icons.trending_up_rounded,
        Color(0xFFF1EFE8), Color(0xFF5F5E5A)),
  ];

  // ── Sidebar content (shared) ──
  Widget _sidebarContent(String role, String userEmail, {required bool isDrawer}) {
    final items = _navItems(role);
    final initials = userEmail.length >= 2
        ? userEmail.substring(0, 2).toUpperCase()
        : userEmail.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Citizens Model',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  Text('School',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        // User info
        Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _purpleLight,
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _purple)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmail.split('@').first,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 6),
            children: [
              _sbLabel('Main'),
              ...items.where((n) => n.label == 'Dashboard').map((e) => _sbTile(e, isDrawer)),
              if (items.any((n) => [
                'Students', 'Teachers', 'Staff', 'Family', 'Register User'
              ].contains(n.label))) ...[
                _sbLabel('People'),
                ...items
                    .where((n) => [
                  'Students', 'Teachers', 'Staff', 'Family',
                  'Register User'
                ].contains(n.label))
                    .map((e) => _sbTile(e, isDrawer)),
              ],
              if (items.any((n) => [
                'Classes', 'Subjects', 'Admissions'
              ].contains(n.label))) ...[
                _sbLabel('Academic'),
                ...items
                    .where((n) => [
                  'Classes', 'Subjects', 'Admissions'
                ].contains(n.label))
                    .map((e) => _sbTile(e, isDrawer)),
              ],
              if (items.any((n) => [
                'Fee Structure', 'Fee Receipts', 'Student Ledger',
                'Add Expense', 'Expenses'
              ].contains(n.label))) ...[
                _sbLabel('Finance'),
                ...items
                    .where((n) => [
                  'Fee Structure', 'Fee Receipts', 'Student Ledger',
                  'Add Expense', 'Expenses'
                ].contains(n.label))
                    .map((e) => _sbTile(e, isDrawer)),
              ],
              if (items.any((n) => [
                'Fee Report', 'Expense Report', 'Profit / Loss'
              ].contains(n.label))) ...[
                _sbLabel('Reports'),
                ...items
                    .where((n) => [
                  'Fee Report', 'Expense Report', 'Profit / Loss'
                ].contains(n.label))
                    .map((e) => _sbTile(e, isDrawer)),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        ListTile(
          dense: true,
          leading: const Icon(Icons.logout_rounded,
              size: 18, color: Colors.redAccent),
          title: const Text('Logout',
              style: TextStyle(fontSize: 13, color: Colors.redAccent)),
          onTap: () =>
              Provider.of<AuthProvider>(context, listen: false).logout(),
        ),
      ],
    );
  }

  // ── Drawer wrapper (used on mobile) ──
  Widget _buildSidebar(String role, String userEmail) {
    return Drawer(
      width: 220,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: _sidebarContent(role, userEmail, isDrawer: true),
      ),
    );
  }

  Widget _sbLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
    child: Text(text.toUpperCase(),
        style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.6)),
  );

  Widget _sbTile(_NavItem item, bool isDrawer) {
    final isActive = item.label == (_selectedLabel ?? '');

    return InkWell(
      onTap: () {
        // Only pop if we are inside a drawer, not the permanent sidebar.
        if (isDrawer) Navigator.pop(context);
        item.onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _purpleLight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(item.icon,
                size: 17,
                color: isActive ? _purple : Colors.grey.shade600),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? _purple : Colors.grey.shade800,
                ),
              ),
            ),
            if (item.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${item.badge}',
                    style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  // ── Stat card ──
  Widget _statCard(_StatItem s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
        Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: s.iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(s.icon, color: s.iconColor, size: 22),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.label,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    letterSpacing: 0.3),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(s.value,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      )],
      ),
    );

  }

  // ── Quick action chip ──
  Widget _qaChip(_QuickAction a) {
    return InkWell(
      onTap: a.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(a.icon, size: 16, color: _purple),
            const SizedBox(width: 6),
            Flexible(
              child: Text(a.label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  // ── Attendance mini spark ──
  Widget _buildAttendanceBar() {
    final data = [92, 88, 91, 94, 90, 86, 93, 95, 89, 91, 88, 92, 90, 93];
    return LayoutBuilder(builder: (ctx, box) {
      final barW =
      ((box.maxWidth - (data.length - 1) * 3) / data.length).clamp(4.0, 24.0);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((e) {
          final pct = (e.value - 80) / 20;
          return Padding(
            padding: EdgeInsets.only(right: e.key < data.length - 1 ? 3 : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: barW,
                  height: (pct * 100).clamp(8.0, 100.0),
                  decoration: BoxDecoration(
                    color: _purple.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  // ── Student growth spark ──
  Widget _buildStudentLine() {
    final data = [28, 29, 30, 31, 33, 36];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(builder: (ctx, box) {
            final w = box.maxWidth;
            final h = box.maxHeight;
            const minV = 26.0;
            const maxV = 38.0;
            final pts = data.asMap().entries.map((e) {
              final x = e.key / (data.length - 1) * w;
              final y = h - (e.value - minV) / (maxV - minV) * h;
              return Offset(x, y);
            }).toList();
            return CustomPaint(
              painter: _LinePainter(pts),
              size: Size(w, h),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: months
              .map((m) => Text(m,
              style: const TextStyle(fontSize: 9, color: Colors.grey)))
              .toList(),
        ),
      ],
    );
  }

  // ── Recent fee row ──
  Widget _recentFeeRow(String initials, String name, String sub,
      String amount, Color bg, Color fg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: bg,
            child: Text(initials,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
                Text(sub,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(amount,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  // ── Notice tile ──
  Widget _noticeTile(String text, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: _purple, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 3),
          Text(time,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // ── Section header ──
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _purple),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  // ── Card wrapper ──
  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  // ── Mobile bottom nav ──
  Widget _buildBottomNav(String role) {
    final items = _navItems(role);
    final tabs = <_NavItem>[
      items.first,
      ...items.where((n) => n.label == 'Students').take(1),
      ...items.where((n) => n.label == 'Fee Receipts').take(1),
      ...items.where((n) => n.label == 'Teachers').take(1),
    ];
    while (tabs.length < 4) {
      tabs.add(_NavItem('More', Icons.more_horiz_rounded, () {}));
    }

    return BottomNavigationBar(
      currentIndex: _mobileNavIndex.clamp(0, tabs.length - 1),
      onTap: (i) {
        setState(() => _mobileNavIndex = i);
        if (i < tabs.length) {
          if (i == 0) return;
          tabs[i].onTap();
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _purple,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      iconSize: 22,
      items: tabs
          .map((n) => BottomNavigationBarItem(
        icon: Icon(n.icon),
        label: n.label,
      ))
          .toList(),
    );
  }

  // ── Panel header for right panel ──
  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Icon(Icons.add, color: _purple),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Add New',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeRightPanel,
          ),
        ],
      ),
    );
  }

  // ── Dashboard content ──
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Academic Quick Actions', Icons.school_rounded),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickActions().map(_qaChip).toList(),
          ),
          const SizedBox(height: 20),
          _sectionHeader('Overview', Icons.bar_chart_rounded),
          LayoutBuilder(builder: (ctx, box) {
            final w = box.maxWidth;
            final crossCount = w < 340
                ? 1
                : w < 500
                ? 2
                : w < 760
                ? 3
                : 4;
            return GridView.count(
              crossAxisCount: crossCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: _stats.map(_statCard).toList(),
            );
          }),
          const SizedBox(height: 20),
          _sectionHeader('Analytics', Icons.analytics_rounded),
          LayoutBuilder(builder: (ctx, box) {
            final wide = box.maxWidth >= 560;
            final charts = [
              _card(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Attendance trend (last 14 days)',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  const Text('02 Jun – 16 Jun',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 10),
                  SizedBox(height: 100, child: _buildAttendanceBar()),
                ],
              )),
              _card(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Student growth (this year)',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  const Text('Jan – Jun 2026',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 10),
                  SizedBox(height: 100, child: _buildStudentLine()),
                ],
              )),
            ];
            if (wide) {
              return Row(
                children: [
                  Expanded(child: charts[0]),
                  const SizedBox(width: 12),
                  Expanded(child: charts[1]),
                ],
              );
            }
            return Column(
              children: [
                charts[0],
                const SizedBox(height: 12),
                charts[1],
              ],
            );
          }),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (ctx, box) {
            final wide = box.maxWidth >= 620;
            final recentCard = _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                    'Recent fee collections', Icons.receipt_long_rounded),
                const Divider(height: 1),
                _recentFeeRow('AM', 'Ali Muhammad', 'Class 5-A · 2 mins ago',
                    'Rs 3,500', const Color(0xFFE6F1FB), const Color(0xFF185FA5)),
                const Divider(height: 1),
                _recentFeeRow('SF', 'Sara Fatima', 'Class 3-B · 18 mins ago',
                    'Rs 2,800', const Color(0xFFEAF3DE), const Color(0xFF3B6D11)),
                const Divider(height: 1),
                _recentFeeRow('HK', 'Hamza Khan', 'Class 7-A · 34 mins ago',
                    'Rs 4,200', const Color(0xFFE1F5EE), const Color(0xFF0F6E56)),
                const Divider(height: 1),
                _recentFeeRow('ZA', 'Zainab Ahmed', 'Class 2-C · 1 hr ago',
                    'Rs 2,500', const Color(0xFFFAEEDA), const Color(0xFF854F0B)),
              ],
            ));

            final noticeCard = _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Notices', Icons.campaign_rounded),
                _noticeTile('Summer vacation: July 15 – Aug 15', 'Today, 9:00 AM'),
                _noticeTile('Annual exam schedule uploaded', 'Yesterday, 2:30 PM'),
                _noticeTile('PTM on Saturday June 28, 10 AM onwards', '2 days ago'),
                _noticeTile('Fee submission deadline: July 10', '3 days ago'),
              ],
            ));

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: recentCard),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: noticeCard),
                ],
              );
            }
            return Column(children: [
              recentCard,
              const SizedBox(height: 12),
              noticeCard,
            ]);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────
  //  BUILD
  // ─────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.role ?? 'teacher';
    final email = auth.user?.email ?? 'user@school.pk';
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leadingWidth: 48,
        leading: isWide
            ? null
            : IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.black87),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            if (isWide) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.school_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
            ],
            const Text('Dashboard',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ],
        ),
        actions: [
          if (isWide)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined, size: 15, color: Colors.grey),
                  const SizedBox(width: 4),
                  const Text('Citizens Model School',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 16),
                  const Icon(Icons.account_circle_outlined,
                      size: 15, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(email.split('@').first,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      drawer: _buildSidebar(role, email),
      bottomNavigationBar: isWide ? null : _buildBottomNav(role),
      body: isWide
          ? Row(
        children: [
          // Permanent sidebar – no Drawer wrapper, uses plain content
          SizedBox(
            width: 220,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: _sidebarContent(role, email, isDrawer: false),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          // Content area with right panel overlay
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _mainContentWidget ?? const SizedBox.shrink(),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  top: 0,
                  right: _rightPanelWidget == null
                      ? -(MediaQuery.of(context).size.width - 220)
                      : 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width - 220,
                  child: _rightPanelWidget != null
                      ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(-4, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPanelHeader(),
                        Expanded(child: _rightPanelWidget!),
                      ],
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      )
          : _buildDashboardContent(),
    );
  }
}

// ─────────────────────────────────────────────
//  Custom painter for student growth line
// ─────────────────────────────────────────────
class _LinePainter extends CustomPainter {
  final List<Offset> pts;
  const _LinePainter(this.pts);

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) return;

    final fillPath = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath
      ..lineTo(pts.last.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = _purple.withOpacity(0.08),
    );

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final c1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final c2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      linePath.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = _purple
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final p in pts) {
      canvas.drawCircle(p, 4, Paint()..color = _purple);
      canvas.drawCircle(
          p,
          4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.pts != pts;
}