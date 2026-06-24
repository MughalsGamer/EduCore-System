import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/teacher_provider.dart';
import 'Staff Profile.dart';
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
    Future.microtask(() =>
        context.read<StaffProvider>().fetchTeachers());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Teachers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditStaffScreen(),
            ),
          );
          if (result == true) {
            provider.fetchTeachers();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.teachers.length,
        itemBuilder: (ctx, i) {
          final t = provider.teachers[i];
          return ListTile(
            onTap: () async {                    // ← YE ADD KARO
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StaffProfileScreen(staff: t), // teacher list mein 't', staff list mein 's'
                ),
              );
              if (result == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditStaffScreen(existingStaff: t),
                  ),
                );
              }
            },

            leading: CircleAvatar(
              backgroundImage: t.imageBase64 != null
                  ? MemoryImage(base64Decode(t.imageBase64!))
                  : null,
              child: t.imageBase64 == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(t.name),
            subtitle: Text('${t.employmentType} · ${t.phone}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditStaffScreen(existingStaff: t),
                      ),
                    );
                    if (result == true) {
                      provider.fetchTeachers();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(
                      context, t.id!, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, String id, StaffProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Teacher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteStaff(id);    // now works from either list
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}