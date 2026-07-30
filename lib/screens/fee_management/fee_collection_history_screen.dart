import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/fee_collection_model.dart';
import '../../providers/fee_collection_provider.dart';
import '../dashboard_screen.dart';
import 'fee_collection_screen.dart';

// ─────────────────────────────────────────────
//  Fee Collection History Screen
//
//  Shows every recorded payment (fee_collections docs)
//  with:
//    - search (family name / father / family ID / phone / receipt#)
//    - payment method filter (All / Cash / Bank / Online)
//    - date range filter
//    - total of currently filtered results
//    - delete (removes from Firestore + local list, with confirm dialog)
//
//  Desktop: table-style rows in a card.
//  Mobile:  stacked detail cards.
// ─────────────────────────────────────────────
class FeeCollectionHistoryScreen extends StatefulWidget {
  const FeeCollectionHistoryScreen({super.key});

  @override
  State<FeeCollectionHistoryScreen> createState() =>
      _FeeCollectionHistoryScreenState();
}

class _FeeCollectionHistoryScreenState
    extends State<FeeCollectionHistoryScreen> {
  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeCollectionProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FeeCollectionScreen()),
    );
  }
  void _openHome() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }


  Future<void> _pickDateRange() async {
    final provider = context.read<FeeCollectionProvider>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: provider.historyDateRange,
    );
    if (picked != null) {
      provider.setHistoryDateRange(picked);
    }
  }

  Future<void> _confirmDelete(FeeCollectionModel c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Payment Delete Karein?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ye payment permanently database se delete ho jayegi. Ye action undo nahi ho sakta.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${c.familyName} (${c.familyId})',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Receipt: ${c.receiptNumber}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  Text('Amount: Rs ${c.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final provider = context.read<FeeCollectionProvider>();
    final ok = await provider.deleteCollection(c.id!);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Payment delete ho gayi' : (provider.error ?? 'Delete fail ho gaya')),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  String _fmtMoney(double v) => 'Rs ${v.toStringAsFixed(0)}';

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text('Fee Collection History'),
        centerTitle: true,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openHome,
            icon: const Icon(Icons.home),
            tooltip: 'Home Screen',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _openAddPayment,
            tooltip: 'Add Payment',
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FeeCollectionProvider>().loadHistory(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFilterBar(isWide),
                const SizedBox(height: 12),
                _buildSummaryBar(),
                const SizedBox(height: 12),
                Expanded(
                  child: isWide ? _buildTable() : _buildMobileList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Search + method filter + date range filter ──
  Widget _buildFilterBar(bool isWide) {
    final provider = context.watch<FeeCollectionProvider>();

    final searchField = TextField(
      controller: _searchCtrl,
      decoration: InputDecoration(
        hintText: 'Family, father, ID, phone ya receipt# search karein...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: _purple, size: 20),
        suffixIcon: _searchCtrl.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, size: 18),
          onPressed: () {
            _searchCtrl.clear();
            provider.setHistorySearch('');
          },
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onChanged: provider.setHistorySearch,
    );

    final methodDropdown = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.historyMethodFilter,
          items: ['All', 'Cash', 'Bank', 'Online']
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (v) => provider.setHistoryMethodFilter(v ?? 'All'),
        ),
      ),
    );

    final dateButton = OutlinedButton.icon(
      onPressed: _pickDateRange,
      icon: const Icon(Icons.calendar_today_outlined, size: 16),
      label: Text(
        provider.historyDateRange == null
            ? 'Date Range'
            : '${_fmtDate(provider.historyDateRange!.start)} - ${_fmtDate(provider.historyDateRange!.end)}',
        style: const TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _purple,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final clearButton = IconButton(
      onPressed: () {
        _searchCtrl.clear();
        provider.clearHistoryFilters();
      },
      icon: const Icon(Icons.filter_alt_off_outlined),
      tooltip: 'Clear filters',
      color: Colors.grey.shade600,
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(flex: 3, child: searchField),
          const SizedBox(width: 10),
          methodDropdown,
          const SizedBox(width: 10),
          dateButton,
          const SizedBox(width: 4),
          clearButton,
        ],
      );
    }

    return Column(
      children: [
        searchField,
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: methodDropdown),
            const SizedBox(width: 8),
            Expanded(child: dateButton),
            clearButton,
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryBar() {
    final provider = context.watch<FeeCollectionProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _lightPurple,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: _purple, size: 20),
          const SizedBox(width: 10),
          Text(
            '${provider.history.length} payment(s)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const Spacer(),
          Text(
            'Total: ${_fmtMoney(provider.historyTotal)}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: _purple),
          ),
        ],
      ),
    );
  }

  // ── Desktop: table layout ──
  Widget _buildTable() {
    final provider = context.watch<FeeCollectionProvider>();

    if (provider.isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.history.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('Receipt#', style: _headerStyle)),
                Expanded(flex: 3, child: Text('Family', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Father', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Amount', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Method', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Date', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Note', style: _headerStyle)),
                SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: provider.history.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, i) {
                final c = provider.history[i];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text(c.receiptNumber,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600))),
                      Expanded(
                          flex: 3,
                          child: Text(c.familyName,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis)),
                      Expanded(
                          flex: 2,
                          child: Text(c.fatherName,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis)),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _fmtMoney(c.amount),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _MethodBadge(method: c.paymentMethod),
                      ),
                      Expanded(
                          flex: 2,
                          child: Text(_fmtDate(c.paymentDate),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                      Expanded(
                        flex: 2,
                        child: Text(
                          c.note?.isNotEmpty == true ? c.note! : '-',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _confirmDelete(c),
                          tooltip: 'Delete',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile: stacked cards ──
  Widget _buildMobileList() {
    final provider = context.watch<FeeCollectionProvider>();

    if (provider.isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.history.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: provider.history.length,
      itemBuilder: (context, i) {
        final c = provider.history[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.familyName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(
                          '${c.fatherName} • ${c.familyId}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _fmtMoney(c.amount),
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MethodBadge(method: c.paymentMethod),
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today_outlined,
                      size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(_fmtDate(c.paymentDate),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const Spacer(),
                  Text(c.receiptNumber,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic)),
                ],
              ),
              if (c.note?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  c.note!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
              const Divider(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(c),
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Koi payment nahi mili',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: Colors.black54,
);

// ─────────────────────────────────────────────
//  Small colored badge for payment method
// ─────────────────────────────────────────────
class _MethodBadge extends StatelessWidget {
  final String method;
  const _MethodBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (method) {
      case 'Bank':
        color = Colors.blue;
        break;
      case 'Online':
        color = Colors.purple;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        method,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}