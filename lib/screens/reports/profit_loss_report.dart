// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/fee_provider.dart';
// import '../../providers/expense_provider.dart';
//
// class ProfitLossScreen extends StatefulWidget {
//   const ProfitLossScreen({super.key});
//
//   @override
//   State<ProfitLossScreen> createState() => _ProfitLossScreenState();
// }
//
// class _ProfitLossScreenState extends State<ProfitLossScreen> {
//   @override
//   void initState() {
//     super.initState();
//     final feeProv = Provider.of<FeeProvider>(context, listen: false);
//     final expProv = Provider.of<ExpenseProvider>(context, listen: false);
//     feeProv.fetchAllReceipts();
//     expProv.fetchExpenses();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final receipts = Provider.of<FeeProvider>(context).receipts;
//     final expenses = Provider.of<ExpenseProvider>(context).expenses;
//     double income = receipts.fold(0, (sum, r) => sum + r.amountPaid);
//     double expense = expenses.fold(0, (sum, e) => sum + e.amount);
//     double profit = income - expense;
//     return Scaffold(
//       appBar: AppBar(title: const Text('Profit & Loss')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Total Income: $income', style: const TextStyle(fontSize: 18)),
//             Text('Total Expense: $expense', style: const TextStyle(fontSize: 18)),
//             const Divider(),
//             Text('Profit/Loss: $profit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: profit >= 0 ? Colors.green : Colors.red)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/profit_loss_provider.dart'; // Adjust the import path

