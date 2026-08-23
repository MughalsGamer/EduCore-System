//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/class_attendance_model.dart';
// import '../../models/class_model.dart';
// import '../../providers/class_attendance_provider.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/student_provider.dart';
//
// const _purple = Color(0xFF534AB7);
// const _purpleLight = Color(0xFFEEECFA);
// const _green = Color(0xFF16A34A);
// const _red = Color(0xFFDC2626);
// const _orange = Color(0xFFD97706);
// const _blue = Color(0xFF2563EB);
// const _grayStatus = Color(0xFF6B7280);
//
// // ★ Sunday = weekly holiday. Attendance cannot be marked or viewed
// // for this date anywhere in the class attendance module.
// bool isHolidayDate(DateTime date) => date.weekday == DateTime.sunday;
//
// Color _statusColor(AttendanceStatus s) {
//   switch (s) {
//     case AttendanceStatus.present: return _green;
//     case AttendanceStatus.absent: return _red;
//     case AttendanceStatus.leave: return _blue;
//     case AttendanceStatus.late: return _orange;
//     case AttendanceStatus.halfDay: return const Color(0xFF9333EA);
//   }
// }
//
// IconData _statusIcon(AttendanceStatus s) {
//   switch (s) {
//     case AttendanceStatus.present: return Icons.check_circle_rounded;
//     case AttendanceStatus.absent: return Icons.cancel_rounded;
//     case AttendanceStatus.leave: return Icons.event_busy_rounded;
//     case AttendanceStatus.late: return Icons.schedule_rounded;
//     case AttendanceStatus.halfDay: return Icons.hourglass_bottom_rounded;
//   }
// }
//
// class ClassAttendanceScreen extends StatefulWidget {
//   final bool showAppBar;
//   const ClassAttendanceScreen({super.key, this.showAppBar = true});
//
//   @override
//   State<ClassAttendanceScreen> createState() => _ClassAttendanceScreenState();
// }
//
// class _ClassAttendanceScreenState extends State<ClassAttendanceScreen> {
//   String? _selectedClassId;
//   String? _selectedSectionName;
//   DateTime _selectedDate = DateTime.now();
//
//   // ★ Overlay-style dropdown calendar (same pattern as staff AttendanceScreen)
//   final GlobalKey _dateChipKey = GlobalKey();
//   OverlayEntry? _dateOverlayEntry;
//   DateTime? _tempSelectedDate;
//
//   bool get _isHoliday => isHolidayDate(_selectedDate);
//
//   String get _dateKey =>
//       '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
//
//   String _fmtDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//
//   @override
//   void dispose() {
//     _dateOverlayEntry?.remove();
//     _dateOverlayEntry = null;
//     super.dispose();
//   }
//
//   void _closeDateOverlay() {
//     _dateOverlayEntry?.remove();
//     _dateOverlayEntry = null;
//   }
//
//   // ★ Same dropdown-style calendar as the staff Attendance screen.
//   // Sundays are disabled (greyed out, unselectable).
//   void _toggleDateOverlay() {
//     if (_dateOverlayEntry != null) {
//       _closeDateOverlay();
//       return;
//     }
//
//     final renderBox =
//     _dateChipKey.currentContext?.findRenderObject() as RenderBox?;
//     if (renderBox == null) return;
//
//     final overlay = Overlay.of(context);
//     final position = renderBox.localToGlobal(Offset.zero);
//     final initialDate = _selectedDate;
//     _tempSelectedDate = initialDate;
//
//     _dateOverlayEntry = OverlayEntry(
//       builder: (overlayContext) {
//         return Stack(
//           children: [
//             GestureDetector(
//               onTap: _closeDateOverlay,
//               behavior: HitTestBehavior.opaque,
//               child: Container(color: Colors.black.withOpacity(0.1)),
//             ),
//             Positioned(
//               top: position.dy + renderBox.size.height + 6,
//               left: position.dx,
//               width: 320,
//               child: Material(
//                 elevation: 8,
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.white,
//                 child: Card(
//                   margin: EdgeInsets.zero,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(
//                         height: 360,
//                         child: CalendarDatePicker(
//                           initialDate: initialDate,
//                           firstDate: DateTime(2020),
//                           lastDate: DateTime.now(),
//                           selectableDayPredicate: (date) => !isHolidayDate(date),
//                           onDateChanged: (date) {
//                             _tempSelectedDate = date;
//                           },
//                         ),
//                       ),
//                       const Divider(height: 1),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Container(
//                               width: 8,
//                               height: 8,
//                               decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle),
//                             ),
//                             const SizedBox(width: 6),
//                             Text('Sundays are holidays',
//                                 style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//                           ],
//                         ),
//                       ),
//                       const Divider(height: 1),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             TextButton(
//                               onPressed: _closeDateOverlay,
//                               child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w600)),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 final newDate = _tempSelectedDate ?? initialDate;
//                                 _closeDateOverlay();
//                                 setState(() => _selectedDate = newDate);
//                                 // ★ Never load/mark attendance for a holiday date.
//                                 if (!isHolidayDate(newDate)) {
//                                   _loadIfReady();
//                                 }
//                               },
//                               child: const Text('OK',
//                                   style: TextStyle(fontWeight: FontWeight.w600, color: _purple)),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//
//     overlay.insert(_dateOverlayEntry!);
//   }
//
//   void _loadIfReady() {
//     if (_selectedClassId == null || _selectedSectionName == null) return;
//     if (_isHoliday) return; // ★ never fetch/mark attendance on a holiday
//
//     final classes = context.read<ClassProvider>().classes;
//     SchoolClass? cls;
//     try {
//       cls = classes.firstWhere((c) => c.id == _selectedClassId);
//     } catch (_) {
//       return;
//     }
//
//     // Roster comes live from StudentProvider — always reflects the
//     // CURRENT class/section, so promote/demote is handled automatically.
//     final allStudents = context.read<StudentProvider>().students;
//     final activeStudents = allStudents
//         .where((s) =>
//     s.student.className == cls!.name &&
//         s.student.sectionName == _selectedSectionName &&
//         s.student.isActive)
//         .map((s) => MapEntry(s.student.studentId, s.student.name))
//         .toList();
//
//     context.read<ClassAttendanceProvider>().loadForClass(
//       classId: _selectedClassId!,
//       className: cls.name,
//       sectionId: _selectedSectionName!, // section names act as section IDs here
//       sectionName: _selectedSectionName!,
//       date: _dateKey,
//       activeStudents: activeStudents,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= 900;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5FA),
//       appBar: widget.showAppBar
//           ? AppBar(
//         title: const Text('Attendance'),
//         centerTitle: true,
//         backgroundColor: _purple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       )
//           : null,
//       body: isDesktop ? _buildDesktop() : _buildMobile(),
//     );
//   }
//
//   // ═══════════════════ DESKTOP ═══════════════════
//   Widget _buildDesktop() {
//     final classes = context.watch<ClassProvider>().classes;
//
//     return Row(
//       children: [
//         Container(
//           width: 300,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             border: Border(right: BorderSide(color: Color(0xFFE9E9F2))),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
//                 child: Text('Classes',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
//               ),
//               _dateSelector(),
//               const Divider(height: 1),
//               Expanded(
//                 child: classes.isEmpty
//                     ? Center(child: Text('No classes found', style: TextStyle(color: Colors.grey.shade400)))
//                     : ListView.builder(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   itemCount: classes.length,
//                   itemBuilder: (context, i) {
//                     final cls = classes[i];
//                     final sections = cls.sections.isNotEmpty
//                         ? cls.sections.map((s) => s.sectionName).toList()
//                         : <String>[];
//                     return _ClassExpansionTile(
//                       className: cls.name,
//                       sections: sections,
//                       isClassSelected: cls.id == _selectedClassId,
//                       selectedSection: cls.id == _selectedClassId ? _selectedSectionName : null,
//                       onSectionTap: (section) {
//                         setState(() {
//                           _selectedClassId = cls.id;
//                           _selectedSectionName = section;
//                         });
//                         _loadIfReady();
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: (_selectedClassId == null || _selectedSectionName == null)
//               ? _emptySelectionState()
//               : (_isHoliday
//               ? _holidayState()
//               : _AttendanceGrid(dateLabel: _fmtDate(_selectedDate))),
//         ),
//       ],
//     );
//   }
//
//   Widget _dateSelector() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//       child: InkWell(
//         key: _dateChipKey,
//         onTap: _toggleDateOverlay,
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           decoration: BoxDecoration(
//             color: _isHoliday ? const Color(0xFFFFF7ED) : _purpleLight,
//             borderRadius: BorderRadius.circular(10),
//             border: _isHoliday ? Border.all(color: _orange.withOpacity(0.3)) : null,
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.calendar_today_rounded, size: 15, color: _isHoliday ? _orange : _purple),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(_fmtDate(_selectedDate),
//                     style: TextStyle(
//                         fontSize: 13, fontWeight: FontWeight.w600, color: _isHoliday ? _orange : _purple)),
//               ),
//               if (_isHoliday)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   margin: const EdgeInsets.only(right: 6),
//                   decoration: BoxDecoration(
//                     color: _orange.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: const Text('HOLIDAY',
//                       style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _orange)),
//                 ),
//               Icon(Icons.keyboard_arrow_down, size: 16, color: _isHoliday ? _orange : _purple),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _emptySelectionState() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(color: _purpleLight, borderRadius: BorderRadius.circular(20)),
//             child: const Icon(Icons.fact_check_outlined, size: 34, color: _purple),
//           ),
//           const SizedBox(height: 16),
//           Text('Select a class & section', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
//           const SizedBox(height: 4),
//           Text('Choose from the list to mark attendance', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400)),
//         ],
//       ),
//     );
//   }
//
//   // ★ Shown instead of the marking grid whenever the selected date is
//   // a Sunday. No attendance can be marked or viewed for a holiday —
//   // this applies regardless of whether older data happens to exist
//   // for that date.
//   Widget _holidayState() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(20)),
//             child: const Icon(Icons.weekend_rounded, size: 34, color: _orange),
//           ),
//           const SizedBox(height: 16),
//           Text('Sunday — Holiday', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
//           const SizedBox(height: 4),
//           Text('Attendance cannot be marked or viewed on a holiday.',
//               style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400)),
//         ],
//       ),
//     );
//   }
//
//   // ═══════════════════ MOBILE ═══════════════════
//   Widget _buildMobile() {
//     if (_selectedClassId == null || _selectedSectionName == null) {
//       return _buildMobileClassPicker();
//     }
//     if (_isHoliday) {
//       return Column(
//         children: [
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
//                   onPressed: () => setState(() {
//                     _selectedClassId = null;
//                     _selectedSectionName = null;
//                     context.read<ClassAttendanceProvider>().clear();
//                   }),
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     key: _dateChipKey,
//                     onTap: _toggleDateOverlay,
//                     borderRadius: BorderRadius.circular(8),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF7ED),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: _orange.withOpacity(0.3)),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.calendar_today_rounded, size: 15, color: _orange),
//                           const SizedBox(width: 8),
//                           Text(_fmtDate(_selectedDate),
//                               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _orange)),
//                           const Spacer(),
//                           const Icon(Icons.keyboard_arrow_down, size: 16, color: _orange),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(child: _holidayState()),
//         ],
//       );
//     }
//     return _AttendanceGrid(
//       dateLabel: _fmtDate(_selectedDate),
//       onBack: () => setState(() {
//         _selectedClassId = null;
//         _selectedSectionName = null;
//         context.read<ClassAttendanceProvider>().clear();
//       }),
//       onDateTap: _toggleDateOverlay,
//       dateChipKey: _dateChipKey,
//     );
//   }
//
//   Widget _buildMobileClassPicker() {
//     final classes = context.watch<ClassProvider>().classes;
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: _dateSelector(),
//         ),
//         Expanded(
//           child: classes.isEmpty
//               ? Center(child: Text('No classes found', style: TextStyle(color: Colors.grey.shade400)))
//               : ListView.builder(
//             padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
//             itemCount: classes.length,
//             itemBuilder: (context, i) {
//               final cls = classes[i];
//               final sections = cls.sections.isNotEmpty
//                   ? cls.sections.map((s) => s.sectionName).toList()
//                   : <String>[];
//               return _MobileClassCard(
//                 className: cls.name,
//                 sections: sections,
//                 onSectionTap: (section) {
//                   setState(() {
//                     _selectedClassId = cls.id;
//                     _selectedSectionName = section;
//                   });
//                   _loadIfReady();
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─── Desktop: class + expandable sections ──────────────────────
// class _ClassExpansionTile extends StatelessWidget {
//   final String className;
//   final List<String> sections;
//   final bool isClassSelected;
//   final String? selectedSection;
//   final ValueChanged<String> onSectionTap;
//
//   const _ClassExpansionTile({
//     required this.className,
//     required this.sections,
//     required this.isClassSelected,
//     required this.selectedSection,
//     required this.onSectionTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (sections.isEmpty) return const SizedBox.shrink();
//     return Theme(
//       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//       child: ExpansionTile(
//         initiallyExpanded: isClassSelected,
//         title: Text(className, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
//         leading: const Icon(Icons.class_outlined, size: 18, color: _purple),
//         childrenPadding: const EdgeInsets.only(left: 12, bottom: 6),
//         children: sections.map((sec) {
//           final selected = isClassSelected && selectedSection == sec;
//           return Material(
//             color: selected ? _purpleLight : Colors.transparent,
//             child: InkWell(
//               onTap: () => onSectionTap(sec),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   children: [
//                     Icon(Icons.group_outlined, size: 15, color: selected ? _purple : Colors.grey.shade500),
//                     const SizedBox(width: 8),
//                     Text(sec,
//                         style: TextStyle(
//                             fontSize: 12.5,
//                             color: selected ? _purple : Colors.grey.shade700,
//                             fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
//
// // ─── Mobile: class card with section chips ────────────────────
// class _MobileClassCard extends StatelessWidget {
//   final String className;
//   final List<String> sections;
//   final ValueChanged<String> onSectionTap;
//
//   const _MobileClassCard({required this.className, required this.sections, required this.onSectionTap});
//
//   @override
//   Widget build(BuildContext context) {
//     if (sections.isEmpty) return const SizedBox.shrink();
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFEEEEF5)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.class_outlined, size: 17, color: _purple),
//               const SizedBox(width: 8),
//               Text(className, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: sections.map((sec) {
//               return InkWell(
//                 borderRadius: BorderRadius.circular(20),
//                 onTap: () => onSectionTap(sec),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: _purpleLight,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(sec, style: const TextStyle(fontSize: 12.5, color: _purple, fontWeight: FontWeight.w600)),
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
// // ─── Attendance marking grid — shared desktop/mobile ──────────
// class _AttendanceGrid extends StatelessWidget {
//   final String dateLabel;
//   final VoidCallback? onBack;
//   final VoidCallback? onDateTap;
//   final GlobalKey? dateChipKey;
//
//   const _AttendanceGrid({required this.dateLabel, this.onBack, this.onDateTap, this.dateChipKey});
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<ClassAttendanceProvider>();
//
//     if (provider.isLoading) {
//       return const Center(child: CircularProgressIndicator(color: _purple));
//     }
//
//     final attendance = provider.current;
//     if (attendance == null) {
//       return const Center(child: Text('No data'));
//     }
//
//     final records = attendance.records.values.toList()
//       ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
//
//     return Column(
//       children: [
//         _header(context, attendance, onBack: onBack, onDateTap: onDateTap, dateChipKey: dateChipKey),
//         if (provider.error != null) _errorBanner(context, provider),
//         _summaryBar(attendance),
//         Expanded(
//           child: records.isEmpty
//               ? Center(
//             child: Text('No active students in this class',
//                 style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
//           )
//               : ListView.builder(
//             padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
//             itemCount: records.length,
//             itemBuilder: (context, i) => _StudentAttendanceRow(
//               record: records[i],
//               locked: attendance.locked,
//               onChanged: (status) =>
//                   context.read<ClassAttendanceProvider>().setStatus(records[i].studentId, status),
//             ),
//           ),
//         ),
//         _bottomBar(context, attendance),
//       ],
//     );
//   }
//
//   Widget _header(BuildContext context, ClassAttendanceModel att,
//       {VoidCallback? onBack, VoidCallback? onDateTap, GlobalKey? dateChipKey}) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
//       child: Row(
//         children: [
//           if (onBack != null) ...[
//             IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18), onPressed: onBack),
//             const SizedBox(width: 4),
//           ],
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('${att.className} — ${att.sectionName}',
//                     style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 2),
//                 Text(
//                   att.locked ? '$dateLabel • Locked (already submitted)' : dateLabel,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: att.locked ? _orange : Colors.grey.shade500,
//                     fontWeight: att.locked ? FontWeight.w600 : FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (onDateTap != null)
//             IconButton(
//               key: dateChipKey,
//               icon: const Icon(Icons.calendar_today_rounded, size: 18, color: _purple),
//               onPressed: onDateTap,
//             ),
//           if (att.locked)
//             TextButton.icon(
//               onPressed: () async {
//                 final confirmed = await showDialog<bool>(
//                   context: context,
//                   builder: (ctx) => AlertDialog(
//                     title: const Text('Unlock attendance?'),
//                     content: const Text('This will allow editing today\'s attendance again.'),
//                     actions: [
//                       TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//                       ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unlock')),
//                     ],
//                   ),
//                 );
//                 if (confirmed == true) {
//                   await context.read<ClassAttendanceProvider>().unlock();
//                 }
//               },
//               icon: const Icon(Icons.lock_open_rounded, size: 15, color: _orange),
//               label: const Text('Edit', style: TextStyle(color: _orange, fontSize: 12, fontWeight: FontWeight.w600)),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _errorBanner(BuildContext context, ClassAttendanceProvider provider) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, size: 16, color: Colors.red.shade600),
//           const SizedBox(width: 8),
//           Expanded(child: Text(provider.error!, style: TextStyle(fontSize: 12, color: Colors.red.shade700))),
//           IconButton(icon: const Icon(Icons.close, size: 16), onPressed: provider.clearError),
//         ],
//       ),
//     );
//   }
//
//   Widget _summaryBar(ClassAttendanceModel att) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             _summaryChip('Total', att.totalCount, _grayStatus),
//             const SizedBox(width: 8),
//             _summaryChip('Present', att.presentCount, _green),
//             const SizedBox(width: 8),
//             _summaryChip('Absent', att.absentCount, _red),
//             const SizedBox(width: 8),
//             _summaryChip('Leave', att.leaveCount, _blue),
//             const SizedBox(width: 8),
//             _summaryChip('Late', att.lateCount, _orange),
//             const SizedBox(width: 8),
//             _summaryChip('Half Day', att.halfDayCount, const Color(0xFF9333EA)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _summaryChip(String label, int count, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
//       child: Text('$label: $count',
//           style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w700)),
//     );
//   }
//
//   Widget _bottomBar(BuildContext context, ClassAttendanceModel att) {
//     final provider = context.watch<ClassAttendanceProvider>();
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
//         ),
//         child: Row(
//           children: [
//             if (!att.locked) ...[
//               OutlinedButton.icon(
//                 onPressed: () => context.read<ClassAttendanceProvider>().markAllPresent(),
//                 icon: const Icon(Icons.done_all_rounded, size: 16),
//                 label: const Text('All Present'),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: _purple,
//                   side: const BorderSide(color: _purple),
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//               const Spacer(),
//               ElevatedButton.icon(
//                 onPressed: provider.isSaving
//                     ? null
//                     : () async {
//                   final ok = await provider.submit();
//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(ok ? 'Attendance submitted' : (provider.error ?? 'Failed')),
//                         backgroundColor: ok ? Colors.green : Colors.red,
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                   }
//                 },
//                 icon: provider.isSaving
//                     ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : const Icon(Icons.check_rounded, size: 17),
//                 label: Text(provider.isSaving ? 'Saving...' : 'Submit Attendance'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _purple,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//               ),
//             ] else
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(color: _orange.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.lock_rounded, size: 15, color: _orange),
//                       const SizedBox(width: 8),
//                       Text('Attendance locked for this date',
//                           style: TextStyle(fontSize: 12.5, color: Colors.orange.shade800, fontWeight: FontWeight.w600)),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _StudentAttendanceRow extends StatelessWidget {
//   final AttendanceRecord record;
//   final bool locked;
//   final ValueChanged<AttendanceStatus> onChanged;
//
//   const _StudentAttendanceRow({required this.record, required this.locked, required this.onChanged});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFEEEEF5)),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 16,
//             backgroundColor: _purpleLight,
//             child: Text(
//               record.name.isNotEmpty ? record.name[0].toUpperCase() : 'S',
//               style: const TextStyle(color: _purple, fontWeight: FontWeight.bold, fontSize: 12),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               record.name.isNotEmpty ? record.name : 'Unnamed',
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//             ),
//           ),
//           const SizedBox(width: 8),
//           _statusSelector(context),
//         ],
//       ),
//     );
//   }
//
//   Widget _statusSelector(BuildContext context) {
//     return SizedBox(
//       width: 210,
//       child: Wrap(
//         spacing: 4,
//         runSpacing: 4,
//         alignment: WrapAlignment.end,
//         children: AttendanceStatus.values.map((s) {
//           final selected = record.status == s;
//           final color = _statusColor(s);
//           return InkWell(
//             borderRadius: BorderRadius.circular(8),
//             onTap: locked ? null : () => onChanged(s),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 120),
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//               decoration: BoxDecoration(
//                 color: selected ? color : color.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 _statusIcon(s),
//                 size: 16,
//                 color: selected ? Colors.white : color,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/class_attendance_model.dart';
import '../../models/class_model.dart';
import '../../providers/class_attendance_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/student_provider.dart';

