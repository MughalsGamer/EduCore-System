//
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import '../../models/teacher.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/teacher_provider.dart';
// import '../../providers/attendance_provider.dart';
// import '../../models/attendance_model.dart';
//
// // ============================================================
// // DESIGN TOKENS — kept identical to attendance_screen.dart so
// // both screens feel like one consistent module.
// // ============================================================
// const _kInk = Color(0xFF1F2937);
// const _kSlate = Color(0xFF64748B);
// const _kBorder = Color(0xFFE2E8F0);
// const _kSurface = Color(0xFFF8FAFC);
// const _kCard = Colors.white;
//
// const _kPrimary = Color(0xFF1E3A8A);
// const _kPrimaryLight = Color(0xFFEFF4FF);
//
// const _kGreen = Color(0xFF166534);
// const _kGreenBg = Color(0xFFEFFCF3);
// const _kRed = Color(0xFFB91C1C);
// const _kRedBg = Color(0xFFFEF2F2);
// const _kOrange = Color(0xFFB45309);
// const _kOrangeBg = Color(0xFFFFFBEB);
// const _kBlue = Color(0xFF1D4ED8);
// const _kBlueBg = Color(0xFFEFF6FF);
// const _kPurple = Color(0xFF6D28D9);
// const _kPurpleBg = Color(0xFFF5F3FF);
//
// const List<Map<String, Object>> _kStatuses = [
//   {'key': 'present', 'label': 'Present', 'icon': Icons.check_circle_rounded, 'color': _kGreen, 'bg': _kGreenBg},
//   {'key': 'absent', 'label': 'Absent', 'icon': Icons.cancel_rounded, 'color': _kRed, 'bg': _kRedBg},
//   {'key': 'late', 'label': 'Late', 'icon': Icons.schedule_rounded, 'color': _kOrange, 'bg': _kOrangeBg},
//   {'key': 'leave', 'label': 'Leave', 'icon': Icons.beach_access_rounded, 'color': _kBlue, 'bg': _kBlueBg},
//   {'key': 'half_day', 'label': 'Half Day', 'icon': Icons.hourglass_bottom_rounded, 'color': _kPurple, 'bg': _kPurpleBg},
// ];
//
// Map<String, Object> _statusMeta(String key) {
//   return _kStatuses.firstWhere((s) => s['key'] == key,
//       orElse: () => _kStatuses[0]);
// }
//
// const double _kDesktopBreakpoint = 900;
//
// // ============================================================
// // ROOT SCREEN — 2 tabs: By Date / By Person
// // ============================================================
// class AttendanceHistoryScreen extends StatefulWidget {
//   const AttendanceHistoryScreen({super.key});
//
//   @override
//   State<AttendanceHistoryScreen> createState() =>
//       _AttendanceHistoryScreenState();
// }
//
// class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isAdmin = context.watch<AuthProvider>().role == 'admin';
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         titleSpacing: 20,
//         title: const Text(
//           'Attendance History',
//           style: TextStyle(
//               fontWeight: FontWeight.w700, fontSize: 17, color: _kInk),
//         ),
//         backgroundColor: _kCard,
//         surfaceTintColor: _kCard,
//         foregroundColor: _kInk,
//         elevation: 0,
//         shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: _kPrimary,
//           unselectedLabelColor: _kSlate,
//           indicatorColor: _kPrimary,
//           indicatorWeight: 2.5,
//           labelStyle:
//           const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
//           unselectedLabelStyle:
//           const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
//           tabs: const [
//             Tab(text: 'By Date'),
//             Tab(text: 'By Person'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _ByDateTab(isAdmin: isAdmin),
//           _ByPersonTab(isAdmin: isAdmin),
//         ],
//       ),
//     );
//   }
// }
//
// // ============================================================
// // SHARED: read-only banner
// // ============================================================
// class _ViewOnlyBanner extends StatelessWidget {
//   const _ViewOnlyBanner();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: _kBlueBg,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: _kBlue.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: const [
//           Icon(Icons.info_outline, size: 16, color: _kBlue),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'View only. Only an admin can edit attendance records.',
//               style: TextStyle(fontSize: 12.5, color: _kBlue, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ★ NEW: shown when a history query fails (e.g. missing Firestore
// // composite index) instead of leaving the user staring at an
// // infinite spinner with no explanation.
// class _ErrorState extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _ErrorState({required this.message, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline_rounded, size: 44, color: _kRed),
//             const SizedBox(height: 12),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 12.5, color: _kSlate),
//             ),
//             const SizedBox(height: 14),
//             OutlinedButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(Icons.refresh, size: 16),
//               label: const Text('Retry'),
//               style: OutlinedButton.styleFrom(foregroundColor: _kPrimary),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // TAB 1 — BY DATE (table view)
// // Pick a date → table of everyone's attendance for that date.
// // Unmarked staff default to "Absent". Admin can edit any cell.
// // ============================================================
// class _ByDateTab extends StatefulWidget {
//   final bool isAdmin;
//   const _ByDateTab({required this.isAdmin});
//
//   @override
//   State<_ByDateTab> createState() => _ByDateTabState();
// }
//
// class _ByDateTabState extends State<_ByDateTab> {
//   DateTime _selectedDate = DateTime.now();
//   String _filterType = 'all';
//
//   String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _load());
//   }
//
//   void _load() {
//     context.read<AttendanceProvider>().loadHistoryForDate(
//       _dateStr,
//       typeFilter: _filterType,
//     );
//   }
//
//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//                 primary: _kPrimary, onPrimary: Colors.white, onSurface: _kInk),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() => _selectedDate = picked);
//       _load();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AttendanceProvider>();
//
//     return LayoutBuilder(builder: (context, constraints) {
//       final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//       return Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.fromLTRB(
//                 isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 0),
//             child: _buildToolbar(isDesktop),
//           ),
//           if (!widget.isAdmin) const _ViewOnlyBanner(),
//           const SizedBox(height: 10),
//           Expanded(
//             child: provider.historyLoading
//                 ? const Center(
//                 child: CircularProgressIndicator(
//                     color: _kPrimary, strokeWidth: 2.5))
//                 : provider.historyError != null
//                 ? _ErrorState(
//                 message: provider.historyError!, onRetry: _load)
//                 : provider.historyRecords.isEmpty
//                 ? const _EmptyState(
//                 message: 'No teachers/staff found for this filter.')
//                 : _AttendanceTable(
//               isDesktop: isDesktop,
//               isAdmin: widget.isAdmin,
//               rowLabelHeader: 'Name',
//               rows: provider.historyRecords,
//               rowLabelBuilder: (r) => _NameCell(record: r),
//               subLabelBuilder: (r) =>
//                   _subtitle(r.designation, r.type),
//               onStatusChanged: (record, status) {
//                 context
//                     .read<AttendanceProvider>()
//                     .adminUpdateHistoryRecord(record,
//                     newStatus: status);
//               },
//               onRemarksChanged: (record, remarks) {
//                 context
//                     .read<AttendanceProvider>()
//                     .adminUpdateHistoryRecord(record,
//                     newRemarks: remarks);
//               },
//             ),
//           ),
//         ],
//       );
//     });
//   }
//
//   Widget _buildToolbar(bool isDesktop) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: isDesktop
//           ? Row(
//         children: [
//           _buildDateChip(),
//           const SizedBox(width: 12),
//           _buildTypeFilter(),
//         ],
//       )
//           : Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildDateChip(),
//           const SizedBox(height: 10),
//           _buildTypeFilter(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDateChip() {
//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: _pickDate,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: _kSurface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _kBorder),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.calendar_today_outlined,
//                 size: 16, color: _kSlate),
//             const SizedBox(width: 10),
//             Text(
//               DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
//               style: const TextStyle(
//                   fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk),
//             ),
//             const SizedBox(width: 6),
//             const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTypeFilter() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: _kSurface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: _kBorder),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _filterType,
//           isDense: true,
//           items: const [
//             DropdownMenuItem(value: 'all', child: Text('All (Teachers + Staff)', style: TextStyle(fontSize: 13, color: _kInk))),
//             DropdownMenuItem(value: 'teacher', child: Text('Teachers Only', style: TextStyle(fontSize: 13, color: _kInk))),
//             DropdownMenuItem(value: 'staff', child: Text('Staff Only', style: TextStyle(fontSize: 13, color: _kInk))),
//           ],
//           onChanged: (val) {
//             if (val == null) return;
//             setState(() => _filterType = val);
//             _load();
//           },
//           icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//           style: const TextStyle(fontSize: 13, color: _kInk),
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // TAB 2 — BY PERSON (table view)
// // Search + pick one staff/teacher → month switcher → table of
// // that person's attendance dates for the month.
// // ============================================================
// class _ByPersonTab extends StatefulWidget {
//   final bool isAdmin;
//   const _ByPersonTab({required this.isAdmin});
//
//   @override
//   State<_ByPersonTab> createState() => _ByPersonTabState();
// }
//
// class _ByPersonTabState extends State<_ByPersonTab> {
//   StaffMember? _selectedStaff;
//   DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
//   String _search = '';
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final staffProvider = context.read<StaffProvider>();
//       if (staffProvider.teachers.isEmpty && staffProvider.staffOnly.isEmpty) {
//         staffProvider.fetchTeachers();
//         staffProvider.fetchStaffOnly();
//       }
//     });
//   }
//
//   void _load() {
//     if (_selectedStaff == null) return;
//     context.read<AttendanceProvider>().loadHistoryForPerson(
//       staffId: _selectedStaff!.id!,
//       year: _selectedMonth.year,
//       month: _selectedMonth.month,
//     );
//   }
//
//   void _changeMonth(int delta) {
//     setState(() {
//       _selectedMonth =
//           DateTime(_selectedMonth.year, _selectedMonth.month + delta);
//     });
//     _load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final staffProvider = context.watch<StaffProvider>();
//     final allStaff = [...staffProvider.teachers, ...staffProvider.staffOnly];
//
//     if (_selectedStaff == null) {
//       return _buildPersonPicker(allStaff);
//     }
//
//     return LayoutBuilder(builder: (context, constraints) {
//       final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//       final provider = context.watch<AttendanceProvider>();
//
//       return Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.fromLTRB(
//                 isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 0),
//             child: _buildSelectedPersonHeader(),
//           ),
//           Padding(
//             padding: EdgeInsets.fromLTRB(
//                 isDesktop ? 28 : 16, 10, isDesktop ? 28 : 16, 0),
//             child: _buildMonthSwitcher(),
//           ),
//           if (!widget.isAdmin) const _ViewOnlyBanner(),
//           const SizedBox(height: 10),
//           Expanded(
//             child: provider.historyLoading
//                 ? const Center(
//                 child: CircularProgressIndicator(
//                     color: _kPrimary, strokeWidth: 2.5))
//                 : provider.historyError != null
//                 ? _ErrorState(
//                 message: provider.historyError!, onRetry: _load)
//                 : provider.historyRecords.isEmpty
//                 ? const _EmptyState(
//                 message: 'No attendance records for this month yet.')
//                 : _AttendanceTable(
//               isDesktop: isDesktop,
//               isAdmin: widget.isAdmin,
//               rowLabelHeader: 'Date',
//               rows: provider.historyRecords,
//               rowLabelBuilder: (r) => _DateCell(record: r),
//               subLabelBuilder: (r) =>
//                   _subtitle(r.designation, r.type),
//               onStatusChanged: (record, status) {
//                 context
//                     .read<AttendanceProvider>()
//                     .adminUpdateHistoryRecord(record,
//                     newStatus: status);
//               },
//               onRemarksChanged: (record, remarks) {
//                 context
//                     .read<AttendanceProvider>()
//                     .adminUpdateHistoryRecord(record,
//                     newRemarks: remarks);
//               },
//             ),
//           ),
//         ],
//       );
//     });
//   }
//
//   // ---- Person picker: search bar + tappable list ----
//   Widget _buildPersonPicker(List<StaffMember> allStaff) {
//     final filtered = _search.isEmpty
//         ? allStaff
//         : allStaff
//         .where((s) =>
//         s.name.toLowerCase().contains(_search.toLowerCase()))
//         .toList();
//
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: _kCard,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _kBorder),
//             ),
//             child: TextField(
//               onChanged: (val) => setState(() => _search = val),
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Search teacher or staff by name',
//                 hintStyle: TextStyle(fontSize: 13.5, color: _kSlate),
//                 prefixIcon: Icon(Icons.search, size: 20, color: _kSlate),
//               ),
//               style: const TextStyle(fontSize: 13.5, color: _kInk),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Expanded(
//           child: filtered.isEmpty
//               ? const _EmptyState(message: 'No matching teacher/staff found.')
//               : ListView.separated(
//             padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
//             itemCount: filtered.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 8),
//             itemBuilder: (ctx, index) {
//               final staff = filtered[index];
//               return _buildStaffTile(staff);
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStaffTile(StaffMember staff) {
//     final subtitle = _subtitle(staff.designation, staff.type);
//
//     return InkWell(
//       borderRadius: BorderRadius.circular(10),
//       onTap: () {
//         setState(() {
//           _selectedStaff = staff;
//           _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
//         });
//         _load();
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: _kCard,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: _kBorder),
//         ),
//         child: Row(
//           children: [
//             _buildAvatar(staff.imageBase64, staff.name, size: 40),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(staff.name,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14.5,
//                           color: _kInk)),
//                   const SizedBox(height: 2),
//                   Text(subtitle,
//                       style:
//                       const TextStyle(fontSize: 12, color: _kSlate)),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right, color: _kSlate),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSelectedPersonHeader() {
//     final staff = _selectedStaff!;
//     final subtitle = _subtitle(staff.designation, staff.type);
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Row(
//         children: [
//           _buildAvatar(staff.imageBase64, staff.name, size: 40),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(staff.name,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14.5,
//                         color: _kInk)),
//                 const SizedBox(height: 2),
//                 Text(subtitle,
//                     style: const TextStyle(fontSize: 12, color: _kSlate)),
//               ],
//             ),
//           ),
//           TextButton.icon(
//             onPressed: () => setState(() => _selectedStaff = null),
//             icon: const Icon(Icons.swap_horiz, size: 16, color: _kPrimary),
//             label: const Text('Change',
//                 style: TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w600,
//                     color: _kPrimary)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMonthSwitcher() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             onPressed: () => _changeMonth(-1),
//             icon: const Icon(Icons.chevron_left, color: _kSlate),
//           ),
//           Text(
//             DateFormat('MMMM yyyy').format(_selectedMonth),
//             style: const TextStyle(
//                 fontSize: 14, fontWeight: FontWeight.w700, color: _kInk),
//           ),
//           IconButton(
//             onPressed: DateTime(_selectedMonth.year, _selectedMonth.month)
//                 .isBefore(DateTime(DateTime.now().year, DateTime.now().month))
//                 ? () => _changeMonth(1)
//                 : null,
//             icon: const Icon(Icons.chevron_right, color: _kSlate),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAvatar(String? base64, String name, {double size = 32}) {
//     ImageProvider? image;
//     if (base64 != null && base64.isNotEmpty) {
//       try {
//         image = MemoryImage(base64Decode(base64));
//       } catch (_) {
//         image = null;
//       }
//     }
//     return CircleAvatar(
//       radius: size / 2,
//       backgroundColor: _kPrimaryLight,
//       backgroundImage: image,
//       child: image == null
//           ? Text(
//         name.isNotEmpty ? name[0].toUpperCase() : '?',
//         style: TextStyle(
//             fontSize: size * 0.4,
//             fontWeight: FontWeight.w700,
//             color: _kPrimary),
//       )
//           : null,
//     );
//   }
// }
//
// String _subtitle(String? designation, String type) {
//   if (designation != null && designation.trim().isNotEmpty) return designation;
//   return type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff';
// }
//
// // ============================================================
// // TABLE — shared by both tabs. Columns: [Name or Date] | Status |
// // Remarks | Designation/Type. Dense rows so max data fits on screen.
// // On narrow screens it becomes horizontally scrollable so nothing
// // gets clipped/squeezed unreadably.
// // ============================================================
// class _AttendanceTable extends StatelessWidget {
//   final bool isDesktop;
//   final bool isAdmin;
//   final String rowLabelHeader;
//   final List<AttendanceRecord> rows;
//   final Widget Function(AttendanceRecord) rowLabelBuilder;
//   final String Function(AttendanceRecord) subLabelBuilder;
//   final void Function(AttendanceRecord, String) onStatusChanged;
//   final void Function(AttendanceRecord, String) onRemarksChanged;
//
//   const _AttendanceTable({
//     required this.isDesktop,
//     required this.isAdmin,
//     required this.rowLabelHeader,
//     required this.rows,
//     required this.rowLabelBuilder,
//     required this.subLabelBuilder,
//     required this.onStatusChanged,
//     required this.onRemarksChanged,
//   });
//
//   static const double _nameColWidth = 220;
//   static const double _statusColWidth = 190;
//   static const double _remarksColWidth = 220;
//   static const double _typeColWidth = 130;
//
//   @override
//   Widget build(BuildContext context) {
//     final totalWidth =
//         _nameColWidth + _statusColWidth + _remarksColWidth + _typeColWidth;
//
//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//           isDesktop ? 28 : 16, 4, isDesktop ? 28 : 16, 20),
//       child: Container(
//         decoration: BoxDecoration(
//           color: _kCard,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _kBorder),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minWidth: totalWidth),
//             child: SizedBox(
//               width: isDesktop ? null : totalWidth,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildHeaderRow(),
//                   ...List.generate(rows.length, (i) {
//                     final record = rows[i];
//                     return _TableRow(
//                       record: record,
//                       isAdmin: isAdmin,
//                       isEven: i.isEven,
//                       nameColWidth: _nameColWidth,
//                       statusColWidth: _statusColWidth,
//                       remarksColWidth: _remarksColWidth,
//                       typeColWidth: _typeColWidth,
//                       rowLabel: rowLabelBuilder(record),
//                       subLabel: subLabelBuilder(record),
//                       onStatusChanged: (s) => onStatusChanged(record, s),
//                       onRemarksChanged: (r) => onRemarksChanged(record, r),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderRow() {
//     Widget cell(String text, double width, {TextAlign align = TextAlign.left}) {
//       return SizedBox(
//         width: width,
//         child: Text(
//           text,
//           textAlign: align,
//           style: const TextStyle(
//               fontSize: 11.5,
//               fontWeight: FontWeight.w700,
//               color: _kSlate,
//               letterSpacing: 0.3),
//         ),
//       );
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: const BoxDecoration(
//         color: _kSurface,
//         border: Border(bottom: BorderSide(color: _kBorder)),
//       ),
//       child: Row(
//         children: [
//           cell(rowLabelHeader.toUpperCase(), _nameColWidth),
//           cell('STATUS', _statusColWidth),
//           cell('REMARKS', _remarksColWidth),
//           cell('DESIGNATION/TYPE', _typeColWidth),
//         ],
//       ),
//     );
//   }
// }
//
// class _TableRow extends StatefulWidget {
//   final AttendanceRecord record;
//   final bool isAdmin;
//   final bool isEven;
//   final double nameColWidth;
//   final double statusColWidth;
//   final double remarksColWidth;
//   final double typeColWidth;
//   final Widget rowLabel;
//   final String subLabel;
//   final ValueChanged<String> onStatusChanged;
//   final ValueChanged<String> onRemarksChanged;
//
//   const _TableRow({
//     required this.record,
//     required this.isAdmin,
//     required this.isEven,
//     required this.nameColWidth,
//     required this.statusColWidth,
//     required this.remarksColWidth,
//     required this.typeColWidth,
//     required this.rowLabel,
//     required this.subLabel,
//     required this.onStatusChanged,
//     required this.onRemarksChanged,
//   });
//
//   @override
//   State<_TableRow> createState() => _TableRowState();
// }
//
// class _TableRowState extends State<_TableRow> {
//   late final TextEditingController _remarksController;
//
//   @override
//   void initState() {
//     super.initState();
//     _remarksController = TextEditingController(text: widget.record.remarks);
//   }
//
//   @override
//   void didUpdateWidget(covariant _TableRow oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.record.id != widget.record.id) {
//       _remarksController.text = widget.record.remarks;
//     }
//   }
//
//   @override
//   void dispose() {
//     _remarksController.dispose();
//     super.dispose();
//   }
//
//   void _notifyLocked() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Only an admin can edit attendance records.'),
//         backgroundColor: _kOrange,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final record = widget.record;
//     final locked = !widget.isAdmin;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: widget.isEven ? _kCard : _kSurface.withOpacity(0.5),
//         border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: widget.nameColWidth,
//             child: Row(
//               children: [
//                 Expanded(child: widget.rowLabel),
//                 if (record.isSaving)
//                   const Padding(
//                     padding: EdgeInsets.only(left: 6),
//                     child: SizedBox(
//                       width: 13,
//                       height: 13,
//                       child: CircularProgressIndicator(
//                           strokeWidth: 2, color: _kPrimary),
//                     ),
//                   )
//                 else if (record.isSaved)
//                   const Padding(
//                     padding: EdgeInsets.only(left: 6),
//                     child: Icon(Icons.check_circle, size: 15, color: _kGreen),
//                   ),
//               ],
//             ),
//           ),
//           SizedBox(
//             width: widget.statusColWidth,
//             child: _StatusDropdown(
//               status: record.status,
//               locked: locked,
//               onChanged: (s) {
//                 if (locked) {
//                   _notifyLocked();
//                   return;
//                 }
//                 widget.onStatusChanged(s);
//               },
//             ),
//           ),
//           SizedBox(
//             width: widget.remarksColWidth,
//             child: _buildRemarksField(locked),
//           ),
//           SizedBox(
//             width: widget.typeColWidth,
//             child: Text(
//               widget.subLabel,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontSize: 12, color: _kSlate),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRemarksField(bool locked) {
//     final field = TextField(
//       controller: _remarksController,
//       onChanged: locked ? null : widget.onRemarksChanged,
//       readOnly: locked,
//       maxLines: 1,
//       style: TextStyle(fontSize: 12.5, color: locked ? _kSlate : _kInk),
//       decoration: InputDecoration(
//         hintText: 'Add remarks',
//         hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
//         isDense: true,
//         filled: true,
//         fillColor: locked ? _kBorder.withOpacity(0.3) : _kSurface,
//         contentPadding:
//         const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: const BorderSide(color: _kBorder)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: const BorderSide(color: _kBorder)),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: const BorderSide(color: _kPrimary, width: 1.4)),
//       ),
//     );
//
//     if (!locked) return field;
//
//     return GestureDetector(
//       onTap: _notifyLocked,
//       behavior: HitTestBehavior.opaque,
//       child: AbsorbPointer(child: field),
//     );
//   }
// }
//
// // Compact status control for the table — tapping opens a small popup
// // menu instead of showing 5 full buttons per row (keeps rows dense so
// // more records fit on screen, per your request).
// class _StatusDropdown extends StatelessWidget {
//   final String status;
//   final bool locked;
//   final ValueChanged<String> onChanged;
//
//   const _StatusDropdown({
//     required this.status,
//     required this.locked,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final meta = _statusMeta(status);
//     final color = meta['color'] as Color;
//     final bg = meta['bg'] as Color;
//     final icon = meta['icon'] as IconData;
//     final label = meta['label'] as String;
//
//     return PopupMenuButton<String>(
//       enabled: !locked,
//       onSelected: onChanged,
//       itemBuilder: (context) => _kStatuses.map((s) {
//         final key = s['key'] as String;
//         return PopupMenuItem<String>(
//           value: key,
//           child: Row(
//             children: [
//               Icon(s['icon'] as IconData,
//                   size: 16, color: s['color'] as Color),
//               const SizedBox(width: 8),
//               Text(s['label'] as String,
//                   style: const TextStyle(fontSize: 13, color: _kInk)),
//             ],
//           ),
//         );
//       }).toList(),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//         decoration: BoxDecoration(
//           color: locked ? bg.withOpacity(0.5) : bg,
//           borderRadius: BorderRadius.circular(7),
//           border: Border.all(color: locked ? color.withOpacity(0.3) : color.withOpacity(0.4)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 15, color: locked ? color.withOpacity(0.6) : color),
//             const SizedBox(width: 6),
//             Text(label,
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: locked ? color.withOpacity(0.6) : color)),
//             if (!locked) ...[
//               const SizedBox(width: 4),
//               Icon(Icons.arrow_drop_down, size: 16, color: color.withOpacity(0.7)),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // "By Date" tab's row label — avatar + name (used inside the table row).
// class _NameCell extends StatelessWidget {
//   final AttendanceRecord record;
//   const _NameCell({required this.record});
//
//   @override
//   Widget build(BuildContext context) {
//     ImageProvider? image;
//     if (record.photoBase64 != null && record.photoBase64!.isNotEmpty) {
//       try {
//         image = MemoryImage(base64Decode(record.photoBase64!));
//       } catch (_) {
//         image = null;
//       }
//     }
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 14,
//           backgroundColor: _kPrimaryLight,
//           backgroundImage: image,
//           child: image == null
//               ? Text(
//             record.staffName.isNotEmpty
//                 ? record.staffName[0].toUpperCase()
//                 : '?',
//             style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: _kPrimary),
//           )
//               : null,
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             record.staffName,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//                 fontSize: 13, fontWeight: FontWeight.w600, color: _kInk),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // "By Person" tab's row label — date badge + weekday (used inside the
// // table row).
// class _DateCell extends StatelessWidget {
//   final AttendanceRecord record;
//   const _DateCell({required this.record});
//
//   @override
//   Widget build(BuildContext context) {
//     DateTime? parsed;
//     try {
//       parsed = DateTime.parse(record.date);
//     } catch (_) {}
//
//     return Text(
//       parsed != null
//           ? DateFormat('EEE, dd MMM yyyy').format(parsed)
//           : record.date,
//       overflow: TextOverflow.ellipsis,
//       style: const TextStyle(
//           fontSize: 13, fontWeight: FontWeight.w600, color: _kInk),
//     );
//   }
// }
//
// // ============================================================
// // Simple empty-state used by both tabs.
// // ============================================================
// class _EmptyState extends StatelessWidget {
//   final String message;
//   const _EmptyState({required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.event_busy_outlined,
//                 size: 44, color: Colors.grey.shade300),
//             const SizedBox(height: 12),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//


