import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
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
    Future.microtask(() => Provider.of<ClassProvider>(context, listen: false).fetchClasses());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClassProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddClassScreen())),
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.classes.length,
        itemBuilder: (ctx, i) {
          ClassModel c = provider.classes[i];
          return ListTile(
            title: Text(c.name),
            subtitle: Text('Sections: ${c.sections.join(', ')} | Subjects: ${c.subjects.join(', ')}'),
          );
        },
      ),
    );
  }
}