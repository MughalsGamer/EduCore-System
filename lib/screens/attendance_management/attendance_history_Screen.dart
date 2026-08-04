
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================
const _kInk = Color(0xFF1F2937);
const _kSlate = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);
const _kSurface = Color(0xFFF8FAFC);
const _kCard = Colors.white;

// EduCore brand purple
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
// neutral grey tone used for the 'holiday' (Sunday) status
const _kGrey = Color(0xFF475569);
const _kGreyBg = Color(0xFFF1F5F9);

const List<Map<String, Object>> _kStatuses = [
  {'key': 'present', 'label': 'Present', 'icon': Icons.check_circle_rounded, 'color': _kGreen, 'bg': _kGreenBg},
  {'key': 'absent', 'label': 'Absent', 'icon': Icons.cancel_rounded, 'color': _kRed, 'bg': _kRedBg},
  {'key': 'late', 'label': 'Late', 'icon': Icons.schedule_rounded, 'color': _kOrange, 'bg': _kOrangeBg},
  {'key': 'leave', 'label': 'Leave', 'icon': Icons.beach_access_rounded, 'color': _kBlue, 'bg': _kBlueBg},
  {'key': 'half_day', 'label': 'Half Day', 'icon': Icons.hourglass_bottom_rounded, 'color': _kPurple, 'bg': _kPurpleBg},
  // Holiday status — used automatically for Sundays (or any day
  // with no expected attendance) so such days are never shown as 'Absent'.
  {'key': 'holiday', 'label': 'Holiday', 'icon': Icons.home_rounded, 'color': _kGrey, 'bg': _kGreyBg},
];

Map<String, Object> _statusMeta(String key) {
  return _kStatuses.firstWhere((s) => s['key'] == key,
      orElse: () => _kStatuses[0]);
}

const double _kDesktopBreakpoint = 900;
const double _kTabletBreakpoint = 620;

// ============================================================
// ROOT SCREEN — By Date history only (By Person moved to
// AttendanceReportScreen, opened from the "Reports" button on
// AttendanceScreen).
// ============================================================
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
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
      ),
      body: _ByDateTab(isAdmin: isAdmin),
    );
  }
}

// ============================================================
// SHARED WIDGETS
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

String _subtitle(String? designation, String type) {
  if (designation != null && designation.trim().isNotEmpty) return designation;
  return type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff';
}

