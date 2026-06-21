import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../models/student.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _father = TextEditingController();
  final _class = TextEditingController();
  final _section = TextEditingController();
  final _roll = TextEditingController();
  final _date = TextEditingController();
  final _fee = TextEditingController();
  final _uniform = TextEditingController();
  final _books = TextEditingController();

  void _save() {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        name: _name.text,
        fatherName: _father.text,
        className: _class.text,
        section: _section.text,
        rollNumber: _roll.text,
        admissionDate: _date.text,
        annualFee: double.tryParse(_fee.text) ?? 0,
        uniformCharges: double.tryParse(_uniform.text) ?? 0,
        booksCharges: double.tryParse(_books.text) ?? 0,
      );
      Provider.of<StudentProvider>(context, listen: false).addStudent(student);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
              TextFormField(controller: _father, decoration: const InputDecoration(labelText: 'Father Name')),
              TextFormField(controller: _class, decoration: const InputDecoration(labelText: 'Class')),
              TextFormField(controller: _section, decoration: const InputDecoration(labelText: 'Section')),
              TextFormField(controller: _roll, decoration: const InputDecoration(labelText: 'Roll Number')),
              TextFormField(controller: _date, decoration: const InputDecoration(labelText: 'Admission Date')),
              TextFormField(controller: _fee, decoration: const InputDecoration(labelText: 'Annual Fee'), keyboardType: TextInputType.number),
              TextFormField(controller: _uniform, decoration: const InputDecoration(labelText: 'Uniform Charges'), keyboardType: TextInputType.number),
              TextFormField(controller: _books, decoration: const InputDecoration(labelText: 'Books Charges'), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}