//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/admission_model.dart';
// import '../../providers/admission_provider.dart';
// import 'family_ledger_screen.dart';
//
// // ─────────────────────────────────────────────
// //  Family Management List Screen
// // ─────────────────────────────────────────────
// class FamilyManagementScreen extends StatefulWidget {
//   const FamilyManagementScreen({super.key});
//
//   @override
//   State<FamilyManagementScreen> createState() => _FamilyManagementScreenState();
// }
//
// class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
//   static const _purple = Color(0xFF534AB7);
//   static const _lightPurple = Color(0xFFEEECFA);
//
//   final _searchCtrl = TextEditingController();
//   String _searchQuery = '';
//
//   // Group admissions by familyId
//   Map<String, List<AdmissionModel>> _groupByFamily(
//       List<AdmissionModel> admissions) {
//     final map = <String, List<AdmissionModel>>{};
//     for (final a in admissions) {
//       final key = a.familyId.isNotEmpty ? a.familyId : a.fatherName;
//       map.putIfAbsent(key, () => []).add(a);
//     }
//     return map;
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   void _openLedger(BuildContext context, AdmissionModel rep) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => FamilyLedgerScreen(
//           familyDocId: rep.familyDocId,
//           familyName: rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
//           fatherName: rep.fatherName,
//           familyId: rep.familyId,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final admissions = context.watch<AdmissionProvider>().admissions;
//     final isLoading = context.watch<AdmissionProvider>().isLoading;
//
//     final grouped = _groupByFamily(admissions);
//
//     // Filter by search query
//     final filteredKeys = grouped.keys.where((key) {
//       final reps = grouped[key]!;
//       final rep = reps.first;
//       final q = _searchQuery.toLowerCase();
//       return q.isEmpty ||
//           rep.familyName.toLowerCase().contains(q) ||
//           rep.fatherName.toLowerCase().contains(q) ||
//           rep.familyId.toLowerCase().contains(q) ||
//           rep.fatherPhone.contains(q);
//     }).toList();
//
//     // Sort by family name
//     filteredKeys.sort((a, b) {
//       final fa = grouped[a]!.first.familyName.toLowerCase();
//       final fb = grouped[b]!.first.familyName.toLowerCase();
//       return fa.compareTo(fb);
//     });
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5FA),
//       appBar: AppBar(
//         title: const Text('Family Management'),
//         centerTitle: true,
//         backgroundColor: _purple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Header Stats + Search
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF534AB7), Color(0xFF6C63CC)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
//             child: Column(
//               children: [
//                 // Stats Row
//                 Row(
//                   children: [
//                     _statChip(
//                       icon: Icons.family_restroom,
//                       label: 'Families',
//                       value: grouped.length.toString(),
//                     ),
//                     const SizedBox(width: 12),
//                     _statChip(
//                       icon: Icons.people,
//                       label: 'Students',
//                       value: admissions
//                           .fold<int>(0, (sum, a) => sum + a.students.length)
//                           .toString(),
//                     ),
//                     const SizedBox(width: 12),
//                     _statChip(
//                       icon: Icons.how_to_reg,
//                       label: 'Admissions',
//                       value: admissions.length.toString(),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//                 // Search Bar
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: TextField(
//                     controller: _searchCtrl,
//                     onChanged: (v) => setState(() => _searchQuery = v.trim()),
//                     decoration: InputDecoration(
//                       hintText: 'Family name, father, phone se search...',
//                       hintStyle: TextStyle(
//                           color: Colors.grey.shade400, fontSize: 14),
//                       prefixIcon:
//                       const Icon(Icons.search, color: Color(0xFF534AB7)),
//                       suffixIcon: _searchQuery.isNotEmpty
//                           ? IconButton(
//                         icon: const Icon(Icons.clear,
//                             color: Colors.grey, size: 18),
//                         onPressed: () {
//                           _searchCtrl.clear();
//                           setState(() => _searchQuery = '');
//                         },
//                       )
//                           : null,
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 14),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Family List
//           Expanded(
//             child: isLoading
//                 ? const Center(
//                 child: CircularProgressIndicator(color: _purple))
//                 : filteredKeys.isEmpty
//                 ? _buildEmpty()
//                 : ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: filteredKeys.length,
//               itemBuilder: (context, i) {
//                 final key = filteredKeys[i];
//                 final reps = grouped[key]!;
//                 return _FamilyCard(
//                   familyKey: key,
//                   admissions: reps,
//                   onLedgerTap: () => _openLedger(context, reps.first),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _statChip({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.white, size: 18),
//             const SizedBox(width: 8),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(value,
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18)),
//                 Text(label,
//                     style: const TextStyle(
//                         color: Colors.white70, fontSize: 11)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.family_restroom,
//               size: 64, color: Colors.grey.shade300),
//           const SizedBox(height: 16),
//           Text(
//             _searchQuery.isEmpty
//                 ? 'Koi family nahi mili'
//                 : 'Search result nahi mila',
//             style: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Admission form se families auto-create hongi',
//             style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Family Card Widget
// // ─────────────────────────────────────────────
// class _FamilyCard extends StatelessWidget {
//   final String familyKey;
//   final List<AdmissionModel> admissions;
//   final VoidCallback onLedgerTap;
//
//   const _FamilyCard({
//     required this.familyKey,
//     required this.admissions,
//     required this.onLedgerTap,
//   });
//
//   static const _purple = Color(0xFF534AB7);
//   static const _lightPurple = Color(0xFFEEECFA);
//
//   @override
//   Widget build(BuildContext context) {
//     final rep = admissions.first; // representative admission
//     final allStudents = admissions.expand((a) => a.students).toList();
//     final totalMonthlyFee = allStudents.fold<double>(
//         0, (sum, s) => sum + (s.monthlyFee ?? 0));
//     final hasMultipleAdmissions = admissions.length > 1;
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shadowColor: _purple.withOpacity(0.1),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => FamilyDetailScreen(
//               familyKey: familyKey,
//               admissions: admissions,
//             ),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top Row: Avatar + Name + ID + Ledger button
//               Row(
//                 children: [
//                   // Family Avatar
//                   Container(
//                     width: 52,
//                     height: 52,
//                     decoration: BoxDecoration(
//                       color: _lightPurple,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Text(
//                         rep.familyName.isNotEmpty
//                             ? rep.familyName[0].toUpperCase()
//                             : 'F',
//                         style: const TextStyle(
//                           color: _purple,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 22,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//
//                   // Name + ID
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           rep.familyName.isNotEmpty
//                               ? rep.familyName
//                               : rep.fatherName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.black87,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 3),
//                         Row(
//                           children: [
//                             Icon(Icons.tag,
//                                 size: 12, color: Colors.grey.shade500),
//                             const SizedBox(width: 3),
//                             Text(
//                               rep.familyId.isNotEmpty
//                                   ? rep.familyId
//                                   : '—',
//                               style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade500),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Ledger button
//                   OutlinedButton.icon(
//                     onPressed: onLedgerTap,
//                     icon: const Icon(Icons.receipt_long_outlined, size: 15, color: _purple),
//                     label: const Text('Ledger',
//                         style: TextStyle(fontSize: 12, color: _purple, fontWeight: FontWeight.w600)),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: _purple),
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                       minimumSize: Size.zero,
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//
//                   // Arrow
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: _lightPurple,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(Icons.chevron_right,
//                         color: _purple, size: 20),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 14),
//               const Divider(height: 1, color: Color(0xFFEEEEEE)),
//               const SizedBox(height: 12),
//
//               // Info Row
//               Row(
//                 children: [
//                   _infoItem(
//                       Icons.person,
//                       rep.fatherName.isNotEmpty ? rep.fatherName : '—'),
//                   const SizedBox(width: 16),
//                   _infoItem(Icons.phone, rep.fatherPhone),
//                 ],
//               ),
//               const SizedBox(height: 8),
//
//               // Students Count + Fee
//               Row(
//                 children: [
//                   // Students pill
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: _lightPurple,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.people,
//                             size: 13, color: _purple),
//                         const SizedBox(width: 5),
//                         Text(
//                           '${allStudents.length} Student${allStudents.length != 1 ? 's' : ''}',
//                           style: const TextStyle(
//                               fontSize: 12,
//                               color: _purple,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//
//                   // Multiple admissions badge
//                   if (hasMultipleAdmissions)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade50,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '${admissions.length} Admissions',
//                         style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.orange.shade700,
//                             fontWeight: FontWeight.w600),
//                       ),
//                     ),
//
//                   const Spacer(),
//
//                   // Monthly Fee
//                   if (totalMonthlyFee > 0)
//                     Text(
//                       'Rs ${totalMonthlyFee.toStringAsFixed(0)}/mo',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: _purple,
//                         fontSize: 13,
//                       ),
//                     ),
//                 ],
//               ),
//
//               // Student mini-chips
//               if (allStudents.isNotEmpty) ...[
//                 const SizedBox(height: 10),
//                 Wrap(
//                   spacing: 6,
//                   runSpacing: 4,
//                   children: allStudents.take(4).map((s) {
//                     return Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 3),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: Text(
//                         s.name.isNotEmpty ? s.name : 'Unnamed',
//                         style: TextStyle(
//                             fontSize: 11, color: Colors.grey.shade700),
//                       ),
//                     );
//                   }).toList()
//                     ..addAll(allStudents.length > 4
//                         ? [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: _lightPurple,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text(
//                           '+${allStudents.length - 4} more',
//                           style: const TextStyle(
//                               fontSize: 11,
//                               color: _purple,
//                               fontWeight: FontWeight.w500),
//                         ),
//                       )
//                     ]
//                         : []),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _infoItem(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 14, color: Colors.grey.shade500),
//         const SizedBox(width: 5),
//         Text(
//           text,
//           style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Family Detail Screen
// // ─────────────────────────────────────────────
// class FamilyDetailScreen extends StatelessWidget {
//   final String familyKey;
//   final List<AdmissionModel> admissions;
//
//   const FamilyDetailScreen({
//     super.key,
//     required this.familyKey,
//     required this.admissions,
//   });
//
//   static const _purple = Color(0xFF534AB7);
//   static const _lightPurple = Color(0xFFEEECFA);
//
//   @override
//   Widget build(BuildContext context) {
//     final rep = admissions.first;
//     final allStudents = admissions.expand((a) => a.students).toList();
//
//     final totalMonthly =
//     allStudents.fold<double>(0, (s, st) => s + (st.monthlyFee ?? 0));
//     final totalAnnual =
//     allStudents.fold<double>(0, (s, st) => s + (st.annualFee ?? 0));
//     final totalRegistration =
//     allStudents.fold<double>(0, (s, st) => s + (st.registrationFee ?? 0));
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5FA),
//       body: CustomScrollView(
//         slivers: [
//           // ── SliverAppBar with family info ──
//           SliverAppBar(
//             expandedHeight: 200,
//             pinned: true,
//             backgroundColor: _purple,
//             foregroundColor: Colors.white,
//             actions: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 12),
//                 child: TextButton.icon(
//                   onPressed: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => FamilyLedgerScreen(
//                         familyDocId: rep.familyDocId,
//                         familyName: rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
//                         fatherName: rep.fatherName,
//                         familyId: rep.familyId,
//                       ),
//                     ),
//                   ),
//                   icon: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 18),
//                   label: const Text('Ledger', style: TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF534AB7), Color(0xFF6C63CC)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // Avatar
//                         Container(
//                           width: 68,
//                           height: 68,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                                 color: Colors.white.withOpacity(0.5),
//                                 width: 2),
//                           ),
//                           child: Center(
//                             child: Text(
//                               rep.familyName.isNotEmpty
//                                   ? rep.familyName[0].toUpperCase()
//                                   : 'F',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 28,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 rep.familyName.isNotEmpty
//                                     ? rep.familyName
//                                     : rep.fatherName,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 20,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'ID: ${rep.familyId.isNotEmpty ? rep.familyId : "—"}',
//                                 style: const TextStyle(
//                                     color: Colors.white70, fontSize: 13),
//                               ),
//                               const SizedBox(height: 6),
//                               Row(
//                                 children: [
//                                   _headerBadge(
//                                       '${allStudents.length} Students'),
//                                   const SizedBox(width: 8),
//                                   _headerBadge(
//                                       '${admissions.length} Admissions'),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Fee Summary Cards ──
//                   _sectionTitle('Fee Summary'),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       _feeCard('Monthly', 'Rs ${totalMonthly.toStringAsFixed(0)}',
//                           Icons.calendar_month, Colors.blue.shade600),
//                       const SizedBox(width: 10),
//                       _feeCard('Annual', 'Rs ${totalAnnual.toStringAsFixed(0)}',
//                           Icons.calendar_today, Colors.green.shade600),
//                       const SizedBox(width: 10),
//                       _feeCard('Reg.', 'Rs ${totalRegistration.toStringAsFixed(0)}',
//                           Icons.app_registration, Colors.orange.shade600),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//
//                   // ── Parent Details ──
//                   _sectionTitle('Parent Details'),
//                   const SizedBox(height: 10),
//                   _buildParentCard(rep),
//                   const SizedBox(height: 24),
//
//                   // ── Students ──
//                   _sectionTitle('Students (${allStudents.length})'),
//                   const SizedBox(height: 10),
//                   ...admissions.asMap().entries.expand((entry) {
//                     final idx = entry.key;
//                     final admission = entry.value;
//                     return [
//                       if (admissions.length > 1)
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 8),
//                           child: _admissionLabel(admission, idx),
//                         ),
//                       ...admission.students
//                           .map((s) => _StudentDetailCard(
//                         student: s,
//                         admission: admission,
//                       )),
//                     ];
//                   }),
//                   const SizedBox(height: 24),
//
//                   // ── Previous School (if any) ──
//                   if (rep.previousSchoolName != null &&
//                       rep.previousSchoolName!.isNotEmpty) ...[
//                     _sectionTitle('Previous School'),
//                     const SizedBox(height: 10),
//                     _buildPreviousSchoolCard(rep),
//                     const SizedBox(height: 24),
//                   ],
//
//                   // ── Address ──
//                   if (rep.address != null && rep.address!.isNotEmpty) ...[
//                     _sectionTitle('Address'),
//                     const SizedBox(height: 10),
//                     _buildInfoCard([
//                       _DetailRow(Icons.home_outlined, 'Address', rep.address!),
//                       if (rep.caste != null && rep.caste!.isNotEmpty)
//                         _DetailRow(Icons.diversity_3_outlined, 'Caste', rep.caste!),
//                     ]),
//                     const SizedBox(height: 24),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _headerBadge(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(text,
//           style: const TextStyle(color: Colors.white, fontSize: 11)),
//     );
//   }
//
//   Widget _sectionTitle(String title) {
//     return Row(
//       children: [
//         Container(
//           width: 4,
//           height: 18,
//           decoration: BoxDecoration(
//             color: _purple,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(title,
//             style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87)),
//       ],
//     );
//   }
//
//   Widget _feeCard(String label, String value, IconData icon, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             )
//           ],
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 20),
//             const SizedBox(height: 6),
//             Text(value,
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13,
//                     color: color)),
//             const SizedBox(height: 2),
//             Text(label,
//                 style: TextStyle(
//                     fontSize: 11, color: Colors.grey.shade500)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildParentCard(AdmissionModel rep) {
//     return _buildInfoCard([
//       _DetailRow(Icons.person, 'Father', rep.fatherName),
//       if (rep.fatherPhone.isNotEmpty)
//         _DetailRow(Icons.phone, 'Phone', rep.fatherPhone),
//       if (rep.fatherCnic != null && rep.fatherCnic!.isNotEmpty)
//         _DetailRow(Icons.credit_card, 'CNIC', rep.fatherCnic!),
//       if (rep.fatherOccupation != null && rep.fatherOccupation!.isNotEmpty)
//         _DetailRow(Icons.work_outline, 'Occupation', rep.fatherOccupation!),
//       if (rep.motherName.isNotEmpty) ...[
//         const SizedBox(height: 4),
//         _DetailRow(Icons.person_outline, 'Mother', rep.motherName),
//         if (rep.motherPhone != null && rep.motherPhone!.isNotEmpty)
//           _DetailRow(
//               Icons.phone_outlined, 'Mother Phone', rep.motherPhone!),
//         if (rep.motherCnic != null && rep.motherCnic!.isNotEmpty)
//           _DetailRow(
//               Icons.credit_card_outlined, 'Mother CNIC', rep.motherCnic!),
//       ],
//     ]);
//   }
//
//   Widget _buildPreviousSchoolCard(AdmissionModel rep) {
//     return _buildInfoCard([
//       if (rep.previousSchoolName != null)
//         _DetailRow(Icons.school_outlined, 'School', rep.previousSchoolName!),
//       if (rep.previousClassName != null)
//         _DetailRow(Icons.class_, 'Class', rep.previousClassName!),
//       if (rep.previousClassMarks != null)
//         _DetailRow(Icons.grade_outlined, 'Marks/Grade', rep.previousClassMarks!),
//     ]);
//   }
//
//   Widget _admissionLabel(AdmissionModel a, int idx) {
//     final isRegular = a.type == AdmissionType.regular;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: isRegular
//             ? Colors.green.shade50
//             : Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isRegular
//               ? Colors.green.shade200
//               : Colors.blue.shade200,
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             isRegular ? Icons.verified : Icons.pending_outlined,
//             size: 14,
//             color: isRegular
//                 ? Colors.green.shade600
//                 : Colors.blue.shade600,
//           ),
//           const SizedBox(width: 6),
//           Text(
//             '${a.type.label} — ${a.inquiryOrRegId}',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: isRegular
//                   ? Colors.green.shade700
//                   : Colors.blue.shade700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoCard(List<Widget> children) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       ),
//     );
//   }
// }
//
// // ── Detail Row Helper ──
// class _DetailRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//
//   const _DetailRow(this.icon, this.label, this.value);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 15, color: Colors.grey.shade400),
//           const SizedBox(width: 8),
//           Text('$label: ',
//               style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey.shade600,
//                   fontWeight: FontWeight.w500)),
//           Expanded(
//             child: Text(value,
//                 style: const TextStyle(
//                     fontSize: 13, color: Colors.black87)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Student Detail Card
// // ─────────────────────────────────────────────
// class _StudentDetailCard extends StatefulWidget {
//   final AdmissionStudent student;
//   final AdmissionModel admission;
//
//   const _StudentDetailCard({
//     required this.student,
//     required this.admission,
//   });
//
//   @override
//   State<_StudentDetailCard> createState() => _StudentDetailCardState();
// }
//
// class _StudentDetailCardState extends State<_StudentDetailCard> {
//   bool _expanded = false;
//
//   static const _purple = Color(0xFF534AB7);
//   static const _lightPurple = Color(0xFFEEECFA);
//
//   @override
//   Widget build(BuildContext context) {
//     final s = widget.student;
//     final admission = widget.admission;
//     final isRegular = admission.type == AdmissionType.regular;
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       elevation: 1,
//       shadowColor: Colors.black.withOpacity(0.08),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       child: Column(
//         children: [
//           // ── Collapsed Header ──
//           InkWell(
//             borderRadius: BorderRadius.circular(14),
//             onTap: () => setState(() => _expanded = !_expanded),
//             child: Padding(
//               padding: const EdgeInsets.all(14),
//               child: Row(
//                 children: [
//                   // Photo or Avatar
//                   s.picBase64 != null
//                       ? CircleAvatar(
//                     radius: 26,
//                     backgroundImage:
//                     MemoryImage(base64Decode(s.picBase64!)),
//                   )
//                       : CircleAvatar(
//                     radius: 26,
//                     backgroundColor: _lightPurple,
//                     child: Text(
//                       s.name.isNotEmpty
//                           ? s.name[0].toUpperCase()
//                           : 'S',
//                       style: const TextStyle(
//                         color: _purple,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//
//                   // Name + Class
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           s.name.isNotEmpty ? s.name : 'Unnamed',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15,
//                               color: Colors.black87),
//                         ),
//                         const SizedBox(height: 3),
//                         Row(
//                           children: [
//                             if (s.className != null)
//                               _smallChip(
//                                 Icons.class_,
//                                 s.sectionName != null
//                                     ? '${s.className} - ${s.sectionName}'
//                                     : s.className!,
//                                 Colors.grey.shade100,
//                                 Colors.grey.shade600,
//                               ),
//                             const SizedBox(width: 6),
//                             _smallChip(
//                               isRegular
//                                   ? Icons.verified
//                                   : Icons.pending_outlined,
//                               isRegular ? 'Regular' : 'Pre',
//                               isRegular
//                                   ? Colors.green.shade50
//                                   : Colors.blue.shade50,
//                               isRegular
//                                   ? Colors.green.shade700
//                                   : Colors.blue.shade700,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Monthly Fee + Arrow
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       if (s.monthlyFee != null && s.monthlyFee! > 0)
//                         Text(
//                           'Rs ${s.monthlyFee!.toStringAsFixed(0)}',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: _purple,
//                               fontSize: 14),
//                         ),
//                       const SizedBox(height: 4),
//                       Icon(
//                         _expanded
//                             ? Icons.keyboard_arrow_up
//                             : Icons.keyboard_arrow_down,
//                         color: Colors.grey.shade400,
//                         size: 20,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // ── Expanded Details ──
//           if (_expanded)
//             Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF9F9FF),
//                 borderRadius: const BorderRadius.vertical(
//                     bottom: Radius.circular(14)),
//               ),
//               padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Divider(height: 16),
//
//                   // Student IDs
//                   _expandRow(Icons.fingerprint, 'Student ID',
//                       s.studentId.isNotEmpty ? s.studentId : '—'),
//                   if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
//                     _expandRow(Icons.format_list_numbered, 'Roll No',
//                         s.classRollNo!),
//                   if (s.bFormCnic != null && s.bFormCnic!.isNotEmpty)
//                     _expandRow(
//                         Icons.credit_card_outlined, 'B-Form/CNIC', s.bFormCnic!),
//                   if (s.dob != null)
//                     _expandRow(
//                       Icons.cake_outlined,
//                       'Date of Birth',
//                       '${s.dob!.day.toString().padLeft(2, '0')}/${s.dob!.month.toString().padLeft(2, '0')}/${s.dob!.year}',
//                     ),
//
//                   // Admission info
//                   _expandRow(Icons.badge_outlined, 'Admission ID',
//                       admission.inquiryOrRegId),
//                   _expandRow(
//                     Icons.calendar_today_outlined,
//                     'Admission Date',
//                     '${admission.admissionDate.day.toString().padLeft(2, '0')}/${admission.admissionDate.month.toString().padLeft(2, '0')}/${admission.admissionDate.year}',
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   // Fee Summary
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: _lightPurple,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.payments_outlined,
//                             color: _purple, size: 15),
//                         const SizedBox(width: 6),
//                         const Text('Fees: ',
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: _purple)),
//                         Text(
//                           [
//                             if (s.monthlyFee != null && s.monthlyFee! > 0)
//                               'Monthly: Rs ${s.monthlyFee!.toStringAsFixed(0)}',
//                             if (s.annualFee != null && s.annualFee! > 0)
//                               'Annual: Rs ${s.annualFee!.toStringAsFixed(0)}',
//                             if (s.registrationFee != null &&
//                                 s.registrationFee! > 0)
//                               'Reg: Rs ${s.registrationFee!.toStringAsFixed(0)}',
//                           ].join('  •  '),
//                           style: const TextStyle(
//                               fontSize: 12, color: _purple),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _smallChip(
//       IconData icon, String label, Color bg, Color fg) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 11, color: fg),
//           const SizedBox(width: 3),
//           Text(label,
//               style:
//               TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }
//
//   Widget _expandRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 14, color: Colors.grey.shade400),
//           const SizedBox(width: 7),
//           Text('$label: ',
//               style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade500,
//                   fontWeight: FontWeight.w500)),
//           Expanded(
//             child: Text(value,
//                 style: const TextStyle(
//                     fontSize: 12, color: Colors.black87)),
//           ),
//         ],
//       ),
//     );
//   }
// }






