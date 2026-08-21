//
//
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../models/class_model.dart';
// import '../../models/class_attendance_model.dart';
// import '../../pdf_files/class_attendance_pdf_service.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/class_attendance_provider.dart';
// import '../../providers/class_attendance_report_provider.dart';
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
// const double _kTabletBreakpoint = 620;
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
// Color _pctColor(double pct) => pct >= 75 ? _kGreen : (pct >= 50 ? _kOrange : _kRed);
//
// // ============================================================
// // ATTENDANCE FILTER (used by the "Filters" button on dashboard)
// // ============================================================
// enum AttendanceFilterOption { all, good, average, low }
//
// extension AttendanceFilterOptionX on AttendanceFilterOption {
//   String get label {
//     switch (this) {
//       case AttendanceFilterOption.all:
//         return 'All Classes';
//       case AttendanceFilterOption.good:
//         return 'Good (≥ 75%)';
//       case AttendanceFilterOption.average:
//         return 'Average (50% – 74%)';
//       case AttendanceFilterOption.low:
//         return 'Low (< 50%)';
//     }
//   }
//
//   IconData get icon {
//     switch (this) {
//       case AttendanceFilterOption.all:
//         return Icons.apps_rounded;
//       case AttendanceFilterOption.good:
//         return Icons.check_circle_rounded;
//       case AttendanceFilterOption.average:
//         return Icons.schedule_rounded;
//       case AttendanceFilterOption.low:
//         return Icons.cancel_rounded;
//     }
//   }
//
//   Color get color {
//     switch (this) {
//       case AttendanceFilterOption.all:
//         return _kPrimary;
//       case AttendanceFilterOption.good:
//         return _kGreen;
//       case AttendanceFilterOption.average:
//         return _kOrange;
//       case AttendanceFilterOption.low:
//         return _kRed;
//     }
//   }
//
//   bool matches(double pct) {
//     switch (this) {
//       case AttendanceFilterOption.all:
//         return true;
//       case AttendanceFilterOption.good:
//         return pct >= 75;
//       case AttendanceFilterOption.average:
//         return pct >= 50 && pct < 75;
//       case AttendanceFilterOption.low:
//         return pct < 50;
//     }
//   }
// }
//
// /// Computes a class's overall present% across all its sections, using the
// /// already-loaded today's-attendance docs (byKey). Shared by the card UI
// /// and the dashboard's filter logic so both stay in sync.
// double classOverallPct(SchoolClass cls, Map<String, ClassAttendanceModel> byKey) {
//   int present = 0, total = 0;
//   for (final s in cls.sections) {
//     final doc = byKey['${cls.id}_${s.sectionName}'];
//     if (doc != null) {
//       present += doc.presentCount;
//       total += doc.totalCount;
//     }
//   }
//   return total == 0 ? 0.0 : (present / total) * 100;
// }
//
// // ============================================================
// // SHARED SMALL WIDGETS
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
//   final IconData icon;
//   const _EmptyState({required this.message, this.icon = Icons.event_busy_outlined});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 44, color: Colors.grey.shade300),
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
// // WINDOWS-STYLE MONTH/YEAR PICKER
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
// // BREADCRUMB (desktop only, like reference: Dashboard > Class Attendance > ...)
// // ============================================================
// class _Breadcrumb extends StatelessWidget {
//   final List<String> parts;
//   const _Breadcrumb({required this.parts});
//
//   @override
//   Widget build(BuildContext context) {
//     final children = <Widget>[];
//     for (var i = 0; i < parts.length; i++) {
//       final isLast = i == parts.length - 1;
//       children.add(Text(
//         parts[i],
//         style: TextStyle(
//           fontSize: 12.5,
//           fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
//           color: isLast ? _kSlate : _kPrimary,
//         ),
//       ));
//       if (!isLast) {
//         children.add(const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 6),
//           child: Icon(Icons.chevron_right_rounded, size: 14, color: _kSlate),
//         ));
//       }
//     }
//     return Row(children: children);
//   }
// }
//
// // ============================================================
// // ROOT SCREEN — Class-wise Attendance Report
// // Landing = "All Classes — Today" style dashboard (per reference image)
// // From there: tap a class row -> section-level drill-down -> Daily/Monthly tabs
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
//   String _search = '';
//
//   // View: 0 = dashboard (All classes today), 1 = class picker (search list)
//   // Daily tab state
//   DateTime _selectedDate = DateTime.now();
//   String _dailyFilter = 'present';
//
//   // Monthly tab state
//   int _selectedYear = DateTime.now().year;
//   int _selectedMonth = DateTime.now().month;
//
//   // 0 = Daily, 1 = Monthly (only relevant once a class+section is picked)
//   int _tabIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ClassAttendanceReportProvider>().loadAllClassesToday();
//     });
//   }
//
//   String get _dateKey =>
//       '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
//
//   void _loadMonthly() {
//     if (_selectedClass == null || _selectedSection == null) return;
//     final classId = _selectedClass!.id;
//     if (classId == null) return;
//     context.read<ClassAttendanceReportProvider>().loadClassMonth(
//       classId: classId,
//       sectionId: _selectedSection!,
//       year: _selectedYear,
//       month: _selectedMonth,
//     );
//   }
//
//   void _loadDaily() {
//     if (_selectedClass == null || _selectedSection == null) return;
//     final cls = _selectedClass!;
//     if (cls.id == null) return;
//
//     context.read<ClassAttendanceProvider>().loadForClass(
//       classId: cls.id!,
//       className: cls.name,
//       sectionId: _selectedSection!,
//       sectionName: _selectedSection!,
//       date: _dateKey,
//       activeStudents: const [],
//     );
//   }
//
//   void _loadCurrentTab() {
//     if (_tabIndex == 0) {
//       _loadDaily();
//     } else {
//       _loadMonthly();
//     }
//   }
//
//   Future<void> _openMonthYearPicker() async {
//     final result = await showMonthYearPicker(context: context, initialYear: _selectedYear, initialMonth: _selectedMonth);
//     if (result == null) return;
//     setState(() {
//       _selectedYear = result.year;
//       _selectedMonth = result.month;
//     });
//     _loadMonthly();
//   }
//
//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() => _selectedDate = picked);
//       _loadDaily();
//     }
//   }
//
//   void _onTabChanged(int index) {
//     if (_tabIndex == index) return;
//     setState(() => _tabIndex = index);
//     _loadCurrentTab();
//   }
//
//   void _openClassSection(SchoolClass cls, String section) {
//     setState(() {
//       _selectedClass = cls;
//       _selectedSection = section;
//       _selectedYear = DateTime.now().year;
//       _selectedMonth = DateTime.now().month;
//       _selectedDate = DateTime.now();
//       _dailyFilter = 'present';
//       _tabIndex = 0;
//     });
//     _loadCurrentTab();
//   }
//
//   void _goBackToDashboard() {
//     setState(() {
//       _selectedClass = null;
//       _selectedSection = null;
//       _search = '';
//     });
//     context.read<ClassAttendanceReportProvider>().clear();
//   }
//
//   bool get _inDrillDown => _selectedClass != null && _selectedSection != null;
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;
//
//       final headerTitle = !_inDrillDown ? 'Class Attendance Report' : '${_selectedClass!.name} — $_selectedSection';
//
//       final breadcrumbParts = !_inDrillDown
//           ? const ['Dashboard', 'Class Attendance', 'Class Attendance Report']
//           : ['Dashboard', 'Class Attendance', 'Class Attendance Report', '${_selectedClass!.name} — $_selectedSection'];
//
//       return Scaffold(
//         backgroundColor: _kSurface,
//         appBar: isDesktop
//             ? null
//             : AppBar(
//
//           titleSpacing: 4,
//           title: Text(headerTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _kInk)),
//           backgroundColor: _kCard,
//           surfaceTintColor: _kCard,
//           foregroundColor: _kInk,
//           elevation: 0,
//           shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
//           leading: _inDrillDown
//               ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBackToDashboard)
//               : null,
//           actions: [
//             IconButton(
//               tooltip: 'Export PDF',
//               icon: _isExportingPdf
//                   ? const SizedBox(
//                 width: 18,
//                 height: 18,
//                 child: CircularProgressIndicator(strokeWidth: 2, color: _kPrimary),
//               )
//                   : const Icon(Icons.picture_as_pdf_outlined, color: _kPrimary),
//               onPressed: _isExportingPdf ? null : () => _exportTodayPdf(context),
//             ),
//           ],
//
//         ),
//         body: SafeArea(
//           top: isDesktop,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               if (isDesktop) _buildDesktopPageHeader(headerTitle, breadcrumbParts),
//               Expanded(
//                 child: _inDrillDown ? _buildReportBody(isDesktop) : _buildDashboardBody(isDesktop),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   // ---- Desktop-only page header (title + breadcrumb, like reference) ----
//   Widget _buildDesktopPageHeader(String title, List<String> breadcrumbParts) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
//       decoration: const BoxDecoration(
//         color: _kCard,
//         border: Border(bottom: BorderSide(color: _kBorder)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (_inDrillDown)
//             Padding(
//               padding: const EdgeInsets.only(right: 12, top: 2),
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(8),
//                 onTap: _goBackToDashboard,
//                 child: Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
//                   child: const Icon(Icons.arrow_back, size: 18, color: _kInk),
//                 ),
//               ),
//             ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _kInk)),
//                 const SizedBox(height: 6),
//                 _Breadcrumb(parts: breadcrumbParts),
//               ],
//             ),
//           ),
//           if (_inDrillDown)
//             ElevatedButton.icon(
//               onPressed: () => _showComingSoon(context),
//               icon: const Icon(Icons.file_download_outlined, size: 16),
//               label: const Text('Download Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _kPrimary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 elevation: 0,
//               ),
//             )
//           else
//             _buildExportPdfButton(context),
//         ],
//       ),
//     );
//   }
//
//
//   bool _isExportingPdf = false;
//
//   Widget _buildExportPdfButton(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: _isExportingPdf ? null : () => _exportTodayPdf(context),
//       icon: _isExportingPdf
//           ? const SizedBox(
//         width: 14,
//         height: 14,
//         child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//       )
//           : const Icon(Icons.file_download_outlined, size: 16),
//       label: Text(
//         _isExportingPdf ? 'Preparing...' : 'Export PDF',
//         style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _kPrimary,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         elevation: 0,
//       ),
//     );
//   }
//
//   Future<void> _exportTodayPdf(BuildContext context) async {
//     final reportProvider = context.read<ClassAttendanceReportProvider>();
//     final docs = reportProvider.todayDocs;
//
//     if (docs.isEmpty || docs.every((d) => d.records.isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No attendance marked for today yet.'),
//           backgroundColor: _kRed,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isExportingPdf = true);
//     try {
//       await ClassAttendancePdfService.generateAndOpen(docs);
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to generate PDF: $e'),
//             backgroundColor: _kRed,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isExportingPdf = false);
//     }
//   }
//
//   // ================================================================
//   // DASHBOARD BODY — "All Classes — Today" landing page (per reference)
//   // ================================================================
//   Widget _buildDashboardBody(bool isDesktop) {
//     return _DashboardView(
//       isDesktop: isDesktop,
//       search: _search,
//       onSearchChanged: (v) => setState(() => _search = v),
//       onOpenClassSection: _openClassSection,
//     );
//   }
//
//   // ================================================================
//   // REPORT BODY (drilled into a class+section): Daily / Monthly tabs
//   // ================================================================
//   Widget _buildReportBody(bool isDesktop) {
//     return Column(
//       children: [
//         _buildTabBar(isDesktop),
//         Expanded(
//           child: _tabIndex == 0
//               ? _DailyReportView(
//             isDesktop: isDesktop,
//             selectedDate: _selectedDate,
//             filter: _dailyFilter,
//             onPickDate: _pickDate,
//             onFilterChanged: (f) => setState(() => _dailyFilter = f),
//             onRetry: _loadDaily,
//           )
//               : _MonthlyReportView(
//             isDesktop: isDesktop,
//             selectedYear: _selectedYear,
//             selectedMonth: _selectedMonth,
//             onOpenMonthYearPicker: _openMonthYearPicker,
//             onRetry: _loadMonthly,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTabBar(bool isDesktop) {
//     return Container(
//       color: _kCard,
//       padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 12, isDesktop ? 28 : 16, 0),
//       child: Row(
//         children: [
//           _buildTabButton('Daily', Icons.today_rounded, 0),
//           const SizedBox(width: 8),
//           _buildTabButton('Monthly', Icons.calendar_view_month_rounded, 1),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTabButton(String label, IconData icon, int index) {
//     final selected = _tabIndex == index;
//     return InkWell(
//       borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
//       onTap: () => _onTabChanged(index),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: selected ? _kPrimaryLight : Colors.transparent,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
//           border: Border(
//             bottom: BorderSide(color: selected ? _kPrimary : Colors.transparent, width: 2.5),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 15, color: selected ? _kPrimary : _kSlate),
//             const SizedBox(width: 7),
//             Text(label,
//                 style: TextStyle(
//                     fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? _kPrimary : _kSlate)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // DASHBOARD VIEW — matches reference image:
// // search bar + filters, 6 stat cards, "Classes & Sections" list
// // with expandable class rows -> section rows -> chevron detail.
// // Now with a WORKING "Filters" (attendance %) sheet and a WORKING
// // Grid / List view switcher.
// // ============================================================
// class _DashboardView extends StatefulWidget {
//   final bool isDesktop;
//   final String search;
//   final ValueChanged<String> onSearchChanged;
//   final void Function(SchoolClass cls, String section) onOpenClassSection;
//
//   const _DashboardView({
//     required this.isDesktop,
//     required this.search,
//     required this.onSearchChanged,
//     required this.onOpenClassSection,
//   });
//
//   @override
//   State<_DashboardView> createState() => _DashboardViewState();
// }
//
// class _DashboardViewState extends State<_DashboardView> {
//   // Which class ids are expanded to show their sections.
//   final Set<String> _expandedClassIds = {};
//   bool _gridView = true;
//   AttendanceFilterOption _attendanceFilter = AttendanceFilterOption.all;
//
//   void _toggleExpand(SchoolClass cls) {
//     setState(() {
//       final key = cls.id ?? cls.name;
//       if (_expandedClassIds.contains(key)) {
//         _expandedClassIds.remove(key);
//       } else {
//         _expandedClassIds.add(key);
//       }
//     });
//   }
//
//   Future<void> _openFiltersSheet(BuildContext context) async {
//     final result = await showModalBottomSheet<AttendanceFilterOption>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (ctx) => _FiltersSheet(current: _attendanceFilter),
//     );
//     if (result != null && mounted) {
//       setState(() => _attendanceFilter = result);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final reportProvider = context.watch<ClassAttendanceReportProvider>();
//     final classProvider = context.watch<ClassProvider>();
//
//     if (reportProvider.isLoadingToday) {
//       return const Center(child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5));
//     }
//     if (reportProvider.todayError != null) {
//       return _ErrorState(
//         message: reportProvider.todayError!,
//         onRetry: () => context.read<ClassAttendanceReportProvider>().loadAllClassesToday(),
//       );
//     }
//
//     final classes = classProvider.classes;
//     final todayDocs = reportProvider.todayDocs;
//
//     // Map className+sectionName -> doc for quick per-section lookup.
//     final Map<String, ClassAttendanceModel> byKey = {
//       for (final d in todayDocs) '${d.classId}_${d.sectionId}': d,
//     };
//
//     // Search + attendance-% filter combined.
//     final filteredClasses = classes.where((c) {
//       final matchesSearch =
//           widget.search.isEmpty || c.name.toLowerCase().contains(widget.search.toLowerCase());
//       if (!matchesSearch) return false;
//       if (_attendanceFilter == AttendanceFilterOption.all) return true;
//       final pct = classOverallPct(c, byKey);
//       return _attendanceFilter.matches(pct);
//     }).toList();
//
//     int totalClasses = classes.length;
//     int totalPresent = 0, totalAbsent = 0, totalLate = 0, totalLeave = 0, totalMarkedStudents = 0;
//     for (final d in todayDocs) {
//       totalPresent += d.presentCount;
//       totalAbsent += d.absentCount;
//       totalLate += d.lateCount;
//       totalLeave += d.leaveCount;
//       totalMarkedStudents += d.totalCount;
//     }
//     final overallPct = totalMarkedStudents == 0 ? 0.0 : (totalPresent / totalMarkedStudents) * 100;
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.fromLTRB(
//         widget.isDesktop ? 28 : 14,
//         widget.isDesktop ? 20 : 14,
//         widget.isDesktop ? 28 : 14,
//         24,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildSearchRow(context),
//           if (_attendanceFilter != AttendanceFilterOption.all) ...[
//             const SizedBox(height: 10),
//             _buildActiveFilterChip(),
//           ],
//           const SizedBox(height: 16),
//           _buildTopStatRow(
//             isDesktop: widget.isDesktop,
//             totalClasses: totalClasses,
//             totalPresent: totalPresent,
//             totalAbsent: totalAbsent,
//             totalLate: totalLate,
//             totalLeave: totalLeave,
//             overallPct: overallPct,
//           ),
//           const SizedBox(height: 20),
//           _buildSectionHeader(context, filteredClasses.length),
//           const SizedBox(height: 12),
//           if (filteredClasses.isEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 40),
//               child: _EmptyState(
//                 message: _attendanceFilter == AttendanceFilterOption.all
//                     ? 'No matching class found.'
//                     : 'No classes match "${_attendanceFilter.label}".',
//               ),
//             )
//           else if (widget.isDesktop && _gridView)
//             _buildClassesGrid(filteredClasses, byKey)
//           else
//             _buildClassesList(filteredClasses, byKey),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActiveFilterChip() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: () => setState(() => _attendanceFilter = AttendanceFilterOption.all),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//           decoration: BoxDecoration(
//             color: _attendanceFilter.color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: _attendanceFilter.color.withOpacity(0.35)),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(_attendanceFilter.icon, size: 14, color: _attendanceFilter.color),
//               const SizedBox(width: 6),
//               Text(_attendanceFilter.label,
//                   style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _attendanceFilter.color)),
//               const SizedBox(width: 6),
//               Icon(Icons.close_rounded, size: 14, color: _attendanceFilter.color),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildClassesList(List<SchoolClass> list, Map<String, ClassAttendanceModel> byKey) {
//     return Column(
//       children: list
//           .map((cls) => Padding(
//         padding: const EdgeInsets.only(bottom: 12),
//         child: _ClassExpandCard(
//           cls: cls,
//           isDesktop: widget.isDesktop,
//           compact: false,
//           expanded: _expandedClassIds.contains(cls.id ?? cls.name),
//           byKey: byKey,
//           onToggleExpand: () => _toggleExpand(cls),
//           onOpenSection: (section) => widget.onOpenClassSection(cls, section),
//         ),
//       ))
//           .toList(),
//     );
//   }
//
//   Widget _buildClassesGrid(List<SchoolClass> list, Map<String, ClassAttendanceModel> byKey) {
//     return LayoutBuilder(builder: (context, constraints) {
//       const spacing = 12.0;
//       final cardWidth = (constraints.maxWidth - spacing) / 2;
//       return Wrap(
//         spacing: spacing,
//         runSpacing: spacing,
//         children: list
//             .map((cls) => SizedBox(
//           width: cardWidth,
//           child: _ClassExpandCard(
//             cls: cls,
//             isDesktop: widget.isDesktop,
//             compact: true,
//             expanded: _expandedClassIds.contains(cls.id ?? cls.name),
//             byKey: byKey,
//             onToggleExpand: () => _toggleExpand(cls),
//             onOpenSection: (section) => widget.onOpenClassSection(cls, section),
//           ),
//         ))
//             .toList(),
//       );
//     });
//   }
//
//   Widget _buildSearchRow(BuildContext context) {
//     final searchField = Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//       child: TextField(
//         onChanged: widget.onSearchChanged,
//         decoration: const InputDecoration(
//           border: InputBorder.none,
//           hintText: 'Search class, grade or section...',
//           hintStyle: TextStyle(fontSize: 13.5, color: _kSlate),
//           prefixIcon: Icon(Icons.search, size: 20, color: _kSlate),
//         ),
//         style: const TextStyle(fontSize: 13.5, color: _kInk),
//       ),
//     );
//
//     final hasActiveFilter = _attendanceFilter != AttendanceFilterOption.all;
//     final filterButton = OutlinedButton.icon(
//       onPressed: () => _openFiltersSheet(context),
//       icon: Icon(Icons.filter_list_rounded, size: 17, color: hasActiveFilter ? _kPrimary : _kSlate),
//       label: Text(
//         hasActiveFilter ? 'Filters • 1' : 'Filters',
//         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: hasActiveFilter ? _kPrimary : _kInk),
//       ),
//       style: OutlinedButton.styleFrom(
//         backgroundColor: hasActiveFilter ? _kPrimaryLight : _kCard,
//         side: BorderSide(color: hasActiveFilter ? _kPrimary : _kBorder),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//
//     if (widget.isDesktop) {
//       return Row(children: [Expanded(child: searchField), const SizedBox(width: 12), filterButton]);
//     }
//     return Column(children: [searchField, const SizedBox(height: 10), filterButton]);
//   }
//
//   Widget _buildTopStatRow({
//     required bool isDesktop,
//     required int totalClasses,
//     required int totalPresent,
//     required int totalAbsent,
//     required int totalLate,
//     required int totalLeave,
//     required double overallPct,
//   }) {
//     final cards = [
//       _DashStatData('All Classes', '$totalClasses', 'Total Classes', Icons.groups_2_rounded, _kPrimary, _kPrimaryLight),
//       _DashStatData('Present Today', '$totalPresent', 'Students', Icons.check_circle_rounded, _kGreen, _kGreenBg),
//       _DashStatData('Absent Today', '$totalAbsent', 'Students', Icons.cancel_rounded, _kRed, _kRedBg),
//       _DashStatData('Late Today', '$totalLate', 'Students', Icons.schedule_rounded, _kOrange, _kOrangeBg),
//       _DashStatData('Leave Today', '$totalLeave', 'Students', Icons.calendar_month_rounded, _kBlue, _kBlueBg),
//       _DashStatData('Overall Attendance', '${overallPct.toStringAsFixed(1)}%', 'Average', Icons.pie_chart_rounded, _kPrimary, _kPrimaryLight),
//     ];
//     final columns = isDesktop ? 6 : (MediaQuery.of(context).size.width >= _kTabletBreakpoint ? 3 : 2);
//     return LayoutBuilder(builder: (context, constraints) {
//       const spacing = 10.0;
//       final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
//       return Wrap(
//         spacing: spacing,
//         runSpacing: spacing,
//         children: cards.map((c) => SizedBox(width: cardWidth, child: _DashStatCard(data: c, compact: !isDesktop))).toList(),
//       );
//     });
//   }
//
//   Widget _buildSectionHeader(BuildContext context, int count) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Text('Classes & Sections', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: _kInk)),
//               SizedBox(height: 2),
//               Text('View attendance summary by class and section', style: TextStyle(fontSize: 12, color: _kSlate)),
//             ],
//           ),
//         ),
//         if (widget.isDesktop)
//           Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _viewToggleBtn(Icons.grid_view_rounded, true),
//                 _viewToggleBtn(Icons.view_list_rounded, false),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _viewToggleBtn(IconData icon, bool value) {
//     final selected = _gridView == value;
//     return InkWell(
//       borderRadius: BorderRadius.circular(7),
//       onTap: () => setState(() => _gridView = value),
//       child: Container(
//         padding: const EdgeInsets.all(7),
//         decoration: BoxDecoration(color: selected ? _kPrimary : Colors.transparent, borderRadius: BorderRadius.circular(7)),
//         child: Icon(icon, size: 16, color: selected ? Colors.white : _kSlate),
//       ),
//     );
//   }
// }
//
// // ============================================================
// // FILTERS BOTTOM SHEET — pick an attendance-% band to filter
// // the "Classes & Sections" list by.
// // ============================================================
// class _FiltersSheet extends StatefulWidget {
//   final AttendanceFilterOption current;
//   const _FiltersSheet({required this.current});
//
//   @override
//   State<_FiltersSheet> createState() => _FiltersSheetState();
// }
//
// class _FiltersSheetState extends State<_FiltersSheet> {
//   late AttendanceFilterOption _selected;
//
//   @override
//   void initState() {
//     super.initState();
//     _selected = widget.current;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         margin: const EdgeInsets.all(12),
//         decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(18)),
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.only(bottom: 14),
//                   decoration: BoxDecoration(color: _kBorder, borderRadius: BorderRadius.circular(4)),
//                 ),
//               ),
//               Row(
//                 children: [
//                   const Icon(Icons.filter_list_rounded, size: 18, color: _kPrimary),
//                   const SizedBox(width: 8),
//                   const Expanded(
//                     child: Text('Filter by Attendance', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: _kInk)),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close_rounded, size: 20, color: _kSlate),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               const Text('Show only classes whose overall attendance today falls in:',
//                   style: TextStyle(fontSize: 12, color: _kSlate)),
//               const SizedBox(height: 14),
//               ...AttendanceFilterOption.values.map((opt) => _optionTile(opt)),
//               const SizedBox(height: 6),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => setState(() => _selected = AttendanceFilterOption.all),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: _kSlate,
//                         side: const BorderSide(color: _kBorder),
//                         padding: const EdgeInsets.symmetric(vertical: 13),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       ),
//                       child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w700)),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     flex: 2,
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.of(context).pop(_selected),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _kPrimary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 13),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                         elevation: 0,
//                       ),
//                       child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.w700)),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _optionTile(AttendanceFilterOption opt) {
//     final selected = _selected == opt;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () => setState(() => _selected = opt),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           decoration: BoxDecoration(
//             color: selected ? opt.color.withOpacity(0.08) : _kSurface,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: selected ? opt.color : _kBorder),
//           ),
//           child: Row(
//             children: [
//               Icon(opt.icon, size: 18, color: opt.color),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(opt.label,
//                     style: TextStyle(
//                         fontSize: 13, fontWeight: FontWeight.w700, color: selected ? opt.color : _kInk)),
//               ),
//               Icon(
//                 selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
//                 size: 18,
//                 color: selected ? opt.color : _kSlate,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ---- Small data holder for top stat cards ----
// class _DashStatData {
//   final String label;
//   final String value;
//   final String sublabel;
//   final IconData icon;
//   final Color color;
//   final Color bg;
//   _DashStatData(this.label, this.value, this.sublabel, this.icon, this.color, this.bg);
// }
//
// class _DashStatCard extends StatelessWidget {
//   final _DashStatData data;
//   final bool compact;
//   const _DashStatCard({required this.data, this.compact = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(compact ? 12 : 16),
//       decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: compact ? 32 : 40,
//             height: compact ? 32 : 40,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(color: data.bg, borderRadius: BorderRadius.circular(10)),
//             child: Icon(data.icon, size: compact ? 16 : 19, color: data.color),
//           ),
//           SizedBox(height: compact ? 8 : 12),
//           Text(data.label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _kSlate), maxLines: 1, overflow: TextOverflow.ellipsis),
//           const SizedBox(height: 4),
//           Text(data.value, style: TextStyle(fontSize: compact ? 19 : 23, fontWeight: FontWeight.w800, color: _kInk)),
//           const SizedBox(height: 1),
//           Text(data.sublabel, style: const TextStyle(fontSize: 10.5, color: _kSlate)),
//         ],
//       ),
//     );
//   }
// }
//
// // ============================================================
// // CLASS EXPAND CARD — one class row that expands to show its
// // sections; each section row is tappable to open the Daily/Monthly
// // report for that class+section.
// //
// // `compact` = true forces the narrower, mobile-style layout even on
// // desktop — used automatically when the dashboard is in Grid view
// // (2 cards per row leaves less horizontal room per card).
// // ============================================================
// class _ClassExpandCard extends StatelessWidget {
//   final SchoolClass cls;
//   final bool isDesktop;
//   final bool compact;
//   final bool expanded;
//   final Map<String, ClassAttendanceModel> byKey;
//   final VoidCallback onToggleExpand;
//   final ValueChanged<String> onOpenSection;
//
//   const _ClassExpandCard({
//     required this.cls,
//     required this.isDesktop,
//     required this.compact,
//     required this.expanded,
//     required this.byKey,
//     required this.onToggleExpand,
//     required this.onOpenSection,
//   });
//
//   bool get _useWideLayout => isDesktop && !compact;
//
//   @override
//   Widget build(BuildContext context) {
//     final sections = cls.sections.map((s) => s.sectionName).toList();
//     if (sections.isEmpty) return const SizedBox.shrink();
//
//     // Aggregate today's totals across this class's sections (from already-loaded docs).
//     int present = 0, absent = 0, late = 0, leave = 0, halfDay = 0, total = 0;
//     for (final sec in sections) {
//       final doc = byKey['${cls.id}_$sec'];
//       if (doc != null) {
//         present += doc.presentCount;
//         absent += doc.absentCount;
//         late += doc.lateCount;
//         leave += doc.leaveCount;
//         halfDay += doc.halfDayCount;
//         total += doc.totalCount;
//       }
//     }
//     final overallPct = total == 0 ? 0.0 : (present / total) * 100;
//     int totalStudents = 0;
//     for (final sec in sections) {
//       totalStudents += (byKey['${cls.id}_$sec']?.totalCount ?? 0);
//     }
//
//     return Container(
//       decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         children: [
//           InkWell(
//             onTap: onToggleExpand,
//             child: Padding(
//               padding: const EdgeInsets.all(14),
//               child: _useWideLayout
//                   ? _buildDesktopHeaderRow(sections, present, absent, late, leave, overallPct, totalStudents)
//                   : _buildMobileHeaderRow(sections, present, absent, late, leave, overallPct, totalStudents),
//             ),
//           ),
//           AnimatedCrossFade(
//             duration: const Duration(milliseconds: 180),
//             crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
//             firstChild: _buildSectionsList(context, sections),
//             secondChild: const SizedBox(width: double.infinity, height: 0),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _classIcon() {
//     return Container(
//       width: 38,
//       height: 38,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(10)),
//       child: const Icon(Icons.menu_book_rounded, size: 18, color: _kPrimary),
//     );
//   }
//
//   Widget _sectionCountPill(int count) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
//       decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(20)),
//       child: Text('$count ${count == 1 ? 'Section' : 'Sections'}',
//           style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _kPrimary)),
//     );
//   }
//
//   Widget _miniStatBox(String label, int value, String pctLabel, Color color, Color bg) {
//     return Container(
//       constraints: const BoxConstraints(minWidth: 68),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
//           const SizedBox(height: 2),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.baseline,
//             textBaseline: TextBaseline.alphabetic,
//             children: [
//               Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
//               const SizedBox(width: 4),
//               Text(pctLabel, style: TextStyle(fontSize: 9.5, color: color.withOpacity(0.75))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _overallRing(double pct) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           width: 46,
//           height: 46,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 width: 46,
//                 height: 46,
//                 child: CircularProgressIndicator(
//                   value: (pct / 100).clamp(0, 1),
//                   strokeWidth: 4.5,
//                   backgroundColor: _kBorder,
//                   valueColor: AlwaysStoppedAnimation(_pctColor(pct)),
//                 ),
//               ),
//               Text('${pct.toStringAsFixed(0)}%',
//                   style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: _pctColor(pct))),
//             ],
//           ),
//         ),
//         const SizedBox(height: 3),
//         const Text('Overall', style: TextStyle(fontSize: 9.5, color: _kSlate)),
//       ],
//     );
//   }
//
//   Widget _buildDesktopHeaderRow(List<String> sections, int present, int absent, int late, int leave, double overallPct, int totalStudents) {
//     final total = present + absent + late + leave;
//     return Row(
//       children: [
//         _classIcon(),
//         const SizedBox(width: 12),
//         SizedBox(
//           width: 190,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(children: [
//                 Flexible(child: Text(cls.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _kInk))),
//                 const SizedBox(width: 8),
//                 _sectionCountPill(sections.length),
//               ]),
//               const SizedBox(height: 4),
//               Text('Total Students: $totalStudents', style: const TextStyle(fontSize: 11.5, color: _kSlate)),
//             ],
//           ),
//         ),
//         const Spacer(),
//         _miniStatBox('Present', present, total == 0 ? '0%' : '${(present / total * 100).toStringAsFixed(0)}%', _kGreen, _kGreenBg),
//         const SizedBox(width: 8),
//         _miniStatBox('Absent', absent, total == 0 ? '0%' : '${(absent / total * 100).toStringAsFixed(0)}%', _kRed, _kRedBg),
//         const SizedBox(width: 8),
//         _miniStatBox('Late', late, total == 0 ? '0%' : '${(late / total * 100).toStringAsFixed(0)}%', _kOrange, _kOrangeBg),
//         const SizedBox(width: 8),
//         _miniStatBox('Leave', leave, total == 0 ? '0%' : '${(leave / total * 100).toStringAsFixed(0)}%', _kBlue, _kBlueBg),
//         const SizedBox(width: 16),
//         _overallRing(overallPct),
//         const SizedBox(width: 10),
//         Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _kSlate),
//       ],
//     );
//   }
//
//   Widget _buildMobileHeaderRow(List<String> sections, int present, int absent, int late, int leave, double overallPct, int totalStudents) {
//     final total = present + absent + late + leave;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             _classIcon(),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(children: [
//                     Flexible(child: Text(cls.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: _kInk))),
//                     const SizedBox(width: 8),
//                     _sectionCountPill(sections.length),
//                   ]),
//                   const SizedBox(height: 2),
//                   Text('Total Students: $totalStudents', style: const TextStyle(fontSize: 11, color: _kSlate)),
//                 ],
//               ),
//             ),
//             Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _kSlate),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(child: _miniStatBox('Present', present, total == 0 ? '0%' : '${(present / total * 100).toStringAsFixed(0)}%', _kGreen, _kGreenBg)),
//             const SizedBox(width: 8),
//             Expanded(child: _miniStatBox('Absent', absent, total == 0 ? '0%' : '${(absent / total * 100).toStringAsFixed(0)}%', _kRed, _kRedBg)),
//             const SizedBox(width: 8),
//             _overallRing(overallPct),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSectionsList(BuildContext context, List<String> sections) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: _kSurface,
//         border: Border(top: BorderSide(color: _kBorder)),
//       ),
//       child: Column(
//         children: sections.map((sec) {
//           final doc = byKey['${cls.id}_$sec'];
//           final present = doc?.presentCount ?? 0;
//           final absent = doc?.absentCount ?? 0;
//           final late = doc?.lateCount ?? 0;
//           final leave = doc?.leaveCount ?? 0;
//           final studentCount = doc?.totalCount ?? 0;
//           final total = present + absent + late + leave;
//           final pct = total == 0 ? 0.0 : (present / total) * 100;
//
//           return InkWell(
//             onTap: () => onOpenSection(sec),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: const BoxDecoration(border: Border(top: BorderSide(color: _kBorder, width: 0.6))),
//               child: _useWideLayout
//                   ? Row(
//                 children: [
//                   Container(
//                     width: 6,
//                     height: 6,
//                     margin: const EdgeInsets.only(right: 10),
//                     decoration: const BoxDecoration(color: _kPrimary, shape: BoxShape.circle),
//                   ),
//                   Expanded(
//                     flex: 3,
//                     child: Text('${cls.name} $sec', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
//                   ),
//                   Expanded(
//                     flex: 2,
//                     child: Row(children: [
//                       const Icon(Icons.people_outline_rounded, size: 14, color: _kSlate),
//                       const SizedBox(width: 4),
//                       Text('$studentCount Students', style: const TextStyle(fontSize: 11.5, color: _kSlate)),
//                     ]),
//                   ),
//                   Expanded(flex: 2, child: _sectionStatusText('✓', present, total == 0 ? 0 : (present / total * 100), _kGreen)),
//                   Expanded(flex: 2, child: _sectionStatusText('✕', absent, total == 0 ? 0 : (absent / total * 100), _kRed)),
//                   Expanded(flex: 2, child: _sectionStatusText('◔', late, total == 0 ? 0 : (late / total * 100), _kOrange)),
//                   Expanded(flex: 2, child: _sectionStatusText('▤', leave, total == 0 ? 0 : (leave / total * 100), _kBlue)),
//                   const SizedBox(width: 8),
//                   const Icon(Icons.chevron_right_rounded, size: 18, color: _kSlate),
//                 ],
//               )
//                   : Row(
//                 children: [
//                   Container(
//                     width: 6,
//                     height: 6,
//                     margin: const EdgeInsets.only(right: 10),
//                     decoration: const BoxDecoration(color: _kPrimary, shape: BoxShape.circle),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text('${cls.name} $sec', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
//                         const SizedBox(height: 3),
//                         Text('$studentCount Students', style: const TextStyle(fontSize: 11, color: _kSlate)),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: (pct >= 75 ? _kGreen : (pct >= 50 ? _kOrange : _kRed)).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text('${pct.toStringAsFixed(0)}%',
//                         style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _pctColor(pct))),
//                   ),
//                   const SizedBox(width: 6),
//                   const Icon(Icons.chevron_right_rounded, size: 18, color: _kSlate),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _sectionStatusText(String symbol, int value, double pct, Color color) {
//     return Row(
//       children: [
//         Text(symbol, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w800)),
//         const SizedBox(width: 5),
//         Text('$value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
//         const SizedBox(width: 4),
//         Text('(${pct.toStringAsFixed(0)}%)', style: TextStyle(fontSize: 10.5, color: color.withOpacity(0.75))),
//       ],
//     );
//   }
// }
//
// // ============================================================
// // DAILY REPORT VIEW — default: today, Present filter
// // ============================================================
// class _DailyReportView extends StatelessWidget {
//   final bool isDesktop;
//   final DateTime selectedDate;
//   final String filter;
//   final VoidCallback onPickDate;
//   final ValueChanged<String> onFilterChanged;
//   final VoidCallback onRetry;
//
//   const _DailyReportView({
//     required this.isDesktop,
//     required this.selectedDate,
//     required this.filter,
//     required this.onPickDate,
//     required this.onFilterChanged,
//     required this.onRetry,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<ClassAttendanceProvider>();
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 14, isDesktop ? 28 : 16, 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildDateRow(context),
//           const SizedBox(height: 14),
//           if (provider.isLoading)
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 60),
//               child: Center(child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5)),
//             )
//           else if (provider.error != null)
//             _ErrorState(message: provider.error!, onRetry: onRetry)
//           else
//             _buildContent(context, provider),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDateRow(BuildContext context) {
//     final dateChip = InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: onPickDate,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.calendar_today_rounded, size: 15, color: _kSlate),
//             const SizedBox(width: 10),
//             Text(DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
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
//           ? Row(children: [dateChip, const Spacer(), exportButton])
//           : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [dateChip, const SizedBox(height: 10), exportButton]),
//     );
//   }
//
//   Widget _buildContent(BuildContext context, ClassAttendanceProvider provider) {
//     final attendance = provider.current;
//     if (attendance == null || attendance.records.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 40),
//         child: _EmptyState(message: 'No attendance marked for this class on this date yet.'),
//       );
//     }
//
//     final allRecords = attendance.records.values.toList()
//       ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
//
//     final filteredRecords = filter == 'all'
//         ? allRecords
//         : allRecords.where((r) => r.status.name == filter).toList();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         _buildSummaryCards(attendance, isDesktop),
//         const SizedBox(height: 14),
//         _buildFilterChips(context, attendance),
//         const SizedBox(height: 10),
//         if (filteredRecords.isEmpty)
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 32),
//             child: _EmptyState(message: 'No students found for this filter.', icon: Icons.filter_alt_off_outlined),
//           )
//         else
//           _buildStudentList(filteredRecords, isDesktop),
//       ],
//     );
//   }
//
//   Widget _buildSummaryCards(ClassAttendanceModel att, bool isDesktop) {
//     final cards = [
//       _SummaryCardData('Total', '${att.totalCount}', Icons.groups_outlined, _kSlate, _kSurface),
//       _SummaryCardData('Present', '${att.presentCount}', Icons.check_circle_outline, _kGreen, _kGreenBg),
//       _SummaryCardData('Absent', '${att.absentCount}', Icons.cancel_outlined, _kRed, _kRedBg),
//       _SummaryCardData('Leave', '${att.leaveCount}', Icons.beach_access_outlined, _kBlue, _kBlueBg),
//       _SummaryCardData('Late', '${att.lateCount}', Icons.schedule_outlined, _kOrange, _kOrangeBg),
//       _SummaryCardData('Half Day', '${att.halfDayCount}', Icons.hourglass_bottom_outlined, _kPurple, _kPurpleBg),
//     ];
//     final columns = isDesktop ? 6 : 3;
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
//   Widget _buildFilterChips(BuildContext context, ClassAttendanceModel att) {
//     final chips = <_FilterChipData>[
//       _FilterChipData('all', 'All', att.totalCount, _kGrey, _kGreyBg),
//       _FilterChipData('present', 'Present', att.presentCount, _kGreen, _kGreenBg),
//       _FilterChipData('absent', 'Absent', att.absentCount, _kRed, _kRedBg),
//       _FilterChipData('leave', 'Leave', att.leaveCount, _kBlue, _kBlueBg),
//       _FilterChipData('late', 'Late', att.lateCount, _kOrange, _kOrangeBg),
//       _FilterChipData('halfDay', 'Half Day', att.halfDayCount, _kPurple, _kPurpleBg),
//     ];
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: chips.map((c) {
//           final selected = filter == c.key;
//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(20),
//               onTap: () => onFilterChanged(c.key),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 120),
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//                 decoration: BoxDecoration(
//                   color: selected ? c.color : c.bg,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: selected ? c.color : c.color.withOpacity(0.25)),
//                 ),
//                 child: Text('${c.label} (${c.count})',
//                     style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: selected ? Colors.white : c.color)),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildStudentList(List<AttendanceRecord> records, bool isDesktop) {
//     if (!isDesktop) return _buildMobileList(records);
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
//                 Expanded(flex: 5, child: _headTxt('STUDENT')),
//                 Expanded(flex: 3, child: _headTxt('STATUS')),
//               ],
//             ),
//           ),
//           ...List.generate(records.length, (i) {
//             final r = records[i];
//             final meta = _statusMeta(r.status);
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               decoration: BoxDecoration(
//                 color: i.isEven ? _kCard : _kSurface.withOpacity(0.6),
//                 border: const Border(bottom: BorderSide(color: _kBorder, width: 0.6)),
//               ),
//               child: Row(
//                 children: [
//                   SizedBox(width: 28, child: Text('${i + 1}', style: const TextStyle(fontSize: 11.5, color: _kSlate))),
//                   Expanded(
//                     flex: 5,
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 13,
//                           backgroundColor: _kPrimaryLight,
//                           child: Text(r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
//                               style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kPrimary)),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(r.name.isNotEmpty ? r.name : 'Unnamed',
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _kInk)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(flex: 3, child: _StatusBadge(meta: meta, compact: true)),
//                 ],
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
//   Widget _buildMobileList(List<AttendanceRecord> records) {
//     return Column(
//       children: List.generate(records.length, (i) {
//         final r = records[i];
//         final meta = _statusMeta(r.status);
//         return Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 16,
//                 backgroundColor: _kPrimaryLight,
//                 child: Text(r.name.isNotEmpty ? r.name[0].toUpperCase() : '?',
//                     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary)),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(r.name.isNotEmpty ? r.name : 'Unnamed',
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
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
// class _FilterChipData {
//   final String key;
//   final String label;
//   final int count;
//   final Color color;
//   final Color bg;
//   _FilterChipData(this.key, this.label, this.count, this.color, this.bg);
// }
//
// // ============================================================
// // MONTHLY REPORT VIEW
// // ============================================================
// class _MonthlyReportView extends StatelessWidget {
//   final bool isDesktop;
//   final int selectedYear;
//   final int selectedMonth;
//   final VoidCallback onOpenMonthYearPicker;
//   final VoidCallback onRetry;
//
//   const _MonthlyReportView({
//     required this.isDesktop,
//     required this.selectedYear,
//     required this.selectedMonth,
//     required this.onOpenMonthYearPicker,
//     required this.onRetry,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<ClassAttendanceReportProvider>();
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.fromLTRB(isDesktop ? 28 : 16, 14, isDesktop ? 28 : 16, 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildFilterRow(context),
//           const SizedBox(height: 14),
//           if (provider.isLoading)
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 60),
//               child: Center(child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5)),
//             )
//           else if (provider.error != null)
//             _ErrorState(message: provider.error!, onRetry: onRetry)
//           else if (provider.studentStats.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 40),
//                 child: _EmptyState(message: 'No attendance marked for this class in this month yet.'),
//               )
//             else ...[
//                 _buildClassSummaryCards(provider, isDesktop),
//                 const SizedBox(height: 16),
//                 if (provider.monthDailyTrend.isNotEmpty) ...[
//                   _buildMonthTrendCard(provider, isDesktop),
//                   const SizedBox(height: 16),
//                 ],
//                 const Text('Student-wise Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
//                 const SizedBox(height: 8),
//                 _buildStudentTable(context, provider, isDesktop),
//               ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterRow(BuildContext context) {
//     final monthYearChip = InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: onOpenMonthYearPicker,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.calendar_month_outlined, size: 16, color: _kSlate),
//             const SizedBox(width: 10),
//             Text(DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth)),
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
//   Widget _buildMonthTrendCard(ClassAttendanceReportProvider provider, bool isDesktop) {
//     final trend = provider.monthDailyTrend;
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kBorder)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Attendance Trend', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _kInk)),
//           const SizedBox(height: 4),
//           const Text('Present % across the month', style: TextStyle(fontSize: 11, color: _kSlate)),
//           const SizedBox(height: 14),
//           SizedBox(
//             height: isDesktop ? 220 : 180,
//             child: _MonthTrendChart(trend: trend),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStudentTable(BuildContext context, ClassAttendanceReportProvider provider, bool isDesktop) {
//     final students = provider.studentStats;
//     if (!isDesktop) return _buildMobileStudentList(context, students);
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
//               onTap: () => _openStudentDetail(context, s),
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
//   Widget _buildMobileStudentList(BuildContext context, List<StudentMonthStat> students) {
//     return Column(
//       children: List.generate(students.length, (i) {
//         final s = students[i];
//         return InkWell(
//           borderRadius: BorderRadius.circular(10),
//           onTap: () => _openStudentDetail(context, s),
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
//   void _openStudentDetail(BuildContext context, StudentMonthStat stat) {
//     final provider = context.read<ClassAttendanceReportProvider>();
//     final entries = provider.dayEntriesForStudent(stat.studentId);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => _StudentDayDetailSheet(
//         stat: stat,
//         entries: entries,
//         monthLabel: DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth)),
//       ),
//     );
//   }
// }
//
// // ---- Monthly trend line (single class, present %) ----
// class _MonthTrendChart extends StatelessWidget {
//   final List<DayAggregate> trend;
//   const _MonthTrendChart({required this.trend});
//
//   @override
//   Widget build(BuildContext context) {
//     final spots = List.generate(trend.length, (i) => FlSpot(i.toDouble(), trend[i].presentPct));
//
//     return LineChart(
//       LineChartData(
//         minX: 0,
//         maxX: (trend.length - 1).toDouble().clamp(0, double.infinity),
//         minY: 0,
//         maxY: 100,
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: 25,
//           getDrawingHorizontalLine: (_) => const FlLine(color: _kBorder, strokeWidth: 1),
//         ),
//         borderData: FlBorderData(show: false),
//         titlesData: FlTitlesData(
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 34,
//               interval: 25,
//               getTitlesWidget: (value, meta) => Text('${value.toInt()}%',
//                   style: const TextStyle(fontSize: 10, color: _kSlate)),
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 26,
//               getTitlesWidget: (value, meta) {
//                 final i = value.toInt();
//                 if (i < 0 || i >= trend.length) return const SizedBox.shrink();
//                 if (trend.length > 10 && i % (trend.length ~/ 6).clamp(1, trend.length) != 0) {
//                   return const SizedBox.shrink();
//                 }
//                 final label = DateFormat('d MMM').format(trend[i].date);
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 6),
//                   child: Text(label, style: const TextStyle(fontSize: 9.5, color: _kSlate)),
//                 );
//               },
//             ),
//           ),
//         ),
//         lineTouchData: LineTouchData(
//           touchTooltipData: LineTouchTooltipData(
//             getTooltipItems: (spots) => spots.map((s) {
//               return LineTooltipItem(
//                 '${s.y.toStringAsFixed(0)}%',
//                 const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
//               );
//             }).toList(),
//           ),
//         ),
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             curveSmoothness: 0.25,
//             color: _kPrimary,
//             barWidth: 2.5,
//             dotData: FlDotData(
//               show: true,
//               getDotPainter: (spot, percent, bar, index) =>
//                   FlDotCirclePainter(radius: 3, color: _kPrimary, strokeWidth: 1.5, strokeColor: Colors.white),
//             ),
//             belowBarData: BarAreaData(show: true, color: _kPrimaryLight.withOpacity(0.5)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ============================================================
// // Day-by-day detail bottom sheet
// // ============================================================
// class _StudentDayDetailSheet extends StatelessWidget {
//   final StudentMonthStat stat;
//   final List<DayStatusEntry> entries;
//   final String monthLabel;
//
//   const _StudentDayDetailSheet({required this.stat, required this.entries, required this.monthLabel});
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
//                     final meta = _statusMeta(e.status);
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


