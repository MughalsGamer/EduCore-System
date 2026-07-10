

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/teacher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';

// ============================================================
// DESIGN TOKENS — kept identical to attendance_screen.dart so
// both screens feel like one consistent module.
// ============================================================
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

const List<Map<String, Object>> _kStatuses = [
  {'key': 'present', 'label': 'Present', 'icon': Icons.check_circle_rounded, 'color': _kGreen, 'bg': _kGreenBg},
  {'key': 'absent', 'label': 'Absent', 'icon': Icons.cancel_rounded, 'color': _kRed, 'bg': _kRedBg},
  {'key': 'late', 'label': 'Late', 'icon': Icons.schedule_rounded, 'color': _kOrange, 'bg': _kOrangeBg},
  {'key': 'leave', 'label': 'Leave', 'icon': Icons.beach_access_rounded, 'color': _kBlue, 'bg': _kBlueBg},
  {'key': 'half_day', 'label': 'Half Day', 'icon': Icons.hourglass_bottom_rounded, 'color': _kPurple, 'bg': _kPurpleBg},
];

Map<String, Object> _statusMeta(String key) {
  return _kStatuses.firstWhere((s) => s['key'] == key,
      orElse: () => _kStatuses[0]);
}

const double _kDesktopBreakpoint = 900;

// ============================================================
// ROOT SCREEN — 2 tabs: By Date / By Person
// ============================================================
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().role == 'admin';

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Attendance History',
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 17, color: _kInk),
        ),
        backgroundColor: _kCard,
        surfaceTintColor: _kCard,
        foregroundColor: _kInk,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _kPrimary,
          unselectedLabelColor: _kSlate,
          indicatorColor: _kPrimary,
          indicatorWeight: 2.5,
          labelStyle:
          const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
          const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'By Date'),
            Tab(text: 'By Person'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ByDateTab(isAdmin: isAdmin),
          _ByPersonTab(isAdmin: isAdmin),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED: read-only banner
// ============================================================
class _ViewOnlyBanner extends StatelessWidget {
  const _ViewOnlyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kBlueBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, size: 16, color: _kBlue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'View only. Only an admin can edit attendance records.',
              style: TextStyle(fontSize: 12.5, color: _kBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ★ NEW: shown when a history query fails (e.g. missing Firestore
// composite index) instead of leaving the user staring at an
// infinite spinner with no explanation.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 44, color: _kRed),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: _kSlate),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(foregroundColor: _kPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TAB 1 — BY DATE (table view)
// Pick a date → table of everyone's attendance for that date.
// Unmarked staff default to "Absent". Admin can edit any cell.
// ============================================================
class _ByDateTab extends StatefulWidget {
  final bool isAdmin;
  const _ByDateTab({required this.isAdmin});

  @override
  State<_ByDateTab> createState() => _ByDateTabState();
}

class _ByDateTabState extends State<_ByDateTab> {
  DateTime _selectedDate = DateTime.now();
  String _filterType = 'all';

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<AttendanceProvider>().loadHistoryForDate(
      _dateStr,
      typeFilter: _filterType,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: _kPrimary, onPrimary: Colors.white, onSurface: _kInk),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 0),
            child: _buildToolbar(isDesktop),
          ),
          if (!widget.isAdmin) const _ViewOnlyBanner(),
          const SizedBox(height: 10),
          Expanded(
            child: provider.historyLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: _kPrimary, strokeWidth: 2.5))
                : provider.historyError != null
                ? _ErrorState(
                message: provider.historyError!, onRetry: _load)
                : provider.historyRecords.isEmpty
                ? const _EmptyState(
                message: 'No teachers/staff found for this filter.')
                : _AttendanceTable(
              isDesktop: isDesktop,
              isAdmin: widget.isAdmin,
              rowLabelHeader: 'Name',
              rows: provider.historyRecords,
              rowLabelBuilder: (r) => _NameCell(record: r),
              subLabelBuilder: (r) =>
                  _subtitle(r.designation, r.type),
              onStatusChanged: (record, status) {
                context
                    .read<AttendanceProvider>()
                    .adminUpdateHistoryRecord(record,
                    newStatus: status);
              },
              onRemarksChanged: (record, remarks) {
                context
                    .read<AttendanceProvider>()
                    .adminUpdateHistoryRecord(record,
                    newRemarks: remarks);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildToolbar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: isDesktop
          ? Row(
        children: [
          _buildDateChip(),
          const SizedBox(width: 12),
          _buildTypeFilter(),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateChip(),
          const SizedBox(height: 10),
          _buildTypeFilter(),
        ],
      ),
    );
  }

  Widget _buildDateChip() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: _kSlate),
            const SizedBox(width: 10),
            Text(
              DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterType,
          isDense: true,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All (Teachers + Staff)', style: TextStyle(fontSize: 13, color: _kInk))),
            DropdownMenuItem(value: 'teacher', child: Text('Teachers Only', style: TextStyle(fontSize: 13, color: _kInk))),
            DropdownMenuItem(value: 'staff', child: Text('Staff Only', style: TextStyle(fontSize: 13, color: _kInk))),
          ],
          onChanged: (val) {
            if (val == null) return;
            setState(() => _filterType = val);
            _load();
          },
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
          style: const TextStyle(fontSize: 13, color: _kInk),
        ),
      ),
    );
  }
}

