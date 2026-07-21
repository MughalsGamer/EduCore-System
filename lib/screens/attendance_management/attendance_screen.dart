
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../app.dart';
import '../../providers/teacher_provider.dart'; // Your existing provider
import '../../providers/attendance_provider.dart'; // Our new provider
import 'attendance_history_screen.dart'; // ★ NEW — By Date / By Person history view
import '../../main.dart' show routeObserver;
import 'bulk_attendance_screen.dart'; // ★ NEW — global RouteObserver for RouteAware

// ============================================================
// CORPORATE / PROFESSIONAL DESIGN TOKENS
// ============================================================
const _kInk = Color(0xFF1F2937); // Primary text
const _kSlate = Color(0xFF64748B); // Secondary text
const _kBorder = Color(0xFFE2E8F0); // Standard border
const _kSurface = Color(0xFFF8FAFC); // Page background
const _kCard = Colors.white;

const _kPrimary = Color(0xFF1E3A8A); // Deep corporate navy
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

// ★ Saved-record highlight (whole card/row tint when attendance already exists)
const _kSavedBg = Color(0xFFEFFCF3); // light green
const _kSavedBorder = Color(0xFFBBEBC7);

const List<Map<String, Object>> _kStatuses = [
  {
    'key': 'present',
    'label': 'Present',
    'icon': Icons.check_circle_rounded,
    'color': _kGreen,
    'bg': _kGreenBg,
  },
  {
    'key': 'absent',
    'label': 'Absent',
    'icon': Icons.cancel_rounded,
    'color': _kRed,
    'bg': _kRedBg,
  },
  {
    'key': 'late',
    'label': 'Late',
    'icon': Icons.schedule_rounded,
    'color': _kOrange,
    'bg': _kOrangeBg,
  },
  {
    'key': 'leave',
    'label': 'Leave',
    'icon': Icons.beach_access_rounded,
    'color': _kBlue,
    'bg': _kBlueBg,
  },
  {
    'key': 'half_day',
    'label': 'Half Day',
    'icon': Icons.hourglass_bottom_rounded,
    'color': _kPurple,
    'bg': _kPurpleBg,
  },
];

