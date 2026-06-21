import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fee_provider.dart';
import '../../models/fee_structure.dart';

class FeeStructureScreen extends StatefulWidget {
  const FeeStructureScreen({super.key});

  @override
  State<FeeStructureScreen> createState() => _FeeStructureScreenState();
}

class _FeeStructureScreenState extends State<FeeStructureScreen> {
  final _class = TextEditingController();
  final _monthly = TextEditingController();
  final _exam = TextEditingController();
  final _annual = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<FeeProvider>(context, listen: false).fetchStructures());
  }

  void _add() {
    final fs = FeeStructure(
      className: _class.text,
      monthlyFee: double.tryParse(_monthly.text) ?? 0,
      examFee: double.tryParse(_exam.text) ?? 0,
      annualFee: double.tryParse(_annual.text) ?? 0,
    );
    Provider.of<FeeProvider>(context, listen: false).addStructure(fs);
    _class.clear(); _monthly.clear(); _exam.clear(); _annual.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FeeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Structure')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(controller: _class, decoration: const InputDecoration(labelText: 'Class')),
                TextField(controller: _monthly, decoration: const InputDecoration(labelText: 'Monthly Fee'), keyboardType: TextInputType.number),
                TextField(controller: _exam, decoration: const InputDecoration(labelText: 'Exam Fee'), keyboardType: TextInputType.number),
                TextField(controller: _annual, decoration: const InputDecoration(labelText: 'Annual Fee'), keyboardType: TextInputType.number),
                ElevatedButton(onPressed: _add, child: const Text('Add Structure')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.structures.length,
              itemBuilder: (ctx, i) {
                FeeStructure fs = provider.structures[i];
                return ListTile(
                  title: Text(fs.className),
                  subtitle: Text('Monthly: ${fs.monthlyFee}, Exam: ${fs.examFee}, Annual: ${fs.annualFee}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}