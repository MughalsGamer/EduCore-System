//
// import 'dart:convert';
// import 'package:educoresystem/screens/student_management/student_profile.dart';
// import 'package:educoresystem/screens/student_management/terminated_students_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/admission_model.dart';
// import '../../models/class_model.dart';
// import '../../providers/admission_provider.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/student_provider.dart';
//
// class StudentListScreen extends StatefulWidget {
//   const StudentListScreen({super.key});
//
//   @override
//   State<StudentListScreen> createState() => _StudentListScreenState();
// }
//
// class _StudentListScreenState extends State<StudentListScreen> {
//   static const _purple = Color(0xFF534AB7);
//   final _searchCtrl = TextEditingController();
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   void _showFilters(BuildContext context, StudentProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (ctx, setSheetState) {
//             final families = provider.allFamilies;
//             final classes  = provider.allClassNames;
//             String? selFamily  = provider.selectedFamilyId;
//             String? selClass   = provider.selectedClassName;
//             String? selSection = provider.selectedSectionName;
//
//             final sections = selClass != null
//                 ? provider.sectionsForClass(selClass!)
//                 : <String>[];
//
//             return Padding(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Container(
//                       width: 40, height: 4,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       const Text('Filters',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                       const Spacer(),
//                       if (provider.hasActiveFilters)
//                         TextButton(
//                           onPressed: () {
//                             provider.clearAllFilters();
//                             _searchCtrl.clear();
//                             Navigator.pop(ctx);
//                           },
//                           child: const Text('Clear All',
//                               style: TextStyle(color: Colors.red)),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//
//                   const Text('Family',
//                       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 8),
//                   if (families.isEmpty)
//                     Text('No families found', style: TextStyle(color: Colors.grey.shade500, fontSize: 13))
//                   else
//                     Wrap(
//                       spacing: 8, runSpacing: 6,
//                       children: [
//                         _filterChip(
//                           label: 'All',
//                           selected: selFamily == null,
//                           onTap: () {
//                             setSheetState(() => selFamily = null);
//                             provider.setFamilyFilter(null);
//                           },
//                         ),
//                         ...families.map((f) => _filterChip(
//                           label: '${f.value} (${f.key})',
//                           selected: selFamily == f.key,
//                           onTap: () {
//                             setSheetState(() => selFamily = f.key);
//                             provider.setFamilyFilter(f.key);
//                           },
//                         )),
//                       ],
//                     ),
//
//                   const SizedBox(height: 20),
//
//                   const Text('Class',
//                       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 8),
//                   if (classes.isEmpty)
//                     Text('No classes found', style: TextStyle(color: Colors.grey.shade500, fontSize: 13))
//                   else
//                     Wrap(
//                       spacing: 8, runSpacing: 6,
//                       children: [
//                         _filterChip(
//                           label: 'All',
//                           selected: selClass == null,
//                           onTap: () {
//                             setSheetState(() {
//                               selClass = null;
//                               selSection = null;
//                             });
//                             provider.setClassFilter(null);
//                           },
//                         ),
//                         ...classes.map((c) => _filterChip(
//                           label: c,
//                           selected: selClass == c,
//                           onTap: () {
//                             setSheetState(() {
//                               selClass = c;
//                               selSection = null;
//                             });
//                             provider.setClassFilter(c);
//                           },
//                         )),
//                       ],
//                     ),
//
//                   if (selClass != null && sections.isNotEmpty) ...[
//                     const SizedBox(height: 20),
//                     Text('Section',
//                         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8, runSpacing: 6,
//                       children: [
//                         _filterChip(
//                           label: 'All',
//                           selected: selSection == null,
//                           onTap: () {
//                             setSheetState(() => selSection = null);
//                             provider.setSectionFilter(null);
//                           },
//                         ),
//                         ...sections.map((sec) => _filterChip(
//                           label: sec,
//                           selected: selSection == sec,
//                           onTap: () {
//                             setSheetState(() => selSection = sec);
//                             provider.setSectionFilter(sec);
//                           },
//                         )),
//                       ],
//                     ),
//                   ],
//
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(ctx),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _purple,
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 46),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: const Text('Apply'),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _filterChip({
//     required String label,
//     required bool selected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//         decoration: BoxDecoration(
//           color: selected ? _purple : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: selected ? _purple : Colors.grey.shade300,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: selected ? Colors.white : Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Students'),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_off_outlined),
//             tooltip: 'Deactivated / Terminated Students',
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const TerminatedStudentsScreen()),
//             ),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
//             child: Consumer<StudentProvider>(
//               builder: (context, provider, _) {
//                 return Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _searchCtrl,
//                         onChanged: provider.setSearch,
//                         decoration: InputDecoration(
//                           hintText: 'Search by name, ID, class...',
//                           prefixIcon: const Icon(Icons.search, size: 20),
//                           suffixIcon: _searchCtrl.text.isNotEmpty
//                               ? IconButton(
//                             icon: const Icon(Icons.clear, size: 18),
//                             onPressed: () {
//                               _searchCtrl.clear();
//                               provider.setSearch('');
//                             },
//                           )
//                               : null,
//                           filled: true,
//                           fillColor: Colors.grey.shade100,
//                           contentPadding:
//                           const EdgeInsets.symmetric(vertical: 0),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(30),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         InkWell(
//                           onTap: () => _showFilters(context, provider),
//                           borderRadius: BorderRadius.circular(30),
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: provider.hasActiveFilters
//                                   ? _purple
//                                   : Colors.grey.shade100,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Icon(
//                               Icons.filter_list,
//                               size: 22,
//                               color: provider.hasActiveFilters
//                                   ? Colors.white
//                                   : Colors.grey.shade700,
//                             ),
//                           ),
//                         ),
//                         if (provider.hasActiveFilters)
//                           Positioned(
//                             top: -2,
//                             right: -2,
//                             child: Container(
//                               width: 10,
//                               height: 10,
//                               decoration: const BoxDecoration(
//                                 color: Colors.orange,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//       body: Consumer<StudentProvider>(
//         builder: (context, provider, _) {
//           final bool loading = provider.isLoading;
//           final String? err  = provider.error;
//           final List<StudentWithContext> list = provider.students;
//
//           if (loading && list.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (err != null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error: $err'),
//                   const SizedBox(height: 12),
//                   ElevatedButton(
//                     onPressed: provider.clearError,
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           if (list.isEmpty) {
//             return _buildEmpty(provider);
//           }
//
//           return Column(
//             children: [
//               if (provider.selectedFamilyId != null ||
//                   provider.selectedClassName != null)
//                 _buildActiveFilterBar(provider),
//
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
//                 child: Row(
//                   children: [
//                     Text(
//                       '${list.length} student(s)',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade600,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
//                   itemCount: list.length,
//                   itemBuilder: (ctx, i) => _StudentCard(
//                     key: ValueKey('${list[i].student.studentId}_$i'),
//                     data: list[i],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildActiveFilterBar(StudentProvider provider) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
//       child: Wrap(
//         spacing: 8, runSpacing: 4,
//         children: [
//           if (provider.selectedFamilyId != null)
//             Chip(
//               label: Text(
//                 'Family: ${provider.allFamilies.firstWhere(
//                       (f) => f.key == provider.selectedFamilyId,
//                   orElse: () => MapEntry(provider.selectedFamilyId!, provider.selectedFamilyId!),
//                 ).value}',
//                 style: const TextStyle(fontSize: 12),
//               ),
//               deleteIcon: const Icon(Icons.close, size: 16),
//               onDeleted: () => provider.setFamilyFilter(null),
//               backgroundColor: _purple.withOpacity(0.1),
//               deleteIconColor: _purple,
//               labelStyle: const TextStyle(color: _purple),
//               side: BorderSide(color: _purple.withOpacity(0.3)),
//             ),
//           if (provider.selectedClassName != null)
//             Chip(
//               label: Text(
//                 'Class: ${provider.selectedClassName}',
//                 style: const TextStyle(fontSize: 12),
//               ),
//               deleteIcon: const Icon(Icons.close, size: 16),
//               onDeleted: () => provider.setClassFilter(null),
//               backgroundColor: Colors.blue.withOpacity(0.1),
//               deleteIconColor: Colors.blue,
//               labelStyle: const TextStyle(color: Colors.blue),
//               side: BorderSide(color: Colors.blue.withOpacity(0.3)),
//             ),
//           if (provider.selectedSectionName != null)
//             Chip(
//               label: Text(
//                 'Section: ${provider.selectedSectionName}',
//                 style: const TextStyle(fontSize: 12),
//               ),
//               deleteIcon: const Icon(Icons.close, size: 16),
//               onDeleted: () => provider.setSectionFilter(null),
//               backgroundColor: Colors.teal.withOpacity(0.1),
//               deleteIconColor: Colors.teal,
//               labelStyle: const TextStyle(color: Colors.teal),
//               side: BorderSide(color: Colors.teal.withOpacity(0.3)),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmpty(StudentProvider provider) {
//     final bool hasFilters = provider.hasActiveFilters;
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             hasFilters ? Icons.search_off : Icons.school_outlined,
//             size: 64,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             hasFilters ? 'No students match filters' : 'No students yet',
//             style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
//           ),
//           if (hasFilters) ...[
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               onPressed: () {
//                 provider.clearAllFilters();
//                 _searchCtrl.clear();
//               },
//               icon: const Icon(Icons.clear_all, size: 18),
//               label: const Text('Clear Filters'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _purple,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ] else ...[
//             const SizedBox(height: 8),
//             Text(
//               'Add Regular Admissions to see students here',
//               style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Student Card
// // ─────────────────────────────────────────────
// class _StudentCard extends StatelessWidget {
//   final StudentWithContext data;
//   const _StudentCard({required this.data, Key? key}) : super(key: key);
//
//   static const _purple = Color(0xFF534AB7);
//   static const _red = Color(0xFFB91C1C);
//
//   Future<void> _confirmDeactivate(BuildContext context) async {
//     final result = await showDialog<_DeactivateResult>(
//       context: context,
//       builder: (_) => _DeactivateStudentDialog(studentName: data.student.name),
//     );
//     if (result == null || !context.mounted) return;
//
//     try {
//       await context.read<StudentProvider>().deactivateStudent(
//         context: data,
//         reason: result.reason,
//         date: result.date,
//         note: result.note,
//       );
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${data.student.name} has been deactivated'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   Future<void> _confirmPromote(BuildContext context) async {
//     final result = await showDialog<_PromoteResult>(
//       context: context,
//       builder: (_) => _PromoteStudentDialog(data: data),
//     );
//     if (result == null || !context.mounted) return;
//
//     try {
//       await context.read<StudentProvider>().promoteStudent(
//         context: data,
//         action: result.action,
//         date: result.date,
//         note: result.note,
//         classId: result.classId,
//         className: result.className,
//         sectionId: result.sectionId,
//         sectionName: result.sectionName,
//         monthlyFee: result.monthlyFee,
//         annualFee: result.annualFee,
//         registrationFee: result.registrationFee,
//       );
//       if (context.mounted) {
//         final label = result.action == 'promoted' ? 'promoted' : 'demoted';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${data.student.name} $label to ${result.className}'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final s = data.student;
//     final d = data;
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 2,
//       child: InkWell(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => StudentProfileScreen(data: data),
//           ),
//         ),
//         borderRadius: BorderRadius.circular(14),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               _avatar(s.picBase64),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       s.name.isNotEmpty ? s.name : '—',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     if (s.className != null && s.className!.isNotEmpty)
//                       Text(
//                         (s.sectionName != null && s.sectionName!.isNotEmpty)
//                             ? '${s.className} — ${s.sectionName}'
//                             : s.className!,
//                         style: TextStyle(
//                             fontSize: 12, color: Colors.grey.shade600),
//                       ),
//                     if (s.studentId.isNotEmpty)
//                       Text(
//                         'ID: ${s.studentId}',
//                         style: TextStyle(
//                             fontSize: 11, color: Colors.grey.shade500),
//                       ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.green),
//                 ),
//                 child: Text(
//                   d.inquiryOrRegId,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 6),
//               PopupMenuButton<String>(
//                 icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
//                 onSelected: (value) {
//                   if (value == 'deactivate') {
//                     _confirmDeactivate(context);
//                   } else if (value == 'view') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => StudentProfileScreen(data: data),
//                       ),
//                     );
//                   } else if (value == 'promote') {
//                     _confirmPromote(context);
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                     value: 'view',
//                     child: Row(
//                       children: [
//                         Icon(Icons.person_outline, size: 18, color: _purple),
//                         SizedBox(width: 10),
//                         Text('View Profile'),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'promote',
//                     child: Row(
//                       children: [
//                         Icon(Icons.trending_up, size: 18, color: Colors.blue),
//                         SizedBox(width: 10),
//                         Text('Promote / Demote Class', style: TextStyle(color: Colors.blue)),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'deactivate',
//                     child: Row(
//                       children: [
//                         Icon(Icons.person_off_outlined, size: 18, color: _red),
//                         SizedBox(width: 10),
//                         Text('Deactivate', style: TextStyle(color: _red)),
//                       ],
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
//   Widget _avatar(String? picBase64) {
//     if (picBase64 != null && picBase64.isNotEmpty) {
//       try {
//         return CircleAvatar(
//           radius: 28,
//           backgroundImage: MemoryImage(base64Decode(picBase64)),
//         );
//       } catch (_) {}
//     }
//     return CircleAvatar(
//       radius: 28,
//       backgroundColor: Colors.purple.shade50,
//       child: const Icon(Icons.person, size: 26, color: _purple),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Deactivate dialog — reason + date (defaults to today) + note
// // ─────────────────────────────────────────────
// class _DeactivateResult {
//   final String reason; // 'left_school' | 'terminated'
//   final DateTime date;
//   final String? note;
//   _DeactivateResult({required this.reason, required this.date, this.note});
// }
//
// class _DeactivateStudentDialog extends StatefulWidget {
//   final String studentName;
//   const _DeactivateStudentDialog({required this.studentName});
//
//   @override
//   State<_DeactivateStudentDialog> createState() =>
//       _DeactivateStudentDialogState();
// }
//
// class _DeactivateStudentDialogState extends State<_DeactivateStudentDialog> {
//   static const _purple = Color(0xFF534AB7);
//   String _reason = 'left_school';
//   DateTime _date = DateTime.now();
//   final _noteCtrl = TextEditingController();
//
//   @override
//   void dispose() {
//     _noteCtrl.dispose();
//     super.dispose();
//   }
//
//   String _formatDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       title: const Text('Deactivate Student',
//           style: TextStyle(fontWeight: FontWeight.w600)),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('"${widget.studentName}" will be moved to the Deactivated list.'),
//             const SizedBox(height: 16),
//             const Text('Reason *',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: _reasonChip(
//                     label: 'Left School',
//                     value: 'left_school',
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: _reasonChip(
//                     label: 'Terminated',
//                     value: 'terminated',
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Text('Date *',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
//             const SizedBox(height: 2),
//             Text('Defaults to today — tap to change if needed.',
//                 style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500)),
//             const SizedBox(height: 6),
//             InkWell(
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: _date,
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//                 if (picked != null) setState(() => _date = picked);
//               },
//               child: InputDecorator(
//                 decoration: InputDecoration(
//                   isDense: true,
//                   suffixIcon: const Icon(Icons.calendar_today, size: 16),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: Text(_formatDate(_date)),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text('Note (optional)',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
//             const SizedBox(height: 6),
//             TextField(
//               controller: _noteCtrl,
//               maxLines: 2,
//               decoration: InputDecoration(
//                 isDense: true,
//                 hintText: 'e.g. Family relocated to another city',
//                 hintStyle: const TextStyle(fontSize: 12),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFFB91C1C),
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           onPressed: () {
//             Navigator.pop(
//               context,
//               _DeactivateResult(
//                 reason: _reason,
//                 date: _date,
//                 note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
//               ),
//             );
//           },
//           child: const Text('Deactivate'),
//         ),
//       ],
//     );
//   }
//
//   Widget _reasonChip({required String label, required String value}) {
//     final selected = _reason == value;
//     return GestureDetector(
//       onTap: () => setState(() => _reason = value),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: selected ? _purple : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: selected ? _purple : Colors.grey.shade300),
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: selected ? Colors.white : Colors.black87,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Promote / Demote dialog — pick new class, section & fees (admission-form style)
// // ─────────────────────────────────────────────
// class _PromoteResult {
//   final String action; // 'promoted' | 'demoted'
//   final DateTime date;
//   final String classId;
//   final String className;
//   final String? sectionId;
//   final String? sectionName;
//   final double? monthlyFee;
//   final double? annualFee;
//   final double? registrationFee;
//   final String? note;
//   _PromoteResult({
//     required this.action,
//     required this.date,
//     required this.classId,
//     required this.className,
//     this.sectionId,
//     this.sectionName,
//     this.monthlyFee,
//     this.annualFee,
//     this.registrationFee,
//     this.note,
//   });
// }
//
// class _PromoteStudentDialog extends StatefulWidget {
//   final StudentWithContext data;
//   const _PromoteStudentDialog({required this.data});
//
//   @override
//   State<_PromoteStudentDialog> createState() => _PromoteStudentDialogState();
// }
//
// class _PromoteStudentDialogState extends State<_PromoteStudentDialog> {
//   static const _purple = Color(0xFF534AB7);
//
//   String _action = 'promoted';
//   DateTime _date = DateTime.now();
//   String? _classId;
//   String? _className;
//   String? _sectionId;
//   String? _sectionName;
//   bool _loadingFees = false;
//
//   late TextEditingController _monthlyCtrl;
//   late TextEditingController _annualCtrl;
//   late TextEditingController _regCtrl;
//   late TextEditingController _noteCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//     final s = widget.data.student;
//     _monthlyCtrl = TextEditingController(text: s.monthlyFee?.toStringAsFixed(0) ?? '');
//     _annualCtrl = TextEditingController(text: s.annualFee?.toStringAsFixed(0) ?? '');
//     _regCtrl = TextEditingController(text: s.registrationFee?.toStringAsFixed(0) ?? '');
//     _noteCtrl = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     _monthlyCtrl.dispose();
//     _annualCtrl.dispose();
//     _regCtrl.dispose();
//     _noteCtrl.dispose();
//     super.dispose();
//   }
//
//   String _formatDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//
//   double? _parse(String v) => v.trim().isEmpty ? null : double.tryParse(v.trim());
//
//   Future<void> _fetchFees() async {
//     if (_classId == null) return;
//     setState(() => _loadingFees = true);
//     try {
//       final fees = await context.read<AdmissionProvider>().fetchFees(_classId!, _sectionName);
//       if (!mounted) return;
//       setState(() {
//         if (fees['monthlyFee'] != null) _monthlyCtrl.text = fees['monthlyFee']!.toStringAsFixed(0);
//         if (fees['annualFee'] != null) _annualCtrl.text = fees['annualFee']!.toStringAsFixed(0);
//         if (fees['registrationFee'] != null) _regCtrl.text = fees['registrationFee']!.toStringAsFixed(0);
//         _loadingFees = false;
//       });
//     } catch (e) {
//       if (mounted) setState(() => _loadingFees = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final s = widget.data.student;
//     final classes = context.watch<ClassProvider>().classes;
//
//     SchoolClass? selectedClass;
//     if (_classId != null) {
//       try {
//         selectedClass = classes.firstWhere((c) => c.id == _classId);
//       } catch (_) {}
//     }
//     final sections = selectedClass?.sections ?? [];
//
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       title: const Text('Promote / Demote Student', style: TextStyle(fontWeight: FontWeight.w600)),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Current Class: ${s.className ?? '—'}'
//                   '${(s.sectionName != null && s.sectionName!.isNotEmpty) ? ' — ${s.sectionName}' : ''}',
//               style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 16),
//
//             const Text('Action *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(child: _actionChip(label: '⬆ Promote', value: 'promoted')),
//                 const SizedBox(width: 8),
//                 Expanded(child: _actionChip(label: '⬇ Demote', value: 'demoted')),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             const Text('Date *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
//             const SizedBox(height: 6),
//             InkWell(
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: _date,
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//                 if (picked != null) setState(() => _date = picked);
//               },
//               child: InputDecorator(
//                 decoration: InputDecoration(
//                   isDense: true,
//                   suffixIcon: const Icon(Icons.calendar_today, size: 16),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: Text(_formatDate(_date)),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             const Text('New Class *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
//             const SizedBox(height: 6),
//             DropdownButtonFormField<String>(
//               value: classes.any((c) => c.id == _classId) ? _classId : null,
//               decoration: InputDecoration(
//                 isDense: true,
//                 hintText: 'Select new class',
//                 prefixIcon: const Icon(Icons.class_, size: 18),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
//               onChanged: (val) async {
//                 final newClass = classes.firstWhere((c) => c.id == val);
//                 setState(() {
//                   _classId = val;
//                   _className = newClass.name;
//                   if (newClass.sections.length == 1) {
//                     _sectionId = newClass.sections.first.sectionName;
//                     _sectionName = newClass.sections.first.sectionName;
//                   } else {
//                     _sectionId = null;
//                     _sectionName = null;
//                   }
//                 });
//                 await _fetchFees();
//               },
//             ),
//             if (sections.isNotEmpty) ...[
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String>(
//                 value: sections.any((sec) => sec.sectionName == _sectionName) ? _sectionName : null,
//                 decoration: InputDecoration(
//                   isDense: true,
//                   labelText: 'Section',
//                   prefixIcon: const Icon(Icons.group_outlined, size: 18),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 items: sections
//                     .map((sec) => DropdownMenuItem(value: sec.sectionName, child: Text(sec.sectionName)))
//                     .toList(),
//                 onChanged: (val) async {
//                   setState(() {
//                     _sectionName = val;
//                     _sectionId = val;
//                   });
//                   await _fetchFees();
//                 },
//               ),
//             ],
//             const SizedBox(height: 18),
//
//             Row(
//               children: [
//                 Icon(Icons.payments_outlined, size: 15, color: _purple),
//                 const SizedBox(width: 6),
//                 const Text('Fee Structure', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
//                 if (_loadingFees) ...[
//                   const SizedBox(width: 8),
//                   const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
//                 ],
//               ],
//             ),
//             const SizedBox(height: 8),
//             _field('Monthly Fee', _monthlyCtrl, isNumber: true),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(child: _field('Annual Fee', _annualCtrl, isNumber: true)),
//                 const SizedBox(width: 8),
//                 Expanded(child: _field('Registration Fee', _regCtrl, isNumber: true)),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             const Text('Note (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
//             const SizedBox(height: 6),
//             TextField(
//               controller: _noteCtrl,
//               maxLines: 2,
//               decoration: InputDecoration(
//                 isDense: true,
//                 hintText: 'e.g. Annual result based promotion',
//                 hintStyle: const TextStyle(fontSize: 12),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _purple,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           onPressed: () {
//             if (_classId == null) {
//               ScaffoldMessenger.of(context)
//                   .showSnackBar(const SnackBar(content: Text('Please select the new class')));
//               return;
//             }
//             Navigator.pop(
//               context,
//               _PromoteResult(
//                 action: _action,
//                 date: _date,
//                 classId: _classId!,
//                 className: _className ?? '',
//                 sectionId: _sectionId,
//                 sectionName: _sectionName,
//                 monthlyFee: _parse(_monthlyCtrl.text),
//                 annualFee: _parse(_annualCtrl.text),
//                 registrationFee: _parse(_regCtrl.text),
//                 note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
//               ),
//             );
//           },
//           child: const Text('Confirm'),
//         ),
//       ],
//     );
//   }
//
//   Widget _actionChip({required String label, required String value}) {
//     final selected = _action == value;
//     return GestureDetector(
//       onTap: () => setState(() => _action = value),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: selected ? _purple : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: selected ? _purple : Colors.grey.shade300),
//         ),
//         child: Center(
//           child: Text(label,
//               style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black87)),
//         ),
//       ),
//     );
//   }
//
//   Widget _field(String label, TextEditingController ctrl, {bool isNumber = false}) {
//     return TextField(
//       controller: ctrl,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//       style: const TextStyle(fontSize: 13),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(fontSize: 12),
//         isDense: true,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:educoresystem/screens/student_management/student_profile.dart';
import 'package:educoresystem/screens/student_management/terminated_students_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admission_model.dart';
import '../../models/class_model.dart';
import '../../providers/admission_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/student_provider.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  static const _purple = Color(0xFF534AB7);
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilters(BuildContext context, StudentProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final families = provider.allFamilies;
            final classes  = provider.allClassNames;
            String? selFamily  = provider.selectedFamilyId;
            String? selClass   = provider.selectedClassName;
            String? selSection = provider.selectedSectionName;

            final sections = selClass != null
                ? provider.sectionsForClass(selClass!)
                : <String>[];

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Filters',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (provider.hasActiveFilters)
                        TextButton(
                          onPressed: () {
                            provider.clearAllFilters();
                            _searchCtrl.clear();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Clear All',
                              style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('Family',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (families.isEmpty)
                    Text('No families found', style: TextStyle(color: Colors.grey.shade500, fontSize: 13))
                  else
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: [
                        _filterChip(
                          label: 'All',
                          selected: selFamily == null,
                          onTap: () {
                            setSheetState(() => selFamily = null);
                            provider.setFamilyFilter(null);
                          },
                        ),
                        ...families.map((f) => _filterChip(
                          label: '${f.value} (${f.key})',
                          selected: selFamily == f.key,
                          onTap: () {
                            setSheetState(() => selFamily = f.key);
                            provider.setFamilyFilter(f.key);
                          },
                        )),
                      ],
                    ),

                  const SizedBox(height: 20),

                  const Text('Class',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (classes.isEmpty)
                    Text('No classes found', style: TextStyle(color: Colors.grey.shade500, fontSize: 13))
                  else
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: [
                        _filterChip(
                          label: 'All',
                          selected: selClass == null,
                          onTap: () {
                            setSheetState(() {
                              selClass = null;
                              selSection = null;
                            });
                            provider.setClassFilter(null);
                          },
                        ),
                        ...classes.map((c) => _filterChip(
                          label: c,
                          selected: selClass == c,
                          onTap: () {
                            setSheetState(() {
                              selClass = c;
                              selSection = null;
                            });
                            provider.setClassFilter(c);
                          },
                        )),
                      ],
                    ),

                  if (selClass != null && sections.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Section',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: [
                        _filterChip(
                          label: 'All',
                          selected: selSection == null,
                          onTap: () {
                            setSheetState(() => selSection = null);
                            provider.setSectionFilter(null);
                          },
                        ),
                        ...sections.map((sec) => _filterChip(
                          label: sec,
                          selected: selSection == sec,
                          onTap: () {
                            setSheetState(() => selSection = sec);
                            provider.setSectionFilter(sec);
                          },
                        )),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _purple : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_off_outlined),
            tooltip: 'Deactivated / Terminated Students',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TerminatedStudentsScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Consumer<StudentProvider>(
              builder: (context, provider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: provider.setSearch,
                        decoration: InputDecoration(
                          hintText: 'Search by name, ID, class...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              provider.setSearch('');
                            },
                          )
                              : null,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InkWell(
                          onTap: () => _showFilters(context, provider),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: provider.hasActiveFilters
                                  ? _purple
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.filter_list,
                              size: 22,
                              color: provider.hasActiveFilters
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                        if (provider.hasActiveFilters)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          final bool loading = provider.isLoading;
          final String? err  = provider.error;
          final List<StudentWithContext> list = provider.students;

          if (loading && list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (err != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $err'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.clearError,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (list.isEmpty) {
            return _buildEmpty(provider);
          }

          return Column(
            children: [
              if (provider.selectedFamilyId != null ||
                  provider.selectedClassName != null)
                _buildActiveFilterBar(provider),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Text(
                      '${list.length} student(s)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => _StudentCard(
                    key: ValueKey('${list[i].student.studentId}_$i'),
                    data: list[i],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterBar(StudentProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Wrap(
        spacing: 8, runSpacing: 4,
        children: [
          if (provider.selectedFamilyId != null)
            Chip(
              label: Text(
                'Family: ${provider.allFamilies.firstWhere(
                      (f) => f.key == provider.selectedFamilyId,
                  orElse: () => MapEntry(provider.selectedFamilyId!, provider.selectedFamilyId!),
                ).value}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => provider.setFamilyFilter(null),
              backgroundColor: _purple.withOpacity(0.1),
              deleteIconColor: _purple,
              labelStyle: const TextStyle(color: _purple),
              side: BorderSide(color: _purple.withOpacity(0.3)),
            ),
          if (provider.selectedClassName != null)
            Chip(
              label: Text(
                'Class: ${provider.selectedClassName}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => provider.setClassFilter(null),
              backgroundColor: Colors.blue.withOpacity(0.1),
              deleteIconColor: Colors.blue,
              labelStyle: const TextStyle(color: Colors.blue),
              side: BorderSide(color: Colors.blue.withOpacity(0.3)),
            ),
          if (provider.selectedSectionName != null)
            Chip(
              label: Text(
                'Section: ${provider.selectedSectionName}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => provider.setSectionFilter(null),
              backgroundColor: Colors.teal.withOpacity(0.1),
              deleteIconColor: Colors.teal,
              labelStyle: const TextStyle(color: Colors.teal),
              side: BorderSide(color: Colors.teal.withOpacity(0.3)),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty(StudentProvider provider) {
    final bool hasFilters = provider.hasActiveFilters;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.school_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No students match filters' : 'No students yet',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearAllFilters();
                _searchCtrl.clear();
              },
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Add Regular Admissions to see students here',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Student Card
// ─────────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  final StudentWithContext data;
  const _StudentCard({required this.data, Key? key}) : super(key: key);

  static const _purple = Color(0xFF534AB7);
  static const _red = Color(0xFFB91C1C);

  Future<void> _confirmDeactivate(BuildContext context) async {
    final result = await showDialog<_DeactivateResult>(
      context: context,
      builder: (_) => _DeactivateStudentDialog(studentName: data.student.name),
    );
    if (result == null || !context.mounted) return;

    try {
      await context.read<StudentProvider>().deactivateStudent(
        context: data,
        reason: result.reason,
        date: result.date,
        note: result.note,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data.student.name} has been deactivated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmPromote(BuildContext context) async {
    final result = await showDialog<_PromoteResult>(
      context: context,
      builder: (_) => _PromoteStudentDialog(data: data),
    );
    if (result == null || !context.mounted) return;

    try {
      await context.read<StudentProvider>().promoteStudent(
        context: data,
        action: result.action,
        date: result.date,
        note: result.note,
        classId: result.classId,
        className: result.className,
        sectionId: result.sectionId,
        sectionName: result.sectionName,
        monthlyFee: result.monthlyFee,
        annualFee: result.annualFee,
        academyFee: result.academyFee,
      );
      if (context.mounted) {
        final label = result.action == 'promoted' ? 'promoted' : 'demoted';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data.student.name} $label to ${result.className}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = data.student;
    final d = data;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentProfileScreen(data: data),
          ),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _avatar(s.picBase64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name.isNotEmpty ? s.name : '—',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (s.className != null && s.className!.isNotEmpty)
                      Text(
                        (s.sectionName != null && s.sectionName!.isNotEmpty)
                            ? '${s.className} — ${s.sectionName}'
                            : s.className!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    if (s.studentId.isNotEmpty)
                      Text(
                        'ID: ${s.studentId}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  d.inquiryOrRegId,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                onSelected: (value) {
                  if (value == 'deactivate') {
                    _confirmDeactivate(context);
                  } else if (value == 'view') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentProfileScreen(data: data),
                      ),
                    );
                  } else if (value == 'promote') {
                    _confirmPromote(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 18, color: _purple),
                        SizedBox(width: 10),
                        Text('View Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'promote',
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, size: 18, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Promote / Demote Class', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(Icons.person_off_outlined, size: 18, color: _red),
                        SizedBox(width: 10),
                        Text('Deactivate', style: TextStyle(color: _red)),
                      ],
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

  Widget _avatar(String? picBase64) {
    if (picBase64 != null && picBase64.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 28,
          backgroundImage: MemoryImage(base64Decode(picBase64)),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.purple.shade50,
      child: const Icon(Icons.person, size: 26, color: _purple),
    );
  }
}

// ─────────────────────────────────────────────
//  Deactivate dialog — reason + date (defaults to today) + note
// ─────────────────────────────────────────────
class _DeactivateResult {
  final String reason; // 'left_school' | 'terminated'
  final DateTime date;
  final String? note;
  _DeactivateResult({required this.reason, required this.date, this.note});
}

class _DeactivateStudentDialog extends StatefulWidget {
  final String studentName;
  const _DeactivateStudentDialog({required this.studentName});

  @override
  State<_DeactivateStudentDialog> createState() =>
      _DeactivateStudentDialogState();
}

class _DeactivateStudentDialogState extends State<_DeactivateStudentDialog> {
  static const _purple = Color(0xFF534AB7);
  String _reason = 'left_school';
  DateTime _date = DateTime.now();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Deactivate Student',
          style: TextStyle(fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"${widget.studentName}" will be moved to the Deactivated list.'),
            const SizedBox(height: 16),
            const Text('Reason *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _reasonChip(
                    label: 'Left School',
                    value: 'left_school',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _reasonChip(
                    label: 'Terminated',
                    value: 'terminated',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Date *',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 2),
            Text('Defaults to today — tap to change if needed.',
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500)),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  isDense: true,
                  suffixIcon: const Icon(Icons.calendar_today, size: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_formatDate(_date)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Note (optional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'e.g. Family relocated to another city',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB91C1C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.pop(
              context,
              _DeactivateResult(
                reason: _reason,
                date: _date,
                note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
              ),
            );
          },
          child: const Text('Deactivate'),
        ),
      ],
    );
  }

  Widget _reasonChip({required String label, required String value}) {
    final selected = _reason == value;
    return GestureDetector(
      onTap: () => setState(() => _reason = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _purple : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Promote / Demote dialog — pick new class, section & fees (admission-form style)
// ─────────────────────────────────────────────
class _PromoteResult {
  final String action; // 'promoted' | 'demoted'
  final DateTime date;
  final String classId;
  final String className;
  final String? sectionId;
  final String? sectionName;
  final double? monthlyFee;
  final double? annualFee;
  final double? academyFee;
  final String? note;
  _PromoteResult({
    required this.action,
    required this.date,
    required this.classId,
    required this.className,
    this.sectionId,
    this.sectionName,
    this.monthlyFee,
    this.annualFee,
    this.academyFee,
    this.note,
  });
}

class _PromoteStudentDialog extends StatefulWidget {
  final StudentWithContext data;
  const _PromoteStudentDialog({required this.data});

  @override
  State<_PromoteStudentDialog> createState() => _PromoteStudentDialogState();
}

class _PromoteStudentDialogState extends State<_PromoteStudentDialog> {
  static const _purple = Color(0xFF534AB7);

  String _action = 'promoted';
  DateTime _date = DateTime.now();
  String? _classId;
  String? _className;
  String? _sectionId;
  String? _sectionName;
  bool _loadingFees = false;

  late TextEditingController _monthlyCtrl;
  late TextEditingController _annualCtrl;
  late TextEditingController _academyCtrl;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.data.student;
    _monthlyCtrl = TextEditingController(text: s.monthlyFee?.toStringAsFixed(0) ?? '');
    _annualCtrl = TextEditingController(text: s.annualFee?.toStringAsFixed(0) ?? '');
    _academyCtrl = TextEditingController(text: s.academyFee?.toStringAsFixed(0) ?? '');
    _noteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _monthlyCtrl.dispose();
    _annualCtrl.dispose();
    _academyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  double? _parse(String v) => v.trim().isEmpty ? null : double.tryParse(v.trim());

  Future<void> _fetchFees() async {
    if (_classId == null) return;
    setState(() => _loadingFees = true);
    try {
      final fees = await context.read<AdmissionProvider>().fetchFees(_classId!, _sectionName);
      if (!mounted) return;
      setState(() {
        if (fees['monthlyFee'] != null) _monthlyCtrl.text = fees['monthlyFee']!.toStringAsFixed(0);
        if (fees['annualFee'] != null) _annualCtrl.text = fees['annualFee']!.toStringAsFixed(0);
        if (fees['academyFee'] != null) _academyCtrl.text = fees['academyFee']!.toStringAsFixed(0);
        _loadingFees = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingFees = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.data.student;
    final classes = context.watch<ClassProvider>().classes;

    SchoolClass? selectedClass;
    if (_classId != null) {
      try {
        selectedClass = classes.firstWhere((c) => c.id == _classId);
      } catch (_) {}
    }
    final sections = selectedClass?.sections ?? [];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Promote / Demote Student', style: TextStyle(fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Class: ${s.className ?? '—'}'
                  '${(s.sectionName != null && s.sectionName!.isNotEmpty) ? ' — ${s.sectionName}' : ''}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            const Text('Action *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _actionChip(label: '⬆ Promote', value: 'promoted')),
                const SizedBox(width: 8),
                Expanded(child: _actionChip(label: '⬇ Demote', value: 'demoted')),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Date *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  isDense: true,
                  suffixIcon: const Icon(Icons.calendar_today, size: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_formatDate(_date)),
              ),
            ),
            const SizedBox(height: 16),

            const Text('New Class *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: classes.any((c) => c.id == _classId) ? _classId : null,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Select new class',
                prefixIcon: const Icon(Icons.class_, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (val) async {
                final newClass = classes.firstWhere((c) => c.id == val);
                setState(() {
                  _classId = val;
                  _className = newClass.name;
                  if (newClass.sections.length == 1) {
                    _sectionId = newClass.sections.first.sectionName;
                    _sectionName = newClass.sections.first.sectionName;
                  } else {
                    _sectionId = null;
                    _sectionName = null;
                  }
                });
                await _fetchFees();
              },
            ),
            if (sections.isNotEmpty) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: sections.any((sec) => sec.sectionName == _sectionName) ? _sectionName : null,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Section',
                  prefixIcon: const Icon(Icons.group_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: sections
                    .map((sec) => DropdownMenuItem(value: sec.sectionName, child: Text(sec.sectionName)))
                    .toList(),
                onChanged: (val) async {
                  setState(() {
                    _sectionName = val;
                    _sectionId = val;
                  });
                  await _fetchFees();
                },
              ),
            ],
            const SizedBox(height: 18),

            Row(
              children: [
                Icon(Icons.payments_outlined, size: 15, color: _purple),
                const SizedBox(width: 6),
                const Text('Fee Structure', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                if (_loadingFees) ...[
                  const SizedBox(width: 8),
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            _field('Monthly Fee', _monthlyCtrl, isNumber: true),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _field('Annual Fee', _annualCtrl, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: _field('Academy Fee', _academyCtrl, isNumber: true)),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Note (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'e.g. Annual result based promotion',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (_classId == null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Please select the new class')));
              return;
            }
            Navigator.pop(
              context,
              _PromoteResult(
                action: _action,
                date: _date,
                classId: _classId!,
                className: _className ?? '',
                sectionId: _sectionId,
                sectionName: _sectionName,
                monthlyFee: _parse(_monthlyCtrl.text),
                annualFee: _parse(_annualCtrl.text),
                academyFee: _parse(_academyCtrl.text),
                note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
              ),
            );
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _actionChip({required String label, required String value}) {
    final selected = _action == value;
    return GestureDetector(
      onTap: () => setState(() => _action = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _purple : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}