const double _kDesktopBreakpoint = 900;

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with RouteAware {
  // ★ Overlay key + entry for the custom dropdown-style calendar,
  // matching the design used in AttendanceHistoryScreen's By Date tab.
  final GlobalKey _dateChipKey = GlobalKey();
  OverlayEntry? _dateOverlayEntry;
  DateTime? _tempSelectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resetToTodayAndRefresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ★ NEW — subscribe to the global RouteObserver so this screen is
    // notified whenever a route pushed on top of it (e.g. History) is
    // popped and it becomes visible again.
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _dateOverlayEntry?.remove();
    _dateOverlayEntry = null;
    super.dispose();
  }

  // ★ NEW — Called by RouteObserver whenever a route above this one
  // (e.g. AttendanceHistoryScreen) is popped and this screen is visible
  // again. Resets the date to today and reloads fresh data, so the
  // user never lands back on a stale date/list.
  @override
  void didPopNext() {
    _resetToTodayAndRefresh();
  }

  // ★ NEW — Always show today's date and pull fresh data, whether this
  // is the first time the screen opens or we're returning to it.
  // changeDate() updates provider.selectedDate (and may already trigger
  // its own reload internally); loadData() is called explicitly right
  // after to guarantee a fresh fetch regardless of that implementation
  // detail, so the list is never left stale.
  void _resetToTodayAndRefresh() {
    if (!mounted) return;
    final provider = context.read<AttendanceProvider>();
    provider.changeDate(DateTime.now());
    provider.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    // staffProvider kept in scope for parity with existing app wiring.
    context.watch<StaffProvider>();

    return Scaffold(
      backgroundColor: _kSurface,
      extendBody: false,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
            return isDesktop
                ? _buildDesktopLayout(context, attendanceProvider, constraints)
                : _buildMobileLayout(context, attendanceProvider);
          },
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 20,
      title: const Text(
        'Staff Attendance',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: _kInk,
          letterSpacing: 0.1,
        ),
      ),
      backgroundColor: _kCard,
      surfaceTintColor: _kCard,
      foregroundColor: _kInk,
      elevation: 0,
      shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BulkAttendanceScreen()),
              );
            },
            icon: const Icon(Icons.calendar_month, size: 16),
            label: const Text('Bulk',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPrimary,
              side: const BorderSide(color: _kBorder),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AttendanceHistoryScreen()),
              );
            },
            icon: const Icon(Icons.history_rounded, size: 16),
            label: const Text('History',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPrimary,
              side: const BorderSide(color: _kBorder),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reports feature coming soon')),
              );
            },
            icon: const Icon(Icons.bar_chart_outlined, size: 16),
            label: const Text('Reports',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kSlate,
              side: const BorderSide(color: _kBorder),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DESKTOP LAYOUT
  // ============================================================
  Widget _buildDesktopLayout(BuildContext context,
      AttendanceProvider provider, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToolbarCard(context, provider, isDesktop: true),
          const SizedBox(height: 14),
          _buildSummaryStrip(provider),
          const SizedBox(height: 14),
          Expanded(
            child: provider.loading
                ? _buildLoadingState()
                : provider.records.isEmpty
                ? _buildEmptyState()
                : _buildDesktopTwoColumnTable(provider),
          ),
          const SizedBox(height: 14),
          _buildSaveBar(context, provider, isDesktop: true),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE LAYOUT
  // ============================================================
  Widget _buildMobileLayout(
      BuildContext context, AttendanceProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _buildToolbarCard(context, provider, isDesktop: false),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSummaryStrip(provider),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: provider.loading
              ? _buildLoadingState()
              : provider.records.isEmpty
              ? _buildEmptyState()
              : _buildMobileCompactList(provider),
        ),
        _buildSaveBar(context, provider, isDesktop: false),
      ],
    );
  }

  // ============================================================
  // TOOLBAR: date, filter, quick actions
  // ============================================================
  Widget _buildToolbarCard(
      BuildContext context, AttendanceProvider provider,
      {required bool isDesktop}) {
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
          _buildDatePicker(context, provider),
          const SizedBox(width: 12),
          _buildTypeFilter(provider),
          const Spacer(),
          _buildQuickActions(context, provider),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildDatePicker(context, provider)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTypeFilter(provider)),
            ],
          ),
          const SizedBox(height: 10),
          _buildQuickActions(context, provider, fullWidth: true),
        ],
      ),
    );
  }

  void _closeDateOverlay() {
    _dateOverlayEntry?.remove();
    _dateOverlayEntry = null;
  }

  void _toggleDateOverlay(BuildContext context, AttendanceProvider provider) {
    if (_dateOverlayEntry != null) {
      _closeDateOverlay();
      return;
    }

    final renderBox =
    _dateChipKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final position = renderBox.localToGlobal(Offset.zero);
    final initialDate =
        DateTime.tryParse(provider.selectedDate) ?? DateTime.now();
    _tempSelectedDate = initialDate;

    _dateOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _closeDateOverlay,
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
                          initialDate: initialDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          onDateChanged: (date) {
                            _tempSelectedDate = date;
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _closeDateOverlay,
                              child: const Text('CANCEL',
                                  style:
                                  TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            TextButton(
                              onPressed: () {
                                final newDate =
                                    _tempSelectedDate ?? initialDate;
                                _closeDateOverlay();
                                provider.changeDate(newDate);
                                provider.loadData();
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

    overlay.insert(_dateOverlayEntry!);
  }

  Widget _buildDatePicker(BuildContext context, AttendanceProvider provider) {
    return InkWell(
      key: _dateChipKey,
      borderRadius: BorderRadius.circular(8),
      onTap: () => _toggleDateOverlay(context, provider),
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
            Flexible(
              child: Text(
                DateFormat('EEE, dd MMM yyyy')
                    .format(DateTime.parse(provider.selectedDate)),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _kInk,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(AttendanceProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.filterType,
          isDense: true,
          isExpanded: false,
          items: const [
            DropdownMenuItem(
              value: 'all',
              child: Text('All (Teachers + Staff)',
                  style: TextStyle(fontSize: 13, color: _kInk)),
            ),
            DropdownMenuItem(
              value: 'teacher',
              child: Text('Teachers Only',
                  style: TextStyle(fontSize: 13, color: _kInk)),
            ),
            DropdownMenuItem(
              value: 'staff',
              child: Text('Staff Only',
                  style: TextStyle(fontSize: 13, color: _kInk)),
            ),
          ],
          onChanged: (val) {
            if (val != null) provider.changeFilter(val);
          },
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
          style: const TextStyle(fontSize: 13, color: _kInk),
        ),
      ),
    );
  }

  // ★ Quick actions (Mark All Present / Mark All Absent) skip records
  // that are already saved, and warn the user via a SnackBar if one or
  // more people were skipped because their attendance was already
  // marked for the selected date.
  Widget _buildQuickActions(BuildContext context, AttendanceProvider provider,
      {bool fullWidth = false}) {
    final children = [
      _buildQuickActionBtn(
          'Mark All Present', Icons.check_circle_outline, _kGreen, _kGreenBg,
              () {
            final skipped = provider.markAll('present');
            _showMarkAllResult(context, skipped);
          }),
      const SizedBox(width: 8),
      _buildQuickActionBtn(
          'Mark All Absent', Icons.cancel_outlined, _kRed, _kRedBg, () {
        final skipped = provider.markAll('absent');
        _showMarkAllResult(context, skipped);
      }),
    ];

    if (fullWidth) {
      return Row(
        children: [
          Expanded(child: children[0]),
          const SizedBox(width: 8),
          Expanded(child: children[2]),
        ],
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  void _showMarkAllResult(BuildContext context, int skippedCount) {
    if (skippedCount <= 0) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          skippedCount == 1
              ? 'Attendance already marked for 1 person on this date. Skipped.'
              : 'Attendance already marked for $skippedCount people on this date. Skipped.',
        ),
        backgroundColor: _kOrange,
      ),
    );
  }

  Widget _buildQuickActionBtn(String label, IconData icon, Color color,
      Color bgColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: color.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY STRIP (counts)
  // ============================================================
  Widget _buildSummaryStrip(AttendanceProvider provider) {
    final counts = <String, int>{
      for (final s in _kStatuses) s['key'] as String: 0,
    };
    for (final r in provider.records) {
      if (counts.containsKey(r.status)) {
        counts[r.status] = counts[r.status]! + 1;
      }
    }
    final savedCount = provider.records.where((r) => r.isSaved).length;

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryTile(
              'Total',
              provider.records.length.toString(),
              _kInk,
              _kSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryTile(
              'Saved',
              savedCount.toString(),
              _kGreen,
              _kSavedBg,
            ),
          ),
          for (final s in _kStatuses) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryTile(
                s['label'] as String,
                counts[s['key']].toString(),
                s['color'] as Color,
                s['bg'] as Color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryTile(
      String label, String value, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w500, color: _kSlate),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ★ DESKTOP: two-column compact table (matches reference design)
  // Splits the record list into two equal halves and renders them
  // side-by-side as two scrollable columns, each with a table-style
  // header (#, Staff Member, Role, Status, Note). Numbering stays
  // continuous (1..N) across both columns like the reference image.
  // ============================================================
  Widget _buildDesktopTwoColumnTable(AttendanceProvider provider) {
    final records = provider.records;
    final half = (records.length / 2).ceil();
    final leftIndices = List<int>.generate(
        half > records.length ? records.length : half, (i) => i);
    final rightIndices = List<int>.generate(
        records.length - leftIndices.length, (i) => i + leftIndices.length);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTableColumn(provider, leftIndices),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: rightIndices.isEmpty
              ? const SizedBox.shrink()
              : _buildTableColumn(provider, rightIndices),
        ),
      ],
    );
  }

  Widget _buildTableColumn(AttendanceProvider provider, List<int> indices) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeaderRow(),
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: indices.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: _kBorder),
              itemBuilder: (ctx, i) {
                final index = indices[i];
                final record = provider.records[index];
                return _buildTableDataRow(
                  context: ctx,
                  provider: provider,
                  record: record,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 26, child: Text('#', style: _kHeaderStyle)),
          SizedBox(width: 8),
          Expanded(
              flex: 4, child: Text('Staff Member', style: _kHeaderStyle)),
          Expanded(flex: 3, child: Text('Role', style: _kHeaderStyle)),
          Expanded(flex: 4, child: Text('Status', style: _kHeaderStyle)),
          Expanded(flex: 3, child: Text('Note', style: _kHeaderStyle)),
        ],
      ),
    );
  }

  // ============================================================
  // ★ SHARED: single table data row (desktop two-column table)
  // ============================================================
  Widget _buildTableDataRow({
    required BuildContext context,
    required AttendanceProvider provider,
    required dynamic record,
    required int index,
  }) {
    final bool isSaved = record.isSaved == true;
    final String? designation =
    (record.designation != null && (record.designation as String).trim().isNotEmpty)
        ? record.designation as String
        : null;
    final String roleText = designation ?? _typeLabel(record.type as String);

    void notifyAlreadySaved() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Attendance already marked for ${record.staffName} on this date.'),
          backgroundColor: _kOrange,
        ),
      );
    }

    return Container(
      color: isSaved ? _kSavedBg : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: _kSlate),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _buildAvatar(record.photoBase64 as String?,
                    record.staffName as String,
                    size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.staffName as String,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: _kInk),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              roleText,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: _kSlate),
            ),
          ),
          Expanded(
            flex: 4,
            child: _StatusDropdown(
              currentStatus: record.status as String,
              locked: isSaved,
              compact: true,
              onChanged: (val) {
                if (isSaved) {
                  notifyAlreadySaved();
                  return;
                }
                provider.updateStatus(record.staffId as String, val);
              },
              onLockedTap: notifyAlreadySaved,
            ),
          ),
          Expanded(
            flex: 3,
            child: _RemarksField(
              key: ValueKey('remark-${record.staffId}'),
              initialValue: record.remarks as String,
              hint: 'Note',
              enabled: !isSaved,
              compact: true,
              onChanged: (val) {
                provider.updateRemarks(record.staffId as String, val);
              },
              onLockedTap: notifyAlreadySaved,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimaryLight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _kPrimary.withOpacity(0.15)),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: _kPrimary),
      ),
    );
  }

  // ============================================================
  // ★ MOBILE: compact single-row list (scrollable, many-per-screen)
  // Each person is one slim row: avatar + name/role on the left,
  // a compact status dropdown + note icon on the right. This lets
  // far more people fit on screen at once vs. the old big cards.
  // ============================================================
  Widget _buildMobileCompactList(AttendanceProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: provider.records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, index) {
        final record = provider.records[index];
        return _buildMobileCompactRow(
          context: ctx,
          provider: provider,
          record: record,
          index: index,
        );
      },
    );
  }

  Widget _buildMobileCompactRow({
    required BuildContext context,
    required AttendanceProvider provider,
    required dynamic record,
    required int index,
  }) {
    final bool isSaved = record.isSaved == true;
    final String? designation =
    (record.designation != null && (record.designation as String).trim().isNotEmpty)
        ? record.designation as String
        : null;
    final String roleText = designation ?? _typeLabel(record.type as String);

    void notifyAlreadySaved() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Attendance already marked for ${record.staffName} on this date.'),
          backgroundColor: _kOrange,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isSaved ? _kSavedBg : _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSaved ? _kSavedBorder : _kBorder,
          width: isSaved ? 1.3 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: isSaved ? _kGreen.withOpacity(0.12) : _kPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isSaved ? _kGreen : _kPrimary,
              ),
            ),
          ),
          _buildAvatar(record.photoBase64 as String?, record.staffName as String,
              size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        record.staffName as String,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _kInk),
                      ),
                    ),
                    if (isSaved) ...[
                      const SizedBox(width: 5),
                      const Icon(Icons.check_circle,
                          size: 13, color: _kGreen),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  roleText,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: _kSlate),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 118,
            child: _StatusDropdown(
              currentStatus: record.status as String,
              locked: isSaved,
              compact: true,
              onChanged: (val) {
                if (isSaved) {
                  notifyAlreadySaved();
                  return;
                }
                provider.updateStatus(record.staffId as String, val);
              },
              onLockedTap: notifyAlreadySaved,
            ),
          ),
          const SizedBox(width: 6),
          _NoteIconButton(
            key: ValueKey('remark-${record.staffId}'),
            initialValue: record.remarks as String,
            enabled: !isSaved,
            onChanged: (val) {
              provider.updateRemarks(record.staffId as String, val);
            },
            onLockedTap: notifyAlreadySaved,
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    if (type.toLowerCase() == 'teacher') return 'Teacher';
    return 'Staff';
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
          color: _kPrimary,
        ),
      )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_outlined, size: 44, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'No records found',
            style:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kInk),
          ),
          const SizedBox(height: 4),
          Text(
            'No active teachers/staff found for this filter.',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE BAR
  // ============================================================
  Widget _buildSaveBar(BuildContext context, AttendanceProvider provider,
      {required bool isDesktop}) {
    final button = ElevatedButton.icon(
      onPressed: provider.loading
          ? null
          : () async {
        await provider.saveAttendance();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance saved successfully'),
              backgroundColor: _kGreen,
            ),
          );
        }
      },
      icon: const Icon(Icons.check_circle_outline, size: 17),
      label: const Text('Save Attendance',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [SizedBox(width: 210, child: button)],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: _kCard,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: SizedBox(width: double.infinity, child: button),
    );
  }
}