import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../models/class_attendance_model.dart';
import '../../pdf_files/class_attendance_pdf_service.dart';
import '../../providers/class_provider.dart';
import '../../providers/class_attendance_provider.dart';
import '../../providers/class_attendance_report_provider.dart';

// ============================================================
// DESIGN TOKENS
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
const double _kTabletBreakpoint = 620;

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

Color _pctColor(double pct) => pct >= 75 ? _kGreen : (pct >= 50 ? _kOrange : _kRed);

// ============================================================
// ATTENDANCE FILTER (used by the "Filters" button on dashboard)
// ============================================================
enum AttendanceFilterOption { all, good, average, low }

extension AttendanceFilterOptionX on AttendanceFilterOption {
  String get label {
    switch (this) {
      case AttendanceFilterOption.all:
        return 'All Classes';
      case AttendanceFilterOption.good:
        return 'Good (≥ 75%)';
      case AttendanceFilterOption.average:
        return 'Average (50% – 74%)';
      case AttendanceFilterOption.low:
        return 'Low (< 50%)';
    }
  }

  IconData get icon {
    switch (this) {
      case AttendanceFilterOption.all:
        return Icons.apps_rounded;
      case AttendanceFilterOption.good:
        return Icons.check_circle_rounded;
      case AttendanceFilterOption.average:
        return Icons.schedule_rounded;
      case AttendanceFilterOption.low:
        return Icons.cancel_rounded;
    }
  }

