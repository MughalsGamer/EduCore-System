//
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/class_model.dart';
// import '../../models/exam_result_card_model.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/exam_result_card_provider.dart';
// import '../../providers/student_provider.dart';
// import 'exam_result_card_form_screen.dart';
//
// // ─── Design Tokens ─────────────────────────────────────────────
// class _T {
//   static const primary = Color(0xFF4F46E5);
//   static const primaryDark = Color(0xFF4338CA);
//   static const primaryLight = Color(0xFFEEF2FF);
//   static const bg = Color(0xFFF8F9FC);
//   static const surface = Color(0xFFFFFFFF);
//   static const border = Color(0xFFEDEFF5);
//   static const success = Color(0xFF059669);
//   static const successBg = Color(0xFFECFDF5);
//   static const danger = Color(0xFFDC2626);
//   static const dangerBg = Color(0xFFFEF2F2);
//   static const textPrimary = Color(0xFF111827);
//   static const textSecondary = Color(0xFF6B7280);
//   static const textTertiary = Color(0xFF9CA3AF);
//
//   static const cardRadius = 20.0;
//
//   static List<BoxShadow> softShadow = [
//     BoxShadow(
//       color: primary.withOpacity(0.06),
//       blurRadius: 24,
//       offset: const Offset(0, 10),
//     ),
//     BoxShadow(
//       color: Colors.black.withOpacity(0.02),
//       blurRadius: 4,
//       offset: const Offset(0, 1),
//     ),
//   ];
//
//   static const gradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
//   );
// }
//
// enum _ViewMode { list, grid }
//
// class StudentWiseResultCardsScreen extends StatefulWidget {
//   const StudentWiseResultCardsScreen({super.key});
//
//   @override
//   State<StudentWiseResultCardsScreen> createState() =>
//       _StudentWiseResultCardsScreenState();
// }
//
// class _StudentWiseResultCardsScreenState
//     extends State<StudentWiseResultCardsScreen>
//     with SingleTickerProviderStateMixin {
//   String? _selectedClassId;
//   String? _selectedSectionName;
//   String _search = '';
//   bool _filtersExpanded = false;
//   _ViewMode _viewMode = _ViewMode.grid;
//   late AnimationController _listController;
//   final ScrollController _scrollController = ScrollController();
//   bool _showScrollToTop = false;
//
//   // ─── Helpers ──────────────────────────────────────────────
//
//   String _classNameById(String id) {
//     final cls = context.read<ClassProvider>().classes.firstWhere(
//           (c) => c.id == id,
//       orElse: () => SchoolClass(name: 'Unknown'),
//     );
//     return cls.name;
//   }
//
//   List<_StudentExamResult> _buildFlatResults(
//       List<StudentWithContext> allStudents, List<ExamResultCard> allCards) {
//     final results = <_StudentExamResult>[];
//     final studentMap = {for (final s in allStudents) s.student.studentId: s};
//
//     for (final card in allCards) {
//       for (final sm in card.studentMarks) {
//         final student = studentMap[sm.studentId];
//         if (student != null) {
//           results.add(_StudentExamResult(
//             student: student,
//             examCard: card,
//             studentMarks: sm,
//           ));
//         }
//       }
//     }
//     return results;
//   }
//
//   // ─── Lifecycle ─────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     _listController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _listController.forward();
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     final shouldShow = _scrollController.hasClients &&
//         _scrollController.offset > 320;
//     if (shouldShow != _showScrollToTop) {
//       setState(() => _showScrollToTop = shouldShow);
//     }
//   }
//
//   void _scrollToTop() {
//     _scrollController.animateTo(
//       0,
//       duration: const Duration(milliseconds: 450),
//       curve: Curves.easeOutCubic,
//     );
//   }
//
//   @override
//   void dispose() {
//     _listController.dispose();
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   // ─── Build ──────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     final classProvider = context.watch<ClassProvider>();
//     final examCardProvider = context.watch<ExamResultCardProvider>();
//     final studentProvider = context.watch<StudentProvider>();
//
//     final allStudents = studentProvider.allActiveStudents;
//     final allCards = examCardProvider.cards;
//
//     var flatResults = _buildFlatResults(allStudents, allCards);
//
//     if (_selectedClassId != null) {
//       final className = _classNameById(_selectedClassId!);
//       flatResults = flatResults
//           .where((r) => r.student.student.className == className)
//           .toList();
//     }
//
//     if (_selectedSectionName != null) {
//       flatResults = flatResults
//           .where((r) => r.student.student.sectionName == _selectedSectionName)
//           .toList();
//     }
//
//     if (_search.isNotEmpty) {
//       final q = _search.toLowerCase();
//       flatResults = flatResults.where((r) {
//         final s = r.student;
//         return s.student.name.toLowerCase().contains(q) ||
//             s.familyId.toLowerCase().contains(q) ||
//             s.student.studentId.toLowerCase().contains(q) ||
//             r.examCard.examName.toLowerCase().contains(q);
//       }).toList();
//     }
//
//     flatResults.sort((a, b) {
//       final nameComp =
//       a.student.student.name.compareTo(b.student.student.name);
//       if (nameComp != 0) return nameComp;
//       return b.examCard.date.compareTo(a.examCard.date);
//     });
//
//     final totalResults = flatResults.length;
//     final passCount = flatResults.where((r) => _isExamPass(r)).length;
//     final failCount = totalResults - passCount;
//
//     final width = MediaQuery.of(context).size.width;
//     final isWeb = width > 800;
//     final isLoading = examCardProvider.isLoading || studentProvider.isLoading;
//
//     return Scaffold(
//       backgroundColor: _T.bg,
//       body: Stack(
//         children: [
//           isWeb
//               ? _buildWebLayout(
//               context, classProvider, flatResults, totalResults,
//               passCount, failCount, isLoading)
//               : _buildMobileLayout(
//               context, classProvider, flatResults, totalResults,
//               passCount, failCount, isLoading),
//           _buildScrollToTopButton(),
//         ],
//       ),
//       floatingActionButton: isWeb ? null : _buildMobileFab(context),
//     );
//   }
//
//   // ─── Scroll-to-top button ───────────────────────────────────
//
//   Widget _buildScrollToTopButton() {
//     return Positioned(
//       right: 20,
//       bottom: 20,
//       child: AnimatedSlide(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOutCubic,
//         offset: _showScrollToTop ? Offset.zero : const Offset(0, 2),
//         child: AnimatedOpacity(
//           duration: const Duration(milliseconds: 200),
//           opacity: _showScrollToTop ? 1 : 0,
//           child: IgnorePointer(
//             ignoring: !_showScrollToTop,
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: _scrollToTop,
//                 borderRadius: BorderRadius.circular(24),
//                 child: Container(
//                   width: 46,
//                   height: 46,
//                   decoration: BoxDecoration(
//                     gradient: _T.gradient,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: _T.primary.withOpacity(0.35),
//                         blurRadius: 16,
//                         offset: const Offset(0, 6),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(Icons.keyboard_arrow_up_rounded,
//                       color: Colors.white, size: 28),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════
//   // MOBILE LAYOUT
//   // ══════════════════════════════════════════════════════════
//
//   Widget _buildMobileFab(BuildContext context) {
//     return FloatingActionButton.extended(
//       onPressed: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const ExamResultCardFormScreen()),
//         );
//       },
//       backgroundColor: _T.primary,
//       elevation: 4,
//       icon: const Icon(Icons.add_rounded, color: Colors.white),
//       label: const Text('New Result',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
//     );
//   }
//
//   Widget _buildMobileLayout(
//       BuildContext context,
//       ClassProvider classProvider,
//       List<_StudentExamResult> flatResults,
//       int total,
//       int pass,
//       int fail,
//       bool isLoading,
//       ) {
//     return CustomScrollView(
//       controller: _scrollController,
//       physics: const BouncingScrollPhysics(
//           parent: AlwaysScrollableScrollPhysics()),
//       slivers: [
//         SliverAppBar(
//           pinned: false,
//           floating: true,
//           backgroundColor: _T.bg,
//           elevation: 0,
//           surfaceTintColor: Colors.transparent,
//           expandedHeight: 118,
//           automaticallyImplyLeading: false,
//           flexibleSpace: FlexibleSpaceBar(
//             titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
//             title: const Text(
//               'Student Results',
//               style: TextStyle(
//                 fontWeight: FontWeight.w800,
//                 fontSize: 20,
//                 letterSpacing: -0.3,
//                 color: _T.textPrimary,
//               ),
//             ),
//             background: Container(color: _T.bg),
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.picture_as_pdf_outlined,
//                   color: _T.textSecondary),
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   _snack('PDF generation coming soon'),
//                 );
//               },
//             ),
//             const SizedBox(width: 4),
//           ],
//         ),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
//             child: _buildStatsRow(total, pass, fail, compact: true),
//           ),
//         ),
//         // Sticky: search bar + filters + view toggle stay pinned at the
//         // top once scrolled past, so the user can always search/filter
//         // without scrolling back up.
//         SliverPersistentHeader(
//           pinned: true,
//           delegate: _StickyFilterHeaderDelegate(
//             minHeight: 64,
//             maxHeight: _filtersExpanded ? 218 : 64,
//             child: _buildStickyFilterBar(classProvider, isMobile: true),
//           ),
//         ),
//         if (isLoading)
//           const SliverFillRemaining(
//             child: Center(
//               child: CircularProgressIndicator(
//                   color: _T.primary, strokeWidth: 3),
//             ),
//           )
//         else if (flatResults.isEmpty)
//           SliverFillRemaining(child: _buildEmptyState())
//         else if (_viewMode == _ViewMode.grid)
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
//               sliver: _buildResponsiveGridSliver(flatResults),
//             )
//           else
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
//               sliver: SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                       (ctx, i) => _AnimatedListItem(
//                     index: i,
//                     controller: _listController,
//                     child: _buildResultCard(flatResults[i], isMobile: true),
//                   ),
//                   childCount: flatResults.length,
//                 ),
//               ),
//             ),
//       ],
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════
//   // WEB LAYOUT
//   // ══════════════════════════════════════════════════════════
//
//   Widget _buildWebLayout(
//       BuildContext context,
//       ClassProvider classProvider,
//       List<_StudentExamResult> flatResults,
//       int total,
//       int pass,
//       int fail,
//       bool isLoading,
//       ) {
//     return Column(
//       children: [
//         _buildWebHeader(context),
//         Expanded(
//           child: CustomScrollView(
//             controller: _scrollController,
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(maxWidth: 1400),
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
//                       child: _buildStatsRow(total, pass, fail, compact: false),
//                     ),
//                   ),
//                 ),
//               ),
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _StickyFilterHeaderDelegate(
//                   minHeight: 78,
//                   maxHeight: 78,
//                   backgroundColor: _T.bg,
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(maxWidth: 1400),
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(32, 16, 32, 10),
//                         child: _buildSearchAndFilterCard(classProvider,
//                             isMobile: false),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(maxWidth: 1400),
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(32, 10, 32, 32),
//                       child: isLoading
//                           ? const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 120),
//                         child: Center(
//                           child: CircularProgressIndicator(
//                               color: _T.primary, strokeWidth: 3),
//                         ),
//                       )
//                           : flatResults.isEmpty
//                           ? Padding(
//                         padding:
//                         const EdgeInsets.symmetric(vertical: 60),
//                         child: _buildEmptyState(),
//                       )
//                           : _viewMode == _ViewMode.grid
//                           ? _buildResponsiveGrid(flatResults)
//                           : _buildResultListColumn(flatResults),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWebHeader(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
//       decoration: BoxDecoration(
//         color: _T.surface,
//         border: Border(bottom: BorderSide(color: _T.border)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               gradient: _T.gradient,
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: [
//                 BoxShadow(
//                   color: _T.primary.withOpacity(0.3),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: const Icon(Icons.assignment_rounded,
//                 color: Colors.white, size: 22),
//           ),
//           const SizedBox(width: 16),
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Student Results',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 22,
//                   letterSpacing: -0.4,
//                   color: _T.textPrimary,
//                 ),
//               ),
//               Text(
//                 'View and manage exam result cards',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: _T.textSecondary,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           _buildViewToggle(),
//           const SizedBox(width: 12),
//           OutlinedButton.icon(
//             onPressed: () {
//               ScaffoldMessenger.of(context)
//                   .showSnackBar(_snack('PDF generation coming soon'));
//             },
//             icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
//             label: const Text('Export PDF'),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: _T.textSecondary,
//               side: const BorderSide(color: _T.border),
//               padding:
//               const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//           const SizedBox(width: 12),
//           ElevatedButton.icon(
//             onPressed: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) => const ExamResultCardFormScreen()),
//               );
//             },
//             icon: const Icon(Icons.add_rounded, size: 20),
//             label: const Text('New Result Card'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _T.primary,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               padding:
//               const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Stats ──────────────────────────────────────────────────
//
//   Widget _buildStatsRow(int total, int pass, int fail,
//       {required bool compact}) {
//     final items = [
//       _StatData('Total Results', total, _T.primary, _T.primaryLight,
//           Icons.assignment_rounded),
//       _StatData(
//           'Passed', pass, _T.success, _T.successBg, Icons.check_circle_rounded),
//       _StatData('Failed', fail, _T.danger, _T.dangerBg, Icons.cancel_rounded),
//     ];
//
//     if (compact) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
//         decoration: BoxDecoration(
//           color: _T.surface,
//           borderRadius: BorderRadius.circular(_T.cardRadius),
//           boxShadow: _T.softShadow,
//         ),
//         child: Row(
//           children: items
//               .map((item) => Expanded(child: _statItemCompact(item)))
//               .toList(),
//         ),
//       );
//     }
//
//     return Row(
//       children: items
//           .map((item) => Expanded(
//         child: Padding(
//           padding: const EdgeInsets.only(right: 16),
//           child: _statCardWeb(item),
//         ),
//       ))
//           .toList(),
//     );
//   }
//
//   Widget _statItemCompact(_StatData item) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: item.bgColor,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(item.icon, color: item.color, size: 18),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           item.value.toString(),
//           style: TextStyle(
//             fontWeight: FontWeight.w800,
//             fontSize: 19,
//             letterSpacing: -0.5,
//             color: _T.textPrimary,
//           ),
//         ),
//         Text(
//           item.label,
//           style: const TextStyle(
//             fontSize: 11.5,
//             fontWeight: FontWeight.w600,
//             color: _T.textTertiary,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _statCardWeb(_StatData item) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: _T.surface,
//         borderRadius: BorderRadius.circular(_T.cardRadius),
//         boxShadow: _T.softShadow,
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: item.bgColor,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(item.icon, color: item.color, size: 22),
//           ),
//           const SizedBox(width: 14),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 item.value.toString(),
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 24,
//                   letterSpacing: -0.6,
//                   color: _T.textPrimary,
//                 ),
//               ),
//               Text(
//                 item.label,
//                 style: const TextStyle(
//                   fontSize: 12.5,
//                   fontWeight: FontWeight.w600,
//                   color: _T.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Filters ────────────────────────────────────────────────
//
//   Widget _buildSearchAndFilterCard(ClassProvider classProvider,
//       {required bool isMobile}) {
//     final classes = classProvider.classes;
//     final sections = _selectedClassId == null
//         ? <String>[]
//         : classProvider.classes
//         .firstWhere((c) => c.id == _selectedClassId,
//         orElse: () => SchoolClass(name: ''))
//         .sections
//         .map((s) => s.sectionName)
//         .toList();
//
//     if (!isMobile) {
//       // Web: single row — search + class + section + view toggle.
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: _T.surface,
//           borderRadius: BorderRadius.circular(_T.cardRadius),
//           boxShadow: _T.softShadow,
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               flex: 3,
//               child: _searchField(),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               flex: 2,
//               child: _dropdownField<String?>(
//                 value: _selectedClassId,
//                 hint: 'All Classes',
//                 items: [
//                   const DropdownMenuItem<String?>(
//                       value: null, child: Text('All Classes')),
//                   ...classes.map((c) => DropdownMenuItem<String?>(
//                       value: c.id, child: Text(c.name))),
//                 ],
//                 onChanged: (v) {
//                   setState(() {
//                     _selectedClassId = v;
//                     _selectedSectionName = null;
//                   });
//                 },
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               flex: 2,
//               child: _dropdownField<String?>(
//                 value: _selectedSectionName,
//                 hint: 'All Sections',
//                 items: [
//                   const DropdownMenuItem<String?>(
//                       value: null, child: Text('All Sections')),
//                   ...sections.map((s) =>
//                       DropdownMenuItem<String?>(value: s, child: Text(s))),
//                 ],
//                 onChanged: (v) => setState(() => _selectedSectionName = v),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     // Mobile: compact — search bar + filter toggle + view toggle always
//     // visible; class/section dropdowns reveal underneath when expanded.
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: _T.surface,
//         borderRadius: BorderRadius.circular(_T.cardRadius),
//         boxShadow: _T.softShadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             children: [
//               Expanded(child: _searchField()),
//               const SizedBox(width: 8),
//               _iconToggleButton(
//                 icon: Icons.tune_rounded,
//                 active: _filtersExpanded ||
//                     _selectedClassId != null ||
//                     _selectedSectionName != null,
//                 onTap: () =>
//                     setState(() => _filtersExpanded = !_filtersExpanded),
//               ),
//               const SizedBox(width: 8),
//               _buildViewToggle(),
//             ],
//           ),
//           AnimatedCrossFade(
//             duration: const Duration(milliseconds: 220),
//             crossFadeState: _filtersExpanded
//                 ? CrossFadeState.showFirst
//                 : CrossFadeState.showSecond,
//             firstChild: Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _dropdownField<String?>(
//                       value: _selectedClassId,
//                       hint: 'All Classes',
//                       items: [
//                         const DropdownMenuItem<String?>(
//                             value: null, child: Text('All Classes')),
//                         ...classes.map((c) => DropdownMenuItem<String?>(
//                             value: c.id, child: Text(c.name))),
//                       ],
//                       onChanged: (v) {
//                         setState(() {
//                           _selectedClassId = v;
//                           _selectedSectionName = null;
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: _dropdownField<String?>(
//                       value: _selectedSectionName,
//                       hint: 'All Sections',
//                       items: [
//                         const DropdownMenuItem<String?>(
//                             value: null, child: Text('All Sections')),
//                         ...sections.map((s) => DropdownMenuItem<String?>(
//                             value: s, child: Text(s))),
//                       ],
//                       onChanged: (v) =>
//                           setState(() => _selectedSectionName = v),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             secondChild: const SizedBox(width: double.infinity, height: 0),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _searchField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: _T.bg,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: TextField(
//         onChanged: (v) => setState(() => _search = v),
//         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         decoration: InputDecoration(
//           hintText: 'Search student, ID, family or exam...',
//           hintStyle: TextStyle(
//               color: _T.textTertiary,
//               fontSize: 13.5,
//               fontWeight: FontWeight.w500),
//           prefixIcon:
//           const Icon(Icons.search_rounded, color: _T.textTertiary, size: 22),
//           border: InputBorder.none,
//           isDense: true,
//           contentPadding:
//           const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
//         ),
//       ),
//     );
//   }
//
//   Widget _iconToggleButton({
//     required IconData icon,
//     required bool active,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         width: 46,
//         height: 46,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: active ? _T.primaryLight : _T.bg,
//           borderRadius: BorderRadius.circular(14),
//           border: active ? Border.all(color: _T.primary, width: 1.2) : null,
//         ),
//         child: Icon(icon,
//             color: active ? _T.primary : _T.textTertiary, size: 20),
//       ),
//     );
//   }
//
//   /// List / Grid view toggle — matches the old behavior where users could
//   /// switch between a compact list and a card grid.
//   Widget _buildViewToggle() {
//     return Container(
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         color: _T.bg,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _viewToggleIcon(Icons.view_list_rounded, _ViewMode.list),
//           _viewToggleIcon(Icons.grid_view_rounded, _ViewMode.grid),
//         ],
//       ),
//     );
//   }
//
//   Widget _viewToggleIcon(IconData icon, _ViewMode mode) {
//     final active = _viewMode == mode;
//     return InkWell(
//       onTap: () => setState(() => _viewMode = mode),
//       borderRadius: BorderRadius.circular(11),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         width: 40,
//         height: 40,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: active ? _T.surface : Colors.transparent,
//           borderRadius: BorderRadius.circular(11),
//           boxShadow: active
//               ? [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ]
//               : null,
//         ),
//         child: Icon(icon,
//             size: 19, color: active ? _T.primary : _T.textTertiary),
//       ),
//     );
//   }
//
//   /// Wrapper used for the sticky-header build inside CustomScrollView.
//   Widget _buildStickyFilterBar(ClassProvider classProvider,
//       {required bool isMobile}) {
//     return Container(
//       color: _T.bg,
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
//       child: _buildSearchAndFilterCard(classProvider, isMobile: isMobile),
//     );
//   }
//
//   Widget _dropdownField<T>({
//     required T value,
//     required String hint,
//     required List<DropdownMenuItem<T>> items,
//     required void Function(T?) onChanged,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: _T.bg,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<T>(
//           value: value,
//           isExpanded: true,
//           icon: const Icon(Icons.keyboard_arrow_down_rounded,
//               color: _T.textTertiary),
//           style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: _T.textPrimary),
//           borderRadius: BorderRadius.circular(14),
//           items: items,
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
//
//   // ─── Empty State ────────────────────────────────────────────
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 96,
//             height: 96,
//             decoration: BoxDecoration(
//               color: _T.primaryLight,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.assignment_outlined,
//                 size: 44, color: _T.primary.withOpacity(0.6)),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'No exam results found',
//             style: TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w700,
//               color: _T.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 6),
//           const Text(
//             'Generate a result card first to see results here.',
//             style: TextStyle(
//               fontSize: 13.5,
//               color: _T.textSecondary,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Grid Layout (masonry-style, no leftover empty space) ──────
//   //
//   // A fixed-aspect-ratio GridView leaves empty gaps whenever cards have a
//   // different number of subjects (different content height). Instead we
//   // bucket the cards into N columns (by available width) and let each
//   // column size itself naturally with a Column — this is the standard
//   // "masonry" trick without needing an external package, and it keeps
//   // each card exactly as tall/short as its content requires.
//
//   int _gridColumnCount(double width) {
//     if (width >= 1180) return 3;
//     if (width >= 760) return 2;
//     return 1;
//   }
//
//   Widget _buildResponsiveGrid(List<_StudentExamResult> results) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final columnCount = _gridColumnCount(constraints.maxWidth);
//         if (columnCount == 1) {
//           return _buildResultListColumn(results);
//         }
//         final columns = List.generate(columnCount, (_) => <Widget>[]);
//         for (var i = 0; i < results.length; i++) {
//           final col = i % columnCount;
//           columns[col].add(
//             Padding(
//               padding: const EdgeInsets.only(bottom: 18),
//               child: _AnimatedListItem(
//                 index: i,
//                 controller: _listController,
//                 child: _buildResultCard(results[i], isMobile: false),
//               ),
//             ),
//           );
//         }
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             for (var c = 0; c < columnCount; c++) ...[
//               if (c > 0) const SizedBox(width: 18),
//               Expanded(
//                 child: Column(children: columns[c]),
//               ),
//             ],
//           ],
//         );
//       },
//     );
//   }
//
//   /// Same masonry grid but usable inside a CustomScrollView sliver
//   /// (mobile). Falls back to a single column list on narrow screens.
//   Widget _buildResponsiveGridSliver(List<_StudentExamResult> results) {
//     return SliverToBoxAdapter(
//       child: _buildResponsiveGrid(results),
//     );
//   }
//
//   Widget _buildResultListColumn(List<_StudentExamResult> results) {
//     return Column(
//       children: [
//         for (var i = 0; i < results.length; i++)
//           _AnimatedListItem(
//             index: i,
//             controller: _listController,
//             child: _buildResultCard(results[i], isMobile: true),
//           ),
//       ],
//     );
//   }
//
//   // ─── Result Card (shared, mobile/web variants) ─────────────
//
//   Widget _buildResultCard(_StudentExamResult result, {required bool isMobile}) {
//     final student = result.student;
//     final exam = result.examCard;
//     final sm = result.studentMarks;
//     final isPass = _isExamPass(result);
//
//     return _HoverScaleCard(
//       onTap: () {},
//       child: Container(
//         margin: EdgeInsets.only(bottom: isMobile ? 14 : 0),
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: _T.surface,
//           borderRadius: BorderRadius.circular(_T.cardRadius),
//           border: Border.all(color: _T.border),
//           boxShadow: _T.softShadow,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     gradient: _T.gradient,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   alignment: Alignment.center,
//                   child: Text(
//                     student.student.name.isNotEmpty
//                         ? student.student.name[0].toUpperCase()
//                         : '?',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w800,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         student.student.name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 15,
//                           color: _T.textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         '${student.student.className} · ${student.student.sectionName}',
//                         style: const TextStyle(
//                           fontSize: 12.5,
//                           color: _T.textSecondary,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _buildPassFailChip(isPass),
//                 PopupMenuButton<String>(
//                   icon: const Icon(Icons.more_vert_rounded,
//                       color: _T.textTertiary, size: 20),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14)),
//                   onSelected: (value) async {
//                     if (value == 'edit') {
//                       await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ExamResultCardFormScreen(
//                             card: exam,
//                             studentContext: student,
//                           ),
//                         ),
//                       );
//                     } else if (value == 'delete') {
//                       final confirmed = await _showRemoveDialog(student.student.name);
//                       if (confirmed == true) {
//                         try {
//                           await context
//                               .read<ExamResultCardProvider>()
//                               .removeStudentFromCard(
//                               exam.id!, student.student.studentId);
//                           if (mounted) {
//                             ScaffoldMessenger.of(context)
//                                 .showSnackBar(_snack('Student result removed.'));
//                           }
//                         } catch (e) {
//                           if (mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               _snack('Error: $e', isError: true),
//                             );
//                           }
//                         }
//                       }
//                     }
//                   },
//                   itemBuilder: (ctx) => [
//                     const PopupMenuItem<String>(
//                       value: 'edit',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit_outlined, color: _T.primary, size: 18),
//                           SizedBox(width: 10),
//                           Text('Edit Marks',
//                               style: TextStyle(fontWeight: FontWeight.w500)),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem<String>(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete_outline_rounded,
//                               color: _T.danger, size: 18),
//                           SizedBox(width: 10),
//                           Text('Remove Student',
//                               style: TextStyle(fontWeight: FontWeight.w500)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 14),
//             Container(height: 1, color: _T.border),
//             const SizedBox(height: 14),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     exam.examName,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 13.5,
//                       color: _T.textPrimary,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   DateFormat('dd MMM yyyy').format(exam.date),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: _T.textTertiary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             ...exam.subjects.map((subj) {
//               final obtained = sm.obtainedMarks[subj.name] ?? 0;
//               final total = subj.totalMarks;
//               final percentage = total > 0 ? obtained / total : 0.0;
//               final isFail = obtained < total * 0.25;
//               final barColor = isFail ? _T.danger : _T.success;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 5),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 72,
//                       child: Text(
//                         subj.name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: _T.textSecondary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: TweenAnimationBuilder<double>(
//                           tween: Tween(
//                               begin: 0, end: percentage.clamp(0.0, 1.0)),
//                           duration: const Duration(milliseconds: 700),
//                           curve: Curves.easeOutCubic,
//                           builder: (ctx, value, _) => LinearProgressIndicator(
//                             value: value,
//                             backgroundColor: _T.bg,
//                             color: barColor,
//                             minHeight: 7,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 54,
//                       child: Text(
//                         '$obtained/$total',
//                         textAlign: TextAlign.right,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: barColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<bool?> _showRemoveDialog(String studentName) {
//     return showDialog<bool>(
//       context: context,
//       builder: (ctx) => Dialog(
//         shape:
//         RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: _T.dangerBg,
//                   shape: BoxShape.circle,
//                 ),
//                 child:
//                 const Icon(Icons.warning_rounded, color: _T.danger, size: 28),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Remove Student Result?',
//                 style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Are you sure you want to remove $studentName from this exam?',
//                 textAlign: TextAlign.center,
//                 style:
//                 const TextStyle(color: _T.textSecondary, fontSize: 13.5),
//               ),
//               const SizedBox(height: 22),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(ctx, false),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         side: const BorderSide(color: _T.border),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text('Cancel',
//                           style: TextStyle(
//                               color: _T.textSecondary,
//                               fontWeight: FontWeight.w700)),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.pop(ctx, true),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _T.danger,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text('Remove',
//                           style: TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.w700)),
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
//   bool _isExamPass(_StudentExamResult result) {
//     final sm = result.studentMarks;
//     for (final subj in result.examCard.subjects) {
//       final obtained = sm.obtainedMarks[subj.name] ?? 0;
//       if (obtained < subj.totalMarks * 0.25) return false;
//     }
//     return true;
//   }
//
//   Widget _buildPassFailChip(bool pass) {
//     return Container(
//       margin: const EdgeInsets.only(right: 2),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: pass ? _T.successBg : _T.dangerBg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             pass ? Icons.check_circle_rounded : Icons.cancel_rounded,
//             color: pass ? _T.success : _T.danger,
//             size: 13,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             pass ? 'PASS' : 'FAIL',
//             style: TextStyle(
//               fontWeight: FontWeight.w800,
//               fontSize: 10.5,
//               letterSpacing: 0.3,
//               color: pass ? _T.success : _T.danger,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   SnackBar _snack(String msg, {bool isError = false}) {
//     return SnackBar(
//       content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
//       backgroundColor: isError ? _T.danger : _T.textPrimary,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       duration: const Duration(seconds: 2),
//     );
//   }
// }
//
// // ─── Small reusable animated widgets ──────────────────────────
//
// class _StatData {
//   final String label;
//   final int value;
//   final Color color;
//   final Color bgColor;
//   final IconData icon;
//   _StatData(this.label, this.value, this.color, this.bgColor, this.icon);
// }
//
// /// Staggered fade + slide entrance for list/grid items.
// /// Falls back gracefully (no error) even with large item counts by
// /// capping the stagger window.
// /// SliverPersistentHeaderDelegate that pins the search/filter bar to the
// /// top of the scroll view. Supports a variable maxHeight so the mobile
// /// "expanded filters" state can animate its height too.
// class _StickyFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final double minHeight;
//   final double maxHeight;
//   final Widget child;
//   final Color backgroundColor;
//
//   _StickyFilterHeaderDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//     required this.child,
//     this.backgroundColor = _T.bg,
//   });
//
//   @override
//   double get minExtent => minHeight;
//
//   @override
//   double get maxExtent => maxHeight < minHeight ? minHeight : maxHeight;
//
//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: backgroundColor,
//       alignment: Alignment.topCenter,
//       child: ClipRect(
//         child: OverflowBox(
//           minHeight: 0,
//           maxHeight: double.infinity,
//           alignment: Alignment.topCenter,
//           child: child,
//         ),
//       ),
//     );
//   }
//
//   @override
//   bool shouldRebuild(covariant _StickyFilterHeaderDelegate oldDelegate) {
//     return oldDelegate.child != child ||
//         oldDelegate.maxHeight != maxHeight ||
//         oldDelegate.minHeight != minHeight;
//   }
// }
//
// class _AnimatedListItem extends StatelessWidget {
//   final int index;
//   final AnimationController controller;
//   final Widget child;
//
//   const _AnimatedListItem({
//     required this.index,
//     required this.controller,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final cappedIndex = index.clamp(0, 12); // avoid huge stagger delays
//     final start = (cappedIndex * 0.05).clamp(0.0, 0.8);
//     final end = (start + 0.4).clamp(0.0, 1.0);
//
//     final animation = CurvedAnimation(
//       parent: controller,
//       curve: Interval(start, end, curve: Curves.easeOutCubic),
//     );
//
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, _) {
//         return Opacity(
//           opacity: animation.value,
//           child: Transform.translate(
//             offset: Offset(0, (1 - animation.value) * 16),
//             child: child,
//           ),
//         );
//       },
//     );
//   }
// }
//
// /// Lightweight hover/press scale wrapper — subtle, works on web & mobile,
// /// uses only implicit animation (no external packages).
// class _HoverScaleCard extends StatefulWidget {
//   final Widget child;
//   final VoidCallback? onTap;
//   const _HoverScaleCard({required this.child, this.onTap});
//
//   @override
//   State<_HoverScaleCard> createState() => _HoverScaleCardState();
// }
//
// class _HoverScaleCardState extends State<_HoverScaleCard> {
//   bool _hovering = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (_) => setState(() => _hovering = true),
//       onExit: (_) => setState(() => _hovering = false),
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: AnimatedScale(
//           scale: _hovering ? 1.015 : 1.0,
//           duration: const Duration(milliseconds: 180),
//           curve: Curves.easeOut,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             child: widget.child,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Helper class ────────────────────────────────────────────
//
// class _StudentExamResult {
//   final StudentWithContext student;
//   final ExamResultCard examCard;
//   final StudentExamMarks studentMarks;
//
//   _StudentExamResult({
//     required this.student,
//     required this.examCard,
//     required this.studentMarks,
//   });
// }



import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../models/class_model.dart';
import '../../models/exam_result_card_model.dart';
import '../../pdf_files/result_card_pdf_generator.dart';
import '../../providers/class_provider.dart';
import '../../providers/exam_result_card_provider.dart';
import '../../providers/student_provider.dart';
import 'exam_result_card_form_screen.dart';

// ─── Design Tokens ─────────────────────────────────────────────
class _T {
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF4338CA);
  static const primaryLight = Color(0xFFEEF2FF);
  static const bg = Color(0xFFF8F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFEDEFF5);
  static const success = Color(0xFF059669);
  static const successBg = Color(0xFFECFDF5);
  static const danger = Color(0xFFDC2626);
  static const dangerBg = Color(0xFFFEF2F2);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  static const cardRadius = 20.0;

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primary.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
  );
}

enum _ViewMode { list, grid }

/// Special sentinel value for the "All Data" date-range filter option,
/// distinct from `null` which is used for "no exam filter" elsewhere.
const String _kAllDataRange = '__all_data__';

class StudentWiseResultCardsScreen extends StatefulWidget {
  const StudentWiseResultCardsScreen({super.key});

  @override
  State<StudentWiseResultCardsScreen> createState() =>
      _StudentWiseResultCardsScreenState();
}

class _StudentWiseResultCardsScreenState
    extends State<StudentWiseResultCardsScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedClassId;
  String? _selectedSectionName;
  String? _selectedExamName; // null = All Exams
  String _search = '';
  bool _filtersExpanded = false;
  _ViewMode _viewMode = _ViewMode.grid;
  late AnimationController _listController;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  // Month/Year filter — defaults to the current month; switching to
  // "All Data" removes the date restriction entirely.
  int? _filterMonth = DateTime.now().month;
  int? _filterYear = DateTime.now().year;
  bool _showAllData = false;

  // Selection / PDF generation mode.
  bool _selectionMode = false;
  final Set<String> _selectedResultKeys = {}; // "${cardId}_${studentId}"

  bool _generatingPdf = false;

  // ─── Helpers ──────────────────────────────────────────────

  String _classNameById(String id) {
    final cls = context.read<ClassProvider>().classes.firstWhere(
          (c) => c.id == id,
      orElse: () => SchoolClass(name: 'Unknown'),
    );
    return cls.name;
  }

  String _resultKey(_StudentExamResult r) =>
      '${r.examCard.id ?? r.examCard.examName}_${r.student.student.studentId}';

  List<_StudentExamResult> _buildFlatResults(
      List<StudentWithContext> allStudents, List<ExamResultCard> allCards) {
    final results = <_StudentExamResult>[];
    final studentMap = {for (final s in allStudents) s.student.studentId: s};

    for (final card in allCards) {
      for (final sm in card.studentMarks) {
        final student = studentMap[sm.studentId];
        if (student != null) {
          results.add(_StudentExamResult(
            student: student,
            examCard: card,
            studentMarks: sm,
          ));
        }
      }
    }
    return results;
  }

  // ─── Lifecycle ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _listController.forward();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldShow = _scrollController.hasClients &&
        _scrollController.offset > 320;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _listController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final examCardProvider = context.watch<ExamResultCardProvider>();
    final studentProvider = context.watch<StudentProvider>();

    final allStudents = studentProvider.allActiveStudents;
    final allCards = examCardProvider.cards;

    var flatResults = _buildFlatResults(allStudents, allCards);

    if (_selectedClassId != null) {
      final className = _classNameById(_selectedClassId!);
      flatResults = flatResults
          .where((r) => r.student.student.className == className)
          .toList();
    }

    if (_selectedSectionName != null) {
      flatResults = flatResults
          .where((r) => r.student.student.sectionName == _selectedSectionName)
          .toList();
    }

    if (_selectedExamName != null) {
      flatResults = flatResults
          .where((r) => r.examCard.examName == _selectedExamName)
          .toList();
    }

    // Month/Year filter — only applied when "All Data" is off.
    if (!_showAllData && _filterMonth != null && _filterYear != null) {
      flatResults = flatResults.where((r) {
        final d = r.examCard.date;
        return d.month == _filterMonth && d.year == _filterYear;
      }).toList();
    }

    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      flatResults = flatResults.where((r) {
        final s = r.student;
        return s.student.name.toLowerCase().contains(q) ||
            s.familyId.toLowerCase().contains(q) ||
            s.student.studentId.toLowerCase().contains(q) ||
            r.examCard.examName.toLowerCase().contains(q);
      }).toList();
    }

    flatResults.sort((a, b) {
      final nameComp =
      a.student.student.name.compareTo(b.student.student.name);
      if (nameComp != 0) return nameComp;
      return b.examCard.date.compareTo(a.examCard.date);
    });

    final totalResults = flatResults.length;
    final passCount = flatResults.where((r) => _isExamPass(r)).length;
    final failCount = totalResults - passCount;

    final width = MediaQuery.of(context).size.width;
    final isWeb = width > 800;
    final isLoading = examCardProvider.isLoading || studentProvider.isLoading;

    final examNames = allCards.map((c) => c.examName).toSet().toList()
      ..sort();

    return Scaffold(
      backgroundColor: _T.bg,
      body: Stack(
        children: [
          isWeb
              ? _buildWebLayout(context, classProvider, flatResults,
              totalResults, passCount, failCount, isLoading, examNames)
              : _buildMobileLayout(context, classProvider, flatResults,
              totalResults, passCount, failCount, isLoading, examNames),
          _buildScrollToTopButton(),
          if (_selectionMode) _buildSelectionBar(flatResults),
        ],
      ),
      floatingActionButton: isWeb ? null : _buildMobileFab(context),
    );
  }

  // ─── Scroll-to-top button ───────────────────────────────────

  Widget _buildScrollToTopButton() {
    return Positioned(
      right: 20,
      bottom: _selectionMode ? 92 : 20,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        offset: _showScrollToTop ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showScrollToTop ? 1 : 0,
          child: IgnorePointer(
            ignoring: !_showScrollToTop,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _scrollToTop,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: _T.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _T.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.keyboard_arrow_up_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Selection / PDF bottom bar ──────────────────────────────

  Widget _buildSelectionBar(List<_StudentExamResult> visibleResults) {
    final allKeys = visibleResults.map(_resultKey).toSet();
    final allSelected = allKeys.isNotEmpty &&
        allKeys.every((k) => _selectedResultKeys.contains(k));

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: _T.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Checkbox(
                value: allSelected,
                activeColor: _T.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedResultKeys.addAll(allKeys);
                    } else {
                      _selectedResultKeys.removeAll(allKeys);
                    }
                  });
                },
              ),
              Expanded(
                child: Text(
                  '${_selectedResultKeys.length} selected',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: _T.textPrimary),
                ),
              ),
              TextButton(
                onPressed: _generatingPdf
                    ? null
                    : () {
                  setState(() {
                    _selectionMode = false;
                    _selectedResultKeys.clear();
                  });
                },
                child: const Text('Cancel',
                    style: TextStyle(
                        color: _T.textSecondary,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: (_selectedResultKeys.isEmpty || _generatingPdf)
                    ? null
                    : () => _confirmAndGeneratePdf(visibleResults),
                icon: _generatingPdf
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: Text(_generatingPdf ? 'Generating...' : 'Confirm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _T.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startSelectionAll(List<_StudentExamResult> visibleResults) {
    setState(() {
      _selectionMode = true;
      _selectedResultKeys
        ..clear()
        ..addAll(visibleResults.map(_resultKey));
    });
  }

  Future<void> _confirmAndGeneratePdf(
      List<_StudentExamResult> visibleResults) async {
    final selected = visibleResults
        .where((r) => _selectedResultKeys.contains(_resultKey(r)))
        .toList();

    if (selected.isEmpty) return;

    setState(() => _generatingPdf = true);
    try {
      final studentProvider = context.read<StudentProvider>();
      final lookup = {
        for (final s in studentProvider.allActiveStudents)
          s.student.studentId: s,
      };

      final pairs = selected
          .map((r) => MapEntry(r.examCard, r.studentMarks))
          .toList();

      final entries = buildResultCardEntries(
        selected: pairs,
        studentLookup: lookup,
      );

      final bytes = await ResultCardPdfGenerator.generate(results: entries);

      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name:
        'Result_Cards_${DateFormat('ddMMMyyyy').format(DateTime.now())}.pdf',
      );

      if (mounted) {
        setState(() {
          _selectionMode = false;
          _selectedResultKeys.clear();
        });
      }
    } catch (e, stack) {
      debugPrint('PDF GENERATION ERROR: $e');
      debugPrint('STACK TRACE:\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_snack('PDF generation failed: $e', isError: true));
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  // ══════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ══════════════════════════════════════════════════════════

  Widget _buildMobileFab(BuildContext context) {
    if (_selectionMode) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExamResultCardFormScreen()),
        );
      },
      backgroundColor: _T.primary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text('New Result',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      ClassProvider classProvider,
      List<_StudentExamResult> flatResults,
      int total,
      int pass,
      int fail,
      bool isLoading,
      List<String> examNames,
      ) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverAppBar(
          pinned: false,
          floating: true,
          backgroundColor: _T.bg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          expandedHeight: 118,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: const Text(
              'Student Results',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.3,
                color: _T.textPrimary,
              ),
            ),
            background: Container(color: _T.bg),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined,
                  color: _T.textSecondary),
              onPressed: () => _startSelectionAll(flatResults),
            ),
            const SizedBox(width: 4),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _buildStatsRow(total, pass, fail, compact: true),
          ),
        ),
        // Sticky: search bar + filters + view toggle stay pinned at the
        // top once scrolled past, so the user can always search/filter
        // without scrolling back up.
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyFilterHeaderDelegate(
            minHeight: 64,
            maxHeight: _filtersExpanded ? 330 : 64,
            child: _buildStickyFilterBar(classProvider, examNames,
                isMobile: true),
          ),
        ),
        if (isLoading)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                  color: _T.primary, strokeWidth: 3),
            ),
          )
        else if (flatResults.isEmpty)
          SliverFillRemaining(child: _buildEmptyState())
        else if (_viewMode == _ViewMode.grid)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, _selectionMode ? 110 : 100),
              sliver: _buildResponsiveGridSliver(flatResults),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, _selectionMode ? 110 : 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _AnimatedListItem(
                    index: i,
                    controller: _listController,
                    child: _buildResultCard(flatResults[i], isMobile: true),
                  ),
                  childCount: flatResults.length,
                ),
              ),
            ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // WEB LAYOUT
  // ══════════════════════════════════════════════════════════

  Widget _buildWebLayout(
      BuildContext context,
      ClassProvider classProvider,
      List<_StudentExamResult> flatResults,
      int total,
      int pass,
      int fail,
      bool isLoading,
      List<String> examNames,
      ) {
    return Column(
      children: [
        _buildWebHeader(context, flatResults),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                      child: _buildStatsRow(total, pass, fail, compact: false),
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyFilterHeaderDelegate(
                  minHeight: 78,
                  maxHeight: 78,
                  backgroundColor: _T.bg,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 16, 32, 10),
                        child: _buildSearchAndFilterCard(
                            classProvider, examNames,
                            isMobile: false),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          32, 10, 32, _selectionMode ? 110 : 32),
                      child: isLoading
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 120),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: _T.primary, strokeWidth: 3),
                        ),
                      )
                          : flatResults.isEmpty
                          ? Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 60),
                        child: _buildEmptyState(),
                      )
                          : _viewMode == _ViewMode.grid
                          ? _buildResponsiveGrid(flatResults)
                          : _buildResultListColumn(flatResults),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebHeader(
      BuildContext context, List<_StudentExamResult> flatResults) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: _T.surface,
        border: Border(bottom: BorderSide(color: _T.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: _T.gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _T.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.assignment_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Results',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.4,
                  color: _T.textPrimary,
                ),
              ),
              Text(
                'View and manage exam result cards',
                style: TextStyle(
                  fontSize: 13,
                  color: _T.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildViewToggle(),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _startSelectionAll(flatResults),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _T.textSecondary,
              side: const BorderSide(color: _T.border),
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ExamResultCardFormScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('New Result Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _T.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats ──────────────────────────────────────────────────

  Widget _buildStatsRow(int total, int pass, int fail,
      {required bool compact}) {
    final items = [
      _StatData('Total Results', total, _T.primary, _T.primaryLight,
          Icons.assignment_rounded),
      _StatData(
          'Passed', pass, _T.success, _T.successBg, Icons.check_circle_rounded),
      _StatData('Failed', fail, _T.danger, _T.dangerBg, Icons.cancel_rounded),
    ];

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.cardRadius),
          boxShadow: _T.softShadow,
        ),
        child: Row(
          children: items
              .map((item) => Expanded(child: _statItemCompact(item)))
              .toList(),
        ),
      );
    }

    return Row(
      children: items
          .map((item) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _statCardWeb(item),
        ),
      ))
          .toList(),
    );
  }

  Widget _statItemCompact(_StatData item) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: item.bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          item.value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
            letterSpacing: -0.5,
            color: _T.textPrimary,
          ),
        ),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _T.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _statCardWeb(_StatData item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.cardRadius),
        boxShadow: _T.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -0.6,
                  color: _T.textPrimary,
                ),
              ),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _T.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Filters ────────────────────────────────────────────────

  Widget _buildSearchAndFilterCard(
      ClassProvider classProvider, List<String> examNames,
      {required bool isMobile}) {
    final classes = classProvider.classes;
    final sections = _selectedClassId == null
        ? <String>[]
        : classProvider.classes
        .firstWhere((c) => c.id == _selectedClassId,
        orElse: () => SchoolClass(name: ''))
        .sections
        .map((s) => s.sectionName)
        .toList();

    if (!isMobile) {
      // Web: single row — search + class + section + exam + month/year.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.cardRadius),
          boxShadow: _T.softShadow,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: _searchField(),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _dropdownField<String?>(
                value: _selectedClassId,
                hint: 'All Classes',
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('All Classes')),
                  ...classes.map((c) => DropdownMenuItem<String?>(
                      value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) {
                  setState(() {
                    _selectedClassId = v;
                    _selectedSectionName = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _dropdownField<String?>(
                value: _selectedSectionName,
                hint: 'All Sections',
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('All Sections')),
                  ...sections.map((s) =>
                      DropdownMenuItem<String?>(value: s, child: Text(s))),
                ],
                onChanged: (v) => setState(() => _selectedSectionName = v),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _dropdownField<String?>(
                value: _selectedExamName,
                hint: 'All Exams',
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('All Exams')),
                  ...examNames.map((e) =>
                      DropdownMenuItem<String?>(value: e, child: Text(e))),
                ],
                onChanged: (v) => setState(() => _selectedExamName = v),
              ),
            ),
            const SizedBox(width: 10),
            _iconToggleButton(
              icon: Icons.calendar_month_rounded,
              active: true,
              onTap: () => _openDateFilterSheet(),
            ),
          ],
        ),
      );
    }

    // Mobile: compact — search bar + filter toggle + view toggle always
    // visible; class/section/exam/date filters reveal underneath when
    // expanded.
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.cardRadius),
        boxShadow: _T.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _searchField()),
              const SizedBox(width: 8),
              _iconToggleButton(
                icon: Icons.tune_rounded,
                active: _filtersExpanded ||
                    _selectedClassId != null ||
                    _selectedSectionName != null ||
                    _selectedExamName != null,
                onTap: () =>
                    setState(() => _filtersExpanded = !_filtersExpanded),
              ),
              const SizedBox(width: 8),
              _buildViewToggle(),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _filtersExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownField<String?>(
                          value: _selectedClassId,
                          hint: 'All Classes',
                          items: [
                            const DropdownMenuItem<String?>(
                                value: null, child: Text('All Classes')),
                            ...classes.map((c) => DropdownMenuItem<String?>(
                                value: c.id, child: Text(c.name))),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _selectedClassId = v;
                              _selectedSectionName = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dropdownField<String?>(
                          value: _selectedSectionName,
                          hint: 'All Sections',
                          items: [
                            const DropdownMenuItem<String?>(
                                value: null, child: Text('All Sections')),
                            ...sections.map((s) => DropdownMenuItem<String?>(
                                value: s, child: Text(s))),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedSectionName = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownField<String?>(
                          value: _selectedExamName,
                          hint: 'All Exams',
                          items: [
                            const DropdownMenuItem<String?>(
                                value: null, child: Text('All Exams')),
                            ...examNames.map((e) => DropdownMenuItem<String?>(
                                value: e, child: Text(e))),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedExamName = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _dateFilterChip(),
                    ],
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  /// Compact chip showing the current month/year (or "All Data"), tapping
  /// opens the picker sheet.
  Widget _dateFilterChip() {
    final label = _showAllData
        ? 'All Data'
        : DateFormat('MMM yyyy')
        .format(DateTime(_filterYear ?? DateTime.now().year,
        _filterMonth ?? DateTime.now().month));

    return InkWell(
      onTap: _openDateFilterSheet,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _T.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _T.primary.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded,
                color: _T.primary, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _T.primary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDateFilterSheet() async {
    int tempMonth = _filterMonth ?? DateTime.now().month;
    int tempYear = _filterYear ?? DateTime.now().year;
    bool tempAllData = _showAllData;

    final months = List.generate(
        12, (i) => DateFormat('MMMM').format(DateTime(2000, i + 1)));
    final currentYear = DateTime.now().year;
    final years = List.generate(6, (i) => currentYear - 3 + i);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: _T.surface,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _T.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text('Filter by Date',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: _T.primary,
                    title: const Text('Show All Data',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: const Text(
                        'Ignore month/year, show every result',
                        style: TextStyle(fontSize: 12, color: _T.textSecondary)),
                    value: tempAllData,
                    onChanged: (v) => setSheetState(() => tempAllData = v),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: tempAllData
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _sheetDropdown<int>(
                              label: 'Month',
                              value: tempMonth,
                              items: List.generate(
                                12,
                                    (i) => DropdownMenuItem(
                                    value: i + 1, child: Text(months[i])),
                              ),
                              onChanged: (v) =>
                                  setSheetState(() => tempMonth = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _sheetDropdown<int>(
                              label: 'Year',
                              value: tempYear,
                              items: years
                                  .map((y) => DropdownMenuItem(
                                  value: y, child: Text('$y')))
                                  .toList(),
                              onChanged: (v) =>
                                  setSheetState(() => tempYear = v!),
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondChild: const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showAllData = tempAllData;
                          _filterMonth = tempMonth;
                          _filterYear = tempYear;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _T.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                        const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 11.5, color: _T.textSecondary),
            border: InputBorder.none,
          ),
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _T.textPrimary),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search student, ID, family or exam...',
          hintStyle: TextStyle(
              color: _T.textTertiary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500),
          prefixIcon:
          const Icon(Icons.search_rounded, color: _T.textTertiary, size: 22),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        ),
      ),
    );
  }

  Widget _iconToggleButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _T.primaryLight : _T.bg,
          borderRadius: BorderRadius.circular(14),
          border: active ? Border.all(color: _T.primary, width: 1.2) : null,
        ),
        child: Icon(icon,
            color: active ? _T.primary : _T.textTertiary, size: 20),
      ),
    );
  }

  /// List / Grid view toggle — matches the old behavior where users could
  /// switch between a compact list and a card grid.
  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _viewToggleIcon(Icons.view_list_rounded, _ViewMode.list),
          _viewToggleIcon(Icons.grid_view_rounded, _ViewMode.grid),
        ],
      ),
    );
  }

  Widget _viewToggleIcon(IconData icon, _ViewMode mode) {
    final active = _viewMode == mode;
    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _T.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: active
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Icon(icon,
            size: 19, color: active ? _T.primary : _T.textTertiary),
      ),
    );
  }

  /// Wrapper used for the sticky-header build inside CustomScrollView.
  Widget _buildStickyFilterBar(
      ClassProvider classProvider, List<String> examNames,
      {required bool isMobile}) {
    return Container(
      color: _T.bg,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: _buildSearchAndFilterCard(classProvider, examNames,
          isMobile: isMobile),
    );
  }

  Widget _dropdownField<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: _T.textTertiary),
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _T.textPrimary),
          borderRadius: BorderRadius.circular(14),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── Empty State ────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: _T.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_outlined,
                size: 44, color: _T.primary.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No exam results found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _T.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _showAllData
                ? 'Generate a result card first to see results here.'
                : 'No results for this month. Try "All Data" in the date filter.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: _T.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Grid Layout (masonry-style, no leftover empty space) ──────

  int _gridColumnCount(double width) {
    if (width >= 1180) return 3;
    if (width >= 760) return 2;
    return 1;
  }

  Widget _buildResponsiveGrid(List<_StudentExamResult> results) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _gridColumnCount(constraints.maxWidth);
        if (columnCount == 1) {
          return _buildResultListColumn(results);
        }
        final columns = List.generate(columnCount, (_) => <Widget>[]);
        for (var i = 0; i < results.length; i++) {
          final col = i % columnCount;
          columns[col].add(
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _AnimatedListItem(
                index: i,
                controller: _listController,
                child: _buildResultCard(results[i], isMobile: false),
              ),
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < columnCount; c++) ...[
              if (c > 0) const SizedBox(width: 18),
              Expanded(
                child: Column(children: columns[c]),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Same masonry grid but usable inside a CustomScrollView sliver
  /// (mobile). Falls back to a single column list on narrow screens.
  Widget _buildResponsiveGridSliver(List<_StudentExamResult> results) {
    return SliverToBoxAdapter(
      child: _buildResponsiveGrid(results),
    );
  }

  Widget _buildResultListColumn(List<_StudentExamResult> results) {
    return Column(
      children: [
        for (var i = 0; i < results.length; i++)
          _AnimatedListItem(
            index: i,
            controller: _listController,
            child: _buildResultCard(results[i], isMobile: true),
          ),
      ],
    );
  }

  // ─── Result Card (shared, mobile/web variants) ─────────────

  Widget _buildResultCard(_StudentExamResult result, {required bool isMobile}) {
    final student = result.student;
    final exam = result.examCard;
    final sm = result.studentMarks;
    final isPass = _isExamPass(result);
    final key = _resultKey(result);
    final isSelected = _selectedResultKeys.contains(key);

    return _HoverScaleCard(
      onTap: _selectionMode
          ? () {
        setState(() {
          if (isSelected) {
            _selectedResultKeys.remove(key);
          } else {
            _selectedResultKeys.add(key);
          }
        });
      }
          : () {},
      onLongPress: () {
        if (!_selectionMode) {
          setState(() {
            _selectionMode = true;
            _selectedResultKeys.add(key);
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isMobile ? 14 : 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.cardRadius),
          border: Border.all(
              color: isSelected ? _T.primary : _T.border,
              width: isSelected ? 1.6 : 1),
          boxShadow: _T.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_selectionMode) ...[
                  Checkbox(
                    value: isSelected,
                    activeColor: _T.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedResultKeys.add(key);
                        } else {
                          _selectedResultKeys.remove(key);
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                ],
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: _T.gradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    student.student.name.isNotEmpty
                        ? student.student.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.student.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: _T.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${student.student.className} · ${student.student.sectionName}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _T.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPassFailChip(isPass),
                if (!_selectionMode)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: _T.textTertiary, size: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamResultCardFormScreen(
                              card: exam,
                              studentContext: student,
                            ),
                          ),
                        );
                      } else if (value == 'pdf') {
                        setState(() {
                          _selectionMode = true;
                          _selectedResultKeys.add(key);
                        });
                      } else if (value == 'delete') {
                        final confirmed =
                        await _showRemoveDialog(student.student.name);
                        if (confirmed == true) {
                          try {
                            await context
                                .read<ExamResultCardProvider>()
                                .removeStudentFromCard(
                                exam.id!, student.student.studentId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  _snack('Student result removed.'));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                _snack('Error: $e', isError: true),
                              );
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                color: _T.primary, size: 18),
                            SizedBox(width: 10),
                            Text('Edit Marks',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'pdf',
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf_outlined,
                                color: _T.success, size: 18),
                            SizedBox(width: 10),
                            Text('Generate PDF',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                color: _T.danger, size: 18),
                            SizedBox(width: 10),
                            Text('Remove Student',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: _T.border),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exam.examName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: _T.textPrimary,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(exam.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _T.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...exam.subjects.map((subj) {
              final obtained = sm.obtainedMarks[subj.name] ?? 0;
              final total = subj.totalMarks;
              final percentage = total > 0 ? obtained / total : 0.0;
              final isFail = obtained < total * 0.25;
              final barColor = isFail ? _T.danger : _T.success;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        subj.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _T.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                              begin: 0, end: percentage.clamp(0.0, 1.0)),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (ctx, value, _) => LinearProgressIndicator(
                            value: value,
                            backgroundColor: _T.bg,
                            color: barColor,
                            minHeight: 7,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 54,
                      child: Text(
                        '$obtained/$total',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: barColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showRemoveDialog(String studentName) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _T.dangerBg,
                  shape: BoxShape.circle,
                ),
                child:
                const Icon(Icons.warning_rounded, color: _T.danger, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Remove Student Result?',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove $studentName from this exam?',
                textAlign: TextAlign.center,
                style:
                const TextStyle(color: _T.textSecondary, fontSize: 13.5),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: _T.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: _T.textSecondary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _T.danger,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Remove',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700)),
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

  bool _isExamPass(_StudentExamResult result) {
    final sm = result.studentMarks;
    for (final subj in result.examCard.subjects) {
      final obtained = sm.obtainedMarks[subj.name] ?? 0;
      if (obtained < subj.totalMarks * 0.25) return false;
    }
    return true;
  }

  Widget _buildPassFailChip(bool pass) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pass ? _T.successBg : _T.dangerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pass ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: pass ? _T.success : _T.danger,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            pass ? 'PASS' : 'FAIL',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              letterSpacing: 0.3,
              color: pass ? _T.success : _T.danger,
            ),
          ),
        ],
      ),
    );
  }

  SnackBar _snack(String msg, {bool isError = false}) {
    return SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? _T.danger : _T.textPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    );
  }
}

// ─── Small reusable animated widgets ──────────────────────────

class _StatData {
  final String label;
  final int value;
  final Color color;
  final Color bgColor;
  final IconData icon;
  _StatData(this.label, this.value, this.color, this.bgColor, this.icon);
}

/// SliverPersistentHeaderDelegate that pins the search/filter bar to the
/// top of the scroll view. Supports a variable maxHeight so the mobile
/// "expanded filters" state can animate its height too.
class _StickyFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  final Color backgroundColor;

  _StickyFilterHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
    this.backgroundColor = _T.bg,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight < minHeight ? minHeight : maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: OverflowBox(
          minHeight: 0,
          maxHeight: double.infinity,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilterHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.minHeight != minHeight;
  }
}

class _AnimatedListItem extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedListItem({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cappedIndex = index.clamp(0, 12); // avoid huge stagger delays
    final start = (cappedIndex * 0.05).clamp(0.0, 0.8);
    final end = (start + 0.4).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 16),
            child: child,
          ),
        );
      },
    );
  }
}

/// Lightweight hover/press scale wrapper — subtle, works on web & mobile,
/// uses only implicit animation (no external packages).
class _HoverScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const _HoverScaleCard({required this.child, this.onTap, this.onLongPress});

  @override
  State<_HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<_HoverScaleCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _hovering ? 1.015 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─── Helper class ────────────────────────────────────────────

class _StudentExamResult {
  final StudentWithContext student;
  final ExamResultCard examCard;
  final StudentExamMarks studentMarks;

  _StudentExamResult({
    required this.student,
    required this.examCard,
    required this.studentMarks,
  });
}