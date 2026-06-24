// ─────────────────────────────────────────────────────────────
//  screens/muddul_management/muddul_list_screen.dart
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subject_model.dart';
import '../../providers/subject_provider.dart';
import 'add_edit_subject.dart';

const List<_SC> _colors = [
  _SC(bg: Color(0xFFEEEDFE), text: Color(0xFF3C3489)),
  _SC(bg: Color(0xFFE1F5EE), text: Color(0xFF085041)),
  _SC(bg: Color(0xFFE6F1FB), text: Color(0xFF0C447C)),
  _SC(bg: Color(0xFFFAECE7), text: Color(0xFF712B13)),
  _SC(bg: Color(0xFFEAF3DE), text: Color(0xFF27500A)),
  _SC(bg: Color(0xFFFAEEDA), text: Color(0xFF633806)),
  _SC(bg: Color(0xFFFBEAF0), text: Color(0xFF72243E)),
];

class _SC {
  final Color bg;
  final Color text;
  const _SC({required this.bg, required this.text});
}

class MuddulListScreen extends StatefulWidget {
  const MuddulListScreen({super.key});

  @override
  State<MuddulListScreen> createState() => _MuddulListScreenState();
}

class _MuddulListScreenState extends State<MuddulListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Stable color per subject
  final Map<String, int> _colorIdx = {};
  int _nextIdx = 0;

  static const _purple = Color(0xFF534AB7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MuddulProvider>().startListening();
    });
    _searchController.addListener(
          () => setState(
              () => _searchQuery = _searchController.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _SC _colorFor(String subjectName) {
    if (!_colorIdx.containsKey(subjectName)) {
      _colorIdx[subjectName] = _nextIdx % _colors.length;
      _nextIdx++;
    }
    return _colors[_colorIdx[subjectName]!];
  }

  List<Muddul> _filtered(List<Muddul> all) {
    if (_searchQuery.isEmpty) return all;
    return all
        .where((m) =>
    m.subjectName.toLowerCase().contains(_searchQuery) ||
        m.code.toLowerCase().contains(_searchQuery))
        .toList();
  }

  Future<void> _confirmDelete(Muddul m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete subject'),
        content: Text('Delete "${m.subjectName}"?\nThis cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      try {
        await context.read<MuddulProvider>().deleteMuddul(m.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('"${m.subjectName}" deleted'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  // ── Stats row ──
  Widget _buildStats(List<Muddul> all) {
    final now = DateTime.now();
    final thisMonth = all
        .where((m) =>
    m.createdAt != null &&
        m.createdAt!.year == now.year &&
        m.createdAt!.month == now.month)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          _statCard('${all.length}', 'Total'),
          const SizedBox(width: 10),
          _statCard('$thisMonth', 'This month'),
        ],
      ),
    );
  }

  Widget _statCard(String num, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    ),
  );

  // ── Subject card ──
  Widget _buildCard(Muddul m) {
    final c = _colorFor(m.subjectName);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AddEditMuddulScreen(existingMuddul: m)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Code badge
              Container(
                width: 76,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text(m.code,
                    style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8)),
              ),
              const SizedBox(width: 12),
              // Subject name + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.subjectName,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    if (m.description != null &&
                        m.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(m.description!,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              // Edit / Delete
              _iconBtn(Icons.edit_outlined, c.text, 'Edit', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          AddEditMuddulScreen(existingMuddul: m)),
                );
              }),
              _iconBtn(Icons.delete_outline, Colors.red.shade400, 'Delete',
                      () => _confirmDelete(m)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(
      IconData icon, Color color, String tip, VoidCallback onTap) =>
      Tooltip(
        message: tip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      );

  // ── Empty state ──
  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          _searchQuery.isEmpty
              ? 'No subjects yet.\nTap + to add one.'
              : 'No results for "$_searchQuery"',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MuddulProvider>();
    final filtered = _filtered(provider.mudduls);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Subjects'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${provider.mudduls.length} total',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _purple),
              ),
            ),
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
          child: Text(provider.error!,
              style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search subjects…',
                prefixIcon:
                const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: _searchController.clear,
                )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // Stats
          _buildStats(provider.mudduls),
          const SizedBox(height: 6),
          // List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
              padding:
              const EdgeInsets.only(bottom: 110),
              itemCount: filtered.length,
              itemBuilder: (_, i) =>
                  _buildCard(filtered[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddEditMuddulScreen()),
        ),
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add subject',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}