// ============================================================
// TAB 2 — BY PERSON (table view)
// Search + pick one staff/teacher → month switcher → table of
// that person's attendance dates for the month.
// ============================================================
class _ByPersonTab extends StatefulWidget {
  final bool isAdmin;
  const _ByPersonTab({required this.isAdmin});

  @override
  State<_ByPersonTab> createState() => _ByPersonTabState();
}

class _ByPersonTabState extends State<_ByPersonTab> {
  StaffMember? _selectedStaff;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final staffProvider = context.read<StaffProvider>();
      if (staffProvider.teachers.isEmpty && staffProvider.staffOnly.isEmpty) {
        staffProvider.fetchTeachers();
        staffProvider.fetchStaffOnly();
      }
    });
  }

  void _load() {
    if (_selectedStaff == null) return;
    context.read<AttendanceProvider>().loadHistoryForPerson(
      staffId: _selectedStaff!.id!,
      year: _selectedMonth.year,
      month: _selectedMonth.month,
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final allStaff = [...staffProvider.teachers, ...staffProvider.staffOnly];

    if (_selectedStaff == null) {
      return _buildPersonPicker(allStaff);
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
      final provider = context.watch<AttendanceProvider>();

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 0),
            child: _buildSelectedPersonHeader(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                isDesktop ? 28 : 16, 10, isDesktop ? 28 : 16, 0),
            child: _buildMonthSwitcher(),
          ),
          if (!widget.isAdmin) const _ViewOnlyBanner(),
          const SizedBox(height: 10),
          Expanded(
            child: provider.historyLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: _kPrimary, strokeWidth: 2.5))
                : provider.historyError != null
                ? _ErrorState(
                message: provider.historyError!, onRetry: _load)
                : provider.historyRecords.isEmpty
                ? const _EmptyState(
                message: 'No attendance records for this month yet.')
                : _AttendanceTable(
              isDesktop: isDesktop,
              isAdmin: widget.isAdmin,
              rowLabelHeader: 'Date',
              rows: provider.historyRecords,
              rowLabelBuilder: (r) => _DateCell(record: r),
              subLabelBuilder: (r) =>
                  _subtitle(r.designation, r.type),
              onStatusChanged: (record, status) {
                context
                    .read<AttendanceProvider>()
                    .adminUpdateHistoryRecord(record,
                    newStatus: status);
              },
              onRemarksChanged: (record, remarks) {
                context
                    .read<AttendanceProvider>()
                    .adminUpdateHistoryRecord(record,
                    newRemarks: remarks);
              },
            ),
          ),
        ],
      );
    });
  }

  // ---- Person picker: search bar + tappable list ----
  Widget _buildPersonPicker(List<StaffMember> allStaff) {
    final filtered = _search.isEmpty
        ? allStaff
        : allStaff
        .where((s) =>
        s.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _search = val),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search teacher or staff by name',
                hintStyle: TextStyle(fontSize: 13.5, color: _kSlate),
                prefixIcon: Icon(Icons.search, size: 20, color: _kSlate),
              ),
              style: const TextStyle(fontSize: 13.5, color: _kInk),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: filtered.isEmpty
              ? const _EmptyState(message: 'No matching teacher/staff found.')
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              final staff = filtered[index];
              return _buildStaffTile(staff);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStaffTile(StaffMember staff) {
    final subtitle = _subtitle(staff.designation, staff.type);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _selectedStaff = staff;
          _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
        });
        _load();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            _buildAvatar(staff.imageBase64, staff.name, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(staff.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: _kInk)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                      const TextStyle(fontSize: 12, color: _kSlate)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _kSlate),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPersonHeader() {
    final staff = _selectedStaff!;
    final subtitle = _subtitle(staff.designation, staff.type);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          _buildAvatar(staff.imageBase64, staff.name, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(staff.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: _kInk)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: _kSlate)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _selectedStaff = null),
            icon: const Icon(Icons.swap_horiz, size: 16, color: _kPrimary),
            label: const Text('Change',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _kPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSwitcher() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left, color: _kSlate),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: _kInk),
          ),
          IconButton(
            onPressed: DateTime(_selectedMonth.year, _selectedMonth.month)
                .isBefore(DateTime(DateTime.now().year, DateTime.now().month))
                ? () => _changeMonth(1)
                : null,
            icon: const Icon(Icons.chevron_right, color: _kSlate),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? base64, String name, {double size = 32}) {
    ImageProvider? image;
    if (base64 != null && base64.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(base64));
      } catch (_) {
        image = null;
      }
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _kPrimaryLight,
      backgroundImage: image,
      child: image == null
          ? Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: _kPrimary),
      )
          : null,
    );
  }
}

