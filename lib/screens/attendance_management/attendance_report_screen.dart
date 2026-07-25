import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/teacher.dart';
import '../../pdf_files/attendance_pdf_service.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';

// ============================================================
// DESIGN TOKENS (same as AttendanceHistoryScreen)
// ============================================================
const _kInk = Color(0xFF1F2937);
const _kSlate = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);
const _kSurface = Color(0xFFF8FAFC);
const _kCard = Colors.white;

const _kPrimary = Color(0xFF534AB7);
const _kPrimaryDark = Color(0xFF433CA0);
const _kPrimaryLight = Color(0xFFF0EFFE);

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
const _kGrey = Color(0xFF475569);
const _kGreyBg = Color(0xFFF1F5F9);

Map<String, Object> _statusMeta(String key) {
  const statuses = [
    {'key': 'present', 'label': 'Present', 'icon': Icons.check_circle_rounded, 'color': _kGreen, 'bg': _kGreenBg},
    {'key': 'absent', 'label': 'Absent', 'icon': Icons.cancel_rounded, 'color': _kRed, 'bg': _kRedBg},
    {'key': 'late', 'label': 'Late', 'icon': Icons.schedule_rounded, 'color': _kOrange, 'bg': _kOrangeBg},
    {'key': 'leave', 'label': 'Leave', 'icon': Icons.beach_access_rounded, 'color': _kBlue, 'bg': _kBlueBg},
    {'key': 'half_day', 'label': 'Half Day', 'icon': Icons.hourglass_bottom_rounded, 'color': _kPurple, 'bg': _kPurpleBg},
    {'key': 'holiday', 'label': 'Holiday', 'icon': Icons.home_rounded, 'color': _kGrey, 'bg': _kGreyBg},
  ];
  return statuses.firstWhere((s) => s['key'] == key, orElse: () => statuses[0]);
}

const double _kDesktopBreakpoint = 900;

// ============================================================
// SHARED WIDGETS (copied locally so this screen is standalone)
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
            Icon(Icons.event_busy_outlined, size: 44, color: Colors.grey.shade300),
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

String _subtitle(String? designation, String type) {
  if (designation != null && designation.trim().isNotEmpty) return designation;
  return type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff';
}

// ============================================================
// WINDOWS-STYLE MONTH/YEAR PICKER
// ============================================================
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
  late final ScrollController _yearScrollController;

  static const int _minYear = 2015;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
    final index = _year - _minYear;
    final estimatedOffset = (index ~/ 3) * 64.0;
    _yearScrollController = ScrollController(
      initialScrollOffset: estimatedOffset > 0 ? estimatedOffset : 0,
    );
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              SizedBox(
                height: 260,
                child: _showYearGrid ? _buildYearGrid() : _buildMonthGrid(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: _kSlate)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: _kSlate),
          onPressed: _showYearGrid ? null : _goToPreviousYear,
        ),
        Expanded(
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _showYearGrid = !_showYearGrid),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_year',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kInk),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showYearGrid
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: _kSlate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: _kSlate),
          onPressed:
          (_showYearGrid || _year + 1 > widget.maxYear) ? null : _goToNextYear,
        ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isFuture = _year == widget.maxYear && month > DateTime.now().month;
        final isSelected = month == _month && _year == widget.initialYear;
        final label = DateFormat('MMM').format(DateTime(0, month));

        return _PickerCell(
          label: label,
          isSelected: isSelected,
          isDisabled: isFuture,
          onTap: isFuture
              ? null
              : () {
            Navigator.of(context)
                .pop(_MonthYearPickerResult(_year, month));
          },
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
      controller: _yearScrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == _year;

        return _PickerCell(
          label: '$year',
          isSelected: isSelected,
          isDisabled: false,
          onTap: () {
            setState(() {
              _year = year;
              _showYearGrid = false;
            });
          },
        );
      },
    );
  }
}

