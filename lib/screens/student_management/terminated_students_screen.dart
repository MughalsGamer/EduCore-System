import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admission_model.dart';
import '../../providers/student_provider.dart';
import 'student_profile.dart';

class TerminatedStudentsScreen extends StatefulWidget {
  const TerminatedStudentsScreen({super.key});

  @override
  State<TerminatedStudentsScreen> createState() =>
      _TerminatedStudentsScreenState();
}

class _TerminatedStudentsScreenState extends State<TerminatedStudentsScreen> {
  static const _purple = Color(0xFF534AB7);
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<StudentWithContext> _filter(List<StudentWithContext> list) {
    if (_query.trim().isEmpty) return list;
    final q = _query.toLowerCase();
    return list.where((s) {
      return s.student.name.toLowerCase().contains(q) ||
          s.student.studentId.toLowerCase().contains(q) ||
          s.fatherName.toLowerCase().contains(q) ||
          (s.student.className?.toLowerCase().contains(q) ?? false) ||
          s.familyName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactivated Students'),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by name, ID, class...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = _filter(provider.deactivatedStudents);

          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    _query.isNotEmpty
                        ? 'No matching deactivated students'
                        : 'No deactivated students',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            itemCount: list.length,
            itemBuilder: (ctx, i) => _TerminatedCard(data: list[i]),
          );
        },
      ),
    );
  }
}

class _TerminatedCard extends StatelessWidget {
  final StudentWithContext data;
  const _TerminatedCard({required this.data});

  static const _purple = Color(0xFF534AB7);

  Widget _avatar(String? picBase64) {
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
      backgroundColor: Colors.grey.shade200,
      child: const Icon(Icons.person, size: 24, color: Colors.grey),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = data.student;
    final isTerminated = s.deactivationReason == 'terminated';
    final badgeColor = isTerminated ? const Color(0xFFB91C1C) : Colors.orange.shade700;
    final badgeLabel = isTerminated ? 'Terminated' : 'Left School';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StudentProfileScreen(data: data)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Opacity(opacity: 0.55, child: _avatar(s.picBase64)),
                  const SizedBox(width: 12),
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
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        if (s.studentId.isNotEmpty)
                          Text(
                            'ID: ${s.studentId}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeColor),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event_busy, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Since: ${_formatDate(s.deactivationDate)}',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Icon(Icons.family_restroom, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    data.familyName,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (s.deactivationNote != null && s.deactivationNote!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Note: ${s.deactivationNote}',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}