String _subtitle(String? designation, String type) {
  if (designation != null && designation.trim().isNotEmpty) return designation;
  return type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff';
}

// ============================================================
// TABLE — shared by both tabs. Columns: [Name or Date] | Status |
// Remarks | Designation/Type. Dense rows so max data fits on screen.
// On narrow screens it becomes horizontally scrollable so nothing
// gets clipped/squeezed unreadably.
// ============================================================
class _AttendanceTable extends StatelessWidget {
  final bool isDesktop;
  final bool isAdmin;
  final String rowLabelHeader;
  final List<AttendanceRecord> rows;
  final Widget Function(AttendanceRecord) rowLabelBuilder;
  final String Function(AttendanceRecord) subLabelBuilder;
  final void Function(AttendanceRecord, String) onStatusChanged;
  final void Function(AttendanceRecord, String) onRemarksChanged;

  const _AttendanceTable({
    required this.isDesktop,
    required this.isAdmin,
    required this.rowLabelHeader,
    required this.rows,
    required this.rowLabelBuilder,
    required this.subLabelBuilder,
    required this.onStatusChanged,
    required this.onRemarksChanged,
  });

  static const double _nameColWidth = 220;
  static const double _statusColWidth = 190;
  static const double _remarksColWidth = 220;
  static const double _typeColWidth = 130;

  @override
  Widget build(BuildContext context) {
    final totalWidth =
        _nameColWidth + _statusColWidth + _remarksColWidth + _typeColWidth;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          isDesktop ? 28 : 16, 4, isDesktop ? 28 : 16, 20),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: totalWidth),
            child: SizedBox(
              width: isDesktop ? null : totalWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderRow(),
                  ...List.generate(rows.length, (i) {
                    final record = rows[i];
                    return _TableRow(
                      record: record,
                      isAdmin: isAdmin,
                      isEven: i.isEven,
                      nameColWidth: _nameColWidth,
                      statusColWidth: _statusColWidth,
                      remarksColWidth: _remarksColWidth,
                      typeColWidth: _typeColWidth,
                      rowLabel: rowLabelBuilder(record),
                      subLabel: subLabelBuilder(record),
                      onStatusChanged: (s) => onStatusChanged(record, s),
                      onRemarksChanged: (r) => onRemarksChanged(record, r),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    Widget cell(String text, double width, {TextAlign align = TextAlign.left}) {
      return SizedBox(
        width: width,
        child: Text(
          text,
          textAlign: align,
          style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _kSlate,
              letterSpacing: 0.3),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          cell(rowLabelHeader.toUpperCase(), _nameColWidth),
          cell('STATUS', _statusColWidth),
          cell('REMARKS', _remarksColWidth),
          cell('DESIGNATION/TYPE', _typeColWidth),
        ],
      ),
    );
  }
}

class _TableRow extends StatefulWidget {
  final AttendanceRecord record;
  final bool isAdmin;
  final bool isEven;
  final double nameColWidth;
  final double statusColWidth;
  final double remarksColWidth;
  final double typeColWidth;
  final Widget rowLabel;
  final String subLabel;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onRemarksChanged;

  const _TableRow({
    required this.record,
    required this.isAdmin,
    required this.isEven,
    required this.nameColWidth,
    required this.statusColWidth,
    required this.remarksColWidth,
    required this.typeColWidth,
    required this.rowLabel,
    required this.subLabel,
    required this.onStatusChanged,
    required this.onRemarksChanged,
  });

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  late final TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(text: widget.record.remarks);
  }

  @override
  void didUpdateWidget(covariant _TableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record.id != widget.record.id) {
      _remarksController.text = widget.record.remarks;
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _notifyLocked() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Only an admin can edit attendance records.'),
        backgroundColor: _kOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final locked = !widget.isAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isEven ? _kCard : _kSurface.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: widget.nameColWidth,
            child: Row(
              children: [
                Expanded(child: widget.rowLabel),
                if (record.isSaving)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kPrimary),
                    ),
                  )
                else if (record.isSaved)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.check_circle, size: 15, color: _kGreen),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: widget.statusColWidth,
            child: _StatusDropdown(
              status: record.status,
              locked: locked,
              onChanged: (s) {
                if (locked) {
                  _notifyLocked();
                  return;
                }
                widget.onStatusChanged(s);
              },
            ),
          ),
          SizedBox(
            width: widget.remarksColWidth,
            child: _buildRemarksField(locked),
          ),
          SizedBox(
            width: widget.typeColWidth,
            child: Text(
              widget.subLabel,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: _kSlate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksField(bool locked) {
    final field = TextField(
      controller: _remarksController,
      onChanged: locked ? null : widget.onRemarksChanged,
      readOnly: locked,
      maxLines: 1,
      style: TextStyle(fontSize: 12.5, color: locked ? _kSlate : _kInk),
      decoration: InputDecoration(
        hintText: 'Add remarks',
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        isDense: true,
        filled: true,
        fillColor: locked ? _kBorder.withOpacity(0.3) : _kSurface,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _kBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _kPrimary, width: 1.4)),
      ),
    );

    if (!locked) return field;

    return GestureDetector(
      onTap: _notifyLocked,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(child: field),
    );
  }
}