// ────────────────────────────────────────────────────────────
//  Design Tokens – reused from salary_list_screen
// ────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6C5CE7);
const _kPurpleDark = Color(0xFF5B4BD6);
const _kPurpleLight = Color(0xFFF3F1FF);
const _kPurpleSoft = Color(0xFFEDE9FE);
const _kGreen = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFECFDF3);
const _kGreenBorder = Color(0xFFBBF7D0);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEF2F2);
const _kRedBorder = Color(0xFFFCA5A5);
const _kOrange = Color(0xFFD97706);
const _kOrangeBg = Color(0xFFFFFBEB);
const _kOrangeBorder = Color(0xFFFDE68A);
const _kBlue = Color(0xFF3B82F6);
const _kBorder = Color(0xFFE5E7EB);
const _kSurface = Color(0xFFF7F8FB);
const _kInk = Color(0xFF111827);
const _kSlate = Color(0xFF6B7280);
const _kSlateLight = Color(0xFF9CA3AF);
const double _kDesktopBreakpoint = 900;

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfitLossProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfitLossProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _kInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Profit & Loss',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _kSlate),
            tooltip: 'Refresh',
            onPressed: provider.isLoading ? null : provider.loadAll,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: provider.isLoading && provider.filteredRows.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _kPurple))
          : Column(
        children: [
          // ── Filters ──
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 24 : 16,
              16,
              isDesktop ? 24 : 16,
              16,
            ),
            child: isDesktop
                ? _buildDesktopFilters(provider)
                : _buildMobileFilters(provider),
          ),
          const SizedBox(height: 8),

          // ── Summary Cards ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
            child: _buildSummaryCards(provider, isDesktop),
          ),
          const SizedBox(height: 16),

          // ── Breakdowns ──
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildBreakdownRow(provider),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildBreakdownColumn(provider),
            ),
          const SizedBox(height: 12),

          // ── Transaction List ──
          Expanded(
            child: provider.filteredRows.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 24 : 16,
                8,
                isDesktop ? 24 : 16,
                24,
              ),
              itemCount: provider.filteredRows.length,
              itemBuilder: (context, index) {
                final row = provider.filteredRows[index];
                return _buildTransactionTile(row, isDesktop);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filters: Desktop ──────────────────────────────────────────
  Widget _buildDesktopFilters(ProfitLossProvider provider) {
    return Row(
      children: [
        // Period Preset
        _pillDropdown(
          width: 160,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PLPeriodPreset>(
              value: provider.preset,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _kInk,
              ),
              items: PLPeriodPreset.values.map((p) {
                String label;
                switch (p) {
                  case PLPeriodPreset.thisMonth:
                    label = 'This Month';
                    break;
                  case PLPeriodPreset.lastMonth:
                    label = 'Last Month';
                    break;
                  case PLPeriodPreset.thisYear:
                    label = 'This Year';
                    break;
                  case PLPeriodPreset.lastYear:
                    label = 'Last Year';
                    break;
                  case PLPeriodPreset.last7Days:
                    label = 'Last 7 Days';
                    break;
                  case PLPeriodPreset.last30Days:
                    label = 'Last 30 Days';
                    break;
                  case PLPeriodPreset.allTime:
                    label = 'All Time';
                    break;
                  case PLPeriodPreset.custom:
                    label = 'Custom';
                    break;
                }
                return DropdownMenuItem(
                  value: p,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) provider.setPreset(v);
              },
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Source Filter
        _pillDropdown(
          width: 150,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.sourceFilter,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _kInk,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Sources')),
                DropdownMenuItem(value: 'Fee Collection', child: Text('Fee')),
                DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                DropdownMenuItem(
                    value: 'Staff Transaction', child: Text('Staff Txn')),
              ],
              onChanged: (v) {
                if (v != null) provider.setSourceFilter(v);
              },
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Type Filter
        _pillDropdown(
          width: 120,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.typeFilter,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, size: 18, color: _kSlateLight),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: _kInk,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Types')),
                DropdownMenuItem(value: 'income', child: Text('Income')),
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
              ],
              onChanged: (v) {
                if (v != null) provider.setTypeFilter(v);
              },
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Reset
        OutlinedButton.icon(
          onPressed: provider.clearFilters,
          icon: const Icon(Icons.clear_all_rounded, size: 16, color: _kSlate),
          label: const Text(
            'Reset',
            style: TextStyle(color: _kSlate, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _kBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const Spacer(),

        // Search
        SizedBox(
          width: 260,
          height: 44,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search transactions…',
              hintStyle: TextStyle(color: _kSlateLight, fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 19, color: _kSlateLight),
              filled: true,
              fillColor: _kSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kPurple, width: 1.5),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close, size: 16, color: _kSlateLight),
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                },
              )
                  : null,
            ),
            onChanged: (v) => provider.setSearchQuery(v),
          ),
        ),
      ],
    );
  }

  // ─── Filters: Mobile ───────────────────────────────────────────
  Widget _buildMobileFilters(ProfitLossProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _pillDropdown(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PLPeriodPreset>(
                    value: provider.preset,
                    isExpanded: true,
                    icon: const Icon(Icons.expand_more,
                        size: 18, color: _kSlateLight),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _kInk,
                    ),
                    items: PLPeriodPreset.values.map((p) {
                      String label;
                      switch (p) {
                        case PLPeriodPreset.thisMonth:
                          label = 'This Month';
                          break;
                        case PLPeriodPreset.lastMonth:
                          label = 'Last Month';
                          break;
                        case PLPeriodPreset.thisYear:
                          label = 'This Year';
                          break;
                        case PLPeriodPreset.lastYear:
                          label = 'Last Year';
                          break;
                        case PLPeriodPreset.last7Days:
                          label = 'Last 7 Days';
                          break;
                        case PLPeriodPreset.last30Days:
                          label = 'Last 30 Days';
                          break;
                        case PLPeriodPreset.allTime:
                          label = 'All Time';
                          break;
                        case PLPeriodPreset.custom:
                          label = 'Custom';
                          break;
                      }
                      return DropdownMenuItem(
                        value: p,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) provider.setPreset(v);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _pillDropdown(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.sourceFilter,
                    isExpanded: true,
                    icon: const Icon(Icons.expand_more,
                        size: 18, color: _kSlateLight),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _kInk,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'Fee Collection', child: Text('Fee')),
                      DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                      DropdownMenuItem(
                          value: 'Staff Transaction', child: Text('Txn')),
                    ],
                    onChanged: (v) {
                      if (v != null) provider.setSourceFilter(v);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _pillDropdown(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.typeFilter,
                    isExpanded: true,
                    icon: const Icon(Icons.expand_more,
                        size: 18, color: _kSlateLight),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _kInk,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Types')),
                      DropdownMenuItem(value: 'income', child: Text('Income')),
                      DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    ],
                    onChanged: (v) {
                      if (v != null) provider.setTypeFilter(v);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.clearFilters,
                icon: const Icon(Icons.clear_all_rounded,
                    size: 16, color: _kSlate),
                label: const Text(
                  'Reset',
                  style: TextStyle(color: _kSlate, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _kBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search transactions…',
              hintStyle: TextStyle(color: _kSlateLight, fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 19, color: _kSlateLight),
              filled: true,
              fillColor: _kSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kPurple, width: 1.5),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close, size: 16, color: _kSlateLight),
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                },
              )
                  : null,
            ),
            onChanged: (v) => provider.setSearchQuery(v),
          ),
        ),
      ],
    );
  }

  // ─── Summary Cards ─────────────────────────────────────────────
  Widget _buildSummaryCards(ProfitLossProvider provider, bool isDesktop) {
    final income = provider.totalIncome;
    final expense = provider.totalExpense;
    final profit = provider.netProfit;

    final cards = [
      _SummaryCardData(
        label: 'Total Income',
        value: income,
        icon: Icons.arrow_downward_rounded,
        color: _kGreen,
        bg: _kGreenBg,
        border: _kGreenBorder,
      ),
      _SummaryCardData(
        label: 'Total Expense',
        value: expense,
        icon: Icons.arrow_upward_rounded,
        color: _kRed,
        bg: _kRedBg,
        border: _kRedBorder,
      ),
      _SummaryCardData(
        label: 'Net Profit',
        value: profit,
        icon: Icons.account_balance_rounded,
        color: profit >= 0 ? _kGreen : _kRed,
        bg: profit >= 0 ? _kGreenBg : _kRedBg,
        border: profit >= 0 ? _kGreenBorder : _kRedBorder,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: List.generate(cards.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 12),
              child: _summaryCard(cards[i]),
            ),
          );
        }),
      );
    }

    return Row(
      children: List.generate(cards.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 8),
            child: _summaryCard(cards[i], compact: true),
          ),
        );
      }),
    );
  }

  Widget _summaryCard(_SummaryCardData data, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: compact ? 14 : 16, color: data.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 10.5 : 12,
                    fontWeight: FontWeight.w600,
                    color: data.color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 4 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${data.value < 0 ? '- ' : ''}Rs ${NumberFormat('#,##0').format(data.value.abs())}',
              style: TextStyle(
                fontSize: compact ? 14 : 17,
                fontWeight: FontWeight.w800,
                color: data.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Breakdowns ──────────────────────────────────────────────
  Widget _buildBreakdownRow(ProfitLossProvider provider) {
    final expenseBreakdown = provider.expenseBreakdown();
    final incomeBreakdown = provider.incomeBreakdown();
    return Row(
      children: [
        Expanded(child: _buildBreakdownCard('Expense Breakdown', expenseBreakdown)),
        const SizedBox(width: 16),
        Expanded(child: _buildBreakdownCard('Income by Method', incomeBreakdown)),
      ],
    );
  }

  Widget _buildBreakdownColumn(ProfitLossProvider provider) {
    final expenseBreakdown = provider.expenseBreakdown();
    final incomeBreakdown = provider.incomeBreakdown();
    return Column(
      children: [
        _buildBreakdownCard('Expense Breakdown', expenseBreakdown),
        const SizedBox(height: 12),
        _buildBreakdownCard('Income by Method', incomeBreakdown),
      ],
    );
  }

  Widget _buildBreakdownCard(String title, List<PLCategoryBreakdown> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Center(
          child: Text(
            'No data for $title',
            style: TextStyle(color: _kSlateLight),
          ),
        ),
      );
    }

    final total = items.fold(0.0, (s, i) => s + i.amount);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: _kInk,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final pct = total == 0 ? 0 : (item.amount / total) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _kInk,
                      ),
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _kSlate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rs ${NumberFormat('#,##0').format(item.amount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _kInk,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ─── Transaction Tile ──────────────────────────────────────────
  Widget _buildTransactionTile(PLTransactionRow row, bool isDesktop) {
    final isIncome = row.type == 'income';
    final amountColor = isIncome ? _kGreen : _kRed;
    final iconData = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncome ? _kGreenBg : _kRedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, size: 16, color: amountColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _kInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${row.source} • ${row.subtitle}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kSlate,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (row.status != null)
                  Text(
                    'Status: ${row.status!}',
                    style: TextStyle(
                      fontSize: 11,
                      color: _kSlateLight,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} Rs ${NumberFormat('#,##0').format(row.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: amountColor,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(row.date),
                style: TextStyle(
                  fontSize: 11,
                  color: _kSlateLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────
  Widget _pillDropdown({required Widget child, double? width}) {
    return Container(
      width: width,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: _kSlateLight),
          SizedBox(height: 12),
          Text(
            'No transactions found',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _kSlate,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try adjusting filters or search',
            style: TextStyle(color: _kSlateLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Helper data classes (same as provider's) ──────────────────
class _SummaryCardData {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;

  _SummaryCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
  });
}
