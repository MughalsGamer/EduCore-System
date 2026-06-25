//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/teacher_provider.dart';
// import '../../providers/class_provider.dart'; // ← ADD
// import 'Staff Profile.dart';
// import 'add_teacher.dart';
//
// class StaffListScreen extends StatefulWidget {
//   const StaffListScreen({super.key});
//
//   @override
//   State<StaffListScreen> createState() => _StaffListScreenState();
// }
//
// class _StaffListScreenState extends State<StaffListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(
//             () => context.read<StaffProvider>().fetchStaffOnly());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<StaffProvider>();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Staff')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final result = await Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddEditStaffScreen()),
//           );
//           if (result == true) {
//             provider.fetchStaffOnly();
//           }
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: provider.loading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.staffOnly.isEmpty
//           ? const Center(child: Text('No staff members found.'))
//           : ListView.builder(
//         itemCount: provider.staffOnly.length,
//         itemBuilder: (ctx, i) {
//           final s = provider.staffOnly[i];
//           return ListTile(
//             onTap: () async {
//               // ── classIdToName map banao ──
//               final classProvider = context.read<ClassProvider>();
//               final classIdToName = {
//                 for (final c in classProvider.classes)
//                   if (c.id != null) c.id!: c.name,
//               };
//
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => StaffProfileScreen(
//                     staff: s,
//                     classIdToName: classIdToName, // ← PASS
//                   ),
//                 ),
//               );
//               if (result == 'edit') {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         AddEditStaffScreen(existingStaff: s),
//                   ),
//                 );
//               }
//             },
//             leading: CircleAvatar(
//               backgroundImage: s.imageBase64 != null
//                   ? MemoryImage(base64Decode(s.imageBase64!))
//                   : null,
//               child: s.imageBase64 == null
//                   ? const Icon(Icons.person)
//                   : null,
//             ),
//             title: Text(s.name),
//             subtitle: Text('${s.employmentType} · ${s.phone}'),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: () async {
//                     final result = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>
//                             AddEditStaffScreen(existingStaff: s),
//                       ),
//                     );
//                     if (result == true) {
//                       provider.fetchStaffOnly();
//                     }
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () =>
//                       _confirmDelete(context, s.id!, provider),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _confirmDelete(
//       BuildContext context, String id, StaffProvider provider) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Delete Staff?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               provider.deleteStaff(id);
//               Navigator.pop(ctx);
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/class_provider.dart'; // ← ADD
import 'Staff Profile.dart';
import 'add_teacher.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
            () => context.read<StaffProvider>().fetchStaffOnly());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditStaffScreen()),
          );
          if (result == true) {
            provider.fetchStaffOnly();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.staffOnly.isEmpty
          ? const Center(child: Text('No staff members found.'))
          : ListView.builder(
        itemCount: provider.staffOnly.length,
        itemBuilder: (ctx, i) {
          final s = provider.staffOnly[i];
          return ListTile(
            onTap: () async {
              // ── classIdToName map banao ──
              final classProvider = context.read<ClassProvider>();
              final classIdToName = {
                for (final c in classProvider.classes)
                  if (c.id != null) c.id!: c.name,
              };

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StaffProfileScreen(
                    staff: s,
                    classIdToName: classIdToName, // ← PASS
                  ),
                ),
              );
              if (result == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditStaffScreen(existingStaff: s),
                  ),
                );
              }
            },
            leading: CircleAvatar(
              backgroundImage: s.imageBase64 != null
                  ? MemoryImage(base64Decode(s.imageBase64!))
                  : null,
              child: s.imageBase64 == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(s.name),
            subtitle: Text('${s.employmentType} · ${s.phone}'),
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
                            AddEditStaffScreen(existingStaff: s),
                      ),
                    );
                    if (result == true) {
                      provider.fetchStaffOnly();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _confirmDelete(context, s.id!, provider),
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
        title: const Text('Delete Staff?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteStaff(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}