// Compact status control for the table — tapping opens a small popup
// menu instead of showing 5 full buttons per row (keeps rows dense so
// more records fit on screen, per your request).
class _StatusDropdown extends StatelessWidget {
  final String status;
  final bool locked;
  final ValueChanged<String> onChanged;

  const _StatusDropdown({
    required this.status,
    required this.locked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(status);
    final color = meta['color'] as Color;
    final bg = meta['bg'] as Color;
    final icon = meta['icon'] as IconData;
    final label = meta['label'] as String;

    return PopupMenuButton<String>(
      enabled: !locked,
      onSelected: onChanged,
      itemBuilder: (context) => _kStatuses.map((s) {
        final key = s['key'] as String;
        return PopupMenuItem<String>(
          value: key,
          child: Row(
            children: [
              Icon(s['icon'] as IconData,
                  size: 16, color: s['color'] as Color),
              const SizedBox(width: 8),
              Text(s['label'] as String,
                  style: const TextStyle(fontSize: 13, color: _kInk)),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: locked ? bg.withOpacity(0.5) : bg,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: locked ? color.withOpacity(0.3) : color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: locked ? color.withOpacity(0.6) : color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: locked ? color.withOpacity(0.6) : color)),
            if (!locked) ...[
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, size: 16, color: color.withOpacity(0.7)),
            ],
          ],
        ),
      ),
    );
  }
}

// "By Date" tab's row label — avatar + name (used inside the table row).
class _NameCell extends StatelessWidget {
  final AttendanceRecord record;
  const _NameCell({required this.record});

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (record.photoBase64 != null && record.photoBase64!.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(record.photoBase64!));
      } catch (_) {
        image = null;
      }
    }
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: _kPrimaryLight,
          backgroundImage: image,
          child: image == null
              ? Text(
            record.staffName.isNotEmpty
                ? record.staffName[0].toUpperCase()
                : '?',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kPrimary),
          )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            record.staffName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: _kInk),
          ),
        ),
      ],
    );
  }
}

// "By Person" tab's row label — date badge + weekday (used inside the
// table row).
class _DateCell extends StatelessWidget {
  final AttendanceRecord record;
  const _DateCell({required this.record});

  @override
  Widget build(BuildContext context) {
    DateTime? parsed;
    try {
      parsed = DateTime.parse(record.date);
    } catch (_) {}

    return Text(
      parsed != null
          ? DateFormat('EEE, dd MMM yyyy').format(parsed)
          : record.date,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _kInk),
    );
  }
}

// ============================================================
// Simple empty-state used by both tabs.
// ============================================================
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 44, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