// ============================================================
// BY DATE TAB (Checkbox + Locked edit + Dropdown Calendar)
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
  final Map<String, bool> _selectedRows = {};

  final GlobalKey _dateChipKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  DateTime? _tempSelectedDate;

  // Universal search (name / designation / type) + pagination.
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // Default page size is now 30 (per request: 1-30 on page 1, 31-60 on page 2, etc.)
  int _pageSize = 30;
  int _currentPage = 1;
  static const List<int> _pageSizeOptions = [10, 20, 30];

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    context.read<AttendanceProvider>().loadHistoryForDate(
      _dateStr,
      typeFilter: _filterType,
    );
  }

  // Filters by name, designation, or teacher/staff type — the fields
  // actually present on AttendanceRecord.
  List<AttendanceRecord> _applySearch(List<AttendanceRecord> records) {
    if (_searchQuery.trim().isEmpty) return records;
    final q = _searchQuery.trim().toLowerCase();
    return records.where((r) {
      final name = r.staffName.toLowerCase();
      final designation = (r.designation ?? '').toLowerCase();
      final type = r.type.toLowerCase();
      return name.contains(q) ||
          designation.contains(q) ||
          type.contains(q);
    }).toList();
  }

  void _toggleDatePicker() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    final renderBox = _dateChipKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                _overlayEntry!.remove();
                _overlayEntry = null;
              },
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
            Positioned(
              top: position.dy + renderBox.size.height + 6,
              left: position.dx,
              width: 320,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 360,
                        child: CalendarDatePicker(
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          onDateChanged: (date) {
                            _tempSelectedDate = date;
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                _overlayEntry!.remove();
                                _overlayEntry = null;
                              },
                              child: const Text('CANCEL',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            TextButton(
                              onPressed: () {
                                final newDate = _tempSelectedDate ?? _selectedDate;
                                setState(() {
                                  _selectedDate = newDate;
                                  _selectedRows.clear();
                                  _currentPage = 1;
                                });
                                _overlayEntry!.remove();
                                _overlayEntry = null;
                                _load();
                              },
                              child: const Text('OK',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _kPrimary)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _toggleSelection(String id, bool value) {
    setState(() {
      _selectedRows[id] = value;
    });
  }

  Future<void> _updateSelected() async {
    final selectedIds = _selectedRows.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No rows selected to update.')),
      );
      return;
    }

    final provider = context.read<AttendanceProvider>();
    for (final id in selectedIds) {
      final record = provider.historyRecords.firstWhere((r) => r.id == id);
      await provider.adminUpdateHistoryRecord(record);
    }

    setState(() {
      _selectedRows.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated ${selectedIds.length} record(s).')),
      );
    }
  }

  void _toggleSelectAll(List<AttendanceRecord> pageRows) {
    final allCurrentlySelected = pageRows.isNotEmpty &&
        pageRows.every((r) => _selectedRows[r.id] == true);

    setState(() {
      for (final r in pageRows) {
        _selectedRows[r.id] = !allCurrentlySelected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    // Apply search first, then paginate (max _pageSize per page).
    final filtered = _applySearch(provider.historyRecords);
    final totalEntries = filtered.length;
    final totalPages = totalEntries == 0 ? 1 : (totalEntries / _pageSize).ceil();
    final safePage = _currentPage > totalPages ? totalPages : _currentPage;
    final startIndex = (safePage - 1) * _pageSize;
    final endIndex =
    (startIndex + _pageSize > totalEntries) ? totalEntries : startIndex + _pageSize;
    final pageRows = totalEntries == 0
        ? <AttendanceRecord>[]
        : filtered.sublist(startIndex, endIndex);

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isDesktop = width >= _kDesktopBreakpoint;
      final isTablet = width >= _kTabletBreakpoint && width < _kDesktopBreakpoint;
      final isMobile = width < _kTabletBreakpoint;
      final horizontalPad = isDesktop ? 28.0 : (isTablet ? 20.0 : 12.0);

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPad, 14, horizontalPad, 0),
            child: _buildToolbar(isDesktop),
          ),
          if (!widget.isAdmin) const _ViewOnlyBanner(),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPad, 0, horizontalPad, 0),
            child: _buildSearchAndPageSizeRow(isDesktop),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: provider.historyLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: _kPrimary, strokeWidth: 2.5))
                : provider.historyError != null
                ? _ErrorState(
                message: provider.historyError!, onRetry: _load)
                : totalEntries == 0
                ? const _EmptyState(
                message: 'No teachers/staff found for this filter.')
                : (isMobile
                ? _buildMobileList(pageRows)
                : _CompactAttendanceTable(
              isAdmin: widget.isAdmin,
              selectedRows: _selectedRows,
              onToggleSelection: _toggleSelection,
              rows: pageRows,
              horizontalPad: horizontalPad,
              allSelected: pageRows.isNotEmpty &&
                  pageRows.every((r) => _selectedRows[r.id] == true),
              onToggleSelectAll: () => _toggleSelectAll(pageRows),
              onStatusChanged: (record, status) {
                context
                    .read<AttendanceProvider>()
                    .adminUpdateHistoryRecord(record, newStatus: status);
              },
              onRemarksChanged: (record, remarks) {
                context
                    .read<AttendanceProvider>()
                    .adminUpdateHistoryRecord(record, newRemarks: remarks);
              },
            )),
          ),
          if (!provider.historyLoading &&
              provider.historyError == null &&
              totalEntries > 0)
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalPad, 8, horizontalPad, 14),
              child: _buildPaginationFooter(
                  isDesktop, startIndex, endIndex, totalEntries, totalPages, safePage),
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
          const Spacer(),
          _buildUpdateButton(),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateChip(),
          const SizedBox(height: 10),
          _buildTypeFilter(),
          const SizedBox(height: 10),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  // "Show [10/20/30] entries" + universal search box.
  Widget _buildSearchAndPageSizeRow(bool isDesktop) {
    final pageSizeControl = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Show',
            style: TextStyle(fontSize: 13, color: _kSlate, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _pageSize,
              isDense: true,
              items: _pageSizeOptions
                  .map((n) => DropdownMenuItem(
                  value: n,
                  child: Text('$n',
                      style: const TextStyle(fontSize: 13, color: _kInk))))
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _pageSize = val;
                  _currentPage = 1;
                });
              },
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text('entries',
            style: TextStyle(fontSize: 13, color: _kSlate, fontWeight: FontWeight.w600)),
      ],
    );

    final searchBox = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
            _currentPage = 1;
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: 'Search by name, designation, or type...',
          hintStyle: const TextStyle(fontSize: 13, color: _kSlate),
          prefixIcon: const Icon(Icons.search, size: 20, color: _kSlate),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
            icon: const Icon(Icons.close, size: 18, color: _kSlate),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _currentPage = 1;
              });
            },
          ),
        ),
        style: const TextStyle(fontSize: 13, color: _kInk),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          pageSizeControl,
          const Spacer(),
          SizedBox(width: 340, child: searchBox),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        searchBox,
        const SizedBox(height: 10),
        pageSizeControl,
      ],
    );
  }

  // "Showing X to Y of Z entries" + prev/next/page-number controls.
  Widget _buildPaginationFooter(bool isDesktop, int startIndex, int endIndex,
      int totalEntries, int totalPages, int currentPage) {
    final summary = Text(
      'Showing ${totalEntries == 0 ? 0 : startIndex + 1} to $endIndex of $totalEntries entries',
      style: const TextStyle(fontSize: 12.5, color: _kSlate),
    );

    Widget pageButton({required Widget child, VoidCallback? onTap, bool active = false}) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _kPrimary : _kCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? _kPrimary : _kBorder),
          ),
          child: child,
        ),
      );
    }

    // Show up to 5 page numbers around the current page.
    final pageNumbers = <int>[];
    if (totalPages <= 5) {
      pageNumbers.addAll(List.generate(totalPages, (i) => i + 1));
    } else {
      int start = currentPage - 2;
      int end = currentPage + 2;
      if (start < 1) {
        end += (1 - start);
        start = 1;
      }
      if (end > totalPages) {
        start -= (end - totalPages);
        end = totalPages;
      }
      if (start < 1) start = 1;
      pageNumbers.addAll(List.generate(end - start + 1, (i) => start + i));
    }

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        pageButton(
          child: const Icon(Icons.chevron_left, size: 18, color: _kSlate),
          onTap: currentPage <= 1
              ? null
              : () => setState(() => _currentPage = currentPage - 1),
        ),
        const SizedBox(width: 6),
        ...pageNumbers.expand((p) => [
          pageButton(
            active: p == currentPage,
            child: Text('$p',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p == currentPage ? Colors.white : _kInk)),
            onTap: p == currentPage ? null : () => setState(() => _currentPage = p),
          ),
          const SizedBox(width: 6),
        ]),
        pageButton(
          child: const Icon(Icons.chevron_right, size: 18, color: _kSlate),
          onTap: currentPage >= totalPages
              ? null
              : () => setState(() => _currentPage = currentPage + 1),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [summary, controls],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        summary,
        const SizedBox(height: 10),
        controls,
      ],
    );
  }

  Widget _buildDateChip() {
    return InkWell(
      key: _dateChipKey,
      borderRadius: BorderRadius.circular(8),
      onTap: _toggleDatePicker,
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

// ... inside _ByDateTabState ...

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
            DropdownMenuItem(value: 'staff', child: Text('School Staff Only', style: TextStyle(fontSize: 13, color: _kInk))),
            DropdownMenuItem(value: 'academy_staff', child: Text('Academy Staff Only', style: TextStyle(fontSize: 13, color: _kInk))),
          ],
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _filterType = val;
              _selectedRows.clear();
              _currentPage = 1;
            });
            _load();
          },
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
          style: const TextStyle(fontSize: 13, color: _kInk),
        ),
      ),
    );
  }



  Widget _buildUpdateButton() {
    return ElevatedButton.icon(
      onPressed: _updateSelected,
      icon: const Icon(Icons.save, size: 16),
      label: const Text('Update Selected', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  // ---- Mobile: own compact card layout (not a squeezed table) ----
  Widget _buildMobileList(List<AttendanceRecord> rows) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final record = rows[i];
        final isSelected = _selectedRows[record.id] ?? false;
        return _MobileByDateCard(
          record: record,
          isAdmin: widget.isAdmin,
          isSelected: isSelected,
          onToggle: (val) => _toggleSelection(record.id, val),
          onStatusChanged: (s) => context
              .read<AttendanceProvider>()
              .adminUpdateHistoryRecord(record, newStatus: s),
          onRemarksChanged: (r) => context
              .read<AttendanceProvider>()
              .adminUpdateHistoryRecord(record, newRemarks: r),
        );
      },
    );
  }
}

