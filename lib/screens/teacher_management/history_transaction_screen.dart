import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/employee_trasaction_model.dart';
import '../../providers/employee_transaction_provider.dart';
import 'add_employee_transaction.dart';

// ─────────────────────────────────────────────
//  Constants (matches EduCore brand)
// ─────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kPurpleMid = Color(0xFF6C63D4);

const _kCategoryIcons = <String, IconData>{
  'Advance': Icons.payments_outlined,
  'Loan': Icons.account_balance_outlined,
  'Expense': Icons.receipt_long_outlined,
  'Fine': Icons.gavel_outlined,
  'Reimbursement': Icons.assignment_return_outlined,
  'Others': Icons.more_horiz_rounded,
};

const _kCategoryColors = <String, Color>{
  'Advance': Color(0xFF185FA5),
  'Loan': Color(0xFF854F0B),
  'Expense': Color(0xFF993C1D),
  'Fine': Color(0xFF993556),
  'Reimbursement': Color(0xFF0F6E56),
  'Others': Color(0xFF5F5E5A),
};

const _kFilterTypes = <String>['All', 'Teacher', 'Staff'];
const _kFilterCategories = <String>[
  'All',
  'Advance',
  'Loan',
  'Expense',
  'Fine',
  'Reimbursement',
  'Others',
];

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class StaffTransactionHistoryScreen extends StatefulWidget {
  final bool showAppBar;

  const StaffTransactionHistoryScreen({super.key, this.showAppBar = true});

  @override
  State<StaffTransactionHistoryScreen> createState() =>
      _StaffTransactionHistoryScreenState();
}

