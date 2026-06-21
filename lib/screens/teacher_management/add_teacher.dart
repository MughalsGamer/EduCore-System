import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/teacher_provider.dart';
import '../../models/teacher.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _subject = TextEditingController();
  final _class = TextEditingController();
  final _salary = TextEditingController();

  void _save() {
    if (_formKey.currentState!.validate()) {
      final teacher = Teacher(
        name: _name.text,
        email: _email.text,
        phone: _phone.text,
        subject: _subject.text,
        assignedClass: _class.text,
        salary: double.tryParse(_salary.text) ?? 0,
      );
      Provider.of<TeacherProvider>(context, listen: false).addTeacher(teacher);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Teacher')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
              TextFormField(controller: _subject, decoration: const InputDecoration(labelText: 'Subject')),
              TextFormField(controller: _class, decoration: const InputDecoration(labelText: 'Assigned Class')),
              TextFormField(controller: _salary, decoration: const InputDecoration(labelText: 'Salary'), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}