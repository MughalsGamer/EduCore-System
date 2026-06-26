import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/admission_model.dart';
import '../../providers/student_provider.dart';

class StudentProfileScreen extends StatelessWidget {
  final StudentWithContext data;
  const StudentProfileScreen({super.key, required this.data});

  static const _purple      = Color(0xFF534AB7);
  static const _purpleLight = Color(0xFFEEECFA);
  static const _purpleDark  = Color(0xFF3D3589);

  @override
  Widget build(BuildContext context) {
    final s = data.student;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _purple,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(s, data),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                children: [
                  // Quick stat tiles
                  _buildStatRow(s, data),
                  const SizedBox(height: 16),

                  // Fee Structure
                  if (s.monthlyFee != null ||
                      s.annualFee != null ||
                      s.registrationFee != null) ...[
                    _buildFeeCard(s),
                    const SizedBox(height: 16),
                  ],

                  // Student Information
                  _buildSection(
                    icon: Icons.school_outlined,
                    title: 'Student Information',
                    iconBg: _purpleLight,
                    iconColor: _purple,
                    rows: [
                      if (s.studentId.isNotEmpty)
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
                  const SizedBox(height: 16),

                  // Admission Details
                  _buildSection(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Admission Details',
                    iconBg: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF2E7D32),
                    rows: [
                      _InfoRow('Reg / Inq ID', data.inquiryOrRegId, highlight: true),
                      _InfoRow(
                        'Admission Date',
                        '${data.admissionDate.day.toString().padLeft(2, '0')}/'
                            '${data.admissionDate.month.toString().padLeft(2, '0')}/'
                            '${data.admissionDate.year}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Family Information
                  _buildSection(
                    icon: Icons.family_restroom_outlined,
                    title: 'Family Information',
                    iconBg: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFE65100),
                    rows: [
                      if (data.familyId.isNotEmpty)
                        _InfoRow('Family ID', data.familyId),
                      if (data.familyName.isNotEmpty)
                        _InfoRow('Family Name', data.familyName),
                      if (data.address != null && data.address!.isNotEmpty)
                        _InfoRow('Address', data.address!),
                      if (data.caste != null && data.caste!.isNotEmpty)
                        _InfoRow('Caste', data.caste!),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Father Information
                  _buildSection(
                    icon: Icons.person,
                    title: 'Father Information',
                    iconBg: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1565C0),
                    rows: [
                      if (data.fatherName.isNotEmpty)
                        _InfoRow('Name', data.fatherName),
                      if (data.fatherPhone.isNotEmpty)
                        _InfoRow('Phone', data.fatherPhone),
                      if (data.fatherCnic != null && data.fatherCnic!.isNotEmpty)
                        _InfoRow('CNIC', data.fatherCnic!),
                      if (data.fatherOccupation != null && data.fatherOccupation!.isNotEmpty)
                        _InfoRow('Occupation', data.fatherOccupation!),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mother Information
                  _buildSection(
                    icon: Icons.person_outline,
                    title: 'Mother Information',
                    iconBg: const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFC62828),
                    rows: [
                      if (data.motherName.isNotEmpty)
                        _InfoRow('Name', data.motherName),
                      if (data.motherPhone != null && data.motherPhone!.isNotEmpty)
                        _InfoRow('Phone', data.motherPhone!),
                      if (data.motherCnic != null && data.motherCnic!.isNotEmpty)
                        _InfoRow('CNIC', data.motherCnic!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gradient Header ──
  Widget _buildHeader(AdmissionStudent s, StudentWithContext d) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_purpleDark, _purple, Color(0xFF7B6FD0)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 44),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(child: _avatarContent(s)),
            ),
            const SizedBox(height: 14),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                s.name.isNotEmpty ? s.name : '—',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            // Class badge
            if (s.className != null && s.className!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(
                  '🎓 ${s.sectionName != null && s.sectionName!.isNotEmpty ? "${s.className} — ${s.sectionName}" : s.className!}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            // Quick stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (s.studentId.isNotEmpty)
                  _QuickStat(icon: Icons.badge_outlined, label: s.studentId),
                if (s.studentId.isNotEmpty &&
                    s.classRollNo != null &&
                    s.classRollNo!.isNotEmpty)
                  Container(
                    height: 16,
                    width: 1,
                    color: Colors.white30,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
                  _QuickStat(
                    icon: Icons.format_list_numbered,
                    label: 'Roll: ${s.classRollNo}',
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _avatarContent(AdmissionStudent s) {
    if (s.picBase64 != null && s.picBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(s.picBase64!),
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        );
      } catch (_) {}
    }
    return Container(
      color: Colors.white24,
      width: 100,
      height: 100,
      child: Center(
        child: Text(
          _initials(s.name),
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Stat Row ──
  Widget _buildStatRow(AdmissionStudent s, StudentWithContext d) {
    return Row(
      children: [
        Expanded(
          child: _statTile(
            icon: Icons.confirmation_number_outlined,
            label: 'Reg / Inq ID',
            value: d.inquiryOrRegId,
            color: const Color(0xFF2E7D32),
            bg: const Color(0xFFE8F5E9),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statTile(
            icon: s.classRollNo != null && s.classRollNo!.isNotEmpty
                ? Icons.format_list_numbered
                : Icons.calendar_today_outlined,
            label: s.classRollNo != null && s.classRollNo!.isNotEmpty
                ? 'Roll No'
                : 'Admitted On',
            value: s.classRollNo != null && s.classRollNo!.isNotEmpty
                ? s.classRollNo!
                : '${d.admissionDate.day.toString().padLeft(2, '0')}/'
                '${d.admissionDate.month.toString().padLeft(2, '0')}/'
                '${d.admissionDate.year}',
            color: _purple,
            bg: _purpleLight,
          ),
        ),
      ],
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Fee Card ──
  Widget _buildFeeCard(AdmissionStudent s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
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
                child: const Icon(Icons.payments_outlined,
                    size: 16, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Fee Structure',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (s.monthlyFee != null) ...[
                Expanded(
                  child: _feeTile(
                    'Monthly',
                    s.monthlyFee!,
                    const Color(0xFF1565C0),
                    const Color(0xFFE3F2FD),
                  ),
                ),
                if (s.annualFee != null || s.registrationFee != null)
                  const SizedBox(width: 8),
              ],
              if (s.annualFee != null) ...[
                Expanded(
                  child: _feeTile(
                    'Annual',
                    s.annualFee!,
                    const Color(0xFFE65100),
                    const Color(0xFFFFF3E0),
                  ),
                ),
                if (s.registrationFee != null) const SizedBox(width: 8),
              ],
              if (s.registrationFee != null)
                Expanded(
                  child: _feeTile(
                    'Reg.',
                    s.registrationFee!,
                    const Color(0xFF6A1B9A),
                    const Color(0xFFF3E5F5),
                  ),
                ),
            ],
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
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs ${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Info Section Card ──
  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color iconBg,
    required Color iconColor,
    required List<_InfoRow> rows,
  }) {
    final visible = rows.where((r) => r.value.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          // Rows
          ...visible.asMap().entries.map(
                (e) => _infoRow(e.value, e.key == visible.length - 1),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(_InfoRow row, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  row.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888899),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  row.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                    row.highlight ? FontWeight.bold : FontWeight.w500,
                    color:
                    row.highlight ? _purple : const Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFF0F0F5),
          ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0]
        .substring(0, parts[0].length >= 2 ? 2 : 1)
        .toUpperCase();
  }
}

// ── Helper classes ──
class _InfoRow {
  final String label;
  final String value;
  final bool highlight;
  const _InfoRow(this.label, this.value, {this.highlight = false});
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}