import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admission_model.dart';
import '../../providers/admission_provider.dart';
import 'family_ledger_screen.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleDeep = Color(0xFF3F3792);
const _kPurpleSoft = Color(0xFFF4F3FC);
const _kPurpleTint = Color(0xFFEDEBFA);
const _kInk = Color(0xFF1A1A2E);
const _kSlate = Color(0xFF6B7280);
const _kSlateLight = Color(0xFF9CA3AF);
const _kBorder = Color(0xFFE9E9F2);
const _kSurface = Color(0xFFF7F7FB);
const _kGreen = Color(0xFF16A34A);
const _kOrange = Color(0xFFD97706);

// ─────────────────────────────────────────────
//  Family Management Screen
//  Desktop  → split view: searchable roster (left) + live detail panel (right)
//  Mobile   → refined card list, tap to push full detail screen
// ─────────────────────────────────────────────
class FamilyManagementScreen extends StatefulWidget {
  const FamilyManagementScreen({super.key});

  @override
  State<FamilyManagementScreen> createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedFamilyKey; // desktop-only: which family is shown in the right panel

  Map<String, List<AdmissionModel>> _groupByFamily(List<AdmissionModel> admissions) {
    final map = <String, List<AdmissionModel>>{};
    for (final a in admissions) {
      final key = a.familyId.isNotEmpty ? a.familyId : a.fatherName;
      map.putIfAbsent(key, () => []).add(a);
    }
    return map;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openLedger(BuildContext context, AdmissionModel rep) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FamilyLedgerScreen(
          familyDocId: rep.familyDocId,
          familyName: rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
          fatherName: rep.fatherName,
          familyId: rep.familyId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final admissions = context.watch<AdmissionProvider>().admissions;
    final isLoading = context.watch<AdmissionProvider>().isLoading;
    final grouped = _groupByFamily(admissions);

    final filteredKeys = grouped.keys.where((key) {
      final rep = grouped[key]!.first;
      final q = _searchQuery.toLowerCase();
      return q.isEmpty ||
          rep.familyName.toLowerCase().contains(q) ||
          rep.fatherName.toLowerCase().contains(q) ||
          rep.familyId.toLowerCase().contains(q) ||
          rep.fatherPhone.contains(q);
    }).toList()
      ..sort((a, b) {
        final fa = grouped[a]!.first.familyName.toLowerCase();
        final fb = grouped[b]!.first.familyName.toLowerCase();
        return fa.compareTo(fb);
      });

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: isDesktop
          ? null
          : AppBar(
        title: const Text('Families'),
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isDesktop
          ? _buildDesktop(grouped, filteredKeys, admissions, isLoading)
          : _buildMobile(grouped, filteredKeys, admissions, isLoading),
    );
  }

  // ═══════════════════════════════════════════
  //  DESKTOP — split view
  // ═══════════════════════════════════════════
  Widget _buildDesktop(
      Map<String, List<AdmissionModel>> grouped,
      List<String> filteredKeys,
      List<AdmissionModel> admissions,
      bool isLoading,
      ) {
    final selectedKey = _selectedFamilyKey != null && grouped.containsKey(_selectedFamilyKey)
        ? _selectedFamilyKey
        : (filteredKeys.isNotEmpty ? filteredKeys.first : null);

    return Row(
      children: [
        // ── Left roster panel ──
        Container(
          width: 380,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: _kBorder)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _desktopHeader(grouped, admissions),
              _desktopSearchBar(),
              const Divider(height: 1, color: _kBorder),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: _kPurple))
                    : filteredKeys.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredKeys.length,
                  itemBuilder: (context, i) {
                    final key = filteredKeys[i];
                    final reps = grouped[key]!;
                    return _RosterRow(
                      admissions: reps,
                      isSelected: key == selectedKey,
                      onTap: () => setState(() => _selectedFamilyKey = key),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── Right detail panel ──
        Expanded(
          child: selectedKey == null
              ? _desktopEmptyDetail()
              : _DesktopFamilyDetail(
            key: ValueKey(selectedKey),
            familyKey: selectedKey,
            admissions: grouped[selectedKey]!,
            onLedgerTap: () => _openLedger(context, grouped[selectedKey]!.first),
          ),
        ),
      ],
    );
  }

  Widget _desktopHeader(Map<String, List<AdmissionModel>> grouped, List<AdmissionModel> admissions) {
    final totalStudents = admissions.fold<int>(0, (sum, a) => sum + a.students.length);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Families',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _kInk, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text(
            '${grouped.length} families  •  $totalStudents students',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _desktopSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v.trim()),
          style: const TextStyle(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: 'Search families...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 16),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
            )
                : null,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }

