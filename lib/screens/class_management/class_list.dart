
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/class_model.dart';
import '../../providers/class_provider.dart';
import 'add_class.dart';  // AddEditClassScreen

class ClassesListScreen extends StatefulWidget {
  const ClassesListScreen({super.key});

  @override
  State<ClassesListScreen> createState() => _ClassesListScreenState();
}

class _ClassesListScreenState extends State<ClassesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditClassScreen()),
          );
          if (result == true) {
            // refresh handled by Provider stream
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<ClassProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.classes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.clearError(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.classes.isEmpty) {
            return const Center(child: Text('No classes found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.classes.length,
            itemBuilder: (context, index) {
              final schoolClass = provider.classes[index];
              return _ExpandableClassCard(schoolClass: schoolClass);
            },
          );
        },
      ),
    );
  }
}

// ---------- Expandable Class Card ----------
class _ExpandableClassCard extends StatefulWidget {
  final SchoolClass schoolClass;
  const _ExpandableClassCard({required this.schoolClass});

  @override
  State<_ExpandableClassCard> createState() => _ExpandableClassCardState();
}

class _ExpandableClassCardState extends State<_ExpandableClassCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cls = widget.schoolClass;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Header – always visible, toggles expansion
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cls.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cls.subjects?.length ?? 0} subjects',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Edit & Delete buttons
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditClassScreen(existingClass: cls),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(context, cls),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          // Expanded details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildDetails(cls),
            crossFadeState:
            _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(SchoolClass cls) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          // Head of class teacher
          if (cls.headOfClassTeacher != null && cls.headOfClassTeacher!.isNotEmpty)
            _detailRow(Icons.person, 'Head Teacher: ${cls.headOfClassTeacher}'),
          // Monthly fee
          if (cls.monthlyFee != null)
            _detailRow(Icons.money, 'Monthly Fee: \$${cls.monthlyFee!.toStringAsFixed(2)}'),
          // Subjects
          if (cls.subjects != null && cls.subjects!.isNotEmpty) ...[
            _detailRow(Icons.book, 'Subjects: ${cls.subjects!.join(", ")}'),
          ],
          const SizedBox(height: 8),

          // Class Timetable (compact preview)
          if (cls.timetable != null && cls.timetable!.isNotEmpty) ...[
            Text('Class Timetable:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            _buildTimetablePreview(cls.timetable!),
          ],

          // Sections
          if (cls.sections != null && cls.sections!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Sections:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            ...cls.sections!.map((section) => Card(
              elevation: 0,
              color: Colors.grey.shade50,
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.sectionName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (section.headOfTeacher != null && section.headOfTeacher!.isNotEmpty)
                      Text('Head: ${section.headOfTeacher}'),
                    if (section.monthlyFee != null)
                      Text('Fee: \$${section.monthlyFee!.toStringAsFixed(2)}'),
                    if (section.subjects != null && section.subjects!.isNotEmpty)
                      Text('Subjects: ${section.subjects!.join(", ")}'),
                    if (section.timetable != null && section.timetable!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Timetable:', style: const TextStyle(fontWeight: FontWeight.w600)),
                      _buildTimetablePreview(section.timetable!),
                    ],
                  ],
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  // Compact timetable preview – same style as add/edit "Timetable Preview"
  Widget _buildTimetablePreview(List<TimetableDay> timetable) {
    return Column(
      children: timetable.map((day) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.today, size: 20),
        title: Text(day.day, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          day.periods.map((p) {
            if (p.isLunchBreak) return '🍽 ${p.startTime} - ${p.endTime} (Lunch)';
            return '📚 ${p.startTime} - ${p.endTime}${p.subject != null && p.subject!.isNotEmpty ? " (${p.subject})" : ""}';
          }).join(' | '),
          style: const TextStyle(fontSize: 13),
        ),
      )).toList(),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, SchoolClass cls) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete ${cls.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await context.read<ClassProvider>().deleteClass(cls.id!, cls.name);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}