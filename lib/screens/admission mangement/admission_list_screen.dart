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
//   const AdmissionListScreen({super.key});
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
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const AdmissionFormScreen()),
//         ),
//         backgroundColor: _purple,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text('New', style: TextStyle(color: Colors.white)),
//       ),
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
//           const SizedBox(height: 8),
//           ElevatedButton.icon(
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const AdmissionFormScreen()),
//             ),
//             icon: const Icon(Icons.add),
//             label: const Text('Add Admission'),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: _purple, foregroundColor: Colors.white),
//           ),
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
//       itemBuilder: (context, i) => _AdmissionCard(admission: admissions[i]),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// //  Admission Card
// // ─────────────────────────────────────────────
// class _AdmissionCard extends StatefulWidget {
//   final AdmissionModel admission;
//   const _AdmissionCard({required this.admission});
//
//   @override
//   State<_AdmissionCard> createState() => _AdmissionCardState();
// }
//
// class _AdmissionCardState extends State<_AdmissionCard> {
//   bool _expanded = false;
//   static const _purple = Color(0xFF534AB7);
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
//           // ── Header (always visible) ──
//           InkWell(
//             onTap: () => setState(() => _expanded = !_expanded),
//             borderRadius: BorderRadius.circular(14),
//             child: Padding(
//               padding: const EdgeInsets.all(14),
//               child: Row(
//                 children: [
//                   // Type badge
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
//                   IconButton(
//                     icon: const Icon(Icons.edit_outlined, size: 20),
//                     color: _purple,
//                     onPressed: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AdmissionFormScreen(existing: a),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.delete_outline,
//                         size: 20, color: Colors.red),
//                     onPressed: () => _confirmDelete(context, a),
//                   ),
//                   // ---- Convert Button (only for Pre-Admission) ----
//                   if (isPre)
//                     IconButton(
//                       icon: const Icon(Icons.swap_horiz, size: 20),
//                       color: Colors.orange,
//                       tooltip: 'Convert to Regular Admission',
//                       onPressed: () => _confirmConvert(context, a),
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
//
//           // ── AnimatedSize ──
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
//   // ── Details Section ──
//   Widget _buildDetails(AdmissionModel a) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Divider(),
//
//           // ── Family ──
//           if (a.familyId.isNotEmpty)
//             _row(Icons.family_restroom, 'Family ID', a.familyId),
//           if (a.familyName.isNotEmpty)
//             _row(Icons.group_outlined, 'Family Name', a.familyName),
//
//           const SizedBox(height: 6),
//           _sectionLabel('Father Details'),
//           _row(Icons.person, 'Name', a.fatherName),
//           if (a.fatherPhone.isNotEmpty)
//             _row(Icons.phone, 'Phone', a.fatherPhone),
//           if (a.fatherCnic != null && a.fatherCnic!.isNotEmpty)
//             _row(Icons.credit_card, 'CNIC', a.fatherCnic!),
//           if (a.fatherOccupation != null && a.fatherOccupation!.isNotEmpty)
//             _row(Icons.work_outline, 'Occupation', a.fatherOccupation!),
//
//           const SizedBox(height: 6),
//           _sectionLabel('Mother Details'),
//           if (a.motherName.isNotEmpty)
//             _row(Icons.person_outline, 'Name', a.motherName),
//           if (a.motherPhone != null && a.motherPhone!.isNotEmpty)
//             _row(Icons.phone_outlined, 'Phone', a.motherPhone!),
//           if (a.motherCnic != null && a.motherCnic!.isNotEmpty)
//             _row(Icons.credit_card_outlined, 'CNIC', a.motherCnic!),
//
//           // ── Extra Info ──
//           if (a.caste != null && a.caste!.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             _row(Icons.diversity_3_outlined, 'Caste', a.caste!),
//           ],
//           if (a.address != null && a.address!.isNotEmpty)
//             _row(Icons.home_outlined, 'Address', a.address!),
//
//           // ── Previous School ──
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
//
//           // ── Students ──
//           const SizedBox(height: 10),
//           _sectionLabel('Students (${a.students.length})'),
//           const SizedBox(height: 6),
//           ...a.students.map((s) => _buildStudentChip(s)),
//         ],
//       ),
//     );
//   }
//
//   // ── Student Chip ──
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
//             // Photo
//             _studentAvatar(s.picBase64),
//             const SizedBox(width: 12),
//
//             // Info
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
//
//                   // Student ID
//                   if (s.studentId.isNotEmpty)
//                     _chip(Icons.fingerprint, 'ID: ${s.studentId}',
//                         Colors.purple),
//
//                   // Class / Section
//                   if (s.className != null && s.className!.isNotEmpty)
//                     _chip(
//                       Icons.class_,
//                       s.sectionName != null && s.sectionName!.isNotEmpty
//                           ? '${s.className} — ${s.sectionName}'
//                           : s.className!,
//                       Colors.blue,
//                     ),
//
//                   // Roll No
//                   if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
//                     _chip(Icons.format_list_numbered,
//                         'Roll No: ${s.classRollNo}', Colors.teal),
//
//                   // B-Form
//                   if (s.bFormCnic != null && s.bFormCnic!.isNotEmpty)
//                     _chip(Icons.credit_card_outlined,
//                         'B-Form: ${s.bFormCnic}', Colors.indigo),
//
//                   // DOB
//                   if (s.dob != null)
//                     _chip(
//                       Icons.cake_outlined,
//                       'DOB: ${s.dob!.day.toString().padLeft(2, '0')}/'
//                           '${s.dob!.month.toString().padLeft(2, '0')}/'
//                           '${s.dob!.year}',
//                       Colors.pink,
//                     ),
//
//                   // Fees row
//                   if (s.monthlyFee != null ||
//                       s.annualFee != null ||
//                       s.registrationFee != null) ...[
//                     const SizedBox(height: 6),
//                     Wrap(
//                       spacing: 6,
//                       runSpacing: 4,
//                       children: [
//                         if (s.monthlyFee != null)
//                           _feeBadge(
//                               'Monthly', s.monthlyFee!, Colors.green),
//                         if (s.annualFee != null)
//                           _feeBadge('Annual', s.annualFee!, Colors.orange),
//                         if (s.registrationFee != null)
//                           _feeBadge(
//                               'Reg.', s.registrationFee!, Colors.purple),
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
//         style: TextStyle(
//             fontSize: 11, color: color.withOpacity(0.7), fontWeight: FontWeight.w600),
//       ),
//     );
//   }
//
//   // ── Row helper ──
//   Widget _row(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 15, color: Colors.grey.shade500),
//           const SizedBox(width: 8),
//           Text('$label: ',
//               style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey.shade600,
//                   fontWeight: FontWeight.w500)),
//           Expanded(
//             child: Text(value,
//                 style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
//         style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF534AB7),
//             letterSpacing: 0.3),
//       ),
//     );
//   }
//
//   // ── Delete Confirm ──
//   void _confirmDelete(BuildContext context, AdmissionModel a) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Delete Admission'),
//         content: Text(
//             'Delete admission ${a.inquiryOrRegId} for ${a.fatherName}?'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(ctx, false),
//               child: const Text('Cancel')),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child:
//             const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true && a.id != null) {
//       try {
//         await context.read<AdmissionProvider>().deleteAdmission(a.id!);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('Failed: $e'), backgroundColor: Colors.red));
//       }
//     }
//   }
//
//   // ---- Convert Confirm (new) ----
// // Inside _AdmissionCardState class
//   void _confirmConvert(BuildContext context, AdmissionModel a) async {
//     // 1. Pick a registration date first
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.fromSeed(seedColor: _purple),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     // If user cancels date picker, abort entire conversion
//     if (pickedDate == null || !context.mounted) return;
//
//     // 2. Confirmation dialog
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
//             child: const Text(
//               'Convert',
//               style: TextStyle(color: Colors.orange),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true && context.mounted) {
//       try {
//         await context
//             .read<AdmissionProvider>()
//             .convertToRegular(a, customDate: pickedDate);
//
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Converted to Regular Admission successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Conversion failed: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }
//   // void _confirmConvert(BuildContext context, AdmissionModel a) async {
//   //   final confirmed = await showDialog<bool>(
//   //     context: context,
//   //     builder: (ctx) => AlertDialog(
//   //       title: const Text('Convert to Regular Admission'),
//   //       content: const Text(
//   //         'This will create a new Regular Admission using the same details '
//   //             'and delete this Pre-Admission record. Continue?',
//   //       ),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(ctx, false),
//   //           child: const Text('Cancel'),
//   //         ),
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(ctx, true),
//   //           child: const Text(
//   //             'Convert',
//   //             style: TextStyle(color: Colors.orange),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   //
//   //   if (confirmed == true && context.mounted) {
//   //     try {
//   //       await context.read<AdmissionProvider>().convertToRegular(a);
//   //       if (context.mounted) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(
//   //             content: Text('Converted to Regular Admission successfully'),
//   //             backgroundColor: Colors.green,
//   //           ),
//   //         );
//   //       }
//   //     } catch (e) {
//   //       if (context.mounted) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           SnackBar(
//   //             content: Text('Conversion failed: $e'),
//   //             backgroundColor: Colors.red,
//   //           ),
//   //         );
//   //       }
//   //     }
//   //   }
//   // }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admission_model.dart';
import '../../providers/admission_provider.dart';
import 'add_admission_screen.dart';

