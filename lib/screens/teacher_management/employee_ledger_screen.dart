
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../models/employee_trasaction_model.dart';
import '../../models/teacher.dart';
import '../../pdf_files/staff_ledger_pdf_generator.dart';
import '../../providers/employee_transaction_provider.dart';
import '../../providers/teacher_provider.dart';
import 'add_employee_transaction.dart';

// ─────────────────────────────────────────────
//  Design tokens (matches EduCore brand + uploaded design)
// ─────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kPurpleMid = Color(0xFF6C63D4);

const _kGreen = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFECFDF3);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEF2F2);
const _kOrange = Color(0xFFB45309);

const _kBorder = Color(0xFFE5E7EB);
const _kSurface = Color(0xFFF8FAFC);
const _kInk = Color(0xFF1A1A2E);
const _kSlate = Color(0xFF64748B);

const _kCategories = <String>[
  'All Categories',
  'Advance',
  'Loan',
  'Expense',
  'Fine',
  'Reimbursement',
  'SalaryDeduction',
  'Others',
];

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class EmployeeLedgerScreen extends StatefulWidget {
  /// Optional — if provided, the ledger opens pre-selected on this
  /// employee (e.g. when launched via the "Ledger" button on a staff /
  /// teacher row). If null, the "Select Employee" dropdown starts empty
  /// and the user picks someone from the list.
  final StaffMember? employee;

  /// When true, this screen is embedded (e.g. dashboard's right panel /
  /// mobile push without its own AppBar). When false, it renders its own
  /// Scaffold + AppBar for standalone navigation.
  final bool showAppBar;

  /// Called after a transaction is added/edited from this screen, so an
  /// embedding parent (e.g. dashboard) can react if needed.
  final VoidCallback? onChanged;

  const EmployeeLedgerScreen({
    super.key,
    this.employee,
    this.showAppBar = true,
    this.onChanged,
  });

  @override
  State<EmployeeLedgerScreen> createState() => _EmployeeLedgerScreenState();
}

class _EmployeeLedgerScreenState extends State<EmployeeLedgerScreen> {
  StaffMember? _selectedEmployee;

  List<StaffTransaction> _transactions = [];
  double _balance = 0;
  bool _loading = false;

  // Filters
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _category = 'All Categories';
  String _type = 'All Types'; // All Types / Debit / Credit

