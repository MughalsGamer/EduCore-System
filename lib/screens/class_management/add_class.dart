import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../models/class_model.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _name = TextEditingController();
  final _sections = TextEditingController();
  final _subjects = TextEditingController();

  void _save() {
    final cls = ClassModel(
      name: _name.text,
      sections: _sections.text.split(',').map((e) => e.trim()).toList(),
      subjects: _subjects.text.split(',').map((e) => e.trim()).toList(),
    );
    Provider.of<ClassProvider>(context, listen: false).addClass(cls);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Class')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Class Name')),
            TextField(controller: _sections, decoration: const InputDecoration(labelText: 'Sections (comma separated)')),
            TextField(controller: _subjects, decoration: const InputDecoration(labelText: 'Subjects (comma separated)')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}