class AdmissionListScreen extends StatefulWidget {
  const AdmissionListScreen({super.key});

  @override
  State<AdmissionListScreen> createState() => _AdmissionListScreenState();
}

class _AdmissionListScreenState extends State<AdmissionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _purple = Color(0xFF534AB7);

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdmissionFormScreen()),
        ),
        backgroundColor: _purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New', style: TextStyle(color: Colors.white)),
      ),
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
          if (provider.admissions.isEmpty) {
            return _buildEmpty();
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.admissions),
              _buildList(provider.admissions
                  .where((a) => a.type == AdmissionType.preAdmission)
                  .toList()),
              _buildList(provider.admissions
                  .where((a) => a.type == AdmissionType.regular)
                  .toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No admissions yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
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
      ),
    );
  }

  Widget _buildList(List<AdmissionModel> admissions) {
    if (admissions.isEmpty) {
      return Center(
          child: Text('No records found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admissions.length,
      itemBuilder: (context, i) => _AdmissionCard(admission: admissions[i]),
    );
  }
}

// ─────────────────────────────────────────────
//  Admission Card
// ─────────────────────────────────────────────
class _AdmissionCard extends StatefulWidget {
  final AdmissionModel admission;
  const _AdmissionCard({required this.admission});

  @override
  State<_AdmissionCard> createState() => _AdmissionCardState();
}

class _AdmissionCardState extends State<_AdmissionCard> {
  bool _expanded = false;
  bool _converting = false;   // ✅ local loading state
  static const _purple = Color(0xFF534AB7);

  @override
  Widget build(BuildContext context) {
    final a = widget.admission;
    final isPre = a.type == AdmissionType.preAdmission;
    final typeColor = isPre ? Colors.orange : Colors.green;
    final dateStr =
        '${a.admissionDate.day.toString().padLeft(2, '0')}/${a.admissionDate.month.toString().padLeft(2, '0')}/${a.admissionDate.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: typeColor),
                    ),
                    child: Text(
                      isPre ? 'Pre' : 'Reg',
                      style: TextStyle(
                          fontSize: 11,
                          color: typeColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.fatherName.isNotEmpty
                              ? a.fatherName
                              : 'Family: ${a.familyName}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${a.inquiryOrRegId} • $dateStr',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          '${a.students.length} student(s)',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: _purple,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdmissionFormScreen(existing: a),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(context, a),
                  ),
                  // ✅ Convert Button with loading indicator
                  if (isPre)
                    IconButton(
                      icon: _converting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange,
                        ),
                      )
                          : const Icon(Icons.swap_horiz, size: 20),
                      color: Colors.orange,
                      tooltip: 'Convert to Regular Admission',
                      onPressed: _converting ? null : () => _confirmConvert(context, a),
                    ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          // ── AnimatedSize ──
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
      }
    }
  }

  // ✅ Convert Confirm with loading state and date picker
  void _confirmConvert(BuildContext context, AdmissionModel a) async {
    // 1. Pick a registration date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: _purple),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !context.mounted) return;

    // 2. Confirmation dialog
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Convert', style: TextStyle(color: Colors.orange))),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // ✅ Start loading
    setState(() => _converting = true);

    try {
      await context.read<AdmissionProvider>().convertToRegular(a, customDate: pickedDate);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Converted to Regular Admission successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversion failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // ✅ Stop loading
      if (mounted) {
        setState(() => _converting = false);
      }
    }
  }
}