//2nd code
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import '../../models/teacher.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/teacher_provider.dart';
// import '../../providers/attendance_provider.dart';
// import '../../models/attendance_model.dart';
//
// // ============================================================
// // DESIGN TOKENS
// // ============================================================
// const _kInk = Color(0xFF1F2937);
// const _kSlate = Color(0xFF64748B);
// const _kBorder = Color(0xFFE2E8F0);
// const _kSurface = Color(0xFFF8FAFC);
// const _kCard = Colors.white;
//
// const _kPrimary = Color(0xFF1E3A8A);
// const _kPrimaryLight = Color(0xFFEFF4FF);
//
// const _kGreen = Color(0xFF166534);
// const _kGreenBg = Color(0xFFEFFCF3);
// const _kRed = Color(0xFFB91C1C);
// const _kRedBg = Color(0xFFFEF2F2);
// const _kOrange = Color(0xFFB45309);
// const _kOrangeBg = Color(0xFFFFFBEB);
// const _kBlue = Color(0xFF1D4ED8);
// const _kBlueBg = Color(0xFFEFF6FF);
// const _kPurple = Color(0xFF6D28D9);
// const _kPurpleBg = Color(0xFFF5F3FF);
//
// const List<Map<String, Object>> _kStatuses = [
//   {'key': 'present', 'label': 'Present', 'icon': Icons.check_circle_rounded, 'color': _kGreen, 'bg': _kGreenBg},
//   {'key': 'absent', 'label': 'Absent', 'icon': Icons.cancel_rounded, 'color': _kRed, 'bg': _kRedBg},
//   {'key': 'late', 'label': 'Late', 'icon': Icons.schedule_rounded, 'color': _kOrange, 'bg': _kOrangeBg},
//   {'key': 'leave', 'label': 'Leave', 'icon': Icons.beach_access_rounded, 'color': _kBlue, 'bg': _kBlueBg},
//   {'key': 'half_day', 'label': 'Half Day', 'icon': Icons.hourglass_bottom_rounded, 'color': _kPurple, 'bg': _kPurpleBg},
// ];
//
// Map<String, Object> _statusMeta(String key) {
//   return _kStatuses.firstWhere((s) => s['key'] == key,
//       orElse: () => _kStatuses[0]);
// }
//
// const double _kDesktopBreakpoint = 900;
//
// // ============================================================
// // ROOT SCREEN
// // ============================================================
// class AttendanceHistoryScreen extends StatefulWidget {
//   const AttendanceHistoryScreen({super.key});
//
//   @override
//   State<AttendanceHistoryScreen> createState() =>
//       _AttendanceHistoryScreenState();
// }
//
// class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isAdmin = context.watch<AuthProvider>().role == 'admin';
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         titleSpacing: 20,
//         title: const Text(
//           'Attendance History',
//           style: TextStyle(
//               fontWeight: FontWeight.w700, fontSize: 17, color: _kInk),
//         ),
//         backgroundColor: _kCard,
//         surfaceTintColor: _kCard,
//         foregroundColor: _kInk,
//         elevation: 0,
//         shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: _kPrimary,
//           unselectedLabelColor: _kSlate,
//           indicatorColor: _kPrimary,
//           indicatorWeight: 2.5,
//           labelStyle:
//           const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
//           unselectedLabelStyle:
//           const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
//           tabs: const [
//             Tab(text: 'By Date'),
//             Tab(text: 'By Person'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _ByDateTab(isAdmin: isAdmin),
//           _ByPersonTab(isAdmin: isAdmin),
//         ],
//       ),
//     );
//   }
// }
//
// // ============================================================
// // SHARED WIDGETS
// // ============================================================
// class _ViewOnlyBanner extends StatelessWidget {
//   const _ViewOnlyBanner();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: _kBlueBg,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: _kBlue.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: const [
//           Icon(Icons.info_outline, size: 16, color: _kBlue),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'View only. Only an admin can edit attendance records.',
//               style: TextStyle(fontSize: 12.5, color: _kBlue, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _ErrorState extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _ErrorState({required this.message, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline_rounded, size: 44, color: _kRed),
//             const SizedBox(height: 12),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 12.5, color: _kSlate),
//             ),
//             const SizedBox(height: 14),
//             OutlinedButton.icon(
//               onPressed: onRetry,
//               icon: const Icon(Icons.refresh, size: 16),
//               label: const Text('Retry'),
//               style: OutlinedButton.styleFrom(foregroundColor: _kPrimary),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _EmptyState extends StatelessWidget {
//   final String message;
//   const _EmptyState({required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.event_busy_outlined, size: 44, color: Colors.grey.shade300),
//             const SizedBox(height: 12),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// Widget _buildAvatar(String? base64, String name, {double size = 32}) {
//   ImageProvider? image;
//   if (base64 != null && base64.isNotEmpty) {
//     try {
//       image = MemoryImage(base64Decode(base64));
//     } catch (_) {
//       image = null;
//     }
//   }
//   return CircleAvatar(
//     radius: size / 2,
//     backgroundColor: _kPrimaryLight,
//     backgroundImage: image,
//     child: image == null
//         ? Text(
//       name.isNotEmpty ? name[0].toUpperCase() : '?',
//       style: TextStyle(
//           fontSize: size * 0.4,
//           fontWeight: FontWeight.w700,
//           color: _kPrimary),
//     )
//         : null,
//   );
// }
//
// String _subtitle(String? designation, String type) {
//   if (designation != null && designation.trim().isNotEmpty) return designation;
//   return type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff';
// }
//
// // ============================================================
// // TAB 1 — BY DATE (Checkbox + Locked edit)
// // ============================================================
// class _ByDateTab extends StatefulWidget {
//   final bool isAdmin;
//   const _ByDateTab({required this.isAdmin});
//
//   @override
//   State<_ByDateTab> createState() => _ByDateTabState();
// }
//
// class _ByDateTabState extends State<_ByDateTab> {
//   DateTime _selectedDate = DateTime.now();
//   String _filterType = 'all';
//   // ★ NEW: Track selected rows for batch update
//   final Map<String, bool> _selectedRows = {};
//
//   String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _load());
//   }
//
//   void _load() {
//     context.read<AttendanceProvider>().loadHistoryForDate(
//       _dateStr,
//       typeFilter: _filterType,
//     );
//   }
//
//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//                 primary: _kPrimary, onPrimary: Colors.white, onSurface: _kInk),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         _selectedRows.clear();
//       });
//       _load();
//     }
//   }
//
//   void _toggleSelection(String id, bool value) {
//     setState(() {
//       _selectedRows[id] = value;
//     });
//   }
//
//   Future<void> _updateSelected() async {
//     final selectedIds = _selectedRows.entries
//         .where((e) => e.value)
//         .map((e) => e.key)
//         .toList();
//
//     if (selectedIds.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No rows selected to update.')),
//       );
//       return;
//     }
//
//     final provider = context.read<AttendanceProvider>();
//     for (final id in selectedIds) {
//       final record = provider.historyRecords.firstWhere((r) => r.id == id);
//       await provider.adminUpdateHistoryRecord(record);
//     }
//
//     setState(() {
//       _selectedRows.clear();
//     });
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Updated ${selectedIds.length} record(s).')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AttendanceProvider>();
//
//     return LayoutBuilder(builder: (context, constraints) {
//       final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//       return Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.fromLTRB(
//                 isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 0),
//             child: _buildToolbar(isDesktop),
//           ),
//           if (!widget.isAdmin) const _ViewOnlyBanner(),
//           const SizedBox(height: 10),
//           Expanded(
//             child: provider.historyLoading
//                 ? const Center(
//                 child: CircularProgressIndicator(
//                     color: _kPrimary, strokeWidth: 2.5))
//                 : provider.historyError != null
//                 ? _ErrorState(
//                 message: provider.historyError!, onRetry: _load)
//                 : provider.historyRecords.isEmpty
//                 ? const _EmptyState(
//                 message: 'No teachers/staff found for this filter.')
//                 : _AttendanceTable(
//               isDesktop: isDesktop,
//               isAdmin: widget.isAdmin,
//               selectedRows: _selectedRows,
//               onToggleSelection: _toggleSelection,
//               rowLabelHeader: 'Name',
//               rows: provider.historyRecords,
//               rowLabelBuilder: (r) => _NameCell(record: r),
//               subLabelBuilder: (r) =>
//                   _subtitle(r.designation, r.type),
//               onStatusChanged: (record, status) {
//                 context
//                     .read<AttendanceProvider>()
//                     .adminUpdateHistoryRecord(record,
//                     newStatus: status);
//               },
//               onRemarksChanged: (record, remarks) {
//                 context
//                     .read<AttendanceProvider>()
//                     .adminUpdateHistoryRecord(record,
//                     newRemarks: remarks);
//               },
//             ),
//           ),
//         ],
//       );
//     });
//   }
//
//   Widget _buildToolbar(bool isDesktop) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: isDesktop
//           ? Row(
//         children: [
//           _buildDateChip(),
//           const SizedBox(width: 12),
//           _buildTypeFilter(),
//           const Spacer(),
//           _buildUpdateButton(),
//         ],
//       )
//           : Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildDateChip(),
//           const SizedBox(height: 10),
//           _buildTypeFilter(),
//           const SizedBox(height: 10),
//           _buildUpdateButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDateChip() {
//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: _pickDate,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: _kSurface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: _kBorder),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.calendar_today_outlined,
//                 size: 16, color: _kSlate),
//             const SizedBox(width: 10),
//             Text(
//               DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
//               style: const TextStyle(
//                   fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk),
//             ),
//             const SizedBox(width: 6),
//             const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTypeFilter() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: _kSurface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: _kBorder),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _filterType,
//           isDense: true,
//           items: const [
//             DropdownMenuItem(value: 'all', child: Text('All (Teachers + Staff)', style: TextStyle(fontSize: 13, color: _kInk))),
//             DropdownMenuItem(value: 'teacher', child: Text('Teachers Only', style: TextStyle(fontSize: 13, color: _kInk))),
//             DropdownMenuItem(value: 'staff', child: Text('Staff Only', style: TextStyle(fontSize: 13, color: _kInk))),
//           ],
//           onChanged: (val) {
//             if (val == null) return;
//             setState(() {
//               _filterType = val;
//               _selectedRows.clear();
//             });
//             _load();
//           },
//           icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//           style: const TextStyle(fontSize: 13, color: _kInk),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUpdateButton() {
//     return ElevatedButton.icon(
//       onPressed: _updateSelected,
//       icon: const Icon(Icons.save, size: 16),
//       label: const Text('Update Selected', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _kPrimary,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         elevation: 0,
//       ),
//     );
//   }
// }
//
// // ============================================================
// // TAB 2 — BY PERSON (Enhanced Report)
// // ============================================================
// class _ByPersonTab extends StatefulWidget {
//   final bool isAdmin;
//   const _ByPersonTab({required this.isAdmin});
//
//   @override
//   State<_ByPersonTab> createState() => _ByPersonTabState();
// }
//
// class _ByPersonTabState extends State<_ByPersonTab> {
//   StaffMember? _selectedStaff;
//   int _selectedYear = DateTime.now().year;
//   int _selectedMonth = DateTime.now().month;
//   String _search = '';
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final staffProvider = context.read<StaffProvider>();
//       if (staffProvider.teachers.isEmpty && staffProvider.staffOnly.isEmpty) {
//         staffProvider.fetchTeachers();
//         staffProvider.fetchStaffOnly();
//       }
//     });
//   }
//
//   void _load() {
//     if (_selectedStaff == null) return;
//     context.read<AttendanceProvider>().loadHistoryForPerson(
//       staffId: _selectedStaff!.id!,
//       year: _selectedYear,
//       month: _selectedMonth,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final staffProvider = context.watch<StaffProvider>();
//     final allStaff = [...staffProvider.teachers, ...staffProvider.staffOnly];
//
//     if (_selectedStaff == null) {
//       return _buildPersonPicker(allStaff);
//     }
//
//     final provider = context.watch<AttendanceProvider>();
//
//     return LayoutBuilder(builder: (context, constraints) {
//       final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//       return SingleChildScrollView(
//         padding: EdgeInsets.fromLTRB(
//             isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildProfileHeader(isDesktop),
//             const SizedBox(height: 14),
//             _buildFilterRow(isDesktop),
//             const SizedBox(height: 14),
//             if (!widget.isAdmin) const _ViewOnlyBanner(),
//             const SizedBox(height: 10),
//             if (provider.historyLoading)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 60),
//                 child: Center(
//                   child: CircularProgressIndicator(
//                       color: _kPrimary, strokeWidth: 2.5),
//                 ),
//               )
//             else if (provider.historyError != null)
//               _ErrorState(message: provider.historyError!, onRetry: _load)
//             else if (provider.historyRecords.isEmpty)
//                 const _EmptyState(
//                     message: 'No attendance records for this month yet.')
//               else ...[
//                   _buildSummaryCards(provider, isDesktop),
//                   const SizedBox(height: 16),
//                   const _StatusLegend(),
//                   const SizedBox(height: 10),
//                   _buildReportTable(provider, isDesktop),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Showing 1 to ${provider.historyRecords.length} of ${provider.historyRecords.length} entries',
//                     style: const TextStyle(fontSize: 12, color: _kSlate),
//                   ),
//                 ],
//           ],
//         ),
//       );
//     });
//   }
//
//   // ---- Person picker ----
//   Widget _buildPersonPicker(List<StaffMember> allStaff) {
//     final filtered = _search.isEmpty
//         ? allStaff
//         : allStaff
//         .where((s) => s.name.toLowerCase().contains(_search.toLowerCase()))
//         .toList();
//
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: _kCard,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _kBorder),
//             ),
//             child: TextField(
//               onChanged: (val) => setState(() => _search = val),
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Search teacher or staff by name',
//                 hintStyle: TextStyle(fontSize: 13.5, color: _kSlate),
//                 prefixIcon: Icon(Icons.search, size: 20, color: _kSlate),
//               ),
//               style: const TextStyle(fontSize: 13.5, color: _kInk),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Expanded(
//           child: filtered.isEmpty
//               ? const _EmptyState(message: 'No matching teacher/staff found.')
//               : ListView.separated(
//             padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
//             itemCount: filtered.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 8),
//             itemBuilder: (ctx, index) => _buildStaffTile(filtered[index]),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStaffTile(StaffMember staff) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(10),
//       onTap: () {
//         setState(() {
//           _selectedStaff = staff;
//           _selectedYear = DateTime.now().year;
//           _selectedMonth = DateTime.now().month;
//         });
//         _load();
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: _kCard,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: _kBorder),
//         ),
//         child: Row(
//           children: [
//             _buildAvatar(staff.imageBase64, staff.name, size: 40),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(staff.name,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14.5,
//                           color: _kInk)),
//                   const SizedBox(height: 2),
//                   Text(_subtitle(staff.designation, staff.type),
//                       style: const TextStyle(fontSize: 12, color: _kSlate)),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right, color: _kSlate),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ---- Enhanced Report Header ----
//   Widget _buildProfileHeader(bool isDesktop) {
//     final staff = _selectedStaff!;
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [_kPrimary, Color(0xFF3B5BC7)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(3),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//             ),
//             child: _buildAvatar(staff.imageBase64, staff.name, size: 56),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(staff.name,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 18,
//                         color: Colors.white)),
//                 const SizedBox(height: 4),
//                 Wrap(
//                   spacing: 10,
//                   runSpacing: 4,
//                   children: [
//                     if (staff.designation != null &&
//                         staff.designation!.trim().isNotEmpty)
//                       _headerChip(staff.designation!),
//                     _headerChip(
//                         staff.type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff'),
//                     if (staff.id != null) _headerChip('ID: ${staff.id}'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           TextButton.icon(
//             onPressed: () => setState(() => _selectedStaff = null),
//             icon: const Icon(Icons.swap_horiz, size: 16, color: Colors.white),
//             label: const Text('Change',
//                 style: TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white)),
//             style: TextButton.styleFrom(
//               backgroundColor: Colors.white.withOpacity(0.15),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _headerChip(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.18),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(text,
//           style: const TextStyle(
//               fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
//     );
//   }
//
//   // ---- Month/Year Filter ----
//   Widget _buildFilterRow(bool isDesktop) {
//     final months = List.generate(12, (i) => i + 1);
//     final currentYear = DateTime.now().year;
//     final years = List.generate(6, (i) => currentYear - i);
//
//     final monthDropdown = _dropdown<int>(
//       value: _selectedMonth,
//       items: months
//           .map((m) => DropdownMenuItem(
//           value: m,
//           child: Text(DateFormat('MMMM').format(DateTime(0, m)),
//               style: const TextStyle(fontSize: 13, color: _kInk))))
//           .toList(),
//       onChanged: (val) {
//         if (val == null) return;
//         setState(() => _selectedMonth = val);
//         _load();
//       },
//       icon: Icons.calendar_month_outlined,
//     );
//
//     final yearDropdown = _dropdown<int>(
//       value: _selectedYear,
//       items: years
//           .map((y) => DropdownMenuItem(
//           value: y,
//           child: Text('$y', style: const TextStyle(fontSize: 13, color: _kInk))))
//           .toList(),
//       onChanged: (val) {
//         if (val == null) return;
//         setState(() => _selectedYear = val);
//         _load();
//       },
//       icon: Icons.event_outlined,
//     );
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: isDesktop
//           ? Row(children: [monthDropdown, const SizedBox(width: 10), yearDropdown])
//           : Row(
//         children: [
//           Expanded(child: monthDropdown),
//           const SizedBox(width: 10),
//           Expanded(child: yearDropdown),
//         ],
//       ),
//     );
//   }
//
//   Widget _dropdown<T>({
//     required T value,
//     required List<DropdownMenuItem<T>> items,
//     required ValueChanged<T?> onChanged,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: _kSurface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: _kSlate),
//           const SizedBox(width: 8),
//           DropdownButtonHideUnderline(
//             child: DropdownButton<T>(
//               value: value,
//               isDense: true,
//               items: items,
//               onChanged: onChanged,
//               icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//               style: const TextStyle(fontSize: 13, color: _kInk),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---- Summary Cards ----
//   Widget _buildSummaryCards(AttendanceProvider provider, bool isDesktop) {
//     final summary = provider.monthSummary;
//     final total = summary['total'] ?? 0;
//     final present = summary['present'] ?? 0;
//     final absent = summary['absent'] ?? 0;
//     final leave = summary['leave'] ?? 0;
//     final late = summary['late'] ?? 0;
//     final halfDay = summary['half_day'] ?? 0;
//     final pct = total == 0 ? 0.0 : (present / total) * 100;
//
//     final cards = [
//       _SummaryCardData('Total Working Days', '$total', Icons.event_note_outlined, _kPrimary, _kPrimaryLight),
//       _SummaryCardData('Present Days', '$present', Icons.check_circle_outline, _kGreen, _kGreenBg),
//       _SummaryCardData('Absent Days', '$absent', Icons.cancel_outlined, _kRed, _kRedBg),
//       _SummaryCardData('Leave Days', '$leave', Icons.beach_access_outlined, _kBlue, _kBlueBg),
//       _SummaryCardData('Late Days', '$late', Icons.schedule_outlined, _kOrange, _kOrangeBg),
//       _SummaryCardData('Half Day', '$halfDay', Icons.hourglass_bottom_outlined, _kPurple, _kPurpleBg),
//       _SummaryCardData('Attendance %', '${pct.toStringAsFixed(1)}%', Icons.insights_outlined, _kPrimary, _kPrimaryLight),
//     ];
//
//     final columns = isDesktop ? 4 : 2;
//
//     return LayoutBuilder(builder: (context, constraints) {
//       const spacing = 10.0;
//       final cardWidth =
//           (constraints.maxWidth - spacing * (columns - 1)) / columns;
//       return Wrap(
//         spacing: spacing,
//         runSpacing: spacing,
//         children: cards
//             .map((c) => SizedBox(width: cardWidth, child: _SummaryCard(data: c)))
//             .toList(),
//       );
//     });
//   }
//
//   // ---- Report Table ----
//   Widget _buildReportTable(AttendanceProvider provider, bool isDesktop) {
//     final rows = [...provider.historyRecords]
//       ..sort((a, b) => a.date.compareTo(b.date));
//
//     const dateColWidth = 130.0;
//     const dayColWidth = 100.0;
//     const statusColWidth = 110.0;
//     const remarksColWidth = 220.0;
//     final totalWidth = dateColWidth + dayColWidth + statusColWidth + remarksColWidth;
//
//     Widget headerCell(String text, double width) => SizedBox(
//       width: width,
//       child: Text(text,
//           style: const TextStyle(
//               fontSize: 11.5,
//               fontWeight: FontWeight.w700,
//               color: _kSlate,
//               letterSpacing: 0.3)),
//     );
//
//     return Container(
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kBorder),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(minWidth: totalWidth),
//           child: SizedBox(
//             width: isDesktop ? null : totalWidth,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                   decoration: const BoxDecoration(
//                     color: _kSurface,
//                     border: Border(bottom: BorderSide(color: _kBorder)),
//                   ),
//                   child: Row(
//                     children: [
//                       headerCell('DATE', dateColWidth),
//                       headerCell('DAY', dayColWidth),
//                       headerCell('STATUS', statusColWidth),
//                       headerCell('REMARKS', remarksColWidth),
//                     ],
//                   ),
//                 ),
//                 ...List.generate(rows.length, (i) {
//                   final record = rows[i];
//                   DateTime? parsed;
//                   try {
//                     parsed = DateTime.parse(record.date);
//                   } catch (_) {}
//                   final meta = _statusMeta(record.status);
//
//                   return Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: i.isEven ? _kCard : _kSurface.withOpacity(0.5),
//                       border: const Border(
//                           bottom: BorderSide(color: _kBorder, width: 0.6)),
//                     ),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           width: dateColWidth,
//                           child: Text(
//                             parsed != null
//                                 ? DateFormat('dd MMM yyyy').format(parsed)
//                                 : record.date,
//                             style: const TextStyle(
//                                 fontSize: 12.5,
//                                 fontWeight: FontWeight.w600,
//                                 color: _kInk),
//                           ),
//                         ),
//                         SizedBox(
//                           width: dayColWidth,
//                           child: Text(
//                             parsed != null ? DateFormat('EEEE').format(parsed) : '-',
//                             style: const TextStyle(fontSize: 12, color: _kSlate),
//                           ),
//                         ),
//                         SizedBox(
//                           width: statusColWidth,
//                           child: _StatusBadge(meta: meta),
//                         ),
//                         SizedBox(
//                           width: remarksColWidth,
//                           child: Text(
//                             record.remarks.isEmpty ? '—' : record.remarks,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontSize: 12.5, color: _kInk),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // SHARED TABLE (For By Date Tab)
// // ============================================================
// class _AttendanceTable extends StatelessWidget {
//   final bool isDesktop;
//   final bool isAdmin;
//   final Map<String, bool> selectedRows;
//   final Function(String, bool) onToggleSelection;
//   final String rowLabelHeader;
//   final List<AttendanceRecord> rows;
//   final Widget Function(AttendanceRecord) rowLabelBuilder;
//   final String Function(AttendanceRecord) subLabelBuilder;
//   final void Function(AttendanceRecord, String) onStatusChanged;
//   final void Function(AttendanceRecord, String) onRemarksChanged;
//
//   const _AttendanceTable({
//     required this.isDesktop,
//     required this.isAdmin,
//     required this.selectedRows,
//     required this.onToggleSelection,
//     required this.rowLabelHeader,
//     required this.rows,
//     required this.rowLabelBuilder,
//     required this.subLabelBuilder,
//     required this.onStatusChanged,
//     required this.onRemarksChanged,
//   });
//
//   static const double _checkboxColWidth = 40;
//   static const double _nameColWidth = 180;
//   static const double _statusColWidth = 190;
//   static const double _remarksColWidth = 220;
//   static const double _typeColWidth = 130;
//
//   @override
//   Widget build(BuildContext context) {
//     final totalWidth =
//         _checkboxColWidth + _nameColWidth + _statusColWidth + _remarksColWidth + _typeColWidth;
//
//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//           isDesktop ? 28 : 16, 4, isDesktop ? 28 : 16, 20),
//       child: Container(
//         decoration: BoxDecoration(
//           color: _kCard,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _kBorder),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minWidth: totalWidth),
//             child: SizedBox(
//               width: isDesktop ? null : totalWidth,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildHeaderRow(),
//                   ...List.generate(rows.length, (i) {
//                     final record = rows[i];
//                     return _TableRow(
//                       record: record,
//                       isAdmin: isAdmin,
//                       isEven: i.isEven,
//                       isSelected: selectedRows[record.id] ?? false,
//                       onToggle: onToggleSelection,
//                       nameColWidth: _nameColWidth,
//                       statusColWidth: _statusColWidth,
//                       remarksColWidth: _remarksColWidth,
//                       typeColWidth: _typeColWidth,
//                       rowLabel: rowLabelBuilder(record),
//                       subLabel: subLabelBuilder(record),
//                       onStatusChanged: (s) => onStatusChanged(record, s),
//                       onRemarksChanged: (r) => onRemarksChanged(record, r),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderRow() {
//     Widget cell(String text, double width, {TextAlign align = TextAlign.left}) {
//       return SizedBox(
//         width: width,
//         child: Text(
//           text,
//           textAlign: align,
//           style: const TextStyle(
//               fontSize: 11.5,
//               fontWeight: FontWeight.w700,
//               color: _kSlate,
//               letterSpacing: 0.3),
//         ),
//       );
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: const BoxDecoration(
//         color: _kSurface,
//         border: Border(bottom: BorderSide(color: _kBorder)),
//       ),
//       child: Row(
//         children: [
//           cell('', _checkboxColWidth, align: TextAlign.center),
//           cell(rowLabelHeader.toUpperCase(), _nameColWidth),
//           cell('STATUS', _statusColWidth),
//           cell('REMARKS', _remarksColWidth),
//           cell('DESIGNATION/TYPE', _typeColWidth),
//         ],
//       ),
//     );
//   }
// }
//
// class _TableRow extends StatefulWidget {
//   final AttendanceRecord record;
//   final bool isAdmin;
//   final bool isEven;
//   final bool isSelected;
//   final Function(String, bool) onToggle;
//   final double nameColWidth;
//   final double statusColWidth;
//   final double remarksColWidth;
//   final double typeColWidth;
//   final Widget rowLabel;
//   final String subLabel;
//   final ValueChanged<String> onStatusChanged;
//   final ValueChanged<String> onRemarksChanged;
//
//   const _TableRow({
//     required this.record,
//     required this.isAdmin,
//     required this.isEven,
//     required this.isSelected,
//     required this.onToggle,
//     required this.nameColWidth,
//     required this.statusColWidth,
//     required this.remarksColWidth,
//     required this.typeColWidth,
//     required this.rowLabel,
//     required this.subLabel,
//     required this.onStatusChanged,
//     required this.onRemarksChanged,
//   });
//
//   @override
//   State<_TableRow> createState() => _TableRowState();
// }
//
// class _TableRowState extends State<_TableRow> {
//   late final TextEditingController _remarksController;
//
//   @override
//   void initState() {
//     super.initState();
//     _remarksController = TextEditingController(text: widget.record.remarks);
//   }
//
//   @override
//   void didUpdateWidget(covariant _TableRow oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.record.id != widget.record.id) {
//       _remarksController.text = widget.record.remarks;
//     }
//   }
//
//   @override
//   void dispose() {
//     _remarksController.dispose();
//     super.dispose();
//   }
//
//   void _notifyLocked() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Select the checkbox first to edit this record.'),
//         backgroundColor: _kOrange,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final record = widget.record;
//     final locked = !widget.isAdmin || !widget.isSelected;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: widget.isEven ? _kCard : _kSurface.withOpacity(0.5),
//         border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 40,
//             child: Checkbox(
//               value: widget.isSelected,
//               onChanged: (val) {
//                 widget.onToggle(widget.record.id, val ?? false);
//               },
//               activeColor: _kPrimary,
//             ),
//           ),
//           SizedBox(
//             width: widget.nameColWidth,
//             child: Row(
//               children: [
//                 Expanded(child: widget.rowLabel),
//                 if (record.isSaving)
//                   const Padding(
//                     padding: EdgeInsets.only(left: 6),
//                     child: SizedBox(
//                       width: 13,
//                       height: 13,
//                       child: CircularProgressIndicator(
//                           strokeWidth: 2, color: _kPrimary),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           SizedBox(
//             width: widget.statusColWidth,
//             child: _StatusDropdown(
//               status: record.status,
//               locked: locked,
//               onChanged: (s) {
//                 if (locked) {
//                   _notifyLocked();
//                   return;
//                 }
//                 widget.onStatusChanged(s);
//               },
//             ),
//           ),
//           SizedBox(
//             width: widget.remarksColWidth,
//             child: _buildRemarksField(locked),
//           ),
//           SizedBox(
//             width: widget.typeColWidth,
//             child: Text(
//               widget.subLabel,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontSize: 12, color: _kSlate),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRemarksField(bool locked) {
//     final field = TextField(
//       controller: _remarksController,
//       onChanged: locked ? null : widget.onRemarksChanged,
//       readOnly: locked,
//       maxLines: 1,
//       style: TextStyle(fontSize: 12.5, color: locked ? _kSlate : _kInk),
//       decoration: InputDecoration(
//         hintText: 'Add remarks',
//         hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
//         isDense: true,
//         filled: true,
//         fillColor: locked ? _kBorder.withOpacity(0.3) : _kSurface,
//         contentPadding:
//         const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: const BorderSide(color: _kBorder)),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: const BorderSide(color: _kBorder)),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(6),
//             borderSide: const BorderSide(color: _kPrimary, width: 1.4)),
//       ),
//     );
//
//     if (!locked) return field;
//
//     return GestureDetector(
//       onTap: _notifyLocked,
//       behavior: HitTestBehavior.opaque,
//       child: AbsorbPointer(child: field),
//     );
//   }
// }
//
// class _StatusDropdown extends StatelessWidget {
//   final String status;
//   final bool locked;
//   final ValueChanged<String> onChanged;
//
//   const _StatusDropdown({
//     required this.status,
//     required this.locked,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final meta = _statusMeta(status);
//     final color = meta['color'] as Color;
//     final bg = meta['bg'] as Color;
//     final icon = meta['icon'] as IconData;
//     final label = meta['label'] as String;
//
//     return PopupMenuButton<String>(
//       enabled: !locked,
//       onSelected: onChanged,
//       itemBuilder: (context) => _kStatuses.map((s) {
//         final key = s['key'] as String;
//         return PopupMenuItem<String>(
//           value: key,
//           child: Row(
//             children: [
//               Icon(s['icon'] as IconData,
//                   size: 16, color: s['color'] as Color),
//               const SizedBox(width: 8),
//               Text(s['label'] as String,
//                   style: const TextStyle(fontSize: 13, color: _kInk)),
//             ],
//           ),
//         );
//       }).toList(),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//         decoration: BoxDecoration(
//           color: locked ? bg.withOpacity(0.5) : bg,
//           borderRadius: BorderRadius.circular(7),
//           border: Border.all(color: locked ? color.withOpacity(0.3) : color.withOpacity(0.4)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 15, color: locked ? color.withOpacity(0.6) : color),
//             const SizedBox(width: 6),
//             Text(label,
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: locked ? color.withOpacity(0.6) : color)),
//             if (!locked) ...[
//               const SizedBox(width: 4),
//               Icon(Icons.arrow_drop_down, size: 16, color: color.withOpacity(0.7)),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _NameCell extends StatelessWidget {
//   final AttendanceRecord record;
//   const _NameCell({required this.record});
//
//   @override
//   Widget build(BuildContext context) {
//     ImageProvider? image;
//     if (record.photoBase64 != null && record.photoBase64!.isNotEmpty) {
//       try {
//         image = MemoryImage(base64Decode(record.photoBase64!));
//       } catch (_) {
//         image = null;
//       }
//     }
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 14,
//           backgroundColor: _kPrimaryLight,
//           backgroundImage: image,
//           child: image == null
//               ? Text(
//             record.staffName.isNotEmpty
//                 ? record.staffName[0].toUpperCase()
//                 : '?',
//             style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: _kPrimary),
//           )
//               : null,
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             record.staffName,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//                 fontSize: 13, fontWeight: FontWeight.w600, color: _kInk),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ============================================================
// // ENHANCED REPORT COMPONENTS (By Person Tab)
// // ============================================================
// class _SummaryCardData {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;
//   final Color bg;
//   _SummaryCardData(this.label, this.value, this.icon, this.color, this.bg);
// }
//
// class _SummaryCard extends StatelessWidget {
//   final _SummaryCardData data;
//   const _SummaryCard({required this.data});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: data.bg,
//               borderRadius: BorderRadius.circular(9),
//             ),
//             child: Icon(data.icon, size: 18, color: data.color),
//           ),
//           const SizedBox(height: 10),
//           Text(data.value,
//               style: TextStyle(
//                   fontSize: 20, fontWeight: FontWeight.w800, color: data.color)),
//           const SizedBox(height: 2),
//           Text(data.label,
//               style: const TextStyle(fontSize: 11.5, color: _kSlate),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   final Map<String, Object> meta;
//   const _StatusBadge({required this.meta});
//
//   @override
//   Widget build(BuildContext context) {
//     final color = meta['color'] as Color;
//     final bg = meta['bg'] as Color;
//     final label = meta['label'] as String;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.35)),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
//       ),
//     );
//   }
// }
//
// class _StatusLegend extends StatelessWidget {
//   const _StatusLegend();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Wrap(
//         spacing: 16,
//         runSpacing: 8,
//         crossAxisAlignment: WrapCrossAlignment.center,
//         children: [
//           const Text('LEGEND',
//               style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   color: _kSlate,
//                   letterSpacing: 0.4)),
//           ..._kStatuses.map((s) {
//             final color = s['color'] as Color;
//             final bg = s['bg'] as Color;
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 22,
//                   height: 22,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: bg,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: color.withOpacity(0.5)),
//                   ),
//                   child: Text((s['label'] as String).substring(0, 1),
//                       style: TextStyle(
//                           fontSize: 9.5, fontWeight: FontWeight.w800, color: color)),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(s['label'] as String,
//                     style: const TextStyle(fontSize: 12, color: _kInk)),
//               ],
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }


