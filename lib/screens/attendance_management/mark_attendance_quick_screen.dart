import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/teacher.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/teacher_provider.dart';
import 'Attendance theme.dart';
import 'staff_multi_select.dart';

/// Mode 1 — Quick / Single-Date Attendance.
///
/// Flow:
/// 1. Pick a date (defaults to today, real device date).
/// 2. Select one or more staff/teachers.
/// 3. Each selected member gets a row with 4 status options:
///    Absent, Present, Leave, Half Day.
/// 4. Save writes one attendance record per selected staff for that date.
class MarkAttendanceQuickScreen extends StatefulWidget {
  final bool showAppBar;
  final VoidCallback? onSaved;

  const MarkAttendanceQuickScreen({
    super.key,
    this.showAppBar = true,
    this.onSaved,
  });

  @override
  State<MarkAttendanceQuickScreen> createState() =>
      _MarkAttendanceQuickScreenState();
}

class _MarkAttendanceQuickScreenState
    extends State<MarkAttendanceQuickScreen> {
  DateTime _selectedDate = DateTime.now(); // default = today, real-time
  Set<String> _selectedIds = {};
  bool _staffLoadFailed = false;

  // staffId -> status ('Present' | 'Absent' | 'Leave' | 'Half Day')
  final Map<String, String> _statusMap = {};

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: AttendanceTheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _setStatus(String staffId, String status) {
    setState(() => _statusMap[staffId] = status);
  }

  void _onSelectionChanged(Set<String> ids) {
    setState(() {
      _selectedIds = ids;
      for (final id in ids) {
        _statusMap.putIfAbsent(id, () => 'Present');
      }
      _statusMap.removeWhere((key, _) => !ids.contains(key));
    });
  }

  Future<void> _save() async {
    if (_selectedIds.isEmpty) {
      _showSnack('Pehle staff/teacher select karein');
      return;
    }

    final attendanceProvider =
    Provider.of<AttendanceProvider>(context, listen: false);
    final allStaff = _combinedStaff;

    final records = _selectedIds.map((id) {
      final staff = _resolveStaff(allStaff, id);
      return AttendanceRecord(
        staffId: id,
        staffName: staff.name,
        staffType: staff.type,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        status: _statusMap[id] ?? 'Present',
      );
    }).toList();

    final success = await attendanceProvider.markMultiple(records);

    if (!mounted) return;
    if (success) {
      _showSnack('${records.length} attendance record save ho gaye',
          isError: false);
      widget.onSaved?.call();
    } else {
      _showSnack(
        attendanceProvider.error ?? 'Save karte waqt masla hua',
        isError: true,
      );
    }
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

  void _applyToAllSelected(String status) {
    if (_selectedIds.isEmpty) return;
    setState(() {
      for (final id in _selectedIds) {
        _statusMap[id] = status;
      }
    });
  }

  Widget _dateCard() {
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                  size: 17, color: AttendanceTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AttendanceTheme.textPrimary),
                  ),
                  if (isToday)
                    const Text('Aaj ki tareekh',
                        style: AttendanceTheme.caption),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_rounded,
                size: 18, color: AttendanceTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _bulkActionsRow() {
    if (_selectedIds.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Sab ke liye set karein:',
              style: AttendanceTheme.caption),
          ...AttendanceTheme.statusColors.keys.map(
                (s) => GestureDetector(
              onTap: () => _applyToAllSelected(s),
              child: StatusPill(status: s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String staffId, String label) {
    final color = AttendanceTheme.statusColor(label);
    final selected = _statusMap[staffId] == label;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          onTap: () => _setStatus(staffId, label),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? color : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? color : color.withOpacity(0.25),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedStaffRow(StaffMember staff) {
    final id = staff.id;
    if (id == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AttendanceTheme.card(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AttendanceTheme.primaryLight,
                child: Text(
                  staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AttendanceTheme.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(staff.name,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AttendanceTheme.textPrimary)),
                    Text(
                      staff.type == 'teacher' ? 'Teacher' : 'Staff',
                      style: AttendanceTheme.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: AttendanceTheme.statusColors.keys
                .map((s) => _statusChip(id, s))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, {required bool isWide}) {
    final allStaff = _combinedStaff;
    final selectedStaff = allStaff
        .where((s) => s.id != null && _selectedIds.contains(s.id))
        .toList();

    final controlsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date', style: AttendanceTheme.label),
        const SizedBox(height: 8),
        _dateCard(),
        const SizedBox(height: 20),
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
        _bulkActionsRow(),
      ],
    );

    final markingColumn = selectedStaff.isEmpty
        ? const AttendanceEmptyState(
      icon: Icons.fact_check_outlined,
      title: 'Abhi koi staff select nahi hua',
      subtitle:
      'Upar se staff ya teacher select karein, unki attendance yahan mark karne ke liye',
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mark Attendance', style: AttendanceTheme.label),
        const SizedBox(height: 10),
        ...selectedStaff.map(_selectedStaffRow),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: controlsColumn),
          const SizedBox(width: 20),
          Expanded(flex: 5, child: markingColumn),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        controlsColumn,
        const SizedBox(height: 20),
        markingColumn,
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
                      _selectedIds.isEmpty
                          ? 'Save Attendance'
                          : 'Save Attendance (${_selectedIds.length})',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
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
        title: const Text('Mark Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: AttendanceTheme.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }
}