  @override
  void initState() {
    super.initState();
    _selectedEmployee = widget.employee;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final staffProvider = context.read<StaffProvider>();
      if (staffProvider.teachers.isEmpty) staffProvider.fetchTeachers();
      if (staffProvider.staffOnly.isEmpty) staffProvider.fetchStaffOnly();
      if (staffProvider.academyStaff.isEmpty) staffProvider.fetchAcademyStaff(); // ← NEW
      if (_selectedEmployee != null) _loadLedger();
    });
  }

  List<StaffMember> get _allEmployees {
    final staffProvider = context.watch<StaffProvider>();
    return [
      ...staffProvider.teachers,
      ...staffProvider.staffOnly,
      ...staffProvider.academyStaff,   // ← NEW
    ];
  }

  Future<void> _loadLedger() async {
    if (_selectedEmployee?.id == null) return;
    setState(() => _loading = true);
    try {
      final provider = context.read<StaffTransactionProvider>();
      final result = await provider.getEmployeeLedger(_selectedEmployee!.id!);
      final txns = (result['transactions'] as List<StaffTransaction>? ?? []);
      // ★ Oldest → newest (1, 2, 3 ... 31) as requested — ascending by date,
      // then by createdAt as a tie-breaker for same-day entries.
      txns.sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        return a.createdAt.compareTo(b.createdAt);
      });
      setState(() {
        _transactions = txns;
        _balance = result['balance'] ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading ledger: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onSelectEmployee(StaffMember? e) {
    setState(() {
      _selectedEmployee = e;
      _transactions = [];
      _balance = 0;
      _dateFrom = null;
      _dateTo = null;
      _category = 'All Categories';
      _type = 'All Types';
    });
    if (e != null) _loadLedger();
  }

  // ── Filtering ──
  List<StaffTransaction> get _filteredTransactions {
    return _transactions.where((t) {
      if (_dateFrom != null && t.date.isBefore(_dateFrom!)) return false;
      if (_dateTo != null &&
          t.date.isAfter(_dateTo!.add(const Duration(hours: 23, minutes: 59)))) {
        return false;
      }
      if (_category != 'All Categories' && t.category != _category) return false;
      if (_type == 'Debit' && t.transactionType != 'debit') return false;
      if (_type == 'Credit' && t.transactionType != 'credit') return false;
      return true;
    }).toList();
  }

  double get _totalDebit => _transactions
      .where((t) => t.transactionType == 'debit')
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalCredit => _transactions
      .where((t) => t.transactionType == 'credit')
      .fold(0.0, (s, t) => s + t.amount);

  StaffTransaction? get _lastTransaction =>
      _transactions.isEmpty ? null : _transactions.last;

  Future<void> _openAddTransaction() async {
    if (_selectedEmployee == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStaffTransactionScreen(showAppBar: true),
      ),
    );
    if (result != null || true) {
      _loadLedger();
      widget.onChanged?.call();
    }
  }

  Future<void> _pickDateFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context)
            .copyWith(colorScheme: const ColorScheme.light(primary: _kPurple)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateFrom = picked);
  }

  Future<void> _pickDateTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context)
            .copyWith(colorScheme: const ColorScheme.light(primary: _kPurple)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateTo = picked);
  }



  Future<void> _exportPdf() async {
    if (_selectedEmployee == null || _transactions.isEmpty) return;

    try {
      final pdfData = await generateEmployeeLedgerPdf(
        employee: _selectedEmployee!,
        transactions: _transactions,
        balance: _balance,
      );

      final fileName = '${_selectedEmployee!.name}_ledger.pdf';

      if (kIsWeb) {
        // Download + Open in browser
        await Printing.layoutPdf(
          onLayout: (_) async => pdfData,
          name: fileName,
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();

        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(pdfData);

        // Auto Open
        await OpenFile.open(file.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved:\n${file.path}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _category = 'All Categories';
      _type = 'All Types';
    });
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final content = isDesktop ? _buildDesktop() : _buildMobile();

    if (!widget.showAppBar) {
      return Container(color: _kSurface, child: content);
    }

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Employee Ledger',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      ),
      body: content,
    );
  }

  // ─────────────────────────────────────────────
  //  DESKTOP LAYOUT
  // ─────────────────────────────────────────────
  Widget _buildDesktop() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerRow(isDesktop: true),
          const SizedBox(height: 20),
          _selectEmployeeCard(),
          const SizedBox(height: 18),
          if (_selectedEmployee != null) ...[
            _summaryCardsRow(),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _ledgerTableCard()),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: _filtersCard()),
              ],
            ),
            const SizedBox(height: 16),
            _noteCard(),
          ] else
            _emptyStateCard(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MOBILE LAYOUT
  // ─────────────────────────────────────────────
  Widget _buildMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectEmployeeCard(),
          const SizedBox(height: 14),
          if (_selectedEmployee != null) ...[
            _summaryCardsRow(),
            const SizedBox(height: 14),
            _filtersCard(),
            const SizedBox(height: 14),
            _ledgerTableCard(),
            const SizedBox(height: 14),
            _noteCard(),
          ] else
            _emptyStateCard(),
        ],
      ),
    );
  }

  // ── Header (desktop only – title + New Transaction / Export) ──
  Widget _headerRow({required bool isDesktop}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Employee Ledger',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: _kInk)),
              SizedBox(height: 2),
              Text('Employees wise ledger with debit, credit & balance',
                  style: TextStyle(fontSize: 13, color: _kSlate)),
            ],
          ),
        ),
        if (_selectedEmployee != null) ...[
          ElevatedButton.icon(
            onPressed: _openAddTransaction,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: _transactions.isEmpty ? null : _exportPdf,
            icon: const Icon(Icons.ios_share_rounded, size: 16),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kInk,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }

  // ── Select Employee card ──
  Widget _selectEmployeeCard() {
    final employees = _allEmployees;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Employee',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kInk)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: isDesktop ? 4 : 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: _kBorder),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedEmployee?.id,
                      hint: const Text('Select an employee…',
                          style: TextStyle(fontSize: 13, color: _kSlate)),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kSlate),
                      items: employees
                          .where((e) => e.id != null)
                          .map((e) => DropdownMenuItem<String>(
                        value: e.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: _kPurpleLight,
                              child: Text(
                                e.name.isNotEmpty ? e.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _kPurple),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(e.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (id) {
                        final match = employees.where((e) => e.id == id);
                        _onSelectEmployee(match.isNotEmpty ? match.first : null);
                      },
                    ),
                  ),
                ),
              ),
              if (isDesktop && _selectedEmployee != null) ...[
                const SizedBox(width: 16),
                Expanded(flex: 6, child: _employeeInfoRow()),
              ],
            ],
          ),
          if (!isDesktop && _selectedEmployee != null) ...[
            const SizedBox(height: 12),
            _employeeInfoRow(),
          ],
        ],
      ),
    );
  }

  Widget _employeeInfoRow() {
    final e = _selectedEmployee!;
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final items = [
      ('Employee ID', e.id != null && e.id!.length >= 6 ? e.id!.substring(0, 6).toUpperCase() : (e.id ?? '—')),
      ('Type', e.type.isNotEmpty ? (e.type[0].toUpperCase() + e.type.substring(1)) : '—'),
      ('Designation', (e.designation ?? '').isNotEmpty ? e.designation! : '—'),
      ('Phone', e.phone.isNotEmpty ? e.phone : '—'),
    ];
    return Wrap(
      spacing: isDesktop ? 20 : 12,
      runSpacing: 8,
      children: items
          .map((kv) => SizedBox(
        width: isDesktop ? 120 : 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kv.$1,
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500)),
            const SizedBox(height: 2),
            Text(kv.$2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
          ],
        ),
      ))
          .toList(),
    );
  }

  // ── Summary cards row ──
  Widget _summaryCardsRow() {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final netLabel = _balance >= 0 ? 'Debit Balance' : 'Credit Balance';
    final netColor = _balance >= 0 ? _kRed : _kGreen;

    final cards = <Widget>[
      _summaryCard(
        icon: Icons.arrow_downward_rounded,
        iconColor: _kRed,
        iconBg: _kRedBg,
        label: 'Total Debit',
        value: 'Rs ${NumberFormat('#,##0.00').format(_totalDebit)}',
        valueColor: _kRed,
        sub: 'PKR',
      ),
      _summaryCard(
        icon: Icons.arrow_upward_rounded,
        iconColor: _kGreen,
        iconBg: _kGreenBg,
        label: 'Total Credit',
        value: 'Rs ${NumberFormat('#,##0.00').format(_totalCredit)}',
        valueColor: _kGreen,
        sub: 'PKR',
      ),
      _summaryCard(
        icon: Icons.balance_rounded,
        iconColor: _kPurple,
        iconBg: _kPurpleLight,
        label: 'Net Balance',
        value: 'Rs ${NumberFormat('#,##0.00').format(_balance.abs())}',
        valueColor: _kInk,
        sub: 'PKR',
        badge: netLabel,
        badgeColor: netColor,
      ),
      _summaryCard(
        icon: Icons.event_note_rounded,
        iconColor: _kPurple,
        iconBg: _kPurpleLight,
        label: 'Last Transaction',
        value: _lastTransaction != null
            ? DateFormat('dd MMM yyyy').format(_lastTransaction!.date)
            : '—',
        valueColor: _kInk,
        sub: _lastTransaction != null
            ? '${_lastTransaction!.transactionType == 'debit' ? 'Debit' : 'Credit'} - ${NumberFormat('#,##0').format(_lastTransaction!.amount)}'
            : 'No transactions',
        subColor: _lastTransaction?.transactionType == 'debit' ? _kRed : _kGreen,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((c) => Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: c,
        )))
            .toList(),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: cards,
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required Color valueColor,
    String? sub,
    Color? subColor,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,   // ← added: Column apni natural height se zyada demand nahi karega
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),   // 10 se 8
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: valueColor)),
          const SizedBox(height: 3),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? _kSlate).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: badgeColor ?? _kSlate)),
            )
          else if (sub != null)
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: subColor ?? Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ── Filters card ──
  Widget _filtersCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined, size: 16, color: _kPurple),
              const SizedBox(width: 6),
              const Text('Filters',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk)),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear', style: TextStyle(fontSize: 12, color: _kSlate)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _filterLabel('Date From'),
          _dateFilterField(_dateFrom, _pickDateFrom),
          const SizedBox(height: 12),
          _filterLabel('Date To'),
          _dateFilterField(_dateTo, _pickDateTo),
          const SizedBox(height: 12),
          _filterLabel('Category'),
          _dropdownField(
            value: _category,
            items: _kCategories,
            onChanged: (v) => setState(() => _category = v ?? 'All Categories'),
          ),
          const SizedBox(height: 12),
          _filterLabel('Type'),
          _dropdownField(
            value: _type,
            items: const ['All Types', 'Debit', 'Credit'],
            onChanged: (v) => setState(() => _type = v ?? 'All Types'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.filter_alt_rounded, size: 16),
              label: const Text('Apply Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
  );

  Widget _dateFilterField(DateTime? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? DateFormat('dd/MM/yyyy').format(value) : 'dd/mm/yyyy',
                style: TextStyle(
                    fontSize: 13, color: value != null ? _kInk : Colors.grey.shade400),
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 15, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kSlate),
          items: items
              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── Ledger transactions table/card (scrollable, ascending dates) ──
  Widget _ledgerTableCard() {
    final rows = _filteredTransactions;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, size: 16, color: _kPurple),
                const SizedBox(width: 8),
                const Text('Ledger Transactions',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kInk)),
                const Spacer(),
                if (_loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: _kPurple)),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 44, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text('No transactions yet',
                        style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            isDesktop ? _desktopTable(rows) : _mobileCardsList(rows),
          if (rows.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text('Opening Balance',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _kSlate)),
                  const Spacer(),
                  const Text('Rs 0.00',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kInk)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Desktop: scrollable table with fixed max height so long ledgers scroll
  // inside the card instead of pushing the whole page.
  Widget _desktopTable(List<StaffTransaction> rows) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 520),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFF8F9FC),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                _Th('DATE', flex: 11),
                _Th('PARTICULARS / DESCRIPTION', flex: 22),
                _Th('CATEGORY', flex: 13),
                _Th('DEBIT (PKR)', flex: 12, align: TextAlign.right),
                _Th('CREDIT (PKR)', flex: 12, align: TextAlign.right),
                _Th('BALANCE (PKR)', flex: 13, align: TextAlign.right),
                _Th('TYPE', flex: 9, align: TextAlign.center),
              ],
            ),
          ),
          Flexible(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rows.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, i) => _desktopRow(rows[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopRow(StaffTransaction t) {
    final isDebit = t.transactionType == 'debit';
    final color = isDebit ? _kRed : _kGreen;
    final bal = t.runningBalance ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: Text(DateFormat('dd MMM yyyy').format(t.date),
                style: const TextStyle(fontSize: 12.5, color: _kInk)),
          ),
          Expanded(
            flex: 22,
            child: Text(
              (t.note != null && t.note!.trim().isNotEmpty) ? t.note!.trim() : t.displayCategory,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: _kInk),
            ),
          ),
          Expanded(
            flex: 13,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kPurpleLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(t.displayCategory,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: _kPurple)),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              isDebit ? NumberFormat('#,##0.00').format(t.amount) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: isDebit ? _kRed : Colors.grey.shade400),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              !isDebit ? NumberFormat('#,##0.00').format(t.amount) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: !isDebit ? _kGreen : Colors.grey.shade400),
            ),
          ),
          Expanded(
            flex: 13,
            child: Text(
              '${NumberFormat('#,##0.00').format(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kRed),
            ),
          ),
          Expanded(
            flex: 9,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(isDebit ? 'Debit' : 'Credit',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile: scrollable card list
  Widget _mobileCardsList(List<StaffTransaction> rows) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _mobileRow(rows[i]),
    );
  }

  Widget _mobileRow(StaffTransaction t) {
    final isDebit = t.transactionType == 'debit';
    final color = isDebit ? _kRed : _kGreen;
    final bal = t.runningBalance ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd MMM yyyy').format(t.date),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 3),
                Text(
                  (t.note != null && t.note!.trim().isNotEmpty) ? t.note!.trim() : t.displayCategory,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kInk),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kPurpleLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(t.displayCategory,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _kPurple)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${NumberFormat('#,##0.00').format(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kRed),
              ),
              const SizedBox(height: 6),
              Text(NumberFormat('#,##0.00').format(t.amount),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(isDebit ? 'Debit' : 'Credit',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Note card ──
  Widget _noteCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPurpleLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: _kPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Note',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kPurple)),
                SizedBox(height: 4),
                Text('•  Debit entries increase your balance (Dr)',
                    style: TextStyle(fontSize: 12, color: _kInk)),
                SizedBox(height: 2),
                Text('•  Credit entries reduce your balance or create Credit (Cr)',
                    style: TextStyle(fontSize: 12, color: _kInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyStateCard() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_search_rounded, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Select an employee to view their ledger',
                  style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}

class _Th extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;
  const _Th(this.label, {this.flex = 1, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
            fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF8B8FA8), letterSpacing: 0.4),
      ),
    );
  }
}