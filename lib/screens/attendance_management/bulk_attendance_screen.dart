//
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/attendance_model.dart';
// import '../../providers/attendance_provider.dart';
//
// // ─── Design tokens ───────────────────────────────────────────────
// const _kInk = Color(0xFF1F2937);
// const _kSlate = Color(0xFF64748B);
// const _kBorder = Color(0xFFE2E8F0);
// const _kSurface = Color(0xFFF1F5F9);
// const _kCard = Colors.white;
// const _kPrimary = Color(0xFF1D4ED8);
// const _kPrimaryDark = Color(0xFF0F1E3D);
//
// const _kGreen = Color(0xFF16A34A);
// const _kGreenBg = Color(0xFFDCFCE7);
// const _kRed = Color(0xFFDC2626);
// const _kRedBg = Color(0xFFFEE2E2);
// const _kOrange = Color(0xFFD97706);
// const _kOrangeBg = Color(0xFFFEF3C7);
// const _kBlue = Color(0xFF2563EB);
// const _kBlueBg = Color(0xFFDBEAFE);
// const _kPurple = Color(0xFF9333EA);
// const _kPurpleBg = Color(0xFFF3E8FF);
// const _kGray = Color(0xFF6B7280);
// const _kGrayBg = Color(0xFFE5E7EB);
// const _kBlank = Color(0xFF94A3B8);
// const _kBlankBg = Color(0xFFF8FAFC);
//
// class _StatusInfo {
//   final String key;
//   final String label;
//   final Color color;
//   final Color bg;
//   final IconData icon;
//   const _StatusInfo(this.key, this.label, this.color, this.bg, this.icon);
// }
//
// const _kStatuses = <_StatusInfo>[
//   _StatusInfo('present', 'Present', _kGreen, _kGreenBg, Icons.person_outline),
//   _StatusInfo('absent', 'Absent', _kRed, _kRedBg, Icons.person_off_outlined),
//   _StatusInfo('late', 'Late', _kOrange, _kOrangeBg, Icons.access_time),
//   _StatusInfo('leave', 'Leave', _kBlue, _kBlueBg, Icons.work_outline),
//   _StatusInfo('half_day', 'Half Day', _kPurple, _kPurpleBg, Icons.hourglass_bottom),
// ];
//
// _StatusInfo _statusInfo(String key) {
//   if (key.isEmpty || key == 'unset') {
//     return const _StatusInfo('unset', '—', _kBlank, _kBlankBg, Icons.circle_outlined);
//   }
//   return _kStatuses.firstWhere(
//         (s) => s.key == key,
//     orElse: () => const _StatusInfo('holiday', 'Holiday', _kGray, _kGrayBg, Icons.block),
//   );
// }
//
// class BulkAttendanceScreen extends StatefulWidget {
//   const BulkAttendanceScreen({super.key});
//
//   @override
//   State<BulkAttendanceScreen> createState() => _BulkAttendanceScreenState();
// }
//
// class _BulkAttendanceScreenState extends State<BulkAttendanceScreen> {
//   int _year = DateTime.now().year;
//   int _month = DateTime.now().month;
//   String? _selectedStaffId;
//   String _search = '';
//   bool _saving = false;
//
//   // True only for the very first load (no data on screen yet), so we can
//   // show the big centered spinner exactly once. Every subsequent
//   // month/year/staff change uses `_calendarLoading` instead, which only
//   // affects the calendar card — nothing else on screen moves or resets.
//   bool _initialLoading = true;
//   bool _calendarLoading = false;
//
//   // Tracks which (staffId_date) cells the user has NOT touched yet, so
//   // they render as blank ("—") instead of provider's default 'present'.
//   // Sundays are excluded from this set (they show as holiday always).
//   final Set<String> _untouched = {};
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(initial: true));
//   }
//
//   Future<void> _loadData({bool initial = false}) async {
//     final provider = context.read<AttendanceProvider>();
//
//     setState(() {
//       if (initial) {
//         _initialLoading = true;
//       } else {
//         _calendarLoading = true;
//       }
//     });
//
//     await provider.loadBulkAttendance(year: _year, month: _month, typeFilter: 'all');
//
//     // Mark every non-Sunday, not-already-saved-in-Firestore day as
//     // "untouched" so the UI shows it blank instead of provider's
//     // default 'present' status, until the user explicitly taps it.
//     _untouched.clear();
//     for (final r in provider.bulkRecords) {
//       final dt = DateTime.parse(r.date);
//       final isSunday = dt.weekday == DateTime.sunday;
//       final isBeforeJoin = r.remarks == 'Before joining';
//       if (!isSunday && !isBeforeJoin && !r.isSaved) {
//         _untouched.add('${r.staffId}_${r.date}');
//       }
//     }
//
//     if (!mounted) return;
//
//     setState(() {
//       if (_selectedStaffId == null && provider.bulkRecords.isNotEmpty) {
//         _selectedStaffId = provider.bulkRecords.first.staffId;
//       }
//       _initialLoading = false;
//       _calendarLoading = false;
//     });
//   }
//
//   String _key(String staffId, String date) => '${staffId}_$date';
//
//   Future<void> _saveAttendance() async {
//     if (_selectedStaffId == null) return;
//     setState(() => _saving = true);
//     try {
//       await context.read<AttendanceProvider>().saveBulkAttendanceForStaff(_selectedStaffId!);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Attendance saved successfully'), backgroundColor: _kGreen),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to save: $e'), backgroundColor: _kRed),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }
//
//   void _markAllForSelected(String status) {
//     final provider = context.read<AttendanceProvider>();
//     if (_selectedStaffId == null) return;
//     final records = provider.bulkRecords.where((r) => r.staffId == _selectedStaffId).toList();
//     setState(() {
//       for (final r in records) {
//         final dt = DateTime.parse(r.date);
//         final isReadOnly = r.remarks == 'Before joining' || dt.weekday == DateTime.sunday;
//         if (isReadOnly) continue; // skip holidays
//         provider.updateBulkStatus(r.staffId, r.date, status);
//         _untouched.remove(_key(r.staffId, r.date));
//       }
//     });
//   }
//
//   Future<void> _openStatusPicker(AttendanceRecord record) async {
//     final dt = DateTime.parse(record.date);
//     final isReadOnly = record.remarks == 'Before joining' || dt.weekday == DateTime.sunday;
//     if (isReadOnly) return;
//
//     final isUnset = _untouched.contains(_key(record.staffId, record.date));
//
//     final selected = await showModalBottomSheet<String>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => _StatusPickerSheet(
//         date: dt,
//         currentStatus: isUnset ? '' : record.status,
//       ),
//     );
//
//     if (selected != null) {
//       setState(() {
//         context.read<AttendanceProvider>().updateBulkStatus(record.staffId, record.date, selected);
//         _untouched.remove(_key(record.staffId, record.date));
//       });
//     }
//   }
//
//   Future<void> _pickYear() async {
//     final result = await showDialog<int>(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.3),
//       builder: (ctx) => _CompactYearPicker(currentYear: _year, maxYear: DateTime.now().year),
//     );
//     if (result != null && result != _year) {
//       setState(() => _year = result);
//       _loadData();
//     }
//   }
//
//   // NEW: quick month-jump popup, mirrors the year picker's compact feel.
//   // Lets Ali jump straight to any month within the currently picked year,
//   // with < > arrows to flip years without closing the popup.
//   Future<void> _pickMonth() async {
//     final result = await showDialog<_MonthYearPick>(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.3),
//       builder: (ctx) => _CompactMonthPicker(currentYear: _year, currentMonth: _month, maxYear: DateTime.now().year),
//     );
//     if (result != null) {
//       final now = DateTime.now();
//       final candidate = DateTime(result.year, result.month);
//       if (candidate.isAfter(DateTime(now.year, now.month))) return;
//       if (result.year == _year && result.month == _month) return;
//       setState(() {
//         _year = result.year;
//         _month = result.month;
//       });
//       _loadData();
//     }
//   }
//
//   void _prevMonth() {
//     if (_month == 1) {
//       _year -= 1;
//       _month = 12;
//     } else {
//       _month -= 1;
//     }
//     setState(() {});
//     _loadData();
//   }
//
//   void _nextMonth() {
//     final now = DateTime.now();
//     final next = _month == 12 ? DateTime(_year + 1, 1) : DateTime(_year, _month + 1);
//     if (next.isAfter(DateTime(now.year, now.month))) return;
//     if (_month == 12) {
//       _year += 1;
//       _month = 1;
//     } else {
//       _month += 1;
//     }
//     setState(() {});
//     _loadData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AttendanceProvider>();
//     final isDesktop = MediaQuery.of(context).size.width >= 900;
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       body: SafeArea(
//         child: _initialLoading
//             ? const Center(child: CircularProgressIndicator())
//             : provider.bulkError != null
//             ? Center(child: Text('Error: ${provider.bulkError}'))
//             : provider.bulkRecords.isEmpty
//             ? const Center(child: Text('No staff found.'))
//             : isDesktop
//             ? _buildDesktop(provider)
//             : _buildMobile(provider),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   // Shared data helpers
//   // ═══════════════════════════════════════════════════════════════
//   List<AttendanceRecord> _uniqueStaff(List<AttendanceRecord> records) {
//     final seen = <String>{};
//     final result = <AttendanceRecord>[];
//     for (final r in records) {
//       if (seen.add(r.staffId)) result.add(r);
//     }
//     result.sort((a, b) => a.staffName.compareTo(b.staffName));
//     return result;
//   }
//
//   List<AttendanceRecord> _selectedRecords(AttendanceProvider provider) {
//     final list = provider.bulkRecords.where((r) => r.staffId == _selectedStaffId).toList();
//     list.sort((a, b) => a.date.compareTo(b.date));
//     return list;
//   }
//
//   String _effectiveStatus(AttendanceRecord r) {
//     if (_untouched.contains(_key(r.staffId, r.date))) return '';
//     return r.status;
//   }
//
//   Map<String, int> _counts(List<AttendanceRecord> records) {
//     final counts = <String, int>{
//       'present': 0, 'absent': 0, 'late': 0, 'leave': 0, 'half_day': 0, 'holiday': 0,
//     };
//     for (final r in records) {
//       final status = _effectiveStatus(r);
//       if (counts.containsKey(status)) counts[status] = counts[status]! + 1;
//     }
//     return counts;
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   // DESKTOP LAYOUT — mirrors the reference image exactly
//   //   Row proportions tuned to match the screenshot: calendar is the
//   //   widest card, overview is narrower (not a big dominant chart),
//   //   employee panel stays a fixed compact width on the right.
//   // ═══════════════════════════════════════════════════════════════
//   Widget _buildDesktop(AttendanceProvider provider) {
//     final staffList = _uniqueStaff(provider.bulkRecords);
//     final selected = _selectedRecords(provider);
//     final counts = _counts(selected);
//
//     return Column(
//       children: [
//         _buildTopBar(),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(flex: 5, child: _buildCalendarCard(selected)),
//                 const SizedBox(width: 16),
//                 Expanded(flex: 4, child: _buildOverviewCard(counts, selected.length)),
//                 const SizedBox(width: 16),
//                 SizedBox(width: 260, child: _buildEmployeePanel(staffList)),
//               ],
//             ),
//           ),
//         ),
//         _buildBottomBar(selected, counts),
//       ],
//     );
//   }
//
//   Widget _buildTopBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       color: _kSurface,
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: _kCard,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: _kBorder),
//             ),
//             child: InkWell(
//               onTap: _pickMonth,
//               child: Row(
//                 children: [
//                   const Icon(Icons.calendar_today, size: 14, color: _kInk),
//                   const SizedBox(width: 8),
//                   Text(DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
//                       style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
//                   const SizedBox(width: 4),
//                   const Icon(Icons.keyboard_arrow_down, size: 16, color: _kSlate),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           _pillButton(label: 'All Present', icon: Icons.check_circle_outline, color: _kGreen, bg: _kGreenBg, onTap: () => _markAllForSelected('present')),
//           const SizedBox(width: 8),
//           _pillButton(label: 'All Absent', icon: Icons.cancel_outlined, color: _kRed, bg: _kRedBg, onTap: () => _markAllForSelected('absent')),
//           const Spacer(),
//           ..._legendChips(),
//         ],
//       ),
//     );
//   }
//
//   Widget _pillButton({
//     required String label,
//     required IconData icon,
//     required Color color,
//     required Color bg,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 15, color: color),
//             const SizedBox(width: 6),
//             Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _legendChips() {
//     final legend = [
//       ('P', 'Present', _kGreen, _kGreenBg),
//       ('A', 'Absent', _kRed, _kRedBg),
//       ('L', 'Late', _kOrange, _kOrangeBg),
//       ('Lv', 'Leave', _kBlue, _kBlueBg),
//       ('H', 'Half Day', _kPurple, _kPurpleBg),
//       ('H', 'Holiday', _kGray, _kGrayBg),
//     ];
//     return legend.map((item) {
//       return Padding(
//         padding: const EdgeInsets.only(left: 6),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//           decoration: BoxDecoration(color: item.$4, borderRadius: BorderRadius.circular(8)),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(item.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: item.$3)),
//               Text(item.$2, style: TextStyle(fontSize: 9, color: item.$3)),
//             ],
//           ),
//         ),
//       );
//     }).toList();
//   }
//
//   Widget _buildCalendarCard(List<AttendanceRecord> records) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//             decoration: BoxDecoration(color: _kPrimaryDark, borderRadius: BorderRadius.circular(8)),
//             child: Row(
//               children: [
//                 InkWell(onTap: _prevMonth, child: const Icon(Icons.chevron_left, color: Colors.white, size: 18)),
//                 Expanded(
//                   child: InkWell(
//                     onTap: _pickMonth,
//                     child: Center(
//                       child: Text(
//                         DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
//                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
//                       ),
//                     ),
//                   ),
//                 ),
//                 InkWell(onTap: _nextMonth, child: const Icon(Icons.chevron_right, color: Colors.white, size: 18)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
//                 .map((d) => Expanded(
//               child: Center(
//                 child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kSlate)),
//               ),
//             ))
//                 .toList(),
//           ),
//           const SizedBox(height: 6),
//           // Only this inner region swaps to a spinner while a new
//           // month/year loads — header, weekday row, legend, and the
//           // rest of the screen never move.
//           Expanded(
//             child: _calendarLoading
//                 ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
//                 : _buildCalendarGrid(records),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 10,
//             runSpacing: 4,
//             children: _kStatuses.map((s) => _dotLegend(s.label, s.color)).toList()..add(_dotLegend('Holiday', _kGray)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _dotLegend(String label, Color color) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//         const SizedBox(width: 4),
//         Text(label, style: const TextStyle(fontSize: 10, color: _kSlate)),
//       ],
//     );
//   }
//
//   Widget _buildCalendarGrid(List<AttendanceRecord> records) {
//     final recByDate = {for (var r in records) r.date: r};
//     final monthStart = DateTime(_year, _month, 1);
//     final monthEnd = DateTime(_year, _month + 1, 0);
//     final leadingEmpty = monthStart.weekday % 7;
//
//     final cells = <Widget>[];
//     for (int i = 0; i < leadingEmpty; i++) {
//       cells.add(const SizedBox());
//     }
//     for (int day = 1; day <= monthEnd.day; day++) {
//       final dt = DateTime(_year, _month, day);
//       final dateStr = '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
//       final rec = recByDate[dateStr];
//       cells.add(_buildDayCell(dt, rec));
//     }
//
//     return GridView.count(
//       crossAxisCount: 7,
//       mainAxisSpacing: 6,
//       crossAxisSpacing: 6,
//       children: cells,
//     );
//   }
//
//   Widget _buildDayCell(DateTime dt, AttendanceRecord? rec) {
//     if (rec == null) return const SizedBox();
//     final isReadOnly = rec.remarks == 'Before joining' || dt.weekday == DateTime.sunday;
//     final status = isReadOnly ? 'holiday' : _effectiveStatus(rec);
//     final info = _statusInfo(status);
//
//     return InkWell(
//       onTap: isReadOnly ? null : () => _openStatusPicker(rec),
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         decoration: BoxDecoration(
//           color: info.bg,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: status == 'unset' ? _kBorder : info.color.withOpacity(0.35)),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           '${dt.day}',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w700,
//             color: isReadOnly ? _kSlate : (status == 'unset' ? _kInk : info.color),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Overview card: fixed, modest chart size (radius-capped) so it never
//   // grows to dominate the row the way a naive Expanded PieChart would.
//   Widget _buildOverviewCard(Map<String, int> counts, int totalDays) {
//     final segments = [
//       ('present', 'Present', _kGreen),
//       ('late', 'Late', _kOrange),
//       ('leave', 'Leave', _kBlue),
//       ('half_day', 'Half Day', _kPurple),
//       ('absent', 'Absent', _kRed),
//       ('holiday', 'Holiday', _kGray),
//     ];
//     final nonZero = segments.where((s) => (counts[s.$1] ?? 0) > 0).toList();
//     final sumForChart = nonZero.fold<int>(0, (a, s) => a + (counts[s.$1] ?? 0));
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Attendance Overview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
//           const SizedBox(height: 12),
//           // Fixed-height chart zone instead of Expanded — keeps the
//           // donut visually proportionate to the calendar/employee cards
//           // regardless of available vertical space.
//           SizedBox(
//             height: 220,
//             child: sumForChart == 0
//                 ? const Center(child: Text('No attendance marked yet', style: TextStyle(color: _kSlate, fontSize: 12)))
//                 : Stack(
//               alignment: Alignment.center,
//               children: [
//                 PieChart(
//                   PieChartData(
//                     sectionsSpace: 2,
//                     centerSpaceRadius: 48,
//                     sections: nonZero.map((s) {
//                       final value = (counts[s.$1] ?? 0).toDouble();
//                       final pct = sumForChart > 0 ? (value / sumForChart * 100) : 0.0;
//                       return PieChartSectionData(
//                         value: value,
//                         color: s.$3,
//                         radius: 48,
//                         title: '${pct.toStringAsFixed(1)}%',
//                         titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('$totalDays', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _kInk)),
//                     const Text('Days', style: TextStyle(fontSize: 11, color: _kSlate)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 12,
//             runSpacing: 6,
//             children: segments.map((s) => _dotLegend(s.$2, s.$3)).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Employee panel: fixed overall height via IntrinsicHeight-free approach —
//   // wrapped so the inner ListView always has bounded height and scrolls
//   // internally, no matter how many staff members exist.
//   Widget _buildEmployeePanel(List<AttendanceRecord> staffList) {
//     final filtered = staffList.where((s) => s.staffName.toLowerCase().contains(_search.toLowerCase())).toList();
//
//     return Container(
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Select Employee', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
//                 const SizedBox(height: 8),
//                 TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Search employee...',
//                     prefixIcon: const Icon(Icons.search, size: 18),
//                     isDense: true,
//                     contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: const BorderSide(color: _kBorder),
//                     ),
//                   ),
//                   onChanged: (v) => setState(() => _search = v),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1, color: _kBorder),
//           // Explicit Expanded here is what makes this list scroll
//           // internally when staff count grows — the outer Row already
//           // gives this whole panel a bounded height via the calendar
//           // card's Expanded sibling, so ListView.builder scrolls instead
//           // of pushing the page taller.
//           Expanded(
//             child: filtered.isEmpty
//                 ? const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Text('No employees found', style: TextStyle(fontSize: 12, color: _kSlate)),
//               ),
//             )
//                 : Scrollbar(
//               thumbVisibility: true,
//               child: ListView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 itemCount: filtered.length,
//                 itemBuilder: (ctx, i) {
//                   final s = filtered[i];
//                   final isSelected = s.staffId == _selectedStaffId;
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: isSelected ? _kPrimary.withOpacity(0.07) : Colors.transparent,
//                       borderRadius: BorderRadius.circular(8),
//                       border: isSelected ? Border.all(color: _kPrimary.withOpacity(0.4)) : null,
//                     ),
//                     child: ListTile(
//                       dense: true,
//                       onTap: () => setState(() => _selectedStaffId = s.staffId),
//                       leading: _employeeAvatar(s),
//                       title: Text(s.staffName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//                       subtitle: Text(s.designation ?? s.type, style: const TextStyle(fontSize: 11, color: _kSlate)),
//                       trailing: Checkbox(
//                         value: isSelected,
//                         activeColor: _kPrimary,
//                         onChanged: (_) => setState(() => _selectedStaffId = s.staffId),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _employeeAvatar(AttendanceRecord s) {
//     final hasPhoto = s.photoBase64 != null && s.photoBase64!.isNotEmpty;
//     if (hasPhoto) {
//       final bytes = _decodeBase64(s.photoBase64!);
//       if (bytes != null) {
//         return CircleAvatar(radius: 18, backgroundImage: MemoryImage(bytes));
//       }
//     }
//     return CircleAvatar(
//       radius: 18,
//       backgroundColor: _kBorder,
//       child: Icon(Icons.person, size: 18, color: _kSlate),
//     );
//   }
//
//   Widget _buildBottomBar(List<AttendanceRecord> records, Map<String, int> counts) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: const BoxDecoration(
//         color: _kSurface,
//         border: Border(top: BorderSide(color: _kBorder)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Attendance Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
//           const SizedBox(height: 8),
//           Row(children: [Expanded(child: _summaryChipRow(counts))]),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Row(
//                 children: [
//                   const Icon(Icons.calendar_today, size: 14, color: _kSlate),
//                   const SizedBox(width: 6),
//                   Text('Total Days: ${records.length}', style: const TextStyle(fontSize: 12, color: _kSlate, fontWeight: FontWeight.w600)),
//                 ],
//               ),
//               const SizedBox(width: 16),
//               const Text('Click on date to view or mark attendance', style: TextStyle(fontSize: 11, color: _kSlate, fontStyle: FontStyle.italic)),
//               const Spacer(),
//               ElevatedButton.icon(
//                 onPressed: (_saving || _selectedStaffId == null) ? null : _saveAttendance,
//                 icon: _saving
//                     ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : const Icon(Icons.save, size: 16),
//                 label: const Text('Save Attendance', style: TextStyle(fontWeight: FontWeight.w700)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _kPrimary,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _summaryChipRow(Map<String, int> counts) {
//     final items = [
//       ('Present', counts['present']!, _kGreen),
//       ('Absent', counts['absent']!, _kRed),
//       ('Late', counts['late']!, _kOrange),
//       ('Leave', counts['leave']!, _kBlue),
//       ('Half Day', counts['half_day']!, _kPurple),
//       ('Holidays', counts['holiday']!, _kGray),
//     ];
//     return Row(
//       children: items.map((item) {
//         return Expanded(
//           child: Container(
//             margin: const EdgeInsets.only(right: 8),
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//             decoration: BoxDecoration(
//               color: _kCard,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _kBorder),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('${item.$2}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: item.$3)),
//                 const SizedBox(height: 2),
//                 Text(item.$1, style: const TextStyle(fontSize: 11, color: _kSlate)),
//                 const SizedBox(height: 4),
//                 Container(height: 3, decoration: BoxDecoration(color: item.$3, borderRadius: BorderRadius.circular(2))),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   // MOBILE LAYOUT
//   // ═══════════════════════════════════════════════════════════════
//   Widget _buildMobile(AttendanceProvider provider) {
//     final staffList = _uniqueStaff(provider.bulkRecords);
//     final selected = _selectedRecords(provider);
//     final counts = _counts(selected);
//     final filteredStaff = staffList.where((s) => s.staffName.toLowerCase().contains(_search.toLowerCase())).toList();
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ElevatedButton.icon(
//             onPressed: (_saving || _selectedStaffId == null) ? null : _saveAttendance,
//             icon: _saving
//                 ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                 : const Icon(Icons.save, size: 16),
//             label: const Text('Save Attendance'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _kPrimary,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               minimumSize: const Size(double.infinity, 44),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text('Attendance Calendar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kInk)),
//           const SizedBox(height: 12),
//           TextField(
//             decoration: InputDecoration(
//               hintText: 'Search employee...',
//               prefixIcon: const Icon(Icons.search, size: 18),
//               isDense: true,
//               filled: true,
//               fillColor: _kCard,
//               contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kBorder)),
//             ),
//             onChanged: (v) => setState(() => _search = v),
//           ),
//           const SizedBox(height: 10),
//           // Horizontal chip strip already scrolls on its own axis, so
//           // any number of employees is fine here without extra work.
//           SizedBox(
//             height: 42,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: filteredStaff.length,
//               itemBuilder: (ctx, i) {
//                 final s = filteredStaff[i];
//                 final isSelected = s.staffId == _selectedStaffId;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: ChoiceChip(
//                     avatar: _employeeAvatar(s),
//                     label: Text(s.staffName, style: const TextStyle(fontSize: 12)),
//                     selected: isSelected,
//                     selectedColor: _kPrimary.withOpacity(0.15),
//                     labelStyle: TextStyle(color: isSelected ? _kPrimary : _kInk, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
//                     onSelected: (_) => setState(() => _selectedStaffId = s.staffId),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
//                 child: InkWell(
//                   onTap: _pickMonth,
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(Icons.calendar_today, size: 14),
//                       const SizedBox(width: 8),
//                       Text(DateFormat('MMMM').format(DateTime(_year, _month)), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
//                       const Icon(Icons.keyboard_arrow_down, size: 16),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
//                   child: InkWell(
//                     onTap: _pickYear,
//                     child: Row(
//                       children: [
//                         Text('$_year', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
//                         const Spacer(),
//                         const Icon(Icons.keyboard_arrow_down, size: 16),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (_selectedStaffId != null) ...[
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     decoration: BoxDecoration(color: _kPrimaryDark, borderRadius: BorderRadius.circular(8)),
//                     child: Row(
//                       children: [
//                         InkWell(onTap: _prevMonth, child: const Icon(Icons.chevron_left, color: Colors.white)),
//                         Expanded(
//                           child: InkWell(
//                             onTap: _pickMonth,
//                             child: Center(
//                               child: Text(DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
//                                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
//                             ),
//                           ),
//                         ),
//                         InkWell(onTap: _nextMonth, child: const Icon(Icons.chevron_right, color: Colors.white)),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
//                         .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _kSlate)))))
//                         .toList(),
//                   ),
//                   const SizedBox(height: 6),
//                   SizedBox(
//                     height: 260,
//                     child: _calendarLoading
//                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
//                         : _buildCalendarGrid(selected),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 4,
//                     children: _kStatuses.map((s) => _dotLegend(s.label, s.color)).toList()..add(_dotLegend('Holiday', _kGray)),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(child: _pillButton(label: 'All Present', icon: Icons.check_circle_outline, color: _kGreen, bg: _kGreenBg, onTap: () => _markAllForSelected('present'))),
//                 const SizedBox(width: 8),
//                 Expanded(child: _pillButton(label: 'All Absent', icon: Icons.cancel_outlined, color: _kRed, bg: _kRedBg, onTap: () => _markAllForSelected('absent'))),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Attendance Overview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
//                   const SizedBox(height: 12),
//                   SizedBox(height: 200, child: _buildOverviewChartOnly(counts, selected.length)),
//                   const SizedBox(height: 10),
//                   Wrap(
//                     spacing: 12,
//                     runSpacing: 6,
//                     children: [
//                       _dotLegend('Present', _kGreen),
//                       _dotLegend('Late', _kOrange),
//                       _dotLegend('Leave', _kBlue),
//                       _dotLegend('Half Day', _kPurple),
//                       _dotLegend('Absent', _kRed),
//                       _dotLegend('Holiday', _kGray),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text('Attendance Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
//             const SizedBox(height: 8),
//             _buildSummaryGrid(counts),
//             const SizedBox(height: 8),
//             Text('Total Days: ${selected.length}', style: const TextStyle(fontSize: 12, color: _kSlate, fontWeight: FontWeight.w600)),
//           ] else
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 40),
//               child: Center(child: Text('Select an employee above')),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOverviewChartOnly(Map<String, int> counts, int totalDays) {
//     final segments = [
//       ('present', _kGreen), ('late', _kOrange), ('leave', _kBlue),
//       ('half_day', _kPurple), ('absent', _kRed), ('holiday', _kGray),
//     ];
//     final nonZero = segments.where((s) => (counts[s.$1] ?? 0) > 0).toList();
//     final sumForChart = nonZero.fold<int>(0, (a, s) => a + (counts[s.$1] ?? 0));
//     if (sumForChart == 0) {
//       return const Center(child: Text('No attendance marked yet', style: TextStyle(color: _kSlate, fontSize: 12)));
//     }
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         PieChart(
//           PieChartData(
//             sectionsSpace: 2,
//             centerSpaceRadius: 45,
//             sections: nonZero.map((s) {
//               final value = (counts[s.$1] ?? 0).toDouble();
//               final pct = sumForChart > 0 ? (value / sumForChart * 100) : 0.0;
//               return PieChartSectionData(
//                 value: value,
//                 color: s.$2,
//                 radius: 45,
//                 title: '${pct.toStringAsFixed(1)}%',
//                 titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
//               );
//             }).toList(),
//           ),
//         ),
//         Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('$totalDays', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _kInk)),
//             const Text('Days', style: TextStyle(fontSize: 10, color: _kSlate)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSummaryGrid(Map<String, int> counts) {
//     final items = [
//       ('Present', counts['present']!, _kGreen),
//       ('Absent', counts['absent']!, _kRed),
//       ('Late', counts['late']!, _kOrange),
//       ('Leave', counts['leave']!, _kBlue),
//       ('Half Day', counts['half_day']!, _kPurple),
//       ('Holidays', counts['holiday']!, _kGray),
//     ];
//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       mainAxisSpacing: 8,
//       crossAxisSpacing: 8,
//       childAspectRatio: 2.2,
//       children: items.map((item) {
//         return Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('${item.$2}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: item.$3)),
//               Text(item.$1, style: const TextStyle(fontSize: 11, color: _kSlate)),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
// Uint8List? _decodeBase64(String data) {
//   try {
//     return base64Decode(data.contains(',') ? data.split(',').last : data);
//   } catch (_) {
//     return null;
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════
// // Status picker bottom sheet
// // ═══════════════════════════════════════════════════════════════
// class _StatusPickerSheet extends StatelessWidget {
//   final DateTime date;
//   final String currentStatus; // '' means unset
//
//   const _StatusPickerSheet({required this.date, required this.currentStatus});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 36,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 12),
//               decoration: BoxDecoration(color: _kBorder, borderRadius: BorderRadius.circular(2)),
//             ),
//           ),
//           Row(
//             children: [
//               const Icon(Icons.calendar_today, size: 16, color: _kPrimary),
//               const SizedBox(width: 8),
//               Text(DateFormat('EEEE, d MMMM yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
//             ],
//           ),
//           const SizedBox(height: 4),
//           const Text('Select attendance status', style: TextStyle(fontSize: 12, color: _kSlate)),
//           const SizedBox(height: 16),
//           GridView.count(
//             crossAxisCount: 3,
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             mainAxisSpacing: 10,
//             crossAxisSpacing: 10,
//             childAspectRatio: 1.1,
//             children: _kStatuses.map((s) {
//               final isSelected = s.key == currentStatus;
//               return InkWell(
//                 onTap: () => Navigator.pop(context, s.key),
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: s.bg,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: isSelected ? s.color : s.color.withOpacity(0.25), width: isSelected ? 2 : 1),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(s.icon, color: s.color, size: 22),
//                       const SizedBox(height: 6),
//                       Text(s.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: s.color)),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════
// // Compact year picker popup (small, opens when clicking year)
// // ═══════════════════════════════════════════════════════════════
// class _CompactYearPicker extends StatelessWidget {
//   final int currentYear;
//   final int maxYear;
//   static const int _minYear = 2015;
//
//   const _CompactYearPicker({required this.currentYear, required this.maxYear});
//
//   @override
//   Widget build(BuildContext context) {
//     final years = List.generate(maxYear - _minYear + 1, (i) => _minYear + i).reversed.toList();
//
//     return Dialog(
//       backgroundColor: Colors.white,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 100, vertical: 200),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 220, maxHeight: 260),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 6),
//                 child: Text('Select Year', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
//               ),
//               Flexible(
//                 child: GridView.builder(
//                   shrinkWrap: true,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     childAspectRatio: 1.7,
//                     mainAxisSpacing: 6,
//                     crossAxisSpacing: 6,
//                   ),
//                   itemCount: years.length,
//                   itemBuilder: (ctx, i) {
//                     final year = years[i];
//                     final isSelected = year == currentYear;
//                     return InkWell(
//                       onTap: () => Navigator.pop(context, year),
//                       borderRadius: BorderRadius.circular(6),
//                       child: Container(
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: isSelected ? _kPrimary.withOpacity(0.1) : null,
//                           border: Border.all(color: isSelected ? _kPrimary : _kBorder),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           '$year',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                             color: isSelected ? _kPrimary : _kInk,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════
// // NEW: Compact month picker popup — same tight dialog UX as the year
// // picker. Shows a 3x4 grid of month abbreviations for the currently
// // selected year, with < > arrows above to flip years in place without
// // closing the popup (so jumping e.g. "Nov 2023" takes 2 taps total).
// // ═══════════════════════════════════════════════════════════════
// class _MonthYearPick {
//   final int year;
//   final int month;
//   const _MonthYearPick(this.year, this.month);
// }
//
// class _CompactMonthPicker extends StatefulWidget {
//   final int currentYear;
//   final int currentMonth;
//   final int maxYear;
//
//   const _CompactMonthPicker({
//     required this.currentYear,
//     required this.currentMonth,
//     required this.maxYear,
//   });
//
//   @override
//   State<_CompactMonthPicker> createState() => _CompactMonthPickerState();
// }
//
// class _CompactMonthPickerState extends State<_CompactMonthPicker> {
//   static const int _minYear = 2015;
//   late int _year;
//
//   static const _monthLabels = [
//     'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _year = widget.currentYear;
//   }
//
//   bool get _canGoPrevYear => _year > _minYear;
//   bool get _canGoNextYear => _year < widget.maxYear;
//
//   bool _isMonthDisabled(int monthIndex) {
//     final now = DateTime.now();
//     final candidate = DateTime(_year, monthIndex + 1);
//     return candidate.isAfter(DateTime(now.year, now.month));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       insetPadding: const EdgeInsets.symmetric(horizontal: 90, vertical: 180),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 260, maxHeight: 300),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     onTap: _canGoPrevYear ? () => setState(() => _year -= 1) : null,
//                     borderRadius: BorderRadius.circular(6),
//                     child: Padding(
//                       padding: const EdgeInsets.all(4),
//                       child: Icon(Icons.chevron_left, size: 20, color: _canGoPrevYear ? _kInk : _kBorder),
//                     ),
//                   ),
//                   Text('$_year', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
//                   InkWell(
//                     onTap: _canGoNextYear ? () => setState(() => _year += 1) : null,
//                     borderRadius: BorderRadius.circular(6),
//                     child: Padding(
//                       padding: const EdgeInsets.all(4),
//                       child: Icon(Icons.chevron_right, size: 20, color: _canGoNextYear ? _kInk : _kBorder),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Flexible(
//                 child: GridView.builder(
//                   shrinkWrap: true,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     childAspectRatio: 1.9,
//                     mainAxisSpacing: 6,
//                     crossAxisSpacing: 6,
//                   ),
//                   itemCount: 12,
//                   itemBuilder: (ctx, i) {
//                     final isSelected = (i + 1) == widget.currentMonth && _year == widget.currentYear;
//                     final isDisabled = _isMonthDisabled(i);
//                     return InkWell(
//                       onTap: isDisabled ? null : () => Navigator.pop(context, _MonthYearPick(_year, i + 1)),
//                       borderRadius: BorderRadius.circular(6),
//                       child: Container(
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: isSelected ? _kPrimary.withOpacity(0.1) : null,
//                           border: Border.all(color: isSelected ? _kPrimary : _kBorder),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           _monthLabels[i],
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                             color: isDisabled ? _kBorder : (isSelected ? _kPrimary : _kInk),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//

//2nd code
import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';

// ─── Design tokens (Material 3 inspired) ──────────────────────
const _kInk = Color(0xFF1F2937);
const _kSlate = Color(0xFF64748B);
const _kBorder = Color(0xFFE2E8F0);
const _kSurface = Color(0xFFF8FAFC);
const _kCard = Colors.white;
const _kPrimary = Color(0xFF2563EB);
const _kPrimaryDark = Color(0xFF1E40AF);

const _kGreen = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFDCFCE7);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEE2E2);
const _kOrange = Color(0xFFD97706);
const _kOrangeBg = Color(0xFFFEF3C7);
const _kBlue = Color(0xFF2563EB);
const _kBlueBg = Color(0xFFDBEAFE);
const _kPurple = Color(0xFF9333EA);
const _kPurpleBg = Color(0xFFF3E8FF);
const _kGray = Color(0xFF6B7280);
const _kGrayBg = Color(0xFFE5E7EB);
const _kBlank = Color(0xFF94A3B8);
const _kBlankBg = Color(0xFFF8FAFC);