  Color get color {
    switch (this) {
      case AttendanceFilterOption.all:
        return _kPrimary;
      case AttendanceFilterOption.good:
        return _kGreen;
      case AttendanceFilterOption.average:
        return _kOrange;
      case AttendanceFilterOption.low:
        return _kRed;
    }
  }

  bool matches(double pct) {
    switch (this) {
      case AttendanceFilterOption.all:
        return true;
      case AttendanceFilterOption.good:
        return pct >= 75;
      case AttendanceFilterOption.average:
        return pct >= 50 && pct < 75;
      case AttendanceFilterOption.low:
        return pct < 50;
    }
  }
}

/// Computes a class's overall present% across all its sections, using the
/// already-loaded today's-attendance docs (byKey). Shared by the card UI
/// and the dashboard's filter logic so both stay in sync.
double classOverallPct(SchoolClass cls, Map<String, ClassAttendanceModel> byKey) {
  int present = 0, total = 0;
  for (final s in cls.sections) {
    final doc = byKey['${cls.id}_${s.sectionName}'];
    if (doc != null) {
      present += doc.presentCount;
      total += doc.totalCount;
    }
  }
  return total == 0 ? 0.0 : (present / total) * 100;
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

// ============================================================
// WINDOWS-STYLE MONTH/YEAR PICKER
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
// BREADCRUMB (desktop only, like reference: Dashboard > Class Attendance > ...)
// ============================================================
class _Breadcrumb extends StatelessWidget {
  final List<String> parts;
  const _Breadcrumb({required this.parts});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      final isLast = i == parts.length - 1;
      children.add(Text(
        parts[i],
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
          color: isLast ? _kSlate : _kPrimary,
        ),
      ));
      if (!isLast) {
        children.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.chevron_right_rounded, size: 14, color: _kSlate),
        ));
      }
    }
    return Row(children: children);
  }
}