const _purple = Color(0xFF534AB7);
const _purpleLight = Color(0xFFEEECFA);
const _green = Color(0xFF16A34A);
const _red = Color(0xFFDC2626);
const _orange = Color(0xFFD97706);
const _blue = Color(0xFF2563EB);
const _grayStatus = Color(0xFF6B7280);

// ★ Sunday = weekly holiday. Attendance cannot be marked or viewed
// for this date anywhere in the class attendance module.
bool isHolidayDate(DateTime date) => date.weekday == DateTime.sunday;

// ★ FIX: CalendarDatePicker asserts that `initialDate` satisfies
// `selectableDayPredicate`. Since today can itself be a Sunday (a
// holiday), passing `_selectedDate` (which defaults to DateTime.now())
// straight in as initialDate crashes the picker before it even opens.
// This walks backward day-by-day until it lands on a valid, non-holiday
// date that is also not after `lastDate`, and uses that for initialDate
// only — the actual selected/returned date is unaffected.
DateTime _nearestValidPickerDate(DateTime date, DateTime lastDate) {
  DateTime d = date.isAfter(lastDate) ? lastDate : date;
  int guard = 0;
  while (isHolidayDate(d) && guard < 14) {
    d = d.subtract(const Duration(days: 1));
    guard++;
  }
  return d;
}

