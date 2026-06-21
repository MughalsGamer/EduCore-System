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
    Future.microtask(() =>
        Provider.of<ClassProvider>(context, listen: false).fetchClasses());
  }

  void _showDeleteError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.role == 'admin';
    final provider = Provider.of<ClassProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Classes'), centerTitle: true),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClassFormScreen()),
        ).then((_) => provider.fetchClasses()),
        child: const Icon(Icons.add),
      )
          : null,
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.classes.isEmpty
          ? const Center(child: Text('No classes added yet'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.classes.length,
        itemBuilder: (ctx, i) {
          ClassModel c = provider.classes[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.class_, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(c.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ),
                      if (isAdmin) ...[
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.orange),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ClassFormScreen(
                                    classModel: c)),
                          ).then((_) => provider.fetchClasses()),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Class'),
                                content: Text(
                                    'Delete ${c.name}? Make sure no students/teachers are assigned.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              bool deleted =
                              await provider.deleteClass(c.name);
                              if (!deleted) {
                                _showDeleteError(
                                    'Cannot delete class. Students or teachers are still assigned.');
                              }
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  if (c.headTeacher != null)
                    Text('Head: ${c.headTeacher}'),
                  if (c.hasSections) ...[
                    const SizedBox(height: 4),
                    const Text('Sections:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    ...c.sections.map((sec) => Padding(
                      padding:
                      const EdgeInsets.only(left: 16, top: 4),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text('• ${sec.name}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                          if (sec.headTeacher != null)
                            Text('  Head: ${sec.headTeacher}'),
                          if (sec.monthlyFee != null)
                            Text(
                                '  Fee: ${sec.monthlyFee}'),
                          if (sec.subjects.isNotEmpty)
                            Text(
                                '  Subjects: ${sec.subjects.join(', ')}'),
                          if (sec.timeTable.isNotEmpty)
                            Text(
                                '  Timetable: ${sec.timeTable.length} entries'),
                        ],
                      ),
                    )),
                  ],
                  if (!c.hasSections) ...[
                    if (c.monthlyFee != null)
                      Text('Monthly Fee: ${c.monthlyFee}'),
                    if (c.subjects.isNotEmpty)
                      Text('Subjects: ${c.subjects.join(', ')}'),
                    if (c.timeTable.isNotEmpty)
                      Text(
                          'Time Table: ${c.timeTable.length} entries'),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}