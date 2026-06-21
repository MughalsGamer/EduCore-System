import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fee_provider.dart';
import '../../models/fee_receipt.dart';

class StudentLedgerScreen extends StatelessWidget {
  final String studentId;
  const StudentLedgerScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeeReceipt>>(
      future: Provider.of<FeeProvider>(context, listen: false)
          .fetchReceiptsByStudent(studentId),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final receipts = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('Student Ledger')),
          body: ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (ctx, i) {
              final r = receipts[i];
              return ListTile(
                title: Text(r.month),
                subtitle: Text('Amount: ${r.amountPaid}'),
                trailing: Text(r.date.toString().substring(0, 10)),
              );
            },
          ),
        );
      },
    );
  }
}