const TextStyle _kHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: _kSlate,
  letterSpacing: 0.2,
);

// ============================================================
// ★ STATUS DROPDOWN — compact select control matching the
// reference design. Shows current status as a colored pill with
// a dropdown chevron; opening it reveals all 5 status options.
// ★ Locked state: dims colors, disables the dropdown (no menu
// opens), and forwards taps to onLockedTap so the parent can show
// the "already marked" warning — mirrors old _StatusButton logic.
// ============================================================
class _StatusDropdown extends StatelessWidget {
  final String currentStatus;
  final bool locked;
  final bool compact;
  final ValueChanged<String> onChanged;
  final VoidCallback? onLockedTap;

  const _StatusDropdown({
    required this.currentStatus,
    required this.onChanged,
    this.locked = false,
    this.compact = false,
    this.onLockedTap,
  });

  Map<String, Object> get _current => _kStatuses.firstWhere(
        (s) => s['key'] == currentStatus,
    orElse: () => _kStatuses[0],
  );

  @override
  Widget build(BuildContext context) {
    final s = _current;
    final color = s['color'] as Color;
    final bg = s['bg'] as Color;
    final label = s['label'] as String;

    final Color effectiveColor = locked ? color.withOpacity(0.55) : color;
    final Color effectiveBg = locked ? bg.withOpacity(0.6) : bg;
    final Color effectiveBorder =
    locked ? color.withOpacity(0.25) : color.withOpacity(0.35);

    final pill = Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12, vertical: compact ? 6 : 9),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: effectiveBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11.5 : 13,
                fontWeight: FontWeight.w700,
                color: effectiveColor,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: compact ? 15 : 18,
            color: effectiveColor,
          ),
        ],
      ),
    );

    if (locked) {
      return GestureDetector(
        onTap: onLockedTap,
        behavior: HitTestBehavior.opaque,
        child: pill,
      );
    }

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: onChanged,
      itemBuilder: (ctx) => _kStatuses.map((opt) {
        final optKey = opt['key'] as String;
        final optLabel = opt['label'] as String;
        final optIcon = opt['icon'] as IconData;
        final optColor = opt['color'] as Color;
        final isSelected = optKey == currentStatus;
        return PopupMenuItem<String>(
          value: optKey,
          height: 40,
          child: Row(
            children: [
              Icon(optIcon, size: 17, color: optColor),
              const SizedBox(width: 10),
              Text(
                optLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: _kInk,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                const Icon(Icons.check, size: 15, color: _kPrimary),
              ],
            ],
          ),
        );
      }).toList(),
      child: pill,
    );
  }
}