class _StatusInfo {
  final String key;
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const _StatusInfo(this.key, this.label, this.color, this.bg, this.icon);
}

const _kStatuses = <_StatusInfo>[
  _StatusInfo('present', 'Present', _kGreen, _kGreenBg, Icons.person_outline),
  _StatusInfo('absent', 'Absent', _kRed, _kRedBg, Icons.person_off_outlined),
  _StatusInfo('late', 'Late', _kOrange, _kOrangeBg, Icons.access_time),
  _StatusInfo('leave', 'Leave', _kBlue, _kBlueBg, Icons.work_outline),
  _StatusInfo('half_day', 'Half Day', _kPurple, _kPurpleBg, Icons.hourglass_bottom),
];

_StatusInfo _statusInfo(String key) {
  if (key.isEmpty || key == 'unset') {
    return const _StatusInfo('unset', '—', _kBlank, _kBlankBg, Icons.circle_outlined);
  }
  return _kStatuses.firstWhere(
        (s) => s.key == key,
    orElse: () => const _StatusInfo('holiday', 'Holiday', _kGray, _kGrayBg, Icons.block),
  );
}

class BulkAttendanceScreen extends StatefulWidget {
  const BulkAttendanceScreen({super.key});

  @override
  State<BulkAttendanceScreen> createState() => _BulkAttendanceScreenState();
}