// ============================================================
// ROOT SCREEN — Class-wise Attendance Report
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
  String _dailyFilter = 'present';

  // Monthly tab state
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  // 0 = Daily, 1 = Monthly
  int _tabIndex = 0;

  bool _isExportingPdf = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassAttendanceReportProvider>().loadAllClassesToday();
    });
  }

  String get _dateKey =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  void _loadMonthly() {
    if (_selectedClass == null || _selectedSection == null) return;
    final classId = _selectedClass!.id;
    if (classId == null) return;
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
      activeStudents: const [],
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

  void _openClassSection(SchoolClass cls, String section) {
    setState(() {
      _selectedClass = cls;
      _selectedSection = section;
      _selectedYear = DateTime.now().year;
      _selectedMonth = DateTime.now().month;
      _selectedDate = DateTime.now();
      _dailyFilter = 'present';
      _tabIndex = 0;
    });
    _loadCurrentTab();
  }

  void _goBackToDashboard() {
    setState(() {
      _selectedClass = null;
      _selectedSection = null;
      _search = '';
    });
    context.read<ClassAttendanceReportProvider>().clear();
  }

  bool get _inDrillDown => _selectedClass != null && _selectedSection != null;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;

      final headerTitle = !_inDrillDown ? 'Class Attendance Report' : '${_selectedClass!.name} — $_selectedSection';

      final breadcrumbParts = !_inDrillDown
          ? const ['Dashboard', 'Class Attendance', 'Class Attendance Report']
          : ['Dashboard', 'Class Attendance', 'Class Attendance Report', '${_selectedClass!.name} — $_selectedSection'];

      return Scaffold(
        backgroundColor: _kSurface,
        appBar: isDesktop
            ? null
            : AppBar(
          titleSpacing: 4,
          title: _inDrillDown
              ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_selectedClass!.name} — $_selectedSection',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _kInk),
              ),
              const SizedBox(height: 2),
              Text(
                _tabIndex == 0
                    ? DateFormat('EEEE, dd MMM yyyy').format(_selectedDate)
                    : DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
                style: const TextStyle(fontSize: 12, color: _kSlate),
              ),
            ],
          )
              : Text(headerTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _kInk)),
          backgroundColor: _kCard,
          surfaceTintColor: _kCard,
          foregroundColor: _kInk,
          elevation: 0,
          shape: const Border(bottom: BorderSide(color: _kBorder, width: 1)),
          leading: _inDrillDown
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBackToDashboard)
              : null,
          actions: [
            IconButton(
              tooltip: 'Export PDF',
              icon: _isExportingPdf
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kPrimary),
              )
                  : const Icon(Icons.picture_as_pdf_outlined, color: _kPrimary),
              onPressed: _isExportingPdf ? null : () => _exportPdf(context),
            ),
          ],
        ),
        body: SafeArea(
          top: isDesktop,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop) _buildDesktopPageHeader(headerTitle, breadcrumbParts),
              Expanded(
                child: _inDrillDown ? _buildReportBody(isDesktop) : _buildDashboardBody(isDesktop),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ---- Desktop-only page header ----
  Widget _buildDesktopPageHeader(String title, List<String> breadcrumbParts) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
      decoration: const BoxDecoration(
        color: _kCard,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_inDrillDown)
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _goBackToDashboard,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kBorder)),
                  child: const Icon(Icons.arrow_back, size: 18, color: _kInk),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _kInk)),
                const SizedBox(height: 6),
                _Breadcrumb(parts: breadcrumbParts),
                if (_inDrillDown) ...[
                  const SizedBox(height: 4),
                  Text(
                    _tabIndex == 0
                        ? DateFormat('EEEE, dd MMM yyyy').format(_selectedDate)
                        : DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth)),
                    style: const TextStyle(fontSize: 12.5, color: _kSlate),
                  ),
                ],
              ],
            ),
          ),
          if (_inDrillDown)
            ElevatedButton.icon(
              onPressed: _isExportingPdf ? null : () => _exportPdf(context),
              icon: _isExportingPdf
                  ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.file_download_outlined, size: 16),
              label: Text(
                _isExportingPdf ? 'Preparing...' : 'Download Report',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            )
          else
            _buildExportPdfButton(context),
        ],
      ),
    );
  }

  Widget _buildExportPdfButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isExportingPdf ? null : () => _exportPdf(context),
      icon: _isExportingPdf
          ? const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : const Icon(Icons.file_download_outlined, size: 16),
      label: Text(
        _isExportingPdf ? 'Preparing...' : 'Export PDF',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    if (_inDrillDown) {
      // Export current daily or monthly report
      if (_selectedClass == null || _selectedSection == null) return;
      setState(() => _isExportingPdf = true);
      try {
        if (_tabIndex == 0) {
          // Daily
          final provider = context.read<ClassAttendanceProvider>();
          final attendance = provider.current;
          if (attendance == null || attendance.records.isEmpty) {
            _showNoDataSnack(context);
            return;
          }
          await ClassAttendancePdfService.generateDailyReport(
            model: attendance,
            className: _selectedClass!.name,
            sectionName: _selectedSection!,
            date: _selectedDate,
          );
        } else {
          // Monthly
          final provider = context.read<ClassAttendanceReportProvider>();
          if (provider.studentStats.isEmpty) {
            _showNoDataSnack(context);
            return;
          }
          await ClassAttendancePdfService.generateMonthlyReport(
            provider: provider,
            className: _selectedClass!.name,
            sectionName: _selectedSection!,
            month: _selectedMonth,
            year: _selectedYear,
          );
        }
      } catch (e) {
        _showExportError(context, e);
      } finally {
        if (mounted) setState(() => _isExportingPdf = false);
      }
    } else {
      // Export all classes today (dashboard)
      final reportProvider = context.read<ClassAttendanceReportProvider>();
      final docs = reportProvider.todayDocs;
      if (docs.isEmpty || docs.every((d) => d.records.isEmpty)) {
        _showNoDataSnack(context);
        return;
      }
      setState(() => _isExportingPdf = true);
      try {
        await ClassAttendancePdfService.generateAndOpen(docs);
      } catch (e) {
        _showExportError(context, e);
      } finally {
        if (mounted) setState(() => _isExportingPdf = false);
      }
    }
  }

  void _showNoDataSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No attendance data available for export.'),
        backgroundColor: _kRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showExportError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to generate PDF: $e'),
        backgroundColor: _kRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================================================================
  // DASHBOARD BODY
  // ================================================================
  Widget _buildDashboardBody(bool isDesktop) {
    return _DashboardView(
      isDesktop: isDesktop,
      search: _search,
      onSearchChanged: (v) => setState(() => _search = v),
      onOpenClassSection: _openClassSection,
    );
  }

  // ================================================================
  // REPORT BODY (drilled into a class+section)
  // ================================================================
  Widget _buildReportBody(bool isDesktop) {
    return Column(
      children: [
        _buildTabBar(isDesktop),
        Expanded(
          child: _tabIndex == 0
              ? _DailyReportView(
            isDesktop: isDesktop,
            selectedDate: _selectedDate,
            filter: _dailyFilter,
            onPickDate: _pickDate,
            onFilterChanged: (f) => setState(() => _dailyFilter = f),
            onRetry: _loadDaily,
          )
              : _MonthlyReportView(
            isDesktop: isDesktop,
            selectedYear: _selectedYear,
            selectedMonth: _selectedMonth,
            onOpenMonthYearPicker: _openMonthYearPicker,
            onRetry: _loadMonthly,
          ),
        ),
      ],
    );
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
// DASHBOARD VIEW
// ============================================================
class _DashboardView extends StatefulWidget {
  final bool isDesktop;
  final String search;
  final ValueChanged<String> onSearchChanged;
  final void Function(SchoolClass cls, String section) onOpenClassSection;

  const _DashboardView({
    required this.isDesktop,
    required this.search,
    required this.onSearchChanged,
    required this.onOpenClassSection,
  });

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  final Set<String> _expandedClassIds = {};
  bool _gridView = true;
  AttendanceFilterOption _attendanceFilter = AttendanceFilterOption.all;

  void _toggleExpand(SchoolClass cls) {
    setState(() {
      final key = cls.id ?? cls.name;
      if (_expandedClassIds.contains(key)) {
        _expandedClassIds.remove(key);
      } else {
        _expandedClassIds.add(key);
      }
    });
  }

  Future<void> _openFiltersSheet(BuildContext context) async {
    final result = await showModalBottomSheet<AttendanceFilterOption>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FiltersSheet(current: _attendanceFilter),
    );
    if (result != null && mounted) {
      setState(() => _attendanceFilter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ClassAttendanceReportProvider>();
    final classProvider = context.watch<ClassProvider>();

    if (reportProvider.isLoadingToday) {
      return const Center(child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5));
    }
    if (reportProvider.todayError != null) {
      return _ErrorState(
        message: reportProvider.todayError!,
        onRetry: () => context.read<ClassAttendanceReportProvider>().loadAllClassesToday(),
      );
    }

    final classes = classProvider.classes;
    final todayDocs = reportProvider.todayDocs;

    final Map<String, ClassAttendanceModel> byKey = {
      for (final d in todayDocs) '${d.classId}_${d.sectionId}': d,
    };

    final filteredClasses = classes.where((c) {
      final matchesSearch =
          widget.search.isEmpty || c.name.toLowerCase().contains(widget.search.toLowerCase());
      if (!matchesSearch) return false;
      if (_attendanceFilter == AttendanceFilterOption.all) return true;
      final pct = classOverallPct(c, byKey);
      return _attendanceFilter.matches(pct);
    }).toList();

    int totalClasses = classes.length;
    int totalPresent = 0, totalAbsent = 0, totalLate = 0, totalLeave = 0, totalMarkedStudents = 0;
    for (final d in todayDocs) {
      totalPresent += d.presentCount;
      totalAbsent += d.absentCount;
      totalLate += d.lateCount;
      totalLeave += d.leaveCount;
      totalMarkedStudents += d.totalCount;
    }
    final overallPct = totalMarkedStudents == 0 ? 0.0 : (totalPresent / totalMarkedStudents) * 100;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        widget.isDesktop ? 28 : 14,
        widget.isDesktop ? 20 : 14,
        widget.isDesktop ? 28 : 14,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchRow(context),
          if (_attendanceFilter != AttendanceFilterOption.all) ...[
            const SizedBox(height: 10),
            _buildActiveFilterChip(),
          ],
          const SizedBox(height: 16),
          _buildTopStatRow(
            isDesktop: widget.isDesktop,
            totalClasses: totalClasses,
            totalPresent: totalPresent,
            totalAbsent: totalAbsent,
            totalLate: totalLate,
            totalLeave: totalLeave,
            overallPct: overallPct,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, filteredClasses.length),
          const SizedBox(height: 12),
          if (filteredClasses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: _EmptyState(
                message: _attendanceFilter == AttendanceFilterOption.all
                    ? 'No matching class found.'
                    : 'No classes match "${_attendanceFilter.label}".',
              ),
            )
          else if (widget.isDesktop && _gridView)
            _buildClassesGrid(filteredClasses, byKey)
          else
            _buildClassesList(filteredClasses, byKey),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _attendanceFilter = AttendanceFilterOption.all),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _attendanceFilter.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _attendanceFilter.color.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_attendanceFilter.icon, size: 14, color: _attendanceFilter.color),
              const SizedBox(width: 6),
              Text(_attendanceFilter.label,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _attendanceFilter.color)),
              const SizedBox(width: 6),
              Icon(Icons.close_rounded, size: 14, color: _attendanceFilter.color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassesList(List<SchoolClass> list, Map<String, ClassAttendanceModel> byKey) {
    return Column(
      children: list
          .map((cls) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ClassExpandCard(
          cls: cls,
          isDesktop: widget.isDesktop,
          compact: false,
          expanded: _expandedClassIds.contains(cls.id ?? cls.name),
          byKey: byKey,
          onToggleExpand: () => _toggleExpand(cls),
          onOpenSection: (section) => widget.onOpenClassSection(cls, section),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildClassesGrid(List<SchoolClass> list, Map<String, ClassAttendanceModel> byKey) {
    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 12.0;
      final cardWidth = (constraints.maxWidth - spacing) / 2;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: list
            .map((cls) => SizedBox(
          width: cardWidth,
          child: _ClassExpandCard(
            cls: cls,
            isDesktop: widget.isDesktop,
            compact: true,
            expanded: _expandedClassIds.contains(cls.id ?? cls.name),
            byKey: byKey,
            onToggleExpand: () => _toggleExpand(cls),
            onOpenSection: (section) => widget.onOpenClassSection(cls, section),
          ),
        ))
            .toList(),
      );
    });
  }

  Widget _buildSearchRow(BuildContext context) {
    final searchField = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
      child: TextField(
        onChanged: widget.onSearchChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Search class, grade or section...',
          hintStyle: TextStyle(fontSize: 13.5, color: _kSlate),
          prefixIcon: Icon(Icons.search, size: 20, color: _kSlate),
        ),
        style: const TextStyle(fontSize: 13.5, color: _kInk),
      ),
    );

    final hasActiveFilter = _attendanceFilter != AttendanceFilterOption.all;
    final filterButton = OutlinedButton.icon(
      onPressed: () => _openFiltersSheet(context),
      icon: Icon(Icons.filter_list_rounded, size: 17, color: hasActiveFilter ? _kPrimary : _kSlate),
      label: Text(
        hasActiveFilter ? 'Filters • 1' : 'Filters',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: hasActiveFilter ? _kPrimary : _kInk),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: hasActiveFilter ? _kPrimaryLight : _kCard,
        side: BorderSide(color: hasActiveFilter ? _kPrimary : _kBorder),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (widget.isDesktop) {
      return Row(children: [Expanded(child: searchField), const SizedBox(width: 12), filterButton]);
    }
    return Column(children: [searchField, const SizedBox(height: 10), filterButton]);
  }

  Widget _buildTopStatRow({
    required bool isDesktop,
    required int totalClasses,
    required int totalPresent,
    required int totalAbsent,
    required int totalLate,
    required int totalLeave,
    required double overallPct,
  }) {
    final cards = [
      _DashStatData('All Classes', '$totalClasses', 'Total Classes', Icons.groups_2_rounded, _kPrimary, _kPrimaryLight),
      _DashStatData('Present Today', '$totalPresent', 'Students', Icons.check_circle_rounded, _kGreen, _kGreenBg),
      _DashStatData('Absent Today', '$totalAbsent', 'Students', Icons.cancel_rounded, _kRed, _kRedBg),
      _DashStatData('Late Today', '$totalLate', 'Students', Icons.schedule_rounded, _kOrange, _kOrangeBg),
      _DashStatData('Leave Today', '$totalLeave', 'Students', Icons.calendar_month_rounded, _kBlue, _kBlueBg),
      _DashStatData('Overall Attendance', '${overallPct.toStringAsFixed(1)}%', 'Average', Icons.pie_chart_rounded, _kPrimary, _kPrimaryLight),
    ];
    final columns = isDesktop ? 6 : (MediaQuery.of(context).size.width >= _kTabletBreakpoint ? 3 : 2);
    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 10.0;
      final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: cards.map((c) => SizedBox(width: cardWidth, child: _DashStatCard(data: c, compact: !isDesktop))).toList(),
      );
    });
  }

  Widget _buildSectionHeader(BuildContext context, int count) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Classes & Sections', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: _kInk)),
              SizedBox(height: 2),
              Text('View attendance summary by class and section', style: TextStyle(fontSize: 12, color: _kSlate)),
            ],
          ),
        ),
        if (widget.isDesktop)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _viewToggleBtn(Icons.grid_view_rounded, true),
                _viewToggleBtn(Icons.view_list_rounded, false),
              ],
            ),
          ),
      ],
    );
  }

  Widget _viewToggleBtn(IconData icon, bool value) {
    final selected = _gridView == value;
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: () => setState(() => _gridView = value),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: selected ? _kPrimary : Colors.transparent, borderRadius: BorderRadius.circular(7)),
        child: Icon(icon, size: 16, color: selected ? Colors.white : _kSlate),
      ),
    );
  }
}