//3rd code
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
// DESIGN TOKENS
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
// ROOT SCREEN
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
// TAB 1 — BY DATE (Checkbox + Locked edit + Dropdown Calendar)
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

  // ★ NEW: Dropdown calendar state
  final GlobalKey _dateChipKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  DateTime? _tempSelectedDate;

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

  // ★ NEW: Dropdown calendar toggle
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
            // Dimmed barrier
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
              selectedRows: _selectedRows,
              onToggleSelection: _toggleSelection,
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

  // ★ UPDATED: Uses a custom dropdown that expands below the button
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
            setState(() {
              _filterType = val;
              _selectedRows.clear();
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
}

// ============================================================
// TAB 2 — BY PERSON (Enhanced Report)
// ============================================================
class _ByPersonTab extends StatefulWidget {
  final bool isAdmin;
  const _ByPersonTab({required this.isAdmin});

  @override
  State<_ByPersonTab> createState() => _ByPersonTabState();
}

class _ByPersonTabState extends State<_ByPersonTab> {
  StaffMember? _selectedStaff;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
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
      year: _selectedYear,
      month: _selectedMonth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final allStaff = [...staffProvider.teachers, ...staffProvider.staffOnly];

    if (_selectedStaff == null) {
      return _buildPersonPicker(allStaff);
    }

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
                  const SizedBox(height: 16),
                  const _StatusLegend(),
                  const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, Color(0xFF3B5BC7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _buildAvatar(staff.imageBase64, staff.name, size: 56),
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
                        fontSize: 18,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    if (staff.designation != null &&
                        staff.designation!.trim().isNotEmpty)
                      _headerChip(staff.designation!),
                    _headerChip(
                        staff.type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff'),
                    if (staff.id != null) _headerChip('ID: ${staff.id}'),
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

  // ---- Month/Year Filter ----
  Widget _buildFilterRow(bool isDesktop) {
    final months = List.generate(12, (i) => i + 1);
    final currentYear = DateTime.now().year;
    final years = List.generate(6, (i) => currentYear - i);

    final monthDropdown = _dropdown<int>(
      value: _selectedMonth,
      items: months
          .map((m) => DropdownMenuItem(
          value: m,
          child: Text(DateFormat('MMMM').format(DateTime(0, m)),
              style: const TextStyle(fontSize: 13, color: _kInk))))
          .toList(),
      onChanged: (val) {
        if (val == null) return;
        setState(() => _selectedMonth = val);
        _load();
      },
      icon: Icons.calendar_month_outlined,
    );

    final yearDropdown = _dropdown<int>(
      value: _selectedYear,
      items: years
          .map((y) => DropdownMenuItem(
          value: y,
          child: Text('$y', style: const TextStyle(fontSize: 13, color: _kInk))))
          .toList(),
      onChanged: (val) {
        if (val == null) return;
        setState(() => _selectedYear = val);
        _load();
      },
      icon: Icons.event_outlined,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: isDesktop
          ? Row(children: [monthDropdown, const SizedBox(width: 10), yearDropdown])
          : Row(
        children: [
          Expanded(child: monthDropdown),
          const SizedBox(width: 10),
          Expanded(child: yearDropdown),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _kSlate),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              items: items,
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
              style: const TextStyle(fontSize: 13, color: _kInk),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Summary Cards ----
  Widget _buildSummaryCards(AttendanceProvider provider, bool isDesktop) {
    final summary = provider.monthSummary;
    final total = summary['total'] ?? 0;
    final present = summary['present'] ?? 0;
    final absent = summary['absent'] ?? 0;
    final leave = summary['leave'] ?? 0;
    final late = summary['late'] ?? 0;
    final halfDay = summary['half_day'] ?? 0;
    final pct = total == 0 ? 0.0 : (present / total) * 100;

    final cards = [
      _SummaryCardData('Total Working Days', '$total', Icons.event_note_outlined, _kPrimary, _kPrimaryLight),
      _SummaryCardData('Present Days', '$present', Icons.check_circle_outline, _kGreen, _kGreenBg),
      _SummaryCardData('Absent Days', '$absent', Icons.cancel_outlined, _kRed, _kRedBg),
      _SummaryCardData('Leave Days', '$leave', Icons.beach_access_outlined, _kBlue, _kBlueBg),
      _SummaryCardData('Late Days', '$late', Icons.schedule_outlined, _kOrange, _kOrangeBg),
      _SummaryCardData('Half Day', '$halfDay', Icons.hourglass_bottom_outlined, _kPurple, _kPurpleBg),
      _SummaryCardData('Attendance %', '${pct.toStringAsFixed(1)}%', Icons.insights_outlined, _kPrimary, _kPrimaryLight),
    ];

    final columns = isDesktop ? 4 : 2;

    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 10.0;
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

    const dateColWidth = 130.0;
    const dayColWidth = 100.0;
    const statusColWidth = 110.0;
    const remarksColWidth = 220.0;
    final totalWidth = dateColWidth + dayColWidth + statusColWidth + remarksColWidth;

    Widget headerCell(String text, double width) => SizedBox(
      width: width,
      child: Text(text,
          style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _kSlate,
              letterSpacing: 0.3)),
    );

    return Container(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: _kSurface,
                    border: Border(bottom: BorderSide(color: _kBorder)),
                  ),
                  child: Row(
                    children: [
                      headerCell('DATE', dateColWidth),
                      headerCell('DAY', dayColWidth),
                      headerCell('STATUS', statusColWidth),
                      headerCell('REMARKS', remarksColWidth),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: i.isEven ? _kCard : _kSurface.withOpacity(0.5),
                      border: const Border(
                          bottom: BorderSide(color: _kBorder, width: 0.6)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: dateColWidth,
                          child: Text(
                            parsed != null
                                ? DateFormat('dd MMM yyyy').format(parsed)
                                : record.date,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: _kInk),
                          ),
                        ),
                        SizedBox(
                          width: dayColWidth,
                          child: Text(
                            parsed != null ? DateFormat('EEEE').format(parsed) : '-',
                            style: const TextStyle(fontSize: 12, color: _kSlate),
                          ),
                        ),
                        SizedBox(
                          width: statusColWidth,
                          child: _StatusBadge(meta: meta),
                        ),
                        SizedBox(
                          width: remarksColWidth,
                          child: Text(
                            record.remarks.isEmpty ? '—' : record.remarks,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, color: _kInk),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SHARED TABLE (For By Date Tab)
// ============================================================
class _AttendanceTable extends StatelessWidget {
  final bool isDesktop;
  final bool isAdmin;
  final Map<String, bool> selectedRows;
  final Function(String, bool) onToggleSelection;
  final String rowLabelHeader;
  final List<AttendanceRecord> rows;
  final Widget Function(AttendanceRecord) rowLabelBuilder;
  final String Function(AttendanceRecord) subLabelBuilder;
  final void Function(AttendanceRecord, String) onStatusChanged;
  final void Function(AttendanceRecord, String) onRemarksChanged;

  const _AttendanceTable({
    required this.isDesktop,
    required this.isAdmin,
    required this.selectedRows,
    required this.onToggleSelection,
    required this.rowLabelHeader,
    required this.rows,
    required this.rowLabelBuilder,
    required this.subLabelBuilder,
    required this.onStatusChanged,
    required this.onRemarksChanged,
  });

  static const double _checkboxColWidth = 40;
  static const double _nameColWidth = 180;
  static const double _statusColWidth = 190;
  static const double _remarksColWidth = 220;
  static const double _typeColWidth = 130;

  @override
  Widget build(BuildContext context) {
    final totalWidth =
        _checkboxColWidth + _nameColWidth + _statusColWidth + _remarksColWidth + _typeColWidth;

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
                      isSelected: selectedRows[record.id] ?? false,
                      onToggle: onToggleSelection,
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
          cell('', _checkboxColWidth, align: TextAlign.center),
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
  final bool isSelected;
  final Function(String, bool) onToggle;
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
    required this.isSelected,
    required this.onToggle,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isEven ? _kCard : _kSurface.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: widget.isSelected,
              onChanged: (val) {
                widget.onToggle(widget.record.id, val ?? false);
              },
              activeColor: _kPrimary,
            ),
          ),
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

// ============================================================
// ENHANCED REPORT COMPONENTS (By Person Tab)
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.bg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const SizedBox(height: 10),
          Text(data.value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: data.color)),
          const SizedBox(height: 2),
          Text(data.label,
              style: const TextStyle(fontSize: 11.5, color: _kSlate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Map<String, Object> meta;
  const _StatusBadge({required this.meta});

  @override
  Widget build(BuildContext context) {
    final color = meta['color'] as Color;
    final bg = meta['bg'] as Color;
    final label = meta['label'] as String;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('LEGEND',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kSlate,
                  letterSpacing: 0.4)),
          ..._kStatuses.map((s) {
            final color = s['color'] as Color;
            final bg = s['bg'] as Color;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.5)),
                  ),
                  child: Text((s['label'] as String).substring(0, 1),
                      style: TextStyle(
                          fontSize: 9.5, fontWeight: FontWeight.w800, color: color)),
                ),
                const SizedBox(width: 6),
                Text(s['label'] as String,
                    style: const TextStyle(fontSize: 12, color: _kInk)),
              ],
            );
          }),
        ],
      ),
    );
  }
}


