import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/teacher.dart';

class StaffProfileScreen extends StatelessWidget {
  final StaffMember staff;
  const StaffProfileScreen({super.key, required this.staff});

  static const _purple = Color(0xFF534AB7);
  static const _purpleLight = Color(0xFFEEECFA);
  static const _purpleDark = Color(0xFF3D3589);

  @override
  Widget build(BuildContext context) {
    final isTeacher = staff.type == 'teacher';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: _purple,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(context, isTeacher),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => Navigator.pop(context, 'edit'),
                tooltip: 'Edit',
              ),
            ],
          ),

          // ── Body Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                children: [
                  // Subjects chips (if any)
                  if (staff.subjects.isNotEmpty) ...[
                    _buildSubjectsCard(),
                    const SizedBox(height: 16),
                  ],

                  // Assigned Classes (if any)
                  if (staff.assignedClasses.isNotEmpty) ...[
                    _buildClassesCard(),
                    const SizedBox(height: 16),
                  ],

                  _buildSection(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    rows: [
                      _InfoRow('Father / Husband', staff.fatherOrHusbandName),
                      _InfoRow('CNIC', staff.cnic),
                      _InfoRow('Date of Birth', staff.dob),
                      _InfoRow('Gender', staff.gender),
                      _InfoRow('Marital Status', staff.maritalStatus),
                      if (staff.bloodGroup != null)
                        _InfoRow('Blood Group', staff.bloodGroup!),
                      _InfoRow('Religion', staff.religion),
                      _InfoRow('Nationality', staff.nationality),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    icon: Icons.contact_phone_outlined,
                    title: 'Contact Information',
                    rows: [
                      _InfoRow('Address', staff.address),
                      _InfoRow('Phone', staff.phone),
                      _InfoRow('Emergency', staff.emergencyPhone),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSection(
                    icon: Icons.work_outline,
                    title: 'Job Details',
                    rows: [
                      _InfoRow('Employment Type', staff.employmentType),
                      _InfoRow(
                        'Salary',
                        'PKR ${staff.salary.toStringAsFixed(0)}',
                        highlight: true,
                      ),
                      if (staff.reference != null && staff.reference!.isNotEmpty)
                        _InfoRow('Reference', staff.reference!),
                    ],
                  ),

                  if (staff.note != null && staff.note!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildNoteCard(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Header ──
  Widget _buildHeader(BuildContext context, bool isTeacher) {
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
            const SizedBox(height: 40),
            // Profile Picture
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
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white24,
                backgroundImage: staff.imageBase64 != null
                    ? MemoryImage(base64Decode(staff.imageBase64!))
                    : null,
                child: staff.imageBase64 == null
                    ? Text(
                  _initials(staff.name),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            // Name
            Text(
              staff.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white30),
              ),
              child: Text(
                isTeacher ? '👨‍🏫 Teacher' : '🏢 Staff',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Quick stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _QuickStat(
                  icon: Icons.phone_outlined,
                  label: staff.phone,
                ),
                Container(
                  height: 16,
                  width: 1,
                  color: Colors.white30,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                _QuickStat(
                  icon: Icons.badge_outlined,
                  label: staff.employmentType,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Info Section Card ──
  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: _purple),
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
          ...rows.asMap().entries.map((entry) {
            final isLast = entry.key == rows.length - 1;
            final row = entry.value;
            return _buildInfoRow(row, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoRow row, bool isLast) {
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
                    fontWeight: row.highlight ? FontWeight.bold : FontWeight.w500,
                    color: row.highlight ? _purple : const Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F5)),
      ],
    );
  }

  // ── Subjects Card ──
  Widget _buildSubjectsCard() {
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
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book_outlined, size: 16, color: _purple),
              ),
              const SizedBox(width: 10),
              const Text(
                'Assigned Subjects',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${staff.subjects.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _purple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: staff.subjects.map((subject) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _purple.withOpacity(0.3)),
                ),
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _purple,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Classes Card ──
  Widget _buildClassesCard() {
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
                child: const Icon(Icons.class_outlined, size: 16, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Assigned Classes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${staff.assignedClasses.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: staff.assignedClasses.map((cls) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.class_, size: 12, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Text(
                      cls,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Note Card ──
  Widget _buildNoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.06),
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
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sticky_note_2_outlined,
                    size: 16, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            staff.note!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF78350F),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
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