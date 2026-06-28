//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/teacher.dart';
// import '../../providers/teacher_provider.dart';
// import '../../providers/class_provider.dart';
// import 'Staff Profile.dart';
// import 'add_teacher.dart';
//
// const _kPurple = Color(0xFF534AB7);
// const _kPurpleLight = Color(0xFFF0EFFE);
// const _kGreen = Color(0xFF15803D);
// const _kGreenBg = Color(0xFFDCFCE7);
//
// class TeacherListScreen extends StatefulWidget {
//   // ── Optional callback for opening profile in a side panel ──
//   final void Function(StaffMember staff,
//       {Map<String, String> classIdToName})? onItemTap;
//
//   const TeacherListScreen({
//     super.key,
//     this.onItemTap,
//   });
//
//   @override
//   State<TeacherListScreen> createState() => _TeacherListScreenState();
// }
//
// class _TeacherListScreenState extends State<TeacherListScreen> {
//   final _searchCtrl = TextEditingController();
//   String _searchQuery = '';
//   int _currentPage = 0;
//   int _pageSize = 10;
//   final _pageSizeOptions = [10, 25, 50];
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => context.read<StaffProvider>().fetchTeachers());
//     _searchCtrl.addListener(() {
//       setState(() {
//         _searchQuery = _searchCtrl.text.toLowerCase();
//         _currentPage = 0;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   List _filtered(List all) {
//     if (_searchQuery.isEmpty) return all;
//     return all.where((t) =>
//     t.name.toLowerCase().contains(_searchQuery) ||
//         t.phone.toLowerCase().contains(_searchQuery) ||
//         (t.designation ?? '').toLowerCase().contains(_searchQuery) ||
//         t.employmentType.toLowerCase().contains(_searchQuery)).toList();
//   }
//
//   Future<void> _openProfile(BuildContext context, dynamic t) async {
//     final classProvider = context.read<ClassProvider>();
//     final classIdToName = {
//       for (final c in classProvider.classes)
//         if (c.id != null) c.id!: c.name
//     };
//
//     // If a callback exists, use it instead of pushing a full‑screen page.
//     if (widget.onItemTap != null) {
//       widget.onItemTap!(t, classIdToName: classIdToName);
//       return;
//     }
//
//     // Fallback: full‑screen navigation (standalone usage)
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (_) =>
//               StaffProfileScreen(staff: t, classIdToName: classIdToName)),
//     );
//     if (result == 'edit' && context.mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => AddEditStaffScreen(existingStaff: t)),
//       );
//     }
//   }
//
//   Future<void> _openEdit(BuildContext context, dynamic t) async {
//     final result = await Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => AddEditStaffScreen(existingStaff: t)));
//     if (result == true && context.mounted) {
//       context.read<StaffProvider>().fetchTeachers();
//     }
//   }
//
//   void _confirmDelete(BuildContext context, String id) {
//     showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14)),
//           title: const Text('Delete Teacher?',
//               style: TextStyle(fontWeight: FontWeight.w600)),
//           content: const Text('This action cannot be undone.'),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text('Cancel')),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade600,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8))),
//               onPressed: () {
//                 context.read<StaffProvider>().deleteStaff(id);
//                 Navigator.pop(ctx);
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= 720;
//     return isDesktop ? _buildDesktop() : _buildMobile();
//   }
//
//   // ── DESKTOP (with flexible columns) ─────────────────────────────────────
//   Widget _buildDesktop() {
//     final provider = context.watch<StaffProvider>();
//     final filtered = _filtered(provider.teachers);
//     final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 9999);
//     final pageItems =
//     filtered.skip(_currentPage * _pageSize).take(_pageSize).toList();
//     final start = filtered.isEmpty ? 0 : _currentPage * _pageSize + 1;
//     final end = _currentPage * _pageSize + pageItems.length;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F2F8),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           // Header
//           Row(children: [
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text('Teachers (${provider.teachers.length})',
//                   style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1A1A2E))),
//               const SizedBox(height: 2),
//               Text('Manage all teachers',
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
//             ]),
//             const Spacer(),
//             SizedBox(
//                 width: 240,
//                 height: 40,
//                 child: TextField(
//                   controller: _searchCtrl,
//                   decoration: InputDecoration(
//                       hintText: 'Search…',
//                       hintStyle: TextStyle(
//                           fontSize: 13, color: Colors.grey.shade400),
//                       prefixIcon: const Icon(Icons.search,
//                           size: 18, color: Colors.grey),
//                       contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide:
//                           BorderSide(color: Colors.grey.shade300)),
//                       enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide:
//                           BorderSide(color: Colors.grey.shade300)),
//                       focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: const BorderSide(color: _kPurple)),
//                       filled: true,
//                       fillColor: Colors.white),
//                   style: const TextStyle(fontSize: 13),
//                 )),
//             const SizedBox(width: 12),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 final result = await Navigator.push(context,
//                     MaterialPageRoute(
//                         builder: (_) => const AddEditStaffScreen()));
//                 if (result == true && mounted) provider.fetchTeachers();
//               },
//               icon: const Icon(Icons.add, size: 18),
//               label: const Text('Add Teacher'),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: _kPurple,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 20, vertical: 10),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   textStyle: const TextStyle(
//                       fontSize: 13, fontWeight: FontWeight.w600)),
//             ),
//           ]),
//           const SizedBox(height: 20),
//
//           // Table card
//           Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black.withOpacity(0.04),
//                           blurRadius: 10,
//                           offset: const Offset(0, 2))
//                     ]),
//                 child: Column(children: [
//                   Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 14),
//                       child: Row(children: [
//                         const Text('Show',
//                             style: TextStyle(fontSize: 13, color: Colors.grey)),
//                         const SizedBox(width: 8),
//                         Container(
//                             height: 32,
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey.shade300),
//                                 borderRadius: BorderRadius.circular(6)),
//                             child: DropdownButtonHideUnderline(
//                                 child: DropdownButton<int>(
//                                     value: _pageSize,
//                                     items: _pageSizeOptions
//                                         .map((n) => DropdownMenuItem(
//                                         value: n,
//                                         child: Text('$n',
//                                             style: const TextStyle(
//                                                 fontSize: 13))))
//                                         .toList(),
//                                     onChanged: (v) => setState(() {
//                                       _pageSize = v!;
//                                       _currentPage = 0;
//                                     }),
//                                     style: const TextStyle(
//                                         fontSize: 13, color: Colors.black87),
//                                     iconSize: 16))),
//                         const SizedBox(width: 8),
//                         const Text('entries',
//                             style: TextStyle(fontSize: 13, color: Colors.grey)),
//                         const Spacer(),
//                         if (provider.loading)
//                           const SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(
//                                   strokeWidth: 2, color: _kPurple)),
//                       ])),
//                   // Table header – flex‑based columns
//                   Container(
//                       color: const Color(0xFFF8F9FC),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                       child: Row(children: [
//                         _th('PHOTO', flex: 6),
//                         _th('NAME', flex: 19),
//                         _th('DESIGNATION', flex: 15),
//                         _th('SUBJECTS', flex: 15),
//                         _th('PHONE', flex: 13),
//                         _th('EMPLOYMENT', flex: 11),
//                         _th('STATUS', flex: 9),
//                         _th('ACTION', flex: 10, align: TextAlign.center),
//                       ])),
//                   const Divider(height: 1, color: Color(0xFFEEEFF3)),
//                   Expanded(
//                       child: provider.loading
//                           ? const Center(
//                           child:
//                           CircularProgressIndicator(color: _kPurple))
//                           : filtered.isEmpty
//                           ? _desktopEmpty()
//                           : ListView.separated(
//                           itemCount: pageItems.length,
//                           separatorBuilder: (_, __) => const Divider(
//                               height: 1, color: Color(0xFFEEEFF3)),
//                           itemBuilder: (ctx, i) =>
//                               _desktopRow(ctx, pageItems[i]))),
//                   // Pagination footer
//                   Container(
//                     decoration: const BoxDecoration(
//                         border: Border(
//                             top: BorderSide(color: Color(0xFFEEEFF3)))),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12),
//                     child: Row(children: [
//                       Text(
//                           filtered.isEmpty
//                               ? 'No entries'
//                               : 'Showing $start–$end of ${filtered.length} entries',
//                           style: const TextStyle(
//                               fontSize: 12, color: Colors.grey)),
//                       const Spacer(),
//                       _pageBtn(Icons.chevron_left,
//                           _currentPage > 0
//                               ? () => setState(() => _currentPage--)
//                               : null),
//                       ...List.generate(
//                           totalPages.clamp(0, 5),
//                               (idx) => _pageNumber(idx,
//                                   () => setState(() => _currentPage = idx))),
//                       _pageBtn(Icons.chevron_right,
//                           _currentPage < totalPages - 1
//                               ? () => setState(() => _currentPage++)
//                               : null),
//                     ]),
//                   ),
//                 ]),
//               )),
//         ]),
//       ),
//     );
//   }
//
//   Widget _th(String label, {int flex = 1, TextAlign align = TextAlign.left}) =>
//       Expanded(
//         flex: flex,
//         child: Text(label,
//             textAlign: align,
//             style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF8B8FA8),
//                 letterSpacing: 0.5)),
//       );
//
//   Widget _desktopRow(BuildContext context, dynamic t) {
//     final subjects = (t.subjects as List?)?.cast<String>() ?? [];
//     return InkWell(
//       onTap: () => _openProfile(context, t),
//       hoverColor: const Color(0xFFF8F8FF),
//       child: Padding(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           child: Row(children: [
//             // PHOTO
//             Expanded(
//               flex: 6,
//               child: CircleAvatar(
//                   radius: 18,
//                   backgroundColor: _kPurpleLight,
//                   backgroundImage: t.imageBase64 != null
//                       ? MemoryImage(base64Decode(t.imageBase64!))
//                       : null,
//                   child: t.imageBase64 == null
//                       ? Text(
//                       t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
//                       style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: _kPurple))
//                       : null),
//             ),
//             // NAME
//             Expanded(
//               flex: 19,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(t.name,
//                         style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF1A1A2E)),
//                         overflow: TextOverflow.ellipsis),
//                     Text(t.gender,
//                         style: const TextStyle(
//                             fontSize: 11, color: Colors.grey)),
//                   ]),
//             ),
//             // DESIGNATION
//             Expanded(
//               flex: 15,
//               child: Text(
//                   t.designation?.isNotEmpty == true ? t.designation! : '—',
//                   style: TextStyle(
//                       fontSize: 13, color: Colors.grey.shade700),
//                   overflow: TextOverflow.ellipsis),
//             ),
//             // SUBJECTS
//             Expanded(
//               flex: 15,
//               child: subjects.isEmpty
//                   ? Text('—',
//                   style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade400))
//                   : Wrap(
//                   spacing: 4,
//                   runSpacing: 4,
//                   children: subjects
//                       .take(2)
//                       .map((sub) => Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 7, vertical: 2),
//                     decoration: BoxDecoration(
//                         color: const Color(0xFFF0EFFE),
//                         borderRadius:
//                         BorderRadius.circular(10)),
//                     child: Text(sub,
//                         style: const TextStyle(
//                             fontSize: 10,
//                             color: _kPurple,
//                             fontWeight: FontWeight.w500)),
//                   ))
//                       .toList()
//                     ..addAll(subjects.length > 2
//                         ? [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 7, vertical: 2),
//                         decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius:
//                             BorderRadius.circular(10)),
//                         child: Text(
//                             '+${subjects.length - 2}',
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.grey.shade600)),
//                       )
//                     ]
//                         : [])),
//             ),
//             // PHONE
//             Expanded(
//               flex: 13,
//               child: Text(t.phone,
//                   style: const TextStyle(fontSize: 13),
//                   overflow: TextOverflow.ellipsis),
//             ),
//             // EMPLOYMENT
//             Expanded(
//               flex: 11,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: const Color(0xFFF0F2F8),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Text(t.employmentType,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w500,
//                           color: _kPurple)),
//                 ),
//               ),
//             ),
//             // STATUS
//             Expanded(
//               flex: 9,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: _kGreenBg,
//                       borderRadius: BorderRadius.circular(20)),
//                   child: const Text('Active',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           color: _kGreen)),
//                 ),
//               ),
//             ),
//             // ACTION
//             Expanded(
//               flex: 10,
//               child: Center(
//                 child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _actionBtn(Icons.visibility_outlined,
//                           Colors.blue.shade600,
//                               () => _openProfile(context, t),
//                           tooltip: 'View'),
//                       const SizedBox(width: 4),
//                       _actionBtn(Icons.edit_outlined, _kPurple,
//                               () => _openEdit(context, t),
//                           tooltip: 'Edit'),
//                       const SizedBox(width: 4),
//                       _actionBtn(Icons.delete_outline, Colors.red.shade600,
//                               () => _confirmDelete(context, t.id!),
//                           tooltip: 'Delete'),
//                     ]),
//               ),
//             ),
//           ])),
//     );
//   }
//
//   Widget _actionBtn(IconData icon, Color color, VoidCallback onTap,
//       {String? tooltip}) =>
//       Tooltip(
//           message: tooltip ?? '',
//           child: InkWell(
//               onTap: onTap,
//               borderRadius: BorderRadius.circular(6),
//               child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                       color: color.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(6)),
//                   child: Icon(icon, size: 15, color: color))));
//
//   Widget _desktopEmpty() => Center(
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade300),
//         const SizedBox(height: 12),
//         Text(
//             _searchQuery.isEmpty
//                 ? 'No teachers found.'
//                 : 'No results for "$_searchQuery"',
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade500))
//       ]));
//
//   Widget _pageBtn(IconData icon, VoidCallback? onTap) => InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(6),
//       child: Container(
//           width: 30,
//           height: 30,
//           margin: const EdgeInsets.symmetric(horizontal: 2),
//           decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(6),
//               color: onTap == null ? Colors.grey.shade50 : Colors.white),
//           child: Icon(icon,
//               size: 16,
//               color: onTap == null
//                   ? Colors.grey.shade400
//                   : Colors.grey.shade700)));
//
//   Widget _pageNumber(int idx, VoidCallback onTap) {
//     final isActive = idx == _currentPage;
//     return InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(6),
//         child: Container(
//             width: 30,
//             height: 30,
//             margin: const EdgeInsets.symmetric(horizontal: 2),
//             decoration: BoxDecoration(
//                 color: isActive ? _kPurple : Colors.white,
//                 border: Border.all(
//                     color: isActive ? _kPurple : Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(6)),
//             child: Center(
//                 child: Text('${idx + 1}',
//                     style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color:
//                         isActive ? Colors.white : Colors.grey.shade700)))));
//   }
//
//   // ── MOBILE (unchanged) ──────────────────────────────────────────────────
//   Widget _buildMobile() {
//     final provider = context.watch<StaffProvider>();
//     final filtered = _filtered(provider.teachers);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: _kPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text('Teachers',
//               style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
//           Text('${provider.teachers.length} teachers',
//               style: const TextStyle(fontSize: 11, color: Colors.white70)),
//         ]),
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.add),
//               tooltip: 'Add Teacher',
//               onPressed: () async {
//                 final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const AddEditStaffScreen()));
//                 if (result == true && mounted) provider.fetchTeachers();
//               })
//         ],
//       ),
//       body: Column(children: [
//         Container(
//             color: _kPurple,
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: TextField(
//                 controller: _searchCtrl,
//                 style: const TextStyle(fontSize: 14),
//                 decoration: InputDecoration(
//                     hintText: 'Search teachers…',
//                     hintStyle:
//                     const TextStyle(fontSize: 13, color: Colors.grey),
//                     prefixIcon: const Icon(Icons.search,
//                         size: 18, color: Colors.grey),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 0),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide.none)))),
//         Expanded(
//             child: provider.loading
//                 ? const Center(
//                 child: CircularProgressIndicator(color: _kPurple))
//                 : filtered.isEmpty
//                 ? Center(
//                 child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.school_outlined,
//                           size: 48, color: Colors.grey.shade300),
//                       const SizedBox(height: 12),
//                       Text(
//                           _searchQuery.isEmpty
//                               ? 'No teachers found.'
//                               : 'No results for "$_searchQuery"',
//                           style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade500))
//                     ]))
//                 : ListView.builder(
//                 padding:
//                 const EdgeInsets.fromLTRB(16, 16, 16, 80),
//                 itemCount: filtered.length,
//                 itemBuilder: (ctx, i) =>
//                     _mobileCard(ctx, filtered[i]))),
//       ]),
//       floatingActionButton: FloatingActionButton(
//           backgroundColor: _kPurple,
//           foregroundColor: Colors.white,
//           onPressed: () async {
//             final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) => const AddEditStaffScreen()));
//             if (result == true && mounted) provider.fetchTeachers();
//           },
//           child: const Icon(Icons.add)),
//     );
//   }
//
//   Widget _mobileCard(BuildContext context, dynamic t) {
//     final subjects = (t.subjects as List?)?.cast<String>() ?? [];
//     return Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.04),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2))
//             ]),
//         child: InkWell(
//             onTap: () => _openProfile(context, t),
//             borderRadius: BorderRadius.circular(14),
//             child: Padding(
//                 padding: const EdgeInsets.all(14),
//                 child: Row(children: [
//                   CircleAvatar(
//                       radius: 26,
//                       backgroundColor: _kPurpleLight,
//                       backgroundImage: t.imageBase64 != null
//                           ? MemoryImage(base64Decode(t.imageBase64!))
//                           : null,
//                       child: t.imageBase64 == null
//                           ? Text(
//                           t.name.isNotEmpty
//                               ? t.name[0].toUpperCase()
//                               : '?',
//                           style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: _kPurple))
//                           : null),
//                   const SizedBox(width: 12),
//                   Expanded(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(t.name,
//                                 style: const TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF1A1A2E))),
//                             if (t.designation?.isNotEmpty == true) ...[
//                               const SizedBox(height: 2),
//                               Text(t.designation!,
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey.shade600)),
//                             ],
//                             const SizedBox(height: 6),
//                             Wrap(spacing: 6, runSpacing: 4, children: [
//                               _mobilePill(t.employmentType, _kPurple,
//                                   const Color(0xFFF0EFFE)),
//                               if (subjects.isNotEmpty)
//                                 _mobilePill(
//                                     subjects.first,
//                                     Colors.teal.shade700,
//                                     Colors.teal.shade50,
//                                     icon: Icons.menu_book_outlined),
//                               if (subjects.length > 1)
//                                 _mobilePill(
//                                     '+${subjects.length - 1}',
//                                     Colors.grey.shade600,
//                                     Colors.grey.shade100),
//                             ]),
//                           ])),
//                   Column(mainAxisSize: MainAxisSize.min, children: [
//                     _mobileIconBtn(Icons.edit_outlined, _kPurple,
//                             () => _openEdit(context, t)),
//                     const SizedBox(height: 4),
//                     _mobileIconBtn(Icons.delete_outline, Colors.red.shade600,
//                             () => _confirmDelete(context, t.id!)),
//                   ]),
//                 ]))));
//   }
//
//   Widget _mobilePill(String label, Color textColor, Color bgColor,
//       {IconData? icon}) =>
//       Container(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//           decoration: BoxDecoration(
//               color: bgColor, borderRadius: BorderRadius.circular(20)),
//           child: Row(mainAxisSize: MainAxisSize.min, children: [
//             if (icon != null) ...[
//               Icon(icon, size: 11, color: textColor),
//               const SizedBox(width: 3)
//             ],
//             Text(label,
//                 style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                     color: textColor)),
//           ]));
//
//   Widget _mobileIconBtn(IconData icon, Color color, VoidCallback onTap) =>
//       InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(8),
//           child: Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                   color: color.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(8)),
//               child: Icon(icon, size: 16, color: color)));
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/teacher.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/class_provider.dart';
import 'Staff Profile.dart';
import 'add_teacher.dart';

