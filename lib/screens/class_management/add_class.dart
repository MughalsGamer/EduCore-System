import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../models/class_model.dart';

class ClassFormScreen extends StatefulWidget {
  final ClassModel? classModel;
  const ClassFormScreen({super.key, this.classModel});

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _headTeacherController;
  late TextEditingController _monthlyFeeController;

  bool _hasSections = false;
  List<SectionModel> _sections = [];

  // Class-level fields (used only when sections are OFF)
  List<String> _classSubjects = [];
  List<TimeTableEntry> _classTimeTable = [];

  bool get isEditing => widget.classModel != null;

  @override
  void initState() {
    super.initState();
    final c = widget.classModel;
    _nameController = TextEditingController(text: c?.name ?? '');
    _headTeacherController = TextEditingController(text: c?.headTeacher ?? '');
    _monthlyFeeController = TextEditingController(
        text: c?.monthlyFee?.toString() ?? '');
    _hasSections = c?.hasSections ?? false;
    _sections = c?.sections ?? [];
    _classSubjects = c?.subjects ?? [];
    _classTimeTable = c?.timeTable ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headTeacherController.dispose();
    _monthlyFeeController.dispose();
    super.dispose();
  }

  // ---------- Section management ----------
  void _addSection() async {
    final section = await _showSectionDialog();
    if (section != null) setState(() => _sections.add(section));
  }

  void _editSection(int index) async {
    final updated = await _showSectionDialog(existing: _sections[index]);
    if (updated != null) setState(() => _sections[index] = updated);
  }

  void _deleteSection(int index) {
    setState(() => _sections.removeAt(index));
  }

  Future<SectionModel?> _showSectionDialog({SectionModel? existing}) async {
    final className = _nameController.text.trim();
    String existingSuffix = '';
    if (existing != null) {
      final prefix = '$className - ';
      if (existing.name.startsWith(prefix)) {
        existingSuffix = existing.name.substring(prefix.length);
      } else {
        existingSuffix = existing.name;
      }
    }
    return showDialog<SectionModel>(
      context: context,
      builder: (ctx) => _SectionDialog(
        className: className,
        existing: existing,
        existingSuffix: existingSuffix,
      ),
    );
  }

  // ---------- Timetable entry dialog ----------
  Future<TimeTableEntry?> _showTimetableEntryDialog(
      TimeTableEntry? existing) {
    return showDialog<TimeTableEntry>(
      context: context,
      builder: (ctx) => _TimetableEntryDialog(existing: existing),
    );
  }

  // ---------- Save ----------
  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final classData = ClassModel(
      id: isEditing ? widget.classModel!.id : null,
      name: _nameController.text.trim(),
      hasSections: _hasSections,
      headTeacher: _hasSections
          ? null
          : _headTeacherController.text.trim().isEmpty
          ? null
          : _headTeacherController.text.trim(),
      monthlyFee: _hasSections
          ? null
          : _monthlyFeeController.text.trim().isEmpty
          ? null
          : double.tryParse(_monthlyFeeController.text.trim()),
      subjects: _hasSections ? [] : _classSubjects,
      timeTable: _hasSections ? [] : _classTimeTable,
      sections: _hasSections ? _sections : [],
    );

