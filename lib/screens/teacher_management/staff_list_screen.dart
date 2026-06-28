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
// class StaffListScreen extends StatefulWidget {
//   // ── Optional callback for opening profile in a side panel ──
//   final void Function(StaffMember staff,
//       {Map<String, String> classIdToName})? onItemTap;
//
//   const StaffListScreen({
//     super.key,
//     this.onItemTap,
//   });
//
//   @override
//   State<StaffListScreen> createState() => _StaffListScreenState();
// }
//
// class _StaffListScreenState extends State<StaffListScreen> {
//   final _searchCtrl = TextEditingController();
//   String _searchQuery = '';
//   int _currentPage = 0;
//   int _pageSize = 10;
//   final _pageSizeOptions = [10, 25, 50];
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => context.read<StaffProvider>().fetchStaffOnly());
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
//     return all.where((s) =>
//     s.name.toLowerCase().contains(_searchQuery) ||
//         s.phone.toLowerCase().contains(_searchQuery) ||
//         (s.designation ?? '').toLowerCase().contains(_searchQuery) ||
//         s.employmentType.toLowerCase().contains(_searchQuery)).toList();
//   }
//
//   Future<void> _openProfile(BuildContext context, dynamic s) async {
//     final classProvider = context.read<ClassProvider>();
//     final classIdToName = {
//       for (final c in classProvider.classes)
//         if (c.id != null) c.id!: c.name
//     };
//
//     // If a callback exists, use it instead of pushing a full‑screen page.
//     if (widget.onItemTap != null) {
//       widget.onItemTap!(s, classIdToName: classIdToName);
//       return;
//     }
//
//     // Fallback: full‑screen navigation (standalone usage)
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (_) =>
//               StaffProfileScreen(staff: s, classIdToName: classIdToName)),
//     );
//     if (result == 'edit' && context.mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => AddEditStaffScreen(existingStaff: s)),
//       );
//     }
//   }
//
//   Future<void> _openEdit(BuildContext context, dynamic s) async {
//     final result = await Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => AddEditStaffScreen(existingStaff: s)));
//     if (result == true && context.mounted) {
//       context.read<StaffProvider>().fetchStaffOnly();
//     }
//   }
//
//   void _confirmDelete(BuildContext context, String id) {
//     showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14)),
//           title: const Text('Delete Staff?',
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
//   // ── DESKTOP (flex‑based columns) ────────────────────────────────────────
//   Widget _buildDesktop() {
//     final provider = context.watch<StaffProvider>();
//     final filtered = _filtered(provider.staffOnly);
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
//               Text('Staff (${provider.staffOnly.length})',
//                   style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1A1A2E))),
//               const SizedBox(height: 2),
//               Text('Manage all staff members',
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
//                 if (result == true && mounted) provider.fetchStaffOnly();
//               },
//               icon: const Icon(Icons.add, size: 18),
//               label: const Text('Add Staff'),
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
//                   // Show entries row
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
//                         _th('PHOTO', flex: 7),
//                         _th('NAME', flex: 22),
//                         _th('DESIGNATION', flex: 17),
//                         _th('PHONE', flex: 16),
//                         _th('EMPLOYMENT', flex: 14),
//                         _th('STATUS', flex: 10),
//                         _th('ACTION', flex: 14, align: TextAlign.center),
//                       ])),
//                   const Divider(height: 1, color: Color(0xFFEEEFF3)),
//                   // Body
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
//                   // Footer pagination
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
//   Widget _desktopRow(BuildContext context, dynamic s) {
//     return InkWell(
//       onTap: () => _openProfile(context, s),
//       hoverColor: const Color(0xFFF8F8FF),
//       child: Padding(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           child: Row(children: [
//             // PHOTO
//             Expanded(
//               flex: 7,
//               child: CircleAvatar(
//                   radius: 18,
//                   backgroundColor: _kPurpleLight,
//                   backgroundImage: s.imageBase64 != null
//                       ? MemoryImage(base64Decode(s.imageBase64!))
//                       : null,
//                   child: s.imageBase64 == null
//                       ? Text(
//                       s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
//                       style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: _kPurple))
//                       : null),
//             ),
//             // NAME
//             Expanded(
//               flex: 22,
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(s.name,
//                         style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF1A1A2E)),
//                         overflow: TextOverflow.ellipsis),
//                     Text(s.gender,
//                         style: const TextStyle(
//                             fontSize: 11, color: Colors.grey)),
//                   ]),
//             ),
//             // DESIGNATION
//             Expanded(
//               flex: 17,
//               child: Text(
//                   s.designation?.isNotEmpty == true ? s.designation! : '—',
//                   style: TextStyle(
//                       fontSize: 13, color: Colors.grey.shade700),
//                   overflow: TextOverflow.ellipsis),
//             ),
//             // PHONE
//             Expanded(
//               flex: 16,
//               child: Text(s.phone,
//                   style: const TextStyle(fontSize: 13),
//                   overflow: TextOverflow.ellipsis),
//             ),
//             // EMPLOYMENT
//             Expanded(
//               flex: 14,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: const Color(0xFFF0F2F8),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Text(s.employmentType,
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
//               flex: 10,
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
//               flex: 14,
//               child: Center(
//                 child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _actionBtn(Icons.visibility_outlined,
//                           Colors.blue.shade600,
//                               () => _openProfile(context, s),
//                           tooltip: 'View'),
//                       const SizedBox(width: 4),
//                       _actionBtn(Icons.edit_outlined, _kPurple,
//                               () => _openEdit(context, s),
//                           tooltip: 'Edit'),
//                       const SizedBox(width: 4),
//                       _actionBtn(Icons.delete_outline, Colors.red.shade600,
//                               () => _confirmDelete(context, s.id!),
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
//         Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
//         const SizedBox(height: 12),
//         Text(
//             _searchQuery.isEmpty
//                 ? 'No staff members found.'
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
//     final filtered = _filtered(provider.staffOnly);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       appBar: AppBar(
//         backgroundColor: _kPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text('Staff',
//               style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
//           Text('${provider.staffOnly.length} members',
//               style: const TextStyle(fontSize: 11, color: Colors.white70)),
//         ]),
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.add),
//               tooltip: 'Add Staff',
//               onPressed: () async {
//                 final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const AddEditStaffScreen()));
//                 if (result == true && mounted) provider.fetchStaffOnly();
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
//                     hintText: 'Search staff…',
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
//                       Icon(Icons.people_outline,
//                           size: 48, color: Colors.grey.shade300),
//                       const SizedBox(height: 12),
//                       Text(
//                           _searchQuery.isEmpty
//                               ? 'No staff members found.'
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
//             if (result == true && mounted) provider.fetchStaffOnly();
//           },
//           child: const Icon(Icons.add)),
//     );
//   }
//
//   Widget _mobileCard(BuildContext context, dynamic s) => Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2))
//           ]),
//       child: InkWell(
//           onTap: () => _openProfile(context, s),
//           borderRadius: BorderRadius.circular(14),
//           child: Padding(
//               padding: const EdgeInsets.all(14),
//               child: Row(children: [
//                 CircleAvatar(
//                     radius: 26,
//                     backgroundColor: _kPurpleLight,
//                     backgroundImage: s.imageBase64 != null
//                         ? MemoryImage(base64Decode(s.imageBase64!))
//                         : null,
//                     child: s.imageBase64 == null
//                         ? Text(
//                         s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
//                         style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: _kPurple))
//                         : null),
//                 const SizedBox(width: 12),
//                 Expanded(
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(s.name,
//                               style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF1A1A2E))),
//                           if (s.designation?.isNotEmpty == true) ...[
//                             const SizedBox(height: 2),
//                             Text(s.designation!,
//                                 style: TextStyle(
//                                     fontSize: 12, color: Colors.grey.shade600)),
//                           ],
//                           const SizedBox(height: 6),
//                           Wrap(spacing: 6, children: [
//                             _mobilePill(s.employmentType, _kPurple,
//                                 const Color(0xFFF0EFFE)),
//                             _mobilePill(s.phone, Colors.grey.shade700,
//                                 Colors.grey.shade100,
//                                 icon: Icons.phone_outlined),
//                           ]),
//                         ])),
//                 Column(mainAxisSize: MainAxisSize.min, children: [
//                   _mobileIconBtn(Icons.edit_outlined, _kPurple,
//                           () => _openEdit(context, s)),
//                   const SizedBox(height: 4),
//                   _mobileIconBtn(Icons.delete_outline, Colors.red.shade600,
//                           () => _confirmDelete(context, s.id!)),
//                 ]),
//               ]))));
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

class StaffListScreen extends StatefulWidget {
  final void Function(StaffMember staff,
      {Map<String, String> classIdToName})? onItemTap;

  const StaffListScreen({
    super.key,
    this.onItemTap,
  });

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  int _pageSize = 10;
  final _pageSizeOptions = [10, 25, 50];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StaffProvider>().fetchStaffOnly());
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
    return all.where((s) =>
    s.name.toLowerCase().contains(_searchQuery) ||
        s.phone.toLowerCase().contains(_searchQuery) ||
        (s.designation ?? '').toLowerCase().contains(_searchQuery) ||
        s.employmentType.toLowerCase().contains(_searchQuery)).toList();
  }

  Future<void> _openProfile(BuildContext context, dynamic s) async {
    final classProvider = context.read<ClassProvider>();
    final classIdToName = {
      for (final c in classProvider.classes)
        if (c.id != null) c.id!: c.name
    };

    if (widget.onItemTap != null) {
      widget.onItemTap!(s, classIdToName: classIdToName);
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              StaffProfileScreen(staff: s, classIdToName: classIdToName)),
    );
    if (result == 'edit' && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddEditStaffScreen(existingStaff: s)),
      );
    }
  }

  Future<void> _openEdit(BuildContext context, dynamic s) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddEditStaffScreen(existingStaff: s)));
    if (result == true && context.mounted) {
      context.read<StaffProvider>().fetchStaffOnly();
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          title: const Text('Delete Staff?',
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

  // ── DESKTOP (with sections column) ──────────────────────────────────────
  Widget _buildDesktop() {
    final provider = context.watch<StaffProvider>();
    final filtered = _filtered(provider.staffOnly);
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
              Text('Staff (${provider.staffOnly.length})',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 2),
              Text('Manage all staff members',
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
                    MaterialPageRoute(
                        builder: (_) => const AddEditStaffScreen()));
                if (result == true && mounted) provider.fetchStaffOnly();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Staff'),
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
                  // Table header
                  Container(
                      color: const Color(0xFFF8F9FC),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(children: [
                        _th('PHOTO', flex: 7),
                        _th('NAME', flex: 22),
                        _th('DESIGNATION', flex: 15),
                        _th('SECTIONS', flex: 12),     // NEW
                        _th('PHONE', flex: 14),
                        _th('EMPLOYMENT', flex: 14),
                        _th('STATUS', flex: 10),
                        _th('ACTION', flex: 12, align: TextAlign.center),
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

  Widget _desktopRow(BuildContext context, dynamic s) {
    final sections = (s.assignedSections as List?)?.cast<String>() ?? [];

    return InkWell(
      onTap: () => _openProfile(context, s),
      hoverColor: const Color(0xFFF8F8FF),
      child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            // PHOTO
            Expanded(
              flex: 7,
              child: CircleAvatar(
                  radius: 18,
                  backgroundColor: _kPurpleLight,
                  backgroundImage: s.imageBase64 != null
                      ? MemoryImage(base64Decode(s.imageBase64!))
                      : null,
                  child: s.imageBase64 == null
                      ? Text(
                      s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _kPurple))
                      : null),
            ),
            // NAME
            Expanded(
              flex: 22,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E)),
                        overflow: TextOverflow.ellipsis),
                    Text(s.gender,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ]),
            ),
            // DESIGNATION
            Expanded(
              flex: 15,
              child: Text(
                  s.designation?.isNotEmpty == true ? s.designation! : '—',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis),
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
              flex: 14,
              child: Text(s.phone,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
            // EMPLOYMENT
            Expanded(
              flex: 14,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F8),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(s.employmentType,
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
              flex: 10,
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
              flex: 12,
              child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionBtn(Icons.visibility_outlined,
                          Colors.blue.shade600,
                              () => _openProfile(context, s),
                          tooltip: 'View'),
                      const SizedBox(width: 4),
                      _actionBtn(Icons.edit_outlined, _kPurple,
                              () => _openEdit(context, s),
                          tooltip: 'Edit'),
                      const SizedBox(width: 4),
                      _actionBtn(Icons.delete_outline, Colors.red.shade600,
                              () => _confirmDelete(context, s.id!),
                          tooltip: 'Delete'),
                    ]),
              ),
            ),
          ])),
    );
  }

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
        Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
            _searchQuery.isEmpty
                ? 'No staff members found.'
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

  // ── MOBILE (added sections) ──────────────────────────────────────────────
  Widget _buildMobile() {
    final provider = context.watch<StaffProvider>();
    final filtered = _filtered(provider.staffOnly);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Staff',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          Text('${provider.staffOnly.length} members',
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Staff',
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddEditStaffScreen()));
                if (result == true && mounted) provider.fetchStaffOnly();
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
                    hintText: 'Search staff…',
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
                      Icon(Icons.people_outline,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                          _searchQuery.isEmpty
                              ? 'No staff members found.'
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
            if (result == true && mounted) provider.fetchStaffOnly();
          },
          child: const Icon(Icons.add)),
    );
  }

  Widget _mobileCard(BuildContext context, dynamic s) {
    final sections = (s.assignedSections as List?)?.cast<String>() ?? [];

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
            onTap: () => _openProfile(context, s),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  CircleAvatar(
                      radius: 26,
                      backgroundColor: _kPurpleLight,
                      backgroundImage: s.imageBase64 != null
                          ? MemoryImage(base64Decode(s.imageBase64!))
                          : null,
                      child: s.imageBase64 == null
                          ? Text(
                          s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
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
                            Text(s.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E))),
                            if (s.designation?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Text(s.designation!,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade600)),
                            ],
                            const SizedBox(height: 6),
                            Wrap(spacing: 6, runSpacing: 4, children: [
                              _mobilePill(s.employmentType, _kPurple,
                                  const Color(0xFFF0EFFE)),
                              _mobilePill(s.phone, Colors.grey.shade700,
                                  Colors.grey.shade100,
                                  icon: Icons.phone_outlined),
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
                            () => _openEdit(context, s)),
                    const SizedBox(height: 4),
                    _mobileIconBtn(Icons.delete_outline, Colors.red.shade600,
                            () => _confirmDelete(context, s.id!)),
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