import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admission_model.dart';
import '../../services/Admission_firestore_sercice.dart';


class AdmissionListScreen extends StatelessWidget {
  const AdmissionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admissions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Family Wise'),
              Tab(text: 'Individual'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFamilyList(),
            _buildIndividualList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyList() {
    final firestoreService = FirestoreService();
    return StreamBuilder<List<AdmissionModel>>(
      stream: firestoreService.getAdmissions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final families = snapshot.data!.where((a) => a.type == 'family').toList();
        if (families.isEmpty) return const Center(child: Text('No family admissions'));
        return ListView.builder(
          itemCount: families.length,
          itemBuilder: (context, index) {
            final admission = families[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text('${admission.familyName} (${admission.admissionNo})'),
                subtitle: Text('Children: ${admission.children.length}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Father: ${admission.parent.fatherName}'),
                        Text('Phone: ${admission.parent.phone}'),
                        const Divider(),
                        ...admission.children.map((child) => ListTile(
                          leading: child.studentPictureBase64 != null
                              ? CircleAvatar(
                              backgroundImage: MemoryImage(
                                  base64Decode(child.studentPictureBase64!)))
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(child.studentName),
                          subtitle: Text('Class: ${child.studentClass} | Roll: ${child.rollNo}'),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIndividualList() {
    final firestoreService = FirestoreService();
    return StreamBuilder<List<AdmissionModel>>(
      stream: firestoreService.getAdmissions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final individuals = snapshot.data!.where((a) => a.type == 'individual').toList();
        if (individuals.isEmpty) return const Center(child: Text('No individual admissions'));
        return ListView.builder(
          itemCount: individuals.length,
          itemBuilder: (context, index) {
            final admission = individuals[index];
            final child = admission.children.isNotEmpty ? admission.children.first : null;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: child?.studentPictureBase64 != null
                    ? CircleAvatar(
                    backgroundImage: MemoryImage(base64Decode(child!.studentPictureBase64!)))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(child?.studentName ?? 'N/A'),
                subtitle: Text('Adm No: ${admission.admissionNo} | Class: ${child?.studentClass ?? '-'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteAdmission(context, admission.id!),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteAdmission(BuildContext context, String id) async {
    await FirestoreService().deleteAdmission(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Admission deleted')));
  }
}