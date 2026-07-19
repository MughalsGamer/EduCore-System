
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/teacher.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/class_provider.dart';
import 'Staff Profile.dart';

const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kGrey = Color(0xFF8B8FA8);
const _kGreyBg = Color(0xFFF0F2F8);

/// Shows BOTH terminated Teachers and terminated Staff on a single page.
/// - Type filter chip (All / Teacher / Staff)
/// - Class filter chip (built from ClassProvider)
/// - Section filter chip (built from selected class's sections, or all
///   assignedSections across the filtered list if no class chosen)
/// - "Rejoin" action asks for a rejoining date + note, then restores the
///   member back to the active list and logs the event in their history
/// - Tapping a row/card opens a full employment-history timeline (joined,
///   terminated, rejoined ... in order)
/// - Desktop: dense table layout matching the active Staff/Teacher screens
/// - Mobile: card layout matching the active Staff/Teacher screens
class TerminatedStaffScreen extends StatefulWidget {
  /// 'teacher' | 'staff' | null (null / 'all' shows both)
  final String? initialTypeFilter;

  const TerminatedStaffScreen({super.key, this.initialTypeFilter});

  @override
  State<TerminatedStaffScreen> createState() =>
      _TerminatedStaffScreenState();
}

class _TerminatedStaffScreenState extends State<TerminatedStaffScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  late String _typeFilter; // 'all' | 'teacher' | 'staff'
  String? _classFilter; // class id, null = All Classes
  String? _sectionFilter; // section name, null = All Sections

  @override
  void initState() {
    super.initState();
    _typeFilter = widget.initialTypeFilter ?? 'all';
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
    // Make sure teachers/staffOnly are populated even if this screen is
    // opened directly, otherwise the terminated list would appear empty.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StaffProvider>();
      if (provider.allStaff.isEmpty) {
        provider.fetchAllLists();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<StaffMember> _applyFilters(List<StaffMember> all) {
    var list = all;

    if (_typeFilter != 'all') {
      list = list.where((m) => m.type == _typeFilter).toList();
    }

    if (_classFilter != null) {
      list = list.where((m) => m.assignedClasses.contains(_classFilter)).toList();
    }

    if (_sectionFilter != null) {
      list = list.where((m) => m.assignedSections.contains(_sectionFilter)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((m) =>
      m.name.toLowerCase().contains(_searchQuery) ||
          m.phone.toLowerCase().contains(_searchQuery) ||
          (m.designation ?? '').toLowerCase().contains(_searchQuery)).toList();
    }

    return list;
  }

  String _todayIso() => DateTime.now().toIso8601String().split('T').first;

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

  // ── Rejoin dialog: asks for rejoining date + optional note ──
  void _confirmRejoin(BuildContext context, StaffMember m) {
    DateTime selectedDate = DateTime.now();
    final noteCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: _formatDate(_todayIso()));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Rejoin this member?',
              style: TextStyle(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"${m.name}" will be moved back to the active ${m.type == 'teacher' ? 'Teachers' : 'Staff'} list.'),
                const SizedBox(height: 16),
                const Text('Rejoining Date *',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kGrey)),
                const SizedBox(height: 2),
                Text('Defaults to today — tap to change if needed.',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500)),
                const SizedBox(height: 6),
                TextField(
                  controller: dateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixIcon: const Icon(Icons.calendar_today, size: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                        dateCtrl.text = _formatDate(picked.toIso8601String().split('T').first);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Note (optional)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kGrey)),
                const SizedBox(height: 6),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'e.g. Rejoined on request, previous performance good',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                final isoDate = selectedDate.toIso8601String().split('T').first;
                Navigator.pop(ctx);
                await context.read<StaffProvider>().rejoinStaff(
                  m.id!,
                  rejoiningDate: isoDate,
                  note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${m.name} has rejoined')),
                  );
                  setState(() {});
                }
              },
              child: const Text('Rejoin'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Opens the FULL staff profile (same screen used for active employees),
  // which now also includes the complete Employment History section. ──
  Future<void> _openProfile(BuildContext context, StaffMember m) async {
    final classProvider = context.read<ClassProvider>();
    final classIdToName = {
      for (final c in classProvider.classes)
        if (c.id != null) c.id!: c.name
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffProfileScreen(staff: m, classIdToName: classIdToName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;
    return isDesktop ? _buildDesktop() : _buildMobile();
  }

  // ═══════════════════════════ SHARED HELPERS ═══════════════════════════

  List<String> _availableSections(List<StaffMember> scopeForSections) {
    final set = <String>{};
    for (final m in scopeForSections) {
      set.addAll(m.assignedSections);
    }
    final list = set.toList()..sort();
    return list;
  }

  // ═══════════════════════════ DESKTOP ═══════════════════════════

  Widget _buildDesktop() {
    final provider = context.watch<StaffProvider>();
    final classProvider = context.watch<ClassProvider>();

    final terminated = provider.deactivatedMembers;
    // scope used to build section chips = type-filtered + class-filtered list
    var scopeForSections = terminated;
    if (_typeFilter != 'all') {
      scopeForSections =
          scopeForSections.where((m) => m.type == _typeFilter).toList();
    }
    if (_classFilter != null) {
      scopeForSections = scopeForSections
          .where((m) => m.assignedClasses.contains(_classFilter))
          .toList();
    }
    final sections = _availableSections(scopeForSections);

    final filtered = _applyFilters(terminated);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E))),
            const SizedBox(width: 4),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Deactivated / Terminated (${filtered.length})',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 2),
              Text('Deactivated (terminated) teachers & staff',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ]),
            const Spacer(),
            SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                      hintText: 'Search…',
                      hintStyle:
                      TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon:
                      const Icon(Icons.search, size: 18, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _kPurple)),
                      filled: true,
                      fillColor: Colors.white),
                  style: const TextStyle(fontSize: 13),
                )),
          ]),
          const SizedBox(height: 16),

          // ── Filter chips row ──
          Wrap(spacing: 8, runSpacing: 8, children: [
            _filterDropdown<String>(
              label: 'Type',
              value: _typeFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Types')),
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'staff', child: Text('Staff')),
              ],
              onChanged: (v) => setState(() {
                _typeFilter = v ?? 'all';
              }),
            ),
            _filterDropdown<String?>(
              label: 'Class',
              value: _classFilter,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Classes')),
                ...classProvider.classes
                    .where((c) => c.id != null)
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
              ],
              onChanged: (v) => setState(() {
                _classFilter = v;
                _sectionFilter = null; // reset dependent filter
              }),
            ),
            _filterDropdown<String?>(
              label: 'Section',
              value: _sectionFilter,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Sections')),
                ...sections.map((s) => DropdownMenuItem(value: s, child: Text(s))),
              ],
              onChanged: (v) => setState(() => _sectionFilter = v),
            ),
            if (_typeFilter != 'all' || _classFilter != null || _sectionFilter != null)
              TextButton.icon(
                onPressed: () => setState(() {
                  _typeFilter = 'all';
                  _classFilter = null;
                  _sectionFilter = null;
                }),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Clear filters'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
              ),
          ]),
          const SizedBox(height: 20),

          // Table card
          Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2))
                    ]),
                child: Column(children: [
                  Container(
                      color: const Color(0xFFF8F9FC),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(children: [
                        _th('PHOTO', flex: 6),
                        _th('NAME', flex: 15),
                        _th('TYPE', flex: 9),
                        _th('JOINED', flex: 10),
                        _th('TERMINATED', flex: 11),
                        _th('SECTIONS', flex: 11),
                        _th('PHONE', flex: 10),
                        _th('STATUS', flex: 8),
                        _th('ACTION', flex: 12, align: TextAlign.center),
                      ])),
                  const Divider(height: 1, color: Color(0xFFEEEFF3)),
                  Expanded(
                      child: provider.loading
                          ? const Center(
                          child: CircularProgressIndicator(color: _kPurple))
                          : filtered.isEmpty
                          ? _emptyState()
                          : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: Color(0xFFEEEFF3)),
                          itemBuilder: (ctx, i) =>
                              _desktopRow(ctx, filtered[i]))),
                ]),
              )),
        ]),
      ),
    );
  }

  Widget _filterDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w500),
            iconSize: 16,
          ),
        ),
      ]),
    );
  }

  Widget _th(String label, {int flex = 1, TextAlign align = TextAlign.left}) =>
      Expanded(
        flex: flex,
        child: Text(label,
            textAlign: align,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kGrey,
                letterSpacing: 0.5)),
      );

  Widget _desktopRow(BuildContext context, StaffMember m) {
    final sections = m.assignedSections;
    final isTeacher = m.type == 'teacher';

    return InkWell(
      onTap: () => _openProfile(context, m),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          // PHOTO
          Expanded(
            flex: 6,
            child: CircleAvatar(
                radius: 18,
                backgroundColor: _kPurpleLight,
                backgroundImage:
                m.imageBase64 != null ? MemoryImage(base64Decode(m.imageBase64!)) : null,
                child: m.imageBase64 == null
                    ? Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: _kPurple))
                    : null),
          ),
          // NAME
          Expanded(
            flex: 15,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                  overflow: TextOverflow.ellipsis),
              Text(m.gender, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
          ),
          // TYPE
          Expanded(
            flex: 9,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: isTeacher ? const Color(0xFFF0EFFE) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(isTeacher ? 'Teacher' : 'Staff',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isTeacher ? _kPurple : Colors.blue.shade700)),
              ),
            ),
          ),
          // JOINED
          Expanded(
            flex: 10,
            child: Text(_formatDate(m.joiningDate),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ),
          // TERMINATED
          Expanded(
            flex: 11,
            child: Text(_formatDate(m.terminationDate),
                style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C), fontWeight: FontWeight.w500)),
          ),
          // SECTIONS
          Expanded(
            flex: 11,
            child: sections.isEmpty
                ? Text('—', style: TextStyle(fontSize: 13, color: Colors.grey.shade400))
                : _buildChipRow(sections, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
          ),
          // PHONE
          Expanded(
              flex: 10,
              child: Text(m.phone,
                  style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
          // STATUS
          Expanded(
            flex: 8,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Terminated',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFB91C1C))),
              ),
            ),
          ),
          // ACTION
          Expanded(
            flex: 12,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _actionBtn(Icons.person_outline, _kGrey, () => _openProfile(context, m), tooltip: 'View Profile'),
              const SizedBox(width: 6),
              _actionBtn(Icons.restart_alt, const Color(0xFF15803D),
                      () => _confirmRejoin(context, m),
                  tooltip: 'Rejoin'),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap, {String? tooltip}) =>
      Tooltip(
          message: tooltip ?? '',
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, size: 17, color: color))));

  Widget _buildChipRow(List<String> items, Color bgColor, Color textColor) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: items
          .take(2)
          .map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Text(item,
            style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w500)),
      ))
          .toList()
        ..addAll(items.length > 2
            ? [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration:
            BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            child: Text('+${items.length - 2}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          )
        ]
            : []),
    );
  }

  Widget _emptyState() => Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.person_off_outlined, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
            _searchQuery.isEmpty
                ? 'No terminated members found.'
                : 'No results for "$_searchQuery"',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
      ]));

  // ═══════════════════════════ MOBILE ═══════════════════════════

  Widget _buildMobile() {
    final provider = context.watch<StaffProvider>();
    final classProvider = context.watch<ClassProvider>();

    final terminated = provider.deactivatedMembers;
    var scopeForSections = terminated;
    if (_typeFilter != 'all') {
      scopeForSections = scopeForSections.where((m) => m.type == _typeFilter).toList();
    }
    if (_classFilter != null) {
      scopeForSections =
          scopeForSections.where((m) => m.assignedClasses.contains(_classFilter)).toList();
    }
    final sections = _availableSections(scopeForSections);
    final filtered = _applyFilters(terminated);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Deactivated / Terminated',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          Text('${filtered.length} members',
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
      ),
      body: Column(children: [
        Container(
            color: _kPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                    hintText: 'Search…',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)))),
        // Horizontal scrollable filter chips – built for touch, not dropdowns
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              _mobileTypeChip('All', 'all'),
              _mobileTypeChip('Teacher', 'teacher'),
              _mobileTypeChip('Staff', 'staff'),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 8),
              _mobileDropdownChip(
                  label: _classFilter == null
                      ? 'Class'
                      : (classProvider.classes
                      .firstWhere((c) => c.id == _classFilter,
                      orElse: () => classProvider.classes.first)
                      .name),
                  active: _classFilter != null,
                  onTap: () => _showClassPicker(classProvider)),
              const SizedBox(width: 8),
              _mobileDropdownChip(
                  label: _sectionFilter ?? 'Section',
                  active: _sectionFilter != null,
                  onTap: () => _showSectionPicker(sections)),
            ]),
          ),
        ),
        Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator(color: _kPurple))
                : filtered.isEmpty
                ? _emptyState()
                : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) => _mobileCard(ctx, filtered[i]))),
      ]),
    );
  }

  Widget _mobileTypeChip(String label, String value) {
    final active = _typeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: active,
        selectedColor: _kPurple,
        backgroundColor: _kGreyBg,
        labelStyle: TextStyle(color: active ? Colors.white : const Color(0xFF1A1A2E)),
        onSelected: (_) => setState(() => _typeFilter = value),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _mobileDropdownChip(
      {required String label, required bool active, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: active ? _kPurpleLight : _kGreyBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? _kPurple : Colors.transparent)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: active ? _kPurple : const Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 16, color: active ? _kPurple : Colors.grey),
        ]),
      ),
    );
  }

  void _showClassPicker(ClassProvider classProvider) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
        builder: (ctx) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                  title: const Text('All Classes'),
                  onTap: () {
                    setState(() {
                      _classFilter = null;
                      _sectionFilter = null;
                    });
                    Navigator.pop(ctx);
                  }),
              ...classProvider.classes.where((c) => c.id != null).map((c) => ListTile(
                  title: Text(c.name),
                  onTap: () {
                    setState(() {
                      _classFilter = c.id;
                      _sectionFilter = null;
                    });
                    Navigator.pop(ctx);
                  })),
            ],
          ),
        ));
  }

  void _showSectionPicker(List<String> sections) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
        builder: (ctx) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                  title: const Text('All Sections'),
                  onTap: () {
                    setState(() => _sectionFilter = null);
                    Navigator.pop(ctx);
                  }),
              ...sections.map((s) => ListTile(
                  title: Text(s),
                  onTap: () {
                    setState(() => _sectionFilter = s);
                    Navigator.pop(ctx);
                  })),
            ],
          ),
        ));
  }

  Widget _mobileCard(BuildContext context, StaffMember m) {
    final sections = m.assignedSections;
    final isTeacher = m.type == 'teacher';

    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
            ]),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openProfile(context, m),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              CircleAvatar(
                  radius: 26,
                  backgroundColor: _kPurpleLight,
                  backgroundImage:
                  m.imageBase64 != null ? MemoryImage(base64Decode(m.imageBase64!)) : null,
                  child: m.imageBase64 == null
                      ? Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: _kPurple))
                      : null),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                          child: Text(m.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E)),
                              overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: isTeacher ? const Color(0xFFF0EFFE) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(isTeacher ? 'Teacher' : 'Staff',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isTeacher ? _kPurple : Colors.blue.shade700)),
                      ),
                    ]),
                    if (m.designation?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(m.designation!,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                    const SizedBox(height: 4),
                    Text(
                        'Joined ${_formatDate(m.joiningDate)}  •  Terminated ${_formatDate(m.terminationDate)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      _mobilePill(m.phone, Colors.grey.shade700, Colors.grey.shade100,
                          icon: Icons.phone_outlined),
                      if (sections.isNotEmpty)
                        _mobilePill(sections.first, const Color(0xFF2E7D32),
                            const Color(0xFFE8F5E9),
                            icon: Icons.class_outlined),
                      if (sections.length > 1)
                        _mobilePill('+${sections.length - 1}', Colors.grey.shade600,
                            Colors.grey.shade100),
                    ]),
                  ])),
              const SizedBox(width: 8),
              Column(children: [
                _mobileIconBtn(Icons.person_outline, _kGrey, () => _openProfile(context, m)),
                const SizedBox(height: 6),
                _mobileIconBtn(Icons.restart_alt, const Color(0xFF15803D),
                        () => _confirmRejoin(context, m)),
              ]),
            ]),
          ),
        ));
  }

  Widget _mobilePill(String label, Color textColor, Color bgColor, {IconData? icon}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 11, color: textColor), const SizedBox(width: 3)],
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor)),
      ]));

  Widget _mobileIconBtn(IconData icon, Color color, VoidCallback onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
          width: 34,
          height: 34,
          decoration:
          BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 17, color: color)));
}