  Widget _desktopEmptyDetail() {
    return Container(
      color: _kSurface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: _kPurpleTint, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.family_restroom_rounded, size: 34, color: _kPurple),
            ),
            const SizedBox(height: 16),
            Text('Select a family', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text('Choose a family from the list to view details',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(
            _searchQuery.isEmpty ? 'Koi family nahi mili' : 'Search result nahi mila',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  MOBILE — refined card list
  // ═══════════════════════════════════════════
  Widget _buildMobile(
      Map<String, List<AdmissionModel>> grouped,
      List<String> filteredKeys,
      List<AdmissionModel> admissions,
      bool isLoading,
      ) {
    final totalStudents = admissions.fold<int>(0, (sum, a) => sum + a.students.length);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kPurple, _kPurpleDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    _mobileStat(icon: Icons.family_restroom_rounded, label: 'Families', value: grouped.length.toString()),
                    const SizedBox(width: 10),
                    _mobileStat(icon: Icons.people_alt_rounded, label: 'Students', value: totalStudents.toString()),
                    const SizedBox(width: 10),
                    _mobileStat(icon: Icons.how_to_reg_rounded, label: 'Admissions', value: admissions.length.toString()),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    decoration: InputDecoration(
                      hintText: 'Family, father, phone se search...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
                      prefixIcon: const Icon(Icons.search_rounded, color: _kPurple, size: 21),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: _kPurple)))
        else if (filteredKeys.isEmpty)
          SliverFillRemaining(child: _buildEmpty())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) {
                  final key = filteredKeys[i];
                  final reps = grouped[key]!;
                  return _MobileFamilyCard(
                    admissions: reps,
                    onLedgerTap: () => _openLedger(context, reps.first),
                  );
                },
                childCount: filteredKeys.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _mobileStat({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Desktop roster row (left panel item)
// ─────────────────────────────────────────────
class _RosterRow extends StatelessWidget {
  final List<AdmissionModel> admissions;
  final bool isSelected;
  final VoidCallback onTap;

  const _RosterRow({required this.admissions, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rep = admissions.first;
    final studentCount = admissions.expand((a) => a.students).length;

    return Material(
      color: isSelected ? _kPurpleSoft : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: isSelected ? _kPurple : Colors.transparent, width: 3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected ? [_kPurple, _kPurpleDeep] : [_kPurpleTint, _kPurpleTint],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rep.familyName.isNotEmpty ? rep.familyName[0].toUpperCase() : 'F',
                    style: TextStyle(
                      color: isSelected ? Colors.white : _kPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$studentCount student${studentCount != 1 ? 's' : ''}  •  ${rep.familyId.isNotEmpty ? rep.familyId : "—"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.chevron_right_rounded, color: _kPurple, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Desktop right-panel detail (embedded, no page push)
// ─────────────────────────────────────────────
class _DesktopFamilyDetail extends StatelessWidget {
  final String familyKey;
  final List<AdmissionModel> admissions;
  final VoidCallback onLedgerTap;

  const _DesktopFamilyDetail({super.key, required this.familyKey, required this.admissions, required this.onLedgerTap});

  @override
  Widget build(BuildContext context) {
    final rep = admissions.first;
    final allStudents = admissions.expand((a) => a.students).toList();
    final totalMonthly = allStudents.fold<double>(0, (s, st) => s + (st.monthlyFee ?? 0));
    final totalAnnual = allStudents.fold<double>(0, (s, st) => s + (st.annualFee ?? 0));
    final totalRegistration = allStudents.fold<double>(0, (s, st) => s + (st.registrationFee ?? 0));

    return Container(
      color: _kSurface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: identity + primary actions ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_kPurple, _kPurpleDeep], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: _kPurple.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Center(
                      child: Text(
                        rep.familyName.isNotEmpty ? rep.familyName[0].toUpperCase() : 'F',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _kInk, letterSpacing: -0.3)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _pillTag(icon: Icons.tag_rounded, label: rep.familyId.isNotEmpty ? rep.familyId : '—'),
                            const SizedBox(width: 8),
                            _pillTag(icon: Icons.people_alt_rounded, label: '${allStudents.length} student${allStudents.length != 1 ? 's' : ''}'),
                            if (admissions.length > 1) ...[
                              const SizedBox(width: 8),
                              _pillTag(icon: Icons.receipt_long_rounded, label: '${admissions.length} admissions', color: _kOrange),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onLedgerTap,
                    icon: const Icon(Icons.receipt_long_rounded, size: 17),
                    label: const Text('View Ledger'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FamilyDetailScreen(familyKey: familyKey, admissions: admissions)),
                    ),
                    icon: const Icon(Icons.open_in_full_rounded, size: 15),
                    label: const Text('Full view'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kPurple,
                      side: const BorderSide(color: _kBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Fee summary strip ──
              Row(
                children: [
                  Expanded(child: _feeStat('Monthly', totalMonthly, Icons.calendar_month_rounded, const Color(0xFF2563EB))),
                  const SizedBox(width: 12),
                  Expanded(child: _feeStat('Annual', totalAnnual, Icons.calendar_today_rounded, _kGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _feeStat('Registration', totalRegistration, Icons.app_registration_rounded, _kOrange)),
                ],
              ),

              const SizedBox(height: 28),

              // ── Two-column layout: parent details + students ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _panelCard(
                      title: 'Parent Details',
                      icon: Icons.family_restroom_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow(Icons.person_rounded, 'Father', rep.fatherName),
                          if (rep.fatherPhone.isNotEmpty) _detailRow(Icons.phone_rounded, 'Phone', rep.fatherPhone),
                          if (rep.fatherCnic != null && rep.fatherCnic!.isNotEmpty) _detailRow(Icons.badge_rounded, 'CNIC', rep.fatherCnic!),
                          if (rep.fatherOccupation != null && rep.fatherOccupation!.isNotEmpty)
                            _detailRow(Icons.work_rounded, 'Occupation', rep.fatherOccupation!),
                          if (rep.motherName.isNotEmpty) ...[
                            const Divider(height: 24, color: _kBorder),
                            _detailRow(Icons.person_outline_rounded, 'Mother', rep.motherName),
                            if (rep.motherPhone != null && rep.motherPhone!.isNotEmpty)
                              _detailRow(Icons.phone_outlined, 'Mother Phone', rep.motherPhone!),
                            if (rep.motherCnic != null && rep.motherCnic!.isNotEmpty)
                              _detailRow(Icons.badge_outlined, 'Mother CNIC', rep.motherCnic!),
                          ],
                          if (rep.address != null && rep.address!.isNotEmpty) ...[
                            const Divider(height: 24, color: _kBorder),
                            _detailRow(Icons.home_rounded, 'Address', rep.address!),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _panelCard(
                      title: 'Students (${allStudents.length})',
                      icon: Icons.school_rounded,
                      child: Column(
                        children: allStudents.map((s) => _studentTile(s)).toList(),
                      ),
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

  Widget _pillTag({required IconData icon, required String label, Color color = _kPurple}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _feeStat(String label, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('Rs ${value.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _kInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _kPurple),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kInk)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12.5, color: _kInk, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _studentTile(AdmissionStudent s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          s.picBase64 != null
              ? CircleAvatar(radius: 20, backgroundImage: MemoryImage(base64Decode(s.picBase64!)))
              : CircleAvatar(
            radius: 20,
            backgroundColor: _kPurpleTint,
            child: Text(
              s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
              style: const TextStyle(color: _kPurple, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name.isNotEmpty ? s.name : 'Unnamed',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk)),
                if (s.className != null)
                  Text(
                    s.sectionName != null ? '${s.className} - ${s.sectionName}' : s.className!,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          if (s.monthlyFee != null && s.monthlyFee! > 0)
            Text('Rs ${s.monthlyFee!.toStringAsFixed(0)}/mo',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kPurple)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Mobile — premium family card
// ─────────────────────────────────────────────
class _MobileFamilyCard extends StatelessWidget {
  final List<AdmissionModel> admissions;
  final VoidCallback onLedgerTap;

  const _MobileFamilyCard({required this.admissions, required this.onLedgerTap});

  @override
  Widget build(BuildContext context) {
    final rep = admissions.first;
    final allStudents = admissions.expand((a) => a.students).toList();
    final totalMonthlyFee = allStudents.fold<double>(0, (sum, s) => sum + (s.monthlyFee ?? 0));
    final hasMultipleAdmissions = admissions.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FamilyDetailScreen(
                familyKey: rep.familyId.isNotEmpty ? rep.familyId : rep.fatherName,
                admissions: admissions,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_kPurple, _kPurpleDeep], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          rep.familyName.isNotEmpty ? rep.familyName[0].toUpperCase() : 'F',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19),
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5, color: _kInk),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.tag_rounded, size: 12, color: Colors.grey.shade400),
                              const SizedBox(width: 3),
                              Text(rep.familyId.isNotEmpty ? rep.familyId : '—',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onLedgerTap,
                      icon: const Icon(Icons.receipt_long_rounded, size: 20, color: _kPurple),
                      style: IconButton.styleFrom(
                        backgroundColor: _kPurpleTint,
                        padding: const EdgeInsets.all(9),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: _kBorder),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _mobileInfoItem(Icons.person_rounded, rep.fatherName.isNotEmpty ? rep.fatherName : '—')),
                    Expanded(child: _mobileInfoItem(Icons.phone_rounded, rep.fatherPhone.isNotEmpty ? rep.fatherPhone : '—')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _tag(
                      icon: Icons.people_alt_rounded,
                      label: '${allStudents.length} Student${allStudents.length != 1 ? 's' : ''}',
                      bg: _kPurpleTint,
                      fg: _kPurple,
                    ),
                    if (hasMultipleAdmissions) ...[
                      const SizedBox(width: 8),
                      _tag(
                        icon: Icons.receipt_long_rounded,
                        label: '${admissions.length} Admissions',
                        bg: _kOrange.withOpacity(0.1),
                        fg: _kOrange,
                      ),
                    ],
                    const Spacer(),
                    if (totalMonthlyFee > 0)
                      Text('Rs ${totalMonthlyFee.toStringAsFixed(0)}/mo',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: _kPurple, fontSize: 13.5)),
                  ],
                ),
                if (allStudents.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...allStudents.take(3).map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(8)),
                        child: Text(s.name.isNotEmpty ? s.name : 'Unnamed',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                      )),
                      if (allStudents.length > 3)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(color: _kPurpleTint, borderRadius: BorderRadius.circular(8)),
                          child: Text('+${allStudents.length - 3} more',
                              style: const TextStyle(fontSize: 11, color: _kPurple, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade400),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _tag({required IconData icon, required String label, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11.5, color: fg, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Family Detail Screen (used by mobile push + desktop "Full view")
// ─────────────────────────────────────────────
class FamilyDetailScreen extends StatelessWidget {
  final String familyKey;
  final List<AdmissionModel> admissions;

  const FamilyDetailScreen({super.key, required this.familyKey, required this.admissions});

  @override
  Widget build(BuildContext context) {
    final rep = admissions.first;
    final allStudents = admissions.expand((a) => a.students).toList();

    final totalMonthly = allStudents.fold<double>(0, (s, st) => s + (st.monthlyFee ?? 0));
    final totalAnnual = allStudents.fold<double>(0, (s, st) => s + (st.annualFee ?? 0));
    final totalRegistration = allStudents.fold<double>(0, (s, st) => s + (st.registrationFee ?? 0));

    return Scaffold(
      backgroundColor: _kSurface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _kPurple,
            foregroundColor: Colors.white,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FamilyLedgerScreen(
                        familyDocId: rep.familyDocId,
                        familyName: rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
                        fatherName: rep.fatherName,
                        familyId: rep.familyId,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 18),
                  label: const Text('Ledger', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_kPurple, _kPurpleDeep], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              rep.familyName.isNotEmpty ? rep.familyName[0].toUpperCase() : 'F',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                              ),
                              const SizedBox(height: 4),
                              Text('ID: ${rep.familyId.isNotEmpty ? rep.familyId : "—"}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _headerBadge('${allStudents.length} Students'),
                                  const SizedBox(width: 8),
                                  _headerBadge('${admissions.length} Admissions'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Fee Summary'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _feeCard('Monthly', 'Rs ${totalMonthly.toStringAsFixed(0)}', Icons.calendar_month_rounded, const Color(0xFF2563EB)),
                      const SizedBox(width: 10),
                      _feeCard('Annual', 'Rs ${totalAnnual.toStringAsFixed(0)}', Icons.calendar_today_rounded, _kGreen),
                      const SizedBox(width: 10),
                      _feeCard('Reg.', 'Rs ${totalRegistration.toStringAsFixed(0)}', Icons.app_registration_rounded, _kOrange),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Parent Details'),
                  const SizedBox(height: 10),
                  _buildParentCard(rep),
                  const SizedBox(height: 24),
                  _sectionTitle('Students (${allStudents.length})'),
                  const SizedBox(height: 10),
                  ...admissions.asMap().entries.expand((entry) {
                    final idx = entry.key;
                    final admission = entry.value;
                    return [
                      if (admissions.length > 1)
                        Padding(padding: const EdgeInsets.only(bottom: 8), child: _admissionLabel(admission, idx)),
                      ...admission.students.map((s) => _StudentDetailCard(student: s, admission: admission)),
                    ];
                  }),
                  const SizedBox(height: 24),
                  if (rep.previousSchoolName != null && rep.previousSchoolName!.isNotEmpty) ...[
                    _sectionTitle('Previous School'),
                    const SizedBox(height: 10),
                    _buildPreviousSchoolCard(rep),
                    const SizedBox(height: 24),
                  ],
                  if (rep.address != null && rep.address!.isNotEmpty) ...[
                    _sectionTitle('Address'),
                    const SizedBox(height: 10),
                    _buildInfoCard([
                      _DetailRow(Icons.home_outlined, 'Address', rep.address!),
                      if (rep.caste != null && rep.caste!.isNotEmpty) _DetailRow(Icons.diversity_3_outlined, 'Caste', rep.caste!),
                    ]),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: _kPurple, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _feeCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildParentCard(AdmissionModel rep) {
    return _buildInfoCard([
      _DetailRow(Icons.person, 'Father', rep.fatherName),
      if (rep.fatherPhone.isNotEmpty) _DetailRow(Icons.phone, 'Phone', rep.fatherPhone),
      if (rep.fatherCnic != null && rep.fatherCnic!.isNotEmpty) _DetailRow(Icons.credit_card, 'CNIC', rep.fatherCnic!),
      if (rep.fatherOccupation != null && rep.fatherOccupation!.isNotEmpty)
        _DetailRow(Icons.work_outline, 'Occupation', rep.fatherOccupation!),
      if (rep.motherName.isNotEmpty) ...[
        const SizedBox(height: 4),
        _DetailRow(Icons.person_outline, 'Mother', rep.motherName),
        if (rep.motherPhone != null && rep.motherPhone!.isNotEmpty) _DetailRow(Icons.phone_outlined, 'Mother Phone', rep.motherPhone!),
        if (rep.motherCnic != null && rep.motherCnic!.isNotEmpty) _DetailRow(Icons.credit_card_outlined, 'Mother CNIC', rep.motherCnic!),
      ],
    ]);
  }

  Widget _buildPreviousSchoolCard(AdmissionModel rep) {
    return _buildInfoCard([
      if (rep.previousSchoolName != null) _DetailRow(Icons.school_outlined, 'School', rep.previousSchoolName!),
      if (rep.previousClassName != null) _DetailRow(Icons.class_, 'Class', rep.previousClassName!),
      if (rep.previousClassMarks != null) _DetailRow(Icons.grade_outlined, 'Marks/Grade', rep.previousClassMarks!),
    ]);
  }

  Widget _admissionLabel(AdmissionModel a, int idx) {
    final isRegular = a.type == AdmissionType.regular;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRegular ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isRegular ? Colors.green.shade200 : Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(isRegular ? Icons.verified : Icons.pending_outlined, size: 14, color: isRegular ? Colors.green.shade600 : Colors.blue.shade600),
          const SizedBox(width: 6),
          Text(
            '${a.type.label} — ${a.inquiryOrRegId}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isRegular ? Colors.green.shade700 : Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }
}

class _StudentDetailCard extends StatefulWidget {
  final AdmissionStudent student;
  final AdmissionModel admission;

  const _StudentDetailCard({required this.student, required this.admission});

  @override
  State<_StudentDetailCard> createState() => _StudentDetailCardState();
}

class _StudentDetailCardState extends State<_StudentDetailCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final admission = widget.admission;
    final isRegular = admission.type == AdmissionType.regular;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  s.picBase64 != null
                      ? CircleAvatar(radius: 26, backgroundImage: MemoryImage(base64Decode(s.picBase64!)))
                      : CircleAvatar(
                    radius: 26,
                    backgroundColor: _kPurpleTint,
                    child: Text(
                      s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                      style: const TextStyle(color: _kPurple, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name.isNotEmpty ? s.name : 'Unnamed',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (s.className != null)
                              _smallChip(
                                Icons.class_,
                                s.sectionName != null ? '${s.className} - ${s.sectionName}' : s.className!,
                                Colors.grey.shade100,
                                Colors.grey.shade600,
                              ),
                            const SizedBox(width: 6),
                            _smallChip(
                              isRegular ? Icons.verified : Icons.pending_outlined,
                              isRegular ? 'Regular' : 'Pre',
                              isRegular ? Colors.green.shade50 : Colors.blue.shade50,
                              isRegular ? Colors.green.shade700 : Colors.blue.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (s.monthlyFee != null && s.monthlyFee! > 0)
                        Text('Rs ${s.monthlyFee!.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: _kPurple, fontSize: 14)),
                      const SizedBox(height: 4),
                      Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF9F9FF), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14))),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),
                  _expandRow(Icons.fingerprint, 'Student ID', s.studentId.isNotEmpty ? s.studentId : '—'),
                  if (s.classRollNo != null && s.classRollNo!.isNotEmpty) _expandRow(Icons.format_list_numbered, 'Roll No', s.classRollNo!),
                  if (s.bFormCnic != null && s.bFormCnic!.isNotEmpty) _expandRow(Icons.credit_card_outlined, 'B-Form/CNIC', s.bFormCnic!),
                  if (s.dob != null)
                    _expandRow(
                      Icons.cake_outlined,
                      'Date of Birth',
                      '${s.dob!.day.toString().padLeft(2, '0')}/${s.dob!.month.toString().padLeft(2, '0')}/${s.dob!.year}',
                    ),
                  _expandRow(Icons.badge_outlined, 'Admission ID', admission.inquiryOrRegId),
                  _expandRow(
                    Icons.calendar_today_outlined,
                    'Admission Date',
                    '${admission.admissionDate.day.toString().padLeft(2, '0')}/${admission.admissionDate.month.toString().padLeft(2, '0')}/${admission.admissionDate.year}',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _kPurpleTint, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_outlined, color: _kPurple, size: 15),
                        const SizedBox(width: 6),
                        const Text('Fees: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kPurple)),
                        Text(
                          [
                            if (s.monthlyFee != null && s.monthlyFee! > 0) 'Monthly: Rs ${s.monthlyFee!.toStringAsFixed(0)}',
                            if (s.annualFee != null && s.annualFee! > 0) 'Annual: Rs ${s.annualFee!.toStringAsFixed(0)}',
                            if (s.registrationFee != null && s.registrationFee! > 0) 'Reg: Rs ${s.registrationFee!.toStringAsFixed(0)}',
                          ].join('  •  '),
                          style: const TextStyle(fontSize: 12, color: _kPurple),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _smallChip(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _expandRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 7),
          Text('$label: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }
}