class _StaffTransactionHistoryScreenState
    extends State<StaffTransactionHistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _typeFilter = 'All';
  String _categoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffTransactionProvider>().fetchAll();
    });
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() =>
      context.read<StaffTransactionProvider>().fetchAll();

  List<StaffTransaction> _applyFilters(List<StaffTransaction> all) {
    return all.where((t) {
      if (_typeFilter != 'All' &&
          t.employeeType.toLowerCase() != _typeFilter.toLowerCase()) {
        return false;
      }
      if (_categoryFilter != 'All' && t.category != _categoryFilter) {
        return false;
      }
      if (_query.isNotEmpty) {
        final haystack = [
          t.employeeName,
          t.displayCategory,
          t.note ?? '',
          t.amount.toStringAsFixed(0),
        ].join(' ').toLowerCase();
        if (!haystack.contains(_query)) return false;
      }
      return true;
    }).toList();
  }

  // ─────────────────────────────────────────────
  //  Actions
  // ─────────────────────────────────────────────
  void _openEdit(StaffTransaction txn) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;
    if (isDesktop) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780, maxHeight: 820),
            child: AddStaffTransactionScreen(
              showAppBar: false,
              existingTransaction: txn,
              onSaved: () {
                Navigator.of(dialogContext).pop();
                _refresh();
              },
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddStaffTransactionScreen(
            existingTransaction: txn,
            onSaved: () {
              Navigator.of(context).pop();
              _refresh();
            },
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(StaffTransaction txn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Transaction?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently delete the ${txn.displayCategory} entry of '
              'Rs ${txn.amount.toStringAsFixed(0)} for ${txn.employeeName}. '
              'This action cannot be undone.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<StaffTransactionProvider>().deleteTransaction(txn.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted.'),
              backgroundColor: Colors.green,
            ),
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

  // ─────────────────────────────────────────────
  //  Header: search + filters
  // ─────────────────────────────────────────────
  Widget _searchAndFilters({required bool isDesktop}) {
    final search = TextField(
      controller: _searchCtrl,
      decoration: InputDecoration(
        hintText: 'Search by name, category, note or amount…',
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, size: 18),
          onPressed: () => _searchCtrl.clear(),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
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
      ),
    );

    final typeDropdown = _dropdown(
      value: _typeFilter,
      items: _kFilterTypes,
      icon: Icons.people_outline_rounded,
      onChanged: (v) => setState(() => _typeFilter = v),
    );

    final categoryDropdown = _dropdown(
      value: _categoryFilter,
      items: _kFilterCategories,
      icon: Icons.category_outlined,
      onChanged: (v) => setState(() => _categoryFilter = v),
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(flex: 3, child: search),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: typeDropdown),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: categoryDropdown),
        ],
      );
    }

    return Column(
      children: [
        search,
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: typeDropdown),
            const SizedBox(width: 10),
            Expanded(child: categoryDropdown),
          ],
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, size: 18),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: items
              .map((v) => DropdownMenuItem(
            value: v,
            child: Row(
              children: [
                Icon(icon, size: 15, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(v),
              ],
            ),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Summary bar
  // ─────────────────────────────────────────────
  Widget _summaryBar(List<StaffTransaction> filtered) {
    final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kPurpleLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, size: 18, color: _kPurple),
          const SizedBox(width: 8),
          Text(
            '${filtered.length} transaction${filtered.length == 1 ? '' : 's'}',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: _kPurple),
          ),
          const Spacer(),
          Text(
            'Total: Rs ${NumberFormat('#,##0').format(total)}',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: _kPurple),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Category badge
  // ─────────────────────────────────────────────
  Widget _categoryBadge(StaffTransaction t) {
    final color = _kCategoryColors[t.category] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_kCategoryIcons[t.category] ?? Icons.more_horiz_rounded,
              size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            t.displayCategory,
            style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Empty state
  // ─────────────────────────────────────────────
  Widget _emptyState() {
    final hasFilters =
        _query.isNotEmpty || _typeFilter != 'All' || _categoryFilter != 'All';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            hasFilters
                ? Icons.search_off_rounded
                : Icons.receipt_long_outlined,
            size: 52,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            hasFilters
                ? 'No transactions match your search/filters.'
                : 'No transactions recorded yet.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  MOBILE: card row
  // ─────────────────────────────────────────────
  Widget _mobileCard(StaffTransaction t) {
    final initials = t.employeeName.trim().isEmpty
        ? '?'
        : t.employeeName.trim().split(' ').length >= 2
        ? '${t.employeeName.trim().split(' ')[0][0]}${t.employeeName.trim().split(' ')[1][0]}'
        .toUpperCase()
        : t.employeeName.trim()[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _kPurpleLight,
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kPurple)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.employeeName,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    Text(
                      '${t.employeeType == 'teacher' ? 'Teacher' : 'Staff'} · '
                          '${DateFormat('dd MMM, yyyy').format(t.date)}',
                      style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    size: 18, color: Colors.grey.shade600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onSelected: (v) {
                  if (v == 'edit') _openEdit(t);
                  if (v == 'delete') _confirmDelete(t);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: _kPurple),
                        SizedBox(width: 10),
                        Text('Edit', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 16, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete',
                            style: TextStyle(fontSize: 13, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _categoryBadge(t),
              const Spacer(),
              Text(
                'Rs ${NumberFormat('#,##0').format(t.amount)}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
            ],
          ),
          if ((t.note ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t.note!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DESKTOP: table row
  // ─────────────────────────────────────────────
  Widget _desktopTable(List<StaffTransaction> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _kPurpleLight,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: const [
                Expanded(
                    flex: 3,
                    child: Text('Employee',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kPurple))),
                Expanded(
                    flex: 2,
                    child: Text('Date',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kPurple))),
                Expanded(
                    flex: 2,
                    child: Text('Category',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kPurple))),
                Expanded(
                    flex: 3,
                    child: Text('Note',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kPurple))),
                Expanded(
                    flex: 2,
                    child: Text('Amount',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kPurple))),
                SizedBox(
                    width: 90,
                    child: Text('Actions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kPurple))),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, i) {
              final t = items[i];
              final initials = t.employeeName.trim().isEmpty
                  ? '?'
                  : t.employeeName.trim().split(' ').length >= 2
                  ? '${t.employeeName.trim().split(' ')[0][0]}${t.employeeName.trim().split(' ')[1][0]}'
                  .toUpperCase()
                  : t.employeeName.trim()[0].toUpperCase();

              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: _kPurpleLight,
                            child: Text(initials,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _kPurple)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.employeeName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87)),
                                Text(
                                  t.employeeType == 'teacher'
                                      ? 'Teacher'
                                      : 'Staff',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        DateFormat('dd MMM, yyyy').format(t.date),
                        style: const TextStyle(
                            fontSize: 12.5, color: Colors.black87),
                      ),
                    ),
                    Expanded(flex: 2, child: _categoryBadge(t)),
                    Expanded(
                      flex: 3,
                      child: Text(
                        (t.note ?? '').isEmpty ? '—' : t.note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.5, color: Colors.grey.shade700),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Rs ${NumberFormat('#,##0').format(t.amount)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                size: 17, color: _kPurple),
                            tooltip: 'Edit',
                            onPressed: () => _openEdit(t),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 17, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () => _confirmDelete(t),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;
    final provider = context.watch<StaffTransactionProvider>();

    final filtered = _applyFilters(provider.allTransactions);

    final body = RefreshIndicator(
      onRefresh: _refresh,
      color: _kPurple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kPurple, _kPurpleMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction History',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Advances, loans, expenses & more — for teachers and staff',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _searchAndFilters(isDesktop: isDesktop),
            const SizedBox(height: 14),
            if (provider.loading && provider.allTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kPurple)),
              )
            else ...[
              _summaryBar(filtered),
              const SizedBox(height: 14),
              if (filtered.isEmpty)
                _emptyState()
              else if (isDesktop)
                _desktopTable(filtered)
              else
                Column(
                  children: filtered.map(_mobileCard).toList(),
                ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (!widget.showAppBar) {
      return Container(color: const Color(0xFFF5F6FA), child: body);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Transaction History',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _kPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddStaffTransactionScreen(
                onSaved: () {
                  Navigator.pop(context);
                  _refresh();
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Transaction'),
      ),
      body: body,
    );
  }
}