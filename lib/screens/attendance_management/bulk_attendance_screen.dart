// bulk_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';


// ─── Design tokens (reuse from attendance_screen) ───
const _kInk = Color(0xFF1F2937);
const _kSlate = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);
const _kSurface = Color(0xFFF8FAFC);
const _kCard = Colors.white;
const _kPrimary = Color(0xFF1E3A8A);
const _kPrimaryLight = Color(0xFFEFF4FF);
const _kGreen = Color(0xFF166534);
const _kGreenBg = Color(0xFFEFFCF3);
const _kRed = Color(0xFFB91C1C);
const _kRedBg = Color(0xFFFEF2F2);
const _kOrange = Color(0xFFB45309);
const _kOrangeBg = Color(0xFFFFFBEB);
const _kBlue = Color(0xFF1D4ED8);
const _kBlueBg = Color(0xFFEFF6FF);
const _kPurple = Color(0xFF6D28D9);
const _kPurpleBg = Color(0xFFF5F3FF);
const _kSavedBg = Color(0xFFEFFCF3);
const _kSavedBorder = Color(0xFFBBEBC7);

const _kStatuses = [
  {'key': 'present', 'label': 'P', 'color': _kGreen},
  {'key': 'absent', 'label': 'A', 'color': _kRed},
  {'key': 'late', 'label': 'L', 'color': _kOrange},
  {'key': 'leave', 'label': 'Lv', 'color': _kBlue},
  {'key': 'half_day', 'label': 'H', 'color': _kPurple},
  {'key': 'holiday', 'label': 'H', 'color': _kSlate},
];

class BulkAttendanceScreen extends StatefulWidget {
  const BulkAttendanceScreen({super.key});

  @override
  State<BulkAttendanceScreen> createState() => _BulkAttendanceScreenState();
}