// ============================================================
// ★ NOTE ICON BUTTON (mobile compact row) — small icon that opens
// a bottom-sheet text field to add/edit remarks, keeping the row
// slim. Filled icon + dot indicator shown when a note already
// exists. Disabled + forwards to onLockedTap when saved/locked.
// ============================================================
class _NoteIconButton extends StatefulWidget {
  final String initialValue;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback? onLockedTap;

  const _NoteIconButton({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.enabled = true,
    this.onLockedTap,
  });

  @override
  State<_NoteIconButton> createState() => _NoteIconButtonState();
}

class _NoteIconButtonState extends State<_NoteIconButton> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  Future<void> _openEditor() async {
    if (!widget.enabled) {
      widget.onLockedTap?.call();
      return;
    }
    final controller = TextEditingController(text: _value);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Remarks',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _kInk),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13, color: _kInk),
                  decoration: InputDecoration(
                    hintText: 'Add remarks (optional)',
                    hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: _kSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _kPrimary, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13.5)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null && result != _value) {
      setState(() => _value = result);
      widget.onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNote = _value.trim().isNotEmpty;
    return InkWell(
      onTap: _openEditor,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hasNote
              ? _kPrimaryLight
              : (widget.enabled ? _kSurface : _kBorder.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _kBorder),
        ),
        child: Icon(
          hasNote ? Icons.sticky_note_2_rounded : Icons.sticky_note_2_outlined,
          size: 15,
          color: hasNote
              ? _kPrimary
              : (widget.enabled ? _kSlate : _kSlate.withOpacity(0.5)),
        ),
      ),
    );
  }
}

