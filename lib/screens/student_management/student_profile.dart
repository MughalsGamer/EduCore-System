//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../../models/admission_model.dart';
// import '../../providers/student_provider.dart';
//
// class StudentProfileScreen extends StatelessWidget {
//   final StudentWithContext data;
//   const StudentProfileScreen({super.key, required this.data});
//
//   static const _purple      = Color(0xFF534AB7);
//   static const _purpleLight = Color(0xFFEEECFA);
//   static const _purpleDark  = Color(0xFF3D3589);
//
//   @override
//   Widget build(BuildContext context) {
//     final s = data.student;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F8),
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 280,
//             pinned: true,
//             backgroundColor: _purple,
//             iconTheme: const IconThemeData(color: Colors.white),
//             flexibleSpace: FlexibleSpaceBar(
//               background: _buildHeader(s, data),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
//               child: Column(
//                 children: [
//                   _buildStatRow(s, data),
//                   const SizedBox(height: 16),
//
//                   // Fee Structure (now includes Academy)
//                   if (s.monthlyFee != null ||
//                       s.annualFee != null ||
//                       s.registrationFee != null ||
//                       (s.academyFee != null && s.academyFee! > 0)) ...[
//                     _buildFeeCard(s, context), // <-- PASS context HERE
//                     const SizedBox(height: 16),
//                   ],
//
//                   _buildSection(
//                     icon: Icons.school_outlined,
//                     title: 'Student Information',
//                     iconBg: _purpleLight,
//                     iconColor: _purple,
//                     rows: [
//                       if (s.studentId.isNotEmpty)
//                         _InfoRow('Student ID', s.studentId, highlight: true),
//                       if (s.className != null && s.className!.isNotEmpty)
//                         _InfoRow(
//                           'Class',
//                           (s.sectionName != null && s.sectionName!.isNotEmpty)
//                               ? '${s.className} — ${s.sectionName}'
//                               : s.className!,
//                         ),
//                       if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
//                         _InfoRow('Roll No', s.classRollNo!),
//                       if (s.bFormCnic != null && s.bFormCnic!.isNotEmpty)
//                         _InfoRow('B-Form / CNIC', s.bFormCnic!),
//                       if (s.dob != null)
//                         _InfoRow(
//                           'Date of Birth',
//                           '${s.dob!.day.toString().padLeft(2, '0')}/'
//                               '${s.dob!.month.toString().padLeft(2, '0')}/'
//                               '${s.dob!.year}',
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//
//                   _buildSection(
//                     icon: Icons.confirmation_number_outlined,
//                     title: 'Admission Details',
//                     iconBg: const Color(0xFFE8F5E9),
//                     iconColor: const Color(0xFF2E7D32),
//                     rows: [
//                       _InfoRow('Reg / Inq ID', data.inquiryOrRegId, highlight: true),
//                       _InfoRow(
//                         'Admission Date',
//                         '${data.admissionDate.day.toString().padLeft(2, '0')}/'
//                             '${data.admissionDate.month.toString().padLeft(2, '0')}/'
//                             '${data.admissionDate.year}',
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//
//                   _buildSection(
//                     icon: Icons.family_restroom_outlined,
//                     title: 'Family Information',
//                     iconBg: const Color(0xFFFFF3E0),
//                     iconColor: const Color(0xFFE65100),
//                     rows: [
//                       if (data.familyId.isNotEmpty)
//                         _InfoRow('Family ID', data.familyId),
//                       if (data.familyName.isNotEmpty)
//                         _InfoRow('Family Name', data.familyName),
//                       if (data.address != null && data.address!.isNotEmpty)
//                         _InfoRow('Address', data.address!),
//                       if (data.caste != null && data.caste!.isNotEmpty)
//                         _InfoRow('Caste', data.caste!),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//
//                   _buildSection(
//                     icon: Icons.person,
//                     title: 'Father Information',
//                     iconBg: const Color(0xFFE3F2FD),
//                     iconColor: const Color(0xFF1565C0),
//                     rows: [
//                       if (data.fatherName.isNotEmpty)
//                         _InfoRow('Name', data.fatherName),
//                       if (data.fatherPhone.isNotEmpty)
//                         _InfoRow('Phone', data.fatherPhone),
//                       if (data.fatherCnic != null && data.fatherCnic!.isNotEmpty)
//                         _InfoRow('CNIC', data.fatherCnic!),
//                       if (data.fatherOccupation != null && data.fatherOccupation!.isNotEmpty)
//                         _InfoRow('Occupation', data.fatherOccupation!),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//
//                   _buildSection(
//                     icon: Icons.person_outline,
//                     title: 'Mother Information',
//                     iconBg: const Color(0xFFFCE4EC),
//                     iconColor: const Color(0xFFC62828),
//                     rows: [
//                       if (data.motherName.isNotEmpty)
//                         _InfoRow('Name', data.motherName),
//                       if (data.motherPhone != null && data.motherPhone!.isNotEmpty)
//                         _InfoRow('Phone', data.motherPhone!),
//                       if (data.motherCnic != null && data.motherCnic!.isNotEmpty)
//                         _InfoRow('CNIC', data.motherCnic!),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Header ──
//   Widget _buildHeader(AdmissionStudent s, StudentWithContext d) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [_purpleDark, _purple, Color(0xFF7B6FD0)],
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 44),
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 3),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.25),
//                     blurRadius: 16,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: ClipOval(child: _avatarContent(s)),
//             ),
//             const SizedBox(height: 14),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Text(
//                 s.name.isNotEmpty ? s.name : '—',
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 0.3,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             const SizedBox(height: 6),
//             if (s.className != null && s.className!.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.white30),
//                 ),
//                 child: Text(
//                   '🎓 ${s.sectionName != null && s.sectionName!.isNotEmpty ? "${s.className} — ${s.sectionName}" : s.className!}',
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (s.studentId.isNotEmpty)
//                   _QuickStat(icon: Icons.badge_outlined, label: s.studentId),
//                 if (s.studentId.isNotEmpty &&
//                     s.classRollNo != null &&
//                     s.classRollNo!.isNotEmpty)
//                   Container(
//                     height: 16,
//                     width: 1,
//                     color: Colors.white30,
//                     margin: const EdgeInsets.symmetric(horizontal: 12),
//                   ),
//                 if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
//                   _QuickStat(
//                     icon: Icons.format_list_numbered,
//                     label: 'Roll: ${s.classRollNo}',
//                   ),
//               ],
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _avatarContent(AdmissionStudent s) {
//     if (s.picBase64 != null && s.picBase64!.isNotEmpty) {
//       try {
//         return Image.memory(
//           base64Decode(s.picBase64!),
//           fit: BoxFit.cover,
//           width: 100,
//           height: 100,
//         );
//       } catch (_) {}
//     }
//     return Container(
//       color: Colors.white24,
//       width: 100,
//       height: 100,
//       child: Center(
//         child: Text(
//           _initials(s.name),
//           style: const TextStyle(
//             fontSize: 34,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Stat Row ──
//   Widget _buildStatRow(AdmissionStudent s, StudentWithContext d) {
//     return Row(
//       children: [
//         Expanded(
//           child: _statTile(
//             icon: Icons.confirmation_number_outlined,
//             label: 'Reg / Inq ID',
//             value: d.inquiryOrRegId,
//             color: const Color(0xFF2E7D32),
//             bg: const Color(0xFFE8F5E9),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: _statTile(
//             icon: s.classRollNo != null && s.classRollNo!.isNotEmpty
//                 ? Icons.format_list_numbered
//                 : Icons.calendar_today_outlined,
//             label: s.classRollNo != null && s.classRollNo!.isNotEmpty
//                 ? 'Roll No'
//                 : 'Admitted On',
//             value: s.classRollNo != null && s.classRollNo!.isNotEmpty
//                 ? s.classRollNo!
//                 : '${d.admissionDate.day.toString().padLeft(2, '0')}/'
//                 '${d.admissionDate.month.toString().padLeft(2, '0')}/'
//                 '${d.admissionDate.year}',
//             color: _purple,
//             bg: _purpleLight,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _statTile({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//     required Color bg,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 16, color: color),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: color.withOpacity(0.7),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: color,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Fee Card (now includes Academy) – accepts BuildContext ──
//   Widget _buildFeeCard(AdmissionStudent s, BuildContext context) {
//     // Determine which fee tiles to show
//     final tiles = <Widget>[];
//     if (s.monthlyFee != null) {
//       tiles.add(_feeTile('Monthly', s.monthlyFee!, const Color(0xFF1565C0), const Color(0xFFE3F2FD)));
//     }
//     if (s.academyFee != null && s.academyFee! > 0) {
//       tiles.add(_feeTile('Academy', s.academyFee!, const Color(0xFF8B5CF6), const Color(0xFFF3E8FF)));
//     }
//     if (s.annualFee != null) {
//       tiles.add(_feeTile('Annual', s.annualFee!, const Color(0xFFE65100), const Color(0xFFFFF3E0)));
//     }
//     if (s.registrationFee != null) {
//       tiles.add(_feeTile('Reg.', s.registrationFee!, const Color(0xFF6A1B9A), const Color(0xFFF3E5F5)));
//     }
//
//     if (tiles.isEmpty) return const SizedBox.shrink();
//
//     // Calculate width per tile – use context now
//     final screenWidth = MediaQuery.of(context).size.width;
//     final tileWidth = (screenWidth - 64) / 2 - 8; // two per row with spacing
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE8F5E9),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.payments_outlined,
//                     size: 16, color: Color(0xFF2E7D32)),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Fee Structure',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1A1A2E),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: tiles.map((tile) => SizedBox(
//               width: tileWidth,
//               child: tile,
//             )).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _feeTile(String label, double amount, Color color, Color bg) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               color: color.withOpacity(0.7),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Rs ${amount.toStringAsFixed(0)}',
//             style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Info Section Card ──
//   Widget _buildSection({
//     required IconData icon,
//     required String title,
//     required Color iconBg,
//     required Color iconColor,
//     required List<_InfoRow> rows,
//   }) {
//     final visible = rows.where((r) => r.value.isNotEmpty).toList();
//     if (visible.isEmpty) return const SizedBox.shrink();
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: iconBg,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, size: 16, color: iconColor),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1A2E),
//                     letterSpacing: 0.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1, color: Color(0xFFF0F0F5)),
//           ...visible.asMap().entries.map(
//                 (e) => _infoRow(e.value, e.key == visible.length - 1),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _infoRow(_InfoRow row, bool isLast) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: 120,
//                 child: Text(
//                   row.label,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF888899),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   row.value,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight:
//                     row.highlight ? FontWeight.bold : FontWeight.w500,
//                     color:
//                     row.highlight ? _purple : const Color(0xFF1A1A2E),
//                   ),
//                   textAlign: TextAlign.end,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (!isLast)
//           const Divider(
//             height: 1,
//             indent: 16,
//             endIndent: 16,
//             color: Color(0xFFF0F0F5),
//           ),
//       ],
//     );
//   }
//
//   String _initials(String name) {
//     final parts = name.trim().split(' ');
//     if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     return parts[0]
//         .substring(0, parts[0].length >= 2 ? 2 : 1)
//         .toUpperCase();
//   }
// }
//
// // ── Helper classes ──
// class _InfoRow {
//   final String label;
//   final String value;
//   final bool highlight;
//   const _InfoRow(this.label, this.value, {this.highlight = false});
// }
//
// class _QuickStat extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   const _QuickStat({required this.icon, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 13, color: Colors.white70),
//         const SizedBox(width: 5),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.white70,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admission_model.dart';
import '../../providers/student_provider.dart';

