import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fee_provider.dart';

class FeeReportScreen extends StatefulWidget {
  const FeeReportScreen({super.key});

  @override
  State<FeeReportScreen> createState() => _FeeReportScreenState();
}

class _FeeReportScreenState extends State<FeeReportScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<FeeProvider>(context, listen: false).fetchAllReceipts();
  }

  @override
  Widget build(BuildContext context) {
    final receipts = Provider.of<FeeProvider>(context).receipts;
    double total = receipts.fold(0, (sum, r) => sum + r.amountPaid);
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Report')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total Fees Collected: $total', style: const TextStyle(fontSize: 20)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: receipts.length,
              itemBuilder: (ctx, i) {
                final r = receipts[i];
                return ListTile(
                  title: Text(r.studentName),
                  subtitle: Text('${r.className} - ${r.month}'),
                  trailing: Text('${r.amountPaid}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}