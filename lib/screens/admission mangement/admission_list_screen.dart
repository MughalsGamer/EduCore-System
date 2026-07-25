//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/admission_model.dart';
// import '../../providers/admission_provider.dart';
// import 'add_admission_screen.dart';
//
// class AdmissionListScreen extends StatefulWidget {
//   final bool showAppBar;
//   final bool showFAB;
//
//   const AdmissionListScreen({
//     super.key,
//     this.showAppBar = true,
//     this.showFAB = true,
//   });
//
//   @override
//   State<AdmissionListScreen> createState() => _AdmissionListScreenState();
// }
//
// class _AdmissionListScreenState extends State<AdmissionListScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   static const _purple = Color(0xFF534AB7);
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(() {
//       if (!_tabController.indexIsChanging) {
//         final provider = context.read<AdmissionProvider>();
//         switch (_tabController.index) {
//           case 0:
//             provider.setFilter(null);
//             break;
//           case 1:
//             provider.setFilter(AdmissionType.preAdmission);
//             break;
//           case 2:
//             provider.setFilter(AdmissionType.regular);
//             break;
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   // ── Public helper to switch tab from the outside ──
//   void switchTab(AdmissionType type) {
//     _switchTab(type);
//   }
//
//   void _switchTab(AdmissionType type) {
//     final targetIndex = type == AdmissionType.preAdmission ? 1 : 2;
//     if (_tabController.index != targetIndex) {
//       _tabController.animateTo(targetIndex);
//     } else {
//       // Already on the correct tab – just force a refresh
//       context.read<AdmissionProvider>().refresh();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admissions'),
//         centerTitle: true,
//         elevation: 0,
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: _purple,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: _purple,
//           tabs: const [
//             Tab(text: 'All'),
//             Tab(text: 'Pre-Admission'),
//             Tab(text: 'Regular'),
//           ],
//         ),
//       ),
//       // ─────────── CHANGED FAB ───────────
//       floatingActionButton: widget.showFAB
//           ? FloatingActionButton.extended(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AdmissionFormScreen()),
//           );
//           if (result is AdmissionType && context.mounted) {
//             _switchTab(result);
//           }
//         },
//         backgroundColor: _purple,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text('New', style: TextStyle(color: Colors.white)),
//       )
//           : null,
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: () async {
//       //     final result = await Navigator.push(
//       //       context,
//       //       MaterialPageRoute(builder: (_) => const AdmissionFormScreen()),
//       //     );
//       //     // result is either null (cancelled) or an AdmissionType (saved)
//       //     if (result is AdmissionType && context.mounted) {
//       //       _switchTab(result);
//       //     }
//       //   },
//       //   backgroundColor: _purple,
//       //   icon: const Icon(Icons.add, color: Colors.white),
//       //   label: const Text('New', style: TextStyle(color: Colors.white)),
//       // ),
//       // ───────────────────────────────────
//       body: Consumer<AdmissionProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading && provider.admissions.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (provider.error != null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error: ${provider.error}'),
//                   ElevatedButton(
//                     onPressed: provider.clearError,
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//           if (provider.admissions.isEmpty) {
//             return _buildEmpty();
//           }
//           return TabBarView(
//             controller: _tabController,
//             children: [
//               _buildList(provider.admissions),
//               _buildList(provider.admissions
//                   .where((a) => a.type == AdmissionType.preAdmission)
//                   .toList()),
//               _buildList(provider.admissions
//                   .where((a) => a.type == AdmissionType.regular)
//                   .toList()),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
//           const SizedBox(height: 16),
//           Text('No admissions yet',
//               style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
//           if (widget.showFAB) ...[    // ← यही condition add की है
//             const SizedBox(height: 8),
//             ElevatedButton.icon(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AdmissionFormScreen()),
//               ),
//               icon: const Icon(Icons.add),
//               label: const Text('Add Admission'),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: _purple, foregroundColor: Colors.white),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildList(List<AdmissionModel> admissions) {
//     if (admissions.isEmpty) {
//       return Center(
//           child: Text('No records found',
//               style: TextStyle(color: Colors.grey.shade500, fontSize: 14)));
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: admissions.length,
//       itemBuilder: (context, i) => _AdmissionCard(
//         key: ValueKey(admissions[i].id),   // for smooth widget recycling
//         admission: admissions[i],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Admission Card
// // ─────────────────────────────────────────────
// class _AdmissionCard extends StatefulWidget {
//   final AdmissionModel admission;
//   const _AdmissionCard({required this.admission, Key? key}) : super(key: key);
//
//   @override
//   State<_AdmissionCard> createState() => _AdmissionCardState();
// }
//
// class _AdmissionCardState extends State<_AdmissionCard> {
//   bool _expanded = false;
//   bool _converting = false;
//   static const _purple = Color(0xFF534AB7);
//
//   // Helper to find the list screen's state
//   _AdmissionListScreenState? _findListScreenState() {
//     return context.findAncestorStateOfType<_AdmissionListScreenState>();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final a = widget.admission;
//     final isPre = a.type == AdmissionType.preAdmission;
//     final typeColor = isPre ? Colors.orange : Colors.green;
//     final dateStr =
//         '${a.admissionDate.day.toString().padLeft(2, '0')}/${a.admissionDate.month.toString().padLeft(2, '0')}/${a.admissionDate.year}';
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 2,
//       child: Column(
//         children: [
//           InkWell(
//             onTap: () => setState(() => _expanded = !_expanded),
//             borderRadius: BorderRadius.circular(14),
//             child: Padding(
//               padding: const EdgeInsets.all(14),
//               child: Row(
//                 children: [
//                   Container(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: typeColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: typeColor),
//                     ),
//                     child: Text(
//                       isPre ? 'Pre' : 'Reg',
//                       style: TextStyle(
//                           fontSize: 11,
//                           color: typeColor,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           a.fatherName.isNotEmpty
//                               ? a.fatherName
//                               : 'Family: ${a.familyName}',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 15),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           '${a.inquiryOrRegId} • $dateStr',
//                           style: TextStyle(
//                               fontSize: 12, color: Colors.grey.shade600),
//                         ),
//                         Text(
//                           '${a.students.length} student(s)',
//                           style: TextStyle(
//                               fontSize: 12, color: Colors.grey.shade500),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // ─────────── CHANGED EDIT BUTTON ───────────
//                   IconButton(
//                     icon: const Icon(Icons.edit_outlined, size: 20),
//                     color: _purple,
//                     onPressed: () async {
//                       final result = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => AdmissionFormScreen(existing: a),
//                         ),
//                       );
//                       if (result is AdmissionType && context.mounted) {
//                         _findListScreenState()?.switchTab(result);
//                       }
//                     },
//                   ),
//                   // ────────────────────────────────────────────
//                   IconButton(
//                     icon: const Icon(Icons.delete_outline,
//                         size: 20, color: Colors.red),
//                     onPressed: () => _confirmDelete(context, a),
//                   ),
//                   if (isPre)
//                     IconButton(
//                       icon: _converting
//                           ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.orange,
//                         ),
//                       )
//                           : const Icon(Icons.swap_horiz, size: 20),
//                       color: Colors.orange,
//                       tooltip: 'Convert to Regular Admission',
//                       onPressed:
//                       _converting ? null : () => _confirmConvert(context, a),
//                     ),
//                   AnimatedRotation(
//                     turns: _expanded ? 0.5 : 0,
//                     duration: const Duration(milliseconds: 250),
//                     child: const Icon(Icons.expand_more),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedSize(
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeInOut,
//             child: _expanded
//                 ? _buildDetails(a)
//                 : const SizedBox(width: double.infinity, height: 0),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Details Section (unchanged) ──
//   Widget _buildDetails(AdmissionModel a) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Divider(),
//           if (a.familyId.isNotEmpty)
//             _row(Icons.family_restroom, 'Family ID', a.familyId),
//           if (a.familyName.isNotEmpty)
//             _row(Icons.group_outlined, 'Family Name', a.familyName),
//           const SizedBox(height: 6),
//           _sectionLabel('Father Details'),
//           _row(Icons.person, 'Name', a.fatherName),
//           if (a.fatherPhone.isNotEmpty)
//             _row(Icons.phone, 'Phone', a.fatherPhone),
//           if (a.fatherCnic != null && a.fatherCnic!.isNotEmpty)
//             _row(Icons.credit_card, 'CNIC', a.fatherCnic!),
//           if (a.fatherOccupation != null && a.fatherOccupation!.isNotEmpty)
//             _row(Icons.work_outline, 'Occupation', a.fatherOccupation!),
//           const SizedBox(height: 6),
//           _sectionLabel('Mother Details'),
//           if (a.motherName.isNotEmpty)
//             _row(Icons.person_outline, 'Name', a.motherName),
//           if (a.motherPhone != null && a.motherPhone!.isNotEmpty)
//             _row(Icons.phone_outlined, 'Phone', a.motherPhone!),
//           if (a.motherCnic != null && a.motherCnic!.isNotEmpty)
//             _row(Icons.credit_card_outlined, 'CNIC', a.motherCnic!),
//           if (a.caste != null && a.caste!.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             _row(Icons.diversity_3_outlined, 'Caste', a.caste!),
//           ],
//           if (a.address != null && a.address!.isNotEmpty)
//             _row(Icons.home_outlined, 'Address', a.address!),
//           if (a.previousSchoolName != null &&
//               a.previousSchoolName!.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             _sectionLabel('Previous School'),
//             _row(Icons.school_outlined, 'School', a.previousSchoolName!),
//             if (a.previousClassName != null &&
//                 a.previousClassName!.isNotEmpty)
//               _row(Icons.class_, 'Class', a.previousClassName!),
//             if (a.previousClassMarks != null &&
//                 a.previousClassMarks!.isNotEmpty)
//               _row(Icons.grade_outlined, 'Marks', a.previousClassMarks!),
//           ],
//           const SizedBox(height: 10),
//           _sectionLabel('Students (${a.students.length})'),
//           const SizedBox(height: 6),
//           ...a.students.map((s) => _buildStudentChip(s)),
//         ],
//       ),
//     );
//   }
//
//   // ── Student Chip (unchanged) ──
//   Widget _buildStudentChip(AdmissionStudent s) {
//     return Card(
//       elevation: 0,
//       color: Colors.grey.shade50,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       margin: const EdgeInsets.only(bottom: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _studentAvatar(s.picBase64),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     s.name.isNotEmpty ? s.name : '—',
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 14),
//                   ),
//                   const SizedBox(height: 4),
//                   if (s.studentId.isNotEmpty)
//                     _chip(Icons.fingerprint, 'ID: ${s.studentId}', Colors.purple),
//                   if (s.className != null && s.className!.isNotEmpty)
//                     _chip(
//                       Icons.class_,
//                       s.sectionName != null && s.sectionName!.isNotEmpty
//                           ? '${s.className} — ${s.sectionName}'
//                           : s.className!,
//                       Colors.blue,
//                     ),
//                   if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
//                     _chip(Icons.format_list_numbered, 'Roll No: ${s.classRollNo}', Colors.teal),
//                   if (s.bFormCnic != null && s.bFormCnic!.isNotEmpty)
//                     _chip(Icons.credit_card_outlined, 'B-Form: ${s.bFormCnic}', Colors.indigo),
//                   if (s.dob != null)
//                     _chip(
//                       Icons.cake_outlined,
//                       'DOB: ${s.dob!.day.toString().padLeft(2, '0')}/${s.dob!.month.toString().padLeft(2, '0')}/${s.dob!.year}',
//                       Colors.pink,
//                     ),
//                   if (s.monthlyFee != null || s.annualFee != null || s.registrationFee != null) ...[
//                     const SizedBox(height: 6),
//                     Wrap(
//                       spacing: 6,
//                       runSpacing: 4,
//                       children: [
//                         if (s.monthlyFee != null)
//                           _feeBadge('Monthly', s.monthlyFee!, Colors.green),
//                         if (s.annualFee != null)
//                           _feeBadge('Annual', s.annualFee!, Colors.orange),
//                         if (s.registrationFee != null)
//                           _feeBadge('Reg.', s.registrationFee!, Colors.purple),
//                       ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _studentAvatar(String? picBase64) {
//     if (picBase64 != null && picBase64.isNotEmpty) {
//       try {
//         return CircleAvatar(
//           radius: 26,
//           backgroundImage: MemoryImage(base64Decode(picBase64)),
//         );
//       } catch (_) {}
//     }
//     return CircleAvatar(
//       radius: 26,
//       backgroundColor: Colors.purple.shade50,
//       child: const Icon(Icons.person, size: 22, color: Color(0xFF534AB7)),
//     );
//   }
//
//   Widget _chip(IconData icon, String text, Color color) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 3),
//       child: Row(
//         children: [
//           Icon(icon, size: 13, color: color.withOpacity(0.7)),
//           const SizedBox(width: 4),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _feeBadge(String label, double amount, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         '$label: Rs ${amount.toStringAsFixed(0)}',
//         style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontWeight: FontWeight.w600),
//       ),
//     );
//   }
//
//   Widget _row(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 15, color: Colors.grey.shade500),
//           const SizedBox(width: 8),
//           Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
//           Expanded(
//             child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4, top: 2),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF534AB7), letterSpacing: 0.3),
//       ),
//     );
//   }
//
//   // ── Delete Confirm (unchanged) ──
//   void _confirmDelete(BuildContext context, AdmissionModel a) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Delete Admission'),
//         content: Text('Delete admission ${a.inquiryOrRegId} for ${a.fatherName}?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//           TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );
//     if (confirm == true && a.id != null) {
//       try {
//         await context.read<AdmissionProvider>().deleteAdmission(a.id!);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
//         _findListScreenState()?.switchTab(AdmissionType.regular);
//       }
//     }
//   }
//
//   // ✅ Convert Confirm with loading state and date picker
//   void _confirmConvert(BuildContext context, AdmissionModel a) async {
//     // 1. Pick registration date
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.fromSeed(seedColor: _purple),
//         ),
//         child: child!,
//       ),
//     );
//     if (pickedDate == null || !context.mounted) return;
//
//     // 2. Collect required student details
//     final updatedStudents = await showDialog<List<AdmissionStudent>>(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => _StudentDetailsDialog(students: a.students),
//     );
//     if (updatedStudents == null || !context.mounted) return; // user cancelled
//
//     // 3. Confirm the conversion
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Convert to Regular Admission'),
//         content: Text(
//           'This will create a new Regular Admission with date '
//               '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} '
//               'and delete this Pre-Admission record. Continue?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Convert', style: TextStyle(color: Colors.orange)),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true || !context.mounted) return;
//
//     // 4. Execute conversion
//     setState(() => _converting = true);
//     try {
//       await context.read<AdmissionProvider>().convertToRegular(
//         a,
//         customDate: pickedDate,
//         studentsOverride: updatedStudents,
//       );
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Converted to Regular Admission successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         _findListScreenState()?.switchTab(AdmissionType.regular);
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Conversion failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _converting = false);
//     }
//   }
//   // void _confirmConvert(BuildContext context, AdmissionModel a) async {
//   //   // 1. Pick registration date
//   //   final DateTime? pickedDate = await showDatePicker(
//   //     context: context,
//   //     initialDate: DateTime.now(),
//   //     firstDate: DateTime(2020),
//   //     lastDate: DateTime(2100),
//   //     builder: (context, child) => Theme(
//   //       data: Theme.of(context).copyWith(
//   //         colorScheme: ColorScheme.fromSeed(seedColor: _purple),
//   //       ),
//   //       child: child!,
//   //     ),
//   //   );
//   //   if (pickedDate == null || !context.mounted) return;
//   //
//   //   // 2. Collect required student details
//   //   final updatedStudents = await _showStudentDetailsDialog(a);
//   //   if (updatedStudents == null || !context.mounted) return; // user cancelled
//   //
//   //   // 3. Confirm the conversion
//   //   final confirmed = await showDialog<bool>(
//   //     context: context,
//   //     builder: (ctx) => AlertDialog(
//   //       title: const Text('Convert to Regular Admission'),
//   //       content: Text(
//   //         'This will create a new Regular Admission with date '
//   //             '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} '
//   //             'and delete this Pre-Admission record. Continue?',
//   //       ),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(ctx, false),
//   //           child: const Text('Cancel'),
//   //         ),
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(ctx, true),
//   //           child: const Text('Convert', style: TextStyle(color: Colors.orange)),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   //   if (confirmed != true || !context.mounted) return;
//   //
//   //   // 4. Execute conversion
//   //   setState(() => _converting = true);
//   //   try {
//   //     await context.read<AdmissionProvider>().convertToRegular(
//   //       a,
//   //       customDate: pickedDate,
//   //       studentsOverride: updatedStudents,   // pass the collected students
//   //     );
//   //     if (context.mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Converted to Regular Admission successfully'),
//   //           backgroundColor: Colors.green,
//   //         ),
//   //       );
//   //       _findListScreenState()?.switchTab(AdmissionType.regular);
//   //     }
//   //   } catch (e) {
//   //     if (context.mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text('Conversion failed: $e'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //     }
//   //   } finally {
//   //     if (mounted) setState(() => _converting = false);
//   //   }
//   // }
//
//   Future<List<AdmissionStudent>?> _showStudentDetailsDialog(AdmissionModel a) async {
//     final students = a.students;
//     final formKey = GlobalKey<FormState>();
//
//     // Controllers and initial dates
//     final List<TextEditingController> cnicCtrls =
//     List.generate(students.length, (i) => TextEditingController(text: students[i].bFormCnic ?? ''));
//     final List<DateTime?> dobList = List.generate(students.length, (i) => students[i].dob);
//
//     return showDialog<List<AdmissionStudent>>(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: const Text('Student Details Required'),
//               content: SizedBox(
//                 width: double.maxFinite,
//                 child: Form(
//                   key: formKey,
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: students.length,
//                     itemBuilder: (context, i) {
//                       final s = students[i];
//                       return Card(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Student ${i + 1}: ${s.name}',
//                                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                               ),
//                               const SizedBox(height: 12),
//                               // B-Form / CNIC
//                               TextFormField(
//                                 controller: cnicCtrls[i],
//                                 decoration: const InputDecoration(
//                                   labelText: 'B-Form / CNIC *',
//                                   border: OutlineInputBorder(),
//                                   prefixIcon: Icon(Icons.credit_card_outlined),
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 validator: (v) =>
//                                 (v == null || v.trim().isEmpty) ? 'Required' : null,
//                               ),
//                               const SizedBox(height: 12),
//                               // Date of Birth
//                               InkWell(
//                                 onTap: () async {
//                                   final picked = await showDatePicker(
//                                     context: ctx,
//                                     initialDate: dobList[i] ?? DateTime(2015),
//                                     firstDate: DateTime(2000),
//                                     lastDate: DateTime.now(),
//                                   );
//                                   if (picked != null) {
//                                     setDialogState(() => dobList[i] = picked);
//                                   }
//                                 },
//                                 child: InputDecorator(
//                                   decoration: const InputDecoration(
//                                     labelText: 'Date of Birth *',
//                                     border: OutlineInputBorder(),
//                                     prefixIcon: Icon(Icons.cake_outlined),
//                                   ),
//                                   child: Text(
//                                     dobList[i] != null
//                                         ? '${dobList[i]!.day}/${dobList[i]!.month}/${dobList[i]!.year}'
//                                         : 'Select Date',
//                                     style: TextStyle(
//                                       color: dobList[i] != null ? Colors.black87 : Colors.grey,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // Show validation error if both fields are empty after first attempt
//                               // (validated at dialog submit time anyway)
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     // Dispose controllers before popping
//                     for (var c in cnicCtrls) c.dispose();
//                     Navigator.pop(ctx); // cancel -> null
//                   },
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (formKey.currentState!.validate()) {
//                       // All B-Forms filled; check DOBs
//                       final bool allDobFilled = dobList.every((d) => d != null);
//                       if (!allDobFilled) {
//                         ScaffoldMessenger.of(ctx).showSnackBar(
//                           const SnackBar(content: Text('Please select Date of Birth for all students')),
//                         );
//                         return;
//                       }
//
//                       // Build updated student list
//                       final updated = List<AdmissionStudent>.generate(students.length, (i) {
//                         return students[i].copyWith(
//                           bFormCnic: cnicCtrls[i].text.trim(),
//                           dob: dobList[i],
//                         );
//                       });
//
//                       // Dispose controllers before popping
//                       for (var c in cnicCtrls) c.dispose();
//                       Navigator.pop(ctx, updated);
//                     }
//                   },
//                   child: const Text('Next'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//   // void _confirmConvert(BuildContext context, AdmissionModel a) async {
//   //   // 1. Pick a registration date
//   //   final DateTime? pickedDate = await showDatePicker(
//   //     context: context,
//   //     initialDate: DateTime.now(),
//   //     firstDate: DateTime(2020),
//   //     lastDate: DateTime(2100),
//   //     builder: (context, child) {
//   //       return Theme(
//   //         data: Theme.of(context).copyWith(
//   //           colorScheme: ColorScheme.fromSeed(seedColor: _purple),
//   //         ),
//   //         child: child!,
//   //       );
//   //     },
//   //   );
//   //
//   //   if (pickedDate == null || !context.mounted) return;
//   //
//   //   // 2. Confirmation dialog
//   //   final confirmed = await showDialog<bool>(
//   //     context: context,
//   //     builder: (ctx) => AlertDialog(
//   //       title: const Text('Convert to Regular Admission'),
//   //       content: Text(
//   //         'This will create a new Regular Admission with date '
//   //             '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} '
//   //             'and delete this Pre-Admission record. Continue?',
//   //       ),
//   //       actions: [
//   //         TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
//   //         TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Convert', style: TextStyle(color: Colors.orange))),
//   //       ],
//   //     ),
//   //   );
//   //
//   //   if (confirmed != true || !context.mounted) return;
//   //
//   //   // ✅ Start loading
//   //   setState(() => _converting = true);
//   //
//   //   try {
//   //     await context.read<AdmissionProvider>().convertToRegular(a, customDate: pickedDate);
//   //     if (context.mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Converted to Regular Admission successfully'), backgroundColor: Colors.green),
//   //
//   //       );
//   //       _findListScreenState()?.switchTab(AdmissionType.regular);
//   //     }
//   //   } catch (e) {
//   //     if (context.mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Conversion failed: $e'), backgroundColor: Colors.red),
//   //       );
//   //     }
//   //   } finally {
//   //     // ✅ Stop loading
//   //     if (mounted) {
//   //       setState(() => _converting = false);
//   //     }
//   //   }
//   // }
//
// }
//
// class _StudentDetailsDialog extends StatefulWidget {
//   final List<AdmissionStudent> students;
//   const _StudentDetailsDialog({required this.students, Key? key}) : super(key: key);
//
//   @override
//   State<_StudentDetailsDialog> createState() => _StudentDetailsDialogState();
// }
//
// class _StudentDetailsDialogState extends State<_StudentDetailsDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late final List<TextEditingController> _cnicCtrls;
//   late final List<DateTime?> _dobList;
//
//   @override
//   void initState() {
//     super.initState();
//     _cnicCtrls = List.generate(
//       widget.students.length,
//           (i) => TextEditingController(text: widget.students[i].bFormCnic ?? ''),
//     );
//     _dobList = List.generate(
//       widget.students.length,
//           (i) => widget.students[i].dob,
//     );
//   }
//
//   @override
//   void dispose() {
//     for (final c in _cnicCtrls) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   void _submit() {
//     if (!_formKey.currentState!.validate()) return;
//
//     final allDobFilled = _dobList.every((d) => d != null);
//     if (!allDobFilled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select Date of Birth for all students')),
//       );
//       return;
//     }
//
//     final updated = List<AdmissionStudent>.generate(widget.students.length, (i) {
//       return widget.students[i].copyWith(
//         bFormCnic: _cnicCtrls[i].text.trim(),
//         dob: _dobList[i],
//       );
//     });
//
//     Navigator.pop(context, updated);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Student Details Required'),
//       content: SizedBox(
//         width: double.maxFinite,
//         height: MediaQuery.of(context).size.height * 0.6,
//         child: Form(
//           key: _formKey,
//           child: ListView.builder(
//             shrinkWrap: true,
//             itemCount: widget.students.length,
//             itemBuilder: (context, i) {
//               final s = widget.students[i];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Student ${i + 1}: ${s.name}',
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                       ),
//                       const SizedBox(height: 12),
//                       // B-Form / CNIC
//                       TextFormField(
//                         controller: _cnicCtrls[i],
//                         decoration: const InputDecoration(
//                           labelText: 'B-Form / CNIC *',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.credit_card_outlined),
//                         ),
//                         keyboardType: TextInputType.number,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
//                       ),
//                       const SizedBox(height: 12),
//                       // Date of Birth
//                       InkWell(
//                         onTap: () async {
//                           final picked = await showDatePicker(
//                             context: context,
//                             initialDate: _dobList[i] ?? DateTime(2015),
//                             firstDate: DateTime(2000),
//                             lastDate: DateTime.now(),
//                           );
//                           if (picked != null) {
//                             setState(() => _dobList[i] = picked);
//                           }
//                         },
//                         child: InputDecorator(
//                           decoration: const InputDecoration(
//                             labelText: 'Date of Birth *',
//                             border: OutlineInputBorder(),
//                             prefixIcon: Icon(Icons.cake_outlined),
//                           ),
//                           child: Text(
//                             _dobList[i] != null
//                                 ? '${_dobList[i]!.day}/${_dobList[i]!.month}/${_dobList[i]!.year}'
//                                 : 'Select Date',
//                             style: TextStyle(
//                               color: _dobList[i] != null ? Colors.black87 : Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context), // cancel – returns null
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _submit,
//           child: const Text('Next'),
//         ),
//       ],
//     );
//   }
// }


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admission_model.dart';
import '../../providers/admission_provider.dart';
import 'add_admission_screen.dart';

class AdmissionListScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showFAB;

  const AdmissionListScreen({
    super.key,
    this.showAppBar = true,
    this.showFAB = true,
  });

  @override
  State<AdmissionListScreen> createState() => _AdmissionListScreenState();
}

