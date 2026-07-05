import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/teacher.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/teacher_provider.dart';
import 'Attendance theme.dart';
import 'mark_attendance_calendar_screen.dart';
import 'mark_attendance_quick_screen.dart';

/// View + Edit already-marked attendance.
///
/// Two lookup modes (toggle at the top):
/// • By Date  — pick a date, see every staff/teacher marked that day.
/// • By Staff — pick a staff/teacher + month, see every date marked
///              for them that month (with prev/next month navigation).
///
/// Every row's status can be changed on the spot, and a record can be
/// deleted if it was marked by mistake.
///
/// This is the default landing screen when "Attendance" is opened from
/// the dashboard. A floating action button offers quick access to the
/// Quick / Calendar marking modes without leaving this screen's context.
class ViewEditAttendanceScreen extends StatefulWidget {
  final bool showAppBar;

  const ViewEditAttendanceScreen({super.key, this.showAppBar = true});

  @override
  State<ViewEditAttendanceScreen> createState() =>
      _ViewEditAttendanceScreenState();
}

enum _LookupMode { byDate, byStaff }

class _ViewEditAttendanceScreenState extends State<ViewEditAttendanceScreen> {
  _LookupMode _mode = _LookupMode.byDate;

  // By Date state
  DateTime _selectedDate = DateTime.now();

  // By Staff state
  String? _selectedStaffId;
  late DateTime _selectedMonth; // day = 1

