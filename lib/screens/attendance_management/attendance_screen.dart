//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import '../../providers/teacher_provider.dart'; // Your existing provider
// import '../../providers/attendance_provider.dart'; // Our new provider
//
// // ============================================================
// // CORPORATE / PROFESSIONAL DESIGN TOKENS
// // ============================================================
// const _kInk = Color(0xFF1F2937); // Primary text
// const _kSlate = Color(0xFF64748B); // Secondary text
// const _kBorder = Color(0xFFE2E8F0); // Standard border
// const _kSurface = Color(0xFFF8FAFC); // Page background
// const _kCard = Colors.white;
//
// const _kPrimary = Color(0xFF1E3A8A); // Deep corporate navy
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
//   {'key': 'present', 'label': 'Present', 'color': _kGreen, 'bg': _kGreenBg},
//   {'key': 'absent', 'label': 'Absent', 'color': _kRed, 'bg': _kRedBg},
//   {'key': 'late', 'label': 'Late', 'color': _kOrange, 'bg': _kOrangeBg},
//   {'key': 'leave', 'label': 'Leave', 'color': _kBlue, 'bg': _kBlueBg},
//   {'key': 'half_day', 'label': 'Half Day', 'color': _kPurple, 'bg': _kPurpleBg},
// ];
//
// const double _kDesktopBreakpoint = 900;
//
// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({super.key});
//
//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }
//
// class _AttendanceScreenState extends State<AttendanceScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       final provider = context.read<AttendanceProvider>();
//       if (provider.records.isEmpty) {
//         provider.loadData();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final attendanceProvider = context.watch<AttendanceProvider>();
//     // staffProvider kept in scope for parity with existing app wiring.
//     context.watch<StaffProvider>();
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: _buildAppBar(context),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//             return isDesktop
//                 ? _buildDesktopLayout(context, attendanceProvider, constraints)
//                 : _buildMobileLayout(context, attendanceProvider);
//           },
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // APP BAR
//   // ============================================================
//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       titleSpacing: 20,
//       title: const Text(
//         'Staff Attendance',
//         style: TextStyle(
//           fontWeight: FontWeight.w700,
//           fontSize: 17,
//           color: _kInk,
//           letterSpacing: 0.1,
//         ),
//       ),
//       backgroundColor: _kCard,
//       surfaceTintColor: _kCard,
//       foregroundColor: _kInk,
//       elevation: 0,
//       shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 16),
//           child: OutlinedButton.icon(
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Reports feature coming soon')),
//               );
//             },
//             icon: const Icon(Icons.bar_chart_outlined, size: 16),
//             label: const Text('Reports',
//                 style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: _kSlate,
//               side: const BorderSide(color: _kBorder),
//               padding:
//               const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ============================================================
//   // DESKTOP LAYOUT
//   // ============================================================
//   Widget _buildDesktopLayout(BuildContext context,
//       AttendanceProvider provider, BoxConstraints constraints) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildToolbarCard(context, provider, isDesktop: true),
//           const SizedBox(height: 16),
//           _buildSummaryStrip(provider),
//           const SizedBox(height: 16),
//           Expanded(
//             child: provider.loading
//                 ? _buildLoadingState()
//                 : provider.records.isEmpty
//                 ? _buildEmptyState()
//                 : _buildDesktopTableCard(provider),
//           ),
//           const SizedBox(height: 16),
//           _buildSaveBar(context, provider, isDesktop: true),
//         ],
//       ),
//     );
//   }
//
//   // ============================================================
//   // MOBILE LAYOUT
//   // ============================================================
//   Widget _buildMobileLayout(
//       BuildContext context, AttendanceProvider provider) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//           child: _buildToolbarCard(context, provider, isDesktop: false),
//         ),
//         const SizedBox(height: 12),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: _buildSummaryStrip(provider),
//         ),
//         const SizedBox(height: 8),
//         Expanded(
//           child: provider.loading
//               ? _buildLoadingState()
//               : provider.records.isEmpty
//               ? _buildEmptyState()
//               : _buildMobileList(provider),
//         ),
//         _buildSaveBar(context, provider, isDesktop: false),
//       ],
//     );
//   }
//
//   // ============================================================
//   // TOOLBAR: date, filter, quick actions
//   // ============================================================
//   Widget _buildToolbarCard(
//       BuildContext context, AttendanceProvider provider,
//       {required bool isDesktop}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: isDesktop
//           ? Row(
//         children: [
//           _buildDatePicker(context, provider),
//           const SizedBox(width: 12),
//           _buildTypeFilter(provider),
//           const Spacer(),
//           _buildQuickActions(provider),
//         ],
//       )
//           : Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             children: [
//               Expanded(child: _buildDatePicker(context, provider)),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(child: _buildTypeFilter(provider)),
//             ],
//           ),
//           const SizedBox(height: 10),
//           _buildQuickActions(provider, fullWidth: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDatePicker(BuildContext context, AttendanceProvider provider) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: () async {
//         final initialDate =
//             DateTime.tryParse(provider.selectedDate) ?? DateTime.now();
//         final picked = await showDatePicker(
//           context: context,
//           initialDate: initialDate,
//           firstDate: DateTime(2020),
//           lastDate: DateTime.now(),
//           builder: (context, child) {
//             return Theme(
//               data: Theme.of(context).copyWith(
//                 colorScheme: const ColorScheme.light(
//                   primary: _kPrimary,
//                   onPrimary: Colors.white,
//                   onSurface: _kInk,
//                 ),
//               ),
//               child: child!,
//             );
//           },
//         );
//         if (picked != null) {
//           provider.changeDate(picked);
//         }
//       },
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
//             Flexible(
//               child: Text(
//                 DateFormat('EEE, dd MMM yyyy')
//                     .format(DateTime.parse(provider.selectedDate)),
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 13.5,
//                   fontWeight: FontWeight.w600,
//                   color: _kInk,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 6),
//             const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTypeFilter(AttendanceProvider provider) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: _kSurface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: _kBorder),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: provider.filterType,
//           isDense: true,
//           isExpanded: false,
//           items: const [
//             DropdownMenuItem(
//               value: 'all',
//               child: Text('All (Teachers + Staff)',
//                   style: TextStyle(fontSize: 13, color: _kInk)),
//             ),
//             DropdownMenuItem(
//               value: 'teacher',
//               child: Text('Teachers Only',
//                   style: TextStyle(fontSize: 13, color: _kInk)),
//             ),
//             DropdownMenuItem(
//               value: 'staff',
//               child: Text('Staff Only',
//                   style: TextStyle(fontSize: 13, color: _kInk)),
//             ),
//           ],
//           onChanged: (val) {
//             if (val != null) provider.changeFilter(val);
//           },
//           icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//           style: const TextStyle(fontSize: 13, color: _kInk),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickActions(AttendanceProvider provider,
//       {bool fullWidth = false}) {
//     final children = [
//       _buildQuickActionBtn(
//           'Mark All Present', Icons.check_circle_outline, _kGreen, _kGreenBg,
//               () {
//             provider.markAll('present');
//           }),
//       const SizedBox(width: 8),
//       _buildQuickActionBtn(
//           'Mark All Absent', Icons.cancel_outlined, _kRed, _kRedBg, () {
//         provider.markAll('absent');
//       }),
//     ];
//
//     if (fullWidth) {
//       return Row(
//         children: [
//           Expanded(child: children[0]),
//           const SizedBox(width: 8),
//           Expanded(child: children[2]),
//         ],
//       );
//     }
//     return Row(mainAxisSize: MainAxisSize.min, children: children);
//   }
//
//   Widget _buildQuickActionBtn(String label, IconData icon, Color color,
//       Color bgColor, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(7),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: bgColor,
//           border: Border.all(color: color.withOpacity(0.25)),
//           borderRadius: BorderRadius.circular(7),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 14, color: color),
//             const SizedBox(width: 6),
//             Flexible(
//               child: Text(
//                 label,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                     fontSize: 12, fontWeight: FontWeight.w600, color: color),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // SUMMARY STRIP (counts)
//   // ============================================================
//   Widget _buildSummaryStrip(AttendanceProvider provider) {
//     final counts = <String, int>{
//       for (final s in _kStatuses) s['key'] as String: 0,
//     };
//     for (final r in provider.records) {
//       if (counts.containsKey(r.status)) {
//         counts[r.status] = counts[r.status]! + 1;
//       }
//     }
//
//     return SizedBox(
//       height: 64,
//       child: LayoutBuilder(builder: (context, constraints) {
//         return Row(
//           children: [
//             Expanded(
//               child: _buildSummaryTile(
//                 'Total',
//                 provider.records.length.toString(),
//                 _kInk,
//                 _kSurface,
//               ),
//             ),
//             for (final s in _kStatuses) ...[
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _buildSummaryTile(
//                   s['label'] as String,
//                   counts[s['key']].toString(),
//                   s['color'] as Color,
//                   s['bg'] as Color,
//                 ),
//               ),
//             ],
//           ],
//         );
//       }),
//     );
//   }
//
//   Widget _buildSummaryTile(
//       String label, String value, Color color, Color bgColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//                 fontSize: 16, fontWeight: FontWeight.w700, color: color),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             label,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//                 fontSize: 10.5, fontWeight: FontWeight.w500, color: _kSlate),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ============================================================
//   // DESKTOP TABLE
//   // ============================================================
//   Widget _buildDesktopTableCard(AttendanceProvider provider) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(minWidth: 860),
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.vertical,
//                   child: DataTable(
//                     headingRowHeight: 44,
//                     dataRowMinHeight: 58,
//                     dataRowMaxHeight: 64,
//                     columnSpacing: 20,
//                     horizontalMargin: 20,
//                     headingRowColor:
//                     WidgetStateProperty.all(_kSurface),
//                     headingTextStyle: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       color: _kSlate,
//                       fontSize: 11.5,
//                       letterSpacing: 0.4,
//                     ),
//                     dividerThickness: 1,
//                     columns: const [
//                       DataColumn(label: Text('#')),
//                       DataColumn(label: Text('')),
//                       DataColumn(label: Text('NAME')),
//                       DataColumn(label: Text('TYPE')),
//                       DataColumn(label: Text('STATUS')),
//                       DataColumn(label: Text('REMARKS')),
//                     ],
//                     rows: List.generate(provider.records.length, (index) {
//                       final record = provider.records[index];
//                       return DataRow(
//                         color: WidgetStateProperty.resolveWith((states) {
//                           return index.isEven ? _kCard : _kSurface.withOpacity(0.4);
//                         }),
//                         cells: [
//                           DataCell(Text('${index + 1}',
//                               style: const TextStyle(
//                                   fontSize: 12.5, color: _kSlate))),
//                           DataCell(_buildAvatar(
//                               record.photoBase64, record.staffName)),
//                           DataCell(Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(record.staffName,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                       color: _kInk)),
//                               const SizedBox(height: 2),
//                               Text(record.staffId,
//                                   style: const TextStyle(
//                                       fontSize: 11, color: _kSlate)),
//                             ],
//                           )),
//                           DataCell(_buildTypeBadge(record.type)),
//                           DataCell(_buildStatusSegments(record.status, (val) {
//                             provider.updateStatus(record.staffId, val);
//                           })),
//                           DataCell(SizedBox(
//                             width: 160,
//                             child: _RemarksField(
//                               key: ValueKey('remark-${record.staffId}'),
//                               initialValue: record.remarks,
//                               onChanged: (val) {
//                                 provider.updateRemarks(record.staffId, val);
//                               },
//                             ),
//                           )),
//                         ],
//                       );
//                     }),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTypeBadge(String type) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: _kPrimaryLight,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: _kPrimary.withOpacity(0.15)),
//       ),
//       child: Text(
//         type.toUpperCase(),
//         style: const TextStyle(
//             fontSize: 10, fontWeight: FontWeight.w700, color: _kPrimary),
//       ),
//     );
//   }
//
//   // ============================================================
//   // MOBILE LIST
//   // ============================================================
//   Widget _buildMobileList(AttendanceProvider provider) {
//     return ListView.separated(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//       itemCount: provider.records.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 10),
//       itemBuilder: (ctx, index) {
//         final record = provider.records[index];
//         return Container(
//           decoration: BoxDecoration(
//             color: _kCard,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: _kBorder),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Row(
//                   children: [
//                     _buildAvatar(record.photoBase64, record.staffName,
//                         size: 38),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(record.staffName,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14,
//                                   color: _kInk)),
//                           const SizedBox(height: 2),
//                           Row(
//                             children: [
//                               Text(record.staffId,
//                                   style: const TextStyle(
//                                       fontSize: 11.5, color: _kSlate)),
//                               const SizedBox(width: 6),
//                               _buildTypeBadge(record.type),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 _buildStatusSegments(record.status, (val) {
//                   provider.updateStatus(record.staffId, val);
//                 }, stretch: true),
//                 const SizedBox(height: 8),
//                 _RemarksField(
//                   key: ValueKey('remark-mobile-${record.staffId}'),
//                   initialValue: record.remarks,
//                   hint: 'Add remarks (optional)',
//                   onChanged: (val) {
//                     provider.updateRemarks(record.staffId, val);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
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
//           fontSize: size * 0.4,
//           fontWeight: FontWeight.w700,
//           color: _kPrimary,
//         ),
//       )
//           : null,
//     );
//   }
//
//   // ============================================================
//   // STATUS SEGMENTED CONTROL (Professional)
//   // ============================================================
//   Widget _buildStatusSegments(
//       String currentStatus, Function(String) onChanged,
//       {bool stretch = false}) {
//     final control = Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: _kBorder),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Row(
//         mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
//         children: List.generate(_kStatuses.length, (i) {
//           final s = _kStatuses[i];
//           final key = s['key'] as String;
//           final label = s['label'] as String;
//           final color = s['color'] as Color;
//           final bg = s['bg'] as Color;
//           final isSelected = currentStatus == key;
//           final isLast = i == _kStatuses.length - 1;
//
//           final segment = InkWell(
//             onTap: () => onChanged(key),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: isSelected ? bg : _kCard,
//                 border: isLast
//                     ? null
//                     : const Border(
//                   right: BorderSide(color: _kBorder, width: 1),
//                 ),
//               ),
//               padding:
//               const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
//               child: Text(
//                 label,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 10.5,
//                   fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                   color: isSelected ? color : _kSlate,
//                 ),
//               ),
//             ),
//           );
//
//           return stretch ? Expanded(child: segment) : segment;
//         }),
//       ),
//     );
//
//     return stretch
//         ? control
//         : IntrinsicWidth(child: control);
//   }
//
//   Widget _buildLoadingState() {
//     return const Center(
//       child: SizedBox(
//         width: 28,
//         height: 28,
//         child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Container(
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: _kCard,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.groups_outlined, size: 44, color: Colors.grey.shade300),
//           const SizedBox(height: 12),
//           const Text(
//             'No records found',
//             style:
//             TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _kInk),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'No active teachers/staff found for this filter.',
//             style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ============================================================
//   // SAVE BAR
//   // ============================================================
//   Widget _buildSaveBar(BuildContext context, AttendanceProvider provider,
//       {required bool isDesktop}) {
//     final button = ElevatedButton.icon(
//       onPressed: provider.loading
//           ? null
//           : () async {
//         await provider.saveAttendance();
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Attendance saved successfully'),
//               backgroundColor: _kGreen,
//             ),
//           );
//         }
//       },
//       icon: const Icon(Icons.check_circle_outline, size: 17),
//       label: const Text('Save Attendance',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _kPrimary,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         elevation: 0,
//       ),
//     );
//
//     if (isDesktop) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [SizedBox(width: 210, child: button)],
//       );
//     }
//
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
//       decoration: const BoxDecoration(
//         color: _kCard,
//         border: Border(top: BorderSide(color: _kBorder)),
//       ),
//       child: SizedBox(width: double.infinity, child: button),
//     );
//   }
// }
//
// // ============================================================
// // Stateful remarks field — keeps its own controller so rebuilds
// // triggered by provider.notifyListeners() (e.g. from other rows'
// // status taps) don't reset cursor position or steal focus.
// // ============================================================
// class _RemarksField extends StatefulWidget {
//   final String initialValue;
//   final ValueChanged<String> onChanged;
//   final String hint;
//
//   const _RemarksField({
//     super.key,
//     required this.initialValue,
//     required this.onChanged,
//     this.hint = 'Remarks',
//   });
//
//   @override
//   State<_RemarksField> createState() => _RemarksFieldState();
// }
//
// class _RemarksFieldState extends State<_RemarksField> {
//   late final TextEditingController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.initialValue);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: _controller,
//       onChanged: widget.onChanged,
//       maxLines: 1,
//       style: const TextStyle(fontSize: 12.5, color: _kInk),
//       decoration: InputDecoration(
//         hintText: widget.hint,
//         hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
//         isDense: true,
//         filled: true,
//         fillColor: _kSurface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: _kBorder),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: _kBorder),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: const BorderSide(color: _kPrimary, width: 1.4),
//         ),
//         contentPadding:
//         const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/teacher_provider.dart'; // Your existing provider
import '../../providers/attendance_provider.dart'; // Our new provider

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

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AttendanceProvider>();
      if (provider.records.isEmpty) {
        provider.loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    // staffProvider kept in scope for parity with existing app wiring.
    context.watch<StaffProvider>();

    return Scaffold(
      backgroundColor: _kSurface,
      // Full-screen: no bottom nav / drawer clipping, body takes entire
      // available height below the AppBar.
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
          // Full-screen: list area takes all remaining vertical space.
          Expanded(
            child: provider.loading
                ? _buildLoadingState()
                : provider.records.isEmpty
                ? _buildEmptyState()
                : _buildDesktopCardList(provider),
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
        // Full-screen: list gets all remaining space, scrolls independently.
        Expanded(
          child: provider.loading
              ? _buildLoadingState()
              : provider.records.isEmpty
              ? _buildEmptyState()
              : _buildMobileList(provider),
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
          _buildQuickActions(provider),
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
          _buildQuickActions(provider, fullWidth: true),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, AttendanceProvider provider) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final initialDate =
            DateTime.tryParse(provider.selectedDate) ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: _kPrimary,
                  onPrimary: Colors.white,
                  onSurface: _kInk,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          provider.changeDate(picked);
        }
      },
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

  Widget _buildQuickActions(AttendanceProvider provider,
      {bool fullWidth = false}) {
    final children = [
      _buildQuickActionBtn(
          'Mark All Present', Icons.check_circle_outline, _kGreen, _kGreenBg,
              () {
            provider.markAll('present');
          }),
      const SizedBox(width: 8),
      _buildQuickActionBtn(
          'Mark All Absent', Icons.cancel_outlined, _kRed, _kRedBg, () {
        provider.markAll('absent');
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
  // DESKTOP: card list (replaces the old DataTable so the big
  // status buttons have room to breathe, same as mobile but in
  // a wider two-column-ish row layout).
  // ============================================================
  Widget _buildDesktopCardList(AttendanceProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: provider.records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final record = provider.records[index];
        return _buildPersonCard(
          provider: provider,
          record: record,
          index: index,
          isDesktop: true,
        );
      },
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
  // MOBILE LIST
  // ============================================================
  Widget _buildMobileList(AttendanceProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: provider.records.length,
      // ★ Strong visual gap between each person's card so it's obvious
      // where one person's data ends and the next one's begins.
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (ctx, index) {
        final record = provider.records[index];
        return _buildPersonCard(
          provider: provider,
          record: record,
          index: index,
          isDesktop: false,
        );
      },
    );
  }

  // ============================================================
  // ★ SHARED PERSON CARD (used by both mobile list and desktop list)
  // - Green tint + border when attendance already saved for this date
  // - Numbered badge so each person is clearly indexed
  // - Name + designation (or type if no designation) under it
  // - Large, prominent status buttons (wrap grid, not tiny segments)
  // ============================================================
  Widget _buildPersonCard({
    required AttendanceProvider provider,
    required dynamic record,
    required int index,
    required bool isDesktop,
  }) {
    final bool isSaved = record.isSaved == true;
    final String? designation =
    (record.designation != null && (record.designation as String).trim().isNotEmpty)
        ? record.designation as String
        : null;
    final String subtitleText = designation ?? _typeLabel(record.type as String);

    return Container(
      decoration: BoxDecoration(
        color: isSaved ? _kSavedBg : _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSaved ? _kSavedBorder : _kBorder,
          width: isSaved ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numbered badge — makes each person's start obvious
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  decoration: BoxDecoration(
                    color: isSaved ? _kGreen.withOpacity(0.12) : _kPrimaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isSaved ? _kGreen : _kPrimary,
                    ),
                  ),
                ),
                _buildAvatar(record.photoBase64 as String?, record.staffName as String,
                    size: 42),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              record.staffName as String,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: _kInk),
                            ),
                          ),
                          if (isSaved) ...[
                            const SizedBox(width: 8),
                            _buildSavedChip(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              subtitleText,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: _kSlate),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildTypeBadge(record.type as String),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusButtons(
              currentStatus: record.status as String,
              isDesktop: isDesktop,
              onChanged: (val) {
                provider.updateStatus(record.staffId as String, val);
              },
            ),
            const SizedBox(height: 10),
            _RemarksField(
              key: ValueKey('remark-${record.staffId}'),
              initialValue: record.remarks as String,
              hint: 'Add remarks (optional)',
              onChanged: (val) {
                provider.updateRemarks(record.staffId as String, val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kGreen.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGreen.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: _kGreen),
          SizedBox(width: 4),
          Text(
            'Saved',
            style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w700, color: _kGreen),
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

  // ============================================================
  // ★ STATUS BUTTONS — big, prominent, icon + label.
  // Wraps into a grid instead of tiny text segments so it's the
  // most visually dominant part of each card, as requested.
  // ============================================================
  Widget _buildStatusButtons({
    required String currentStatus,
    required bool isDesktop,
    required Function(String) onChanged,
  }) {
    // 5 statuses: 3-per-row on mobile (2 rows: 3 + 2),
    // and on wider desktop cards let them sit on one row.
    return LayoutBuilder(builder: (context, constraints) {
      final bool wide = constraints.maxWidth >= 560;
      final int columns = wide ? 5 : 3;
      final double spacing = 8;
      final double itemWidth =
          (constraints.maxWidth - spacing * (columns - 1)) / columns;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: _kStatuses.map((s) {
          final key = s['key'] as String;
          final label = s['label'] as String;
          final icon = s['icon'] as IconData;
          final color = s['color'] as Color;
          final bg = s['bg'] as Color;
          final isSelected = currentStatus == key;

          return SizedBox(
            width: itemWidth,
            child: _StatusButton(
              label: label,
              icon: icon,
              color: color,
              bg: bg,
              isSelected: isSelected,
              onTap: () => onChanged(key),
            ),
          );
        }).toList(),
      );
    });
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

// ============================================================
// ★ Individual big status button — replaces the old tiny
// segmented-control text buttons with a real, tappable,
// icon + label button that's visually dominant.
// ============================================================
class _StatusButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? bg : _kSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : _kBorder,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: isSelected ? color : _kSlate),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? color : _kSlate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Stateful remarks field — keeps its own controller so rebuilds
// triggered by provider.notifyListeners() (e.g. from other rows'
// status taps) don't reset cursor position or steal focus.
// ============================================================
class _RemarksField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hint;

  const _RemarksField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.hint = 'Remarks',
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
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      maxLines: 1,
      style: const TextStyle(fontSize: 12.5, color: _kInk),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        isDense: true,
        filled: true,
        fillColor: _kSurface,
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
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}