// ============================================================
// Stateful remarks field — keeps its own controller so rebuilds
// triggered by provider.notifyListeners() (e.g. from other rows'
// status taps) don't reset cursor position or steal focus.
// ★ Supports `enabled: false` for already-saved records — field
// becomes read-only and tapping it shows the "already marked"
// message via onLockedTap. `compact` shrinks padding/font for the
// desktop table layout.
// ============================================================
class _RemarksField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hint;
  final bool enabled;
  final bool compact;
  final VoidCallback? onLockedTap;

  const _RemarksField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.hint = 'Remarks',
    this.enabled = true,
    this.compact = false,
    this.onLockedTap,
  });

  @override
  State<_RemarksField> createState() => _RemarksFieldState();
}

class _RemarksFieldState extends State<_RemarksField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: _controller,
      onChanged: widget.enabled ? widget.onChanged : null,
      readOnly: !widget.enabled,
      maxLines: 1,
      style: TextStyle(
        fontSize: widget.compact ? 12 : 12.5,
        color: widget.enabled ? _kInk : _kSlate,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
            fontSize: widget.compact ? 11.5 : 12, color: Colors.grey.shade400),
        isDense: true,
        filled: true,
        fillColor: widget.enabled ? _kSurface : _kBorder.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _kPrimary, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 8 : 10,
            vertical: widget.compact ? 6 : 8),
      ),
    );

    if (widget.enabled) return field;

    // Wrap with a tap-catcher so tapping a locked field still shows
    // the "already marked" warning instead of doing nothing silently.
    return GestureDetector(
      onTap: widget.onLockedTap,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(child: field),
    );
  }
}