//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/class_model.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/teacher_provider.dart';
// import 'add_class.dart';
//
// const _kPurple = Color(0xFF534AB7);
// const _kPurpleLight = Color(0xFFEEEDFE);
//
// class ClassesListScreen extends StatefulWidget {
//   final bool showAppBar;
//   final bool showFAB;
//   const ClassesListScreen({
//     super.key,
//     this.showAppBar = true,
//     this.showFAB = true,
//   });
//
//   @override
//   State<ClassesListScreen> createState() => _ClassesListScreenState();
// }
//
// class _ClassesListScreenState extends State<ClassesListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   int _currentPage = 1;
//   int _perPage = 10;
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8FA),
//       appBar: widget.showAppBar
//           ? AppBar(
//         title: const Text('Classes',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         surfaceTintColor: Colors.white,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(height: 1, color: Colors.grey.shade200),
//         ),
//       )
//           : null,
//       body: Consumer<ClassProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading && provider.classes.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (provider.error != null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error: ${provider.error}'),
//                   const SizedBox(height: 12),
//                   ElevatedButton(
//                     onPressed: () => provider.clearError(),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final rows = _buildRows(provider.classes);
//           final filtered = rows
//               .where((r) =>
//           r.className
//               .toLowerCase()
//               .contains(_searchQuery.toLowerCase()) ||
//               r.sectionName
//                   .toLowerCase()
//                   .contains(_searchQuery.toLowerCase()) ||
//               (r.headTeacher ?? '')
//                   .toLowerCase()
//                   .contains(_searchQuery.toLowerCase()))
//               .toList();
//
//           return LayoutBuilder(
//             builder: (context, constraints) {
//               final isMobile = constraints.maxWidth < 600;
//               return Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: EdgeInsets.all(isMobile ? 12 : 16),
//                       child: isMobile
//                           ? _buildMobileLayout(context, filtered, provider)
//                           : _buildDesktopLayout(
//                           context, filtered, provider, constraints),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   // ── Mobile card layout ──────────────────────────────────────────────────
//
//   Widget _buildMobileLayout(BuildContext context, List<_ClassRow> filtered,
//       ClassProvider provider) {
//     final totalPages = (filtered.length / _perPage).ceil().clamp(1, 999);
//     if (_currentPage > totalPages) _currentPage = 1;
//
//     final start = (_currentPage - 1) * _perPage;
//     final pageRows = filtered.skip(start).take(_perPage).toList();
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 12,
//               offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildTopBar(context, filtered.length),
//           _buildMobileSearchBar(),
//           if (pageRows.isEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 48),
//               child: Center(
//                 child: Column(children: [
//                   Icon(Icons.search_off, size: 36, color: Colors.grey.shade300),
//                   const SizedBox(height: 10),
//                   Text('No classes match your search',
//                       style: TextStyle(
//                           fontSize: 13, color: Colors.grey.shade400)),
//                 ]),
//               ),
//             )
//           else
//             ListView.separated(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: pageRows.length,
//               separatorBuilder: (_, __) =>
//                   Divider(height: 1, color: Colors.grey.shade100),
//               itemBuilder: (context, idx) => _buildMobileCard(
//                   context,
//                   pageRows[idx],
//                   (_currentPage - 1) * _perPage + idx + 1,
//                   provider),
//             ),
//           _buildFooter(filtered.length, start, pageRows.length, totalPages),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMobileSearchBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
//       color: const Color(0xFFFAFAFA),
//       child: TextField(
//         controller: _searchController,
//         onChanged: (v) => setState(() {
//           _searchQuery = v;
//           _currentPage = 1;
//         }),
//         style: const TextStyle(fontSize: 13),
//         decoration: InputDecoration(
//           hintText: 'Search class, section, teacher...',
//           hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
//           prefixIcon:
//           Icon(Icons.search, size: 17, color: Colors.grey.shade400),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: _kPurple, width: 1.5),
//           ),
//           isDense: true,
//           contentPadding: const EdgeInsets.symmetric(vertical: 10),
//           filled: true,
//           fillColor: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMobileCard(BuildContext context, _ClassRow row, int serial,
//       ClassProvider provider) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Avatar / index
//           Column(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: _kPurpleLight,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 child: Center(
//                   child: Text(
//                     row.className.trim().isEmpty
//                         ? '?'
//                         : row.className.trim()[0].toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                         color: _kPurple),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '#$serial',
//                 style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
//               ),
//             ],
//           ),
//           const SizedBox(width: 12),
//           // Content
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Row 1: Class name + section badge
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         row.className,
//                         style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF1A1A2E)),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: _kPurpleLight,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         row.sectionName,
//                         style: const TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: _kPurple),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 // Row 2: Teacher info
//                 if (row.headTeacher != null && row.headTeacher!.isNotEmpty) ...[
//                   Row(
//                     children: [
//                       _miniAvatar(row.headTeacher!),
//                       const SizedBox(width: 5),
//                       Expanded(
//                         child: Text(
//                           row.headTeacher!,
//                           style: const TextStyle(
//                               fontSize: 12, color: Color(0xFF444444)),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ] else
//                   Text('No teacher assigned',
//                       style: TextStyle(
//                           fontSize: 12, color: Colors.grey.shade400)),
//                 const SizedBox(height: 6),
//                 // Row 3: Fee + subjects row
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF3E0),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '${row.subjectCount} subj.',
//                         style: const TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFFE65100)),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     if (row.monthlyFee != null) ...[
//                       Text(
//                         'Rs ${row.monthlyFee!.toStringAsFixed(0)}/mo',
//                         style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF2E7D32)),
//                       ),
//                     ] else
//                       Text('No fee',
//                           style: TextStyle(
//                               fontSize: 12, color: Colors.grey.shade300)),
//                     const Spacer(),
//                     // Edit button
//                     _actionBtn(
//                       icon: Icons.edit_outlined,
//                       color: Colors.grey.shade600,
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               AddEditClassScreen(existingClass: row.schoolClass),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     // Delete button
//                     _actionBtn(
//                       icon: Icons.delete_outline,
//                       color: Colors.red.shade400,
//                       onTap: () => _confirmDelete(context, row.schoolClass),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Desktop layout ──────────────────────────────────────────────────────
//
//   List<_ClassRow> _buildRows(List<SchoolClass> classes) {
//     final rows = <_ClassRow>[];
//     for (final cls in classes) {
//       if (cls.sections != null && cls.sections!.isNotEmpty) {
//         for (final sec in cls.sections!) {
//           String secName = sec.sectionName;
//           final prefix = '${cls.name} section ';
//           if (secName.startsWith(prefix)) {
//             secName = secName.substring(prefix.length);
//           }
//           rows.add(_ClassRow(
//             schoolClass: cls,
//             section: sec,
//             className: cls.name,
//             sectionName: secName,
//             headTeacher: sec.headOfTeacher,
//             subjectCount: sec.subjectMarks?.length ?? 0,
//             monthlyFee: sec.monthlyFee,
//             annualFee: sec.annualFee,
//           ));
//         }
//       } else {
//         rows.add(_ClassRow(
//           schoolClass: cls,
//           section: null,
//           className: cls.name,
//           sectionName: '—',
//           headTeacher: cls.headOfClassTeacher,
//           subjectCount: cls.subjects?.length ?? 0,
//           monthlyFee: cls.monthlyFee,
//           annualFee: cls.annualFee,
//         ));
//       }
//     }
//     return rows;
//   }
//
//   Widget _buildDesktopLayout(BuildContext context, List<_ClassRow> filtered,
//       ClassProvider provider, BoxConstraints constraints) {
//     final totalPages = (filtered.length / _perPage).ceil().clamp(1, 999);
//     if (_currentPage > totalPages) _currentPage = 1;
//
//     final start = (_currentPage - 1) * _perPage;
//     final pageRows = filtered.skip(start).take(_perPage).toList();
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 12,
//               offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildTopBar(context, filtered.length),
//           _buildToolbar(),
//           _buildResponsiveTable(context, pageRows, provider, constraints),
//           _buildFooter(filtered.length, start, pageRows.length, totalPages),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTopBar(BuildContext context, int count) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
//       ),
//       child: Row(children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Classes',
//                   style:
//                   TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//               Text(
//                 '$count ${count == 1 ? 'class' : 'entries'} found',
//                 style:
//                 TextStyle(fontSize: 12, color: Colors.grey.shade500),
//               ),
//             ],
//           ),
//         ),
//         ElevatedButton.icon(
//           onPressed: () async {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (_) => const AddEditClassScreen()),
//             );
//           },
//           icon: const Icon(Icons.add, size: 16),
//           label: const Text('Add class'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _kPurple,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10)),
//             padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             textStyle:
//             const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//           ),
//         ),
//       ]),
//     );
//   }
//
//   Widget _buildToolbar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
//       color: const Color(0xFFFAFAFA),
//       child: Row(children: [
//         Text('Show',
//             style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
//         const SizedBox(width: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<int>(
//               value: _perPage,
//               isDense: true,
//               style:
//               const TextStyle(fontSize: 13, color: Colors.black87),
//               items: [5, 10, 25, 50]
//                   .map((v) =>
//                   DropdownMenuItem(value: v, child: Text('$v')))
//                   .toList(),
//               onChanged: (v) => setState(() {
//                 _perPage = v!;
//                 _currentPage = 1;
//               }),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text('entries',
//             style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
//         const Spacer(),
//         SizedBox(
//           width: 220,
//           child: TextField(
//             controller: _searchController,
//             onChanged: (v) => setState(() {
//               _searchQuery = v;
//               _currentPage = 1;
//             }),
//             style: const TextStyle(fontSize: 13),
//             decoration: InputDecoration(
//               hintText: 'Search class, section...',
//               hintStyle:
//               TextStyle(fontSize: 13, color: Colors.grey.shade400),
//               prefixIcon: Icon(Icons.search,
//                   size: 17, color: Colors.grey.shade400),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(color: _kPurple, width: 1.5),
//               ),
//               isDense: true,
//               contentPadding: const EdgeInsets.symmetric(vertical: 10),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
//
//   // ── Responsive table using IntrinsicColumnWidth + FlexColumnWidth ───────
//   Widget _buildResponsiveTable(BuildContext context, List<_ClassRow> rows,
//       ClassProvider provider, BoxConstraints constraints) {
//     if (rows.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 48),
//         child: Center(
//           child: Column(children: [
//             Icon(Icons.search_off, size: 36, color: Colors.grey.shade300),
//             const SizedBox(height: 10),
//             Text('No classes match your search',
//                 style:
//                 TextStyle(fontSize: 13, color: Colors.grey.shade400)),
//           ]),
//         ),
//       );
//     }
//
//     // Use a custom list-based layout so it always fits the available width
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // Header row
//         Container(
//           color: const Color(0xFFF8F8FF),
//           child: _buildHeaderRow(),
//         ),
//         // Data rows
//         ...rows.asMap().entries.map((entry) {
//           final idx = entry.key;
//           final row = entry.value;
//           return Container(
//             decoration: BoxDecoration(
//               color: idx.isEven ? Colors.white : const Color(0xFFFCFCFF),
//               border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade100)),
//             ),
//             child: _buildDataRow(
//                 context,
//                 row,
//                 (_currentPage - 1) * _perPage + idx + 1,
//                 provider),
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _buildHeaderRow() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0),
//       child: Row(
//         children: [
//           _headerCell('#', flex: 1, center: false),
//           _headerCell('CLASS', flex: 4, center: false),
//           _headerCell('SECTION', flex: 2, center: false),
//           _headerCell('HEAD TEACHER', flex: 4, center: false),
//           _headerCell('SUBJECTS', flex: 2, center: true),
//           _headerCell('FEE', flex: 3, center: false),
//           _headerCell('ACTION', flex: 2, center: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _headerCell(String label, {required int flex, bool center = false}) {
//     return Expanded(
//       flex: flex,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         child: Align(
//           alignment: center ? Alignment.center : Alignment.centerLeft,
//           child: Text(
//             label,
//             style: const TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//                 color: _kPurple,
//                 letterSpacing: 0.5),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDataRow(BuildContext context, _ClassRow row, int serial,
//       ClassProvider provider) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // # serial
//           Expanded(
//             flex: 1,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Text(
//                 '$serial',
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
//               ),
//             ),
//           ),
//
//           // Class name with avatar
//           Expanded(
//             flex: 4,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 28,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: _kPurpleLight,
//                       borderRadius: BorderRadius.circular(7),
//                     ),
//                     child: Center(
//                       child: Text(
//                         row.className.trim().isEmpty
//                             ? '?'
//                             : row.className.trim()[0].toUpperCase(),
//                         style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w800,
//                             color: _kPurple),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Flexible(
//                     child: Text(
//                       row.className,
//                       style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1A1A2E)),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Section badge
//           Expanded(
//             flex: 2,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 alignment: Alignment.centerLeft,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: _kPurpleLight,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     row.sectionName,
//                     style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         color: _kPurple),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // Head Teacher
//           Expanded(
//             flex: 4,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: row.headTeacher != null && row.headTeacher!.isNotEmpty
//                   ? Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _miniAvatar(row.headTeacher!),
//                   const SizedBox(width: 7),
//                   Flexible(
//                     child: Text(
//                       row.headTeacher!,
//                       style: const TextStyle(
//                           fontSize: 12, color: Color(0xFF444444)),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               )
//                   : Text('—',
//                   style: TextStyle(
//                       fontSize: 13, color: Colors.grey.shade300)),
//             ),
//           ),
//
//           // Subjects badge
//           Expanded(
//             flex: 2,
//             child: Center(
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFF3E0),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '${row.subjectCount} subj.',
//                     style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFFE65100)),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // Fee
//           Expanded(
//             flex: 3,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: row.monthlyFee != null
//                   ? Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Rs ${row.monthlyFee!.toStringAsFixed(0)}/mo',
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF2E7D32)),
//                   ),
//                   if (row.annualFee != null)
//                     Text(
//                       'Annual: Rs ${row.annualFee!.toStringAsFixed(0)}',
//                       style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey.shade400),
//                     ),
//                 ],
//               )
//                   : Text('—',
//                   style: TextStyle(
//                       fontSize: 13, color: Colors.grey.shade300)),
//             ),
//           ),
//
//           // Actions — always visible, centered
//           Expanded(
//             flex: 2,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _actionBtn(
//                   icon: Icons.edit_outlined,
//                   color: Colors.grey.shade600,
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => AddEditClassScreen(
//                           existingClass: row.schoolClass),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 _actionBtn(
//                   icon: Icons.delete_outline,
//                   color: Colors.red.shade400,
//                   onTap: () => _confirmDelete(context, row.schoolClass),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFooter(int total, int start, int pageCount, int totalPages) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFAFAFA),
//         border: Border(top: BorderSide(color: Colors.grey.shade100)),
//         borderRadius:
//         const BorderRadius.vertical(bottom: Radius.circular(16)),
//       ),
//       child: Row(children: [
//         Flexible(
//           child: Text(
//             total == 0
//                 ? 'No entries'
//                 : 'Showing ${start + 1}–${start + pageCount} of $total entries',
//             style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Row(children: [
//           if (_currentPage > 1)
//             _pgBtn('‹', () => setState(() => _currentPage--)),
//           ...List.generate(totalPages, (i) {
//             final p = i + 1;
//             return _pgBtn(
//               '$p',
//                   () => setState(() => _currentPage = p),
//               active: p == _currentPage,
//             );
//           }),
//           if (_currentPage < totalPages)
//             _pgBtn('›', () => setState(() => _currentPage++)),
//         ]),
//       ]),
//     );
//   }
//
//   // ── Helper widgets ──────────────────────────────────────────────────────
//
//   Widget _miniAvatar(String name) {
//     final parts = name.trim().split(' ');
//     final initials = parts.length >= 2
//         ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
//         : parts[0][0].toUpperCase();
//     return Container(
//       width: 26,
//       height: 26,
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8F5E9),
//         borderRadius: BorderRadius.circular(13),
//       ),
//       child: Center(
//         child: Text(initials,
//             style: const TextStyle(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF2E7D32))),
//       ),
//     );
//   }
//
//   Widget _actionBtn({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Icon(icon, size: 15, color: color),
//       ),
//     );
//   }
//
//   Widget _pgBtn(String label, VoidCallback onTap, {bool active = false}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         width: 30,
//         height: 30,
//         margin: const EdgeInsets.only(left: 4),
//         decoration: BoxDecoration(
//           color: active ? _kPurple : Colors.white,
//           borderRadius: BorderRadius.circular(7),
//           border:
//           Border.all(color: active ? _kPurple : Colors.grey.shade200),
//         ),
//         child: Center(
//           child: Text(label,
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: active ? FontWeight.w700 : FontWeight.w400,
//                   color: active ? Colors.white : Colors.grey.shade600)),
//         ),
//       ),
//     );
//   }
//
//   // ── Delete guard ────────────────────────────────────────────────────────
//
//   void _confirmDelete(BuildContext context, SchoolClass cls) async {
//     if (cls.id == null) return;
//
//     final staffProvider = context.read<StaffProvider>();
//     final allStaff = [
//       ...staffProvider.teachers,
//       ...staffProvider.staffOnly,
//     ];
//     final assignedTo = allStaff
//         .where((s) => s.assignedClasses.contains(cls.id))
//         .map((s) => s.name)
//         .toList();
//
//     if (assignedTo.isNotEmpty) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16)),
//           title: Row(children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(Icons.warning_amber_rounded,
//                   color: Colors.orange.shade700, size: 20),
//             ),
//             const SizedBox(width: 10),
//             const Expanded(
//                 child: Text('Cannot delete',
//                     style: TextStyle(fontSize: 15))),
//           ]),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               RichText(
//                 text: TextSpan(
//                   style: const TextStyle(
//                       fontSize: 13,
//                       color: Color(0xFF333333),
//                       height: 1.5),
//                   children: [
//                     const TextSpan(text: '"'),
//                     TextSpan(
//                         text: cls.name,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold)),
//                     const TextSpan(
//                         text: '" is assigned to staff. Remove it first:'),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ...assignedTo.map((name) => Padding(
//                 padding: const EdgeInsets.only(left: 8, bottom: 4),
//                 child: Row(children: [
//                   const Icon(Icons.person_outline,
//                       size: 14, color: _kPurple),
//                   const SizedBox(width: 6),
//                   Text(name,
//                       style: const TextStyle(fontSize: 13)),
//                 ]),
//               )),
//             ],
//           ),
//           actions: [
//             FilledButton(
//               onPressed: () => Navigator.pop(context),
//               style:
//               FilledButton.styleFrom(backgroundColor: _kPurple),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//       return;
//     }
//
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete class'),
//         content:
//         Text('Are you sure you want to delete "${cls.name}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Delete',
//                 style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm == true && context.mounted) {
//       try {
//         await context
//             .read<ClassProvider>()
//             .deleteClass(cls.id!, cls.name);
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text('Delete failed: $e'),
//                 backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }
// }
//
// // ── Data model for table row ────────────────────────────────────────────────
// class _ClassRow {
//   final SchoolClass schoolClass;
//   final Section? section;
//   final String className;
//   final String sectionName;
//   final String? headTeacher;
//   final int subjectCount;
//   final double? monthlyFee;
//   final double? annualFee;
//
//   _ClassRow({
//     required this.schoolClass,
//     required this.section,
//     required this.className,
//     required this.sectionName,
//     this.headTeacher,
//     this.subjectCount = 0,
//     this.monthlyFee,
//     this.annualFee,
//   });
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/teacher_provider.dart';
import 'add_class.dart';

