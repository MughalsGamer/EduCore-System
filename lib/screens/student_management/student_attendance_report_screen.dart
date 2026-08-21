//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../models/class_attendance_model.dart';
// import '../../providers/student_provider.dart';
// import '../../providers/class_attendance_report_provider.dart';
// import '../../providers/class_provider.dart';
// import '../class_management/class_attendance_report_screen.dart';
//
// // ============================================================
// // DESIGN TOKENS — identical to employee AttendanceReportScreen
// // ============================================================
// const _kInk = Color(0xFF1F2937);
// const _kSlate = Color(0xFF64748B);
// const _kBorder = Color(0xFFE2E8F0);
// const _kSurface = Color(0xFFF8FAFC);
// const _kCard = Colors.white;
//
// const _kPrimary = Color(0xFF534AB7);
// const _kPrimaryDark = Color(0xFF433CA0);
// const _kPrimaryLight = Color(0xFFF0EFFE);
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
// const _kGrey = Color(0xFF475569);
// const _kGreyBg = Color(0xFFF1F5F9);
//
// const double _kDesktopBreakpoint = 900;
//
// Map<String, Object> _statusMeta(AttendanceStatus s) {
//   switch (s) {
//     case AttendanceStatus.present:
//       return {'label': 'Present', 'icon': Icons.check_circle_rounded, 'color': _kGreen, 'bg': _kGreenBg};
//     case AttendanceStatus.absent:
//       return {'label': 'Absent', 'icon': Icons.cancel_rounded, 'color': _kRed, 'bg': _kRedBg};
//     case AttendanceStatus.late:
//       return {'label': 'Late', 'icon': Icons.schedule_rounded, 'color': _kOrange, 'bg': _kOrangeBg};
//     case AttendanceStatus.leave:
//       return {'label': 'Leave', 'icon': Icons.beach_access_rounded, 'color': _kBlue, 'bg': _kBlueBg};
//     case AttendanceStatus.halfDay:
//       return {'label': 'Half Day', 'icon': Icons.hourglass_bottom_rounded, 'color': _kPurple, 'bg': _kPurpleBg};
//   }
// }
//
// // ============================================================
// // SHARED WIDGETS
// // ============================================================
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
//             Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: _kSlate)),
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
//             Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// void _showComingSoon(BuildContext context) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(
//       content: Row(
//         children: [
//           Icon(Icons.hourglass_top_rounded, size: 16, color: Colors.white),
//           SizedBox(width: 10),
//           Text('PDF export — coming soon', style: TextStyle(fontWeight: FontWeight.w600)),
//         ],
//       ),
//       backgroundColor: _kPrimaryDark,
//       behavior: SnackBarBehavior.floating,
//     ),
//   );
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
//         ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
//         style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w700, color: _kPrimary))
//         : null,
//   );
// }
//
// // ============================================================
// // ROOT SCREEN — Attendance Report (Student-wise)
// // Flow: Student picker -> Report view (month/year, summary, table)
// //
// // FIX: every time a student is selected (fresh open), the month/year
// // resets to "now" and a fresh load is triggered — so the report never
// // shows stale data left over from a previous student/session.
// // ============================================================
// class StudentAttendanceReportScreen extends StatefulWidget {
//   const StudentAttendanceReportScreen({super.key});
//
//   @override
//   State<StudentAttendanceReportScreen> createState() => _StudentAttendanceReportScreenState();
// }
//
// class _StudentAttendanceReportScreenState extends State<StudentAttendanceReportScreen> {
//   StudentRecord? _selectedStudent;
//   int _selectedYear = DateTime.now().year;
//   int _selectedMonth = DateTime.now().month;
//   String _search = '';
//
//   void _load() {
//     final s = _selectedStudent;
//     if (s == null) return;
//     context.read<ClassAttendanceReportProvider>().loadClassMonth(
//       classId: s.classId,
//       sectionId: s.sectionId,
//       year: _selectedYear,
//       month: _selectedMonth,
//     );
//   }
//
//   // Selecting a student always resets to the current month/year and
//   // triggers a fresh load, so no stale data from a previous view lingers.
//   void _selectStudent(StudentRecord student) {
//     setState(() {
//       _selectedStudent = student;
//       _selectedYear = DateTime.now().year;
//       _selectedMonth = DateTime.now().month;
//     });
//     _load();
//   }
//
//   // Clears everything (including provider state) when leaving the report,
//   // so the next student selected starts from a guaranteed-clean state.
//   void _backToPicker() {
//     setState(() => _selectedStudent = null);
//     context.read<ClassAttendanceReportProvider>().clear();
//   }
//
//   Future<void> _openMonthYearPicker() async {
//     final result = await showMonthYearPicker(context: context, initialYear: _selectedYear, initialMonth: _selectedMonth);
//     if (result == null) return;
//     setState(() {
//       _selectedYear = result.year;
//       _selectedMonth = result.month;
//     });
//     _load();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         titleSpacing: 20,
//         title: Text(
//           _selectedStudent == null ? 'Student Attendance Report' : _selectedStudent!.name,
//           style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: _kInk),
//         ),
//         backgroundColor: _kCard,
//         surfaceTintColor: _kCard,
//         foregroundColor: _kInk,
//         elevation: 0,
//         shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
//         leading: _selectedStudent == null
//             ? null
//             : IconButton(icon: const Icon(Icons.arrow_back), onPressed: _backToPicker),
//       ),
//       body: _selectedStudent == null ? _buildStudentPicker() : _buildReportBody(),
//     );
//   }
//
//   Widget _buildReportBody() {
//     final provider = context.watch<ClassAttendanceReportProvider>();
//     final stat = provider.statFor(_selectedStudent!.studentId);
//     final entries = provider.dayEntriesForStudent(_selectedStudent!.studentId);
//
//     return LayoutBuilder(builder: (context, constraints) {
//       final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//       return SingleChildScrollView(
//         padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildProfileHeader(isDesktop),
//             const SizedBox(height: 14),
//             _buildFilterRow(isDesktop),
//             const SizedBox(height: 14),
//             if (provider.isLoading)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 60),
//                 child: Center(child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5)),
//               )
//             else if (provider.error != null)
//               _ErrorState(message: provider.error!, onRetry: _load)
//             else if (entries.isEmpty)
//                 const _EmptyState(message: 'No attendance records for this month yet.')
//               else ...[
//                   _buildSummaryCards(stat, isDesktop),
//                   const SizedBox(height: 14),
//                   _buildReportTable(entries, isDesktop),
//                   const SizedBox(height: 10),
//                   Text('Showing 1 to ${entries.length} of ${entries.length} entries', style: const TextStyle(fontSize: 12, color: _kSlate)),
//                 ],
//           ],
//         ),
//       );
//     });
//   }
//
//   // ---- Student picker ----
//   // Student model has: id (String?), name, className, section — no
//   // studentId/classId/sectionName fields. We build a StudentRecord view-model
//   // here: id! for studentId (after filtering out unsaved students), and we
//   // resolve classId by matching className against ClassProvider's classes
//   // (also filtering out any class that hasn't been saved yet, i.e. id == null).
//   Widget _buildStudentPicker() {
//     final classProvider = context.watch<ClassProvider>();
//
//     // students getter already returns only active students,
//     // so no extra isActive filter is needed here.
//     final allStudentModels = context.watch<StudentProvider>().students;
//
//     final allStudents = allStudentModels
//         .map((s) {
//       final className = s.student.className ?? '';
//       final sectionName = s.student.sectionName ?? '';
//
//       final matchedClass = classProvider.classes
//           .where((c) => c.id != null && c.name == className)
//           .toList();
//       if (matchedClass.isEmpty) return null;
//
//       return StudentRecord(
//         studentId: s.student.studentId,
//         name: s.student.name,
//         className: className,
//         sectionId: sectionName,
//         sectionName: sectionName,
//         classId: matchedClass.first.id!,
//         imageBase64: null,
//       );
//     })
//         .whereType<StudentRecord>()
//         .toList();
//
//     final filtered = _search.isEmpty
//         ? allStudents
//         : allStudents.where((s) => s.name.toLowerCase().contains(_search.toLowerCase())).toList();
//
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//             child: TextField(
//               onChanged: (val) => setState(() => _search = val),
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Search student by name',
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
//               ? const _EmptyState(message: 'No matching student found.')
//               : ListView.separated(
//             padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
//             itemCount: filtered.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 8),
//             itemBuilder: (ctx, index) => _buildStudentTile(filtered[index]),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStudentTile(StudentRecord student) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(10),
//       onTap: () => _selectStudent(student),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//         child: Row(
//           children: [
//             _buildAvatar(student.imageBase64, student.name, size: 40),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(student.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: _kInk)),
//                   const SizedBox(height: 2),
//                   Text('${student.className} — ${student.sectionName}', style: const TextStyle(fontSize: 12, color: _kSlate)),
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
//   // ---- Profile header ----
//   Widget _buildProfileHeader(bool isDesktop) {
//     final student = _selectedStudent!;
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(colors: [_kPrimary, _kPrimaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(4),
//             decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//             child: _buildAvatar(student.imageBase64, student.name, size: 96),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(student.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: Colors.white)),
//                 const SizedBox(height: 6),
//                 Wrap(
//                   spacing: 10,
//                   runSpacing: 6,
//                   children: [
//                     _headerChip(student.className),
//                     _headerChip('Section ${student.sectionName}'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           TextButton.icon(
//             onPressed: _backToPicker,
//             icon: const Icon(Icons.swap_horiz, size: 16, color: Colors.white),
//             label: const Text('Change', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
//             style: TextButton.styleFrom(
//               backgroundColor: Colors.white.withOpacity(0.15),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
//       decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(6)),
//       child: Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
//     );
//   }
//
//   // ---- Filter row + PDF (coming soon) ----
//   // The month/year chip opens the calendar dropdown immediately on tap —
//   // no intermediate step.
//   Widget _buildFilterRow(bool isDesktop) {
//     final monthYearChip = InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: _openMonthYearPicker,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.calendar_month_outlined, size: 16, color: _kSlate),
//             const SizedBox(width: 10),
//             Text(DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
//                 style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk)),
//             const SizedBox(width: 6),
//             const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
//           ],
//         ),
//       ),
//     );
//
//     final exportButton = ElevatedButton.icon(
//       onPressed: () => _showComingSoon(context),
//       icon: const Icon(Icons.file_download_outlined, size: 16),
//       label: const Text('Export PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _kPrimary,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         elevation: 0,
//       ),
//     );
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//       child: isDesktop
//           ? Row(children: [monthYearChip, const Spacer(), exportButton])
//           : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [monthYearChip, const SizedBox(height: 10), exportButton]),
//     );
//   }
//
//   // ---- Summary Cards ----
//   Widget _buildSummaryCards(StudentMonthStat? stat, bool isDesktop) {
//     final present = stat?.present ?? 0;
//     final absent = stat?.absent ?? 0;
//     final leave = stat?.leave ?? 0;
//     final late = stat?.late ?? 0;
//     final halfDay = stat?.halfDay ?? 0;
//     final markedDays = stat?.markedDays ?? 0;
//     final pct = stat?.percentage ?? 0.0;
//
//     final cards = [
//       _SummaryCardData('Marked Days', '$markedDays', Icons.event_note_outlined, _kPrimary, _kPrimaryLight),
//       _SummaryCardData('Present', '$present', Icons.check_circle_outline, _kGreen, _kGreenBg),
//       _SummaryCardData('Absent', '$absent', Icons.cancel_outlined, _kRed, _kRedBg),
//       _SummaryCardData('Leave', '$leave', Icons.beach_access_outlined, _kBlue, _kBlueBg),
//       _SummaryCardData('Late', '$late', Icons.schedule_outlined, _kOrange, _kOrangeBg),
//       _SummaryCardData('Half Day', '$halfDay', Icons.hourglass_bottom_outlined, _kPurple, _kPurpleBg),
//       _SummaryCardData('Attendance %', '${pct.toStringAsFixed(1)}%', Icons.insights_outlined, _kPrimary, _kPrimaryLight),
//     ];
//
//     final columns = isDesktop ? 7 : 3;
//     return LayoutBuilder(builder: (context, constraints) {
//       const spacing = 8.0;
//       final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
//       return Wrap(
//         spacing: spacing,
//         runSpacing: spacing,
//         children: cards.map((c) => SizedBox(width: cardWidth, child: _SummaryCard(data: c))).toList(),
//       );
//     });
//   }
//
//   // ---- Report Table (day-by-day) ----
//   Widget _buildReportTable(List<DayStatusEntry> rows, bool isDesktop) {
//     if (!isDesktop) return _buildMobileList(rows);
//
//     final half = (rows.length / 2).ceil();
//     final leftRows = rows.sublist(0, half);
//     final rightRows = rows.sublist(half);
//
//     return Container(
//       decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
//       clipBehavior: Clip.antiAlias,
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(child: _buildTableColumn(leftRows, startIndex: 1)),
//             Container(width: 1, color: _kBorder),
//             Expanded(child: _buildTableColumn(rightRows, startIndex: half + 1)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTableColumn(List<DayStatusEntry> rows, {required int startIndex}) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
//           decoration: const BoxDecoration(color: _kPrimaryDark, border: Border(bottom: BorderSide(color: _kBorder))),
//           child: Row(
//             children: [
//               SizedBox(width: 22, child: Text('#', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85)))),
//               Expanded(
//                   flex: 3,
//                   child: Text('DATE',
//                       style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85), letterSpacing: 0.3))),
//               Expanded(
//                   flex: 3,
//                   child: Text('DAY',
//                       style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85), letterSpacing: 0.3))),
//               Expanded(
//                   flex: 3,
//                   child: Text('STATUS',
//                       style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85), letterSpacing: 0.3))),
//             ],
//           ),
//         ),
//         ...List.generate(rows.length, (i) {
//           final entry = rows[i];
//           final meta = _statusMeta(entry.status);
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//             decoration: BoxDecoration(
//               color: i.isEven ? _kCard : _kSurface.withOpacity(0.6),
//               border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
//             ),
//             child: Row(
//               children: [
//                 SizedBox(width: 22, child: Text('${startIndex + i}', style: const TextStyle(fontSize: 11.5, color: _kSlate))),
//                 Expanded(
//                   flex: 3,
//                   child: Text(DateFormat('dd-MMM-yyyy').format(entry.date),
//                       overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _kInk)),
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: Text(DateFormat('EEEE').format(entry.date), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _kSlate)),
//                 ),
//                 Expanded(flex: 3, child: _StatusBadge(meta: meta, compact: true)),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }
//
//   // ---- Mobile: stacked row-cards ----
//   Widget _buildMobileList(List<DayStatusEntry> rows) {
//     return Column(
//       children: List.generate(rows.length, (i) {
//         final entry = rows[i];
//         final meta = _statusMeta(entry.status);
//         return Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//           child: Row(
//             children: [
//               Container(
//                 width: 26,
//                 height: 26,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(7)),
//                 child: Text('${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary)),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(DateFormat('dd MMM yyyy').format(entry.date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
//                     const SizedBox(height: 2),
//                     Text(DateFormat('EEEE').format(entry.date), style: const TextStyle(fontSize: 11.5, color: _kSlate)),
//                   ],
//                 ),
//               ),
//               _StatusBadge(meta: meta),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }
//
// // A light view-model so this screen doesn't depend on the exact Student
// // model shape everywhere. Built in _buildStudentPicker() above by resolving
// // classId via ClassProvider (Student itself has no classId field).
// class StudentRecord {
//   final String studentId;
//   final String name;
//   final String className;
//   final String classId;
//   final String sectionId;
//   final String sectionName;
//   final String? imageBase64;
//
//   StudentRecord({
//     required this.studentId,
//     required this.name,
//     required this.className,
//     required this.classId,
//     required this.sectionId,
//     required this.sectionName,
//     this.imageBase64,
//   });
// }
//
// // ============================================================
// // SMALL COMPONENTS
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
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(color: data.bg, borderRadius: BorderRadius.circular(7)),
//             child: Icon(data.icon, size: 13, color: data.color),
//           ),
//           const SizedBox(height: 7),
//           Text(data.value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: data.color)),
//           const SizedBox(height: 1),
//           Text(data.label, style: const TextStyle(fontSize: 10, color: _kSlate), maxLines: 1, overflow: TextOverflow.ellipsis),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   final Map<String, Object> meta;
//   final bool compact;
//   const _StatusBadge({required this.meta, this.compact = false});
//
//   @override
//   Widget build(BuildContext context) {
//     final color = meta['color'] as Color;
//     final bg = meta['bg'] as Color;
//     final label = meta['label'] as String;
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 4),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.35))),
//       child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 10.5 : 11.5, fontWeight: FontWeight.w700, color: color)),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/class_attendance_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_attendance_report_provider.dart';
import '../../providers/class_provider.dart';
import '../../pdf_files/student_attendance_pdf_service.dart';
import '../class_management/class_attendance_report_screen.dart'; // <-- new import

