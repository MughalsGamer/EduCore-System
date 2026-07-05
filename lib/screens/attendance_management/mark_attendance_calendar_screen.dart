import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/teacher.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/teacher_provider.dart';
import 'Attendance theme.dart';
import 'staff_multi_select.dart';

/// Mode 2 — Multi-Date / Calendar Attendance.
///
/// Flow:
/// 1. Select one or more staff/teachers.
/// 2. A real calendar grid for the current month/year is shown
///    (previous/next month navigation available).
/// 3. Tap any date -> pick one of 4 statuses (Absent, Present, Leave,
///    Half Day). That status is applied to every selected staff member
///    for that date (bulk mark for the day).
/// 4. Save writes one attendance record per staff per marked date.
class MarkAttendanceCalendarScreen extends StatefulWidget {
  final bool showAppBar;
  final VoidCallback? onSaved;

  const MarkAttendanceCalendarScreen({
    super.key,
    this.showAppBar = true,
    this.onSaved,
  });

  @override
  State<MarkAttendanceCalendarScreen> createState() =>
      _MarkAttendanceCalendarScreenState();
}

class _MarkAttendanceCalendarScreenState
    extends State<MarkAttendanceCalendarScreen> {
  Set<String> _selectedIds = {};
  bool _staffLoadFailed = false;

  late DateTime _visibleMonth; // always day = 1

  // yyyy-MM-dd -> status. Applies to ALL selected staff for that date.
  final Map<String, String> _dateStatusMap = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStaff());
  }

  Future<void> _loadStaff() async {
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    try {
      await staffProvider.fetchTeachers();
      await staffProvider.fetchStaffOnly();
      if (mounted) setState(() => _staffLoadFailed = false);
    } catch (_) {
      if (mounted) setState(() => _staffLoadFailed = true);
    }
  }

  List<StaffMember> get _combinedStaff {
    final staffProvider = Provider.of<StaffProvider>(context);
    return [...staffProvider.teachers, ...staffProvider.staffOnly];
  }

  StaffMember _resolveStaff(List<StaffMember> allStaff, String id) {
    return allStaff.firstWhere(
          (s) => s.id == id,
      orElse: () => StaffMember(
        type: 'staff',
        name: 'Unknown',
        fatherOrHusbandName: '',
        cnic: '',
        dob: '',
        gender: '',
        maritalStatus: '',
        religion: '',
        nationality: '',
        address: '',
        phone: '',
        emergencyPhone: '',
        employmentType: '',
        salary: 0,
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() => _visibleMonth = DateTime(now.year, now.month, 1));
  }

  void _onSelectionChanged(Set<String> ids) {
    setState(() => _selectedIds = ids);
  }

  List<DateTime?> _buildMonthCells() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    // Sunday-first grid: DateTime.weekday -> Mon=1 ... Sun=7
    final leadingBlanks = firstDay.weekday % 7;

    final cells = <DateTime?>[];
    cells.addAll(List.filled(leadingBlanks, null));
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_visibleMonth.year, _visibleMonth.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  void _showSnack(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? AttendanceTheme.absent : AttendanceTheme.present,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openStatusPicker(DateTime date) async {
    if (_selectedIds.isEmpty) {
      _showSnack('Pehle staff/teacher select karein');
      return;
    }

    final key = DateFormat('yyyy-MM-dd').format(date);
    final current = _dateStatusMap[key];

    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AttendanceTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(date),
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AttendanceTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedIds.length} staff/teacher ke liye status set hoga',
                  style: AttendanceTheme.caption,
                ),
                const SizedBox(height: 18),
                ...AttendanceTheme.statusColors.keys.map((label) {
                  final color = AttendanceTheme.statusColor(label);
                  final isSelected = current == label;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx, label),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color:
                          isSelected ? color : color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? color
                                  : color.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AttendanceTheme.statusIcon(label),
                              size: 19,
                              color: isSelected ? Colors.white : color,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_rounded,
                                  size: 18, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (current != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(ctx, '__clear__'),
                      icon: const Icon(Icons.close_rounded,
                          size: 16, color: AttendanceTheme.textMuted),
                      label: const Text('Is date ka status hatayein',
                          style: TextStyle(
                              fontSize: 12, color: AttendanceTheme.textMuted)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;

    setState(() {
      if (result == '__clear__') {
        _dateStatusMap.remove(key);
      } else {
        _dateStatusMap[key] = result;
      }
    });
  }

  Future<void> _save() async {
    if (_selectedIds.isEmpty) {
      _showSnack('Pehle staff/teacher select karein');
      return;
    }
    if (_dateStatusMap.isEmpty) {
      _showSnack('Kam az kam ek date mark karein');
      return;
    }

    final attendanceProvider =
    Provider.of<AttendanceProvider>(context, listen: false);
    final allStaff = _combinedStaff;

    final records = <AttendanceRecord>[];
    for (final id in _selectedIds) {
      final staff = _resolveStaff(allStaff, id);
      _dateStatusMap.forEach((date, status) {
        records.add(AttendanceRecord(
          staffId: id,
          staffName: staff.name,
          staffType: staff.type,
          date: date,
          status: status,
        ));
      });
    }

    final success = await attendanceProvider.markMultiple(records);

    if (!mounted) return;
    if (success) {
      _showSnack('${records.length} attendance record save ho gaye',
          isError: false);
      setState(() => _dateStatusMap.clear());
      widget.onSaved?.call();
    } else {
      _showSnack(
        attendanceProvider.error ?? 'Save karte waqt masla hua',
        isError: true,
      );
    }
  }

  Widget _buildMonthHeader() {
    return Row(
      children: [
        _navButton(Icons.chevron_left_rounded, _previousMonth),
        Expanded(
          child: Center(
            child: Column(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_visibleMonth),
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AttendanceTheme.textPrimary),
                ),
                TextButton(
                  onPressed: _jumpToToday,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Today par jayein',
                      style: TextStyle(
                          fontSize: 11, color: AttendanceTheme.primary)),
                ),
              ],
            ),
          ),
        ),
        _navButton(Icons.chevron_right_rounded, _nextMonth),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AttendanceTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        color: AttendanceTheme.primary,
        splashRadius: 22,
      ),
    );
  }

  Widget _buildWeekdayRow() {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: labels
          .map((l) => Expanded(
        child: Center(
          child: Text(
            l,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AttendanceTheme.textMuted),
          ),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildDayCell(DateTime? date) {
    if (date == null) return const SizedBox.shrink();

    final key = DateFormat('yyyy-MM-dd').format(date);
    final status = _dateStatusMap[key];
    final color = status != null ? AttendanceTheme.statusColor(status) : null;
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == key;
    final isWeekend = date.weekday == DateTime.sunday;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openStatusPicker(date),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            decoration: BoxDecoration(
              color: color != null
                  ? color.withOpacity(0.13)
                  : (isWeekend
                  ? AttendanceTheme.surfaceMuted
                  : Colors.white),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isToday
                    ? AttendanceTheme.primary
                    : (color ?? AttendanceTheme.border),
                width: isToday ? 1.6 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                    color: isToday
                        ? AttendanceTheme.primary
                        : AttendanceTheme.textPrimary,
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: 3),
                  StatusDot(status: status),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: AttendanceTheme.statusColors.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
              BoxDecoration(color: e.value, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(e.key, style: AttendanceTheme.caption),
          ],
        );
      }).toList(),
    );
  }

  Widget _calendarCard() {
    final cells = _buildMonthCells();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AttendanceTheme.card(radius: 14),
      child: Column(
        children: [
          _buildMonthHeader(),
          const Divider(height: 20, color: AttendanceTheme.border),
          _buildWeekdayRow(),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (ctx, i) => _buildDayCell(cells[i]),
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: _buildLegend()),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, {required bool isWide}) {
    final allStaff = _combinedStaff;

    final staffColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Staff / Teachers', style: AttendanceTheme.label),
        const SizedBox(height: 8),
        if (_staffLoadFailed)
          AttendanceErrorBanner(
            message: 'Staff list load nahi ho saki. Internet check karein.',
            onRetry: _loadStaff,
          )
        else
          StaffMultiSelect(
            allStaff: allStaff,
            selectedIds: _selectedIds,
            onSelectionChanged: _onSelectionChanged,
          ),
      ],
    );

    final calendarColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Calendar', style: AttendanceTheme.label),
        const SizedBox(height: 8),
        _calendarCard(),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.event_available_rounded,
                size: 15, color: AttendanceTheme.primary),
            const SizedBox(width: 6),
            Text(
              '${_dateStatusMap.length} date(s) mark ki gayi hain',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AttendanceTheme.textSecondary),
            ),
          ],
        ),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: staffColumn),
          const SizedBox(width: 20),
          Expanded(flex: 6, child: calendarColumn),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        staffColumn,
        const SizedBox(height: 20),
        calendarColumn,
      ],
    );
  }

  Widget _buildBody() {
    final isWide = AttendanceTheme.isWide(context);
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, _) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 24 : 16),
                child: _content(context, isWide: isWide),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AttendanceTheme.border)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: attendanceProvider.saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AttendanceTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: attendanceProvider.saving
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      'Save Attendance (${_selectedIds.length} × ${_dateStatusMap.length})',
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAppBar) {
      return _buildBody();
    }
    return Scaffold(
      backgroundColor: AttendanceTheme.surfaceMuted,
      appBar: AppBar(
        title: const Text('Calendar Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: AttendanceTheme.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }
}