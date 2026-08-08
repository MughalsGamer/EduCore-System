
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/fee_challan_model.dart';
import '../../pdf_files/family_ledger_pdf_generator.dart';
import '../../providers/fee_collection_provider.dart';
import '../../services/family_ledger_pdf_service.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFF0EFFE);
const _kGreen = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFECFDF3);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEF2F2);
const _kBorder = Color(0xFFE5E7EB);
const _kSurface = Color(0xFFF8FAFC);
const _kInk = Color(0xFF1A1A2E);
const _kSlate = Color(0xFF64748B);
const _kAcademyColor = Color(0xFF8B5CF6);

class FamilyLedgerScreen extends StatefulWidget {
  final String familyDocId;
  final String familyName;
  final String fatherName;
  final String familyId;

  const FamilyLedgerScreen({
    super.key,
    required this.familyDocId,
    required this.familyName,
    required this.fatherName,
    required this.familyId,
  });

  @override
  State<FamilyLedgerScreen> createState() => _FamilyLedgerScreenState();
}

class _FamilyLedgerScreenState extends State<FamilyLedgerScreen> {
  List<FeeChallanModel> _challans = [];
  bool _isLoadingChallans = false;
  bool _isPdfBusy = false;

  // PDF mode flag
  bool _includeBreakdown = true;

  // Tracks which ledger entry is currently expanded (index in the list)
  int? _expandedEntryIndex;