class _BulkAttendanceScreenState extends State<BulkAttendanceScreen>
    with TickerProviderStateMixin {
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  String? _selectedStaffId;
  String _search = '';
  bool _saving = false;

  bool _initialLoading = true;
  bool _calendarLoading = false;

  final Set<String> _untouched = {};

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(initial: true));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool initial = false}) async {
    final provider = context.read<AttendanceProvider>();

    setState(() {
      if (initial) {
        _initialLoading = true;
      } else {
        _calendarLoading = true;
      }
    });

    await provider.loadBulkAttendance(year: _year, month: _month, typeFilter: 'all');

    _untouched.clear();
    for (final r in provider.bulkRecords) {
      final dt = DateTime.parse(r.date);
      final isSunday = dt.weekday == DateTime.sunday;
      final isBeforeJoin = r.remarks == 'Before joining';
      if (!isSunday && !isBeforeJoin && !r.isSaved) {
        _untouched.add('${r.staffId}_${r.date}');
      }
    }

    if (!mounted) return;

    setState(() {
      if (_selectedStaffId == null && provider.bulkRecords.isNotEmpty) {
        _selectedStaffId = provider.bulkRecords.first.staffId;
      }
      _initialLoading = false;
      _calendarLoading = false;
    });

    _fadeController.reset();
    _fadeController.forward();
  }

  String _key(String staffId, String date) => '${staffId}_$date';

  Future<void> _saveAttendance() async {
    if (_selectedStaffId == null) return;
    setState(() => _saving = true);
    try {
      await context.read<AttendanceProvider>().saveBulkAttendanceForStaff(_selectedStaffId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved successfully'), backgroundColor: _kGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: _kRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _markAllForSelected(String status) {
    final provider = context.read<AttendanceProvider>();
    if (_selectedStaffId == null) return;
    final records = provider.bulkRecords.where((r) => r.staffId == _selectedStaffId).toList();
    setState(() {
      for (final r in records) {
        final dt = DateTime.parse(r.date);
        final isReadOnly = r.remarks == 'Before joining' || dt.weekday == DateTime.sunday;
        if (isReadOnly) continue;
        provider.updateBulkStatus(r.staffId, r.date, status);
        _untouched.remove(_key(r.staffId, r.date));
      }
    });
  }

  Future<void> _openStatusPicker(AttendanceRecord record) async {
    final dt = DateTime.parse(record.date);
    final isReadOnly = record.remarks == 'Before joining' || dt.weekday == DateTime.sunday;
    if (isReadOnly) return;

    final isUnset = _untouched.contains(_key(record.staffId, record.date));

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StatusPickerSheet(
        date: dt,
        currentStatus: isUnset ? '' : record.status,
      ),
    );

    if (selected != null) {
      setState(() {
        context.read<AttendanceProvider>().updateBulkStatus(record.staffId, record.date, selected);
        _untouched.remove(_key(record.staffId, record.date));
      });
    }
  }

  Future<void> _pickYear() async {
    final result = await showDialog<int>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (ctx) => _CompactYearPicker(currentYear: _year, maxYear: DateTime.now().year),
    );
    if (result != null && result != _year) {
      setState(() => _year = result);
      _loadData();
    }
  }

  Future<void> _pickMonth() async {
    final result = await showDialog<_MonthYearPick>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (ctx) => _CompactMonthPicker(currentYear: _year, currentMonth: _month, maxYear: DateTime.now().year),
    );
    if (result != null) {
      final now = DateTime.now();
      final candidate = DateTime(result.year, result.month);
      if (candidate.isAfter(DateTime(now.year, now.month))) return;
      if (result.year == _year && result.month == _month) return;
      setState(() {
        _year = result.year;
        _month = result.month;
      });
      _loadData();
    }
  }

  void _prevMonth() {
    if (_month == 1) {
      _year -= 1;
      _month = 12;
    } else {
      _month -= 1;
    }
    setState(() {});
    _loadData();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = _month == 12 ? DateTime(_year + 1, 1) : DateTime(_year, _month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return;
    if (_month == 12) {
      _year += 1;
      _month = 1;
    } else {
      _month += 1;
    }
    setState(() {});
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: _kSurface,
      body: SafeArea(
        child: _initialLoading
            ? _buildInitialShimmer()
            : provider.bulkError != null
            ? Center(child: Text('Error: ${provider.bulkError}'))
            : provider.bulkRecords.isEmpty
            ? const Center(child: Text('No staff found.'))
            : FadeTransition(
          opacity: _fadeAnimation,
          child: isDesktop ? _buildDesktop(provider) : _buildMobile(provider),
        ),
      ),
    );
  }

  Widget _buildInitialShimmer() {
    return Shimmer.fromColors(
      baseColor: _kBorder,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _shimmerBox(height: 40, width: double.infinity),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _shimmerBox(height: double.infinity)),
                  const SizedBox(width: 16),
                  Expanded(child: _shimmerBox(height: double.infinity)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Shared data helpers
  // ═══════════════════════════════════════════════════════════════
  List<AttendanceRecord> _uniqueStaff(List<AttendanceRecord> records) {
    final seen = <String>{};
    final result = <AttendanceRecord>[];
    for (final r in records) {
      if (seen.add(r.staffId)) result.add(r);
    }
    result.sort((a, b) => a.staffName.compareTo(b.staffName));
    return result;
  }

  List<AttendanceRecord> _selectedRecords(AttendanceProvider provider) {
    final list = provider.bulkRecords.where((r) => r.staffId == _selectedStaffId).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  String _effectiveStatus(AttendanceRecord r) {
    if (_untouched.contains(_key(r.staffId, r.date))) return '';
    return r.status;
  }

  Map<String, int> _counts(List<AttendanceRecord> records) {
    final counts = <String, int>{
      'present': 0, 'absent': 0, 'late': 0, 'leave': 0, 'half_day': 0, 'holiday': 0,
    };
    for (final r in records) {
      final status = _effectiveStatus(r);
      if (counts.containsKey(status)) counts[status] = counts[status]! + 1;
    }
    return counts;
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktop(AttendanceProvider provider) {
    final staffList = _uniqueStaff(provider.bulkRecords);
    final selected = _selectedRecords(provider);
    final counts = _counts(selected);

    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: _buildCalendarCard(selected)),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: _buildOverviewCard(counts, selected.length)),
                const SizedBox(width: 16),
                SizedBox(width: 260, child: _buildEmployeePanel(staffList)),
              ],
            ),
          ),
        ),
        _buildBottomBar(selected, counts),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: _kSurface,
      child: Row(
        children: [
          _monthYearSelector(),
          const SizedBox(width: 10),
          _pillButton(label: 'All Present', icon: Icons.check_circle_outline, color: _kGreen, bg: _kGreenBg, onTap: () => _markAllForSelected('present')),
          const SizedBox(width: 8),
          _pillButton(label: 'All Absent', icon: Icons.cancel_outlined, color: _kRed, bg: _kRedBg, onTap: () => _markAllForSelected('absent')),
          const Spacer(),
          ..._legendChips(),
        ],
      ),
    );
  }

  Widget _monthYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: _pickMonth,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 14, color: _kInk),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: _kSlate),
          ],
        ),
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  List<Widget> _legendChips() {
    final legend = [
      ('P', 'Present', _kGreen, _kGreenBg),
      ('A', 'Absent', _kRed, _kRedBg),
      ('L', 'Late', _kOrange, _kOrangeBg),
      ('Lv', 'Leave', _kBlue, _kBlueBg),
      ('H', 'Half Day', _kPurple, _kPurpleBg),
      ('H', 'Holiday', _kGray, _kGrayBg),
    ];
    return legend.map((item) {
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: item.$4,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: item.$3)),
              Text(item.$2, style: TextStyle(fontSize: 9, color: item.$3)),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCalendarCard(List<AttendanceRecord> records) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _calendarHeader(),
          const SizedBox(height: 10),
          _weekDayRow(),
          const SizedBox(height: 6),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _calendarLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _buildCalendarGrid(records),
            ),
          ),
          const SizedBox(height: 8),
          _statusLegendRow(),
        ],
      ),
    );
  }

  Widget _calendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _kPrimaryDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _prevMonth,
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 18),
            splashRadius: 16,
            padding: EdgeInsets.zero,
          ),
          Expanded(
            child: InkWell(
              onTap: _pickMonth,
              child: Center(
                child: Text(
                  DateFormat('MMMM yyyy').format(DateTime(_year, _month)),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
            splashRadius: 16,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _weekDayRow() {
    return Row(
      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
          .map((d) => Expanded(
        child: Center(
          child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kSlate)),
        ),
      ))
          .toList(),
    );
  }

  Widget _statusLegendRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: _kStatuses.map((s) => _dotLegend(s.label, s.color)).toList()
        ..add(_dotLegend('Holiday', _kGray)),
    );
  }

  Widget _dotLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: _kSlate)),
      ],
    );
  }

  Widget _buildCalendarGrid(List<AttendanceRecord> records) {
    final recByDate = {for (var r in records) r.date: r};
    final monthStart = DateTime(_year, _month, 1);
    final monthEnd = DateTime(_year, _month + 1, 0);
    final leadingEmpty = monthStart.weekday % 7;

    final cells = <Widget>[];
    for (int i = 0; i < leadingEmpty; i++) {
      cells.add(const SizedBox());
    }
    for (int day = 1; day <= monthEnd.day; day++) {
      final dt = DateTime(_year, _month, day);
      final dateStr = '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      final rec = recByDate[dateStr];
      cells.add(_buildDayCell(dt, rec));
    }

    return RepaintBoundary(
      child: GridView.count(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        children: cells,
      ),
    );
  }

  Widget _buildDayCell(DateTime dt, AttendanceRecord? rec) {
    if (rec == null) return const SizedBox();
    final isReadOnly = rec.remarks == 'Before joining' || dt.weekday == DateTime.sunday;
    final status = isReadOnly ? 'holiday' : _effectiveStatus(rec);
    final info = _statusInfo(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isReadOnly ? null : () => _openStatusPicker(rec),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: info.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: status == 'unset' ? _kBorder : info.color.withOpacity(0.35),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${dt.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isReadOnly ? _kSlate : (status == 'unset' ? _kInk : info.color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(Map<String, int> counts, int totalDays) {
    final segments = [
      ('present', 'Present', _kGreen),
      ('late', 'Late', _kOrange),
      ('leave', 'Leave', _kBlue),
      ('half_day', 'Half Day', _kPurple),
      ('absent', 'Absent', _kRed),
      ('holiday', 'Holiday', _kGray),
    ];
    final nonZero = segments.where((s) => (counts[s.$1] ?? 0) > 0).toList();
    final sumForChart = nonZero.fold<int>(0, (a, s) => a + (counts[s.$1] ?? 0));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attendance Overview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: sumForChart == 0
                ? const Center(
                child: Text('No attendance marked yet',
                    style: TextStyle(color: _kSlate, fontSize: 12)))
                : Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 48,
                    sections: nonZero.map((s) {
                      final value = (counts[s.$1] ?? 0).toDouble();
                      final pct = sumForChart > 0 ? (value / sumForChart * 100) : 0.0;
                      return PieChartSectionData(
                        value: value,
                        color: s.$3,
                        radius: 48,
                        title: '${pct.toStringAsFixed(1)}%',
                        titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$totalDays',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800, color: _kInk)),
                    const Text('Days',
                        style: TextStyle(fontSize: 11, color: _kSlate)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: segments.map((s) => _dotLegend(s.$2, s.$3)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeePanel(List<AttendanceRecord> staffList) {
    final filtered = staffList
        .where((s) => s.staffName.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Employee',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search employee...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    filled: true,
                    fillColor: _kSurface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kPrimary, width: 1.5),
                    ),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No employees found',
                    style: TextStyle(fontSize: 12, color: _kSlate)),
              ),
            )
                : Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final s = filtered[i];
                  final isSelected = s.staffId == _selectedStaffId;
                  return _employeeTile(s, isSelected);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _employeeTile(AttendanceRecord s, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedStaffId = s.staffId),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? _kPrimary.withOpacity(0.07) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: _kPrimary.withOpacity(0.4)) : null,
            ),
            child: Row(
              children: [
                _employeeAvatar(s),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.staffName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(s.designation ?? s.type,
                          style: const TextStyle(fontSize: 11, color: _kSlate)),
                    ],
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  activeColor: _kPrimary,
                  onChanged: (_) => setState(() => _selectedStaffId = s.staffId),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _employeeAvatar(AttendanceRecord s) {
    final hasPhoto = s.photoBase64 != null && s.photoBase64!.isNotEmpty;
    if (hasPhoto) {
      final bytes = _decodeBase64(s.photoBase64!);
      if (bytes != null) {
        return CircleAvatar(radius: 16, backgroundImage: MemoryImage(bytes));
      }
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: _kBorder,
      child: Icon(Icons.person, size: 16, color: _kSlate),
    );
  }

  Widget _buildBottomBar(List<AttendanceRecord> records, Map<String, int> counts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attendance Summary',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: _summaryChipRow(counts))]),
          const SizedBox(height: 10),
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: _kSlate),
                  const SizedBox(width: 6),
                  Text('Total Days: ${records.length}',
                      style: const TextStyle(
                          fontSize: 12, color: _kSlate, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(width: 16),
              const Text('Click on date to view or mark attendance',
                  style: TextStyle(fontSize: 11, color: _kSlate, fontStyle: FontStyle.italic)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: (_saving || _selectedStaffId == null) ? null : _saveAttendance,
                icon: _saving
                    ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save, size: 16),
                label: const Text('Save Attendance',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChipRow(Map<String, int> counts) {
    final items = [
      ('Present', counts['present']!, _kGreen),
      ('Absent', counts['absent']!, _kRed),
      ('Late', counts['late']!, _kOrange),
      ('Leave', counts['leave']!, _kBlue),
      ('Half Day', counts['half_day']!, _kPurple),
      ('Holidays', counts['holiday']!, _kGray),
    ];
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.$2}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: item.$3)),
                const SizedBox(height: 2),
                Text(item.$1, style: const TextStyle(fontSize: 11, color: _kSlate)),
                const SizedBox(height: 4),
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: item.$3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE LAYOUT (same improvements)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobile(AttendanceProvider provider) {
    final staffList = _uniqueStaff(provider.bulkRecords);
    final selected = _selectedRecords(provider);
    final counts = _counts(selected);
    final filteredStaff =
    staffList.where((s) => s.staffName.toLowerCase().contains(_search.toLowerCase())).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mobileSaveButton(),
          const SizedBox(height: 12),
          const Text('Attendance Calendar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _kInk)),
          const SizedBox(height: 12),
          _mobileSearchBar(),
          const SizedBox(height: 10),
          _mobileStaffChips(filteredStaff),
          const SizedBox(height: 12),
          _mobileMonthYearRow(),
          const SizedBox(height: 12),
          if (_selectedStaffId != null) ...[
            _mobileCalendarCard(selected),
            const SizedBox(height: 12),
            _mobileBulkActionsRow(),
            const SizedBox(height: 12),
            _mobileOverviewCard(counts, selected.length),
            const SizedBox(height: 12),
            const Text('Attendance Summary',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            _buildSummaryGrid(counts),
            const SizedBox(height: 8),
            Text('Total Days: ${selected.length}',
                style: const TextStyle(fontSize: 12, color: _kSlate, fontWeight: FontWeight.w600)),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Select an employee above')),
            ),
        ],
      ),
    );
  }

  Widget _mobileSaveButton() {
    return ElevatedButton.icon(
      onPressed: (_saving || _selectedStaffId == null) ? null : _saveAttendance,
      icon: _saving
          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.save, size: 16),
      label: const Text('Save Attendance'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _mobileSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search employee...',
        prefixIcon: const Icon(Icons.search, size: 18),
        isDense: true,
        filled: true,
        fillColor: _kCard,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPrimary)),
      ),
      onChanged: (v) => setState(() => _search = v),
    );
  }

  Widget _mobileStaffChips(List<AttendanceRecord> filteredStaff) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredStaff.length,
        itemBuilder: (ctx, i) {
          final s = filteredStaff[i];
          final isSelected = s.staffId == _selectedStaffId;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: _employeeAvatar(s),
              label: Text(s.staffName, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              selectedColor: _kPrimary.withOpacity(0.15),
              labelStyle: TextStyle(
                  color: isSelected ? _kPrimary : _kInk,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
              onSelected: (_) => setState(() => _selectedStaffId = s.staffId),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }

  Widget _mobileMonthYearRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder)),
            child: InkWell(
              onTap: _pickMonth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 14),
                  const SizedBox(width: 8),
                  Text(DateFormat('MMMM').format(DateTime(_year, _month)),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder)),
            child: InkWell(
              onTap: _pickYear,
              child: Row(
                children: [
                  Text('$_year', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileCalendarCard(List<AttendanceRecord> selected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _calendarHeader(),
          const SizedBox(height: 8),
          _weekDayRow(),
          const SizedBox(height: 6),
          SizedBox(
            height: 260,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _calendarLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _buildCalendarGrid(selected),
            ),
          ),
          const SizedBox(height: 8),
          _statusLegendRow(),
        ],
      ),
    );
  }

  Widget _mobileBulkActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _pillButton(
              label: 'All Present',
              icon: Icons.check_circle_outline,
              color: _kGreen,
              bg: _kGreenBg,
              onTap: () => _markAllForSelected('present')),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _pillButton(
              label: 'All Absent',
              icon: Icons.cancel_outlined,
              color: _kRed,
              bg: _kRedBg,
              onTap: () => _markAllForSelected('absent')),
        ),
      ],
    );
  }

  Widget _mobileOverviewCard(Map<String, int> counts, int totalDays) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attendance Overview',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          SizedBox(
              height: 200,
              child: _buildOverviewChartOnly(counts, totalDays)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _dotLegend('Present', _kGreen),
              _dotLegend('Late', _kOrange),
              _dotLegend('Leave', _kBlue),
              _dotLegend('Half Day', _kPurple),
              _dotLegend('Absent', _kRed),
              _dotLegend('Holiday', _kGray),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewChartOnly(Map<String, int> counts, int totalDays) {
    final segments = [
      ('present', _kGreen),
      ('late', _kOrange),
      ('leave', _kBlue),
      ('half_day', _kPurple),
      ('absent', _kRed),
      ('holiday', _kGray),
    ];
    final nonZero = segments.where((s) => (counts[s.$1] ?? 0) > 0).toList();
    final sumForChart = nonZero.fold<int>(0, (a, s) => a + (counts[s.$1] ?? 0));
    if (sumForChart == 0) {
      return const Center(
          child: Text('No attendance marked yet',
              style: TextStyle(color: _kSlate, fontSize: 12)));
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 45,
            sections: nonZero.map((s) {
              final value = (counts[s.$1] ?? 0).toDouble();
              final pct = sumForChart > 0 ? (value / sumForChart * 100) : 0.0;
              return PieChartSectionData(
                value: value,
                color: s.$2,
                radius: 45,
                title: '${pct.toStringAsFixed(1)}%',
                titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              );
            }).toList(),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$totalDays',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: _kInk)),
            const Text('Days', style: TextStyle(fontSize: 10, color: _kSlate)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(Map<String, int> counts) {
    final items = [
      ('Present', counts['present']!, _kGreen),
      ('Absent', counts['absent']!, _kRed),
      ('Late', counts['late']!, _kOrange),
      ('Leave', counts['leave']!, _kBlue),
      ('Half Day', counts['half_day']!, _kPurple),
      ('Holidays', counts['holiday']!, _kGray),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${item.$2}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: item.$3)),
              Text(item.$1, style: const TextStyle(fontSize: 11, color: _kSlate)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

Uint8List? _decodeBase64(String data) {
  try {
    return base64Decode(data.contains(',') ? data.split(',').last : data);
  } catch (_) {
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════
// Status picker bottom sheet
// ═══════════════════════════════════════════════════════════════
class _StatusPickerSheet extends StatelessWidget {
  final DateTime date;
  final String currentStatus;

  const _StatusPickerSheet({required this.date, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: _kBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: _kPrimary),
              const SizedBox(width: 8),
              Text(DateFormat('EEEE, d MMMM yyyy').format(date),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Select attendance status',
              style: TextStyle(fontSize: 12, color: _kSlate)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: _kStatuses.map((s) {
              final isSelected = s.key == currentStatus;
              return InkWell(
                onTap: () => Navigator.pop(context, s.key),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: s.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected ? s.color : s.color.withOpacity(0.25),
                        width: isSelected ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s.icon, color: s.color, size: 22),
                      const SizedBox(height: 6),
                      Text(s.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: s.color)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Compact year picker popup
// ═══════════════════════════════════════════════════════════════
class _CompactYearPicker extends StatelessWidget {
  final int currentYear;
  final int maxYear;
  static const int _minYear = 2015;

  const _CompactYearPicker({required this.currentYear, required this.maxYear});

  @override
  Widget build(BuildContext context) {
    final years = List.generate(maxYear - _minYear + 1, (i) => _minYear + i).reversed.toList();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 100, vertical: 200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220, maxHeight: 260),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('Select Year',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: years.length,
                  itemBuilder: (ctx, i) {
                    final year = years[i];
                    final isSelected = year == currentYear;
                    return InkWell(
                      onTap: () => Navigator.pop(context, year),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? _kPrimary.withOpacity(0.1) : null,
                          border: Border.all(color: isSelected ? _kPrimary : _kBorder),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$year',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? _kPrimary : _kInk,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Compact month picker popup
// ═══════════════════════════════════════════════════════════════
class _MonthYearPick {
  final int year;
  final int month;
  const _MonthYearPick(this.year, this.month);
}

class _CompactMonthPicker extends StatefulWidget {
  final int currentYear;
  final int currentMonth;
  final int maxYear;

  const _CompactMonthPicker({
    required this.currentYear,
    required this.currentMonth,
    required this.maxYear,
  });

  @override
  State<_CompactMonthPicker> createState() => _CompactMonthPickerState();
}

class _CompactMonthPickerState extends State<_CompactMonthPicker> {
  static const int _minYear = 2015;
  late int _year;

  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.currentYear;
  }

  bool get _canGoPrevYear => _year > _minYear;
  bool get _canGoNextYear => _year < widget.maxYear;

  bool _isMonthDisabled(int monthIndex) {
    final now = DateTime.now();
    final candidate = DateTime(_year, monthIndex + 1);
    return candidate.isAfter(DateTime(now.year, now.month));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 90, vertical: 180),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260, maxHeight: 300),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _canGoPrevYear ? () => setState(() => _year -= 1) : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.chevron_left,
                          size: 20,
                          color: _canGoPrevYear ? _kInk : _kBorder),
                    ),
                  ),
                  Text('$_year',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  InkWell(
                    onTap: _canGoNextYear ? () => setState(() => _year += 1) : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.chevron_right,
                          size: 20,
                          color: _canGoNextYear ? _kInk : _kBorder),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.9,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: 12,
                  itemBuilder: (ctx, i) {
                    final isSelected =
                        (i + 1) == widget.currentMonth && _year == widget.currentYear;
                    final isDisabled = _isMonthDisabled(i);
                    return InkWell(
                      onTap: isDisabled
                          ? null
                          : () => Navigator.pop(context, _MonthYearPick(_year, i + 1)),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? _kPrimary.withOpacity(0.1) : null,
                          border: Border.all(color: isSelected ? _kPrimary : _kBorder),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _monthLabels[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isDisabled
                                ? _kBorder
                                : (isSelected ? _kPrimary : _kInk),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


