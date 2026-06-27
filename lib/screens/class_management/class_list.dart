// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/class_model.dart';
// import '../../providers/class_provider.dart';
// import '../../providers/teacher_provider.dart';
// import 'add_class.dart';
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: widget.showAppBar
//           ? AppBar(
//         title: const Text('Classes'),
//         centerTitle: true,
//       )
//           : null,
//       floatingActionButton: widget.showFAB
//           ? FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => const AddEditClassScreen()),
//           );
//           if (result == true) {}
//         },
//         child: const Icon(Icons.add),
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
//                   ElevatedButton(
//                     onPressed: () => provider.clearError(),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//           if (provider.classes.isEmpty) {
//             return const Center(child: Text('No classes found'));
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: provider.classes.length,
//             itemBuilder: (context, index) {
//               final schoolClass = provider.classes[index];
//               return _ExpandableClassCard(schoolClass: schoolClass);
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _ExpandableClassCard extends StatefulWidget {
//   final SchoolClass schoolClass;
//   const _ExpandableClassCard({required this.schoolClass});
//
//   @override
//   State<_ExpandableClassCard> createState() => _ExpandableClassCardState();
// }
//
// class _ExpandableClassCardState extends State<_ExpandableClassCard> {
//   bool _expanded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final cls = widget.schoolClass;
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         children: [
//           InkWell(
//             onTap: () => setState(() => _expanded = !_expanded),
//             borderRadius: BorderRadius.circular(12),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           cls.name,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '${cls.subjects?.length ?? 0} subjects',
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.edit, size: 20),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               AddEditClassScreen(existingClass: cls),
//                         ),
//                       );
//                     },
//                   ),
//                   IconButton(
//                     icon:
//                     const Icon(Icons.delete, size: 20, color: Colors.red),
//                     onPressed: () => _confirmDelete(context, cls),
//                   ),
//                   Icon(_expanded ? Icons.expand_less : Icons.expand_more),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedCrossFade(
//             firstChild: const SizedBox.shrink(),
//             secondChild: _buildDetails(cls),
//             crossFadeState:
//             _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
//             duration: const Duration(milliseconds: 300),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetails(SchoolClass cls) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Divider(),
//
//           // ── Class info ──
//           if (cls.headOfClassTeacher != null &&
//               cls.headOfClassTeacher!.isNotEmpty)
//             _detailRow(Icons.person,
//                 'Head Teacher: ${cls.headOfClassTeacher}'),
//           if (cls.annualFee != null)
//             _detailRow(Icons.calendar_today_outlined,
//                 'Annual Fee: Rs ${cls.annualFee!.toStringAsFixed(0)}'),
//           if (cls.registrationFee != null)
//             _detailRow(Icons.app_registration_outlined,
//                 'Registration Fee: Rs ${cls.registrationFee!.toStringAsFixed(0)}'),
//           if (cls.monthlyFee != null)
//             _detailRow(Icons.date_range_outlined,
//                 'Monthly Fee: Rs ${cls.monthlyFee!.toStringAsFixed(0)}'),
//
//           // ── Class subjects with marks ──
//           if (cls.subjects != null && cls.subjects!.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Icon(Icons.book, size: 18, color: Colors.grey),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Subjects & Marks:',
//                           style: TextStyle(fontWeight: FontWeight.w600,
//                               fontSize: 13)),
//                       const SizedBox(height: 4),
//                       Wrap(
//                         spacing: 6,
//                         runSpacing: 4,
//                         children: cls.subjects!.map((s) => Chip(
//                           label: Text(
//                             '${s.name}  •  ${s.totalMarks} pts',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           backgroundColor: const Color(0xFFEEECFB),
//                           labelStyle:
//                           const TextStyle(color: Color(0xFF534AB7)),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 6, vertical: 2),
//                           materialTapTargetSize:
//                           MaterialTapTargetSize.shrinkWrap,
//                         )).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//
//           const SizedBox(height: 8),
//
//           // ── Class timetable ──
//           if (cls.timetable != null && cls.timetable!.isNotEmpty) ...[
//             Text('Class Timetable:',
//                 style: Theme.of(context).textTheme.titleSmall),
//             const SizedBox(height: 4),
//             _buildTimetablePreview(cls.timetable!),
//           ],
//
//           // ── Sections ──
//           if (cls.sections != null && cls.sections!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Text('Sections:',
//                 style: Theme.of(context).textTheme.titleSmall),
//             const SizedBox(height: 4),
//             ...cls.sections!.map((section) => Card(
//               elevation: 0,
//               color: Colors.grey.shade50,
//               margin: const EdgeInsets.only(bottom: 8),
//               child: Padding(
//                 padding: const EdgeInsets.all(8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(section.sectionName,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold)),
//                     if (section.headOfTeacher != null &&
//                         section.headOfTeacher!.isNotEmpty)
//                       Text('Head: ${section.headOfTeacher}'),
//                     if (section.annualFee != null)
//                       Text(
//                           'Annual: Rs ${section.annualFee!.toStringAsFixed(0)}'),
//                     if (section.registrationFee != null)
//                       Text(
//                           'Reg: Rs ${section.registrationFee!.toStringAsFixed(0)}'),
//                     if (section.monthlyFee != null)
//                       Text(
//                           'Monthly: Rs ${section.monthlyFee!.toStringAsFixed(0)}'),
//
//                     // ── Section subjects with marks ──
//                     if (section.subjectMarks != null &&
//                         section.subjectMarks!.isNotEmpty) ...[
//                       const SizedBox(height: 6),
//                       const Text('Subjects & Marks:',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12)),
//                       const SizedBox(height: 4),
//                       Wrap(
//                         spacing: 6,
//                         runSpacing: 4,
//                         children:
//                         section.subjectMarks!.map((s) => Chip(
//                           label: Text(
//                             '${s.name}  •  ${s.totalMarks} pts',
//                             style: const TextStyle(fontSize: 11),
//                           ),
//                           backgroundColor:
//                           Colors.blue.shade50,
//                           labelStyle: TextStyle(
//                               color: Colors.blue.shade700),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 4, vertical: 0),
//                           materialTapTargetSize:
//                           MaterialTapTargetSize.shrinkWrap,
//                         )).toList(),
//                       ),
//                     ],
//
//                     // ── Section timetable ──
//                     if (section.timetable != null &&
//                         section.timetable!.isNotEmpty) ...[
//                       const SizedBox(height: 4),
//                       const Text('Timetable:',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600)),
//                       _buildTimetablePreview(section.timetable!),
//                     ],
//                   ],
//                 ),
//               ),
//             )),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTimetablePreview(List<TimetableDay> timetable) {
//     return Column(
//       children: timetable
//           .map((day) => ListTile(
//         dense: true,
//         contentPadding: EdgeInsets.zero,
//         leading: const Icon(Icons.today, size: 20),
//         title: Text(day.day,
//             style: const TextStyle(fontWeight: FontWeight.w500)),
//         subtitle: Text(
//           day.periods.map((p) {
//             if (p.isLunchBreak)
//               return '🍽 ${p.startTime} - ${p.endTime} (Lunch)';
//             return '📚 ${p.startTime} - ${p.endTime}'
//                 '${p.subject != null && p.subject!.isNotEmpty ? " (${p.subject})" : ""}';
//           }).join(' | '),
//           style: const TextStyle(fontSize: 13),
//         ),
//       ))
//           .toList(),
//     );
//   }
//
//   Widget _detailRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.grey),
//           const SizedBox(width: 8),
//           Expanded(child: Text(text)),
//         ],
//       ),
//     );
//   }
//
//   // ── Delete with staff-assignment guard ──
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
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(Icons.warning_amber_rounded,
//                     color: Colors.orange.shade700, size: 20),
//               ),
//               const SizedBox(width: 10),
//               const Expanded(
//                 child:
//                 Text('Cannot Delete', style: TextStyle(fontSize: 15)),
//               ),
//             ],
//           ),
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
//                       text: cls.name,
//                       style:
//                       const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const TextSpan(
//                         text:
//                         '" is assigned to the following staff/teachers. Remove the class from them first:'),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ...assignedTo.map(
//                     (name) => Padding(
//                   padding: const EdgeInsets.only(left: 8, bottom: 4),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.person_outline,
//                           size: 14, color: Color(0xFF534AB7)),
//                       const SizedBox(width: 6),
//                       Text(name, style: const TextStyle(fontSize: 13)),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             FilledButton(
//               onPressed: () => Navigator.pop(context),
//               style: FilledButton.styleFrom(
//                   backgroundColor: const Color(0xFF534AB7)),
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
//         title: const Text('Delete Class'),
//         content: Text('Are you sure you want to delete ${cls.name}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child:
//             const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       try {
//         await context.read<ClassProvider>().deleteClass(cls.id!, cls.name);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Delete failed: $e'),
//               backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
// }
//


//2nd code
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7FA),
//       appBar: widget.showAppBar
//           ? AppBar(
//         title: const Text(
//           'Classes',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//         ),
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
//       floatingActionButton: widget.showFAB
//           ? FloatingActionButton(
//         backgroundColor: _kPurple,
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16)),
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => const AddEditClassScreen()),
//           );
//           // Provider auto-refreshes via stream/listener
//         },
//         child: const Icon(Icons.add),
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
//           if (provider.classes.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 64,
//                     height: 64,
//                     decoration: BoxDecoration(
//                       color: _kPurpleLight,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: const Icon(Icons.class_outlined,
//                         size: 32, color: _kPurple),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text('No classes yet',
//                       style: TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 6),
//                   Text('Tap + to add your first class',
//                       style: TextStyle(
//                           fontSize: 13, color: Colors.grey.shade500)),
//                 ],
//               ),
//             );
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
//             itemCount: provider.classes.length,
//             itemBuilder: (context, index) {
//               return _ClassCard(schoolClass: provider.classes[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// // ─── Class Card ───────────────────────────────────────────
// class _ClassCard extends StatefulWidget {
//   final SchoolClass schoolClass;
//   const _ClassCard({required this.schoolClass});
//
//   @override
//   State<_ClassCard> createState() => _ClassCardState();
// }
//
// class _ClassCardState extends State<_ClassCard> {
//   bool _expanded = false;
//
//   String _avatarText(String name) {
//     final parts = name.trim().split(RegExp(r'\s+'));
//     if (parts.isEmpty) return '?';
//     if (parts.length == 1) return parts[0][0].toUpperCase();
//     return parts[0][0].toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cls = widget.schoolClass;
//     final sectionCount = cls.sections?.length ?? 0;
//     final subjectCount = cls.sections?.isNotEmpty == true
//         ? (cls.sections!.first.subjectMarks?.length ?? 0)
//         : (cls.subjects?.length ?? 0);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _expanded
//               ? const Color(0xFFAFA9EC)
//               : Colors.grey.shade200,
//           width: _expanded ? 1.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Header row ──
//           InkWell(
//             onTap: () => setState(() => _expanded = !_expanded),
//             borderRadius: BorderRadius.circular(16),
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
//               child: Row(children: [
//                 // Avatar
//                 Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: _kPurpleLight,
//                     borderRadius: BorderRadius.circular(11),
//                   ),
//                   child: Center(
//                     child: Text(
//                       _avatarText(cls.name),
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w800,
//                         color: _kPurple,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // Title + badges
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         cls.name,
//                         style: const TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF1A1A2E),
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       Row(children: [
//                         if (sectionCount > 0)
//                           _badge(
//                             '$sectionCount section${sectionCount != 1 ? 's' : ''}',
//                             _kPurpleLight,
//                             _kPurple,
//                           ),
//                         if (sectionCount > 0 && subjectCount > 0)
//                           const SizedBox(width: 6),
//                         if (subjectCount > 0)
//                           _badge(
//                             '$subjectCount subject${subjectCount != 1 ? 's' : ''}',
//                             const Color(0xFFE8F5E9),
//                             const Color(0xFF2E7D32),
//                           ),
//                       ]),
//                     ],
//                   ),
//                 ),
//                 // Edit button
//                 _iconBtn(
//                   Icons.edit_outlined,
//                   Colors.grey.shade600,
//                       () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           AddEditClassScreen(existingClass: cls),
//                     ),
//                   ),
//                 ),
//                 // Delete button
//                 _iconBtn(
//                   Icons.delete_outline,
//                   Colors.red.shade400,
//                       () => _confirmDelete(context, cls),
//                 ),
//                 const SizedBox(width: 4),
//                 AnimatedRotation(
//                   turns: _expanded ? 0.5 : 0,
//                   duration: const Duration(milliseconds: 200),
//                   child: Icon(Icons.keyboard_arrow_down,
//                       color: Colors.grey.shade400, size: 20),
//                 ),
//               ]),
//             ),
//           ),
//
//           // ── Expanded body ──
//           AnimatedCrossFade(
//             duration: const Duration(milliseconds: 250),
//             crossFadeState: _expanded
//                 ? CrossFadeState.showSecond
//                 : CrossFadeState.showFirst,
//             firstChild: const SizedBox.shrink(),
//             secondChild: _buildExpandedBody(cls),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildExpandedBody(SchoolClass cls) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(top: BorderSide(color: Colors.grey.shade100)),
//       ),
//       padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Class-level fees / teacher (if any)
//           if (cls.headOfClassTeacher != null &&
//               cls.headOfClassTeacher!.isNotEmpty)
//             _detailRow(Icons.person_outline, cls.headOfClassTeacher!),
//           if (cls.annualFee != null)
//             _detailRow(Icons.calendar_today_outlined,
//                 'Annual fee: Rs ${cls.annualFee!.toStringAsFixed(0)}'),
//           if (cls.registrationFee != null)
//             _detailRow(Icons.app_registration_outlined,
//                 'Registration: Rs ${cls.registrationFee!.toStringAsFixed(0)}'),
//           if (cls.monthlyFee != null)
//             _detailRow(Icons.date_range_outlined,
//                 'Monthly: Rs ${cls.monthlyFee!.toStringAsFixed(0)}'),
//
//           // Sections
//           if (cls.sections != null && cls.sections!.isNotEmpty) ...[
//             const SizedBox(height: 4),
//             ...cls.sections!.map((section) => _buildSectionTile(section)),
//           ] else ...[
//             // Fallback: class-level subjects
//             if (cls.subjects != null && cls.subjects!.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               _subjectsChips(cls.subjects!,
//                   background: _kPurpleLight, textColor: _kPurple),
//             ],
//             if (cls.timetable != null && cls.timetable!.isNotEmpty)
//               _timetablePreview(cls.timetable!),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionTile(Section section) {
//     return Container(
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F8FB),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFEDE8FF)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             section.sectionName,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: _kPurple,
//             ),
//           ),
//           if (section.headOfTeacher != null &&
//               section.headOfTeacher!.isNotEmpty) ...[
//             const SizedBox(height: 4),
//             _detailRow(Icons.person_outline, section.headOfTeacher!,
//                 size: 12),
//           ],
//           if (section.annualFee != null ||
//               section.registrationFee != null ||
//               section.monthlyFee != null) ...[
//             const SizedBox(height: 2),
//             Row(children: [
//               if (section.monthlyFee != null)
//                 _inlineChip(
//                     'Monthly: Rs ${section.monthlyFee!.toStringAsFixed(0)}',
//                     const Color(0xFFE8F5E9),
//                     const Color(0xFF2E7D32)),
//               if (section.annualFee != null) ...[
//                 const SizedBox(width: 6),
//                 _inlineChip(
//                     'Annual: Rs ${section.annualFee!.toStringAsFixed(0)}',
//                     const Color(0xFFFFF3E0),
//                     const Color(0xFFE65100)),
//               ],
//             ]),
//           ],
//           if (section.subjectMarks != null &&
//               section.subjectMarks!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             _subjectsChips(section.subjectMarks!,
//                 background: _kPurpleLight, textColor: _kPurple),
//           ],
//           if (section.timetable != null &&
//               section.timetable!.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             _timetablePreview(section.timetable!),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _subjectsChips(
//       List<SubjectMark> subjects, {
//         required Color background,
//         required Color textColor,
//       }) {
//     return Wrap(
//       spacing: 6,
//       runSpacing: 4,
//       children: subjects
//           .map((s) => Container(
//         padding: const EdgeInsets.symmetric(
//             horizontal: 8, vertical: 3),
//         decoration: BoxDecoration(
//           color: background,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           '${s.name}  •  ${s.totalMarks} pts',
//           style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: textColor),
//         ),
//       ))
//           .toList(),
//     );
//   }
//
//   Widget _timetablePreview(List<TimetableDay> timetable) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 6, bottom: 4),
//           child: Row(children: [
//             Icon(Icons.schedule_outlined,
//                 size: 13, color: Colors.grey.shade500),
//             const SizedBox(width: 4),
//             Text('Timetable',
//                 style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade600)),
//           ]),
//         ),
//         ...timetable.map((day) => Padding(
//           padding: const EdgeInsets.only(bottom: 2),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: 80,
//                 child: Text(day.day,
//                     style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: _kPurple)),
//               ),
//               Expanded(
//                 child: Text(
//                   day.periods.map((p) {
//                     if (p.isLunchBreak) {
//                       return '${p.startTime}–${p.endTime} Lunch';
//                     }
//                     final sub = p.subject != null &&
//                         p.subject!.isNotEmpty
//                         ? ' (${p.subject})'
//                         : '';
//                     return '${p.startTime}–${p.endTime}$sub';
//                   }).join('  '),
//                   style: TextStyle(
//                       fontSize: 11, color: Colors.grey.shade600),
//                 ),
//               ),
//             ],
//           ),
//         )),
//       ],
//     );
//   }
//
//   Widget _badge(String label, Color bg, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: textColor)),
//     );
//   }
//
//   Widget _inlineChip(String label, Color bg, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: textColor)),
//     );
//   }
//
//   Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
//     return IconButton(
//       icon: Icon(icon, size: 19, color: color),
//       onPressed: onTap,
//       padding: const EdgeInsets.all(6),
//       constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
//       splashRadius: 18,
//     );
//   }
//
//   Widget _detailRow(IconData icon, String text, {double size = 13}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 3),
//       child: Row(children: [
//         Icon(icon, size: 14, color: Colors.grey.shade500),
//         const SizedBox(width: 6),
//         Expanded(
//           child: Text(text,
//               style: TextStyle(fontSize: size, color: Colors.grey.shade700)),
//         ),
//       ]),
//     );
//   }
//
//   // ── Delete Guard ────────────────────────────────────────
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
//                         text:
//                         '" is assigned to staff. Remove the class from them first:'),
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
//               style: FilledButton.styleFrom(
//                   backgroundColor: _kPurple),
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