  // Cache of futures that fetch individual challans for each row
  final Map<int, Future<FeeChallanModel?>> _challanFutures = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeCollectionProvider>().loadFamilyLedger(widget.familyDocId);
      _loadChallansForPdf();
    });
  }

  Future<void> _loadChallansForPdf() async {
    setState(() => _isLoadingChallans = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('fee_challans')
          .where('familyDocId', isEqualTo: widget.familyDocId)
          .get();
      final list =
      snap.docs.map((d) => FeeChallanModel.fromFirestore(d)).toList();
      list.sort((a, b) => a.generatedDate.compareTo(b.generatedDate));
      if (!mounted) return;
      setState(() => _challans = list);
    } catch (_) {
      // Silent fail
    } finally {
      if (mounted) setState(() => _isLoadingChallans = false);
    }
  }

  // ─── Improved challan number extraction ──────────────────────────────────
  String? _extractChallanNumber(String description) {
    final patterns = [
      r'CH[-\s]?(\d{4})',
      r'CH[-\s]?(\d+)',
    ];
    for (final p in patterns) {
      final regex = RegExp(p, caseSensitive: false);
      final match = regex.firstMatch(description);
      if (match != null) {
        final number = match.group(1) ?? match.group(0);
        if (number != null) {
          if (number.startsWith('CH-')) return number;
          return 'CH-$number';
        }
      }
    }
    return null;
  }

  Future<FeeChallanModel?> _fetchSingleChallan(String challanNumber) async {
    if (challanNumber.isEmpty) return null;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('fee_challans')
          .where('challanNumber', isEqualTo: challanNumber)
          .where('familyDocId', isEqualTo: widget.familyDocId)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return FeeChallanModel.fromFirestore(snap.docs.first);
      }
    } catch (_) {}
    return null;
  }

  Future<FeeChallanModel?> _fetchChallanByDate(DateTime date) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('fee_challans')
          .where('familyDocId', isEqualTo: widget.familyDocId)
          .where('month', isEqualTo: date.month)
          .where('year', isEqualTo: date.year)
          .get();
      if (snap.docs.isNotEmpty) {
        return FeeChallanModel.fromFirestore(snap.docs.first);
      }
    } catch (_) {}
    return null;
  }

  Future<FeeChallanModel?> _getChallanFutureForEntry(FamilyLedgerEntry entry, int index) {
    if (_challanFutures.containsKey(index)) {
      return _challanFutures[index]!;
    }

    final challanNo = _extractChallanNumber(entry.description);
    if (challanNo != null) {
      FeeChallanModel? cached;
      try {
        cached = _challans.firstWhere((c) => c.challanNumber == challanNo);
      } catch (_) {}
      if (cached != null) {
        _challanFutures[index] = Future.value(cached);
        return _challanFutures[index]!;
      }
      _challanFutures[index] = _fetchSingleChallan(challanNo).then((challan) {
        if (challan != null) return challan;
        return _fetchChallanByDate(entry.date);
      });
    } else {
      _challanFutures[index] = _fetchChallanByDate(entry.date);
    }
    return _challanFutures[index]!;
  }

  List<FamilyLedgerCreditEntry> _creditEntriesFromProvider() {
    final entries = context.read<FeeCollectionProvider>().ledgerEntries;
    return entries.where((e) => e.type == 'credit').map((e) {
      return FamilyLedgerCreditEntry(
        date: e.date,
        amount: e.amount,
        description: e.description,
        note: e.note,
      );
    }).toList();
  }

  // ─── PDF methods: pass the flag ──────────────────────────────────────────
  Future<void> _printPdf() async {
    if (_isPdfBusy) return;
    setState(() => _isPdfBusy = true);
    try {
      await FamilyLedgerPdfService.printLedger(
        familyName: widget.familyName,
        fatherName: widget.fatherName,
        familyId: widget.familyId,
        fatherPhone: null,
        challans: _challans,
        credits: _creditEntriesFromProvider(),
        includeBreakdown: _includeBreakdown,
      );
    } catch (e) {
      _showSnack('Print failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isPdfBusy = false);
    }
  }

  Future<void> _downloadPdf() async {
    if (_isPdfBusy) return;
    setState(() => _isPdfBusy = true);
    try {
      await FamilyLedgerPdfService.downloadAndOpen(
        familyName: widget.familyName,
        fatherName: widget.fatherName,
        familyId: widget.familyId,
        fatherPhone: null,
        challans: _challans,
        credits: _creditEntriesFromProvider(),
        includeBreakdown: _includeBreakdown,
      );
    } catch (e) {
      _showSnack('Save failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isPdfBusy = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${widget.familyName} — Ledger',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        actions: [
          // ─── Dropdown for PDF mode (fixed: removed 'icon' parameter) ──
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _includeBreakdown = value == 'withDetails';
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'withDetails',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, size: 18, color: _kPurple),
                    SizedBox(width: 8),
                    Text('With Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'withoutDetails',
                child: Row(
                  children: [
                    Icon(Icons.receipt, size: 18, color: _kPurple),
                    SizedBox(width: 8),
                    Text('Without Details'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(_includeBreakdown ? 'Details' : 'Summary',
                      style: const TextStyle(fontSize: 12)),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
          // ─── Existing buttons ──────────────────────────────────────────
          if (_isPdfBusy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Print PDF',
              onPressed: (_isLoadingChallans) ? null : _printPdf,
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download PDF',
              onPressed: (_isLoadingChallans) ? null : _downloadPdf,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context
                  .read<FeeCollectionProvider>()
                  .loadFamilyLedger(widget.familyDocId);
              _loadChallansForPdf();
              _challanFutures.clear();
            },
          ),
        ],
      ),
      body: isDesktop ? _buildDesktop() : _buildMobile(),
    );
  }

  // ── Layout builders ──

  Widget _buildDesktop() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _familyInfoCard(),
          const SizedBox(height: 18),
          _summaryCardsRow(isDesktop: true),
          const SizedBox(height: 18),
          _ledgerTableCard(),
          const SizedBox(height: 16),
          _noteCard(),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _familyInfoCard(),
          const SizedBox(height: 14),
          _summaryCardsRow(isDesktop: false),
          const SizedBox(height: 14),
          _ledgerTableCard(),
          const SizedBox(height: 14),
          _noteCard(),
        ],
      ),
    );
  }

  // ── Family info card ──
  Widget _familyInfoCard() {
    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _kPurpleLight,
            child: Text(
              widget.familyName.isNotEmpty
                  ? widget.familyName[0].toUpperCase()
                  : 'F',
              style: const TextStyle(
                  color: _kPurple, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.familyName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kInk)),
                const SizedBox(height: 3),
                Text(
                  '${widget.fatherName} • ${widget.familyId}',
                  style:
                  TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary cards ──
  Widget _summaryCardsRow({required bool isDesktop}) {
    final provider = context.watch<FeeCollectionProvider>();
    final entries = provider.ledgerEntries;
    final balance = provider.ledgerBalance;
    final lastEntry = entries.isEmpty ? null : entries.last;

    final netLabel = balance >= 0 ? 'Balance Due' : 'Advance';
    final netColor = balance >= 0 ? _kRed : _kGreen;

    final cards = <Widget>[
      _summaryCard(
        icon: Icons.arrow_downward_rounded,
        iconColor: _kRed,
        iconBg: _kRedBg,
        label: 'Total Challans (Debit)',
        value:
        'Rs ${NumberFormat('#,##0').format(provider.ledgerTotalDebit)}',
        valueColor: _kRed,
      ),
      _summaryCard(
        icon: Icons.arrow_upward_rounded,
        iconColor: _kGreen,
        iconBg: _kGreenBg,
        label: 'Total Paid (Credit)',
        value:
        'Rs ${NumberFormat('#,##0').format(provider.ledgerTotalCredit)}',
        valueColor: _kGreen,
      ),
      _summaryCard(
        icon: Icons.balance_rounded,
        iconColor: _kPurple,
        iconBg: _kPurpleLight,
        label: 'Net Balance',
        value: 'Rs ${NumberFormat('#,##0').format(balance.abs())}',
        valueColor: _kInk,
        badge: netLabel,
        badgeColor: netColor,
      ),
      _summaryCard(
        icon: Icons.event_note_rounded,
        iconColor: _kPurple,
        iconBg: _kPurpleLight,
        label: 'Last Entry',
        value: lastEntry != null
            ? DateFormat('dd MMM yyyy').format(lastEntry.date)
            : '—',
        valueColor: _kInk,
        sub: lastEntry != null
            ? '${lastEntry.type == 'debit' ? 'Debit' : 'Credit'} - Rs ${NumberFormat('#,##0').format(lastEntry.amount)}'
            : 'No entries',
        subColor: lastEntry?.type == 'debit' ? _kRed : _kGreen,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((c) => Expanded(
            child: Padding(
                padding: const EdgeInsets.only(right: 12), child: c)))
            .toList(),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: cards,
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required Color valueColor,
    String? sub,
    Color? subColor,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label,
              style:
              TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: valueColor)),
          const SizedBox(height: 4),
          if (badge != null)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? _kSlate).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: badgeColor ?? _kSlate)),
            )
          else if (sub != null)
            Text(sub,
                style: TextStyle(
                    fontSize: 11, color: subColor ?? Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ── Ledger table / card ──
  Widget _ledgerTableCard() {
    final provider = context.watch<FeeCollectionProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final entries = provider.ledgerEntries;

    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    size: 16, color: _kPurple),
                const SizedBox(width: 8),
                const Text('Ledger Entries',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kInk)),
                const Spacer(),
                if (provider.isLoadingLedger)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kPurple),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (provider.isLoadingLedger)
            const Padding(
              padding: EdgeInsets.all(40),
              child:
              Center(child: CircularProgressIndicator(color: _kPurple)),
            )
          else if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 44, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text('No ledger entries yet',
                        style: TextStyle(
                            fontSize: 13.5, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            isDesktop ? _desktopTable(entries) : _mobileCardsList(entries),
        ],
      ),
    );
  }

  // ── Desktop table with expandable rows ──
  Widget _desktopTable(List<FamilyLedgerEntry> rows) {
    final provider = context.read<FeeCollectionProvider>();
    final totalDebit = provider.ledgerTotalDebit;
    final totalCredit = provider.ledgerTotalCredit;
    final netBalance = provider.ledgerBalance;

    return Container(
      constraints: const BoxConstraints(maxHeight: 560),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFF8F9FC),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                _Th('DATE', flex: 12),
                _Th('DESCRIPTION', flex: 26),
                _Th('DEBIT (Rs)', flex: 14, align: TextAlign.right),
                _Th('CREDIT (Rs)', flex: 14, align: TextAlign.right),
                _Th('BALANCE (Rs)', flex: 15, align: TextAlign.right),
                _Th('TYPE', flex: 9, align: TextAlign.center),
              ],
            ),
          ),
          Flexible(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final entry = rows[index];
                  final isExpanded = _expandedEntryIndex == index;
                  final challanFuture =
                  entry.type == 'debit'
                      ? _getChallanFutureForEntry(entry, index)
                      : null;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expandedEntryIndex =
                            isExpanded ? null : index;
                          });
                        },
                        child:
                        _desktopRow(entry, isExpanded: isExpanded),
                      ),
                      if (isExpanded && entry.type == 'debit')
                        _challanBreakdownFuture(challanFuture!),
                      Divider(height: 1, color: Colors.grey.shade100),
                    ],
                  );
                },
              ),
            ),
          ),
          _desktopTotalsRow(totalDebit, totalCredit, netBalance),
        ],
      ),
    );
  }

  Widget _desktopRow(FamilyLedgerEntry e, {bool isExpanded = false}) {
    final isDebit = e.type == 'debit';
    final color = isDebit ? _kRed : _kGreen;
    final bal = e.runningBalance;

    return Container(
      color: isExpanded ? _kPurpleLight.withOpacity(0.3) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Expanded(
            flex: 12,
            child: Text(DateFormat('dd MMM yyyy').format(e.date),
                style: const TextStyle(fontSize: 12.5, color: _kInk)),
          ),
          Expanded(
            flex: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(e.description,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: _kInk)),
                    ),
                    if (isDebit)
                      Icon(
                        isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 16,
                        color: _kSlate,
                      ),
                  ],
                ),
                if (e.note != null && e.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(e.note!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              isDebit ? NumberFormat('#,##0').format(e.amount) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDebit ? _kRed : Colors.grey.shade400),
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              !isDebit ? NumberFormat('#,##0').format(e.amount) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: !isDebit ? _kGreen : Colors.grey.shade400),
            ),
          ),
          Expanded(
            flex: 15,
            child: Text(
              '${NumberFormat('#,##0').format(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _kRed),
            ),
          ),
          Expanded(
            flex: 9,
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(isDebit ? 'Debit' : 'Credit',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Student‑wise breakdown (with Academy and Extra Charges) ──
  Widget _challanBreakdownFuture(Future<FeeChallanModel?> future) {
    return FutureBuilder<FeeChallanModel?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
            ),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple),
              ),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
            ),
            child: const Text('Could not load challan details.',
                style: TextStyle(fontSize: 12, color: _kSlate)),
          );
        }
        return _buildChallanBreakdown(snapshot.data!);
      },
    );
  }

  Widget _buildChallanBreakdown(FeeChallanModel challan) {
    final showAcademy = challan.students.any((s) => s.academyFee > 0);
    final hasExtraCharges = challan.extraCharges.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: _kPurple.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STUDENT-WISE BREAKDOWN',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kPurple,
                  letterSpacing: 0.3)),
          const SizedBox(height: 8),
          Table(
            border: TableBorder.all(color: _kBorder, width: 0.5),
            columnWidths: {
              0: const FlexColumnWidth(2.0),
              1: const FlexColumnWidth(1.5),
              2: const FlexColumnWidth(3.0),
              3: const FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: _kPurpleLight),
                children: [
                  const _SubTh('Student'),
                  const _SubTh('Class'),
                  if (showAcademy) const _SubTh('Academy'),
                  const _SubTh('Fee Heads'),
                  const _SubTh('Amount', align: TextAlign.right),
                ],
              ),
              ...challan.students.map((s) {
                final heads = <String>[];
                if (s.isFirstChallan) {
                  if (s.registrationFee > 0)
                    heads.add(
                        'Admission: ${NumberFormat('#,##0').format(s.registrationFee)}');
                  if (s.annualFee > 0)
                    heads.add(
                        'Annual: ${NumberFormat('#,##0').format(s.annualFee)}');
                }
                if (s.monthlyFee > 0)
                  heads.add(
                      'Monthly: ${NumberFormat('#,##0').format(s.monthlyFee)}');
                if (s.academyFee > 0)
                  heads.add(
                      'Academy: ${NumberFormat('#,##0').format(s.academyFee)}');

                final classLabel = [
                  s.className,
                  s.sectionName,
                ].whereType<String>().join(' - ');

                return TableRow(
                  children: [
                    _SubData(s.name, bold: true),
                    _SubData(classLabel),
                    if (showAcademy)
                      _SubData(
                        s.academyFee > 0
                            ? NumberFormat('#,##0').format(s.academyFee)
                            : '—',
                        align: TextAlign.right,
                      ),
                    _SubData(heads.isEmpty ? '—' : heads.join('  •  ')),
                    _SubData(
                      'Rs ${NumberFormat('#,##0').format(s.lineTotal)}',
                      align: TextAlign.right,
                      bold: true,
                      color: _kPurple,
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          // Extra charges section
          if (hasExtraCharges) ...[
            const Divider(height: 8, color: _kBorder),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Extra Charges',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kSlate),
                ),
                Text(
                  'Rs ${NumberFormat('#,##0').format(challan.extraCharges.fold(0.0, (s, e) => s + e.amount))}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kRed),
                ),
              ],
            ),
            ...challan.extraCharges.map((ex) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '  ${ex.label} (${ex.source == 'overall' ? 'All' : 'Family'})',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  Text(
                    'Rs ${NumberFormat('#,##0').format(ex.amount)}',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )),
            const Divider(height: 8, color: _kBorder),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Challan Total: Rs ${NumberFormat('#,##0').format(challan.currentMonthTotal)}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _kRed),
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop totals footer ──
  Widget _desktopTotalsRow(
      double totalDebit, double totalCredit, double netBalance) {
    return Container(
      decoration: BoxDecoration(
        color: _kPurpleLight,
        border: Border(
            top: BorderSide(
                color: _kPurple.withOpacity(0.25), width: 1.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          const Expanded(
            flex: 38,
            child: Text('TOTAL',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _kPurple,
                    letterSpacing: 0.4)),
          ),
          Expanded(
            flex: 14,
            child: Text(
              NumberFormat('#,##0').format(totalDebit),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _kRed),
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              NumberFormat('#,##0').format(totalCredit),
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _kGreen),
            ),
          ),
          Expanded(
            flex: 15,
            child: Text(
              '${NumberFormat('#,##0').format(netBalance.abs())} ${netBalance >= 0 ? 'Dr' : 'Cr'}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _kInk),
            ),
          ),
          const Expanded(flex: 9, child: SizedBox()),
        ],
      ),
    );
  }

  // ── Mobile cards list with expansion ──
  Widget _mobileCardsList(List<FamilyLedgerEntry> rows) {
    final provider = context.read<FeeCollectionProvider>();
    return Container(
      constraints: const BoxConstraints(maxHeight: 520),
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                shrinkWrap: true,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final entry = rows[index];
                  final isExpanded = _expandedEntryIndex == index;
                  final challanFuture =
                  entry.type == 'debit'
                      ? _getChallanFutureForEntry(entry, index)
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedEntryIndex =
                              isExpanded ? null : index;
                            });
                          },
                          child:
                          _mobileRow(entry, isExpanded: isExpanded),
                        ),
                        if (isExpanded && entry.type == 'debit')
                          _challanBreakdownFuture(challanFuture!),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          _mobileTotalsCard(
            provider.ledgerTotalDebit,
            provider.ledgerTotalCredit,
            provider.ledgerBalance,
          ),
        ],
      ),
    );
  }

  Widget _mobileRow(FamilyLedgerEntry e, {bool isExpanded = false}) {
    final isDebit = e.type == 'debit';
    final color = isDebit ? _kRed : _kGreen;
    final bal = e.runningBalance;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpanded ? _kPurpleLight.withOpacity(0.2) : _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isExpanded ? _kPurple.withOpacity(0.4) : _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd MMM yyyy').format(e.date),
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(e.description,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kInk)),
                    ),
                    if (isDebit)
                      Icon(
                        isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 16,
                        color: _kSlate,
                      ),
                  ],
                ),
                if (e.note != null && e.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(e.note!,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${NumberFormat('#,##0').format(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _kRed),
              ),
              const SizedBox(height: 6),
              Text('Rs ${NumberFormat('#,##0').format(e.amount)}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color)),
              const SizedBox(height: 4),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(isDebit ? 'Debit' : 'Credit',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileTotalsCard(
      double totalDebit, double totalCredit, double netBalance) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kPurpleLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPurple.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Debit',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade700)),
              Text('Rs ${NumberFormat('#,##0').format(totalDebit)}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _kRed)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Credit',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade700)),
              Text('Rs ${NumberFormat('#,##0').format(totalCredit)}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _kGreen)),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Balance',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kPurple)),
              Text(
                '${NumberFormat('#,##0').format(netBalance.abs())} ${netBalance >= 0 ? 'Dr' : 'Cr'}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _kInk),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noteCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _kPurpleLight,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: _kPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Note',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _kPurple)),
                SizedBox(height: 4),
                Text('•  Fee challans increase the balance (Dr)',
                    style: TextStyle(fontSize: 12, color: _kInk)),
                SizedBox(height: 2),
                Text('•  Collected payments reduce the balance (Cr)',
                    style: TextStyle(fontSize: 12, color: _kInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}

// ── Reusable table header and sub-header widgets ──
class _Th extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;
  const _Th(this.label, {this.flex = 1, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8B8FA8),
            letterSpacing: 0.4),
      ),
    );
  }
}

class _SubTh extends StatelessWidget {
  final String label;
  final TextAlign align;
  const _SubTh(this.label, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Text(label,
          textAlign: align,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B))),
    );
  }
}

class _SubData extends StatelessWidget {
  final String text;
  final TextAlign align;
  final bool bold;
  final Color? color;
  const _SubData(this.text,
      {this.align = TextAlign.left, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Text(text,
          textAlign: align,
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            color: color ?? const Color(0xFF1A1A2E),
          )),
    );
  }
}