import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/employee_trasaction_model.dart';
import '../../models/teacher.dart';
import '../../providers/employee_transaction_provider.dart';

const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kGreen = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFECFDF3);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEF2F2);

class EmployeeLedgerScreen extends StatefulWidget {
  final StaffMember employee;

  const EmployeeLedgerScreen({super.key, required this.employee});

  @override
  State<EmployeeLedgerScreen> createState() => _EmployeeLedgerScreenState();
}

class _EmployeeLedgerScreenState extends State<EmployeeLedgerScreen> {
  List<StaffTransaction> _transactions = [];
  double _balance = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLedger();
  }

  Future<void> _loadLedger() async {
    setState(() => _loading = true);
    try {
      final provider = context.read<StaffTransactionProvider>();
      final result = await provider.getEmployeeLedger(widget.employee.id!);
      setState(() {
        _transactions = result['transactions'] ?? [];
        _balance = result['balance'] ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ledger: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                widget.employee.name.isNotEmpty ? widget.employee.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '${widget.employee.name} - Ledger',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kPurple))
          : Column(
        children: [
          // Balance Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _balance >= 0 ? [_kPurple, const Color(0xFF6C63D4)] : [_kRed, const Color(0xFFEF4444)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_balance >= 0 ? _kPurple : _kRed).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${NumberFormat('#,##0').format(_balance.abs())}',
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  _balance >= 0
                      ? '${widget.employee.name} owes the company'
                      : 'Company owes ${widget.employee.name}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _balanceChip('Debit Total', _calculateTotal('debit'), _kRed),
                    const SizedBox(width: 10),
                    _balanceChip('Credit Total', _calculateTotal('credit'), _kGreen),
                  ],
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: _transactions.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final txn = _transactions[index];
                return _buildTransactionCard(txn, index == _transactions.length - 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceChip(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
          ),
          const SizedBox(width: 6),
          Text(
            'Rs ${NumberFormat('#,##0').format(amount)}',
            style: TextStyle(
              color: color == _kRed ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal(String type) {
    return _transactions
        .where((t) => t.transactionType == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Widget _buildTransactionCard(StaffTransaction txn, bool isLast) {
    final isDebit = txn.transactionType == 'debit';
    final color = isDebit ? _kRed : _kGreen;
    final bgColor = isDebit ? _kRedBg : _kGreenBg;
    final icon = isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final label = isDebit ? 'Debit' : 'Credit';

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        txn.displayCategory,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM, yyyy').format(txn.date),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (txn.note != null && txn.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    txn.note!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (txn.salaryRecordId != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: _kPurpleLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Salary',
                      style: TextStyle(fontSize: 9, color: _kPurple, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDebit ? '+' : '-'} Rs ${NumberFormat('#,##0').format(txn.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (txn.runningBalance != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Balance: Rs ${NumberFormat('#,##0').format(txn.runningBalance!.abs())}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}