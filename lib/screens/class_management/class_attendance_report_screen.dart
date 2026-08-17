// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../models/class_model.dart';
// import '../../models/class_attendance_model.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/class_attendance_report_provider.dart';
//
// // ============================================================
// // DESIGN TOKENS — matched to AttendanceReportScreen (employee side)
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
//
// const double _kDesktopBreakpoint = 900;
//
// // ============================================================
// // SHARED SMALL WIDGETS (standalone copies — same look as employee report)
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
// // ============================================================
// // WINDOWS-STYLE MONTH/YEAR PICKER (shared pattern)
// // ============================================================
// class MonthYearPickerResult {
//   final int year;
//   final int month;
//   MonthYearPickerResult(this.year, this.month);
// }
//
// Future<MonthYearPickerResult?> showMonthYearPicker({
//   required BuildContext context,
//   required int initialYear,
//   required int initialMonth,
// }) {
//   final currentYear = DateTime.now().year;
//   return showDialog<MonthYearPickerResult>(
//     context: context,
//     barrierColor: Colors.black.withOpacity(0.35),
//     builder: (context) => _MonthYearPickerDialog(
//       initialYear: initialYear,
//       initialMonth: initialMonth,
//       maxYear: currentYear,
//     ),
//   );
// }
//
// class _MonthYearPickerDialog extends StatefulWidget {
//   final int initialYear;
//   final int initialMonth;
//   final int maxYear;
//   const _MonthYearPickerDialog({required this.initialYear, required this.initialMonth, required this.maxYear});
//
//   @override
//   State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
// }
//
// class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
//   late int _year;
//   late int _month;
//   bool _showYearGrid = false;
//   late final ScrollController _yearScrollController;
//
//   static const int _minYear = 2015;
//
//   @override
//   void initState() {
//     super.initState();
//     _year = widget.initialYear;
//     _month = widget.initialMonth;
//     final index = _year - _minYear;
//     final estimatedOffset = (index ~/ 3) * 64.0;
//     _yearScrollController = ScrollController(initialScrollOffset: estimatedOffset > 0 ? estimatedOffset : 0);
//   }
//
//   @override
//   void dispose() {
//     _yearScrollController.dispose();
//     super.dispose();
//   }
//
//   void _goToPreviousYear() {
//     if (_year - 1 < _minYear) return;
//     setState(() => _year -= 1);
//   }
//
//   void _goToNextYear() {
//     if (_year + 1 > widget.maxYear) return;
//     setState(() => _year += 1);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 320),
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(),
//               const SizedBox(height: 14),
//               SizedBox(height: 260, child: _showYearGrid ? _buildYearGrid() : _buildMonthGrid()),
//               const SizedBox(height: 8),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w600, color: _kSlate)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Row(
//       children: [
//         IconButton(icon: const Icon(Icons.chevron_left, color: _kSlate), onPressed: _showYearGrid ? null : _goToPreviousYear),
//         Expanded(
//           child: Center(
//             child: InkWell(
//               borderRadius: BorderRadius.circular(8),
//               onTap: () => setState(() => _showYearGrid = !_showYearGrid),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('$_year', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kInk)),
//                     const SizedBox(width: 4),
//                     Icon(_showYearGrid ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: _kSlate),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.chevron_right, color: _kSlate),
//           onPressed: (_showYearGrid || _year + 1 > widget.maxYear) ? null : _goToNextYear,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMonthGrid() {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6),
//       itemCount: 12,
//       itemBuilder: (context, index) {
//         final month = index + 1;
//         final isFuture = _year == widget.maxYear && month > DateTime.now().month;
//         final isSelected = month == _month && _year == widget.initialYear;
//         final label = DateFormat('MMM').format(DateTime(0, month));
//         return _PickerCell(
//           label: label,
//           isSelected: isSelected,
//           isDisabled: isFuture,
//           onTap: isFuture ? null : () => Navigator.of(context).pop(MonthYearPickerResult(_year, month)),
//         );
//       },
//     );
//   }
//
//   Widget _buildYearGrid() {
//     final years = List.generate(widget.maxYear - _minYear + 1, (i) => _minYear + i);
//     return GridView.builder(
//       controller: _yearScrollController,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6),
//       itemCount: years.length,
//       itemBuilder: (context, index) {
//         final year = years[index];
//         return _PickerCell(
//           label: '$year',
//           isSelected: year == _year,
//           isDisabled: false,
//           onTap: () => setState(() {
//             _year = year;
//             _showYearGrid = false;
//           }),
//         );
//       },
//     );
//   }
// }
//
// class _PickerCell extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final bool isDisabled;
//   final VoidCallback? onTap;
//   const _PickerCell({required this.label, required this.isSelected, required this.isDisabled, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: isSelected ? _kPrimary : Colors.transparent,
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         onTap: onTap,
//         child: Container(
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: isSelected ? _kPrimary : _kBorder),
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: isDisabled ? Colors.grey.shade300 : (isSelected ? Colors.white : _kInk),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // ROOT SCREEN — Class-wise Attendance Report
// // Flow: Class+Section picker -> Report view (month/year, student list)
// // ============================================================
// class ClassAttendanceReportScreen extends StatefulWidget {
//   const ClassAttendanceReportScreen({super.key});
//
//   @override
//   State<ClassAttendanceReportScreen> createState() => _ClassAttendanceReportScreenState();
// }
//
// class _ClassAttendanceReportScreenState extends State<ClassAttendanceReportScreen> {
//   SchoolClass? _selectedClass;
//   String? _selectedSection;
//   int _selectedYear = DateTime.now().year;
//   int _selectedMonth = DateTime.now().month;
//   String _search = '';
//
//   void _load() {
//     if (_selectedClass == null || _selectedSection == null) return;
//     final classId = _selectedClass!.id;
//     if (classId == null) return; // safety: unsaved class has no id
//     context.read<ClassAttendanceReportProvider>().loadClassMonth(
//       classId: classId,
//       sectionId: _selectedSection!,
//       year: _selectedYear,
//       month: _selectedMonth,
//     );
//   }
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
//     final headerTitle = (_selectedClass == null || _selectedSection == null)
//         ? 'Class Attendance Report'
//         : '${_selectedClass!.name} — $_selectedSection';
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         titleSpacing: 20,
//         title: Text(headerTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: _kInk)),
//         backgroundColor: _kCard,
//         surfaceTintColor: _kCard,
//         foregroundColor: _kInk,
//         elevation: 0,
//         shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
//         leading: (_selectedClass == null || _selectedSection == null)
//             ? null
//             : IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => setState(() {
//             _selectedClass = null;
//             _selectedSection = null;
//             context.read<ClassAttendanceReportProvider>().clear();
//           }),
//         ),
//       ),
//       body: (_selectedClass == null || _selectedSection == null) ? _buildClassPicker() : _buildReportBody(),
//     );
//   }
//
//   // ---- Class + Section picker ----
//   Widget _buildClassPicker() {
//     final classes = context.watch<ClassProvider>().classes;
//     final filtered = _search.isEmpty
//         ? classes
//         : classes.where((c) => c.name.toLowerCase().contains(_search.toLowerCase())).toList();
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
//                 hintText: 'Search class',
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
//               ? const _EmptyState(message: 'No matching class found.')
//               : ListView.separated(
//             padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
//             itemCount: filtered.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 8),
//             itemBuilder: (ctx, index) => _buildClassTile(filtered[index]),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildClassTile(SchoolClass cls) {
//     final sections = cls.sections.map((s) => s.sectionName).toList();
//     if (sections.isEmpty) return const SizedBox.shrink();
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 34,
//                 height: 34,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(9)),
//                 child: const Icon(Icons.class_outlined, size: 17, color: _kPrimary),
//               ),
//               const SizedBox(width: 10),
//               Text(cls.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: _kInk)),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: sections.map((sec) {
//               return InkWell(
//                 borderRadius: BorderRadius.circular(20),
//                 onTap: () {
//                   setState(() {
//                     _selectedClass = cls;
//                     _selectedSection = sec;
//                     _selectedYear = DateTime.now().year;
//                     _selectedMonth = DateTime.now().month;
//                   });
//                   _load();
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                   decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(20)),
//                   child: Text(sec, style: const TextStyle(fontSize: 12.5, color: _kPrimary, fontWeight: FontWeight.w600)),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---- Report body ----
//   Widget _buildReportBody() {
//     final provider = context.watch<ClassAttendanceReportProvider>();
//
//     return LayoutBuilder(builder: (context, constraints) {
//       final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//       return SingleChildScrollView(
//         padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 16, isDesktop ? 28 : 16, 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildFilterRow(isDesktop),
//             const SizedBox(height: 14),
//             if (provider.isLoading)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 60),
//                 child: Center(child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5)),
//               )
//             else if (provider.error != null)
//               _ErrorState(message: provider.error!, onRetry: _load)
//             else if (provider.studentStats.isEmpty)
//                 const _EmptyState(message: 'No attendance marked for this class in this month yet.')
//               else ...[
//                   _buildClassSummaryCards(provider, isDesktop),
//                   const SizedBox(height: 14),
//                   Text('Student-wise Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
//                   const SizedBox(height: 8),
//                   _buildStudentTable(provider, isDesktop),
//                 ],
//           ],
//         ),
//       );
//     });
//   }
//
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
//   Widget _buildClassSummaryCards(ClassAttendanceReportProvider provider, bool isDesktop) {
//     final students = provider.studentStats;
//     final totalStudents = students.length;
//     final daysMarked = provider.daysMarkedInMonth;
//
//     final avgPct = students.isEmpty ? 0.0 : students.map((s) => s.percentage).reduce((a, b) => a + b) / students.length;
//
//     int totalPresent = 0, totalAbsent = 0, totalLeave = 0, totalLate = 0, totalHalf = 0;
//     for (final s in students) {
//       totalPresent += s.present;
//       totalAbsent += s.absent;
//       totalLeave += s.leave;
//       totalLate += s.late;
//       totalHalf += s.halfDay;
//     }
//
//     final cards = [
//       _SummaryCardData('Students', '$totalStudents', Icons.groups_outlined, _kPrimary, _kPrimaryLight),
//       _SummaryCardData('Days Marked', '$daysMarked', Icons.event_note_outlined, _kSlate, _kSurface),
//       _SummaryCardData('Present', '$totalPresent', Icons.check_circle_outline, _kGreen, _kGreenBg),
//       _SummaryCardData('Absent', '$totalAbsent', Icons.cancel_outlined, _kRed, _kRedBg),
//       _SummaryCardData('Leave', '$totalLeave', Icons.beach_access_outlined, _kBlue, _kBlueBg),
//       _SummaryCardData('Late', '$totalLate', Icons.schedule_outlined, _kOrange, _kOrangeBg),
//       _SummaryCardData('Half Day', '$totalHalf', Icons.hourglass_bottom_outlined, _kPurple, _kPurpleBg),
//       _SummaryCardData('Avg Attendance', '${avgPct.toStringAsFixed(1)}%', Icons.insights_outlined, _kPrimary, _kPrimaryLight),
//     ];
//
//     final columns = isDesktop ? 8 : 3;
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
//   Widget _buildStudentTable(ClassAttendanceReportProvider provider, bool isDesktop) {
//     final students = provider.studentStats;
//     if (!isDesktop) return _buildMobileStudentList(students);
//
//     return Container(
//       decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: const BoxDecoration(color: _kPrimaryDark, border: Border(bottom: BorderSide(color: _kBorder))),
//             child: Row(
//               children: [
//                 const SizedBox(width: 28, child: Text('#', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70))),
//                 Expanded(flex: 4, child: _headTxt('STUDENT')),
//                 Expanded(flex: 2, child: _headTxt('PRESENT')),
//                 Expanded(flex: 2, child: _headTxt('ABSENT')),
//                 Expanded(flex: 2, child: _headTxt('LEAVE')),
//                 Expanded(flex: 2, child: _headTxt('LATE')),
//                 Expanded(flex: 2, child: _headTxt('HALF')),
//                 Expanded(flex: 2, child: _headTxt('%')),
//               ],
//             ),
//           ),
//           ...List.generate(students.length, (i) {
//             final s = students[i];
//             return InkWell(
//               onTap: () => _openStudentDetail(s),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: i.isEven ? _kCard : _kSurface.withOpacity(0.6),
//                   border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(width: 28, child: Text('${i + 1}', style: const TextStyle(fontSize: 11.5, color: _kSlate))),
//                     Expanded(
//                       flex: 4,
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 13,
//                             backgroundColor: _kPrimaryLight,
//                             child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
//                                 style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary)),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(s.name,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(flex: 2, child: _cellTxt('${s.present}', _kGreen)),
//                     Expanded(flex: 2, child: _cellTxt('${s.absent}', _kRed)),
//                     Expanded(flex: 2, child: _cellTxt('${s.leave}', _kBlue)),
//                     Expanded(flex: 2, child: _cellTxt('${s.late}', _kOrange)),
//                     Expanded(flex: 2, child: _cellTxt('${s.halfDay}', _kPurple)),
//                     Expanded(flex: 2, child: _cellTxt('${s.percentage.toStringAsFixed(0)}%', _kPrimary, bold: true)),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _headTxt(String t) =>
//       Text(t, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.3));
//
//   Widget _cellTxt(String t, Color c, {bool bold = false}) =>
//       Text(t, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: c));
//
//   Widget _buildMobileStudentList(List<StudentMonthStat> students) {
//     return Column(
//       children: List.generate(students.length, (i) {
//         final s = students[i];
//         return InkWell(
//           borderRadius: BorderRadius.circular(10),
//           onTap: () => _openStudentDetail(s),
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 16,
//                       backgroundColor: _kPrimaryLight,
//                       child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
//                           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary)),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Text(s.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk)),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(20)),
//                       child: Text('${s.percentage.toStringAsFixed(0)}%',
//                           style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _kPrimary)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 Wrap(
//                   spacing: 6,
//                   runSpacing: 6,
//                   children: [
//                     _miniStatChip('P', s.present, _kGreen, _kGreenBg),
//                     _miniStatChip('A', s.absent, _kRed, _kRedBg),
//                     _miniStatChip('L', s.leave, _kBlue, _kBlueBg),
//                     _miniStatChip('Late', s.late, _kOrange, _kOrangeBg),
//                     _miniStatChip('Half', s.halfDay, _kPurple, _kPurpleBg),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _miniStatChip(String label, int count, Color color, Color bg) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
//       child: Text('$label: $count', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
//     );
//   }
//
//   void _openStudentDetail(StudentMonthStat stat) {
//     final provider = context.read<ClassAttendanceReportProvider>();
//     final entries = provider.dayEntriesForStudent(stat.studentId);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => _StudentDayDetailSheet(
//         stat: stat,
//         entries: entries,
//         monthLabel: DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // Day-by-day detail bottom sheet (tap a student row)
// // ============================================================
// class _StudentDayDetailSheet extends StatelessWidget {
//   final StudentMonthStat stat;
//   final List<DayStatusEntry> entries;
//   final String monthLabel;
//
//   const _StudentDayDetailSheet({required this.stat, required this.entries, required this.monthLabel});
//
//   Map<String, Object> _meta(AttendanceStatus s) {
//     switch (s) {
//       case AttendanceStatus.present:
//         return {'label': 'Present', 'color': _kGreen, 'bg': _kGreenBg, 'icon': Icons.check_circle_rounded};
//       case AttendanceStatus.absent:
//         return {'label': 'Absent', 'color': _kRed, 'bg': _kRedBg, 'icon': Icons.cancel_rounded};
//       case AttendanceStatus.leave:
//         return {'label': 'Leave', 'color': _kBlue, 'bg': _kBlueBg, 'icon': Icons.beach_access_rounded};
//       case AttendanceStatus.late:
//         return {'label': 'Late', 'color': _kOrange, 'bg': _kOrangeBg, 'icon': Icons.schedule_rounded};
//       case AttendanceStatus.halfDay:
//         return {'label': 'Half Day', 'color': _kPurple, 'bg': _kPurpleBg, 'icon': Icons.hourglass_bottom_rounded};
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.7,
//       minChildSize: 0.4,
//       maxChildSize: 0.92,
//       expand: false,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: _kCard,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               Container(width: 40, height: 4, decoration: BoxDecoration(color: _kBorder, borderRadius: BorderRadius.circular(4))),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 18,
//                       backgroundColor: _kPrimaryLight,
//                       child: Text(stat.name.isNotEmpty ? stat.name[0].toUpperCase() : '?',
//                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kPrimary)),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(stat.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _kInk)),
//                           Text(monthLabel, style: const TextStyle(fontSize: 12, color: _kSlate)),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(20)),
//                       child: Text('${stat.percentage.toStringAsFixed(1)}%',
//                           style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _kPrimary)),
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: _kBorder),
//               Expanded(
//                 child: entries.isEmpty
//                     ? const _EmptyState(message: 'No records for this student this month.')
//                     : ListView.separated(
//                   controller: scrollController,
//                   padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
//                   itemCount: entries.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 6),
//                   itemBuilder: (ctx, i) {
//                     final e = entries[i];
//                     final meta = _meta(e.status);
//                     return Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                       decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(10)),
//                       child: Row(
//                         children: [
//                           Icon(meta['icon'] as IconData, size: 16, color: meta['color'] as Color),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(DateFormat('EEEE, dd MMM yyyy').format(e.date),
//                                 style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(color: meta['bg'] as Color, borderRadius: BorderRadius.circular(20)),
//                             child: Text(meta['label'] as String,
//                                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: meta['color'] as Color)),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
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



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../models/class_attendance_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/class_attendance_provider.dart';
import '../../providers/class_attendance_report_provider.dart';

