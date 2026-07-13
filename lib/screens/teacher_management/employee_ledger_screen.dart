import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/employee_trasaction_model.dart';
import '../../models/teacher.dart';
import '../../providers/employee_transaction_provider.dart';
import '../../providers/teacher_provider.dart';

const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kGreen = Color(0xFF15803D);
const _kGreenBg = Color(0xFFDCFCE7);
const _kRed = Color(0xFFB91C1C);
const _kRedBg = Color(0xFFFEE2E2);
const _kAmber = Color(0xFF92400E);
const _kAmberBg = Color(0xFFFEF3C7);

/// Single combined Employee Ledger screen.
///
/// Layout (as requested — one page, not split across multiple screens):
///   1. Employee picker (pick any staff/teacher; ledger loads for them)
///   2. One shared form with a Type dropdown (Expense / Loan / Advance /
///      Repayment) — fields shown adapt slightly per type (e.g.
///      Repayment shows a "repay against which loan/advance" selector).
///   3. A table-style ledger below: Date | Details | Type | Debit |
///      Credit | Balance — with running balance and edit/delete on each row.
class EmployeeLedgerScreen extends StatefulWidget {
  final bool showAppBar;
  final StaffMember? initialStaff;

  const EmployeeLedgerScreen({
    super.key,
    this.showAppBar = true,
    this.initialStaff,
  });

  @override
  State<EmployeeLedgerScreen> createState() => _EmployeeLedgerScreenState();
}

class _EmployeeLedgerScreenState extends State<EmployeeLedgerScreen> {
  StaffMember? _selectedStaff;

  @override
  void initState() {
    super.initState();
    if (widget.initialStaff != null) {
      _selectedStaff = widget.initialStaff;
      Future.microtask(() => context
          .read<EmployeeTransactionProvider>()
          .loadLedgerForStaff(_selectedStaff!.id!));
    }
  }

  Future<void> _pickEmployee() async {
    final staffProvider = context.read<StaffProvider>();
    if (staffProvider.allStaff.isEmpty) {
      await staffProvider.fetchAll();
    }
    if (!mounted) return;

    final selected = await showModalBottomSheet<StaffMember>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EmployeePickerSheet(),
    );