// ============================================================
// FILTERS BOTTOM SHEET
// ============================================================
class _FiltersSheet extends StatefulWidget {
  final AttendanceFilterOption current;
  const _FiltersSheet({required this.current});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late AttendanceFilterOption _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: _kBorder, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.filter_list_rounded, size: 18, color: _kPrimary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Filter by Attendance', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: _kInk)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: _kSlate),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Show only classes whose overall attendance today falls in:',
                  style: TextStyle(fontSize: 12, color: _kSlate)),
              const SizedBox(height: 14),
              ...AttendanceFilterOption.values.map((opt) => _optionTile(opt)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selected = AttendanceFilterOption.all),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kSlate,
                        side: const BorderSide(color: _kBorder),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile(AttendanceFilterOption opt) {
    final selected = _selected == opt;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selected = opt),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? opt.color.withOpacity(0.08) : _kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? opt.color : _kBorder),
          ),
          child: Row(
            children: [
              Icon(opt.icon, size: 18, color: opt.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(opt.label,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: selected ? opt.color : _kInk)),
              ),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                size: 18,
                color: selected ? opt.color : _kSlate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Small data holder for top stat cards ----
class _DashStatData {
  final String label;
  final String value;
  final String sublabel;
  final IconData icon;
  final Color color;
  final Color bg;
  _DashStatData(this.label, this.value, this.sublabel, this.icon, this.color, this.bg);
}

class _DashStatCard extends StatelessWidget {
  final _DashStatData data;
  final bool compact;
  const _DashStatCard({required this.data, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 32 : 40,
            height: compact ? 32 : 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: data.bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(data.icon, size: compact ? 16 : 19, color: data.color),
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(data.label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _kSlate), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(data.value, style: TextStyle(fontSize: compact ? 19 : 23, fontWeight: FontWeight.w800, color: _kInk)),
          const SizedBox(height: 1),
          Text(data.sublabel, style: const TextStyle(fontSize: 10.5, color: _kSlate)),
        ],
      ),
    );
  }
}

