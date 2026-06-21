import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../models/student.dart';
import 'add_student.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<StudentProvider>(context, listen: false).fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentScreen())),
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.students.length,
        itemBuilder: (ctx, i) {
          Student s = provider.students[i];
          return ListTile(
            title: Text(s.name),
            subtitle: Text('${s.className} ${s.section} - Roll: ${s.rollNumber}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await provider.deleteStudent(s.id!);
              },
            ),
          );
        },
      ),
    );
  }
}