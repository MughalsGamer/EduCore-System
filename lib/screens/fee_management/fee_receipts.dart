import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fee_provider.dart';

class FeeReceiptsScreen extends StatelessWidget {
  const FeeReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FeeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('All Receipts')),
      body: ListView.builder(
        itemCount: provider.receipts.length,
        itemBuilder: (ctx, i) {
          final r = provider.receipts[i];
          return ListTile(
            title: Text(r.studentName),
            subtitle: Text('${r.className} - ${r.month}: ${r.amountPaid}'),
          );
        },
      ),
    );
  }
}