// ============================================================
// CLASS EXPAND CARD
// ============================================================
class _ClassExpandCard extends StatelessWidget {
  final SchoolClass cls;
  final bool isDesktop;
  final bool compact;
  final bool expanded;
  final Map<String, ClassAttendanceModel> byKey;
  final VoidCallback onToggleExpand;
  final ValueChanged<String> onOpenSection;

  const _ClassExpandCard({
    required this.cls,
    required this.isDesktop,
    required this.compact,
    required this.expanded,
    required this.byKey,
    required this.onToggleExpand,
    required this.onOpenSection,
  });

  bool get _useWideLayout => isDesktop && !compact;

  @override
  Widget build(BuildContext context) {
    final sections = cls.sections.map((s) => s.sectionName).toList();
    if (sections.isEmpty) return const SizedBox.shrink();

    int present = 0, absent = 0, late = 0, leave = 0, halfDay = 0, total = 0;
    for (final sec in sections) {
      final doc = byKey['${cls.id}_$sec'];
      if (doc != null) {
        present += doc.presentCount;
        absent += doc.absentCount;
        late += doc.lateCount;
        leave += doc.leaveCount;
        halfDay += doc.halfDayCount;
        total += doc.totalCount;
      }
    }
    final overallPct = total == 0 ? 0.0 : (present / total) * 100;
    int totalStudents = 0;
    for (final sec in sections) {
      totalStudents += (byKey['${cls.id}_$sec']?.totalCount ?? 0);
    }

    return Container(
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: _useWideLayout
                  ? _buildDesktopHeaderRow(sections, present, absent, late, leave, overallPct, totalStudents)
                  : _buildMobileHeaderRow(sections, present, absent, late, leave, overallPct, totalStudents),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: _buildSectionsList(context, sections),
            secondChild: const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  Widget _classIcon() {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.menu_book_rounded, size: 18, color: _kPrimary),
    );
  }

