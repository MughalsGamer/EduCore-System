import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'student_management/student_list.dart';
import '../widgets/custom_drawer.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout()),
      ]),
      drawer: const CustomDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen())),
          child: const Text('View Students'),
        ),
      ),
    );
  }
}