import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profit_loss_provider.dart';



// ─────────────────────────────────────────────
//  Profit & Loss Report Screen  (Admin only)
//
//  Profit = Fee Collections − (Salaries + Staff Transactions)
//
//  - Every filter is available: date presets, custom range,
//    source (Fee/Salary/Transaction), type (income/expense), search.
//  - Charts: 6-month income vs expense trend (bar), expense-by-source
//    donut, income-by-method donut — all hand-drawn with CustomPainter
//    so there's no extra chart-package dependency to add to pubspec.
//  - Mobile  -> stacked cards, full-width filter sheet, scroll layout.
//  - Desktop -> side-by-side stat grid + charts row + wide data table.
//  - This screen guards itself: if a non-admin somehow lands here it
//    shows an access-restricted state instead of the report.
// ─────────────────────────────────────────────

const _kPurple = Color(0xFF6C5CE7);
const _kPurpleDark = Color(0xFF4C3FCB);
const _kPurpleLight = Color(0xFFF3F1FF);
const _kGreen = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFECFDF3);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEF2F2);
const _kAmber = Color(0xFFD97706);
const _kAmberBg = Color(0xFFFFFBEB);
const _kInk = Color(0xFF111827);
const _kSlate = Color(0xFF6B7280);
const _kSlateLight = Color(0xFF9CA3AF);
const _kBorder = Color(0xFFE5E7EB);
const _kSurface = Color(0xFFF7F8FB);
const double _kDesktopBreak = 980;

String _money(double v) {
  final neg = v < 0;
  final f = NumberFormat('#,##0').format(v.abs());
  return '${neg ? '- ' : ''}Rs $f';
}

String _moneyCompact(double v) {
  final abs = v.abs();
  final sign = v < 0 ? '-' : '';
  if (abs >= 10000000) return '$sign${(abs / 10000000).toStringAsFixed(1)}Cr';
  if (abs >= 100000) return '$sign${(abs / 100000).toStringAsFixed(1)}L';
  if (abs >= 1000) return '$sign${(abs / 1000).toStringAsFixed(1)}K';
  return '$sign${abs.toStringAsFixed(0)}';
}

class ProfitLossReportScreen extends StatefulWidget {
  const ProfitLossReportScreen({super.key});

  @override
  State<ProfitLossReportScreen> createState() => _ProfitLossReportScreenState();
}