Color _statusColor(AttendanceStatus s) {
  switch (s) {
    case AttendanceStatus.present: return _green;
    case AttendanceStatus.absent: return _red;
    case AttendanceStatus.leave: return _blue;
    case AttendanceStatus.late: return _orange;
    case AttendanceStatus.halfDay: return const Color(0xFF9333EA);
  }
}

IconData _statusIcon(AttendanceStatus s) {
  switch (s) {
    case AttendanceStatus.present: return Icons.check_circle_rounded;
    case AttendanceStatus.absent: return Icons.cancel_rounded;
    case AttendanceStatus.leave: return Icons.event_busy_rounded;
    case AttendanceStatus.late: return Icons.schedule_rounded;
    case AttendanceStatus.halfDay: return Icons.hourglass_bottom_rounded;
  }
}

class ClassAttendanceScreen extends StatefulWidget {
  final bool showAppBar;
  const ClassAttendanceScreen({super.key, this.showAppBar = true});

  @override
  State<ClassAttendanceScreen> createState() => _ClassAttendanceScreenState();
}

class _ClassAttendanceScreenState extends State<ClassAttendanceScreen> {
  String? _selectedClassId;
  String? _selectedSectionName;
  DateTime _selectedDate = DateTime.now();

  // ★ Desktop still uses the overlay-style dropdown calendar.
  final GlobalKey _dateChipKey = GlobalKey();
  OverlayEntry? _dateOverlayEntry;
  DateTime? _tempSelectedDate;

