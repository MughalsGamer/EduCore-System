//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/admission_model.dart';
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
//   // ── Filter bottom sheet ──
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
//             final families  = provider.allFamilies;
//             final classes   = provider.allClassNames;
//             String? selFamily = provider.selectedFamilyId;
//             String? selClass  = provider.selectedClassName;
//
//             return Padding(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Handle
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
//                   // ── Family Filter ──
//                   const Text('Family',
//                       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 8),
//                   if (families.isEmpty)
//                     Text('No families found',
//                         style: TextStyle(color: Colors.grey.shade500, fontSize: 13))
//                   else
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 6,
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
//                   // ── Class Filter ──
//                   const Text('Class',
//                       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 8),
//                   if (classes.isEmpty)
//                     Text('No classes found',
//                         style: TextStyle(color: Colors.grey.shade500, fontSize: 13))
//                   else
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 6,
//                       children: [
//                         _filterChip(
//                           label: 'All',
//                           selected: selClass == null,
//                           onTap: () {
//                             setSheetState(() => selClass = null);
//                             provider.setClassFilter(null);
//                           },
//                         ),
//                         ...classes.map((c) => _filterChip(
//                           label: c,
//                           selected: selClass == c,
//                           onTap: () {
//                             setSheetState(() => selClass = c);
//                             provider.setClassFilter(c);
//                           },
//                         )),
//                       ],
//                     ),
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
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
//             child: Consumer<StudentProvider>(
//               builder: (context, provider, _) {
//                 return Row(
//                   children: [
//                     // Search bar
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
//                     // Filter button
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
//                         // Active dot
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
//               // ── Active filter chips ──
//               if (provider.selectedFamilyId != null || provider.selectedClassName != null)
//                 _buildActiveFilterBar(provider),
//
//               // Count
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
//         spacing: 8,
//         runSpacing: 4,
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
// class _StudentCard extends StatefulWidget {
//   final StudentWithContext data;
//   const _StudentCard({required this.data, Key? key}) : super(key: key);
//
//   @override
//   State<_StudentCard> createState() => _StudentCardState();
// }
//
// class _StudentCardState extends State<_StudentCard> {
//   bool _expanded = false;
//   static const _purple = Color(0xFF534AB7);
//
//   @override
//   Widget build(BuildContext context) {
//     final s = widget.data.student;
//     final d = widget.data;
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 2,
//       child: Column(
//         children: [
//           InkWell(
//             onTap: () => setState(() => _expanded = !_expanded),
//             borderRadius: BorderRadius.circular(14),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   _avatar(s.picBase64),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           s.name.isNotEmpty ? s.name : '—',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 15),
//                         ),
//                         const SizedBox(height: 2),
//                         if (s.className != null && s.className!.isNotEmpty)
//                           Text(
//                             (s.sectionName != null && s.sectionName!.isNotEmpty)
//                                 ? '${s.className} — ${s.sectionName}'
//                                 : s.className!,
//                             style: TextStyle(
//                                 fontSize: 12, color: Colors.grey.shade600),
//                           ),
//                         if (s.studentId.isNotEmpty)
//                           Text(
//                             'ID: ${s.studentId}',
//                             style: TextStyle(
//                                 fontSize: 11, color: Colors.grey.shade500),
//                           ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: Colors.green),
//                     ),
//                     child: Text(
//                       d.inquiryOrRegId,
//                       style: const TextStyle(
//                           fontSize: 10,
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   const SizedBox(width: 4),
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
//                 ? _buildDetails(s, d)
//                 : const SizedBox(width: double.infinity, height: 0),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetails(AdmissionStudent s, StudentWithContext d) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Divider(),
//           _sectionLabel('Student Info'),
//           if (s.studentId.isNotEmpty)
//             _row(Icons.fingerprint, 'Student ID', s.studentId, Colors.purple),
//           if (s.className != null && s.className!.isNotEmpty)
//             _row(
//               Icons.class_,
//               'Class',
//               (s.sectionName != null && s.sectionName!.isNotEmpty)
//                   ? '${s.className} — ${s.sectionName}'
//                   : s.className!,
//               Colors.blue,
//             ),
//           if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
//             _row(Icons.format_list_numbered, 'Roll No', s.classRollNo!,
//                 Colors.teal),
//           if (s.bFormCnic != null && s.bFormCnic!.isNotEmpty)
//             _row(Icons.credit_card_outlined, 'B-Form / CNIC', s.bFormCnic!,
//                 Colors.indigo),
//           if (s.dob != null)
//             _row(
//               Icons.cake_outlined,
//               'Date of Birth',
//               '${s.dob!.day.toString().padLeft(2, '0')}/'
//                   '${s.dob!.month.toString().padLeft(2, '0')}/'
//                   '${s.dob!.year}',
//               Colors.pink,
//             ),
//           if (s.monthlyFee != null ||
//               s.annualFee != null ||
//               s.registrationFee != null) ...[
//             const SizedBox(height: 8),
//             _sectionLabel('Fee Structure'),
//             const SizedBox(height: 4),
//             Wrap(
//               spacing: 8,
//               runSpacing: 6,
//               children: [
//                 if (s.monthlyFee != null)
//                   _feeBadge('Monthly', s.monthlyFee!, Colors.green),
//                 if (s.annualFee != null)
//                   _feeBadge('Annual', s.annualFee!, Colors.orange),
//                 if (s.registrationFee != null)
//                   _feeBadge('Reg.', s.registrationFee!, Colors.purple),
//               ],
//             ),
//           ],
//           const SizedBox(height: 8),
//           _sectionLabel('Family'),
//           if (d.familyId.isNotEmpty)
//             _row(Icons.tag, 'Family ID', d.familyId, _purple),
//           if (d.familyName.isNotEmpty)
//             _row(Icons.family_restroom, 'Family Name', d.familyName,
//                 Colors.brown),
//           const SizedBox(height: 8),
//           _sectionLabel('Father'),
//           _row(Icons.person, 'Name', d.fatherName, Colors.blueGrey),
//           _row(Icons.phone, 'Phone', d.fatherPhone, Colors.blueGrey),
//           if (d.fatherCnic != null && d.fatherCnic!.isNotEmpty)
//             _row(Icons.credit_card, 'CNIC', d.fatherCnic!, Colors.blueGrey),
//           if (d.fatherOccupation != null && d.fatherOccupation!.isNotEmpty)
//             _row(Icons.work_outline, 'Occupation', d.fatherOccupation!,
//                 Colors.blueGrey),
//           const SizedBox(height: 8),
//           _sectionLabel('Mother'),
//           _row(Icons.person_outline, 'Name', d.motherName, Colors.pinkAccent),
//           if (d.motherPhone != null && d.motherPhone!.isNotEmpty)
//             _row(Icons.phone_outlined, 'Phone', d.motherPhone!,
//                 Colors.pinkAccent),
//           if (d.motherCnic != null && d.motherCnic!.isNotEmpty)
//             _row(Icons.credit_card_outlined, 'CNIC', d.motherCnic!,
//                 Colors.pinkAccent),
//           if (d.caste != null && d.caste!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             _row(Icons.diversity_3_outlined, 'Caste', d.caste!, Colors.grey),
//           ],
//           if (d.address != null && d.address!.isNotEmpty)
//             _row(Icons.home_outlined, 'Address', d.address!, Colors.grey),
//           const SizedBox(height: 8),
//           _sectionLabel('Admission'),
//           _row(Icons.confirmation_number_outlined, 'Reg ID',
//               d.inquiryOrRegId, Colors.green),
//           _row(
//             Icons.calendar_today_outlined,
//             'Date',
//             '${d.admissionDate.day.toString().padLeft(2, '0')}/'
//                 '${d.admissionDate.month.toString().padLeft(2, '0')}/'
//                 '${d.admissionDate.year}',
//             Colors.green,
//           ),
//         ],
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
//
//   Widget _sectionLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6, top: 2),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: _purple,
//           letterSpacing: 0.3,
//         ),
//       ),
//     );
//   }
//
//   Widget _row(IconData icon, String label, String value, Color color) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 5),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 14, color: color.withOpacity(0.7)),
//           const SizedBox(width: 8),
//           Text(
//             '$label: ',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 12, color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _feeBadge(String label, double amount, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         '$label: Rs ${amount.toStringAsFixed(0)}',
//         style: TextStyle(
//           fontSize: 11,
//           color: color.withOpacity(0.8),
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:educoresystem/screens/student_management/student_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admission_model.dart';
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

  // ── Filter bottom sheet ──
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
            String? selSection = provider.selectedSectionName;   // NEW

            // Sections for the currently selected class (if any)
            final sections = selClass != null
                ? provider.sectionsForClass(selClass!)
                : <String>[];

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
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

                  // ── Family Filter ──
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

                  // ── Class Filter ──
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
                              selSection = null;   // clear section when class resets
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
                              selSection = null;   // class changed → reset section
                            });
                            provider.setClassFilter(c);
                          },
                        )),
                      ],
                    ),

                  // ── Section Filter (NEW) – only if class selected & has sections ──
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
  // void _showFilters(BuildContext context, StudentProvider provider) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (ctx) {
  //       return StatefulBuilder(
  //         builder: (ctx, setSheetState) {
  //           final families = provider.allFamilies;
  //           final classes  = provider.allClassNames;
  //           String? selFamily = provider.selectedFamilyId;
  //           String? selClass  = provider.selectedClassName;
  //
  //           return Padding(
  //             padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Handle
  //                 Center(
  //                   child: Container(
  //                     width: 40,
  //                     height: 4,
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey.shade300,
  //                       borderRadius: BorderRadius.circular(2),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Row(
  //                   children: [
  //                     const Text('Filters',
  //                         style: TextStyle(
  //                             fontSize: 18, fontWeight: FontWeight.bold)),
  //                     const Spacer(),
  //                     if (provider.hasActiveFilters)
  //                       TextButton(
  //                         onPressed: () {
  //                           provider.clearAllFilters();
  //                           _searchCtrl.clear();
  //                           Navigator.pop(ctx);
  //                         },
  //                         child: const Text('Clear All',
  //                             style: TextStyle(color: Colors.red)),
  //                       ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //
  //                 // ── Family Filter ──
  //                 const Text('Family',
  //                     style: TextStyle(
  //                         fontSize: 13, fontWeight: FontWeight.w600)),
  //                 const SizedBox(height: 8),
  //                 if (families.isEmpty)
  //                   Text('No families found',
  //                       style: TextStyle(
  //                           color: Colors.grey.shade500, fontSize: 13))
  //                 else
  //                   Wrap(
  //                     spacing: 8,
  //                     runSpacing: 6,
  //                     children: [
  //                       _filterChip(
  //                         label: 'All',
  //                         selected: selFamily == null,
  //                         onTap: () {
  //                           setSheetState(() => selFamily = null);
  //                           provider.setFamilyFilter(null);
  //                         },
  //                       ),
  //                       ...families.map((f) => _filterChip(
  //                         label: '${f.value} (${f.key})',
  //                         selected: selFamily == f.key,
  //                         onTap: () {
  //                           setSheetState(() => selFamily = f.key);
  //                           provider.setFamilyFilter(f.key);
  //                         },
  //                       )),
  //                     ],
  //                   ),
  //
  //                 const SizedBox(height: 20),
  //
  //                 // ── Class Filter ──
  //                 const Text('Class',
  //                     style: TextStyle(
  //                         fontSize: 13, fontWeight: FontWeight.w600)),
  //                 const SizedBox(height: 8),
  //                 if (classes.isEmpty)
  //                   Text('No classes found',
  //                       style: TextStyle(
  //                           color: Colors.grey.shade500, fontSize: 13))
  //                 else
  //                   Wrap(
  //                     spacing: 8,
  //                     runSpacing: 6,
  //                     children: [
  //                       _filterChip(
  //                         label: 'All',
  //                         selected: selClass == null,
  //                         onTap: () {
  //                           setSheetState(() => selClass = null);
  //                           provider.setClassFilter(null);
  //                         },
  //                       ),
  //                       ...classes.map((c) => _filterChip(
  //                         label: c,
  //                         selected: selClass == c,
  //                         onTap: () {
  //                           setSheetState(() => selClass = c);
  //                           provider.setClassFilter(c);
  //                         },
  //                       )),
  //                     ],
  //                   ),
  //
  //                 const SizedBox(height: 20),
  //                 ElevatedButton(
  //                   onPressed: () => Navigator.pop(ctx),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: _purple,
  //                     foregroundColor: Colors.white,
  //                     minimumSize: const Size(double.infinity, 46),
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12)),
  //                   ),
  //                   child: const Text('Apply'),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Consumer<StudentProvider>(
              builder: (context, provider, _) {
                return Row(
                  children: [
                    // Search bar
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
                    // Filter button
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
              // Active filter chips
              if (provider.selectedFamilyId != null ||
                  provider.selectedClassName != null)
                _buildActiveFilterBar(provider),

              // Count
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
          // ── NEW: Section chip ──
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

  // Widget _buildActiveFilterBar(StudentProvider provider) {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
  //     child: Wrap(
  //       spacing: 8,
  //       runSpacing: 4,
  //       children: [
  //         if (provider.selectedFamilyId != null)
  //           Chip(
  //             label: Text(
  //               'Family: ${provider.allFamilies.firstWhere(
  //                     (f) => f.key == provider.selectedFamilyId,
  //                 orElse: () => MapEntry(
  //                   provider.selectedFamilyId!,
  //                   provider.selectedFamilyId!,
  //                 ),
  //               ).value}',
  //               style: const TextStyle(fontSize: 12),
  //             ),
  //             deleteIcon: const Icon(Icons.close, size: 16),
  //             onDeleted: () => provider.setFamilyFilter(null),
  //             backgroundColor: _purple.withOpacity(0.1),
  //             deleteIconColor: _purple,
  //             labelStyle: const TextStyle(color: _purple),
  //             side: BorderSide(color: _purple.withOpacity(0.3)),
  //           ),
  //         if (provider.selectedClassName != null)
  //           Chip(
  //             label: Text(
  //               'Class: ${provider.selectedClassName}',
  //               style: const TextStyle(fontSize: 12),
  //             ),
  //             deleteIcon: const Icon(Icons.close, size: 16),
  //             onDeleted: () => provider.setClassFilter(null),
  //             backgroundColor: Colors.blue.withOpacity(0.1),
  //             deleteIconColor: Colors.blue,
  //             labelStyle: const TextStyle(color: Colors.blue),
  //             side: BorderSide(color: Colors.blue.withOpacity(0.3)),
  //           ),
  //       ],
  //     ),
  //   );
  // }

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
//  Student Card  ← now StatelessWidget, navigates to profile on tap
// ─────────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  final StudentWithContext data;
  const _StudentCard({required this.data, Key? key}) : super(key: key);

  static const _purple = Color(0xFF534AB7);

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
              // Avatar
              _avatar(s.picBase64),
              const SizedBox(width: 12),

              // Name + Class + ID
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

              // Reg/Inq badge
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

              // Arrow indicating tappable
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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