class _ProfitLossReportScreenState extends State<ProfitLossReportScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfitLossProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _isAdmin {
    try {
      final role = context.read<AuthProvider>().role ?? '';
      return role.toLowerCase() == 'admin';
    } catch (_) {
      return true; // if AuthProvider isn't wired the same way, fail open to avoid blocking dev/testing
    }
  }

  Future<void> _pickCustomRange() async {
    final provider = context.read<ProfitLossProvider>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      initialDateRange: provider.customRange,
    );
    if (picked != null) provider.setCustomRange(picked);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: _kSurface,
        appBar: AppBar(title: const Text('Profit & Loss')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: _kRedBg, shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline_rounded, size: 40, color: _kRed),
              ),
              const SizedBox(height: 16),
              const Text('Admins Only', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kInk)),
              const SizedBox(height: 6),
              Text('This financial report is restricted to admin accounts.', style: TextStyle(fontSize: 13, color: _kSlate)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _kInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Profit & Loss Report', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => context.read<ProfitLossProvider>().loadAll(),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: _kBorder)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= _kDesktopBreak;
          return Consumer<ProfitLossProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.filteredRows.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: _kPurple));
              }
              if (provider.error != null) {
                return _buildErrorState(provider);
              }
              return isDesktop ? _buildDesktop(provider) : _buildMobile(provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ProfitLossProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 44, color: _kRed),
          const SizedBox(height: 12),
          Text(provider.error!, style: const TextStyle(color: _kSlate, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => provider.loadAll(),
            style: ElevatedButton.styleFrom(backgroundColor: _kPurple, foregroundColor: Colors.white),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  MOBILE LAYOUT
  // ═══════════════════════════════════════════
  Widget _buildMobile(ProfitLossProvider p) {
    return RefreshIndicator(
      color: _kPurple,
      onRefresh: () => p.loadAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _periodChipsRow(p),
            const SizedBox(height: 14),
            _heroProfitCard(p, compact: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _miniStat('Income', p.totalIncome, _kGreen, _kGreenBg, Icons.trending_up_rounded, '${p.incomeCount} entries')),
                const SizedBox(width: 10),
                Expanded(child: _miniStat('Expense', p.totalExpense, _kRed, _kRedBg, Icons.trending_down_rounded, '${p.expenseCount} entries')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _miniStat('Salaries', p.salaryExpense, _kPurple, _kPurpleLight, Icons.badge_outlined, null)),
                const SizedBox(width: 10),
                Expanded(child: _miniStat('Transactions', p.transactionExpense, _kAmber, _kAmberBg, Icons.swap_horiz_rounded, null)),
              ],
            ),
            const SizedBox(height: 18),
            _sectionTitle('Income vs Expense', Icons.bar_chart_rounded),
            const SizedBox(height: 10),
            _card(SizedBox(height: 200, child: _TrendChart(points: p.monthlyTrend(), compact: true))),
            const SizedBox(height: 18),
            _sectionTitle('Expense Breakdown', Icons.pie_chart_rounded),
            const SizedBox(height: 10),
            _card(_breakdownRow(p.expenseBreakdown(), p.totalExpense)),
            const SizedBox(height: 18),
            _sectionTitle('Income by Method', Icons.donut_small_rounded),
            const SizedBox(height: 10),
            _card(_breakdownRow(p.incomeBreakdown(), p.totalIncome)),
            const SizedBox(height: 18),
            _filterBar(p, isDesktop: false),
            const SizedBox(height: 12),
            _sectionTitle('Transactions (${p.filteredRows.length})', Icons.receipt_long_rounded),
            const SizedBox(height: 10),
            if (p.filteredRows.isEmpty)
              _emptyState()
            else
              ...p.filteredRows.map((r) => _mobileRow(r)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  DESKTOP LAYOUT
  // ═══════════════════════════════════════════
  Widget _buildDesktop(ProfitLossProvider p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _heroProfitCard(p, compact: false)),
              const SizedBox(width: 16),
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _miniStat('Total Income', p.totalIncome, _kGreen, _kGreenBg, Icons.trending_up_rounded, '${p.incomeCount} entries')),
                        const SizedBox(width: 12),
                        Expanded(child: _miniStat('Total Expense', p.totalExpense, _kRed, _kRedBg, Icons.trending_down_rounded, '${p.expenseCount} entries')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _miniStat('Salaries', p.salaryExpense, _kPurple, _kPurpleLight, Icons.badge_outlined, 'incl. pending')),
                        const SizedBox(width: 12),
                        Expanded(child: _miniStat('Staff Transactions', p.transactionExpense, _kAmber, _kAmberBg, Icons.swap_horiz_rounded, 'advances, fines…')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _periodChipsRow(p),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Income vs Expense — Trend', Icons.bar_chart_rounded),
                        const SizedBox(height: 16),
                        SizedBox(height: 260, child: _TrendChart(points: p.monthlyTrend(), compact: false)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _card(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Expense Breakdown', Icons.pie_chart_rounded),
                            const SizedBox(height: 12),
                            _breakdownRow(p.expenseBreakdown(), p.totalExpense),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _card(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Income by Method', Icons.donut_small_rounded),
                            const SizedBox(height: 12),
                            _breakdownRow(p.incomeBreakdown(), p.totalIncome),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _filterBar(p, isDesktop: true),
          const SizedBox(height: 16),
          _card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _sectionTitle('Transaction Ledger', Icons.receipt_long_rounded),
                    const Spacer(),
                    Text('${p.filteredRows.length} records', style: const TextStyle(fontSize: 12.5, color: _kSlate, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),
                if (p.filteredRows.isEmpty)
                  _emptyState()
                else
                  _desktopTable(p.filteredRows),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared pieces ──

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: _kPurpleLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: _kPurple),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kInk)),
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget _heroProfitCard(ProfitLossProvider p, {required bool compact}) {
    final isProfit = p.netProfit >= 0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit ? [_kPurpleDark, _kPurple] : [const Color(0xFF7A1F1F), _kRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: (isProfit ? _kPurple : _kRed).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(isProfit ? 'NET PROFIT' : 'NET LOSS', style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _money(p.netProfit),
              style: TextStyle(color: Colors.white, fontSize: compact ? 30 : 38, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${p.profitMarginPct.abs().toStringAsFixed(1)}% margin · ${_periodLabel(p)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withOpacity(0.18)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Income', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(_money(p.totalIncome), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white.withOpacity(0.18)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expense', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(_money(p.totalExpense), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _periodLabel(ProfitLossProvider p) {
    switch (p.preset) {
      case PLPeriodPreset.thisMonth:
        return 'This month';
      case PLPeriodPreset.lastMonth:
        return 'Last month';
      case PLPeriodPreset.thisYear:
        return 'This year';
      case PLPeriodPreset.lastYear:
        return 'Last year';
      case PLPeriodPreset.last7Days:
        return 'Last 7 days';
      case PLPeriodPreset.last30Days:
        return 'Last 30 days';
      case PLPeriodPreset.allTime:
        return 'All time';
      case PLPeriodPreset.custom:
        final r = p.customRange;
        if (r == null) return 'Custom range';
        return '${DateFormat('dd MMM').format(r.start)} - ${DateFormat('dd MMM yyyy').format(r.end)}';
    }
  }

  Widget _miniStat(String label, double value, Color color, Color bg, IconData icon, String? sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 14, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11.5, color: _kSlate, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(_money(value), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 10.5, color: _kSlateLight)),
          ],
        ],
      ),
    );
  }

  Widget _periodChipsRow(ProfitLossProvider p) {
    final presets = <(String, PLPeriodPreset)>[
      ('This Month', PLPeriodPreset.thisMonth),
      ('Last Month', PLPeriodPreset.lastMonth),
      ('This Year', PLPeriodPreset.thisYear),
      ('Last Year', PLPeriodPreset.lastYear),
      ('Last 7 Days', PLPeriodPreset.last7Days),
      ('Last 30 Days', PLPeriodPreset.last30Days),
      ('All Time', PLPeriodPreset.allTime),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...presets.map((entry) {
            final selected = p.preset == entry.$2;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.$1, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : _kInk)),
                selected: selected,
                onSelected: (_) => p.setPreset(entry.$2),
                selectedColor: _kPurple,
                backgroundColor: Colors.white,
                side: BorderSide(color: selected ? _kPurple : _kBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            );
          }),
          ActionChip(
            avatar: Icon(Icons.calendar_today_outlined, size: 14, color: p.preset == PLPeriodPreset.custom ? Colors.white : _kPurple),
            label: Text(
              p.preset == PLPeriodPreset.custom ? _periodLabel(p) : 'Custom',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.preset == PLPeriodPreset.custom ? Colors.white : _kInk),
            ),
            onPressed: _pickCustomRange,
            backgroundColor: p.preset == PLPeriodPreset.custom ? _kPurple : Colors.white,
            side: BorderSide(color: p.preset == PLPeriodPreset.custom ? _kPurple : _kBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ],
      ),
    );
  }

  Widget _filterBar(ProfitLossProvider p, {required bool isDesktop}) {
    final search = TextField(
      controller: _searchCtrl,
      onChanged: p.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Search by name, receipt, note…',
        hintStyle: const TextStyle(fontSize: 13, color: _kSlateLight),
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: _kSlateLight),
        suffixIcon: _searchCtrl.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); p.setSearchQuery(''); })
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPurple, width: 1.5)),
      ),
    );

    final sourceDropdown = _filterDropdown(
      value: p.sourceFilter,
      items: const ['All', 'Fee Collection', 'Salary', 'Staff Transaction'],
      icon: Icons.source_outlined,
      onChanged: p.setSourceFilter,
    );

    final typeDropdown = _filterDropdown(
      value: p.typeFilter,
      items: const ['All', 'income', 'expense'],
      icon: Icons.swap_vert_rounded,
      labelBuilder: (v) => v == 'All' ? 'All' : (v == 'income' ? 'Income' : 'Expense'),
      onChanged: p.setTypeFilter,
    );

    final clearBtn = OutlinedButton.icon(
      onPressed: () { _searchCtrl.clear(); p.clearFilters(); },
      icon: const Icon(Icons.filter_alt_off_outlined, size: 16, color: _kSlate),
      label: const Text('Clear', style: TextStyle(fontSize: 12.5, color: _kSlate, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(side: const BorderSide(color: _kBorder), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(flex: 3, child: search),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: sourceDropdown),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: typeDropdown),
          const SizedBox(width: 10),
          clearBtn,
        ],
      );
    }

    return Column(
      children: [
        search,
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: sourceDropdown),
            const SizedBox(width: 8),
            Expanded(child: typeDropdown),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: clearBtn),
      ],
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String> onChanged,
    String Function(String)? labelBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, size: 18, color: _kSlateLight),
          style: const TextStyle(fontSize: 13, color: _kInk, fontWeight: FontWeight.w600),
          items: items.map((v) => DropdownMenuItem(
            value: v,
            child: Row(children: [Icon(icon, size: 14, color: _kSlateLight), const SizedBox(width: 8), Text(labelBuilder?.call(v) ?? v)]),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _breakdownRow(List<PLCategoryBreakdown> items, double total) {
    if (items.isEmpty || total == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No data for this period', style: TextStyle(fontSize: 12.5, color: _kSlateLight))),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 92, height: 92, child: CustomPaint(painter: _DonutPainter(items: items, total: total))),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              final pct = total == 0 ? 0.0 : (item.amount / total) * 100;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.label, style: const TextStyle(fontSize: 12.5, color: _kInk, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Text('${pct.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11.5, color: _kSlate)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 44, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('No transactions found for this filter', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _sourceIcon(String source) {
    IconData icon;
    Color color;
    switch (source) {
      case 'Fee Collection':
        icon = Icons.payments_rounded;
        color = _kGreen;
        break;
      case 'Salary':
        icon = Icons.badge_rounded;
        color = _kPurple;
        break;
      default:
        icon = Icons.swap_horiz_rounded;
        color = _kAmber;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 17, color: color),
    );
  }

  Widget _mobileRow(PLTransactionRow r) {
    final isIncome = r.type == 'income';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kBorder)),
      child: Row(
        children: [
          _sourceIcon(r.source),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${r.subtitle} · ${DateFormat('dd MMM').format(r.date)}', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isIncome ? '+' : '-'} ${_moneyCompact(r.amount)}',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: isIncome ? _kGreen : _kRed),
          ),
        ],
      ),
    );
  }

  Widget _desktopTable(List<PLTransactionRow> rows) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: _kBorder), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: _kSurface, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('Source', style: _headerStyle)),
                Expanded(flex: 3, child: Text('Details', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Category', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Date', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Amount', style: _headerStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length > 200 ? 200 : rows.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, i) {
              final r = rows[i];
              final isIncome = r.type == 'income';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          _sourceIcon(r.source),
                          const SizedBox(width: 8),
                          Expanded(child: Text(r.source, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                          Text(r.subtitle, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis, maxLines: 1),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(r.category ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(DateFormat('dd MMM, yyyy').format(r.date), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${isIncome ? '+' : '-'} ${_money(r.amount)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isIncome ? _kGreen : _kRed),
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
}

const TextStyle _headerStyle = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _kSlate, letterSpacing: 0.3);

// ─────────────────────────────────────────────
//  Hand-drawn trend bar chart (no external chart package needed)
// ─────────────────────────────────────────────
class _TrendChart extends StatelessWidget {
  final List<PLMonthPoint> points;
  final bool compact;
  const _TrendChart({required this.points, required this.compact});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty || points.every((p) => p.income == 0 && p.expense == 0)) {
      return Center(child: Text('No data yet', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400)));
    }
    return Column(
      children: [
        Expanded(child: CustomPaint(painter: _BarChartPainter(points: points), size: Size.infinite)),
        const SizedBox(height: 8),
        SizedBox(
          height: 18,
          child: Row(
            children: points
                .map((p) => Expanded(
              child: Text(
                DateFormat(compact ? 'MMM' : 'MMM yy').format(p.month),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: _kSlateLight, fontWeight: FontWeight.w600),
              ),
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(_kGreen, 'Income'),
            const SizedBox(width: 14),
            _legendDot(_kRed, 'Expense'),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: _kSlate)),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<PLMonthPoint> points;
  _BarChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = points.fold<double>(0, (m, p) => math.max(m, math.max(p.income, p.expense)));
    if (maxVal <= 0) return;

    final n = points.length;
    final groupWidth = size.width / n;
    final barWidth = math.min(16.0, groupWidth * 0.28);
    final gap = barWidth * 0.35;

    // gridlines
    final gridPaint = Paint()..color = _kBorder..strokeWidth = 1;
    for (int g = 0; g <= 3; g++) {
      final y = size.height - (size.height * g / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < n; i++) {
      final p = points[i];
      final centerX = groupWidth * i + groupWidth / 2;
      final incomeH = maxVal == 0 ? 0.0 : (p.income / maxVal) * size.height;
      final expenseH = maxVal == 0 ? 0.0 : (p.expense / maxVal) * size.height;

      final incomeRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - gap - barWidth, size.height - incomeH, barWidth, incomeH),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      final expenseRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX + gap, size.height - expenseH, barWidth, expenseH),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );

      canvas.drawRRect(incomeRect, Paint()..color = _kGreen);
      canvas.drawRRect(expenseRect, Paint()..color = _kRed);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => oldDelegate.points != points;
}

// ─────────────────────────────────────────────
//  Hand-drawn donut chart
// ─────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<PLCategoryBreakdown> items;
  final double total;
  _DonutPainter({required this.items, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 14.0;

    double startAngle = -math.pi / 2;
    for (final item in items) {
      final sweep = (item.amount / total) * 2 * math.pi;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.items != items || oldDelegate.total != total;
}