class _BulkAttendanceScreenState extends State<BulkAttendanceScreen> {
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<AttendanceProvider>().loadBulkAttendance(
      year: _year,
      month: _month,
      typeFilter: _filter,
    );
  }

  Future<void> _pickMonthYear() async {
    final result = await _showMonthYearPicker(
      context: context,
      initialYear: _year,
      initialMonth: _month,
    );
    if (result == null) return;
    setState(() {
      _year = result.year;
      _month = result.month;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        title: const Text('Bulk Attendance',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        backgroundColor: _kCard,
        surfaceTintColor: _kCard,
        foregroundColor: _kInk,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
        actions: [
          // Month/Year picker
          TextButton.icon(
            onPressed: _pickMonthYear,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text(
              DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          // Filter dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teachers')),
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _filter = val);
                    _loadData();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Save button
          ElevatedButton.icon(
            onPressed: provider.bulkLoading ? null : provider.saveBulkAttendance,
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save All',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: provider.bulkLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.bulkError != null
          ? Center(child: Text('Error: ${provider.bulkError}'))
          : provider.bulkRecords.isEmpty
          ? const Center(child: Text('No staff found for this filter.'))
          : isDesktop
          ? _buildDesktopTable(provider)
          : _buildMobileList(provider),
    );
  }

  // ─── DESKTOP: compact table ────────────────────────────────────
  Widget _buildDesktopTable(AttendanceProvider provider) {
    // Group records by staffId
    final Map<String, List<AttendanceRecord>> staffMap = {};
    for (final rec in provider.bulkRecords) {
      staffMap.putIfAbsent(rec.staffId, () => []);
      staffMap[rec.staffId]!.add(rec);
    }

    // Get sorted list of unique dates in the month
    final dates = provider.bulkRecords
        .map((r) => r.date)
        .toSet()
        .toList()
      ..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            children: [
              // ── Header row ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: const BoxDecoration(
                  color: _kPrimaryLight,
                  border: Border(bottom: BorderSide(color: _kBorder)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 120, child: Text('Staff', style: _headerStyle)),
                    ...dates.map((date) {
                      final dt = DateTime.parse(date);
                      return SizedBox(
                        width: 52,
                        child: Column(
                          children: [
                            Text('${dt.day}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _kInk)),
                            Text(DateFormat('E').format(dt).substring(0, 2),
                                style: TextStyle(
                                    fontSize: 9, color: _kSlate)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // ── Staff rows ──
              ...staffMap.entries.map((entry) {
                final staffId = entry.key;
                final records = entry.value..sort((a, b) => a.date.compareTo(b.date));
                // Build a map date->record
                final recMap = {for (var r in records) r.date: r};

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
                    color: records.any((r) => r.isSaved) ? _kSavedBg : Colors.white,
                  ),
                  child: Row(
                    children: [
                      // Staff name column
                      SizedBox(
                        width: 120,
                        child: Text(
                          records.first.staffName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Day cells
                      ...dates.map((date) {
                        final rec = recMap[date];
                        if (rec == null) return const SizedBox(width: 52);
                        final isReadOnly = rec.isSaved && rec.remarks == 'Before joining';
                        return SizedBox(
                          width: 52,
                          child: _StatusCell(
                            status: rec.status,
                            isReadOnly: isReadOnly,
                            onChanged: (newStatus) {
                              if (!isReadOnly) {
                                provider.updateBulkStatus(staffId, date, newStatus);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── MOBILE: staff list with horizontal scrollable day cells ──
  Widget _buildMobileList(AttendanceProvider provider) {
    final Map<String, List<AttendanceRecord>> staffMap = {};
    for (final rec in provider.bulkRecords) {
      staffMap.putIfAbsent(rec.staffId, () => []);
      staffMap[rec.staffId]!.add(rec);
    }

    final dates = provider.bulkRecords
        .map((r) => r.date)
        .toSet()
        .toList()
      ..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: staffMap.length,
      itemBuilder: (ctx, index) {
        final entry = staffMap.entries.elementAt(index);
        final staffId = entry.key;
        final records = entry.value..sort((a, b) => a.date.compareTo(b.date));
        final recMap = {for (var r in records) r.date: r};

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(records.first.staffName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: dates.map((date) {
                      final rec = recMap[date];
                      if (rec == null) return const SizedBox(width: 44);
                      final isReadOnly = rec.isSaved && rec.remarks == 'Before joining';
                      return SizedBox(
                        width: 44,
                        child: Column(
                          children: [
                            Text(DateFormat('d').format(DateTime.parse(date)),
                                style: const TextStyle(fontSize: 10, color: _kSlate)),
                            _StatusCell(
                              status: rec.status,
                              isReadOnly: isReadOnly,
                              compact: true,
                              onChanged: (newStatus) {
                                if (!isReadOnly) {
                                  provider.updateBulkStatus(staffId, date, newStatus);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Status cell (tap to change) ────────────────────────────────
class _StatusCell extends StatelessWidget {
  final String status;
  final bool isReadOnly;
  final bool compact;
  final ValueChanged<String> onChanged;

  const _StatusCell({
    required this.status,
    required this.onChanged,
    this.isReadOnly = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Find color for current status
    final statusMap = _kStatuses.firstWhere(
          (s) => s['key'] == status,
      orElse: () => _kStatuses[0],
    );
    final color = statusMap['color'] as Color;
    final label = statusMap['label'] as String;

    final cell = Container(
      height: compact ? 26 : 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isReadOnly ? _kBorder.withOpacity(0.4) : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isReadOnly ? Colors.grey.shade300 : color.withOpacity(0.4),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w700,
          color: isReadOnly ? _kSlate : color,
        ),
      ),
    );

    if (isReadOnly) {
      return Tooltip(
        message: 'Before joining',
        child: cell,
      );
    }

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 4),
      onSelected: onChanged,
      itemBuilder: (context) => _kStatuses.map((s) {
        final key = s['key'] as String;
        final label = s['label'] as String;
        final color = s['color'] as Color;
        return PopupMenuItem<String>(
          value: key,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        );
      }).toList(),
      child: cell,
    );
  }
}

// ─── Month/Year picker (reused from history) ────────────────────
class _MonthYearPickerResult {
  final int year;
  final int month;
  _MonthYearPickerResult(this.year, this.month);
}

Future<_MonthYearPickerResult?> _showMonthYearPicker({
  required BuildContext context,
  required int initialYear,
  required int initialMonth,
}) {
  final currentYear = DateTime.now().year;
  return showDialog<_MonthYearPickerResult>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (context) {
      return _MonthYearPickerDialog(
        initialYear: initialYear,
        initialMonth: initialMonth,
        maxYear: currentYear,
      );
    },
  );
}

class _MonthYearPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int maxYear;
  const _MonthYearPickerDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.maxYear,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _year;
  late int _month;
  bool _showYearGrid = false;
  static const int _minYear = 2015;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  void _goToPreviousYear() {
    if (_year - 1 < _minYear) return;
    setState(() => _year -= 1);
  }

  void _goToNextYear() {
    if (_year + 1 > widget.maxYear) return;
    setState(() => _year += 1);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _goToPreviousYear,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _showYearGrid = !_showYearGrid),
                    child: Text(
                      '$_year',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _goToNextYear,
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 240,
              child: _showYearGrid
                  ? _buildYearGrid()
                  : _buildMonthGrid(),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (ctx, i) {
        final month = i + 1;
        final isFuture = _year == widget.maxYear && month > DateTime.now().month;
        return GestureDetector(
          onTap: isFuture
              ? null
              : () => Navigator.pop(context, _MonthYearPickerResult(_year, month)),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: _kBorder),
              borderRadius: BorderRadius.circular(8),
              color: month == _month ? _kPrimaryLight : null,
            ),
            child: Text(
              DateFormat('MMM').format(DateTime(_year, month)),
              style: TextStyle(
                color: isFuture ? Colors.grey.shade300 : _kInk,
                fontWeight: month == _month ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearGrid() {
    final years = List.generate(
      widget.maxYear - _minYear + 1,
          (i) => _minYear + i,
    );
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: years.length,
      itemBuilder: (ctx, i) {
        final year = years[i];
        return GestureDetector(
          onTap: () => setState(() {
            _year = year;
            _showYearGrid = false;
          }),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: _kBorder),
              borderRadius: BorderRadius.circular(8),
              color: year == _year ? _kPrimaryLight : null,
            ),
            child: Text(
              '$year',
              style: TextStyle(
                fontWeight: year == _year ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Header style ────────────────────────────────────────────────
const _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: _kSlate,
  letterSpacing: 0.2,
);