// ============================================================
// DESIGN TOKENS — identical to employee AttendanceReportScreen
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

const double _kDesktopBreakpoint = 900;

Map<String, Object> _statusMeta(AttendanceStatus s) {
  switch (s) {
    case AttendanceStatus.present:
      return {'label': 'Present', 'icon': Icons.check_circle_rounded, 'color': _kGreen, 'bg': _kGreenBg};
    case AttendanceStatus.absent:
      return {'label': 'Absent', 'icon': Icons.cancel_rounded, 'color': _kRed, 'bg': _kRedBg};
    case AttendanceStatus.late:
      return {'label': 'Late', 'icon': Icons.schedule_rounded, 'color': _kOrange, 'bg': _kOrangeBg};
    case AttendanceStatus.leave:
      return {'label': 'Leave', 'icon': Icons.beach_access_rounded, 'color': _kBlue, 'bg': _kBlueBg};
    case AttendanceStatus.halfDay:
      return {'label': 'Half Day', 'icon': Icons.hourglass_bottom_rounded, 'color': _kPurple, 'bg': _kPurpleBg};
  }
}

// ============================================================
// SHARED WIDGETS
// ============================================================
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
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: _kSlate)),
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
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500)),
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
        ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w700, color: _kPrimary))
        : null,
  );
}