  bool get _isHoliday => isHolidayDate(_selectedDate);

  String get _dateKey =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void dispose() {
    _dateOverlayEntry?.remove();
    _dateOverlayEntry = null;
    super.dispose();
  }

  void _closeDateOverlay() {
    _dateOverlayEntry?.remove();
    _dateOverlayEntry = null;
  }

  // ★ Desktop dropdown-style calendar (unchanged — used only on wide screens).
  void _toggleDateOverlay() {
    if (_dateOverlayEntry != null) {
      _closeDateOverlay();
      return;
    }

    final renderBox =
    _dateChipKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final position = renderBox.localToGlobal(Offset.zero);
    final lastDate = DateTime.now();
    final initialDate = _nearestValidPickerDate(_selectedDate, lastDate);
    _tempSelectedDate = _selectedDate;

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
                          lastDate: lastDate,
                          selectableDayPredicate: (date) => !isHolidayDate(date),
                          onDateChanged: (date) {
                            _tempSelectedDate = date;
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text('Sundays are holidays',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _closeDateOverlay,
                              child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            TextButton(
                              onPressed: () {
                                final newDate = _tempSelectedDate ?? initialDate;
                                _closeDateOverlay();
                                setState(() => _selectedDate = newDate);
                                if (!isHolidayDate(newDate)) {
                                  _loadIfReady();
                                }
                              },
                              child: const Text('OK',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: _purple)),
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

  // ★ Mobile date picker — a real bottom sheet, always anchored to
  // the bottom of the screen and respecting SafeArea. No RenderBox
  // position math, so it can never end up mis-placed or clipped.
  Future<void> _openMobileDateSheet() async {
    final lastDate = DateTime.now();
    // ★ FIX: seed the sheet's temp/initial date with a value that is
    // guaranteed to satisfy selectableDayPredicate, even if
    // _selectedDate itself is currently a holiday (e.g. today = Sunday).
    DateTime tempDate = _nearestValidPickerDate(_selectedDate, lastDate);

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.only(top: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                      child: Row(
                        children: [
                          const Text('Select Date',
                              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => Navigator.of(sheetContext).pop(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 360,
                      child: CalendarDatePicker(
                        initialDate: tempDate,
                        firstDate: DateTime(2020),
                        lastDate: lastDate,
                        selectableDayPredicate: (date) => !isHolidayDate(date),
                        onDateChanged: (date) {
                          setSheetState(() => tempDate = date);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text('Sundays are holidays',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(tempDate),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _selectedDate = result);
      if (!isHolidayDate(result)) {
        _loadIfReady();
      }
    }
  }

  void _loadIfReady() {
    if (_selectedClassId == null || _selectedSectionName == null) return;
    if (_isHoliday) return; // ★ never fetch/mark attendance on a holiday

    final classes = context.read<ClassProvider>().classes;
    SchoolClass? cls;
    try {
      cls = classes.firstWhere((c) => c.id == _selectedClassId);
    } catch (_) {
      return;
    }

    final allStudents = context.read<StudentProvider>().students;
    final activeStudents = allStudents
        .where((s) =>
    s.student.className == cls!.name &&
        s.student.sectionName == _selectedSectionName &&
        s.student.isActive)
        .map((s) => MapEntry(s.student.studentId, s.student.name))
        .toList();

    context.read<ClassAttendanceProvider>().loadForClass(
      classId: _selectedClassId!,
      className: cls.name,
      sectionId: _selectedSectionName!,
      sectionName: _selectedSectionName!,
      date: _dateKey,
      activeStudents: activeStudents,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: widget.showAppBar
          ? AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        elevation: 0,
      )
          : null,
      body: isDesktop ? _buildDesktop() : _buildMobile(),
    );
  }

  // ═══════════════════ DESKTOP ═══════════════════
  Widget _buildDesktop() {
    final classes = context.watch<ClassProvider>().classes;

    return Row(
      children: [
        Container(
          width: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Color(0xFFE9E9F2))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Classes',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
              ),
              _dateSelector(),
              const Divider(height: 1),
              Expanded(
                child: classes.isEmpty
                    ? Center(child: Text('No classes found', style: TextStyle(color: Colors.grey.shade400)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: classes.length,
                  itemBuilder: (context, i) {
                    final cls = classes[i];
                    final sections = cls.sections.isNotEmpty
                        ? cls.sections.map((s) => s.sectionName).toList()
                        : <String>[];
                    return _ClassExpansionTile(
                      className: cls.name,
                      sections: sections,
                      isClassSelected: cls.id == _selectedClassId,
                      selectedSection: cls.id == _selectedClassId ? _selectedSectionName : null,
                      onSectionTap: (section) {
                        setState(() {
                          _selectedClassId = cls.id;
                          _selectedSectionName = section;
                        });
                        _loadIfReady();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: (_selectedClassId == null || _selectedSectionName == null)
              ? _emptySelectionState()
              : (_isHoliday
              ? _holidayState()
              : _AttendanceGrid(dateLabel: _fmtDate(_selectedDate))),
        ),
      ],
    );
  }

  // Desktop-only date chip (keeps the overlay dropdown behavior).
  Widget _dateSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        key: _dateChipKey,
        onTap: _toggleDateOverlay,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isHoliday ? const Color(0xFFFFF7ED) : _purpleLight,
            borderRadius: BorderRadius.circular(10),
            border: _isHoliday ? Border.all(color: _orange.withOpacity(0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 15, color: _isHoliday ? _orange : _purple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_fmtDate(_selectedDate),
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: _isHoliday ? _orange : _purple)),
              ),
              if (_isHoliday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('HOLIDAY',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _orange)),
                ),
              Icon(Icons.keyboard_arrow_down, size: 16, color: _isHoliday ? _orange : _purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptySelectionState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: _purpleLight, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.fact_check_outlined, size: 34, color: _purple),
          ),
          const SizedBox(height: 16),
          Text('Select a class & section', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text('Choose from the list to mark attendance', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _holidayState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.weekend_rounded, size: 34, color: _orange),
          ),
          const SizedBox(height: 16),
          Text('Sunday — Holiday', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text('Attendance cannot be marked or viewed on a holiday.',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  // ═══════════════════ MOBILE ═══════════════════
  Widget _buildMobile() {
    if (_selectedClassId == null || _selectedSectionName == null) {
      return _buildMobileClassPicker();
    }
    if (_isHoliday) {
      return SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    onPressed: () => setState(() {
                      _selectedClassId = null;
                      _selectedSectionName = null;
                      context.read<ClassAttendanceProvider>().clear();
                    }),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _openMobileDateSheet,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 15, color: _orange),
                            const SizedBox(width: 8),
                            Text(_fmtDate(_selectedDate),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _orange)),
                            const Spacer(),
                            const Icon(Icons.keyboard_arrow_down, size: 16, color: _orange),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _holidayState()),
          ],
        ),
      );
    }
    return SafeArea(
      child: _AttendanceGrid(
        dateLabel: _fmtDate(_selectedDate),
        onBack: () => setState(() {
          _selectedClassId = null;
          _selectedSectionName = null;
          context.read<ClassAttendanceProvider>().clear();
        }),
        onDateTap: _openMobileDateSheet,
      ),
    );
  }

  Widget _buildMobileClassPicker() {
    final classes = context.watch<ClassProvider>().classes;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
            child: Row(
              children: [
                // ★ Back arrow next to the calendar chip so the user can
                // leave this screen (e.g. back to the dashboard/menu)
                // without having to open the date sheet first.
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _openMobileDateSheet,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isHoliday ? const Color(0xFFFFF7ED) : _purpleLight,
                        borderRadius: BorderRadius.circular(10),
                        border: _isHoliday ? Border.all(color: _orange.withOpacity(0.3)) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 15, color: _isHoliday ? _orange : _purple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_fmtDate(_selectedDate),
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: _isHoliday ? _orange : _purple)),
                          ),
                          if (_isHoliday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: _orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('HOLIDAY',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _orange)),
                            ),
                          Icon(Icons.keyboard_arrow_down, size: 16, color: _isHoliday ? _orange : _purple),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: classes.isEmpty
                ? Center(child: Text('No classes found', style: TextStyle(color: Colors.grey.shade400)))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              itemCount: classes.length,
              itemBuilder: (context, i) {
                final cls = classes[i];
                final sections = cls.sections.isNotEmpty
                    ? cls.sections.map((s) => s.sectionName).toList()
                    : <String>[];
                return _MobileClassCard(
                  className: cls.name,
                  sections: sections,
                  onSectionTap: (section) {
                    setState(() {
                      _selectedClassId = cls.id;
                      _selectedSectionName = section;
                    });
                    _loadIfReady();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Desktop: class + expandable sections ──────────────────────
class _ClassExpansionTile extends StatelessWidget {
  final String className;
  final List<String> sections;
  final bool isClassSelected;
  final String? selectedSection;
  final ValueChanged<String> onSectionTap;

  const _ClassExpansionTile({
    required this.className,
    required this.sections,
    required this.isClassSelected,
    required this.selectedSection,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isClassSelected,
        title: Text(className, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        leading: const Icon(Icons.class_outlined, size: 18, color: _purple),
        childrenPadding: const EdgeInsets.only(left: 12, bottom: 6),
        children: sections.map((sec) {
          final selected = isClassSelected && selectedSection == sec;
          return Material(
            color: selected ? _purpleLight : Colors.transparent,
            child: InkWell(
              onTap: () => onSectionTap(sec),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.group_outlined, size: 15, color: selected ? _purple : Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(sec,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: selected ? _purple : Colors.grey.shade700,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Mobile: class card with section chips ────────────────────
class _MobileClassCard extends StatelessWidget {
  final String className;
  final List<String> sections;
  final ValueChanged<String> onSectionTap;

  const _MobileClassCard({required this.className, required this.sections, required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.class_outlined, size: 17, color: _purple),
              const SizedBox(width: 8),
              Text(className, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sections.map((sec) {
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSectionTap(sec),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(sec, style: const TextStyle(fontSize: 12.5, color: _purple, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Attendance marking grid — shared desktop/mobile ──────────
class _AttendanceGrid extends StatelessWidget {
  final String dateLabel;
  final VoidCallback? onBack;
  final VoidCallback? onDateTap;

  const _AttendanceGrid({required this.dateLabel, this.onBack, this.onDateTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassAttendanceProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _purple));
    }

    final attendance = provider.current;
    if (attendance == null) {
      return const Center(child: Text('No data'));
    }

    final records = attendance.records.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Column(
      children: [
        _header(context, attendance, onBack: onBack, onDateTap: onDateTap),
        if (provider.error != null) _errorBanner(context, provider),
        _summaryBar(attendance),
        Expanded(
          child: records.isEmpty
              ? Center(
            child: Text('No active students in this class',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
            itemCount: records.length,
            itemBuilder: (context, i) => _StudentAttendanceRow(
              record: records[i],
              locked: attendance.locked,
              onChanged: (status) =>
                  context.read<ClassAttendanceProvider>().setStatus(records[i].studentId, status),
            ),
          ),
        ),
        _bottomBar(context, attendance),
      ],
    );
  }

  Widget _header(BuildContext context, ClassAttendanceModel att,
      {VoidCallback? onBack, VoidCallback? onDateTap}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18), onPressed: onBack),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${att.className} — ${att.sectionName}',
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  att.locked ? '$dateLabel • Locked (already submitted)' : dateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: att.locked ? _orange : Colors.grey.shade500,
                    fontWeight: att.locked ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (onDateTap != null)
            IconButton(
              icon: const Icon(Icons.calendar_today_rounded, size: 18, color: _purple),
              onPressed: onDateTap,
            ),
          if (att.locked)
            TextButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Unlock attendance?'),
                    content: const Text('This will allow editing today\'s attendance again.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unlock')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await context.read<ClassAttendanceProvider>().unlock();
                }
              },
              icon: const Icon(Icons.lock_open_rounded, size: 15, color: _orange),
              label: const Text('Edit', style: TextStyle(color: _orange, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _errorBanner(BuildContext context, ClassAttendanceProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(provider.error!, style: TextStyle(fontSize: 12, color: Colors.red.shade700))),
          IconButton(icon: const Icon(Icons.close, size: 16), onPressed: provider.clearError),
        ],
      ),
    );
  }

  Widget _summaryBar(ClassAttendanceModel att) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _summaryChip('Total', att.totalCount, _grayStatus),
            const SizedBox(width: 8),
            _summaryChip('Present', att.presentCount, _green),
            const SizedBox(width: 8),
            _summaryChip('Absent', att.absentCount, _red),
            const SizedBox(width: 8),
            _summaryChip('Leave', att.leaveCount, _blue),
            const SizedBox(width: 8),
            _summaryChip('Late', att.lateCount, _orange),
            const SizedBox(width: 8),
            _summaryChip('Half Day', att.halfDayCount, const Color(0xFF9333EA)),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text('$label: $count',
          style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _bottomBar(BuildContext context, ClassAttendanceModel att) {
    final provider = context.watch<ClassAttendanceProvider>();
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            if (!att.locked) ...[
              OutlinedButton.icon(
                onPressed: () => context.read<ClassAttendanceProvider>().markAllPresent(),
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: const Text('All Present'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _purple,
                  side: const BorderSide(color: _purple),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: provider.isSaving
                    ? null
                    : () async {
                  final ok = await provider.submit();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Attendance submitted' : (provider.error ?? 'Failed')),
                        backgroundColor: ok ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: provider.isSaving
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded, size: 17),
                label: Text(provider.isSaving ? 'Saving...' : 'Submit Attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ] else
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: _orange.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_rounded, size: 15, color: _orange),
                      const SizedBox(width: 8),
                      Text('Attendance locked for this date',
                          style: TextStyle(fontSize: 12.5, color: Colors.orange.shade800, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StudentAttendanceRow extends StatelessWidget {
  final AttendanceRecord record;
  final bool locked;
  final ValueChanged<AttendanceStatus> onChanged;

  const _StudentAttendanceRow({required this.record, required this.locked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEF5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _purpleLight,
            child: Text(
              record.name.isNotEmpty ? record.name[0].toUpperCase() : 'S',
              style: const TextStyle(color: _purple, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              record.name.isNotEmpty ? record.name : 'Unnamed',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          _statusSelector(context),
        ],
      ),
    );
  }

  Widget _statusSelector(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.end,
        children: AttendanceStatus.values.map((s) {
          final selected = record.status == s;
          final color = _statusColor(s);
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: locked ? null : () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? color : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _statusIcon(s),
                size: 16,
                color: selected ? Colors.white : color,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}