class _AdmissionListScreenState extends State<AdmissionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _purple = Color(0xFF534AB7);

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final provider = context.read<AdmissionProvider>();
        switch (_tabController.index) {
          case 0:
            provider.setFilter(null);
            break;
          case 1:
            provider.setFilter(AdmissionType.preAdmission);
            break;
          case 2:
            provider.setFilter(AdmissionType.regular);
            break;
        }
      }
    });
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Public helper to switch tab from the outside ──
  void switchTab(AdmissionType type) {
    _switchTab(type);
  }

  void _switchTab(AdmissionType type) {
    final targetIndex = type == AdmissionType.preAdmission ? 1 : 2;
    if (_tabController.index != targetIndex) {
      _tabController.animateTo(targetIndex);
    } else {
      // Already on the correct tab – just force a refresh
      context.read<AdmissionProvider>().refresh();
    }
  }

  // ── Search matching ──────────────────────────────
  // Normalizes CNIC-like strings by stripping everything except digits, so
  // "34101-0134567-8" and "3410101345678" both match the same query.
  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  bool _matchesSearch(AdmissionModel a, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    final qDigits = _digitsOnly(query);
    final bool queryLooksNumeric = qDigits.isNotEmpty && qDigits.length == query.replaceAll(' ', '').length;

    bool textHit(String? v) =>
        v != null && v.toLowerCase().contains(q);

    bool cnicHit(String? v) {
      if (v == null || v.isEmpty || qDigits.isEmpty) return false;
      return _digitsOnly(v).contains(qDigits);
    }

    // Top-level admission / family / parent fields
    if (textHit(a.inquiryOrRegId)) return true;
    if (textHit(a.familyId)) return true;
    if (textHit(a.familyName)) return true;
    if (textHit(a.fatherName)) return true;
    if (textHit(a.motherName)) return true;
    if (textHit(a.fatherPhone)) return true;
    if (textHit(a.motherPhone)) return true;

    // CNIC fields — digit-normalized so dashes don't matter either way
    if (cnicHit(a.fatherCnic)) return true;
    if (cnicHit(a.motherCnic)) return true;
    // Phone numbers are also sensible to match digit-only (in case the
    // user types with or without dashes/spaces).
    if (queryLooksNumeric) {
      if (cnicHit(a.fatherPhone)) return true;
      if (cnicHit(a.motherPhone)) return true;
    }

    // Per-student fields
    for (final s in a.students) {
      if (textHit(s.name)) return true;
      if (textHit(s.studentId)) return true;
      if (textHit(s.className)) return true;
      if (cnicHit(s.bFormCnic)) return true;
    }

    return false;
  }

  List<AdmissionModel> _filtered(List<AdmissionModel> source) {
    if (_searchQuery.isEmpty) return source;
    return source.where((a) => _matchesSearch(a, _searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      appBar: AppBar(
        title: const Text('Admissions'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _purple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _purple,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pre-Admission'),
            Tab(text: 'Regular'),
          ],
        ),
      ),
      floatingActionButton: widget.showFAB
          ? FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdmissionFormScreen()),
          );
          if (result is AdmissionType && context.mounted) {
            _switchTab(result);
          }
        },
        backgroundColor: _purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New', style: TextStyle(color: Colors.white)),
      )
          : null,
      body: Consumer<AdmissionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.admissions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: provider.clearError,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildSearchBar(provider),
              if (provider.admissions.isEmpty)
                Expanded(child: _buildEmpty())
              else
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_filtered(provider.admissions)),
                      _buildList(_filtered(provider.admissions
                          .where((a) => a.type == AdmissionType.preAdmission)
                          .toList())),
                      _buildList(_filtered(provider.admissions
                          .where((a) => a.type == AdmissionType.regular)
                          .toList())),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Search Bar + quick stats row ──
  Widget _buildSearchBar(AdmissionProvider provider) {
    final total = provider.admissions.length;
    final preCount =
        provider.admissions.where((a) => a.type == AdmissionType.preAdmission).length;
    final regCount =
        provider.admissions.where((a) => a.type == AdmissionType.regular).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search name, ID, CNIC, class, phone…',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: Colors.grey.shade500),
                onPressed: () => _searchCtrl.clear(),
              )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF3F2F9),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _purple, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statChip('Total', total, _purple),
              const SizedBox(width: 8),
              _statChip('Pre-Admission', preCount, Colors.orange),
              const SizedBox(width: 8),
              _statChip('Regular', regCount, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, color: color.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final searching = _searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              searching ? Icons.search_off : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
              searching ? 'No admissions match "$_searchQuery"' : 'No admissions yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
          if (!searching && widget.showFAB) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdmissionFormScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Admission'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _purple, foregroundColor: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList(List<AdmissionModel> admissions) {
    if (admissions.isEmpty) {
      final searching = _searchQuery.isNotEmpty;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                searching ? Icons.search_off : Icons.inbox_outlined,
                size: 48,
                color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
                searching ? 'No matches in this tab' : 'No records found',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: admissions.length,
      itemBuilder: (context, i) => _AdmissionCard(
        key: ValueKey(admissions[i].id),   // for smooth widget recycling
        admission: admissions[i],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Admission Card
// ─────────────────────────────────────────────
class _AdmissionCard extends StatefulWidget {
  final AdmissionModel admission;
  const _AdmissionCard({required this.admission, Key? key}) : super(key: key);

  @override
  State<_AdmissionCard> createState() => _AdmissionCardState();
}

class _AdmissionCardState extends State<_AdmissionCard> {
  bool _expanded = false;
  bool _converting = false;
  static const _purple = Color(0xFF534AB7);

  // Helper to find the list screen's state
  _AdmissionListScreenState? _findListScreenState() {
    return context.findAncestorStateOfType<_AdmissionListScreenState>();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.admission;
    final isPre = a.type == AdmissionType.preAdmission;
    final typeColor = isPre ? Colors.orange : Colors.green;
    final dateStr =
        '${a.admissionDate.day.toString().padLeft(2, '0')}/${a.admissionDate.month.toString().padLeft(2, '0')}/${a.admissionDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _studentAvatar(
                    a.students.isNotEmpty ? a.students.first.picBase64 : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: typeColor),
                              ),
                              child: Text(
                                isPre ? 'Pre' : 'Reg',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    color: typeColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                a.fatherName.isNotEmpty
                                    ? a.fatherName
                                    : 'Family: ${a.familyName}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${a.inquiryOrRegId} • $dateStr',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          '${a.students.length} student(s)'
                              '${a.students.isNotEmpty && a.students.first.name.isNotEmpty ? " — ${a.students.map((s) => s.name).where((n) => n.isNotEmpty).join(", ")}" : ""}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdmissionFormScreen(existing: a),
                          ),
                        );
                        if (result is AdmissionType && context.mounted) {
                          _findListScreenState()?.switchTab(result);
                        }
                      } else if (value == 'delete') {
                        _confirmDelete(context, a);
                      } else if (value == 'convert') {
                        _confirmConvert(context, a);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: _purple),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      if (isPre)
                        PopupMenuItem(
                          value: 'convert',
                          enabled: !_converting,
                          child: Row(
                            children: [
                              _converting
                                  ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.orange),
                              )
                                  : const Icon(Icons.swap_horiz,
                                  size: 18, color: Colors.orange),
                              const SizedBox(width: 10),
                              const Text('Convert to Regular'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.expand_more, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? _buildDetails(a)
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  // ── Details Section (unchanged) ──
  Widget _buildDetails(AdmissionModel a) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          if (a.familyId.isNotEmpty)
            _row(Icons.family_restroom, 'Family ID', a.familyId),
          if (a.familyName.isNotEmpty)
            _row(Icons.group_outlined, 'Family Name', a.familyName),
          const SizedBox(height: 6),
          _sectionLabel('Father Details'),
          _row(Icons.person, 'Name', a.fatherName),
          if (a.fatherPhone.isNotEmpty)
            _row(Icons.phone, 'Phone', a.fatherPhone),
          if (a.fatherCnic != null && a.fatherCnic!.isNotEmpty)
            _row(Icons.credit_card, 'CNIC', a.fatherCnic!),
          if (a.fatherOccupation != null && a.fatherOccupation!.isNotEmpty)
            _row(Icons.work_outline, 'Occupation', a.fatherOccupation!),
          const SizedBox(height: 6),
          _sectionLabel('Mother Details'),
          if (a.motherName.isNotEmpty)
            _row(Icons.person_outline, 'Name', a.motherName),
          if (a.motherPhone != null && a.motherPhone!.isNotEmpty)
            _row(Icons.phone_outlined, 'Phone', a.motherPhone!),
          if (a.motherCnic != null && a.motherCnic!.isNotEmpty)
            _row(Icons.credit_card_outlined, 'CNIC', a.motherCnic!),
          if (a.caste != null && a.caste!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row(Icons.diversity_3_outlined, 'Caste', a.caste!),
          ],
          if (a.address != null && a.address!.isNotEmpty)
            _row(Icons.home_outlined, 'Address', a.address!),
          if (a.previousSchoolName != null &&
              a.previousSchoolName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _sectionLabel('Previous School'),
            _row(Icons.school_outlined, 'School', a.previousSchoolName!),
            if (a.previousClassName != null &&
                a.previousClassName!.isNotEmpty)
              _row(Icons.class_, 'Class', a.previousClassName!),
            if (a.previousClassMarks != null &&
                a.previousClassMarks!.isNotEmpty)
              _row(Icons.grade_outlined, 'Marks', a.previousClassMarks!),
          ],
          const SizedBox(height: 10),
          _sectionLabel('Students (${a.students.length})'),
          const SizedBox(height: 6),
          ...a.students.map((s) => _buildStudentChip(s)),
        ],
      ),
    );
  }

  // ── Student Chip (unchanged) ──
  Widget _buildStudentChip(AdmissionStudent s) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _studentAvatar(s.picBase64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name.isNotEmpty ? s.name : '—',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  if (s.studentId.isNotEmpty)
                    _chip(Icons.fingerprint, 'ID: ${s.studentId}', Colors.purple),
                  if (s.className != null && s.className!.isNotEmpty)
                    _chip(
                      Icons.class_,
                      s.sectionName != null && s.sectionName!.isNotEmpty
                          ? '${s.className} — ${s.sectionName}'
                          : s.className!,
                      Colors.blue,
                    ),
                  if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
                    _chip(Icons.format_list_numbered, 'Roll No: ${s.classRollNo}', Colors.teal),
                  if (s.bFormCnic != null && s.bFormCnic!.isNotEmpty)
                    _chip(Icons.credit_card_outlined, 'B-Form: ${s.bFormCnic}', Colors.indigo),
                  if (s.dob != null)
                    _chip(
                      Icons.cake_outlined,
                      'DOB: ${s.dob!.day.toString().padLeft(2, '0')}/${s.dob!.month.toString().padLeft(2, '0')}/${s.dob!.year}',
                      Colors.pink,
                    ),
                  if (s.monthlyFee != null || s.annualFee != null || s.registrationFee != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (s.monthlyFee != null)
                          _feeBadge('Monthly', s.monthlyFee!, Colors.green),
                        if (s.annualFee != null)
                          _feeBadge('Annual', s.annualFee!, Colors.orange),
                        if (s.registrationFee != null)
                          _feeBadge('Reg.', s.registrationFee!, Colors.purple),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentAvatar(String? picBase64) {
    if (picBase64 != null && picBase64.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 26,
          backgroundImage: MemoryImage(base64Decode(picBase64)),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.purple.shade50,
      child: const Icon(Icons.person, size: 22, color: Color(0xFF534AB7)),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color.withOpacity(0.7)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeBadge(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: Rs ${amount.toStringAsFixed(0)}',
        style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF534AB7), letterSpacing: 0.3),
      ),
    );
  }

  // ── Delete Confirm (unchanged) ──
  void _confirmDelete(BuildContext context, AdmissionModel a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Admission'),
        content: Text('Delete admission ${a.inquiryOrRegId} for ${a.fatherName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && a.id != null) {
      try {
        await context.read<AdmissionProvider>().deleteAdmission(a.id!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
        _findListScreenState()?.switchTab(AdmissionType.regular);
      }
    }
  }

  // ✅ Convert Confirm with loading state and date picker
  void _confirmConvert(BuildContext context, AdmissionModel a) async {
    // 1. Pick registration date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: _purple),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null || !context.mounted) return;

    // 2. Collect required student details
    final updatedStudents = await showDialog<List<AdmissionStudent>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _StudentDetailsDialog(students: a.students),
    );
    if (updatedStudents == null || !context.mounted) return; // user cancelled

    // 3. Confirm the conversion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Convert to Regular Admission'),
        content: Text(
          'This will create a new Regular Admission with date '
              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} '
              'and delete this Pre-Admission record. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Convert', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // 4. Execute conversion
    setState(() => _converting = true);
    try {
      await context.read<AdmissionProvider>().convertToRegular(
        a,
        customDate: pickedDate,
        studentsOverride: updatedStudents,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Converted to Regular Admission successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _findListScreenState()?.switchTab(AdmissionType.regular);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversion failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _converting = false);
    }
  }
}