// ============================================================
// ROOT SCREEN — Attendance Report (Student-wise)
// ============================================================
class StudentAttendanceReportScreen extends StatefulWidget {
  const StudentAttendanceReportScreen({super.key});

  @override
  State<StudentAttendanceReportScreen> createState() => _StudentAttendanceReportScreenState();
}

class _StudentAttendanceReportScreenState extends State<StudentAttendanceReportScreen> {
  StudentRecord? _selectedStudent;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _search = '';
  bool _isExportingPdf = false;

  void _load() {
    final s = _selectedStudent;
    if (s == null) return;
    context.read<ClassAttendanceReportProvider>().loadClassMonth(
      classId: s.classId,
      sectionId: s.sectionId,
      year: _selectedYear,
      month: _selectedMonth,
    );
  }

  void _selectStudent(StudentRecord student) {
    setState(() {
      _selectedStudent = student;
      _selectedYear = DateTime.now().year;
      _selectedMonth = DateTime.now().month;
    });
    _load();
  }

  void _backToPicker() {
    setState(() => _selectedStudent = null);
    context.read<ClassAttendanceReportProvider>().clear();
  }

  Future<void> _openMonthYearPicker() async {
    final result = await showMonthYearPicker(context: context, initialYear: _selectedYear, initialMonth: _selectedMonth);
    if (result == null) return;
    setState(() {
      _selectedYear = result.year;
      _selectedMonth = result.month;
    });
    _load();
  }