class _PickerCell extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _PickerCell({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? _kPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? _kPrimary : _kBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDisabled
                  ? Colors.grey.shade300
                  : (isSelected ? Colors.white : _kInk),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ROOT SCREEN — Attendance Report (formerly "By Person" tab)
// Flow: Person picker -> Report view (month/year, summary, table)
// ============================================================
class AttendanceReportScreen extends StatefulWidget {
  final bool isAdmin;
  const AttendanceReportScreen({super.key, this.isAdmin = true});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  StaffMember? _selectedStaff;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _search = '';
  bool _isExporting = false;

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
      year: _selectedYear,
      month: _selectedMonth,
    );
  }

  Future<void> _openMonthYearPicker() async {
    final result = await _showMonthYearPicker(
      context: context,
      initialYear: _selectedYear,
      initialMonth: _selectedMonth,
    );
    if (result == null) return;
    setState(() {
      _selectedYear = result.year;
      _selectedMonth = result.month;
    });
    _load();
  }

  Future<void> _handleExportPdf() async {
    final staff = _selectedStaff;
    if (staff == null) return;

    final provider = context.read<AttendanceProvider>();
    await generateAndOpenAttendancePdf(
      staff: staff,
      records: provider.historyRecords,
      summary: provider.monthSummary,
      year: _selectedYear,
      month: _selectedMonth,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final allStaff = [...staffProvider.teachers, ...staffProvider.staffOnly];

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          _selectedStaff == null ? 'Attendance Report' : _selectedStaff!.name,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 17, color: _kInk),
        ),
        backgroundColor: _kCard,
        surfaceTintColor: _kCard,
        foregroundColor: _kInk,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
        leading: _selectedStaff == null
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedStaff = null),
        ),
      ),
      body: _selectedStaff == null
          ? _buildPersonPicker(allStaff)
          : _buildReportBody(),
    );
  }

  Widget _buildReportBody() {
    final provider = context.watch<AttendanceProvider>();

    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(isDesktop),
            const SizedBox(height: 14),
            _buildFilterRow(isDesktop),
            const SizedBox(height: 14),
            if (!widget.isAdmin) const _ViewOnlyBanner(),
            const SizedBox(height: 10),
            if (provider.historyLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(
                      color: _kPrimary, strokeWidth: 2.5),
                ),
              )
            else if (provider.historyError != null)
              _ErrorState(message: provider.historyError!, onRetry: _load)
            else if (provider.historyRecords.isEmpty)
                const _EmptyState(
                    message: 'No attendance records for this month yet.')
              else ...[
                  _buildSummaryCards(provider, isDesktop),
                  const SizedBox(height: 14),
                  _buildReportTable(provider, isDesktop),
                  const SizedBox(height: 10),
                  Text(
                    'Showing 1 to ${provider.historyRecords.length} of ${provider.historyRecords.length} entries',
                    style: const TextStyle(fontSize: 12, color: _kSlate),
                  ),
                ],
          ],
        ),
      );
    });
  }

  // ---- Person picker ----
  Widget _buildPersonPicker(List<StaffMember> allStaff) {
    final filtered = _search.isEmpty
        ? allStaff
        : allStaff
        .where((s) => s.name.toLowerCase().contains(_search.toLowerCase()))
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
            itemBuilder: (ctx, index) => _buildStaffTile(filtered[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffTile(StaffMember staff) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _selectedStaff = staff;
          _selectedYear = DateTime.now().year;
          _selectedMonth = DateTime.now().month;
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
                  Text(_subtitle(staff.designation, staff.type),
                      style: const TextStyle(fontSize: 12, color: _kSlate)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _kSlate),
          ],
        ),
      ),
    );
  }

  // ---- Enhanced Report Header ----
  Widget _buildProfileHeader(bool isDesktop) {
    final staff = _selectedStaff!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, _kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: _buildAvatar(staff.imageBase64, staff.name, size: 96),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(staff.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        if (staff.designation != null &&
                            staff.designation!.trim().isNotEmpty)
                          _headerChip(staff.designation!),
                        _headerChip(
                            staff.type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff'),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _selectedStaff = null),
                icon: const Icon(Icons.swap_horiz, size: 16, color: Colors.white),
                label: const Text('Change',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }

  // ---- Combined Month+Year Filter + Export button ----
  Widget _buildFilterRow(bool isDesktop) {
    final monthYearChip = InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _openMonthYearPicker,
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
            const Icon(Icons.calendar_month_outlined, size: 16, color: _kSlate),
            const SizedBox(width: 10),
            Text(
              DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
          ],
        ),
      ),
    );

    final exportButton = ElevatedButton.icon(
      onPressed: _isExporting
          ? null
          : () async {
        setState(() => _isExporting = true);
        try {
          await _handleExportPdf();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Export failed: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _isExporting = false);
        }
      },
      icon: _isExporting
          ? const SizedBox(
        width: 16, height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : const Icon(Icons.file_download_outlined, size: 16),
      label: Text(
        _isExporting ? 'Exporting…' : 'Export PDF',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: isDesktop
          ? Row(
        children: [
          monthYearChip,
          const Spacer(),
          exportButton,
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          monthYearChip,
          const SizedBox(height: 10),
          exportButton,
        ],
      ),
    );
  }

  // ---- Summary Cards (compact) ----
  Widget _buildSummaryCards(AttendanceProvider provider, bool isDesktop) {
    final summary = provider.monthSummary;
    final total = summary['total'] ?? 0;
    final present = summary['present'] ?? 0;
    final absent = summary['absent'] ?? 0;
    final leave = summary['leave'] ?? 0;
    final late = summary['late'] ?? 0;
    final halfDay = summary['half_day'] ?? 0;
    final holiday = summary['holiday'] ?? 0;
    final workingDays = total - holiday;
    final pct = workingDays <= 0 ? 0.0 : (present / workingDays) * 100;

    final cards = [
      _SummaryCardData('Working Days', '$workingDays', Icons.event_note_outlined, _kPrimary, _kPrimaryLight),
      _SummaryCardData('Present', '$present', Icons.check_circle_outline, _kGreen, _kGreenBg),
      _SummaryCardData('Absent', '$absent', Icons.cancel_outlined, _kRed, _kRedBg),
      _SummaryCardData('Leave', '$leave', Icons.beach_access_outlined, _kBlue, _kBlueBg),
      _SummaryCardData('Late', '$late', Icons.schedule_outlined, _kOrange, _kOrangeBg),
      _SummaryCardData('Half Day', '$halfDay', Icons.hourglass_bottom_outlined, _kPurple, _kPurpleBg),
      _SummaryCardData('Holidays', '$holiday', Icons.home_outlined, _kGrey, _kGreyBg),
      _SummaryCardData('Attendance %', '${pct.toStringAsFixed(1)}%', Icons.insights_outlined, _kPrimary, _kPrimaryLight),
    ];

    final columns = isDesktop ? 8 : 3;

    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 8.0;
      final cardWidth =
          (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: cards
            .map((c) => SizedBox(width: cardWidth, child: _SummaryCard(data: c)))
            .toList(),
      );
    });
  }

  // ---- Report Table ----
  Widget _buildReportTable(AttendanceProvider provider, bool isDesktop) {
    final rows = [...provider.historyRecords]
      ..sort((a, b) => a.date.compareTo(b.date));

    if (!isDesktop) {
      return _buildMobileList(rows);
    }

    final half = (rows.length / 2).ceil();
    final leftRows = rows.sublist(0, half);
    final rightRows = rows.sublist(half);

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                child: _buildTableColumn(leftRows, startIndex: 1)),
            Container(width: 1, color: _kBorder),
            Expanded(
                child: _buildTableColumn(rightRows,
                    startIndex: half + 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableColumn(List<AttendanceRecord> rows, {required int startIndex}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: const BoxDecoration(
            color: _kPrimaryDark,
            border: Border(bottom: BorderSide(color: _kBorder)),
          ),
          child: Row(
            children: [
              SizedBox(
                  width: 22,
                  child: Text('#',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.85)))),
              Expanded(
                  flex: 3,
                  child: Text('DATE',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.3))),
              Expanded(
                  flex: 3,
                  child: Text('DAY',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.3))),
              Expanded(
                  flex: 3,
                  child: Text('STATUS',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.3))),
              Expanded(
                  flex: 3,
                  child: Text('REMARKS',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 0.3))),
            ],
          ),
        ),
        ...List.generate(rows.length, (i) {
          final record = rows[i];
          DateTime? parsed;
          try {
            parsed = DateTime.parse(record.date);
          } catch (_) {}
          final meta = _statusMeta(record.status);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: i.isEven ? _kCard : _kSurface.withOpacity(0.6),
              border: const Border(
                  bottom: BorderSide(color: _kBorder, width: 0.6)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: Text('${startIndex + i}',
                      style: const TextStyle(fontSize: 11.5, color: _kSlate)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    parsed != null
                        ? DateFormat('dd-MMM-yyyy').format(parsed)
                        : record.date,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _kInk),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    parsed != null ? DateFormat('EEEE').format(parsed) : '-',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: _kSlate),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _StatusBadge(meta: meta, compact: true),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    record.remarks.isEmpty ? '-' : record.remarks,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: _kInk),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ---- Mobile: stacked row-cards ----
  Widget _buildMobileList(List<AttendanceRecord> rows) {
    return Column(
      children: List.generate(rows.length, (i) {
        final record = rows[i];
        DateTime? parsed;
        try {
          parsed = DateTime.parse(record.date);
        } catch (_) {}
        final meta = _statusMeta(record.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text('${i + 1}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kPrimary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      parsed != null
                          ? DateFormat('dd MMM yyyy').format(parsed)
                          : record.date,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kInk),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      parsed != null ? DateFormat('EEEE').format(parsed) : '-',
                      style: const TextStyle(fontSize: 11.5, color: _kSlate),
                    ),
                    if (record.remarks.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.remarks,
                        style: const TextStyle(fontSize: 11.5, color: _kInk),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusBadge(meta: meta),
            ],
          ),
        );
      }),
    );
  }
}

// ============================================================
// SMALL COMPONENTS
// ============================================================
class _SummaryCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  _SummaryCardData(this.label, this.value, this.icon, this.color, this.bg);
}

class _SummaryCard extends StatelessWidget {
  final _SummaryCardData data;
  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.bg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(data.icon, size: 13, color: data.color),
          ),
          const SizedBox(height: 7),
          Text(data.value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: data.color)),
          const SizedBox(height: 1),
          Text(data.label,
              style: const TextStyle(fontSize: 10, color: _kSlate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Map<String, Object> meta;
  final bool compact;
  const _StatusBadge({required this.meta, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = meta['color'] as Color;
    final bg = meta['bg'] as Color;
    final label = meta['label'] as String;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10, vertical: compact ? 3 : 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: compact ? 10.5 : 11.5,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }
}