  bool _staffLoadFailed = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    try {
      await staffProvider.fetchTeachers();
      await staffProvider.fetchStaffOnly();
      if (mounted) setState(() => _staffLoadFailed = false);
    } catch (_) {
      if (mounted) setState(() => _staffLoadFailed = true);
    }
    await _fetchByDate();
  }

  List<StaffMember> get _combinedStaff {
    final staffProvider = Provider.of<StaffProvider>(context);
    return [...staffProvider.teachers, ...staffProvider.staffOnly];
  }

  Future<void> _fetchByDate() async {
    final attendanceProvider =
    Provider.of<AttendanceProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    await attendanceProvider.fetchByDate(dateStr);
  }

  Future<void> _fetchByStaff() async {
    if (_selectedStaffId == null) return;
    final attendanceProvider =
    Provider.of<AttendanceProvider>(context, listen: false);
    final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
    await attendanceProvider.fetchByStaffAndMonth(_selectedStaffId!, yearMonth);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
          Theme.of(ctx).colorScheme.copyWith(primary: AttendanceTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _fetchByDate();
    }
  }

  void _previousMonth() {
    setState(() => _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1));
    _fetchByStaff();
  }

  void _nextMonth() {
    setState(() => _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1));
    _fetchByStaff();
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

  Future<void> _editStatus(AttendanceRecord record) async {
    final attendanceProvider =
    Provider.of<AttendanceProvider>(context, listen: false);
    final parsedDate = record.parsedDate;

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
                  record.staffName,
                  style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AttendanceTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  parsedDate != null
                      ? DateFormat('EEEE, dd MMM yyyy').format(parsedDate)
                      : record.date,
                  style: AttendanceTheme.caption,
                ),
                const SizedBox(height: 18),
                ...AttendanceTheme.statusColors.keys.map((label) {
                  final color = AttendanceTheme.statusColor(label);
                  final isSelected = record.status == label;
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
                const Divider(height: 24, color: AttendanceTheme.border),
                TextButton.icon(
                  onPressed: () => Navigator.pop(ctx, '__delete__'),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AttendanceTheme.absent),
                  label: const Text('Ye record delete karein',
                      style:
                      TextStyle(fontSize: 12.5, color: AttendanceTheme.absent)),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null || result == record.status) return;

    if (result == '__delete__') {
      final confirmed = await _confirmDelete(record);
      if (confirmed != true) return;
      final success = await attendanceProvider.deleteRecord(record);
      if (!mounted) return;
      _showSnack(
        success
            ? 'Record delete ho gaya'
            : (attendanceProvider.error ?? 'Delete nahi ho saka'),
        isError: !success,
      );
      return;
    }

    final success = await attendanceProvider.updateStatus(record, result);
    if (!mounted) return;
    _showSnack(
      success
          ? 'Status update ho gaya'
          : (attendanceProvider.error ?? 'Update nahi ho saka'),
      isError: !success,
    );
  }

  Future<bool?> _confirmDelete(AttendanceRecord record) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Record delete karein?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text(
          '${record.staffName} ki attendance record hamesha ke liye delete ho jayegi.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AttendanceTheme.absent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _openMarkAttendance(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AttendanceTheme.surfaceMuted,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AttendanceTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: AttendanceTheme.primary,
                        unselectedLabelColor: AttendanceTheme.textMuted,
                        indicatorColor: AttendanceTheme.primary,
                        labelStyle: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                        tabs: [
                          Tab(text: 'Quick Mark'),
                          Tab(text: 'Calendar Mark'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            MarkAttendanceQuickScreen(
                              showAppBar: false,
                              onSaved: () {
                                Navigator.pop(ctx);
                                _fetchByDate();
                                if (_selectedStaffId != null) _fetchByStaff();
                              },
                            ),
                            MarkAttendanceCalendarScreen(
                              showAppBar: false,
                              onSaved: () {
                                Navigator.pop(ctx);
                                _fetchByDate();
                                if (_selectedStaffId != null) _fetchByStaff();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AttendanceTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _modeButton('By Date', _LookupMode.byDate)),
          Expanded(child: _modeButton('By Staff', _LookupMode.byStaff)),
        ],
      ),
    );
  }

  Widget _modeButton(String label, _LookupMode mode) {
    final isSelected = _mode == mode;
    return InkWell(
      onTap: () {
        setState(() => _mode = mode);
        if (mode == _LookupMode.byDate) {
          _fetchByDate();
        } else if (_selectedStaffId != null) {
          _fetchByStaff();
        }
      },
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
            BoxShadow(
                color: Colors.black.withOpacity(0.06), blurRadius: 6)
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? AttendanceTheme.primary
                : AttendanceTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _byDateControls() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: AttendanceTheme.card(radius: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AttendanceTheme.primaryLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  size: 16, color: AttendanceTheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AttendanceTheme.textPrimary),
            ),
            const Spacer(),
            const Icon(Icons.edit_calendar_rounded,
                size: 18, color: AttendanceTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _byStaffControls() {
    final allStaff = List<StaffMember>.from(_combinedStaff)
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_staffLoadFailed)
          AttendanceErrorBanner(
            message: 'Staff list load nahi ho saki.',
            onRetry: _loadInitial,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: AttendanceTheme.card(radius: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Staff/Teacher chunein',
                    style: TextStyle(fontSize: 13.5)),
                value: _selectedStaffId,
                icon: const Icon(Icons.expand_more_rounded,
                    color: AttendanceTheme.textMuted),
                items: allStaff
                    .where((s) => s.id != null)
                    .map((s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(
                    '${s.name} (${s.type == 'teacher' ? 'Teacher' : 'Staff'})',
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ))
                    .toList(),
                onChanged: (id) {
                  setState(() => _selectedStaffId = id);
                  _fetchByStaff();
                },
              ),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: AttendanceTheme.card(radius: 12),
          child: Row(
            children: [
              _monthNavButton(Icons.chevron_left_rounded, _previousMonth),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AttendanceTheme.textPrimary),
                  ),
                ),
              ),
              _monthNavButton(Icons.chevron_right_rounded, _nextMonth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _monthNavButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      color: AttendanceTheme.primary,
      splashRadius: 20,
    );
  }

  Widget _recordRow(AttendanceRecord record,
      {bool showDate = false, bool showName = false}) {
    final color = AttendanceTheme.statusColor(record.status);
    final parsedDate = record.parsedDate;

    return InkWell(
      onTap: () => _editStatus(record),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: AttendanceTheme.card(radius: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AttendanceTheme.primaryLight,
              child: Text(
                record.staffName.isNotEmpty
                    ? record.staffName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AttendanceTheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showName)
                    Text(record.staffName,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AttendanceTheme.textPrimary)),
                  if (showDate)
                    Text(
                      parsedDate != null
                          ? DateFormat('EEE, dd MMM').format(parsedDate)
                          : record.date,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AttendanceTheme.textPrimary),
                    ),
                  Text(
                    record.staffType == 'teacher' ? 'Teacher' : 'Staff',
                    style: AttendanceTheme.caption,
                  ),
                ],
              ),
            ),
            StatusPill(status: record.status),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AttendanceTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(BuildContext context, AttendanceProvider provider) {
    final records = _mode == _LookupMode.byDate
        ? provider.byDateRecords
        : provider.byStaffRecords;

    if (provider.error != null) {
      return AttendanceErrorBanner(
        message: provider.error!,
        onRetry: _mode == _LookupMode.byDate ? _fetchByDate : _fetchByStaff,
      );
    }

    if (provider.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AttendanceTheme.primary),
        ),
      );
    }

    if (_mode == _LookupMode.byStaff && _selectedStaffId == null) {
      return const AttendanceEmptyState(
        icon: Icons.person_search_rounded,
        title: 'Staff/teacher select karein',
        subtitle: 'Unki mahine ki attendance dekhne ke liye upar se chunein',
      );
    }

    if (records.isEmpty) {
      return AttendanceEmptyState(
        icon: Icons.event_busy_rounded,
        title: 'Koi attendance record nahi mila',
        subtitle: _mode == _LookupMode.byDate
            ? 'Is date ke liye abhi tak koi attendance mark nahi hui'
            : 'Is mahine ke liye is staff ki koi attendance mark nahi hui',
      );
    }

    return Column(
      children: records
          .map((r) => _recordRow(
        r,
        showName: _mode == _LookupMode.byDate,
        showDate: _mode == _LookupMode.byStaff,
      ))
          .toList(),
    );
  }

  Widget _summaryBar(AttendanceProvider provider) {
    final records = _mode == _LookupMode.byDate
        ? provider.byDateRecords
        : provider.byStaffRecords;
    if (records.isEmpty) return const SizedBox.shrink();

    final counts = <String, int>{};
    for (final r in records) {
      counts[r.status] = (counts[r.status] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: counts.entries
            .map((e) => Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color:
            AttendanceTheme.statusColor(e.key).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${e.key}: ${e.value}',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AttendanceTheme.statusColor(e.key),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildBody() {
    final isWide = AttendanceTheme.isWide(context);

    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, _) {
        final controlsAndList = SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _modeToggle(),
              const SizedBox(height: 14),
              if (_mode == _LookupMode.byDate)
                _byDateControls()
              else
                _byStaffControls(),
              const SizedBox(height: 16),
              _summaryBar(attendanceProvider),
              _buildListSection(context, attendanceProvider),
            ],
          ),
        );

        return Stack(
          children: [
            RefreshIndicator(
              color: AttendanceTheme.primary,
              onRefresh: _mode == _LookupMode.byDate
                  ? _fetchByDate
                  : () async => _fetchByStaff(),
              child: controlsAndList,
            ),
            if (!widget.showAppBar || !isWide)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: () => _openMarkAttendance(context),
                  backgroundColor: AttendanceTheme.primary,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Mark Attendance',
                      style: TextStyle(fontWeight: FontWeight.w700)),
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
        title: const Text('Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: AttendanceTheme.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => _openMarkAttendance(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Mark Attendance'),
              style: TextButton.styleFrom(
                foregroundColor: AttendanceTheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}