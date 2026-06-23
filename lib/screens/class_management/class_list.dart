import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/class_model.dart';
import 'add_class.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  @override
  void initState() {
    super.initState();
    // Load classes (including their sections) on startup
    Future.microtask(() =>
        Provider.of<ClassProvider>(context, listen: false).fetchClasses());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.role == 'admin';
    final provider = Provider.of<ClassProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClassFormScreen()),
        ).then((_) => provider.fetchClasses()),
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      )
          : null,
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.classes.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('No classes yet',
                style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Tap + to add your first class',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () => provider.fetchClasses(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: provider.classes.length,
          itemBuilder: (ctx, i) {
            final c = provider.classes[i];
            return _ClassCard(
              classModel: c,
              isAdmin: isAdmin,
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ClassFormScreen(classModel: c)),
              ).then((_) => provider.fetchClasses()),
              onDelete: () async {
                // Confirm deletion
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Class'),
                    content: Text(
                        'Are you sure you want to delete ${c.name}?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    // Use the document ID (not the name)
                    await provider.deleteClass(c.id!);
                    _showSuccess('Class deleted successfully');
                  } catch (e) {
                    _showError(
                        'Cannot delete class. Students or teachers may still be assigned.');
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }
}

// ------------------- Card Widget -------------------
class _ClassCard extends StatefulWidget {
  final ClassModel classModel;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClassCard({
    required this.classModel,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<_ClassCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.classModel;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.class_,
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold)),
                          if (c.headTeacher != null)
                            Text('Head: ${c.headTeacher}',
                                style: theme.textTheme.bodySmall),
                          if (c.hasSections)
                            Text('${c.sections.length} sections',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary)),
                          if (!c.hasSections)
                            Text(c.monthlyFee != null
                                ? 'Fee: ${c.monthlyFee}'
                                : 'No fee set',
                                style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    if (widget.isAdmin) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        color: theme.colorScheme.primary,
                        onPressed: widget.onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: theme.colorScheme.error,
                        onPressed: widget.onDelete,
                      ),
                    ],
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              if (_expanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildDetails(c, theme),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(ClassModel c, ThemeData theme) {
    if (c.hasSections) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sections',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...c.sections.map((sec) => _SectionDetail(sec, theme)),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.monthlyFee != null)
            _infoRow('Monthly Fee', c.monthlyFee.toString(), theme),
          if (c.subjects.isNotEmpty)
            _infoRow('Subjects', c.subjects.join(', '), theme),
          if (c.timeTable.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Time Table',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ...c.timeTable.map((t) => _TimetableChip(t, theme)),
          ],
        ],
      );
    }
  }

  Widget _infoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

// ------------------- Section Detail Widget -------------------
class _SectionDetail extends StatelessWidget {
  final SectionModel section;
  final ThemeData theme;

  const _SectionDetail(this.section, this.theme);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.name,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            if (section.headTeacher != null)
              Text('Head: ${section.headTeacher}', style: theme.textTheme.bodySmall),
            if (section.monthlyFee != null)
              Text('Fee: ${section.monthlyFee}', style: theme.textTheme.bodySmall),
            if (section.subjects.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Subjects: ${section.subjects.join(', ')}',
                    style: theme.textTheme.bodySmall),
              ),
            if (section.timeTable.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Timetable',
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...section.timeTable.map((t) => _TimetableChip(t, theme)),
            ],
          ],
        ),
      ),
    );
  }
}

// ------------------- Timetable Chip -------------------
class _TimetableChip extends StatelessWidget {
  final TimeTableEntry entry;
  final ThemeData theme;

  const _TimetableChip(this.entry, this.theme);

  @override
  Widget build(BuildContext context) {
    final label = entry.isLunch
        ? '🍽 Lunch ${entry.day} ${entry.startTime} - ${entry.endTime}'
        : '${entry.day} ${entry.startTime}-${entry.endTime} ${entry.subject} (${entry.teacher})';
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: entry.isLunch ? Colors.orange.shade50 : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: theme.textTheme.bodySmall),
    );
  }
}