class _StudentDetailsDialog extends StatefulWidget {
  final List<AdmissionStudent> students;
  const _StudentDetailsDialog({required this.students, Key? key}) : super(key: key);

  @override
  State<_StudentDetailsDialog> createState() => _StudentDetailsDialogState();
}

class _StudentDetailsDialogState extends State<_StudentDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _cnicCtrls;
  late final List<DateTime?> _dobList;

  @override
  void initState() {
    super.initState();
    _cnicCtrls = List.generate(
      widget.students.length,
          (i) => TextEditingController(text: widget.students[i].bFormCnic ?? ''),
    );
    _dobList = List.generate(
      widget.students.length,
          (i) => widget.students[i].dob,
    );
  }

  @override
  void dispose() {
    for (final c in _cnicCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final allDobFilled = _dobList.every((d) => d != null);
    if (!allDobFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date of Birth for all students')),
      );
      return;
    }

    final updated = List<AdmissionStudent>.generate(widget.students.length, (i) {
      return widget.students[i].copyWith(
        bFormCnic: _cnicCtrls[i].text.trim(),
        dob: _dobList[i],
      );
    });

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Student Details Required'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Form(
          key: _formKey,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.students.length,
            itemBuilder: (context, i) {
              final s = widget.students[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student ${i + 1}: ${s.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      // B-Form / CNIC
                      TextFormField(
                        controller: _cnicCtrls[i],
                        decoration: const InputDecoration(
                          labelText: 'B-Form / CNIC *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      // Date of Birth
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dobList[i] ?? DateTime(2015),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _dobList[i] = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cake_outlined),
                          ),
                          child: Text(
                            _dobList[i] != null
                                ? '${_dobList[i]!.day}/${_dobList[i]!.month}/${_dobList[i]!.year}'
                                : 'Select Date',
                            style: TextStyle(
                              color: _dobList[i] != null ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // cancel – returns null
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Next'),
        ),
      ],
    );
  }
}