  // Export PDF handler
  Future<void> _exportPdf() async {
    if (_selectedStudent == null || _isExportingPdf) return;
    final provider = context.read<ClassAttendanceReportProvider>();
    final stat = provider.statFor(_selectedStudent!.studentId);
    final entries = provider.dayEntriesForStudent(_selectedStudent!.studentId);

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No attendance data available for export.'), backgroundColor: _kRed),
      );
      return;
    }

    setState(() => _isExportingPdf = true);
    try {
      await StudentAttendancePdfService.generatePdf(
        student: _selectedStudent!,
        stat: stat,
        entries: entries,
        month: _selectedMonth,
        year: _selectedYear,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: _kRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          _selectedStudent == null ? 'Student Attendance Report' : _selectedStudent!.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: _kInk),
        ),
        backgroundColor: _kCard,
        surfaceTintColor: _kCard,
        foregroundColor: _kInk,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
        leading: _selectedStudent == null
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back), onPressed: _backToPicker),
      ),
      body: _selectedStudent == null ? _buildStudentPicker() : _buildReportBody(),
    );
  }

  Widget _buildReportBody() {
    final provider = context.watch<ClassAttendanceReportProvider>();
    final stat = provider.statFor(_selectedStudent!.studentId);
    final entries = provider.dayEntriesForStudent(_selectedStudent!.studentId);

    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(isDesktop),
            const SizedBox(height: 14),
            _buildFilterRow(isDesktop),
            const SizedBox(height: 14),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5)),
              )
            else if (provider.error != null)
              _ErrorState(message: provider.error!, onRetry: _load)
            else if (entries.isEmpty)
                const _EmptyState(message: 'No attendance records for this month yet.')
              else ...[
                  _buildSummaryCards(stat, isDesktop),
                  const SizedBox(height: 14),
                  _buildReportTable(entries, isDesktop),
                  const SizedBox(height: 10),
                  Text('Showing 1 to ${entries.length} of ${entries.length} entries', style: const TextStyle(fontSize: 12, color: _kSlate)),
                ],
          ],
        ),
      );
    });
  }

  // ---- Student picker (with actual image) ----
  Widget _buildStudentPicker() {
    final classProvider = context.watch<ClassProvider>();
    final allStudentModels = context.watch<StudentProvider>().students;

    final allStudents = allStudentModels
        .map((s) {
      final className = s.student.className ?? '';
      final sectionName = s.student.sectionName ?? '';
      final matchedClass = classProvider.classes
          .where((c) => c.id != null && c.name == className)
          .toList();
      if (matchedClass.isEmpty) return null;

      return StudentRecord(
        studentId: s.student.studentId,
        name: s.student.name,
        className: className,
        sectionId: sectionName,
        sectionName: sectionName,
        classId: matchedClass.first.id!,
        imageBase64: s.student.picBase64, // <-- actual image
        familyId: s.familyId, // optional if you want family ID in PDF
        familyName: s.familyName,
      );
    })
        .whereType<StudentRecord>()
        .toList();

    final filtered = _search.isEmpty
        ? allStudents
        : allStudents.where((s) => s.name.toLowerCase().contains(_search.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
            child: TextField(
              onChanged: (val) => setState(() => _search = val),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search student by name',
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
              ? const _EmptyState(message: 'No matching student found.')
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) => _buildStudentTile(filtered[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentTile(StudentRecord student) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _selectStudent(student),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
        child: Row(
          children: [
            _buildAvatar(student.imageBase64, student.name, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(student.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: _kInk)),
                  const SizedBox(height: 2),
                  Text('${student.className} — ${student.sectionName}', style: const TextStyle(fontSize: 12, color: _kSlate)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _kSlate),
          ],
        ),
      ),
    );
  }

  // ---- Profile header ----
  Widget _buildProfileHeader(bool isDesktop) {
    final student = _selectedStudent!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kPrimary, _kPrimaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: _buildAvatar(student.imageBase64, student.name, size: 96),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(student.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: Colors.white)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _headerChip(student.className),
                    _headerChip('Section ${student.sectionName}'),
                    if (student.familyId.isNotEmpty) _headerChip('Family ID: ${student.familyId}'),
                  ],
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _backToPicker,
            icon: const Icon(Icons.swap_horiz, size: 16, color: Colors.white),
            label: const Text('Change', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }

  // ---- Filter row + working Export PDF ----
  Widget _buildFilterRow(bool isDesktop) {
    final monthYearChip = InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _openMonthYearPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_outlined, size: 16, color: _kSlate),
            const SizedBox(width: 10),
            Text(DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk)),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
          ],
        ),
      ),
    );

    final exportButton = ElevatedButton.icon(
      onPressed: _isExportingPdf ? null : _exportPdf,
      icon: _isExportingPdf
          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.file_download_outlined, size: 16),
      label: Text(
        _isExportingPdf ? 'Preparing...' : 'Export PDF',
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
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
      child: isDesktop
          ? Row(children: [monthYearChip, const Spacer(), exportButton])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [monthYearChip, const SizedBox(height: 10), exportButton]),
    );
  }

  // ---- Summary Cards ----
  Widget _buildSummaryCards(StudentMonthStat? stat, bool isDesktop) {
    final present = stat?.present ?? 0;
    final absent = stat?.absent ?? 0;
    final leave = stat?.leave ?? 0;
    final late = stat?.late ?? 0;
    final halfDay = stat?.halfDay ?? 0;
    final markedDays = stat?.markedDays ?? 0;
    final pct = stat?.percentage ?? 0.0;

    final cards = [
      _SummaryCardData('Marked Days', '$markedDays', Icons.event_note_outlined, _kPrimary, _kPrimaryLight),
      _SummaryCardData('Present', '$present', Icons.check_circle_outline, _kGreen, _kGreenBg),
      _SummaryCardData('Absent', '$absent', Icons.cancel_outlined, _kRed, _kRedBg),
      _SummaryCardData('Leave', '$leave', Icons.beach_access_outlined, _kBlue, _kBlueBg),
      _SummaryCardData('Late', '$late', Icons.schedule_outlined, _kOrange, _kOrangeBg),
      _SummaryCardData('Half Day', '$halfDay', Icons.hourglass_bottom_outlined, _kPurple, _kPurpleBg),
      _SummaryCardData('Attendance %', '${pct.toStringAsFixed(1)}%', Icons.insights_outlined, _kPrimary, _kPrimaryLight),
    ];

    final columns = isDesktop ? 7 : 3;
    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 8.0;
      final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: cards.map((c) => SizedBox(width: cardWidth, child: _SummaryCard(data: c))).toList(),
      );
    });
  }

  // ---- Report Table (day-by-day) ----
  Widget _buildReportTable(List<DayStatusEntry> rows, bool isDesktop) {
    if (!isDesktop) return _buildMobileList(rows);

    final half = (rows.length / 2).ceil();
    final leftRows = rows.sublist(0, half);
    final rightRows = rows.sublist(half);

    return Container(
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildTableColumn(leftRows, startIndex: 1)),
            Container(width: 1, color: _kBorder),
            Expanded(child: _buildTableColumn(rightRows, startIndex: half + 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableColumn(List<DayStatusEntry> rows, {required int startIndex}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: const BoxDecoration(color: _kPrimaryDark, border: Border(bottom: BorderSide(color: _kBorder))),
          child: Row(
            children: [
              SizedBox(width: 22, child: Text('#', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85)))),
              Expanded(
                  flex: 3,
                  child: Text('DATE',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85), letterSpacing: 0.3))),
              Expanded(
                  flex: 3,
                  child: Text('DAY',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85), letterSpacing: 0.3))),
              Expanded(
                  flex: 3,
                  child: Text('STATUS',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85), letterSpacing: 0.3))),
            ],
          ),
        ),
        ...List.generate(rows.length, (i) {
          final entry = rows[i];
          final meta = _statusMeta(entry.status);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: i.isEven ? _kCard : _kSurface.withOpacity(0.6),
              border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
            ),
            child: Row(
              children: [
                SizedBox(width: 22, child: Text('${startIndex + i}', style: const TextStyle(fontSize: 11.5, color: _kSlate))),
                Expanded(
                  flex: 3,
                  child: Text(DateFormat('dd-MMM-yyyy').format(entry.date),
                      overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _kInk)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(DateFormat('EEEE').format(entry.date), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _kSlate)),
                ),
                Expanded(flex: 3, child: _StatusBadge(meta: meta, compact: true)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMobileList(List<DayStatusEntry> rows) {
    return Column(
      children: List.generate(rows.length, (i) {
        final entry = rows[i];
        final meta = _statusMeta(entry.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(7)),
                child: Text('${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(DateFormat('dd MMM yyyy').format(entry.date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
                    const SizedBox(height: 2),
                    Text(DateFormat('EEEE').format(entry.date), style: const TextStyle(fontSize: 11.5, color: _kSlate)),
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

// Updated StudentRecord to include family info for PDF
class StudentRecord {
  final String studentId;
  final String name;
  final String className;
  final String classId;
  final String sectionId;
  final String sectionName;
  final String? imageBase64;
  final String familyId;
  final String familyName;

  StudentRecord({
    required this.studentId,
    required this.name,
    required this.className,
    required this.classId,
    required this.sectionId,
    required this.sectionName,
    this.imageBase64,
    this.familyId = '',
    this.familyName = '',
  });
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
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: data.bg, borderRadius: BorderRadius.circular(7)),
            child: Icon(data.icon, size: 13, color: data.color),
          ),
          const SizedBox(height: 7),
          Text(data.value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: data.color)),
          const SizedBox(height: 1),
          Text(data.label, style: const TextStyle(fontSize: 10, color: _kSlate), maxLines: 1, overflow: TextOverflow.ellipsis),
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
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.35))),
      child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 10.5 : 11.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}