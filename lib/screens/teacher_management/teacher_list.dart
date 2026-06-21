import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';
import '../../models/teacher.dart';
import 'add_teacher.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<TeacherProvider>(context, listen: false).fetchTeachers());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeacherProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Teachers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTeacherScreen())),
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.teachers.length,
        itemBuilder: (ctx, i) {
          Teacher t = provider.teachers[i];
          return ListTile(
            title: Text(t.name),
            subtitle: Text('${t.subject} - ${t.assignedClass}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => provider.deleteTeacher(t.id!),
            ),
          );
        },
      ),
    );
  }
}