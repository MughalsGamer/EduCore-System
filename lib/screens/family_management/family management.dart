import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admission_model.dart';
import '../../providers/admission_provider.dart';

// ─────────────────────────────────────────────
//  Family Management List Screen
// ─────────────────────────────────────────────
class FamilyManagementScreen extends StatefulWidget {
  const FamilyManagementScreen({super.key});

  @override
  State<FamilyManagementScreen> createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Group admissions by familyId
  Map<String, List<AdmissionModel>> _groupByFamily(
      List<AdmissionModel> admissions) {
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

  @override
  Widget build(BuildContext context) {
    final admissions = context.watch<AdmissionProvider>().admissions;
    final isLoading = context.watch<AdmissionProvider>().isLoading;

    final grouped = _groupByFamily(admissions);

    // Filter by search query
    final filteredKeys = grouped.keys.where((key) {
      final reps = grouped[key]!;
      final rep = reps.first;
      final q = _searchQuery.toLowerCase();
      return q.isEmpty ||
          rep.familyName.toLowerCase().contains(q) ||
          rep.fatherName.toLowerCase().contains(q) ||
          rep.familyId.toLowerCase().contains(q) ||
          rep.fatherPhone.contains(q);
    }).toList();

    // Sort by family name
    filteredKeys.sort((a, b) {
      final fa = grouped[a]!.first.familyName.toLowerCase();
      final fb = grouped[b]!.first.familyName.toLowerCase();
      return fa.compareTo(fb);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text('Family Management'),
        centerTitle: true,
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Stats + Search
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF534AB7), Color(0xFF6C63CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              children: [
                // Stats Row
                Row(
                  children: [
                    _statChip(
                      icon: Icons.family_restroom,
                      label: 'Families',
                      value: grouped.length.toString(),
                    ),
                    const SizedBox(width: 12),
                    _statChip(
                      icon: Icons.people,
                      label: 'Students',
                      value: admissions
                          .fold<int>(0, (sum, a) => sum + a.students.length)
                          .toString(),
                    ),
                    const SizedBox(width: 12),
                    _statChip(
                      icon: Icons.how_to_reg,
                      label: 'Admissions',
                      value: admissions.length.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    decoration: InputDecoration(
                      hintText: 'Family name, father, phone se search...',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF534AB7)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Family List
          Expanded(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(color: _purple))
                : filteredKeys.isEmpty
                ? _buildEmpty()
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredKeys.length,
              itemBuilder: (context, i) {
                final key = filteredKeys[i];
                final reps = grouped[key]!;
                return _FamilyCard(
                  familyKey: key,
                  admissions: reps,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),
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
          Icon(Icons.family_restroom,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Koi family nahi mili'
                : 'Search result nahi mila',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            'Admission form se families auto-create hongi',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Family Card Widget
// ─────────────────────────────────────────────
class _FamilyCard extends StatelessWidget {
  final String familyKey;
  final List<AdmissionModel> admissions;

  const _FamilyCard({
    required this.familyKey,
    required this.admissions,
  });

  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  @override
  Widget build(BuildContext context) {
    final rep = admissions.first; // representative admission
    final allStudents = admissions.expand((a) => a.students).toList();
    final totalMonthlyFee = allStudents.fold<double>(
        0, (sum, s) => sum + (s.monthlyFee ?? 0));
    final hasMultipleAdmissions = admissions.length > 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: _purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FamilyDetailScreen(
              familyKey: familyKey,
              admissions: admissions,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Name + ID
              Row(
                children: [
                  // Family Avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        rep.familyName.isNotEmpty
                            ? rep.familyName[0].toUpperCase()
                            : 'F',
                        style: const TextStyle(
                          color: _purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rep.familyName.isNotEmpty
                              ? rep.familyName
                              : rep.fatherName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.tag,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Text(
                              rep.familyId.isNotEmpty
                                  ? rep.familyId
                                  : '—',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _lightPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: _purple, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 12),

              // Info Row
              Row(
                children: [
                  _infoItem(
                      Icons.person,
                      rep.fatherName.isNotEmpty ? rep.fatherName : '—'),
                  const SizedBox(width: 16),
                  _infoItem(Icons.phone, rep.fatherPhone),
                ],
              ),
              const SizedBox(height: 8),

              // Students Count + Fee
              Row(
                children: [
                  // Students pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _lightPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people,
                            size: 13, color: _purple),
                        const SizedBox(width: 5),
                        Text(
                          '${allStudents.length} Student${allStudents.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: _purple,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Multiple admissions badge
                  if (hasMultipleAdmissions)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${admissions.length} Admissions',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600),
                      ),
                    ),

                  const Spacer(),

                  // Monthly Fee
                  if (totalMonthlyFee > 0)
                    Text(
                      'Rs ${totalMonthlyFee.toStringAsFixed(0)}/mo',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _purple,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),

              // Student mini-chips
              if (allStudents.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: allStudents.take(4).map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        s.name.isNotEmpty ? s.name : 'Unnamed',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade700),
                      ),
                    );
                  }).toList()
                    ..addAll(allStudents.length > 4
                        ? [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _lightPurple,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${allStudents.length - 4} more',
                          style: const TextStyle(
                              fontSize: 11,
                              color: _purple,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ]
                        : []),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Family Detail Screen
// ─────────────────────────────────────────────
class FamilyDetailScreen extends StatelessWidget {
  final String familyKey;
  final List<AdmissionModel> admissions;

  const FamilyDetailScreen({
    super.key,
    required this.familyKey,
    required this.admissions,
  });

  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

  @override
  Widget build(BuildContext context) {
    final rep = admissions.first;
    final allStudents = admissions.expand((a) => a.students).toList();

    final totalMonthly =
    allStudents.fold<double>(0, (s, st) => s + (st.monthlyFee ?? 0));
    final totalAnnual =
    allStudents.fold<double>(0, (s, st) => s + (st.annualFee ?? 0));
    final totalRegistration =
    allStudents.fold<double>(0, (s, st) => s + (st.registrationFee ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar with family info ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF534AB7), Color(0xFF6C63CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2),
                          ),
                          child: Center(
                            child: Text(
                              rep.familyName.isNotEmpty
                                  ? rep.familyName[0].toUpperCase()
                                  : 'F',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
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
                                rep.familyName.isNotEmpty
                                    ? rep.familyName
                                    : rep.fatherName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${rep.familyId.isNotEmpty ? rep.familyId : "—"}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _headerBadge(
                                      '${allStudents.length} Students'),
                                  const SizedBox(width: 8),
                                  _headerBadge(
                                      '${admissions.length} Admissions'),
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
                  // ── Fee Summary Cards ──
                  _sectionTitle('Fee Summary'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _feeCard('Monthly', 'Rs ${totalMonthly.toStringAsFixed(0)}',
                          Icons.calendar_month, Colors.blue.shade600),
                      const SizedBox(width: 10),
                      _feeCard('Annual', 'Rs ${totalAnnual.toStringAsFixed(0)}',
                          Icons.calendar_today, Colors.green.shade600),
                      const SizedBox(width: 10),
                      _feeCard('Reg.', 'Rs ${totalRegistration.toStringAsFixed(0)}',
                          Icons.app_registration, Colors.orange.shade600),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Parent Details ──
                  _sectionTitle('Parent Details'),
                  const SizedBox(height: 10),
                  _buildParentCard(rep),
                  const SizedBox(height: 24),

                  // ── Students ──
                  _sectionTitle('Students (${allStudents.length})'),
                  const SizedBox(height: 10),
                  ...admissions.asMap().entries.expand((entry) {
                    final idx = entry.key;
                    final admission = entry.value;
                    return [
                      if (admissions.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _admissionLabel(admission, idx),
                        ),
                      ...admission.students
                          .map((s) => _StudentDetailCard(
                        student: s,
                        admission: admission,
                      )),
                    ];
                  }),
                  const SizedBox(height: 24),

                  // ── Previous School (if any) ──
                  if (rep.previousSchoolName != null &&
                      rep.previousSchoolName!.isNotEmpty) ...[
                    _sectionTitle('Previous School'),
                    const SizedBox(height: 10),
                    _buildPreviousSchoolCard(rep),
                    const SizedBox(height: 24),
                  ],

                  // ── Address ──
                  if (rep.address != null && rep.address!.isNotEmpty) ...[
                    _sectionTitle('Address'),
                    const SizedBox(height: 10),
                    _buildInfoCard([
                      _DetailRow(Icons.home_outlined, 'Address', rep.address!),
                      if (rep.caste != null && rep.caste!.isNotEmpty)
                        _DetailRow(Icons.diversity_3_outlined, 'Caste', rep.caste!),
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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildParentCard(AdmissionModel rep) {
    return _buildInfoCard([
      _DetailRow(Icons.person, 'Father', rep.fatherName),
      if (rep.fatherPhone.isNotEmpty)
        _DetailRow(Icons.phone, 'Phone', rep.fatherPhone),
      if (rep.fatherCnic != null && rep.fatherCnic!.isNotEmpty)
        _DetailRow(Icons.credit_card, 'CNIC', rep.fatherCnic!),
      if (rep.fatherOccupation != null && rep.fatherOccupation!.isNotEmpty)
        _DetailRow(Icons.work_outline, 'Occupation', rep.fatherOccupation!),
      if (rep.motherName.isNotEmpty) ...[
        const SizedBox(height: 4),
        _DetailRow(Icons.person_outline, 'Mother', rep.motherName),
        if (rep.motherPhone != null && rep.motherPhone!.isNotEmpty)
          _DetailRow(
              Icons.phone_outlined, 'Mother Phone', rep.motherPhone!),
        if (rep.motherCnic != null && rep.motherCnic!.isNotEmpty)
          _DetailRow(
              Icons.credit_card_outlined, 'Mother CNIC', rep.motherCnic!),
      ],
    ]);
  }

  Widget _buildPreviousSchoolCard(AdmissionModel rep) {
    return _buildInfoCard([
      if (rep.previousSchoolName != null)
        _DetailRow(Icons.school_outlined, 'School', rep.previousSchoolName!),
      if (rep.previousClassName != null)
        _DetailRow(Icons.class_, 'Class', rep.previousClassName!),
      if (rep.previousClassMarks != null)
        _DetailRow(Icons.grade_outlined, 'Marks/Grade', rep.previousClassMarks!),
    ]);
  }

  Widget _admissionLabel(AdmissionModel a, int idx) {
    final isRegular = a.type == AdmissionType.regular;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRegular
            ? Colors.green.shade50
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRegular
              ? Colors.green.shade200
              : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isRegular ? Icons.verified : Icons.pending_outlined,
            size: 14,
            color: isRegular
                ? Colors.green.shade600
                : Colors.blue.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            '${a.type.label} — ${a.inquiryOrRegId}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isRegular
                  ? Colors.green.shade700
                  : Colors.blue.shade700,
            ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ── Detail Row Helper ──
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
          Text('$label: ',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Student Detail Card
// ─────────────────────────────────────────────
class _StudentDetailCard extends StatefulWidget {
  final AdmissionStudent student;
  final AdmissionModel admission;

  const _StudentDetailCard({
    required this.student,
    required this.admission,
  });

  @override
  State<_StudentDetailCard> createState() => _StudentDetailCardState();
}

class _StudentDetailCardState extends State<_StudentDetailCard> {
  bool _expanded = false;

  static const _purple = Color(0xFF534AB7);
  static const _lightPurple = Color(0xFFEEECFA);

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
          // ── Collapsed Header ──
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Photo or Avatar
                  s.picBase64 != null
                      ? CircleAvatar(
                    radius: 26,
                    backgroundImage:
                    MemoryImage(base64Decode(s.picBase64!)),
                  )
                      : CircleAvatar(
                    radius: 26,
                    backgroundColor: _lightPurple,
                    child: Text(
                      s.name.isNotEmpty
                          ? s.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + Class
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name.isNotEmpty ? s.name : 'Unnamed',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (s.className != null)
                              _smallChip(
                                Icons.class_,
                                s.sectionName != null
                                    ? '${s.className} - ${s.sectionName}'
                                    : s.className!,
                                Colors.grey.shade100,
                                Colors.grey.shade600,
                              ),
                            const SizedBox(width: 6),
                            _smallChip(
                              isRegular
                                  ? Icons.verified
                                  : Icons.pending_outlined,
                              isRegular ? 'Regular' : 'Pre',
                              isRegular
                                  ? Colors.green.shade50
                                  : Colors.blue.shade50,
                              isRegular
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Monthly Fee + Arrow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (s.monthlyFee != null && s.monthlyFee! > 0)
                        Text(
                          'Rs ${s.monthlyFee!.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _purple,
                              fontSize: 14),
                        ),
                      const SizedBox(height: 4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Details ──
          if (_expanded)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FF),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),

                  // Student IDs
                  _expandRow(Icons.fingerprint, 'Student ID',
                      s.studentId.isNotEmpty ? s.studentId : '—'),
                  if (s.classRollNo != null && s.classRollNo!.isNotEmpty)
                    _expandRow(Icons.format_list_numbered, 'Roll No',
                        s.classRollNo!),
                  if (s.bFormCnic != null && s.bFormCnic!.isNotEmpty)
                    _expandRow(
                        Icons.credit_card_outlined, 'B-Form/CNIC', s.bFormCnic!),
                  if (s.dob != null)
                    _expandRow(
                      Icons.cake_outlined,
                      'Date of Birth',
                      '${s.dob!.day.toString().padLeft(2, '0')}/${s.dob!.month.toString().padLeft(2, '0')}/${s.dob!.year}',
                    ),

                  // Admission info
                  _expandRow(Icons.badge_outlined, 'Admission ID',
                      admission.inquiryOrRegId),
                  _expandRow(
                    Icons.calendar_today_outlined,
                    'Admission Date',
                    '${admission.admissionDate.day.toString().padLeft(2, '0')}/${admission.admissionDate.month.toString().padLeft(2, '0')}/${admission.admissionDate.year}',
                  ),

                  const SizedBox(height: 8),

                  // Fee Summary
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _lightPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.payments_outlined,
                            color: _purple, size: 15),
                        const SizedBox(width: 6),
                        const Text('Fees: ',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _purple)),
                        Text(
                          [
                            if (s.monthlyFee != null && s.monthlyFee! > 0)
                              'Monthly: Rs ${s.monthlyFee!.toStringAsFixed(0)}',
                            if (s.annualFee != null && s.annualFee! > 0)
                              'Annual: Rs ${s.annualFee!.toStringAsFixed(0)}',
                            if (s.registrationFee != null &&
                                s.registrationFee! > 0)
                              'Reg: Rs ${s.registrationFee!.toStringAsFixed(0)}',
                          ].join('  •  '),
                          style: const TextStyle(
                              fontSize: 12, color: _purple),
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

  Widget _smallChip(
      IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(label,
              style:
              TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500)),
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
          Text('$label: ',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}