    if (selected != null && mounted) {
      setState(() => _selectedStaff = selected);
      context.read<EmployeeTransactionProvider>().loadLedgerForStaff(
          selected.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _selectedStaff == null
        ? _buildEmptyState()
        : SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmployeeHeader(_selectedStaff!),
          const SizedBox(height: 16),
          _TransactionForm(staff: _selectedStaff!),
          const SizedBox(height: 16),
          _buildOutstandingSection(),
          const SizedBox(height: 16),
          _buildLedgerTable(),
        ],
      ),
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Employee Ledger',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_rounded),
            tooltip: 'Select Employee',
            onPressed: _pickEmployee,
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Select an employee to view or add ledger entries.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickEmployee,
              icon: const Icon(Icons.person_search_rounded),
              label: const Text('Select Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeHeader(StaffMember staff) {
    return Consumer<EmployeeTransactionProvider>(
      builder: (context, provider, _) {
        final balance = provider.currentNetBalance;
        final owesCompany = balance > 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kPurple, Color(0xFF6C63D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: Text(
                  staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(staff.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(
                      staff.designation?.isNotEmpty == true
                          ? staff.designation!
                          : (staff.type == 'teacher' ? 'Teacher' : 'Staff'),
                      style: TextStyle(
                          fontSize: 12, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(owesCompany ? 'Owes Company' : 'Balance',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white70)),
                  Text(
                    'Rs ${_formatMoney(balance.abs())}',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.swap_horiz_rounded,
                    color: Colors.white),
                tooltip: 'Change Employee',
                onPressed: _pickEmployee,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOutstandingSection() {
    return Consumer<EmployeeTransactionProvider>(
      builder: (context, provider, _) {
        final outstanding = provider.currentOutstanding
            .where((o) => o.computedStatus != 'settled')
            .toList();
        if (outstanding.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pending_actions_rounded,
                      size: 17, color: _kAmber),
                  SizedBox(width: 6),
                  Text('Outstanding Loans / Advances',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              ...outstanding.map((o) => _outstandingTile(o)),
            ],
          ),
        );
      },
    );
  }

  Widget _outstandingTile(OutstandingItem o) {
    final isPartial = o.computedStatus == 'partially_paid';
    final label = o.original.type == 'loan' ? 'Loan' : 'Advance';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isPartial ? _kAmberBg.withOpacity(0.4) : _kRedBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('$label — ${o.original.description}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Given: Rs ${_formatMoney(o.original.amount)}  •  Repaid: Rs ${_formatMoney(o.totalRepaid)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Rs ${_formatMoney(o.remaining)}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isPartial ? _kAmber : _kRed)),
              const Text('remaining',
                  style: TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _showRepayDialog(o.original),
            style: TextButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Repay', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showRepayDialog(EmployeeTransaction original) {
    showDialog(
      context: context,
      builder: (_) => _RepayDialog(
        staff: _selectedStaff!,
        original: original,
      ),
    );
  }

  Widget _buildLedgerTable() {
    return Consumer<EmployeeTransactionProvider>(
      builder: (context, provider, _) {
        final entries = provider.currentLedger.reversed.toList(); // newest on top for viewing
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded,
                        size: 17, color: _kPurple),
                    const SizedBox(width: 6),
                    const Text('Ledger',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (provider.loading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _kPurple),
                      ),
                  ],
                ),
              ),
              if (!provider.loading && entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('No ledger entries yet.',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                )
              else
                LayoutBuilder(builder: (ctx, box) {
                  final isNarrow = box.maxWidth < 560;
                  return isNarrow
                      ? _buildMobileCards(entries)
                      : _buildDesktopTable(entries);
                }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Desktop / wide table layout ──
  Widget _buildDesktopTable(List<LedgerEntry> entries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 560),
        child: DataTable(
          headingRowHeight: 38,
          dataRowMinHeight: 46,
          dataRowMaxHeight: 60,
          columnSpacing: 18,
          headingRowColor:
          MaterialStateProperty.all(_kPurpleLight),
          columns: const [
            DataColumn(
                label: Text('Date',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700))),
            DataColumn(
                label: Text('Details',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700))),
            DataColumn(
                label: Text('Type',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700))),
            DataColumn(
                numeric: true,
                label: Text('Debit',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700))),
            DataColumn(
                numeric: true,
                label: Text('Credit',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700))),
            DataColumn(
                numeric: true,
                label: Text('Balance',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700))),
            DataColumn(label: Text('')),
          ],
          rows: entries.map((e) {
            final tx = e.tx;
            return DataRow(cells: [
              DataCell(Text(tx.date, style: const TextStyle(fontSize: 12))),
              DataCell(SizedBox(
                width: 180,
                child: Text(tx.description,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2),
              )),
              DataCell(_typeBadge(tx)),
              DataCell(Text(
                tx.isDebit ? 'Rs ${_formatMoney(tx.amount)}' : '-',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tx.isDebit ? _kRed : Colors.grey.shade400),
              )),
              DataCell(Text(
                tx.isCredit ? 'Rs ${_formatMoney(tx.amount)}' : '-',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tx.isCredit ? _kGreen : Colors.grey.shade400),
              )),
              DataCell(Text(
                'Rs ${_formatMoney(e.runningBalance)}',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700),
              )),
              DataCell(_rowActions(tx)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  // ── Mobile card layout ──
  Widget _buildMobileCards(List<LedgerEntry> entries) {
    return Column(
      children: entries.map((e) {
        final tx = e.tx;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _typeBadge(tx),
                  const Spacer(),
                  Text(tx.date,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(height: 6),
              Text(tx.description,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (tx.isDebit)
                    Text('Debit: Rs ${_formatMoney(tx.amount)}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kRed))
                  else
                    Text('Credit: Rs ${_formatMoney(tx.amount)}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kGreen)),
                  Text('Bal: Rs ${_formatMoney(e.runningBalance)}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: _rowActions(tx),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _typeBadge(EmployeeTransaction tx) {
    Color color;
    String label;
    switch (tx.type) {
      case 'expense':
        color = tx.expenseKind == 'deduction' ? _kRed : _kAmber;
        label = 'Expense';
        break;
      case 'loan':
        color = _kRed;
        label = 'Loan';
        break;
      case 'advance':
        color = _kAmber;
        label = 'Advance';
        break;
      case 'repayment':
        color = _kGreen;
        label = 'Repayment';
        break;
      default:
        color = Colors.grey;
        label = tx.type;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _rowActions(EmployeeTransaction tx) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _editTransaction(tx),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.edit_outlined,
                size: 16, color: Colors.grey.shade500),
          ),
        ),
        InkWell(
          onTap: () => _confirmDeleteTransaction(tx),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.delete_outline_rounded,
                size: 16, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  void _editTransaction(EmployeeTransaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditTransactionSheet(
        staff: _selectedStaff!,
        transaction: tx,
      ),
    );
  }

  Future<void> _confirmDeleteTransaction(EmployeeTransaction tx) async {
    final isOriginalWithRepayments = (tx.type == 'loan' || tx.type == 'advance');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete this entry?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          isOriginalWithRepayments
              ? 'This will also delete any repayments linked to this ${tx.type}.'
              : 'This will permanently remove this entry.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: _kRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<EmployeeTransactionProvider>().deleteTransaction(
        staff: _selectedStaff!,
        tx: tx,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Entry deleted.'), backgroundColor: _kGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

String _formatMoney(double value) => NumberFormat('#,##0').format(value);

// ─────────────────────────────────────────────────────────────────────────
// Shared Transaction Form (Add) — single form, type dropdown decides
// which extra field shows (e.g. Repayment needs "which loan/advance").
// ─────────────────────────────────────────────────────────────────────────
class _TransactionForm extends StatefulWidget {
  final StaffMember staff;
  const _TransactionForm({required this.staff});

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'expense';
  String _expenseKind = 'company_expense';
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  EmployeeTransaction? _repayTarget;
  bool _isSaving = false;

  final _typeOptions = const [
    {'value': 'expense', 'label': 'Expense'},
    {'value': 'loan', 'label': 'Loan'},
    {'value': 'advance', 'label': 'Advance Salary'},
    {'value': 'repayment', 'label': 'Repayment'},
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_date),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid amount.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_type == 'repayment' && _repayTarget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select which loan/advance this repays.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<EmployeeTransactionProvider>();
    try {
      switch (_type) {
        case 'expense':
          await provider.addExpense(
            staff: widget.staff,
            amount: amount,
            description: _descCtrl.text.trim(),
            date: _date,
            expenseKind: _expenseKind,
          );
          break;
        case 'loan':
          await provider.addLoan(
            staff: widget.staff,
            amount: amount,
            description: _descCtrl.text.trim(),
            date: _date,
          );
          break;
        case 'advance':
          await provider.addAdvance(
            staff: widget.staff,
            amount: amount,
            description: _descCtrl.text.trim(),
            date: _date,
          );
          break;
        case 'repayment':
          await provider.addRepayment(
            staff: widget.staff,
            original: _repayTarget!,
            amount: amount,
            description: _descCtrl.text.trim(),
            date: _date,
          );
          break;
      }
      if (mounted) {
        _amountCtrl.clear();
        _descCtrl.clear();
        setState(() => _repayTarget = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Entry added successfully.'),
              backgroundColor: _kGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final outstandingForRepay = context
        .watch<EmployeeTransactionProvider>()
        .currentOutstanding
        .where((o) => o.computedStatus != 'settled')
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Entry',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: _inputDeco('Type *'),
              items: _typeOptions
                  .map((o) => DropdownMenuItem(
                value: o['value'],
                child: Text(o['label']!),
              ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _type = v!;
                  _repayTarget = null;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_type == 'expense') ...[
              DropdownButtonFormField<String>(
                value: _expenseKind,
                decoration: _inputDeco('Expense Kind *'),
                items: const [
                  DropdownMenuItem(
                      value: 'company_expense',
                      child: Text('Company Expense (for employee)')),
                  DropdownMenuItem(
                      value: 'deduction',
                      child: Text('Deduction (from employee)')),
                ],
                onChanged: (v) => setState(() => _expenseKind = v!),
              ),
              const SizedBox(height: 12),
            ],
            if (_type == 'repayment') ...[
              outstandingForRepay.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No outstanding loans or advances for this employee.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
                  : DropdownButtonFormField<EmployeeTransaction>(
                value: _repayTarget,
                decoration: _inputDeco('Repay Against *'),
                items: outstandingForRepay.map((o) {
                  final label =
                      '${o.original.type == 'loan' ? 'Loan' : 'Advance'} • Rs ${_formatMoney(o.remaining)} remaining';
                  return DropdownMenuItem(
                    value: o.original,
                    child: Text(label,
                        overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _repayTarget = v),
                validator: (v) =>
                v == null ? 'Please select a loan/advance' : null,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration:
              _inputDeco('Amount *', prefixText: 'Rs  '),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: _date),
              decoration: _inputDeco('Date *').copyWith(
                suffixIcon: const Icon(Icons.calendar_today,
                    size: 18, color: _kPurple),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: _inputDeco(
                _type == 'repayment' ? 'Note (Optional)' : 'Description *',
                hint: _type == 'repayment'
                    ? 'e.g. Partial repayment via cash'
                    : 'e.g. Medical expense, Emergency loan...',
              ),
              validator: _type == 'repayment'
                  ? null
                  : (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSaving
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Text('Add Entry',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDeco(String label, {String? hint, String? prefixText}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixText: prefixText,
    labelStyle: const TextStyle(fontSize: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _kPurple, width: 1.5),
    ),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Repay dialog (quick-repay from the Outstanding section)
// ─────────────────────────────────────────────────────────────────────────
class _RepayDialog extends StatefulWidget {
  final StaffMember staff;
  final EmployeeTransaction original;
  const _RepayDialog({required this.staff, required this.original});

  @override
  State<_RepayDialog> createState() => _RepayDialogState();
}

class _RepayDialogState extends State<_RepayDialog> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid amount.'),
            backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await context.read<EmployeeTransactionProvider>().addRepayment(
        staff: widget.staff,
        original: widget.original,
        amount: amount,
        description: _noteCtrl.text.trim(),
        date: _date,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Record Repayment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputDeco('Amount *', prefixText: 'Rs  '),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteCtrl,
            decoration: _inputDeco('Note (Optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          style: ElevatedButton.styleFrom(
              backgroundColor: _kPurple, foregroundColor: Colors.white),
          child: _isSaving
              ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Edit sheet — reuses same field set, prefilled.
// ─────────────────────────────────────────────────────────────────────────
class _EditTransactionSheet extends StatefulWidget {
  final StaffMember staff;
  final EmployeeTransaction transaction;
  const _EditTransactionSheet(
      {required this.staff, required this.transaction});

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descCtrl;
  late String _date;
  late String _expenseKind;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _amountCtrl = TextEditingController(text: tx.amount.toStringAsFixed(0));
    _descCtrl = TextEditingController(text: tx.description);
    _date = tx.date;
    _expenseKind = tx.expenseKind ?? 'company_expense';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_date),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid amount.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = widget.transaction.copyWith(
        amount: amount,
        description: _descCtrl.text.trim(),
        date: _date,
        expenseKind:
        widget.transaction.type == 'expense' ? _expenseKind : null,
      );
      await context.read<EmployeeTransactionProvider>().editTransaction(
        staff: widget.staff,
        updated: updated,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Edit ${tx.type[0].toUpperCase()}${tx.type.substring(1)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (tx.type == 'expense') ...[
                DropdownButtonFormField<String>(
                  value: _expenseKind,
                  decoration: _inputDeco('Expense Kind *'),
                  items: const [
                    DropdownMenuItem(
                        value: 'company_expense',
                        child: Text('Company Expense (for employee)')),
                    DropdownMenuItem(
                        value: 'deduction',
                        child: Text('Deduction (from employee)')),
                  ],
                  onChanged: (v) => setState(() => _expenseKind = v!),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDeco('Amount *', prefixText: 'Rs  '),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: _date),
                decoration: _inputDeco('Date *').copyWith(
                  suffixIcon: const Icon(Icons.calendar_today,
                      size: 18, color: _kPurple),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: _inputDeco('Description'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Employee picker bottom sheet (same pattern as Salary Management screen)
// ─────────────────────────────────────────────────────────────────────────
class _EmployeePickerSheet extends StatefulWidget {
  const _EmployeePickerSheet();

  @override
  State<_EmployeePickerSheet> createState() => _EmployeePickerSheetState();
}

class _EmployeePickerSheetState extends State<_EmployeePickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _typeFilter = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<StaffMember> _filtered(List<StaffMember> all) {
    var list = all.where((s) => s.isActive).toList();
    if (_typeFilter != 'all') {
      list = list.where((s) => s.type == _typeFilter).toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where((s) =>
      s.name.toLowerCase().contains(_query) ||
          (s.designation ?? '').toLowerCase().contains(_query))
          .toList();
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final filtered = _filtered(staffProvider.allStaff);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.person_search_rounded,
                        color: _kPurple, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Select Employee',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by name or designation…',
                    hintStyle:
                    TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _filterChip('Teachers', 'teacher'),
                    const SizedBox(width: 8),
                    _filterChip('Staff', 'staff'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: staffProvider.loading
                    ? const Center(
                    child: CircularProgressIndicator(color: _kPurple))
                    : filtered.isEmpty
                    ? Center(
                  child: Text('No employees found.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500)),
                )
                    : ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  itemBuilder: (ctx, i) {
                    final s = filtered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: _kPurpleLight,
                        child: Text(
                          s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _kPurple),
                        ),
                      ),
                      title: Text(s.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        [
                          s.type == 'teacher' ? 'Teacher' : 'Staff',
                          if (s.designation?.isNotEmpty == true)
                            s.designation!,
                        ].join(' • '),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      onTap: () => Navigator.pop(context, s),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _typeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _typeFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _kPurple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _kPurple : Colors.grey.shade300,
            width: selected ? 1.5 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}