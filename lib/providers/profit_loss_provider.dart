import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
//  Profit & Loss Provider
//
//  FORMULA (per Umair):
//  ----------------------------------------------
//  Profit = Fee Collections − (Salaries generated + Staff Transactions)
//
//  - Income  = every fee_collections doc (all payments received)
//  - Expense = every salary_records doc (ALL statuses — Paid AND
//              Pending both count as an expense the moment they're
//              generated, per Umair) + every staff_transactions doc
//              (advances, loans, expenses, fines, reimbursements…)
//
//  Everything here is read directly from Firestore (not from the
//  other providers' in-memory lists) so this screen works standalone
//  and always reflects the true stored data, independent of whatever
//  filters/state those other screens happen to be in.
//
//  All three collections are fetched for the widest possible range
//  once, then every filter (date range / month / year / preset) is
//  applied client-side — same "instant filtering" pattern already
//  used in FeeCollectionProvider's history screen.
// ─────────────────────────────────────────────

enum PLPeriodPreset { thisMonth, lastMonth, thisYear, lastYear, last7Days, last30Days, custom, allTime }

class PLTransactionRow {
  final String id;
  final String type; // 'income' | 'expense'
  final String source; // 'Fee Collection' | 'Salary' | 'Staff Transaction'
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String? category;
  final String? status;

  PLTransactionRow({
    required this.id,
    required this.type,
    required this.source,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    this.category,
    this.status,
  });
}

class PLMonthPoint {
  final DateTime month;
  final double income;
  final double expense;
  double get profit => income - expense;
  PLMonthPoint({required this.month, required this.income, required this.expense});
}

class PLCategoryBreakdown {
  final String label;
  final double amount;
  final Color color;
  PLCategoryBreakdown({required this.label, required this.amount, required this.color});
}

class ProfitLossProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ── Raw rows loaded from Firestore (unfiltered) ──
  List<PLTransactionRow> _allRows = [];

  // ── Filtered result (recomputed on every filter change) ──
  List<PLTransactionRow> _filteredRows = [];
  List<PLTransactionRow> get filteredRows => _filteredRows;

  // ── Filters ──
  PLPeriodPreset _preset = PLPeriodPreset.thisMonth;
  PLPeriodPreset get preset => _preset;

  DateTimeRange? _customRange;
  DateTimeRange? get customRange => _customRange;

  String _sourceFilter = 'All'; // All / Fee Collection / Salary / Staff Transaction
  String get sourceFilter => _sourceFilter;

  String _typeFilter = 'All'; // All / income / expense
  String get typeFilter => _typeFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  DateTimeRange get effectiveRange => _resolveRange();

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _db.collection('fee_collections').get(),
        _db.collection('salaries').get(),
        _db.collection('staff_transactions').get(),
      ]);

      final feeSnap = results[0];
      final salarySnap = results[1];
      final txnSnap = results[2];

      final List<PLTransactionRow> rows = [];

      // ── Income: fee_collections ──
      for (final doc in feeSnap.docs) {
        final d = doc.data();
        final amount = (d['amount'] as num?)?.toDouble() ?? 0;
        DateTime date;
        final pd = d['paymentDate'];
        if (pd is Timestamp) {
          date = pd.toDate();
        } else if (pd is String) {
          date = DateTime.tryParse(pd) ?? DateTime.now();
        } else {
          date = DateTime.now();
        }
        final familyName = (d['familyName'] as String?)?.trim();
        final fatherName = (d['fatherName'] as String?)?.trim();
        final receipt = (d['receiptNumber'] as String?) ?? '';
        rows.add(PLTransactionRow(
          id: doc.id,
          type: 'income',
          source: 'Fee Collection',
          title: (familyName?.isNotEmpty == true) ? familyName! : (fatherName ?? 'Family'),
          subtitle: receipt.isNotEmpty ? 'Receipt $receipt' : 'Fee payment',
          amount: amount,
          date: date,
          category: (d['paymentMethod'] as String?) ?? 'Cash',
        ));
      }

      // ── Expense: salary_records (ALL statuses count, per Umair) ──
      for (final doc in salarySnap.docs) {
        final d = doc.data();
        final net = (d['netSalary'] as num?)?.toDouble() ?? 0;
        final ledgerDeduction = (d['ledgerDeductionAmount'] as num?)?.toDouble() ?? 0;
        final recordInLedger = d['recordInLedger'] == true;
        // Payable amount actually disbursed to the employee (mirrors
        // SalaryRecord.payableNetSalary: net minus whatever was routed
        // to their running balance instead of paid out directly).
        final payable = recordInLedger ? (net - ledgerDeduction) : net;

        DateTime date;
        final gd = d['generatedDate'];
        if (gd is String) {
          date = DateTime.tryParse(gd) ?? DateTime.now();
        } else if (gd is Timestamp) {
          date = gd.toDate();
        } else {
          final y = (d['year'] as num?)?.toInt() ?? DateTime.now().year;
          final m = (d['month'] as num?)?.toInt() ?? DateTime.now().month;
          date = DateTime(y, m, 1);
        }

        rows.add(PLTransactionRow(
          id: doc.id,
          type: 'expense',
          source: 'Salary',
          title: (d['employeeName'] as String?) ?? 'Employee',
          subtitle: '${d['employeeType'] ?? ''} salary',
          amount: payable,
          date: date,
          category: (d['employeeType'] as String?) ?? 'Staff',
          status: (d['status'] as String?) ?? 'Pending',
        ));
      }

      // ── Expense: staff_transactions (advances, loans, fines, etc.) ──
      for (final doc in txnSnap.docs) {
        final d = doc.data();
        final amount = (d['amount'] as num?)?.toDouble() ?? 0;
        final txnType = (d['transactionType'] as String?) ?? 'debit';
        // Only 'debit' entries (money given out to the employee) are a
        // real business expense; 'credit' entries are salary-deduction
        // sync rows that merely offset a salary already counted above,
        // so counting them too would double-count the same rupee.
        if (txnType != 'debit') continue;

        DateTime date;
        final dt = d['date'];
        if (dt is Timestamp) {
          date = dt.toDate();
        } else if (dt is String) {
          date = DateTime.tryParse(dt) ?? DateTime.now();
        } else {
          date = DateTime.now();
        }

        final category = (d['category'] as String?) ?? 'Others';
        final custom = (d['customCategory'] as String?) ?? '';
        rows.add(PLTransactionRow(
          id: doc.id,
          type: 'expense',
          source: 'Staff Transaction',
          title: (d['employeeName'] as String?) ?? 'Employee',
          subtitle: (d['note'] as String?)?.isNotEmpty == true ? d['note'] : (category == 'Others' && custom.isNotEmpty ? custom : category),
          amount: amount,
          date: date,
          category: category == 'Others' && custom.isNotEmpty ? custom : category,
        ));
      }

      rows.sort((a, b) => b.date.compareTo(a.date));
      _allRows = rows;
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load report: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Filter setters ──
  void setPreset(PLPeriodPreset p) {
    _preset = p;
    if (p != PLPeriodPreset.custom) _customRange = null;
    _applyFilters();
    notifyListeners();
  }

  void setCustomRange(DateTimeRange range) {
    _preset = PLPeriodPreset.custom;
    _customRange = range;
    _applyFilters();
    notifyListeners();
  }

  void setSourceFilter(String source) {
    _sourceFilter = source;
    _applyFilters();
    notifyListeners();
  }

  void setTypeFilter(String type) {
    _typeFilter = type;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _preset = PLPeriodPreset.thisMonth;
    _customRange = null;
    _sourceFilter = 'All';
    _typeFilter = 'All';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  DateTimeRange _resolveRange() {
    final now = DateTime.now();
    switch (_preset) {
      case PLPeriodPreset.thisMonth:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 0, 23, 59, 59));
      case PLPeriodPreset.lastMonth:
        final lm = DateTime(now.year, now.month - 1, 1);
        return DateTimeRange(start: lm, end: DateTime(lm.year, lm.month + 1, 0, 23, 59, 59));
      case PLPeriodPreset.thisYear:
        return DateTimeRange(start: DateTime(now.year, 1, 1), end: DateTime(now.year, 12, 31, 23, 59, 59));
      case PLPeriodPreset.lastYear:
        return DateTimeRange(start: DateTime(now.year - 1, 1, 1), end: DateTime(now.year - 1, 12, 31, 23, 59, 59));
      case PLPeriodPreset.last7Days:
        return DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
      case PLPeriodPreset.last30Days:
        return DateTimeRange(start: now.subtract(const Duration(days: 29)), end: now);
      case PLPeriodPreset.allTime:
        return DateTimeRange(start: DateTime(2015, 1, 1), end: DateTime(now.year + 1, 12, 31));
      case PLPeriodPreset.custom:
        return _customRange ?? DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    }
  }

  void _applyFilters() {
    final range = _resolveRange();
    final q = _searchQuery.trim().toLowerCase();

    _filteredRows = _allRows.where((r) {
      final inRange = !r.date.isBefore(DateTime(range.start.year, range.start.month, range.start.day)) &&
          !r.date.isAfter(DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59));
      if (!inRange) return false;

      if (_sourceFilter != 'All' && r.source != _sourceFilter) return false;
      if (_typeFilter != 'All' && r.type != _typeFilter) return false;

      if (q.isNotEmpty) {
        final haystack = '${r.title} ${r.subtitle} ${r.category ?? ''} ${r.source}'.toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  // ── Derived totals (from filtered rows) ──
  double get totalIncome =>
      _filteredRows.where((r) => r.type == 'income').fold(0.0, (s, r) => s + r.amount);

  double get totalExpense =>
      _filteredRows.where((r) => r.type == 'expense').fold(0.0, (s, r) => s + r.amount);

  double get netProfit => totalIncome - totalExpense;

  double get profitMarginPct => totalIncome == 0 ? 0 : (netProfit / totalIncome) * 100;

  double get salaryExpense =>
      _filteredRows.where((r) => r.source == 'Salary').fold(0.0, (s, r) => s + r.amount);

  double get transactionExpense =>
      _filteredRows.where((r) => r.source == 'Staff Transaction').fold(0.0, (s, r) => s + r.amount);

  int get incomeCount => _filteredRows.where((r) => r.type == 'income').length;
  int get expenseCount => _filteredRows.where((r) => r.type == 'expense').length;

  // ── Monthly trend (last 6 months ending at range.end, ignoring the
  //    active date filter so the trend chart always has context) ──
  List<PLMonthPoint> monthlyTrend({int months = 6}) {
    final end = _resolveRange().end;
    final points = <PLMonthPoint>[];
    for (int i = months - 1; i >= 0; i--) {
      final m = DateTime(end.year, end.month - i, 1);
      final mEnd = DateTime(m.year, m.month + 1, 0, 23, 59, 59);
      final rowsInMonth = _allRows.where((r) => !r.date.isBefore(m) && !r.date.isAfter(mEnd));
      final income = rowsInMonth.where((r) => r.type == 'income').fold(0.0, (s, r) => s + r.amount);
      final expense = rowsInMonth.where((r) => r.type == 'expense').fold(0.0, (s, r) => s + r.amount);
      points.add(PLMonthPoint(month: m, income: income, expense: expense));
    }
    return points;
  }

  // ── Expense breakdown by source, for pie/donut chart ──
  List<PLCategoryBreakdown> expenseBreakdown() {
    final salary = salaryExpense;
    final txn = transactionExpense;
    final result = <PLCategoryBreakdown>[];
    if (salary > 0) {
      result.add(PLCategoryBreakdown(label: 'Salaries', amount: salary, color: const Color(0xFF6C5CE7)));
    }
    if (txn > 0) {
      result.add(PLCategoryBreakdown(label: 'Transactions', amount: txn, color: const Color(0xFFDC2626)));
    }
    return result;
  }

  // ── Income breakdown by payment method ──
  List<PLCategoryBreakdown> incomeBreakdown() {
    final colors = {
      'Cash': const Color(0xFFD97706),
      'Bank': const Color(0xFF3B82F6),
      'Online': const Color(0xFF9333EA),
    };
    final Map<String, double> byMethod = {};
    for (final r in _filteredRows.where((r) => r.type == 'income')) {
      final key = r.category ?? 'Cash';
      byMethod[key] = (byMethod[key] ?? 0) + r.amount;
    }
    return byMethod.entries
        .map((e) => PLCategoryBreakdown(label: e.key, amount: e.value, color: colors[e.key] ?? const Color(0xFF16A34A)))
        .toList();
  }
}