import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../models/class_model.dart';

class ClassFormScreen extends StatefulWidget {
  final ClassModel? classModel; // null => Add, otherwise => Edit
  const ClassFormScreen({super.key, this.classModel});

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Class‑level controllers
  final _nameController = TextEditingController();
  final _headTeacherController = TextEditingController();
  final _monthlyFeeController = TextEditingController();

  bool _hasSections = false;
  List<SectionModel> _sections = [];

  // Class‑level subjects & timetable (used only when _hasSections == false)
  final _subjectController = TextEditingController();
  List<String> _classSubjects = [];
  List<TimeTableEntry> _classTimeTable = [];

  bool get isEditing => widget.classModel != null;

  @override
  void initState() {
    super.initState();
    final c = widget.classModel;
    if (c != null) {
      _nameController.text = c.name;
      _headTeacherController.text = c.headTeacher ?? '';
      _hasSections = c.hasSections;
      _sections = List.from(c.sections);
      _classSubjects = List.from(c.subjects);
      _classTimeTable = List.from(c.timeTable);
      _monthlyFeeController.text =
      c.monthlyFee != null ? c.monthlyFee.toString() : '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headTeacherController.dispose();
    _monthlyFeeController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  // ---------- Section CRUD ----------
  Future<void> _addSection() async {
    final section = await _showSectionDialog();
    if (section != null) {
      setState(() => _sections.add(section));
    }
  }

  Future<void> _editSection(int index) async {
    final updated = await _showSectionDialog(existing: _sections[index]);
    if (updated != null) {
      setState(() => _sections[index] = updated);
    }
  }

  void _deleteSection(int index) {
    setState(() => _sections.removeAt(index));
  }

  // Section dialog – returns new or edited SectionModel
  Future<SectionModel?> _showSectionDialog({SectionModel? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final headCtrl = TextEditingController(text: existing?.headTeacher ?? '');
    final feeCtrl = TextEditingController(
        text: existing?.monthlyFee != null
            ? existing!.monthlyFee.toString()
            : '');
    List<String> subjects = existing != null ? List.from(existing.subjects) : [];
    List<TimeTableEntry> timetable =
    existing != null ? List.from(existing.timeTable) : [];

    final result = await showDialog<SectionModel>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add Section' : 'Edit Section'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Section Name *',
                          hintText: 'e.g. A, B, Morning'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: headCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Head Teacher (optional)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: feeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Monthly Fee (optional)'),
                    ),
                    const SizedBox(height: 16),
                    _buildSubjectsEditor(subjects, (updatedList) {
                      setDialogState(() => subjects = updatedList);
                    }),
                    const SizedBox(height: 16),
                    _buildTimetableEditor(timetable, (updatedList) {
                      setDialogState(() => timetable = updatedList);
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Section name is required')),
                      );
                      return;
                    }
                    final section = SectionModel(
                      name: nameCtrl.text.trim(),
                      headTeacher: headCtrl.text.trim().isNotEmpty
                          ? headCtrl.text.trim()
                          : null,
                      monthlyFee: feeCtrl.text.trim().isNotEmpty
                          ? double.tryParse(feeCtrl.text.trim())
                          : null,
                      subjects: subjects,
                      timeTable: timetable,
                    );
                    Navigator.pop(ctx, section);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    return result;
  }

  // Helper: subjects chip editor (used inside dialog)
  Widget _buildSubjectsEditor(
      List<String> subjects, ValueChanged<List<String>> onChanged) {
    final subCtrl = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subjects', style: Theme.of(context).textTheme.titleSmall),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: subCtrl,
                decoration: const InputDecoration(hintText: 'Add subject'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                final val = subCtrl.text.trim();
                if (val.isNotEmpty && !subjects.contains(val)) {
                  onChanged([...subjects, val]);
                  subCtrl.clear();
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: subjects
              .map((s) => Chip(
            label: Text(s),
            onDeleted: () {
              onChanged(subjects.where((e) => e != s).toList());
            },
          ))
              .toList(),
        ),
      ],
    );
  }

  // Helper: timetable editor (used inside dialog)
  Widget _buildTimetableEditor(
      List<TimeTableEntry> entries, ValueChanged<List<TimeTableEntry>> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time Table', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        ...entries.asMap().entries.map((e) {
          final i = e.key;
          final entry = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                        '${entry.day} ${entry.startTime}-${entry.endTime} ${entry.subject}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () async {
                      final updated = await _showTimetableEntryDialog(entry);
                      if (updated != null) {
                        final newList = [...entries];
                        newList[i] = updated;
                        onChanged(newList);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () {
                      final newList = [...entries]..removeAt(i);
                      onChanged(newList);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        TextButton.icon(
          onPressed: () async {
            final entry = await _showTimetableEntryDialog(null);
            if (entry != null) {
              onChanged([...entries, entry]);
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Entry'),
        ),
      ],
    );
  }

  // Dialog for a single timetable entry (add/edit)
  Future<TimeTableEntry?> _showTimetableEntryDialog(
      TimeTableEntry? existing) async {
    final dayCtrl = TextEditingController(text: existing?.day ?? '');
    final startCtrl = TextEditingController(text: existing?.startTime ?? '');
    final endCtrl = TextEditingController(text: existing?.endTime ?? '');
    final subCtrl = TextEditingController(text: existing?.subject ?? '');
    final teacherCtrl = TextEditingController(text: existing?.teacher ?? '');

    return showDialog<TimeTableEntry>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Time Slot' : 'Edit Time Slot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dayCtrl,
                decoration: const InputDecoration(labelText: 'Day *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: startCtrl,
                decoration: const InputDecoration(
                    labelText: 'Start Time *', hintText: '09:00'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: endCtrl,
                decoration: const InputDecoration(
                    labelText: 'End Time *', hintText: '10:00'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subCtrl,
                decoration: const InputDecoration(labelText: 'Subject *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: teacherCtrl,
                decoration: const InputDecoration(labelText: 'Teacher *'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (dayCtrl.text.trim().isEmpty ||
                  startCtrl.text.trim().isEmpty ||
                  endCtrl.text.trim().isEmpty ||
                  subCtrl.text.trim().isEmpty ||
                  teacherCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }
              Navigator.pop(
                ctx,
                TimeTableEntry(
                  day: dayCtrl.text.trim(),
                  startTime: startCtrl.text.trim(),
                  endTime: endCtrl.text.trim(),
                  subject: subCtrl.text.trim(),
                  teacher: teacherCtrl.text.trim(),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ---------- Class‑level subjects editor ----------
  Widget _buildClassSubjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subjects', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subjectController,
                decoration: const InputDecoration(hintText: 'Add subject'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                final val = _subjectController.text.trim();
                if (val.isNotEmpty && !_classSubjects.contains(val)) {
                  setState(() {
                    _classSubjects.add(val);
                    _subjectController.clear();
                  });
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _classSubjects
              .map((s) => Chip(
            label: Text(s),
            onDeleted: () {
              setState(() => _classSubjects.remove(s));
            },
          ))
              .toList(),
        ),
      ],
    );
  }

  // ---------- Class‑level timetable editor ----------
  Widget _buildClassTimetable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time Table', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        ..._classTimeTable.asMap().entries.map((e) {
          final i = e.key;
          final entry = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                        '${entry.day} ${entry.startTime}-${entry.endTime} ${entry.subject}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () async {
                      final updated =
                      await _showTimetableEntryDialog(entry);
                      if (updated != null) {
                        setState(() => _classTimeTable[i] = updated);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () {
                      setState(() => _classTimeTable.removeAt(i));
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        TextButton.icon(
          onPressed: () async {
            final entry = await _showTimetableEntryDialog(null);
            if (entry != null) {
              setState(() => _classTimeTable.add(entry));
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Entry'),
        ),
      ],
    );
  }

  // ---------- Save ----------
  void _save() {
    if (_formKey.currentState!.validate()) {
      final classData = ClassModel(
        id: isEditing ? widget.classModel!.id : null,
        name: _nameController.text.trim(),
        hasSections: _hasSections,
        headTeacher: _headTeacherController.text.trim().isNotEmpty
            ? _headTeacherController.text.trim()
            : null,
        sections: _hasSections ? _sections : [],
        monthlyFee: !_hasSections && _monthlyFeeController.text.trim().isNotEmpty
            ? double.tryParse(_monthlyFeeController.text.trim())
            : null,
        subjects: !_hasSections ? _classSubjects : [],
        timeTable: !_hasSections ? _classTimeTable : [],
      );

      final provider = Provider.of<ClassProvider>(context, listen: false);
      if (isEditing) {
        provider.updateClass(widget.classModel!.id!, classData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class updated successfully')),
        );
      } else {
        provider.addClass(classData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class added successfully')),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Class' : 'Add New Class'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Class Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Class Name *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.trim().isEmpty ? 'Class name is required' : null,
            ),
            const SizedBox(height: 16),

            // Class Head Teacher
            TextFormField(
              controller: _headTeacherController,
              decoration: const InputDecoration(
                labelText: 'Head Teacher (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Section switch
            SwitchListTile(
              title: const Text('Enable Sections'),
              subtitle: Text(_hasSections
                  ? 'Students will be assigned to a section'
                  : 'Students are assigned directly to the class'),
              value: _hasSections,
              onChanged: (val) {
                setState(() {
                  _hasSections = val;
                  // If switching ON, optionally keep existing sections or start fresh
                });
              },
            ),
            const SizedBox(height: 16),

            // Sections list (when enabled)
            if (_hasSections) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sections',
                      style: Theme.of(context).textTheme.titleMedium),
                  FilledButton.icon(
                    onPressed: _addSection,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Section'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_sections.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No sections added yet.'),
                ),
              ..._sections.asMap().entries.map((entry) {
                final idx = entry.key;
                final sec = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(sec.name),
                    subtitle: Text(
                      [
                        if (sec.headTeacher != null) 'Head: ${sec.headTeacher}',
                        if (sec.monthlyFee != null)
                          'Fee: ${sec.monthlyFee}',
                        if (sec.subjects.isNotEmpty)
                          'Subjects: ${sec.subjects.join(', ')}',
                        if (sec.timeTable.isNotEmpty)
                          'Timetable: ${sec.timeTable.length} entries',
                      ].join(' | '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editSection(idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSection(idx),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Class‑level fields (only when sections disabled)
            if (!_hasSections) ...[
              TextFormField(
                controller: _monthlyFeeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Fee (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildClassSubjects(),
              const SizedBox(height: 16),
              _buildClassTimetable(),
              const SizedBox(height: 24),
            ],

            // Save button
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _save,
              child: Text(isEditing ? 'Update Class' : 'Save Class',
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}