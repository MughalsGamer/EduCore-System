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
// // DESIGN TOKENS — matches attendance_history_screen.dart so the
// // whole attendance module feels like one consistent surface.
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
//   {'key': 'present', 'letter': 'P', 'label': 'Present', 'color': _kGreen, 'bg': _kGreenBg},
//   {'key': 'absent', 'letter': 'A', 'label': 'Absent', 'color': _kRed, 'bg': _kRedBg},
//   {'key': 'late', 'letter': 'Late', 'label': 'Late', 'color': _kOrange, 'bg': _kOrangeBg},
//   {'key': 'leave', 'letter': 'L', 'label': 'Leave', 'color': _kBlue, 'bg': _kBlueBg},
//   {'key': 'half_day', 'letter': 'H', 'label': 'Half Day', 'color': _kPurple, 'bg': _kPurpleBg},
// ];
//
// Map<String, Object> _statusMeta(String key) {
//   return _kStatuses.firstWhere((s) => s['key'] == key,
//       orElse: () => _kStatuses[0]);
// }
//
// const double _kDesktopBreakpoint = 900;
//
// String _subtitle(String? designation, String type) {
//   if (designation != null && designation.trim().isNotEmpty) return designation;
//   return type.toLowerCase() == 'teacher' ? 'Teacher' : 'Staff';
// }
//
// // ============================================================
// // STAFF ATTENDANCE REPORT
// // Pick a staff/teacher -> month/year filter -> summary cards +
// // full attendance table for that month, all derived live from
// // AttendanceProvider.historyRecords (no dummy data, no hardcoding).
// //
// // `embedded: true` means this widget is being hosted inside another
// // Scaffold's TabBarView (the History screen's "By Person" tab) so it
// // skips pushing its own AppBar/Scaffold chrome.
// // ============================================================
// class StaffAttendanceReportScreen extends StatefulWidget {
//   final bool embedded;
//   const StaffAttendanceReportScreen({super.key, this.embedded = false});
//
//   @override
//   State<StaffAttendanceReportScreen> createState() =>
//       _StaffAttendanceReportScreenState();
// }
//
// class _StaffAttendanceReportScreenState
//     extends State<StaffAttendanceReportScreen> {
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
//     final body = _selectedStaff == null ? _buildPersonPicker() : _buildReport();
//
//     if (widget.embedded) return body;
//
//     final isAdmin = context.watch<AuthProvider>().role == 'admin';
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         titleSpacing: 20,
//         title: const Text(
//           'Staff Attendance Report',
//           style: TextStyle(
//               fontWeight: FontWeight.w700, fontSize: 17, color: _kInk),
//         ),
//         backgroundColor: _kCard,
//         surfaceTintColor: _kCard,
//         foregroundColor: _kInk,
//         elevation: 0,
//         shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
//       ),
//       body: !isAdmin
//           ? Column(
//         children: [
//           const _ViewOnlyBanner(),
//           Expanded(child: body),
//         ],
//       )
//           : body,
//     );
//   }
//
//   // ---- Step 1: pick a person ----
//   Widget _buildPersonPicker() {
//     final staffProvider = context.watch<StaffProvider>();
//     final allStaff = [...staffProvider.teachers, ...staffProvider.staffOnly];
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
//             _Avatar(base64: staff.imageBase64, name: staff.name, size: 40),
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
//   // ---- Step 2: full report for selected person ----
//   Widget _buildReport() {
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
//             if (!provider.historyLoading && provider.historyError == null)
//               _buildSummaryCards(provider, isDesktop),
//             const SizedBox(height: 16),
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
//             child: _Avatar(base64: staff.imageBase64, name: staff.name, size: 56),
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
// // Colored letter badge for the report table (P / A / L / Late / H).
// class _StatusBadge extends StatelessWidget {
//   final Map<String, Object> meta;
//   const _StatusBadge({required this.meta});
//
//   @override
//   Widget build(BuildContext context) {
//     final color = meta['color'] as Color;
//     final bg = meta['bg'] as Color;
//     final letter = meta['letter'] as String;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.35)),
//       ),
//       child: Text(
//         letter,
//         style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
//       ),
//     );
//   }
// }
//
// // Legend explaining P/A/L/Late/H, reused above the table.
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
//                   child: Text(s['letter'] as String,
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
//
// class _Avatar extends StatelessWidget {
//   final String? base64;
//   final String name;
//   final double size;
//   const _Avatar({required this.base64, required this.name, this.size = 32});
//
//   @override
//   Widget build(BuildContext context) {
//     ImageProvider? image;
//     if (base64 != null && base64!.isNotEmpty) {
//       try {
//         image = MemoryImage(base64Decode(base64!));
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
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 40),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline_rounded, size: 44, color: _kRed),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Text(
//                 message,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 12.5, color: _kSlate),
//               ),
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
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 40),
//       child: Center(
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