class StudentProfileScreen extends StatelessWidget {
  final StudentWithContext data;
  const StudentProfileScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Live lookup so deactivate/rejoin changes reflect immediately —
    // falls back to the snapshot passed in if the stream hasn't caught up.
    final fresh = context.watch<StudentProvider>().findStudent(
      data.admissionId,
      data.student.studentId,
    ) ??
        data;

    return Scaffold(
      backgroundColor: const Color(0xFFF0EFF8),
      appBar: AppBar(
        title: const Text(
          'Student Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF534AB7),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StudentProfileView(data: fresh),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Core view — same visual language as StaffProfileView (purple sidebar,
// history timeline, status banner) but built from student data.
// ─────────────────────────────────────────────────────────────────────────────
class StudentProfileView extends StatelessWidget {
  final StudentWithContext data;
  final VoidCallback? onClose;

  const StudentProfileView({super.key, required this.data, this.onClose});

  static const _purple = Color(0xFF534AB7);
  static const _purpleLight = Color(0xFFF0EFFE);
  static const _purpleDark = Color(0xFF3D3589);
  static const _purpleAccent = Color(0xFF7B6FD0);
  static const _red = Color(0xFFB91C1C);
  static const _redBg = Color(0xFFFEF2F2);
  static const _blue = Color(0xFF2563EB);
  static const _green = Color(0xFF15803D);
  static const _orange = Color(0xFFB45309);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 260, child: SingleChildScrollView(child: _buildSidebar(context))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Student Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      if (onClose != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: onClose,
                          tooltip: 'Close',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._contentWidgets(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 640, child: _buildSidebar(context)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: _contentWidgets(context)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  //  Content sections (right side / below sidebar)
  // ─────────────────────────────────────
  List<Widget> _contentWidgets(BuildContext context) {
    final s = data.student;
    final d = data;

    return [
      if (!s.isActive) ...[
        _buildDeactivatedBanner(),
        const SizedBox(height: 14),
      ],

      // Fee Structure
      if (s.monthlyFee != null ||
          s.annualFee != null ||
          s.registrationFee != null ||
          (s.academyFee != null && s.academyFee! > 0)) ...[
        _buildFeeCard(s, context),
        const SizedBox(height: 14),
      ],

      _buildInfoCard(
        icon: Icons.school_outlined,
        title: 'Student Information',
        rows: [
          _InfoRow('Student ID', s.studentId, highlight: true),
          if (s.className != null && s.className!.isNotEmpty)
            _InfoRow(
              'Class',
              (s.sectionName != null && s.sectionName!.isNotEmpty)
                  ? '${s.className} — ${s.sectionName}'
                  : s.className!,
            ),
          if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
            _InfoRow('Roll No', s.classRollNo!),
          _InfoRow('Institution', _institutionLabel(s)),
          if (s.hasAcademy && s.academyName != null && s.academyName!.isNotEmpty)
            _InfoRow('Academy', s.academyName!),
          if (s.bFormCnic != null && s.bFormCnic!.isNotEmpty)
            _InfoRow('B-Form / CNIC', s.bFormCnic!),
          if (s.dob != null)
            _InfoRow(
              'Date of Birth',
              '${s.dob!.day.toString().padLeft(2, '0')}/'
                  '${s.dob!.month.toString().padLeft(2, '0')}/'
                  '${s.dob!.year}',
            ),
        ],
      ),
      const SizedBox(height: 14),

      _buildInfoCard(
        icon: Icons.confirmation_number_outlined,
        title: 'Admission Details',
        rows: [
          _InfoRow('Reg / Inq ID', d.inquiryOrRegId, highlight: true),
          _InfoRow('Type', d.admissionType.label),
          _InfoRow(
            'Admission Date',
            '${d.admissionDate.day.toString().padLeft(2, '0')}/'
                '${d.admissionDate.month.toString().padLeft(2, '0')}/'
                '${d.admissionDate.year}',
          ),
        ],
      ),

      // Previous School Info — was missing entirely before
      if ((d.previousSchoolName != null && d.previousSchoolName!.isNotEmpty) ||
          (d.previousClassName != null && d.previousClassName!.isNotEmpty) ||
          (d.previousClassMarks != null && d.previousClassMarks!.isNotEmpty)) ...[
        const SizedBox(height: 14),
        _buildInfoCard(
          icon: Icons.history_edu_outlined,
          title: 'Previous School Info',
          rows: [
            if (d.previousSchoolName != null && d.previousSchoolName!.isNotEmpty)
              _InfoRow('Previous School', d.previousSchoolName!),
            if (d.previousClassName != null && d.previousClassName!.isNotEmpty)
              _InfoRow('Previous Class', d.previousClassName!),
            if (d.previousClassMarks != null && d.previousClassMarks!.isNotEmpty)
              _InfoRow('Marks / Grade', d.previousClassMarks!),
          ],
        ),
      ],
      const SizedBox(height: 14),

      _buildInfoCard(
        icon: Icons.family_restroom_outlined,
        title: 'Family Information',
        rows: [
          if (d.familyId.isNotEmpty) _InfoRow('Family ID', d.familyId),
          if (d.familyName.isNotEmpty) _InfoRow('Family Name', d.familyName),
          if (d.address != null && d.address!.isNotEmpty) _InfoRow('Address', d.address!),
          if (d.caste != null && d.caste!.isNotEmpty) _InfoRow('Caste', d.caste!),
        ],
      ),
      const SizedBox(height: 14),

      _buildInfoCard(
        icon: Icons.person,
        title: 'Father Information',
        rows: [
          if (d.fatherName.isNotEmpty) _InfoRow('Name', d.fatherName),
          if (d.fatherPhone.isNotEmpty) _InfoRow('Phone', d.fatherPhone),
          if (d.fatherCnic != null && d.fatherCnic!.isNotEmpty)
            _InfoRow('CNIC', d.fatherCnic!),
          if (d.fatherOccupation != null && d.fatherOccupation!.isNotEmpty)
            _InfoRow('Occupation', d.fatherOccupation!),
        ],
      ),
      const SizedBox(height: 14),

      _buildInfoCard(
        icon: Icons.person_outline,
        title: 'Mother Information',
        rows: [
          if (d.motherName.isNotEmpty) _InfoRow('Name', d.motherName),
          if (d.motherPhone != null && d.motherPhone!.isNotEmpty)
            _InfoRow('Phone', d.motherPhone!),
          if (d.motherCnic != null && d.motherCnic!.isNotEmpty)
            _InfoRow('CNIC', d.motherCnic!),
        ],
      ),

      // Deactivation note (visible even after rejoin, kept in read-only view)
      if (s.deactivationNote != null && s.deactivationNote!.isNotEmpty && !s.isActive) ...[
        const SizedBox(height: 14),
        _buildNoteCard(s.deactivationNote!),
      ],
    ];
  }

  String _institutionLabel(AdmissionStudent s) {
    if (s.hasSchool && s.hasAcademy) return '🏫 School & Academy';
    if (s.hasAcademy) return '📘 Academy Only';
    return '🏫 School';
  }

  // ─────────────────────────────────────
  //  Deactivated banner (mirrors staff's terminated banner)
  // ─────────────────────────────────────
  Widget _buildDeactivatedBanner() {
    final s = data.student;
    final isTerminated = s.deactivationReason == 'terminated';
    final label = isTerminated ? 'Terminated' : 'Left School';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _redBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_off_rounded, color: _red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deactivated — $label',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: _red)),
                if (s.deactivationDate != null && s.deactivationDate!.isNotEmpty)
                  Text('Since: ${_formatDate(s.deactivationDate)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sticky_note_2_outlined,
                    size: 16, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Deactivation Note',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            note,
            style: const TextStyle(fontSize: 13, color: Color(0xFF78350F), height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  //  Fee card
  // ─────────────────────────────────────
  Widget _buildFeeCard(AdmissionStudent s, BuildContext context) {
    final tiles = <Widget>[];
    if (s.monthlyFee != null) {
      tiles.add(_feeTile('Monthly', s.monthlyFee!, const Color(0xFF1565C0), const Color(0xFFE3F2FD)));
    }
    if (s.academyFee != null && s.academyFee! > 0) {
      tiles.add(_feeTile('Academy', s.academyFee!, const Color(0xFF8B5CF6), const Color(0xFFF3E8FF)));
    }
    if (s.annualFee != null) {
      tiles.add(_feeTile('Annual', s.annualFee!, const Color(0xFFE65100), const Color(0xFFFFF3E0)));
    }
    if (s.registrationFee != null) {
      tiles.add(_feeTile('Reg.', s.registrationFee!, const Color(0xFF6A1B9A), const Color(0xFFF3E5F5)));
    }
    if (tiles.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final tileWidth = (screenWidth - 64) / 2 - 8;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEF5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 10),
              const Text('Fee Structure',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tiles.map((tile) => SizedBox(width: tileWidth, child: tile)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _feeTile(String label, double amount, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Rs ${amount.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  //  Generic info card (same look as staff's)
  // ─────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
    final visible = rows.where((r) => r.value.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEF5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: _purpleLight, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 16, color: _purple),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          ...visible.asMap().entries.map((e) {
            final isLast = e.key == visible.length - 1;
            final row = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(row.label,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF888899), fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        child: Text(
                          row.value,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: row.highlight ? FontWeight.bold : FontWeight.w500,
                            color: row.highlight ? _purple : const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F5)),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  //  Sidebar (purple gradient — same as staff)
  // ─────────────────────────────────────
  Widget _buildSidebar(BuildContext context) {
    final s = data.student;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_purpleDark, _purple, _purpleAccent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: ClipOval(child: _avatarContent(s)),
          ),
          const SizedBox(height: 16),
          Text(
            s.name.isNotEmpty ? s.name : '—',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Text('🎓 Student',
                    style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: s.isActive ? Colors.green.withOpacity(0.25) : Colors.red.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: s.isActive ? Colors.green.shade100 : Colors.red.shade100),
                ),
                child: Text(
                  s.isActive ? 'Active' : 'Deactivated',
                  style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 16),
          if (data.fatherPhone.isNotEmpty) _sidebarRow(Icons.phone_outlined, data.fatherPhone),
          if (s.studentId.isNotEmpty) ...[
            const SizedBox(height: 8),
            _sidebarRow(Icons.badge_outlined, s.studentId),
          ],
          if (s.className != null && s.className!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _sidebarRow(
              Icons.class_outlined,
              (s.sectionName != null && s.sectionName!.isNotEmpty)
                  ? '${s.className} — ${s.sectionName}'
                  : s.className!,
            ),
          ],
          const SizedBox(height: 8),
          _sidebarRow(Icons.calendar_today_outlined, 'Admitted ${_formatDate(data.admissionDate.toIso8601String())}'),
          if (!s.isActive && s.deactivationDate != null && s.deactivationDate!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _sidebarRow(Icons.event_busy_outlined, 'Deactivated ${_formatDate(s.deactivationDate)}'),
          ],
          const SizedBox(height: 16),
          _buildActionButton(context),
          _buildHistoryBlock(),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final s = data.student;
    if (s.isActive) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showDeactivateDialog(context),
          icon: const Icon(Icons.person_off_outlined, size: 16, color: Colors.white),
          label: const Text('Deactivate', style: TextStyle(color: Colors.white)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white54),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showRejoinDialog(context),
        icon: const Icon(Icons.restart_alt, size: 16, color: _purpleDark),
        label: const Text('Rejoin', style: TextStyle(color: _purpleDark, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Future<void> _showDeactivateDialog(BuildContext context) async {
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
          SnackBar(content: Text('${data.student.name} deactivated'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showRejoinDialog(BuildContext context) async {
    final result = await showDialog<_RejoinResult>(
      context: context,
      builder: (_) => _RejoinStudentDialog(student: data.student),
    );
    if (result == null || !context.mounted) return;
    try {
      await context.read<StudentProvider>().rejoinStudent(
        context: data,
        date: result.date,
        note: result.note,
        className: result.className,
        sectionName: result.sectionName,
        classId: data.student.classId,
        sectionId: data.student.sectionId,
        monthlyFee: result.monthlyFee,
        annualFee: result.annualFee,
        registrationFee: result.registrationFee,
        hasAcademy: data.student.hasAcademy,
        academyId: data.student.academyId,
        academyName: data.student.academyName,
        academyFee: result.academyFee,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${data.student.name} rejoined'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _sidebarRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _avatarContent(AdmissionStudent s) {
    if (s.picBase64 != null && s.picBase64!.isNotEmpty) {
      try {
        return Image.memory(base64Decode(s.picBase64!), fit: BoxFit.cover, width: 110, height: 110);
      } catch (_) {}
    }
    return Container(
      color: Colors.white24,
      width: 110,
      height: 110,
      child: Center(
        child: Text(
          _initials(s.name),
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  //  History timeline — joined (admissionDate) + statusHistory events
  // ─────────────────────────────────────
  List<_TimelineEvent> _buildHistoryEvents() {
    final s = data.student;
    final events = <_TimelineEvent>[
      _TimelineEvent(
        type: 'joined',
        date: data.admissionDate.toIso8601String().split('T').first,
        note: null,
      ),
    ];
    for (final e in s.statusHistory) {
      events.add(_TimelineEvent(type: e.type, date: e.date, reason: e.reason, note: e.note));
    }
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  Widget _buildHistoryBlock() {
    final events = _buildHistoryEvents();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.history, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('Admission History',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          ...events.asMap().entries.map(
                (e) => _historyTile(e.value, isLast: e.key == events.length - 1),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(_TimelineEvent e, {required bool isLast}) {
    late final String label;
    late final Color color;
    late final IconData icon;
    switch (e.type) {
      case 'joined':
        label = 'Admitted';
        color = _blue;
        icon = Icons.login;
        break;
      case 'deactivated':
        final isTerminated = e.reason == 'terminated';
        label = isTerminated ? 'Terminated' : 'Left School';
        color = isTerminated ? _red : _orange;
        icon = Icons.logout;
        break;
      case 'rejoined':
        label = 'Rejoined';
        color = _green;
        icon = Icons.restart_alt;
        break;
      default:
        label = e.type;
        color = Colors.grey;
        icon = Icons.circle;
    }

    final lightColor = Color.alphaBlend(Colors.white.withOpacity(0.55), color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
              child: Icon(icon, size: 12, color: Colors.white),
            ),
            if (!isLast) Container(width: 2, height: 26, color: Colors.white24),
          ]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: lightColor)),
                const SizedBox(height: 1),
                Text(_formatDate(e.date), style: const TextStyle(fontSize: 11, color: Colors.white70)),
                if (e.note != null && e.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(e.note!, style: const TextStyle(fontSize: 11, color: Colors.white60)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}

class _TimelineEvent {
  final String type;
  final String date;
  final String? reason;
  final String? note;
  _TimelineEvent({required this.type, required this.date, this.reason, this.note});
}

class _InfoRow {
  final String label;
  final String value;
  final bool highlight;
  const _InfoRow(this.label, this.value, {this.highlight = false});
}

// ─────────────────────────────────────────────────────────────────────────────
// Deactivate dialog (same as the one in student_list.dart)
// ─────────────────────────────────────────────────────────────────────────────
class _DeactivateResult {
  final String reason;
  final DateTime date;
  final String? note;
  _DeactivateResult({required this.reason, required this.date, this.note});
}

class _DeactivateStudentDialog extends StatefulWidget {
  final String studentName;
  const _DeactivateStudentDialog({required this.studentName});

  @override
  State<_DeactivateStudentDialog> createState() => _DeactivateStudentDialogState();
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
      title: const Text('Deactivate Student', style: TextStyle(fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"${widget.studentName}" will be moved to the Deactivated list.'),
            const SizedBox(height: 16),
            const Text('Reason *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _reasonChip(label: 'Left School', value: 'left_school')),
                const SizedBox(width: 8),
                Expanded(child: _reasonChip(label: 'Terminated', value: 'terminated')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Date *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
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
            const Text('Note (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
          child: Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rejoin dialog — class/section/fees default to the student's OLD values
// but every field stays editable, per your requirement.
// ─────────────────────────────────────────────────────────────────────────────
class _RejoinResult {
  final DateTime date;
  final String? note;
  final String className;
  final String sectionName;
  final double? monthlyFee;
  final double? annualFee;
  final double? registrationFee;
  final double? academyFee;
  _RejoinResult({
    required this.date,
    this.note,
    required this.className,
    required this.sectionName,
    this.monthlyFee,
    this.annualFee,
    this.registrationFee,
    this.academyFee,
  });
}

class _RejoinStudentDialog extends StatefulWidget {
  final AdmissionStudent student;
  const _RejoinStudentDialog({required this.student});

  @override
  State<_RejoinStudentDialog> createState() => _RejoinStudentDialogState();
}

class _RejoinStudentDialogState extends State<_RejoinStudentDialog> {
  static const _purple = Color(0xFF534AB7);
  late DateTime _date;
  late TextEditingController _noteCtrl;
  late TextEditingController _classCtrl;
  late TextEditingController _sectionCtrl;
  late TextEditingController _monthlyCtrl;
  late TextEditingController _annualCtrl;
  late TextEditingController _regCtrl;
  late TextEditingController _academyCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _date = DateTime.now();
    _noteCtrl = TextEditingController();
    _classCtrl = TextEditingController(text: s.className ?? '');
    _sectionCtrl = TextEditingController(text: s.sectionName ?? '');
    _monthlyCtrl = TextEditingController(text: s.monthlyFee?.toStringAsFixed(0) ?? '');
    _annualCtrl = TextEditingController(text: s.annualFee?.toStringAsFixed(0) ?? '');
    _regCtrl = TextEditingController(text: s.registrationFee?.toStringAsFixed(0) ?? '');
    _academyCtrl = TextEditingController(text: s.academyFee?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _classCtrl.dispose();
    _sectionCtrl.dispose();
    _monthlyCtrl.dispose();
    _annualCtrl.dispose();
    _regCtrl.dispose();
    _academyCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  double? _parse(String v) => v.trim().isEmpty ? null : double.tryParse(v.trim());

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Rejoin Student', style: TextStyle(fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"${s.name}" will become Active again.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Class, section & fees are pre-filled with previous values — edit anything that changed.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 16),

            const Text('Rejoining Date *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
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
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(child: _field('Class', _classCtrl)),
                const SizedBox(width: 8),
                Expanded(child: _field('Section', _sectionCtrl)),
              ],
            ),
            const SizedBox(height: 14),

            _field('Monthly Fee', _monthlyCtrl, isNumber: true),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _field('Annual Fee', _annualCtrl, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: _field('Registration Fee', _regCtrl, isNumber: true)),
              ],
            ),
            if (s.hasAcademy) ...[
              const SizedBox(height: 10),
              _field('Academy Fee', _academyCtrl, isNumber: true),
            ],
            const SizedBox(height: 14),

            const Text('Note (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'e.g. Rejoined after family relocated back',
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
            Navigator.pop(
              context,
              _RejoinResult(
                date: _date,
                note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
                className: _classCtrl.text.trim(),
                sectionName: _sectionCtrl.text.trim(),
                monthlyFee: _parse(_monthlyCtrl.text),
                annualFee: _parse(_annualCtrl.text),
                registrationFee: _parse(_regCtrl.text),
                academyFee: _parse(_academyCtrl.text),
              ),
            );
          },
          child: const Text('Rejoin'),
        ),
      ],
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