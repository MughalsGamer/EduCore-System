import 'package:flutter/material.dart';
import '../../models/teacher.dart';
import 'Attendance theme.dart';

/// Shared multi-select widget for picking staff/teachers.
/// Used by both Mode 1 (quick attendance) and Mode 2 (calendar attendance).
///
/// Shows a search bar, a type filter (All / Teacher / Staff), a
/// "Select All Visible" action, and a wrap of selectable chips.
/// Selected staff ids are reported back via [onSelectionChanged].
class StaffMultiSelect extends StatefulWidget {
  final List<StaffMember> allStaff; // combined teachers + staff, active only
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  const StaffMultiSelect({
    super.key,
    required this.allStaff,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  @override
  State<StaffMultiSelect> createState() => _StaffMultiSelectState();
}

class _StaffMultiSelectState extends State<StaffMultiSelect> {
  String _search = '';
  String _typeFilter = 'All'; // All | teacher | staff
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StaffMember> get _visible {
    return widget.allStaff.where((s) {
      final matchesType = _typeFilter == 'All' ||
          s.type.toLowerCase() == _typeFilter.toLowerCase();
      final matchesSearch = _search.isEmpty ||
          s.name.toLowerCase().contains(_search.toLowerCase());
      return matchesType && matchesSearch;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  void _toggle(String id) {
    final updated = Set<String>.from(widget.selectedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    widget.onSelectionChanged(updated);
  }

  void _selectAllVisible() {
    final updated = Set<String>.from(widget.selectedIds);
    for (final s in _visible) {
      if (s.id != null) updated.add(s.id!);
    }
    widget.onSelectionChanged(updated);
  }

  void _clearAll() {
    widget.onSelectionChanged({});
  }

  Widget _typeChip(String label, String value) {
    final selected = _typeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => setState(() => _typeFilter = value),
        selectedColor: AttendanceTheme.primary,
        backgroundColor: AttendanceTheme.surfaceMuted,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AttendanceTheme.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: AttendanceTheme.fieldDecoration(
            'Search staff / teacher...',
            prefixIcon: const Icon(Icons.search_rounded,
                size: 19, color: AttendanceTheme.textMuted),
          ).copyWith(
            suffixIcon: _search.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 18, color: AttendanceTheme.textMuted),
              onPressed: () {
                _searchController.clear();
                setState(() => _search = '');
              },
            )
                : null,
          ),
          style: const TextStyle(fontSize: 13),
          onChanged: (v) => setState(() => _search = v),
        ),
        const SizedBox(height: 10),

        // Type filter chips + select all/clear
        Row(
          children: [
            _typeChip('All', 'All'),
            _typeChip('Teachers', 'teacher'),
            _typeChip('Staff', 'staff'),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Icon(Icons.people_alt_rounded,
                size: 15, color: AttendanceTheme.primary),
            const SizedBox(width: 6),
            Text(
              '${widget.selectedIds.length} selected',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AttendanceTheme.textPrimary),
            ),
            const Spacer(),
            TextButton(
              onPressed: visible.isEmpty ? null : _selectAllVisible,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Select All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: widget.selectedIds.isEmpty ? null : _clearAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Clear',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AttendanceTheme.absent)),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Chip wrap — no inner fixed height/scroll on mobile so the whole
        // page scrolls as one unit instead of trapping a nested scroll.
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
            color: AttendanceTheme.surfaceMuted,
            border: Border.all(color: AttendanceTheme.border),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
          child: visible.isEmpty
              ? AttendanceEmptyState(
            icon: Icons.person_search_rounded,
            title: 'Koi staff/teacher nahi mila',
            subtitle: _search.isNotEmpty
                ? 'Search ya filter badal kar dobara koshish karein'
                : 'Pehle staff/teacher add karein',
          )
              : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visible.map((s) {
              final id = s.id;
              if (id == null) return const SizedBox.shrink();
              final isSelected = widget.selectedIds.contains(id);
              return _StaffChip(
                staff: s,
                selected: isSelected,
                onTap: () => _toggle(id),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StaffChip extends StatelessWidget {
  final StaffMember staff;
  final bool selected;
  final VoidCallback onTap;

  const _StaffChip({
    required this.staff,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AttendanceTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AttendanceTheme.primary : AttendanceTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor:
              selected ? Colors.white : AttendanceTheme.primaryLight,
              child: Text(
                staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AttendanceTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              staff.name,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AttendanceTheme.textPrimary,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 5),
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}