const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kGreen = Color(0xFF15803D);
const _kGreenBg = Color(0xFFDCFCE7);

class TeacherListScreen extends StatefulWidget {
  final void Function(StaffMember staff,
      {Map<String, String> classIdToName})? onItemTap;

  const TeacherListScreen({
    super.key,
    this.onItemTap,
  });

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  int _pageSize = 10;
  final _pageSizeOptions = [10, 25, 50];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StaffProvider>().fetchTeachers());
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase();
        _currentPage = 0;
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List _filtered(List all) {
    if (_searchQuery.isEmpty) return all;
    return all.where((t) =>
    t.name.toLowerCase().contains(_searchQuery) ||
        t.phone.toLowerCase().contains(_searchQuery) ||
        (t.designation ?? '').toLowerCase().contains(_searchQuery) ||
        t.employmentType.toLowerCase().contains(_searchQuery)).toList();
  }

  Future<void> _openProfile(BuildContext context, dynamic t) async {
    final classProvider = context.read<ClassProvider>();
    final classIdToName = {
      for (final c in classProvider.classes)
        if (c.id != null) c.id!: c.name
    };

    if (widget.onItemTap != null) {
      widget.onItemTap!(t, classIdToName: classIdToName);
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              StaffProfileScreen(staff: t, classIdToName: classIdToName)),
    );
    if (result == 'edit' && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddEditStaffScreen(existingStaff: t)),
      );
    }
  }

  Future<void> _openEdit(BuildContext context, dynamic t) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddEditStaffScreen(existingStaff: t)));
    if (result == true && context.mounted) {
      context.read<StaffProvider>().fetchTeachers();
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          title: const Text('Delete Teacher?',
              style: TextStyle(fontWeight: FontWeight.w600)),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                context.read<StaffProvider>().deleteStaff(id);
                Navigator.pop(ctx);
              },
              child: const Text('Delete'),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;
    return isDesktop ? _buildDesktop() : _buildMobile();
  }

  // ── DESKTOP (with flexible columns) ─────────────────────────────────────
  Widget _buildDesktop() {
    final provider = context.watch<StaffProvider>();
    final filtered = _filtered(provider.teachers);
    final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 9999);
    final pageItems =
    filtered.skip(_currentPage * _pageSize).take(_pageSize).toList();
    final start = filtered.isEmpty ? 0 : _currentPage * _pageSize + 1;
    final end = _currentPage * _pageSize + pageItems.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Teachers (${provider.teachers.length})',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 2),
              Text('Manage all teachers',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ]),
            const Spacer(),
            SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                      hintText: 'Search…',
                      hintStyle: TextStyle(
                          fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: Colors.grey),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                          BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                          BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _kPurple)),
                      filled: true,
                      fillColor: Colors.white),
                  style: const TextStyle(fontSize: 13),
                )),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddEditStaffScreen(initialType: 'teacher')));
                if (result == true && mounted) provider.fetchTeachers();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Teacher'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 20),

          // Table card
          Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2))
                    ]),
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(children: [
                        const Text('Show',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(width: 8),
                        Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(6)),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                    value: _pageSize,
                                    items: _pageSizeOptions
                                        .map((n) => DropdownMenuItem(
                                        value: n,
                                        child: Text('$n',
                                            style: const TextStyle(
                                                fontSize: 13))))
                                        .toList(),
                                    onChanged: (v) => setState(() {
                                      _pageSize = v!;
                                      _currentPage = 0;
                                    }),
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.black87),
                                    iconSize: 16))),
                        const SizedBox(width: 8),
                        const Text('entries',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const Spacer(),
                        if (provider.loading)
                          const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _kPurple)),
                      ])),
                  // Table header – flex‑based columns
                  Container(
                      color: const Color(0xFFF8F9FC),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(children: [
                        _th('PHOTO', flex: 6),
                        _th('NAME', flex: 19),
                        _th('DESIGNATION', flex: 13),
                        _th('SUBJECTS', flex: 12),
                        _th('SECTIONS', flex: 12),     // NEW
                        _th('PHONE', flex: 11),
                        _th('EMPLOYMENT', flex: 10),
                        _th('STATUS', flex: 8),
                        _th('ACTION', flex: 9, align: TextAlign.center),
                      ])),
                  const Divider(height: 1, color: Color(0xFFEEEFF3)),
                  Expanded(
                      child: provider.loading
                          ? const Center(
                          child:
                          CircularProgressIndicator(color: _kPurple))
                          : filtered.isEmpty
                          ? _desktopEmpty()
                          : ListView.separated(
                          itemCount: pageItems.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: Color(0xFFEEEFF3)),
                          itemBuilder: (ctx, i) =>
                              _desktopRow(ctx, pageItems[i]))),
                  // Pagination footer
                  Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Color(0xFFEEEFF3)))),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(children: [
                      Text(
                          filtered.isEmpty
                              ? 'No entries'
                              : 'Showing $start–$end of ${filtered.length} entries',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      _pageBtn(Icons.chevron_left,
                          _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null),
                      ...List.generate(
                          totalPages.clamp(0, 5),
                              (idx) => _pageNumber(idx,
                                  () => setState(() => _currentPage = idx))),
                      _pageBtn(Icons.chevron_right,
                          _currentPage < totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null),
                    ]),
                  ),
                ]),
              )),
        ]),
      ),
    );
  }

  Widget _th(String label, {int flex = 1, TextAlign align = TextAlign.left}) =>
      Expanded(
        flex: flex,
        child: Text(label,
            textAlign: align,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B8FA8),
                letterSpacing: 0.5)),
      );

  Widget _desktopRow(BuildContext context, dynamic t) {
    final subjects = (t.subjects as List?)?.cast<String>() ?? [];
    final sections = (t.assignedSections as List?)?.cast<String>() ?? [];

    return InkWell(
      onTap: () => _openProfile(context, t),
      hoverColor: const Color(0xFFF8F8FF),
      child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            // PHOTO
            Expanded(
              flex: 6,
              child: CircleAvatar(
                  radius: 18,
                  backgroundColor: _kPurpleLight,
                  backgroundImage: t.imageBase64 != null
                      ? MemoryImage(base64Decode(t.imageBase64!))
                      : null,
                  child: t.imageBase64 == null
                      ? Text(
                      t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _kPurple))
                      : null),
            ),
            // NAME
            Expanded(
              flex: 19,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E)),
                        overflow: TextOverflow.ellipsis),
                    Text(t.gender,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ]),
            ),
            // DESIGNATION
            Expanded(
              flex: 13,
              child: Text(
                  t.designation?.isNotEmpty == true ? t.designation! : '—',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis),
            ),
            // SUBJECTS
            Expanded(
              flex: 12,
              child: subjects.isEmpty
                  ? Text('—', style: TextStyle(fontSize: 13, color: Colors.grey.shade400))
                  : _buildChipRow(subjects, const Color(0xFFF0EFFE), _kPurple),
            ),
            // SECTIONS
            Expanded(
              flex: 12,
              child: sections.isEmpty
                  ? Text('—', style: TextStyle(fontSize: 13, color: Colors.grey.shade400))
                  : _buildChipRow(sections, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
            ),
            // PHONE
            Expanded(
              flex: 11,
              child: Text(t.phone,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
            // EMPLOYMENT
            Expanded(
              flex: 10,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F8),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(t.employmentType,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _kPurple)),
                ),
              ),
            ),
            // STATUS
            Expanded(
              flex: 8,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _kGreenBg,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Active',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _kGreen)),
                ),
              ),
            ),
            // ACTION
            Expanded(
              flex: 9,
              child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionBtn(Icons.visibility_outlined,
                          Colors.blue.shade600,
                              () => _openProfile(context, t),
                          tooltip: 'View'),
                      const SizedBox(width: 4),
                      _actionBtn(Icons.edit_outlined, _kPurple,
                              () => _openEdit(context, t),
                          tooltip: 'Edit'),
                      const SizedBox(width: 4),
                      _actionBtn(Icons.delete_outline, Colors.red.shade600,
                              () => _confirmDelete(context, t.id!),
                          tooltip: 'Delete'),
                    ]),
              ),
            ),
          ])),
    );
  }

  // Helper to build chip list with +N overflow
  Widget _buildChipRow(List<String> items, Color bgColor, Color textColor) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: items
          .take(2)
          .map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10)),
        child: Text(item,
            style: TextStyle(
                fontSize: 10,
                color: textColor,
                fontWeight: FontWeight.w500)),
      ))
          .toList()
        ..addAll(items.length > 2
            ? [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10)),
            child: Text('+${items.length - 2}',
                style: TextStyle(
                    fontSize: 10, color: Colors.grey.shade600)),
          )
        ]
            : []),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap,
      {String? tooltip}) =>
      Tooltip(
          message: tooltip ?? '',
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, size: 15, color: color))));

  Widget _desktopEmpty() => Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
            _searchQuery.isEmpty
                ? 'No teachers found.'
                : 'No results for "$_searchQuery"',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500))
      ]));

  Widget _pageBtn(IconData icon, VoidCallback? onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
              color: onTap == null ? Colors.grey.shade50 : Colors.white),
          child: Icon(icon,
              size: 16,
              color: onTap == null
                  ? Colors.grey.shade400
                  : Colors.grey.shade700)));

  Widget _pageNumber(int idx, VoidCallback onTap) {
    final isActive = idx == _currentPage;
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
                color: isActive ? _kPurple : Colors.white,
                border: Border.all(
                    color: isActive ? _kPurple : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6)),
            child: Center(
                child: Text('${idx + 1}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                        isActive ? Colors.white : Colors.grey.shade700)))));
  }

  // ── MOBILE (unchanged layout, added sections) ───────────────────────────
  Widget _buildMobile() {
    final provider = context.watch<StaffProvider>();
    final filtered = _filtered(provider.teachers);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Teachers',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          Text('${provider.teachers.length} teachers',
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Teacher',
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddEditStaffScreen()));
                if (result == true && mounted) provider.fetchTeachers();
              })
        ],
      ),
      body: Column(children: [
        Container(
            color: _kPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                    hintText: 'Search teachers…',
                    hintStyle:
                    const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)))),
        Expanded(
            child: provider.loading
                ? const Center(
                child: CircularProgressIndicator(color: _kPurple))
                : filtered.isEmpty
                ? Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_outlined,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                          _searchQuery.isEmpty
                              ? 'No teachers found.'
                              : 'No results for "$_searchQuery"',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500))
                    ]))
                : ListView.builder(
                padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) =>
                    _mobileCard(ctx, filtered[i]))),
      ]),
      floatingActionButton: FloatingActionButton(
          backgroundColor: _kPurple,
          foregroundColor: Colors.white,
          onPressed: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditStaffScreen()));
            if (result == true && mounted) provider.fetchTeachers();
          },
          child: const Icon(Icons.add)),
    );
  }

  Widget _mobileCard(BuildContext context, dynamic t) {
    final subjects = (t.subjects as List?)?.cast<String>() ?? [];
    final sections = (t.assignedSections as List?)?.cast<String>() ?? [];

    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: InkWell(
            onTap: () => _openProfile(context, t),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  CircleAvatar(
                      radius: 26,
                      backgroundColor: _kPurpleLight,
                      backgroundImage: t.imageBase64 != null
                          ? MemoryImage(base64Decode(t.imageBase64!))
                          : null,
                      child: t.imageBase64 == null
                          ? Text(
                          t.name.isNotEmpty
                              ? t.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _kPurple))
                          : null),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E))),
                            if (t.designation?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Text(t.designation!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600)),
                            ],
                            const SizedBox(height: 6),
                            Wrap(spacing: 6, runSpacing: 4, children: [
                              _mobilePill(t.employmentType, _kPurple,
                                  const Color(0xFFF0EFFE)),
                              if (subjects.isNotEmpty)
                                _mobilePill(
                                    subjects.first,
                                    Colors.teal.shade700,
                                    Colors.teal.shade50,
                                    icon: Icons.menu_book_outlined),
                              if (subjects.length > 1)
                                _mobilePill(
                                    '+${subjects.length - 1}',
                                    Colors.grey.shade600,
                                    Colors.grey.shade100),
                              if (sections.isNotEmpty)
                                _mobilePill(
                                    sections.first,
                                    const Color(0xFF2E7D32),
                                    const Color(0xFFE8F5E9),
                                    icon: Icons.class_outlined),
                              if (sections.length > 1)
                                _mobilePill(
                                    '+${sections.length - 1}',
                                    Colors.grey.shade600,
                                    Colors.grey.shade100),
                            ]),
                          ])),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    _mobileIconBtn(Icons.edit_outlined, _kPurple,
                            () => _openEdit(context, t)),
                    const SizedBox(height: 4),
                    _mobileIconBtn(Icons.delete_outline, Colors.red.shade600,
                            () => _confirmDelete(context, t.id!)),
                  ]),
                ]))));
  }

  Widget _mobilePill(String label, Color textColor, Color bgColor,
      {IconData? icon}) =>
      Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: textColor),
              const SizedBox(width: 3)
            ],
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textColor)),
          ]));

  Widget _mobileIconBtn(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: color)));
}