    final provider = Provider.of<ClassProvider>(context, listen: false);
    if (isEditing) {
      await provider.updateClass(widget.classModel!.id!, classData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class updated successfully')),
        );
      }
    } else {
      await provider.addClass(classData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class added successfully')),
        );
      }
    }
    if (mounted) Navigator.pop(context);
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Class' : 'Add New Class'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ----- Class Name (required) -----
            _buildSectionHeader('Basic Information', Icons.info_outline),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Class Name *',
              controller: _nameController,
              validator: (v) => v!.trim().isEmpty ? 'Enter class name' : null,
            ),
            const SizedBox(height: 20),

            // ----- Head Teacher (optional, shown when sections OFF) -----
            if (!_hasSections) ...[
              _buildTextField(
                label: 'Head Teacher (optional)',
                controller: _headTeacherController,
              ),
              const SizedBox(height: 16),
            ],

            // ----- Enable Sections Toggle -----
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                title: const Text('Enable Sections',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  _hasSections
                      ? 'Each section has its own subjects & timetable'
                      : 'Class works as a single group',
                  style: theme.textTheme.bodySmall,
                ),
                value: _hasSections,
                onChanged: (val) => setState(() => _hasSections = val),
                secondary: Icon(
                  _hasSections ? Icons.workspaces_filled : Icons.workspaces_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ----- Sections list (when enabled) -----
            if (_hasSections) ...[
              _buildSectionHeader('Sections', Icons.view_list),
              const SizedBox(height: 8),
              if (_sections.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text('No sections added yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ),
              ..._sections.asMap().entries.map((e) {
                final idx = e.key;
                final sec = e.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(sec.name[0].toUpperCase(),
                          style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(sec.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      [
                        if (sec.headTeacher != null) 'Head: ${sec.headTeacher}',
                        if (sec.monthlyFee != null) 'Fee: ${sec.monthlyFee}',
                        '${sec.subjects.length} subjects',
                        '${sec.timeTable.length} entries',
                      ].where((t) => t.isNotEmpty).join('  •  '),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                          onPressed: () => _editSection(idx),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: theme.colorScheme.error),
                          onPressed: () => _deleteSection(idx),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // Add section button
              FilledButton.icon(
                onPressed: _addSection,
                icon: const Icon(Icons.add),
                label: const Text('Add Section'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ----- Class-level fields (when sections OFF) -----
            if (!_hasSections) ...[
              _buildSectionHeader('Class Details', Icons.settings),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Monthly Fee (optional)',
                controller: _monthlyFeeController,
                keyboardType: TextInputType.number,
                prefixText: '\$ ',
              ),
              const SizedBox(height: 16),
              _buildSubjectsEditor(
                title: 'Subjects (optional)',
                subjects: _classSubjects,
                onChanged: (list) => setState(() => _classSubjects = list),
              ),
              const SizedBox(height: 16),
              _buildTimetableEditor(
                title: 'Timetable (optional)',
                entries: _classTimeTable,
                onChanged: (list) => setState(() => _classTimeTable = list),
              ),
              const SizedBox(height: 24),
            ],

            // ----- Save Button -----
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _save,
                icon: Icon(isEditing ? Icons.save_as : Icons.save),
                label: Text(isEditing ? 'Update Class' : 'Save Class',
                    style: const TextStyle(fontSize: 16)),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Helper widgets ----------
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: validator,
    );
  }

  Widget _buildSubjectsEditor({
    required String title,
    required List<String> subjects,
    required ValueChanged<List<String>> onChanged,
  }) {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'e.g. Mathematics',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    final val = controller.text.trim();
                    if (val.isNotEmpty && !subjects.contains(val)) {
                      onChanged([...subjects, val]);
                      controller.clear();
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subjects
                  .map((s) => Chip(
                label: Text(s),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  onChanged(subjects.where((e) => e != s).toList());
                },
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableEditor({
    required String title,
    required List<TimeTableEntry> entries,
    required ValueChanged<List<TimeTableEntry>> onChanged,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () async {
                    final entry = await _showTimetableEntryDialog(null);
                    if (entry != null) onChanged([...entries, entry]);
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No entries yet',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ),
            ...entries.asMap().entries.map((e) {
              final idx = e.key;
              final entry = e.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: entry.isLunch
                    ? const Icon(Icons.free_breakfast, color: Colors.orange)
                    : const Icon(Icons.access_time),
                title: Text(
                  entry.isLunch
                      ? 'Lunch Break (${entry.day})'
                      : '${entry.subject} (${entry.teacher})',
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Text(
                    '${entry.day}  ${entry.startTime} - ${entry.endTime}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                      onPressed: () async {
                        final updated =
                        await _showTimetableEntryDialog(entry);
                        if (updated != null) {
                          final newList = [...entries];
                          newList[idx] = updated;
                          onChanged(newList);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: theme.colorScheme.error),
                      onPressed: () {
                        final newList = [...entries]..removeAt(idx);
                        onChanged(newList);
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ------- Section Dialog -------
class _SectionDialog extends StatefulWidget {
  final String className;
  final SectionModel? existing;
  final String existingSuffix;
  const _SectionDialog({
    required this.className,
    this.existing,
    this.existingSuffix = '',
  });

  @override
  State<_SectionDialog> createState() => _SectionDialogState();
}

class _SectionDialogState extends State<_SectionDialog> {
  late TextEditingController _suffixCtrl;
  late TextEditingController _headCtrl;
  late TextEditingController _feeCtrl;
  List<String> _subjects = [];
  List<TimeTableEntry> _timetable = [];

  @override
  void initState() {
    super.initState();
    _suffixCtrl = TextEditingController(text: widget.existingSuffix);
    final sec = widget.existing;
    _headCtrl = TextEditingController(text: sec?.headTeacher ?? '');
    _feeCtrl = TextEditingController(
        text: sec?.monthlyFee?.toString() ?? '');
    _subjects = sec?.subjects ?? [];
    _timetable = sec?.timeTable ?? [];
  }

  @override
  void dispose() {
    _suffixCtrl.dispose();
    _headCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<TimeTableEntry?> _showTimetableDialog(TimeTableEntry? existing) {
    return showDialog<TimeTableEntry>(
      context: context,
      builder: (ctx) => _TimetableEntryDialog(existing: existing),
    );
  }

  String get _fullName => '${widget.className} - ${_suffixCtrl.text.trim()}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.school, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(isEditing ? 'Edit Section' : 'Add Section',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section name = ClassName - suffix
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${widget.className} - ',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
                Expanded(
                  child: TextField(
                    controller: _suffixCtrl,
                    decoration: InputDecoration(
                      labelText: 'Section suffix *',
                      hintText: 'e.g. A, Morning',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _headCtrl,
              decoration: InputDecoration(
                labelText: 'Head Teacher (optional)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monthly Fee (optional)',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            _SubjectsEditor(
              subjects: _subjects,
              onChanged: (list) => setState(() => _subjects = list),
            ),
            const SizedBox(height: 16),
            _TimetableSection(
              entries: _timetable,
              onChanged: (list) => setState(() => _timetable = list),
              showEntryDialog: _showTimetableDialog,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_suffixCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Section suffix is required')),
              );
              return;
            }
            final section = SectionModel(
              name: _fullName,
              headTeacher: _headCtrl.text.trim().isEmpty
                  ? null
                  : _headCtrl.text.trim(),
              monthlyFee: _feeCtrl.text.trim().isEmpty
                  ? null
                  : double.tryParse(_feeCtrl.text.trim()),
              subjects: _subjects,
              timeTable: _timetable,
            );
            Navigator.pop(context, section);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ------- Reusable Subject Editor -------
class _SubjectsEditor extends StatefulWidget {
  final List<String> subjects;
  final ValueChanged<List<String>> onChanged;
  const _SubjectsEditor({required this.subjects, required this.onChanged});

  @override
  State<_SubjectsEditor> createState() => _SubjectsEditorState();
}

class _SubjectsEditorState extends State<_SubjectsEditor> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subjects',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Add subject',
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                final val = _controller.text.trim();
                if (val.isNotEmpty && !widget.subjects.contains(val)) {
                  final newList = [...widget.subjects, val];
                  widget.onChanged(newList);
                  _controller.clear();
                }
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.subjects
              .map((s) => Chip(
            label: Text(s),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              final newList =
              widget.subjects.where((e) => e != s).toList();
              widget.onChanged(newList);
            },
          ))
              .toList(),
        ),
      ],
    );
  }
}

// ------- Reusable Timetable Section -------
class _TimetableSection extends StatelessWidget {
  final List<TimeTableEntry> entries;
  final ValueChanged<List<TimeTableEntry>> onChanged;
  final Future<TimeTableEntry?> Function(TimeTableEntry?) showEntryDialog;

  const _TimetableSection({
    required this.entries,
    required this.onChanged,
    required this.showEntryDialog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Timetable',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () async {
                final entry = await showEntryDialog(null);
                if (entry != null) onChanged([...entries, entry]);
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add'),
            ),
          ],
        ),
        if (entries.isEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('No entries',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant))),
        ...entries.asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: entry.isLunch
                ? const Icon(Icons.free_breakfast, color: Colors.orange, size: 20)
                : const Icon(Icons.access_time, size: 20),
            title: Text(
              entry.isLunch
                  ? 'Lunch Break (${entry.day})'
                  : '${entry.subject} (${entry.teacher})',
              style: theme.textTheme.bodySmall,
            ),
            subtitle: Text(
                '${entry.day}  ${entry.startTime} - ${entry.endTime}',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit,
                      color: theme.colorScheme.primary, size: 20),
                  onPressed: () async {
                    final updated = await showEntryDialog(entry);
                    if (updated != null) {
                      final newList = [...entries];
                      newList[idx] = updated;
                      onChanged(newList);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      color: theme.colorScheme.error, size: 20),
                  onPressed: () {
                    final newList = [...entries]..removeAt(idx);
                    onChanged(newList);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ------- Timetable Entry Dialog -------
class _TimetableEntryDialog extends StatefulWidget {
  final TimeTableEntry? existing;
  const _TimetableEntryDialog({this.existing});

  @override
  State<_TimetableEntryDialog> createState() => _TimetableEntryDialogState();
}

class _TimetableEntryDialogState extends State<_TimetableEntryDialog> {
  late TextEditingController dayCtrl, startCtrl, endCtrl, subjectCtrl,
      teacherCtrl;
  late bool isLunch;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    dayCtrl = TextEditingController(text: e?.day ?? 'Monday');
    startCtrl = TextEditingController(text: e?.startTime ?? '');
    endCtrl = TextEditingController(text: e?.endTime ?? '');
    subjectCtrl = TextEditingController(text: e?.subject ?? '');
    teacherCtrl = TextEditingController(text: e?.teacher ?? '');
    isLunch = e?.isLunch ?? false;
  }

  @override
  void dispose() {
    dayCtrl.dispose();
    startCtrl.dispose();
    endCtrl.dispose();
    subjectCtrl.dispose();
    teacherCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(widget.existing == null ? 'Add Time Slot' : 'Edit Time Slot',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: dayCtrl.text,
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ]
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => dayCtrl.text = v!,
              decoration: InputDecoration(
                labelText: 'Day *',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startCtrl,
              decoration: InputDecoration(
                labelText: 'Start Time * (HH:MM)',
                hintText: '09:00',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endCtrl,
              decoration: InputDecoration(
                labelText: 'End Time * (HH:MM)',
                hintText: '10:00',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Lunch Break?'),
              value: isLunch,
              onChanged: (v) => setState(() => isLunch = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (!isLunch) ...[
              const SizedBox(height: 12),
              TextField(
                controller: subjectCtrl,
                decoration: InputDecoration(
                  labelText: 'Subject *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: teacherCtrl,
                decoration: InputDecoration(
                  labelText: 'Teacher *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (dayCtrl.text.trim().isEmpty ||
                startCtrl.text.trim().isEmpty ||
                endCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Day, start and end time are required')),
              );
              return;
            }
            if (!isLunch &&
                (subjectCtrl.text.trim().isEmpty ||
                    teacherCtrl.text.trim().isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Subject and teacher are required for non‑lunch entries')),
              );
              return;
            }
            Navigator.pop(
                context,
                TimeTableEntry(
                  day: dayCtrl.text.trim(),
                  startTime: startCtrl.text.trim(),
                  endTime: endCtrl.text.trim(),
                  subject: isLunch ? '' : subjectCtrl.text.trim(),
                  teacher: isLunch ? '' : teacherCtrl.text.trim(),
                  isLunch: isLunch,
                ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}