  Widget _sectionCountPill(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(20)),
      child: Text('$count ${count == 1 ? 'Section' : 'Sections'}',
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _kPrimary)),
    );
  }

  Widget _miniStatBox(String label, int value, String pctLabel, Color color, Color bg) {
    return Container(
      constraints: const BoxConstraints(minWidth: 68),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(width: 4),
              Text(pctLabel, style: TextStyle(fontSize: 9.5, color: color.withOpacity(0.75))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overallRing(double pct) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: CircularProgressIndicator(
                  value: (pct / 100).clamp(0, 1),
                  strokeWidth: 4.5,
                  backgroundColor: _kBorder,
                  valueColor: AlwaysStoppedAnimation(_pctColor(pct)),
                ),
              ),
              Text('${pct.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: _pctColor(pct))),
            ],
          ),
        ),
        const SizedBox(height: 3),
        const Text('Overall', style: TextStyle(fontSize: 9.5, color: _kSlate)),
      ],
    );
  }

  Widget _buildDesktopHeaderRow(List<String> sections, int present, int absent, int late, int leave, double overallPct, int totalStudents) {
    final total = present + absent + late + leave;
    return Row(
      children: [
        _classIcon(),
        const SizedBox(width: 12),
        SizedBox(
          width: 190,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Flexible(child: Text(cls.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _kInk))),
                const SizedBox(width: 8),
                _sectionCountPill(sections.length),
              ]),
              const SizedBox(height: 4),
              Text('Total Students: $totalStudents', style: const TextStyle(fontSize: 11.5, color: _kSlate)),
            ],
          ),
        ),
        const Spacer(),
        _miniStatBox('Present', present, total == 0 ? '0%' : '${(present / total * 100).toStringAsFixed(0)}%', _kGreen, _kGreenBg),
        const SizedBox(width: 8),
        _miniStatBox('Absent', absent, total == 0 ? '0%' : '${(absent / total * 100).toStringAsFixed(0)}%', _kRed, _kRedBg),
        const SizedBox(width: 8),
        _miniStatBox('Late', late, total == 0 ? '0%' : '${(late / total * 100).toStringAsFixed(0)}%', _kOrange, _kOrangeBg),
        const SizedBox(width: 8),
        _miniStatBox('Leave', leave, total == 0 ? '0%' : '${(leave / total * 100).toStringAsFixed(0)}%', _kBlue, _kBlueBg),
        const SizedBox(width: 16),
        _overallRing(overallPct),
        const SizedBox(width: 10),
        Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _kSlate),
      ],
    );
  }

  Widget _buildMobileHeaderRow(List<String> sections, int present, int absent, int late, int leave, double overallPct, int totalStudents) {
    final total = present + absent + late + leave;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _classIcon(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Flexible(child: Text(cls.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: _kInk))),
                    const SizedBox(width: 8),
                    _sectionCountPill(sections.length),
                  ]),
                  const SizedBox(height: 2),
                  Text('Total Students: $totalStudents', style: const TextStyle(fontSize: 11, color: _kSlate)),
                ],
              ),
            ),
            Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _kSlate),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _miniStatBox('Present', present, total == 0 ? '0%' : '${(present / total * 100).toStringAsFixed(0)}%', _kGreen, _kGreenBg)),
            const SizedBox(width: 8),
            Expanded(child: _miniStatBox('Absent', absent, total == 0 ? '0%' : '${(absent / total * 100).toStringAsFixed(0)}%', _kRed, _kRedBg)),
            const SizedBox(width: 8),
            _overallRing(overallPct),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionsList(BuildContext context, List<String> sections) {
    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Column(
        children: sections.map((sec) {
          final doc = byKey['${cls.id}_$sec'];
          final present = doc?.presentCount ?? 0;
          final absent = doc?.absentCount ?? 0;
          final late = doc?.lateCount ?? 0;
          final leave = doc?.leaveCount ?? 0;
          final studentCount = doc?.totalCount ?? 0;
          final total = present + absent + late + leave;
          final pct = total == 0 ? 0.0 : (present / total) * 100;

          return InkWell(
            onTap: () => onOpenSection(sec),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: _kBorder, width: 0.6))),
              child: _useWideLayout
                  ? Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: const BoxDecoration(color: _kPrimary, shape: BoxShape.circle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('${cls.name} $sec', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(children: [
                      const Icon(Icons.people_outline_rounded, size: 14, color: _kSlate),
                      const SizedBox(width: 4),
                      Text('$studentCount Students', style: const TextStyle(fontSize: 11.5, color: _kSlate)),
                    ]),
                  ),
                  Expanded(flex: 2, child: _sectionStatusText('✓', present, total == 0 ? 0 : (present / total * 100), _kGreen)),
                  Expanded(flex: 2, child: _sectionStatusText('✕', absent, total == 0 ? 0 : (absent / total * 100), _kRed)),
                  Expanded(flex: 2, child: _sectionStatusText('◔', late, total == 0 ? 0 : (late / total * 100), _kOrange)),
                  Expanded(flex: 2, child: _sectionStatusText('▤', leave, total == 0 ? 0 : (leave / total * 100), _kBlue)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: _kSlate),
                ],
              )
                  : Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: const BoxDecoration(color: _kPrimary, shape: BoxShape.circle),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${cls.name} $sec', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
                        const SizedBox(height: 3),
                        Text('$studentCount Students', style: const TextStyle(fontSize: 11, color: _kSlate)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: (pct >= 75 ? _kGreen : (pct >= 50 ? _kOrange : _kRed)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${pct.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _pctColor(pct))),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: _kSlate),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionStatusText(String symbol, int value, double pct, Color color) {
    return Row(
      children: [
        Text(symbol, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w800)),
        const SizedBox(width: 5),
        Text('$value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 4),
        Text('(${pct.toStringAsFixed(0)}%)', style: TextStyle(fontSize: 10.5, color: color.withOpacity(0.75))),
      ],
    );
  }
}

