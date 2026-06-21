import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/fee_provider.dart';
import '../../models/fee_receipt.dart';

class CollectFeeScreen extends StatefulWidget {
  const CollectFeeScreen({super.key});

  @override
  State<CollectFeeScreen> createState() => _CollectFeeScreenState();
}

class _CollectFeeScreenState extends State<CollectFeeScreen> {
  String? _selectedStudentId;
  final _amount = TextEditingController();
  final _month = TextEditingController();
  final _type = TextEditingController(text: 'cash');

  @override
  void initState() {
    super.initState();
    Provider.of<StudentProvider>(context, listen: false).fetchStudents();
  }

  void _submit() {
    if (_selectedStudentId == null) return;
    final student = Provider.of<StudentProvider>(context, listen: false)
        .students
        .firstWhere((s) => s.id == _selectedStudentId);
    final receipt = FeeReceipt(
      studentId: student.id!,
      studentName: student.name,
      className: student.className,
      amountPaid: double.tryParse(_amount.text) ?? 0,
      date: DateTime.now(),
      month: _month.text,
      paymentType: _type.text,
    );
    Provider.of<FeeProvider>(context, listen: false).addReceipt(receipt);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<StudentProvider>(context).students;
    return Scaffold(
      appBar: AppBar(title: const Text('Collect Fee')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStudentId,
              items: students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => _selectedStudentId = v),
              decoration: const InputDecoration(labelText: 'Student'),
            ),
            TextField(controller: _amount, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            TextField(controller: _month, decoration: const InputDecoration(labelText: 'Month (e.g., Jan 2025)')),
            TextField(controller: _type, decoration: const InputDecoration(labelText: 'Payment Type')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text('Submit Payment')),
          ],
        ),
      ),
    );
  }
}