// ============================================================
// MOBILE CARD (By Date tab) — compact, own design
// ============================================================
class _MobileByDateCard extends StatefulWidget {
  final AttendanceRecord record;
  final bool isAdmin;
  final bool isSelected;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onRemarksChanged;

  const _MobileByDateCard({
    required this.record,
    required this.isAdmin,
    required this.isSelected,
    required this.onToggle,
    required this.onStatusChanged,
    required this.onRemarksChanged,
  });

  @override
  State<_MobileByDateCard> createState() => _MobileByDateCardState();
}

class _MobileByDateCardState extends State<_MobileByDateCard> {
  late final TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(text: widget.record.remarks);
  }

  @override
  void didUpdateWidget(covariant _MobileByDateCard oldWidget) {
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
        content: Text('Select the checkbox first to edit this record.'),
        backgroundColor: _kOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final locked = !widget.isAdmin || !widget.isSelected;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.isAdmin)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Checkbox(
                      value: widget.isSelected,
                      onChanged: (val) => widget.onToggle(val ?? false),
                      activeColor: _kPrimary,
                    ),
                  ),
                ),
              _buildAvatar(record.photoBase64, record.staffName, size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(record.staffName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _kInk)),
                    Text(_subtitle(record.designation, record.type),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: _kSlate)),
                  ],
                ),
              ),
              if (record.isSaving)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kPrimary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _StatusDropdown(
            status: record.status,
            locked: locked,
            fullWidth: true,
            onChanged: (s) {
              if (locked) {
                _notifyLocked();
                return;
              }
              widget.onStatusChanged(s);
            },
          ),
          const SizedBox(height: 8),
          _buildRemarksField(locked),
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
        const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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

