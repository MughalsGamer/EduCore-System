
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/teacher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen wrapper (mobile navigation)
// ─────────────────────────────────────────────────────────────────────────────
class StaffProfileScreen extends StatelessWidget {
  final StaffMember staff;
  final Map<String, String> classIdToName;

  const StaffProfileScreen({
    super.key,
    required this.staff,
    this.classIdToName = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EFF8),
      appBar: AppBar(
        title: const Text(
          'Staff Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF534AB7),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StaffProfileView(staff: staff, classIdToName: classIdToName),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Core view — usable in mobile screen AND desktop side-panel
// ─────────────────────────────────────────────────────────────────────────────
class StaffProfileView extends StatelessWidget {
  final StaffMember staff;
  final Map<String, String> classIdToName;
  final VoidCallback? onClose;

  const StaffProfileView({
    super.key,
    required this.staff,
    this.classIdToName = const {},
    this.onClose,
  });

  // ── Theme ──
  static const _purple       = Color(0xFF534AB7);
  static const _purpleLight  = Color(0xFFF0EFFE);
  static const _purpleDark   = Color(0xFF3D3589);
  static const _purpleAccent = Color(0xFF7B6FD0);

  // ── Build ──
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
      child: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  // ─────────────────────────────────── Desktop ──────────────────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: gradient sidebar (fixed 260 px wide)
        SizedBox(width: 260, child: _buildSidebar()),
        // Right: scrollable detail panel
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
                      'Staff Details',
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
                ..._contentWidgets(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────── Mobile ───────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildSidebar(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: _contentWidgets()),
        ),
      ],
    );
  }

  // ────────────────────── Shared scrollable content ─────────────────────────
  List<Widget> _contentWidgets() {
    return [
      // ── Personal ──
      _buildInfoCard(
        icon: Icons.person_outline,
        title: 'Personal Information',
        rows: [
          _InfoRow('Father / Husband', staff.fatherOrHusbandName),
          _InfoRow('CNIC',             staff.cnic),
          _InfoRow('Date of Birth',    staff.dob),
          _InfoRow('Gender',           staff.gender),
          _InfoRow('Marital Status',   staff.maritalStatus),
          _InfoRow('Blood Group',      staff.bloodGroup ?? '-'),
          _InfoRow('Religion',         staff.religion),
          _InfoRow('Nationality',      staff.nationality),
        ],
      ),
      const SizedBox(height: 14),

      // ── Contact ──
      _buildInfoCard(
        icon: Icons.contact_phone_outlined,
        title: 'Contact Information',
        rows: [
          _InfoRow('Address',   staff.address),
          _InfoRow('Phone',     staff.phone),
          _InfoRow('Emergency', staff.emergencyPhone),
        ],
      ),
      const SizedBox(height: 14),

      // ── Job ──
      _buildInfoCard(
        icon: Icons.work_outline,
        title: 'Job Details',
        rows: [
          _InfoRow('Employment Type', staff.employmentType),
          _InfoRow('Salary', 'PKR ${staff.salary.toStringAsFixed(0)}',
              highlight: true),
          if (staff.reference != null && staff.reference!.isNotEmpty)
            _InfoRow('Reference', staff.reference!),
        ],
      ),

      // ── Subjects ──
      if (staff.subjects.isNotEmpty) ...[
        const SizedBox(height: 14),
        _buildChipCard(
          icon: Icons.menu_book_outlined,
          title: 'Assigned Subjects',
          count: staff.subjects.length,
          accentColor: _purple,
          bgColor: _purpleLight,
          chips: staff.subjects
              .map((s) => _chipItem(label: s, bg: _purpleLight, color: _purple))
              .toList(),
        ),
      ],

      // ── Classes — classIdToName se NAME show hoga, ID nahi ──
      if (staff.assignedClasses.isNotEmpty) ...[
        const SizedBox(height: 14),
        _buildChipCard(
          icon: Icons.class_outlined,
          title: 'Assigned Classes',
          count: staff.assignedClasses.length,
          accentColor: const Color(0xFF2E7D32),
          bgColor: const Color(0xFFE8F5E9),
          chips: staff.assignedClasses.map((id) {
            final name = classIdToName[id] ?? id; // ← NAME, not raw ID
            return _chipItem(
              label: name,
              bg: const Color(0xFFE8F5E9),
              color: const Color(0xFF2E7D32),
              icon: Icons.class_,
            );
          }).toList(),
        ),
      ],

      // ── Note ──
      if (staff.note != null && staff.note!.isNotEmpty) ...[
        const SizedBox(height: 14),
        _buildNoteCard(),
      ],
    ];
  }

  // ─────────────────────────── Gradient Sidebar ─────────────────────────────
  Widget _buildSidebar() {
    final isTeacher = staff.type == 'teacher';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
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
          // ── Portrait photo (ID-card shape — same as shared frame) ──────
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: staff.imageBase64 != null
                  ? Image.memory(
                base64Decode(staff.imageBase64!),
                fit: BoxFit.cover,
                width: 120,
                height: 160,
              )
                  : Container(
                color: Colors.white.withOpacity(0.18),
                child: Center(
                  child: Text(
                    _initials(staff.name),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Name ──
          Text(
            staff.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),

          // ── Role badge ──
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Text(
              isTeacher ? '👨‍🏫 Teacher' : '🏢 Staff',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 20),

          // ── Quick info ──
          _sidebarRow(Icons.phone_outlined,    staff.phone),
          const SizedBox(height: 10),
          _sidebarRow(Icons.badge_outlined,    staff.employmentType),
          if (staff.bloodGroup != null && staff.bloodGroup!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _sidebarRow(Icons.water_drop_outlined, staff.bloodGroup!),
          ],
        ],
      ),
    );
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

  // ─────────────────────────── Info section card ────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          // Rows
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            final row   = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
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
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: row.highlight
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: row.highlight
                                ? _purple
                                : const Color(0xFF1A1A2E),
                          ),
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
          }),
        ],
      ),
    );
  }

  // ─────────────────────────── Chip card (subjects / classes) ──────────────
  Widget _buildChipCard({
    required IconData icon,
    required String title,
    required int count,
    required Color accentColor,
    required Color bgColor,
    required List<Widget> chips,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
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
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: chips),
        ],
      ),
    );
  }

  Widget _chipItem({
    required String label,
    required Color bg,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────── Note card ────────────────────────────────
  Widget _buildNoteCard() {
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
                'Notes',
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

// ─────────────────────────────────────────────────────────────────────────────
// Helper model
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow {
  final String label;
  final String value;
  final bool highlight;
  const _InfoRow(this.label, this.value, {this.highlight = false});
}