//3rd Code
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
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.w700)),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         surfaceTintColor: Colors.white,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child:
//           Container(height: 1, color: Colors.grey.shade200),
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
//           // Flatten: class + each section = one row
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
//           return Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: _buildTable(context, filtered, provider),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   List<_ClassRow> _buildRows(List<SchoolClass> classes) {
//     final rows = <_ClassRow>[];
//     for (final cls in classes) {
//       if (cls.sections != null && cls.sections!.isNotEmpty) {
//         for (final sec in cls.sections!) {
//           // Extract section suffix (remove class name prefix)
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
//   Widget _buildTable(BuildContext context, List<_ClassRow> filtered,
//       ClassProvider provider) {
//     final totalPages =
//     (_filtered(filtered).length / _perPage).ceil().clamp(1, 999);
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
//           // ── Top bar ──
//           _buildTopBar(context, filtered.length),
//           // ── Toolbar: search + show entries ──
//           _buildToolbar(),
//           // ── Table ──
//           _buildTableContent(context, pageRows, provider),
//           // ── Footer: pagination ──
//           _buildFooter(filtered.length, start, pageRows.length, totalPages),
//         ],
//       ),
//     );
//   }
//
//   List<_ClassRow> _filtered(List<_ClassRow> rows) => rows;
//
//   Widget _buildTopBar(BuildContext context, int count) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
//       decoration: BoxDecoration(
//         border:
//         Border(bottom: BorderSide(color: Colors.grey.shade100)),
//       ),
//       child: Row(children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Classes',
//                   style: TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.w700)),
//               Text('$count ${count == 1 ? 'class' : 'entries'} found',
//                   style: TextStyle(
//                       fontSize: 12, color: Colors.grey.shade500)),
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
//             textStyle: const TextStyle(
//                 fontSize: 13, fontWeight: FontWeight.w600),
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
//         // Show entries
//         Text('Show',
//             style:
//             TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
//               style: const TextStyle(fontSize: 13, color: Colors.black87),
//               items: [5, 10, 25, 50]
//                   .map((v) => DropdownMenuItem(
//                   value: v, child: Text('$v')))
//                   .toList(),
//               onChanged: (v) =>
//                   setState(() {
//                     _perPage = v!;
//                     _currentPage = 1;
//                   }),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text('entries',
//             style:
//             TextStyle(fontSize: 13, color: Colors.grey.shade600)),
//         const Spacer(),
//         // Search
//         SizedBox(
//           width: 220,
//           child: TextField(
//             controller: _searchController,
//             onChanged: (v) =>
//                 setState(() {
//                   _searchQuery = v;
//                   _currentPage = 1;
//                 }),
//             style: const TextStyle(fontSize: 13),
//             decoration: InputDecoration(
//               hintText: 'Search class, section...',
//               hintStyle: TextStyle(
//                   fontSize: 13, color: Colors.grey.shade400),
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
//                 borderSide:
//                 const BorderSide(color: _kPurple, width: 1.5),
//               ),
//               isDense: true,
//               contentPadding:
//               const EdgeInsets.symmetric(vertical: 10),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
//
//   Widget _buildTableContent(BuildContext context,
//       List<_ClassRow> rows, ClassProvider provider) {
//     if (rows.isEmpty) {
//       return
//         Padding(
//         padding: const EdgeInsets.symmetric(vertical: 48),
//         child: Center(
//           child: Column(children: [
//             Icon(Icons.search_off,
//                 size: 36, color: Colors.grey.shade300),
//             const SizedBox(height: 10),
//             Text('No classes match your search',
//                 style: TextStyle(
//                     fontSize: 13, color: Colors.grey.shade400)),
//           ]),
//         ),
//       );
//     }
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//             minWidth: MediaQuery.of(context).size.width - 32),
//         child: Table(
//           columnWidths: const {
//             0: FixedColumnWidth(42),
//             1: FlexColumnWidth(2.5),
//             2: FixedColumnWidth(80),
//             3: FlexColumnWidth(2.5),
//             4: FixedColumnWidth(80),
//             5: FlexColumnWidth(1.8),
//             6: FixedColumnWidth(80),          },
//           children: [
//             // Header
//             TableRow(
//               decoration:
//               const BoxDecoration(color: Color(0xFFF8F8FF)),
//               children: [
//                 _th('#'),
//                 _th('Class'),
//                 _th('Section'),
//                 _th('Head teacher'),
//                 _th('Subjects'),
//                 _th('Fee'),
//                 _thCenter('Action'),
//               ],
//             ),
//             // Rows
//             ...rows.asMap().entries.map((entry) {
//               final idx = entry.key;
//               final row = entry.value;
//               final isEven = idx.isEven;
//               return TableRow(
//                 decoration: BoxDecoration(
//                   color: isEven
//                       ? Colors.white
//                       : const Color(0xFFFCFCFF),
//                   border: Border(
//                       bottom: BorderSide(
//                           color: Colors.grey.shade100)),
//                 ),
//                 children: [
//                   // # number
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 14, horizontal: 14),
//                     child: Text(
//                       '${(_currentPage - 1) * _perPage + idx + 1}',
//                       style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade400),
//                     ),
//                   ),
//                   // Class
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 8),
//                     child: Row(children: [
//                       Container(
//                         width: 28,
//                         height: 28,
//                         decoration: BoxDecoration(
//                           color: _kPurpleLight,
//                           borderRadius: BorderRadius.circular(7),
//                         ),
//                         child: Center(
//                           child: Text(
//                             row.className.trim().isEmpty
//                                 ? '?'
//                                 : row.className
//                                 .trim()[0]
//                                 .toUpperCase(),
//                             style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w800,
//                                 color: _kPurple),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Flexible(
//                         child: Text(
//                           row.className,
//                           style: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF1A1A2E)),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ]),
//                   ),
//                   // Section
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 14, horizontal: 8),
//                     child: Container(
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
//                   ),
//                   // Head teacher
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 8),
//                     child: row.headTeacher != null &&
//                         row.headTeacher!.isNotEmpty
//                         ? Row(children: [
//                       _miniAvatar(row.headTeacher!),
//                       const SizedBox(width: 7),
//                       Flexible(
//                         child: Text(
//                           row.headTeacher!,
//                           style: const TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF444444)),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ])
//                         : Text('—',
//                         style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey.shade300)),
//                   ),
//                   // Subjects
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 14, horizontal: 8),
//                     child: Container(
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
//                   ),
//                   // Fee
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 8),
//                     child: row.monthlyFee != null
//                         ? Column(
//                       crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Rs ${row.monthlyFee!.toStringAsFixed(0)}/mo',
//                           style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF2E7D32)),
//                         ),
//                         if (row.annualFee != null)
//                           Text(
//                             'Annual: Rs ${row.annualFee!.toStringAsFixed(0)}',
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 color:
//                                 Colors.grey.shade400),
//                           ),
//                       ],
//                     )
//                         : Text('—',
//                         style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey.shade300)),
//                   ),
//                   // Actions
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 8),
//                     child: Wrap(
//                       alignment: WrapAlignment.center,
//                       spacing: 4,
//                       children: [
//                         _actionBtn(
//                           icon: Icons.edit_outlined,
//                           color: Colors.grey.shade600,
//                           onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => AddEditClassScreen(
//                                   existingClass: row.schoolClass),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         _actionBtn(
//                           icon: Icons.delete_outline,
//                           color: Colors.red.shade400,
//                           onTap: () => _confirmDelete(
//                               context, row.schoolClass),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFooter(
//       int total, int start, int pageCount, int totalPages) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFAFAFA),
//         border: Border(top: BorderSide(color: Colors.grey.shade100)),
//         borderRadius:
//         const BorderRadius.vertical(bottom: Radius.circular(16)),
//       ),
//       child: Row(children: [
//         Text(
//           total == 0
//               ? 'No entries'
//               : 'Showing ${start + 1}–${start + pageCount} of $total entries',
//           style:
//           TextStyle(fontSize: 12, color: Colors.grey.shade500),
//         ),
//         const Spacer(),
//         // Pagination
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
//   // ── Helper widgets ──────────────────────────
//
//   Widget _th(String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//           vertical: 11, horizontal: 8),
//       child: Text(
//         label.toUpperCase(),
//         style: const TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w700,
//             color: _kPurple,
//             letterSpacing: 0.5),
//       ),
//     );
//   }
//
//   Widget _thCenter(String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//           vertical: 11, horizontal: 8),
//       child: Center(
//         child: Text(
//           label.toUpperCase(),
//           style: const TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w700,
//               color: _kPurple,
//               letterSpacing: 0.5),
//         ),
//       ),
//     );
//   }
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
//   Widget _pgBtn(String label, VoidCallback onTap,
//       {bool active = false}) {
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
//           border: Border.all(
//               color: active ? _kPurple : Colors.grey.shade200),
//         ),
//         child: Center(
//           child: Text(label,
//               style: TextStyle(
//                   fontSize: 13,
//                   fontWeight:
//                   active ? FontWeight.w700 : FontWeight.w400,
//                   color: active ? Colors.white : Colors.grey.shade600)),
//         ),
//       ),
//     );
//   }
//
//   // ── Delete guard ─────────────────────────────
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
//                         text:
//                         '" is assigned to staff. Remove it first:'),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ...assignedTo.map((name) => Padding(
//                 padding:
//                 const EdgeInsets.only(left: 8, bottom: 4),
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
//               style: FilledButton.styleFrom(
//                   backgroundColor: _kPurple),
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
// // ── Data model for table row ──────────────────
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
      body: Consumer<ClassProvider>(
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