// ============================================================
// COMPACT ATTENDANCE TABLE (By Date tab, tablet/desktop)
// Auto-shrinks columns to fit available width — no fixed pixel
// widths, no horizontal scrolling, minimal row height so more
// records are visible. No 3-dot menu (per request).
// ============================================================
class _CompactAttendanceTable extends StatelessWidget {
  final bool isAdmin;
  final Map<String, bool> selectedRows;
  final Function(String, bool) onToggleSelection;
  final List<AttendanceRecord> rows;
  final double horizontalPad;
  final void Function(AttendanceRecord, String) onStatusChanged;
  final void Function(AttendanceRecord, String) onRemarksChanged;
  final VoidCallback onToggleSelectAll;
  final bool allSelected;

  const _CompactAttendanceTable({
    required this.isAdmin,
    required this.selectedRows,
    required this.onToggleSelection,
    required this.rows,
    required this.horizontalPad,
    required this.onStatusChanged,
    required this.onRemarksChanged,
    required this.onToggleSelectAll,
    required this.allSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPad, 4, horizontalPad, 20),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildHeaderRow(),
            ...List.generate(rows.length, (i) {
              final record = rows[i];
              return _CompactTableRow(
                record: record,
                isAdmin: isAdmin,
                isEven: i.isEven,
                isSelected: selectedRows[record.id] ?? false,
                onToggle: onToggleSelection,
                onStatusChanged: (s) => onStatusChanged(record, s),
                onRemarksChanged: (r) => onRemarksChanged(record, r),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _kPrimaryLight,
        border: const Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          // Real Select-All checkbox
          SizedBox(
            width: 30,
            child: isAdmin
                ? Transform.scale(
              scale: 0.85,
              child: Checkbox(
                value: allSelected,
                onChanged: rows.isEmpty ? null : (_) => onToggleSelectAll(),
                activeColor: _kPrimary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
                : const SizedBox.shrink(),
          ),
          Expanded(
            flex: 3,
            child: Text('NAME',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _kPrimaryDark,
                    letterSpacing: 0.3)),
          ),
          Expanded(
            flex: 3,
            child: Text('STATUS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _kPrimaryDark,
                    letterSpacing: 0.3)),
          ),
          Expanded(
            flex: 4,
            child: Text('REMARKS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _kPrimaryDark,
                    letterSpacing: 0.3)),
          ),
          Expanded(
            flex: 2,
            child: Text('TYPE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _kPrimaryDark,
                    letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }
}


class _CompactTableRow extends StatefulWidget {
  final AttendanceRecord record;
  final bool isAdmin;
  final bool isEven;
  final bool isSelected;
  final Function(String, bool) onToggle;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onRemarksChanged;

  const _CompactTableRow({
    required this.record,
    required this.isAdmin,
    required this.isEven,
    required this.isSelected,
    required this.onToggle,
    required this.onStatusChanged,
    required this.onRemarksChanged,
  });

  @override
  State<_CompactTableRow> createState() => _CompactTableRowState();
}

class _CompactTableRowState extends State<_CompactTableRow> {
  late final TextEditingController _remarksController;

  @override
  void initState() {
    super.initState();
    _remarksController = TextEditingController(text: widget.record.remarks);
  }

  @override
  void didUpdateWidget(covariant _CompactTableRow oldWidget) {
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
        content: Text('Select the checkbox first to edit this record.'),
        backgroundColor: _kOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final locked = !widget.isAdmin || !widget.isSelected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isEven ? _kCard : _kSurface.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            child: widget.isAdmin
                ? Transform.scale(
              scale: 0.85,
              child: Checkbox(
                value: widget.isSelected,
                onChanged: (val) {
                  widget.onToggle(widget.record.id, val ?? false);
                },
                activeColor: _kPrimary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
                : const SizedBox.shrink(),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                children: [
                  Expanded(child: _NameCell(record: record)),
                  if (record.isSaving)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _kPrimary),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _StatusDropdown(
                status: record.status,
                locked: locked,
                compact: true,
                onChanged: (s) {
                  if (locked) {
                    _notifyLocked();
                    return;
                  }
                  widget.onStatusChanged(s);
                },
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildRemarksField(locked),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _subtitle(record.designation, record.type),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: _kSlate),
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
      style: TextStyle(fontSize: 11.5, color: locked ? _kSlate : _kInk),
      decoration: InputDecoration(
        hintText: 'Add remarks',
        hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        isDense: true,
        filled: true,
        fillColor: locked ? _kBorder.withOpacity(0.3) : _kSurface,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _kBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _kPrimary, width: 1.2)),
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

class _StatusDropdown extends StatelessWidget {
  final String status;
  final bool locked;
  final ValueChanged<String> onChanged;
  final bool compact;
  final bool fullWidth;

  const _StatusDropdown({
    required this.status,
    required this.locked,
    required this.onChanged,
    this.compact = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(status);
    final color = meta['color'] as Color;
    final bg = meta['bg'] as Color;
    final icon = meta['icon'] as IconData;
    final label = meta['label'] as String;

    final content = Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10, vertical: compact ? 6 : 7),
      decoration: BoxDecoration(
        color: locked ? bg.withOpacity(0.5) : bg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: locked ? color.withOpacity(0.3) : color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment:
        fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: locked ? color.withOpacity(0.6) : color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    color: locked ? color.withOpacity(0.6) : color)),
          ),
          if (!locked) ...[
            const SizedBox(width: 3),
            Icon(Icons.arrow_drop_down, size: compact ? 14 : 16, color: color.withOpacity(0.7)),
          ],
        ],
      ),
    );

    return PopupMenuButton<String>(
      enabled: !locked,
      onSelected: onChanged,
      padding: EdgeInsets.zero,
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
      child: content,
    );
  }
}

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
          radius: 12,
          backgroundColor: _kPrimaryLight,
          backgroundImage: image,
          child: image == null
              ? Text(
            record.staffName.isNotEmpty
                ? record.staffName[0].toUpperCase()
                : '?',
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _kPrimary),
          )
              : null,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            record.staffName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk),
          ),
        ),
      ],
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