// ============================================================
// DESIGN TOKENS — matched to AttendanceReportScreen (employee side)
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
// SHARED SMALL WIDGETS
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
  final IconData icon;
  const _EmptyState({required this.message, this.icon = Icons.event_busy_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Row(
        children: [
          Icon(Icons.hourglass_top_rounded, size: 16, color: Colors.white),
          SizedBox(width: 10),
          Text('PDF export — coming soon', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      backgroundColor: _kPrimaryDark,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ============================================================
// WINDOWS-STYLE MONTH/YEAR PICKER (shared pattern)
// ============================================================
class MonthYearPickerResult {
  final int year;
  final int month;
  MonthYearPickerResult(this.year, this.month);
}

Future<MonthYearPickerResult?> showMonthYearPicker({
  required BuildContext context,
  required int initialYear,
  required int initialMonth,
}) {
  final currentYear = DateTime.now().year;
  return showDialog<MonthYearPickerResult>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (context) => _MonthYearPickerDialog(
      initialYear: initialYear,
      initialMonth: initialMonth,
      maxYear: currentYear,
    ),
  );
}

class _MonthYearPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int maxYear;
  const _MonthYearPickerDialog({required this.initialYear, required this.initialMonth, required this.maxYear});

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
    _yearScrollController = ScrollController(initialScrollOffset: estimatedOffset > 0 ? estimatedOffset : 0);
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
              SizedBox(height: 260, child: _showYearGrid ? _buildYearGrid() : _buildMonthGrid()),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w600, color: _kSlate)),
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
        IconButton(icon: const Icon(Icons.chevron_left, color: _kSlate), onPressed: _showYearGrid ? null : _goToPreviousYear),
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
                    Text('$_year', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _kInk)),
                    const SizedBox(width: 4),
                    Icon(_showYearGrid ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: _kSlate),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: _kSlate),
          onPressed: (_showYearGrid || _year + 1 > widget.maxYear) ? null : _goToNextYear,
        ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6),
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
          onTap: isFuture ? null : () => Navigator.of(context).pop(MonthYearPickerResult(_year, month)),
        );
      },
    );
  }

  Widget _buildYearGrid() {
    final years = List.generate(widget.maxYear - _minYear + 1, (i) => _minYear + i);
    return GridView.builder(
      controller: _yearScrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        return _PickerCell(
          label: '$year',
          isSelected: year == _year,
          isDisabled: false,
          onTap: () => setState(() {
            _year = year;
            _showYearGrid = false;
          }),
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
  const _PickerCell({required this.label, required this.isSelected, required this.isDisabled, required this.onTap});

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
            border: Border.all(color: isSelected ? _kPrimary : _kBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDisabled ? Colors.grey.shade300 : (isSelected ? Colors.white : _kInk),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ROOT SCREEN — Class-wise Attendance Report
// Flow: Class+Section picker -> Report view (Daily / Monthly tabs)
// ============================================================
class ClassAttendanceReportScreen extends StatefulWidget {
  const ClassAttendanceReportScreen({super.key});

  @override
  State<ClassAttendanceReportScreen> createState() => _ClassAttendanceReportScreenState();
}

class _ClassAttendanceReportScreenState extends State<ClassAttendanceReportScreen> {
  SchoolClass? _selectedClass;
  String? _selectedSection;
  String _search = '';

  // Daily tab state
  DateTime _selectedDate = DateTime.now();
  String _dailyFilter = 'present'; // all | present | absent | leave | late | halfDay

  // Monthly tab state
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  // 0 = Daily, 1 = Monthly
  int _tabIndex = 0;

  String get _dateKey =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  void _loadMonthly() {
    if (_selectedClass == null || _selectedSection == null) return;
    final classId = _selectedClass!.id;
    if (classId == null) return; // safety: unsaved class has no id
    context.read<ClassAttendanceReportProvider>().loadClassMonth(
      classId: classId,
      sectionId: _selectedSection!,
      year: _selectedYear,
      month: _selectedMonth,
    );
  }

  void _loadDaily() {
    if (_selectedClass == null || _selectedSection == null) return;
    final cls = _selectedClass!;
    if (cls.id == null) return;

    context.read<ClassAttendanceProvider>().loadForClass(
      classId: cls.id!,
      className: cls.name,
      sectionId: _selectedSection!,
      sectionName: _selectedSection!,
      date: _dateKey,
      activeStudents: const [], // report-only: don't seed an empty roster over saved records
    );
  }

  void _loadCurrentTab() {
    if (_tabIndex == 0) {
      _loadDaily();
    } else {
      _loadMonthly();
    }
  }

  Future<void> _openMonthYearPicker() async {
    final result = await showMonthYearPicker(context: context, initialYear: _selectedYear, initialMonth: _selectedMonth);
    if (result == null) return;
    setState(() {
      _selectedYear = result.year;
      _selectedMonth = result.month;
    });
    _loadMonthly();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadDaily();
    }
  }

  void _onTabChanged(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
    _loadCurrentTab();
  }

  @override
  Widget build(BuildContext context) {
    final headerTitle = (_selectedClass == null || _selectedSection == null)
        ? 'Class Attendance Report'
        : '${_selectedClass!.name} — $_selectedSection';

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(headerTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: _kInk)),
        backgroundColor: _kCard,
        surfaceTintColor: _kCard,
        foregroundColor: _kInk,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
        leading: (_selectedClass == null || _selectedSection == null)
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() {
            _selectedClass = null;
            _selectedSection = null;
            context.read<ClassAttendanceReportProvider>().clear();
          }),
        ),
      ),
      body: (_selectedClass == null || _selectedSection == null) ? _buildClassPicker() : _buildReportBody(),
    );
  }

  // ---- Class + Section picker ----
  Widget _buildClassPicker() {
    final classes = context.watch<ClassProvider>().classes;
    final filtered = _search.isEmpty
        ? classes
        : classes.where((c) => c.name.toLowerCase().contains(_search.toLowerCase())).toList();

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
                hintText: 'Search class',
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
              ? const _EmptyState(message: 'No matching class found.')
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) => _buildClassTile(filtered[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildClassTile(SchoolClass cls) {
    final sections = cls.sections.map((s) => s.sectionName).toList();
    if (sections.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.class_outlined, size: 17, color: _kPrimary),
              ),
              const SizedBox(width: 10),
              Text(cls.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: _kInk)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sections.map((sec) {
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _selectedClass = cls;
                    _selectedSection = sec;
                    _selectedYear = DateTime.now().year;
                    _selectedMonth = DateTime.now().month;
                    _selectedDate = DateTime.now();
                    _dailyFilter = 'present';
                    _tabIndex = 0;
                  });
                  _loadCurrentTab();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(20)),
                  child: Text(sec, style: const TextStyle(fontSize: 12.5, color: _kPrimary, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---- Report body: Daily / Monthly tabs ----
  Widget _buildReportBody() {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
      return Column(
        children: [
          _buildTabBar(isDesktop),
          Expanded(
            child: _tabIndex == 0 ? _DailyReportView(
              isDesktop: isDesktop,
              selectedDate: _selectedDate,
              filter: _dailyFilter,
              onPickDate: _pickDate,
              onFilterChanged: (f) => setState(() => _dailyFilter = f),
              onRetry: _loadDaily,
            ) : _MonthlyReportView(
              isDesktop: isDesktop,
              selectedYear: _selectedYear,
              selectedMonth: _selectedMonth,
              onOpenMonthYearPicker: _openMonthYearPicker,
              onRetry: _loadMonthly,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTabBar(bool isDesktop) {
    return Container(
      color: _kCard,
      padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 12, isDesktop ? 28 : 16, 0),
      child: Row(
        children: [
          _buildTabButton('Daily', Icons.today_rounded, 0),
          const SizedBox(width: 8),
          _buildTabButton('Monthly', Icons.calendar_view_month_rounded, 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, int index) {
    final selected = _tabIndex == index;
    return InkWell(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      onTap: () => _onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _kPrimaryLight : Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          border: Border(
            bottom: BorderSide(color: selected ? _kPrimary : Colors.transparent, width: 2.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? _kPrimary : _kSlate),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? _kPrimary : _kSlate)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DAILY REPORT VIEW — default: today, Present filter
// ============================================================
class _DailyReportView extends StatelessWidget {
  final bool isDesktop;
  final DateTime selectedDate;
  final String filter;
  final VoidCallback onPickDate;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onRetry;

  const _DailyReportView({
    required this.isDesktop,
    required this.selectedDate,
    required this.filter,
    required this.onPickDate,
    required this.onFilterChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassAttendanceProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 14, isDesktop ? 28 : 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateRow(context),
          const SizedBox(height: 14),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5)),
            )
          else if (provider.error != null)
            _ErrorState(message: provider.error!, onRetry: onRetry)
          else
            _buildContent(context, provider),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    final dateChip = InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 15, color: _kSlate),
            const SizedBox(width: 10),
            Text(DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk)),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
          ],
        ),
      ),
    );

    final exportButton = ElevatedButton.icon(
      onPressed: () => _showComingSoon(context),
      icon: const Icon(Icons.file_download_outlined, size: 16),
      label: const Text('Export PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
          ? Row(children: [dateChip, const Spacer(), exportButton])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [dateChip, const SizedBox(height: 10), exportButton]),
    );
  }

  Widget _buildContent(BuildContext context, ClassAttendanceProvider provider) {
    final attendance = provider.current;
    if (attendance == null || attendance.records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: _EmptyState(message: 'No attendance marked for this class on this date yet.'),
      );
    }

    final allRecords = attendance.records.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final filteredRecords = filter == 'all'
        ? allRecords
        : allRecords.where((r) => r.status.name == filter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryCards(attendance, isDesktop),
        const SizedBox(height: 14),
        _buildFilterChips(context, attendance),
        const SizedBox(height: 10),
        if (filteredRecords.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: _EmptyState(message: 'No students found for this filter.', icon: Icons.filter_alt_off_outlined),
          )
        else
          _buildStudentList(filteredRecords, isDesktop),
      ],
    );
  }

  Widget _buildSummaryCards(ClassAttendanceModel att, bool isDesktop) {
    final cards = [
      _SummaryCardData('Total', '${att.totalCount}', Icons.groups_outlined, _kSlate, _kSurface),
      _SummaryCardData('Present', '${att.presentCount}', Icons.check_circle_outline, _kGreen, _kGreenBg),
      _SummaryCardData('Absent', '${att.absentCount}', Icons.cancel_outlined, _kRed, _kRedBg),
      _SummaryCardData('Leave', '${att.leaveCount}', Icons.beach_access_outlined, _kBlue, _kBlueBg),
      _SummaryCardData('Late', '${att.lateCount}', Icons.schedule_outlined, _kOrange, _kOrangeBg),
      _SummaryCardData('Half Day', '${att.halfDayCount}', Icons.hourglass_bottom_outlined, _kPurple, _kPurpleBg),
    ];
    final columns = isDesktop ? 6 : 3;
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

  Widget _buildFilterChips(BuildContext context, ClassAttendanceModel att) {
    final chips = <_FilterChipData>[
      _FilterChipData('all', 'All', att.totalCount, _kGrey, _kGreyBg),
      _FilterChipData('present', 'Present', att.presentCount, _kGreen, _kGreenBg),
      _FilterChipData('absent', 'Absent', att.absentCount, _kRed, _kRedBg),
      _FilterChipData('leave', 'Leave', att.leaveCount, _kBlue, _kBlueBg),
      _FilterChipData('late', 'Late', att.lateCount, _kOrange, _kOrangeBg),
      _FilterChipData('halfDay', 'Half Day', att.halfDayCount, _kPurple, _kPurpleBg),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((c) {
          final selected = filter == c.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onFilterChanged(c.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? c.color : c.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? c.color : c.color.withOpacity(0.25)),
                ),
                child: Text('${c.label} (${c.count})',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : c.color)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStudentList(List<AttendanceRecord> records, bool isDesktop) {
    if (!isDesktop) return _buildMobileList(records);

    return Container(
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(color: _kPrimaryDark, border: Border(bottom: BorderSide(color: _kBorder))),
            child: Row(
              children: [
                const SizedBox(width: 28, child: Text('#', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70))),
                Expanded(flex: 5, child: _headTxt('STUDENT')),
                Expanded(flex: 3, child: _headTxt('STATUS')),
              ],
            ),
          ),
          ...List.generate(records.length, (i) {
            final r = records[i];
            final meta = _statusMeta(r.status);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: i.isEven ? _kCard : _kSurface.withOpacity(0.6),
                border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
              ),
              child: Row(
                children: [
                  SizedBox(width: 28, child: Text('${i + 1}', style: const TextStyle(fontSize: 11.5, color: _kSlate))),
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: _kPrimaryLight,
                          child: Text(r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(r.name.isNotEmpty ? r.name : 'Unnamed',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 3, child: _StatusBadge(meta: meta, compact: true)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _headTxt(String t) =>
      Text(t, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.3));

  Widget _buildMobileList(List<AttendanceRecord> records) {
    return Column(
      children: List.generate(records.length, (i) {
        final r = records[i];
        final meta = _statusMeta(r.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _kPrimaryLight,
                child: Text(r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(r.name.isNotEmpty ? r.name : 'Unnamed',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
              ),
              _StatusBadge(meta: meta),
            ],
          ),
        );
      }),
    );
  }
}

class _FilterChipData {
  final String key;
  final String label;
  final int count;
  final Color color;
  final Color bg;
  _FilterChipData(this.key, this.label, this.count, this.color, this.bg);
}

// ============================================================
// MONTHLY REPORT VIEW — unchanged flow, same look
// ============================================================
class _MonthlyReportView extends StatelessWidget {
  final bool isDesktop;
  final int selectedYear;
  final int selectedMonth;
  final VoidCallback onOpenMonthYearPicker;
  final VoidCallback onRetry;

  const _MonthlyReportView({
    required this.isDesktop,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onOpenMonthYearPicker,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassAttendanceReportProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 14, isDesktop ? 28 : 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterRow(context),
          const SizedBox(height: 14),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5)),
            )
          else if (provider.error != null)
            _ErrorState(message: provider.error!, onRetry: onRetry)
          else if (provider.studentStats.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: _EmptyState(message: 'No attendance marked for this class in this month yet.'),
              )
            else ...[
                _buildClassSummaryCards(provider, isDesktop),
                const SizedBox(height: 14),
                Text('Student-wise Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
                const SizedBox(height: 8),
                _buildStudentTable(context, provider, isDesktop),
              ],
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    final monthYearChip = InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onOpenMonthYearPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_outlined, size: 16, color: _kSlate),
            const SizedBox(width: 10),
            Text(DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth)),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _kInk)),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSlate),
          ],
        ),
      ),
    );

    final exportButton = ElevatedButton.icon(
      onPressed: () => _showComingSoon(context),
      icon: const Icon(Icons.file_download_outlined, size: 16),
      label: const Text('Export PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _buildClassSummaryCards(ClassAttendanceReportProvider provider, bool isDesktop) {
    final students = provider.studentStats;
    final totalStudents = students.length;
    final daysMarked = provider.daysMarkedInMonth;

    final avgPct = students.isEmpty ? 0.0 : students.map((s) => s.percentage).reduce((a, b) => a + b) / students.length;

    int totalPresent = 0, totalAbsent = 0, totalLeave = 0, totalLate = 0, totalHalf = 0;
    for (final s in students) {
      totalPresent += s.present;
      totalAbsent += s.absent;
      totalLeave += s.leave;
      totalLate += s.late;
      totalHalf += s.halfDay;
    }

    final cards = [
      _SummaryCardData('Students', '$totalStudents', Icons.groups_outlined, _kPrimary, _kPrimaryLight),
      _SummaryCardData('Days Marked', '$daysMarked', Icons.event_note_outlined, _kSlate, _kSurface),
      _SummaryCardData('Present', '$totalPresent', Icons.check_circle_outline, _kGreen, _kGreenBg),
      _SummaryCardData('Absent', '$totalAbsent', Icons.cancel_outlined, _kRed, _kRedBg),
      _SummaryCardData('Leave', '$totalLeave', Icons.beach_access_outlined, _kBlue, _kBlueBg),
      _SummaryCardData('Late', '$totalLate', Icons.schedule_outlined, _kOrange, _kOrangeBg),
      _SummaryCardData('Half Day', '$totalHalf', Icons.hourglass_bottom_outlined, _kPurple, _kPurpleBg),
      _SummaryCardData('Avg Attendance', '${avgPct.toStringAsFixed(1)}%', Icons.insights_outlined, _kPrimary, _kPrimaryLight),
    ];

    final columns = isDesktop ? 8 : 3;
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

  Widget _buildStudentTable(BuildContext context, ClassAttendanceReportProvider provider, bool isDesktop) {
    final students = provider.studentStats;
    if (!isDesktop) return _buildMobileStudentList(context, students);

    return Container(
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(color: _kPrimaryDark, border: Border(bottom: BorderSide(color: _kBorder))),
            child: Row(
              children: [
                const SizedBox(width: 28, child: Text('#', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70))),
                Expanded(flex: 4, child: _headTxt('STUDENT')),
                Expanded(flex: 2, child: _headTxt('PRESENT')),
                Expanded(flex: 2, child: _headTxt('ABSENT')),
                Expanded(flex: 2, child: _headTxt('LEAVE')),
                Expanded(flex: 2, child: _headTxt('LATE')),
                Expanded(flex: 2, child: _headTxt('HALF')),
                Expanded(flex: 2, child: _headTxt('%')),
              ],
            ),
          ),
          ...List.generate(students.length, (i) {
            final s = students[i];
            return InkWell(
              onTap: () => _openStudentDetail(context, s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: i.isEven ? _kCard : _kSurface.withOpacity(0.6),
                  border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('${i + 1}', style: const TextStyle(fontSize: 11.5, color: _kSlate))),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: _kPrimaryLight,
                            child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(s.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(flex: 2, child: _cellTxt('${s.present}', _kGreen)),
                    Expanded(flex: 2, child: _cellTxt('${s.absent}', _kRed)),
                    Expanded(flex: 2, child: _cellTxt('${s.leave}', _kBlue)),
                    Expanded(flex: 2, child: _cellTxt('${s.late}', _kOrange)),
                    Expanded(flex: 2, child: _cellTxt('${s.halfDay}', _kPurple)),
                    Expanded(flex: 2, child: _cellTxt('${s.percentage.toStringAsFixed(0)}%', _kPrimary, bold: true)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _headTxt(String t) =>
      Text(t, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.3));

  Widget _cellTxt(String t, Color c, {bool bold = false}) =>
      Text(t, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: c));

  Widget _buildMobileStudentList(BuildContext context, List<StudentMonthStat> students) {
    return Column(
      children: List.generate(students.length, (i) {
        final s = students[i];
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openStudentDetail(context, s),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _kPrimaryLight,
                      child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(s.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(20)),
                      child: Text('${s.percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _kPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _miniStatChip('P', s.present, _kGreen, _kGreenBg),
                    _miniStatChip('A', s.absent, _kRed, _kRedBg),
                    _miniStatChip('L', s.leave, _kBlue, _kBlueBg),
                    _miniStatChip('Late', s.late, _kOrange, _kOrangeBg),
                    _miniStatChip('Half', s.halfDay, _kPurple, _kPurpleBg),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _miniStatChip(String label, int count, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text('$label: $count', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
    );
  }

  void _openStudentDetail(BuildContext context, StudentMonthStat stat) {
    final provider = context.read<ClassAttendanceReportProvider>();
    final entries = provider.dayEntriesForStudent(stat.studentId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StudentDayDetailSheet(
        stat: stat,
        entries: entries,
        monthLabel: DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth)),
      ),
    );
  }
}

// ============================================================
// Day-by-day detail bottom sheet (tap a student row, monthly view)
// ============================================================
class _StudentDayDetailSheet extends StatelessWidget {
  final StudentMonthStat stat;
  final List<DayStatusEntry> entries;
  final String monthLabel;

  const _StudentDayDetailSheet({required this.stat, required this.entries, required this.monthLabel});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: _kBorder, borderRadius: BorderRadius.circular(4))),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _kPrimaryLight,
                      child: Text(stat.name.isNotEmpty ? stat.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kPrimary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(stat.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _kInk)),
                          Text(monthLabel, style: const TextStyle(fontSize: 12, color: _kSlate)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(20)),
                      child: Text('${stat.percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _kPrimary)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _kBorder),
              Expanded(
                child: entries.isEmpty
                    ? const _EmptyState(message: 'No records for this student this month.')
                    : ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) {
                    final e = entries[i];
                    final meta = _statusMeta(e.status);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Icon(meta['icon'] as IconData, size: 16, color: meta['color'] as Color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(DateFormat('EEEE, dd MMM yyyy').format(e.date),
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: meta['bg'] as Color, borderRadius: BorderRadius.circular(20)),
                            child: Text(meta['label'] as String,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: meta['color'] as Color)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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