// ============================================================
// DAILY REPORT VIEW
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
      child: dateChip,
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
// MONTHLY REPORT VIEW
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
                const SizedBox(height: 16),
                if (provider.monthDailyTrend.isNotEmpty) ...[
                  _buildMonthTrendCard(provider, isDesktop),
                  const SizedBox(height: 16),
                ],
                const Text('Student-wise Breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kInk)),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
      child: monthYearChip,
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

  Widget _buildMonthTrendCard(ClassAttendanceReportProvider provider, bool isDesktop) {
    final trend = provider.monthDailyTrend;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attendance Trend', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _kInk)),
          const SizedBox(height: 4),
          const Text('Present % across the month', style: TextStyle(fontSize: 11, color: _kSlate)),
          const SizedBox(height: 14),
          SizedBox(
            height: isDesktop ? 220 : 180,
            child: _MonthTrendChart(trend: trend),
          ),
        ],
      ),
    );
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

// ---- Monthly trend line (single class, present %) ----
class _MonthTrendChart extends StatelessWidget {
  final List<DayAggregate> trend;
  const _MonthTrendChart({required this.trend});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(trend.length, (i) => FlSpot(i.toDouble(), trend[i].presentPct));

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (trend.length - 1).toDouble().clamp(0, double.infinity),
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => const FlLine(color: _kBorder, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 25,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}%',
                  style: const TextStyle(fontSize: 10, color: _kSlate)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= trend.length) return const SizedBox.shrink();
                if (trend.length > 10 && i % (trend.length ~/ 6).clamp(1, trend.length) != 0) {
                  return const SizedBox.shrink();
                }
                final label = DateFormat('d MMM').format(trend[i].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label, style: const TextStyle(fontSize: 9.5, color: _kSlate)),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                '${s.y.toStringAsFixed(0)}%',
                const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: _kPrimary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(radius: 3, color: _kPrimary, strokeWidth: 1.5, strokeColor: Colors.white),
            ),
            belowBarData: BarAreaData(show: true, color: _kPrimaryLight.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Day-by-day detail bottom sheet
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