const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFEEEDFE);

class ClassesListScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showFAB;
  const ClassesListScreen({
    super.key,
    this.showAppBar = true,
    this.showFAB = true,
  });

  @override
  State<ClassesListScreen> createState() => _ClassesListScreenState();
}

class _ClassesListScreenState extends State<ClassesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  int _perPage = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ★ Row shown only when there's no AppBar (which would otherwise
  // supply its own back button). Kept minimal so it doesn't disturb
  // the rest of the layout below it.
  Widget _buildManualBackRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: widget.showAppBar
          ? AppBar(
        title: const Text('Classes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      )
          : null,
      // ★ SafeArea so content (and the manual back arrow below) never
      // sit under the notch, status bar, or home-indicator on mobile
      // when no AppBar is shown.
      body: SafeArea(
        child: Consumer<ClassProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.classes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => provider.clearError(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final rows = _buildRows(provider.classes);
            final filtered = rows
                .where((r) =>
            r.className
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
                r.sectionName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                (r.headTeacher ?? '')
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return Column(
                  children: [
                    if (!widget.showAppBar) _buildManualBackRow(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        child: isMobile
                            ? _buildMobileLayout(context, filtered, provider)
                            : _buildDesktopLayout(
                            context, filtered, provider, constraints),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ── Mobile card layout ──────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, List<_ClassRow> filtered,
      ClassProvider provider) {
    final totalPages = (filtered.length / _perPage).ceil().clamp(1, 999);
    if (_currentPage > totalPages) _currentPage = 1;

    final start = (_currentPage - 1) * _perPage;
    final pageRows = filtered.skip(start).take(_perPage).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context, filtered.length),
          _buildMobileSearchBar(),
          if (pageRows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(children: [
                  Icon(Icons.search_off, size: 36, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('No classes match your search',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade400)),
                ]),
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: pageRows.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, idx) => _buildMobileCard(
                  context,
                  pageRows[idx],
                  (_currentPage - 1) * _perPage + idx + 1,
                  provider),
            ),
          _buildFooter(filtered.length, start, pageRows.length, totalPages),
        ],
      ),
    );
  }

  Widget _buildMobileSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      color: const Color(0xFFFAFAFA),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() {
          _searchQuery = v;
          _currentPage = 1;
        }),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search class, section, teacher...',
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon:
          Icon(Icons.search, size: 17, color: Colors.grey.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kPurple, width: 1.5),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, _ClassRow row, int serial,
      ClassProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar / index
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kPurpleLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    row.className.trim().isEmpty
                        ? '?'
                        : row.className.trim()[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _kPurple),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '#$serial',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Class name + section badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.className,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kPurpleLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        row.sectionName,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kPurple),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Row 2: Teacher info
                if (row.headTeacher != null && row.headTeacher!.isNotEmpty) ...[
                  Row(
                    children: [
                      _miniAvatar(row.headTeacher!),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          row.headTeacher!,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF444444)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Text('No teacher assigned',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade400)),
                const SizedBox(height: 6),
                // Row 3: Fee + subjects row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${row.subjectCount} subj.',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE65100)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (row.monthlyFee != null) ...[
                      Text(
                        'Rs ${row.monthlyFee!.toStringAsFixed(0)}/mo',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32)),
                      ),
                    ] else
                      Text('No fee',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade300)),
                    const Spacer(),
                    // Edit button
                    _actionBtn(
                      icon: Icons.edit_outlined,
                      color: Colors.grey.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditClassScreen(existingClass: row.schoolClass),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Delete button
                    _actionBtn(
                      icon: Icons.delete_outline,
                      color: Colors.red.shade400,
                      onTap: () => _confirmDelete(context, row.schoolClass),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop layout ──────────────────────────────────────────────────────

  List<_ClassRow> _buildRows(List<SchoolClass> classes) {
    final rows = <_ClassRow>[];
    for (final cls in classes) {
      if (cls.sections != null && cls.sections!.isNotEmpty) {
        for (final sec in cls.sections!) {
          String secName = sec.sectionName;
          final prefix = '${cls.name} section ';
          if (secName.startsWith(prefix)) {
            secName = secName.substring(prefix.length);
          }
          rows.add(_ClassRow(
            schoolClass: cls,
            section: sec,
            className: cls.name,
            sectionName: secName,
            headTeacher: sec.headOfTeacher,
            subjectCount: sec.subjectMarks?.length ?? 0,
            monthlyFee: sec.monthlyFee,
            annualFee: sec.annualFee,
          ));
        }
      } else {
        rows.add(_ClassRow(
          schoolClass: cls,
          section: null,
          className: cls.name,
          sectionName: '—',
          headTeacher: cls.headOfClassTeacher,
          subjectCount: cls.subjects?.length ?? 0,
          monthlyFee: cls.monthlyFee,
          annualFee: cls.annualFee,
        ));
      }
    }
    return rows;
  }

  Widget _buildDesktopLayout(BuildContext context, List<_ClassRow> filtered,
      ClassProvider provider, BoxConstraints constraints) {
    final totalPages = (filtered.length / _perPage).ceil().clamp(1, 999);
    if (_currentPage > totalPages) _currentPage = 1;

    final start = (_currentPage - 1) * _perPage;
    final pageRows = filtered.skip(start).take(_perPage).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBar(context, filtered.length),
          _buildToolbar(),
          _buildResponsiveTable(context, pageRows, provider, constraints),
          _buildFooter(filtered.length, start, pageRows.length, totalPages),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Classes',
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(
                '$count ${count == 1 ? 'class' : 'entries'} found',
                style:
                TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEditClassScreen()),
            );
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add class'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            textStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: const Color(0xFFFAFAFA),
      child: Row(children: [
        Text('Show',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _perPage,
              isDense: true,
              style:
              const TextStyle(fontSize: 13, color: Colors.black87),
              items: [5, 10, 25, 50]
                  .map((v) =>
                  DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
              onChanged: (v) => setState(() {
                _perPage = v!;
                _currentPage = 1;
              }),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('entries',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const Spacer(),
        SizedBox(
          width: 220,
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() {
              _searchQuery = v;
              _currentPage = 1;
            }),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search class, section...',
              hintStyle:
              TextStyle(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search,
                  size: 17, color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPurple, width: 1.5),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Responsive table using IntrinsicColumnWidth + FlexColumnWidth ───────
  Widget _buildResponsiveTable(BuildContext context, List<_ClassRow> rows,
      ClassProvider provider, BoxConstraints constraints) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(children: [
            Icon(Icons.search_off, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('No classes match your search',
                style:
                TextStyle(fontSize: 13, color: Colors.grey.shade400)),
          ]),
        ),
      );
    }

    // Use a custom list-based layout so it always fits the available width
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row
        Container(
          color: const Color(0xFFF8F8FF),
          child: _buildHeaderRow(),
        ),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final idx = entry.key;
          final row = entry.value;
          return Container(
            decoration: BoxDecoration(
              color: idx.isEven ? Colors.white : const Color(0xFFFCFCFF),
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: _buildDataRow(
                context,
                row,
                (_currentPage - 1) * _perPage + idx + 1,
                provider),
          );
        }),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0),
      child: Row(
        children: [
          _headerCell('#', flex: 1, center: false),
          _headerCell('CLASS', flex: 4, center: false),
          _headerCell('SECTION', flex: 2, center: false),
          _headerCell('HEAD TEACHER', flex: 4, center: false),
          _headerCell('SUBJECTS', flex: 2, center: true),
          _headerCell('FEE', flex: 3, center: false),
          _headerCell('ACTION', flex: 2, center: true),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {required int flex, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: center ? Alignment.center : Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _kPurple,
                letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, _ClassRow row, int serial,
      ClassProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // # serial
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '$serial',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ),
          ),

          // Class name with avatar
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _kPurpleLight,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        row.className.trim().isEmpty
                            ? '?'
                            : row.className.trim()[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _kPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      row.className,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section badge
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kPurpleLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    row.sectionName,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kPurple),
                  ),
                ),
              ),
            ),
          ),

          // Head Teacher
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: row.headTeacher != null && row.headTeacher!.isNotEmpty
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _miniAvatar(row.headTeacher!),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      row.headTeacher!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF444444)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
                  : Text('—',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade300)),
            ),
          ),

          // Subjects badge
          Expanded(
            flex: 2,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${row.subjectCount} subj.',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE65100)),
                  ),
                ),
              ),
            ),
          ),

          // Fee
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: row.monthlyFee != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rs ${row.monthlyFee!.toStringAsFixed(0)}/mo',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32)),
                  ),
                  if (row.annualFee != null)
                    Text(
                      'Annual: Rs ${row.annualFee!.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400),
                    ),
                ],
              )
                  : Text('—',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade300)),
            ),
          ),

          // Actions — always visible, centered
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _actionBtn(
                  icon: Icons.edit_outlined,
                  color: Colors.grey.shade600,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditClassScreen(
                          existingClass: row.schoolClass),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _actionBtn(
                  icon: Icons.delete_outline,
                  color: Colors.red.shade400,
                  onTap: () => _confirmDelete(context, row.schoolClass),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(int total, int start, int pageCount, int totalPages) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        borderRadius:
        const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(children: [
        Flexible(
          child: Text(
            total == 0
                ? 'No entries'
                : 'Showing ${start + 1}–${start + pageCount} of $total entries',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
        const SizedBox(width: 8),
        Row(children: [
          if (_currentPage > 1)
            _pgBtn('‹', () => setState(() => _currentPage--)),
          ...List.generate(totalPages, (i) {
            final p = i + 1;
            return _pgBtn(
              '$p',
                  () => setState(() => _currentPage = p),
              active: p == _currentPage,
            );
          }),
          if (_currentPage < totalPages)
            _pgBtn('›', () => setState(() => _currentPage++)),
        ]),
      ]),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────────────

  Widget _miniAvatar(String name) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32))),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  Widget _pgBtn(String label, VoidCallback onTap, {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: active ? _kPurple : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border:
          Border.all(color: active ? _kPurple : Colors.grey.shade200),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? Colors.white : Colors.grey.shade600)),
        ),
      ),
    );
  }

  // ── Delete guard ────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, SchoolClass cls) async {
    if (cls.id == null) return;

    final staffProvider = context.read<StaffProvider>();
    final allStaff = [
      ...staffProvider.teachers,
      ...staffProvider.staffOnly,
    ];
    final assignedTo = allStaff
        .where((s) => s.assignedClasses.contains(cls.id))
        .map((s) => s.name)
        .toList();

    if (assignedTo.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
                child: Text('Cannot delete',
                    style: TextStyle(fontSize: 15))),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF333333),
                      height: 1.5),
                  children: [
                    const TextSpan(text: '"'),
                    TextSpan(
                        text: cls.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    const TextSpan(
                        text: '" is assigned to staff. Remove it first:'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...assignedTo.map((name) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: _kPurple),
                  const SizedBox(width: 6),
                  Text(name,
                      style: const TextStyle(fontSize: 13)),
                ]),
              )),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style:
              FilledButton.styleFrom(backgroundColor: _kPurple),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete class'),
        content:
        Text('Are you sure you want to delete "${cls.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await context
            .read<ClassProvider>()
            .deleteClass(cls.id!, cls.name);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Delete failed: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

// ── Data model for table row ────────────────────────────────────────────────
class _ClassRow {
  final SchoolClass schoolClass;
  final Section? section;
  final String className;
  final String sectionName;
  final String? headTeacher;
  final int subjectCount;
  final double? monthlyFee;
  final double? annualFee;

  _ClassRow({
    required this.schoolClass,
    required this.section,
    required this.className,
    required this.sectionName,
    this.headTeacher,
    this.subjectCount = 0,
    this.monthlyFee,
    this.annualFee,
  });
}