// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../providers/fee_collection_provider.dart';
//
// // ─────────────────────────────────────────────
// //  Design tokens (matches EduCore brand + EmployeeLedgerScreen style)
// // ─────────────────────────────────────────────
// const _kPurple = Color(0xFF534AB7);
// const _kPurpleLight = Color(0xFFF0EFFE);
//
// const _kGreen = Color(0xFF16A34A);
// const _kGreenBg = Color(0xFFECFDF3);
// const _kRed = Color(0xFFDC2626);
// const _kRedBg = Color(0xFFFEF2F2);
//
// const _kBorder = Color(0xFFE5E7EB);
// const _kSurface = Color(0xFFF8FAFC);
// const _kInk = Color(0xFF1A1A2E);
// const _kSlate = Color(0xFF64748B);
//
// // ─────────────────────────────────────────────
// //  Family Ledger Screen
// //  Opened from the family list's "Ledger" button. Shows the merged
// //  chronological ledger for one family: fee_challans = Debit,
// //  fee_collections = Credit, with a running balance — same visual
// //  language as EmployeeLedgerScreen.
// // ─────────────────────────────────────────────
// class FamilyLedgerScreen extends StatefulWidget {
//   final String familyDocId;
//   final String familyName;
//   final String fatherName;
//   final String familyId;
//
//   const FamilyLedgerScreen({
//     super.key,
//     required this.familyDocId,
//     required this.familyName,
//     required this.fatherName,
//     required this.familyId,
//   });
//
//   @override
//   State<FamilyLedgerScreen> createState() => _FamilyLedgerScreenState();
// }
//
// class _FamilyLedgerScreenState extends State<FamilyLedgerScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<FeeCollectionProvider>().loadFamilyLedger(widget.familyDocId);
//     });
//   }
//
//   @override
//   void dispose() {
//     // Don't clear on dispose synchronously against a disposed context;
//     // safe no-op call guarded by mounted checks elsewhere.
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width >= 900;
//
//     return Scaffold(
//       backgroundColor: _kSurface,
//       appBar: AppBar(
//         backgroundColor: _kPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text('${widget.familyName} — Ledger',
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             tooltip: 'Refresh',
//             onPressed: () =>
//                 context.read<FeeCollectionProvider>().loadFamilyLedger(widget.familyDocId),
//           ),
//         ],
//       ),
//       body: isDesktop ? _buildDesktop() : _buildMobile(),
//     );
//   }
//
//   Widget _buildDesktop() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _familyInfoCard(),
//           const SizedBox(height: 18),
//           _summaryCardsRow(isDesktop: true),
//           const SizedBox(height: 18),
//           _ledgerTableCard(),
//           const SizedBox(height: 16),
//           _noteCard(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMobile() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _familyInfoCard(),
//           const SizedBox(height: 14),
//           _summaryCardsRow(isDesktop: false),
//           const SizedBox(height: 14),
//           _ledgerTableCard(),
//           const SizedBox(height: 14),
//           _noteCard(),
//         ],
//       ),
//     );
//   }
//
//   // ── Family info header card ──
//   Widget _familyInfoCard() {
//     return _card(
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: _kPurpleLight,
//             child: Text(
//               widget.familyName.isNotEmpty ? widget.familyName[0].toUpperCase() : 'F',
//               style: const TextStyle(color: _kPurple, fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.familyName,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kInk)),
//                 const SizedBox(height: 3),
//                 Text(
//                   '${widget.fatherName} • ${widget.familyId}',
//                   style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Summary cards: Total Debit / Total Credit / Net Balance / Last txn ──
//   Widget _summaryCardsRow({required bool isDesktop}) {
//     final provider = context.watch<FeeCollectionProvider>();
//     final entries = provider.ledgerEntries;
//     final balance = provider.ledgerBalance;
//     final lastEntry = entries.isEmpty ? null : entries.last;
//
//     final netLabel = balance >= 0 ? 'Balance Due' : 'Advance';
//     final netColor = balance >= 0 ? _kRed : _kGreen;
//
//     final cards = <Widget>[
//       _summaryCard(
//         icon: Icons.arrow_downward_rounded,
//         iconColor: _kRed,
//         iconBg: _kRedBg,
//         label: 'Total Challans (Debit)',
//         value: 'Rs ${NumberFormat('#,##0').format(provider.ledgerTotalDebit)}',
//         valueColor: _kRed,
//       ),
//       _summaryCard(
//         icon: Icons.arrow_upward_rounded,
//         iconColor: _kGreen,
//         iconBg: _kGreenBg,
//         label: 'Total Paid (Credit)',
//         value: 'Rs ${NumberFormat('#,##0').format(provider.ledgerTotalCredit)}',
//         valueColor: _kGreen,
//       ),
//       _summaryCard(
//         icon: Icons.balance_rounded,
//         iconColor: _kPurple,
//         iconBg: _kPurpleLight,
//         label: 'Net Balance',
//         value: 'Rs ${NumberFormat('#,##0').format(balance.abs())}',
//         valueColor: _kInk,
//         badge: netLabel,
//         badgeColor: netColor,
//       ),
//       _summaryCard(
//         icon: Icons.event_note_rounded,
//         iconColor: _kPurple,
//         iconBg: _kPurpleLight,
//         label: 'Last Entry',
//         value: lastEntry != null ? DateFormat('dd MMM yyyy').format(lastEntry.date) : '—',
//         valueColor: _kInk,
//         sub: lastEntry != null
//             ? '${lastEntry.type == 'debit' ? 'Debit' : 'Credit'} - Rs ${NumberFormat('#,##0').format(lastEntry.amount)}'
//             : 'No entries',
//         subColor: lastEntry?.type == 'debit' ? _kRed : _kGreen,
//       ),
//     ];
//
//     if (isDesktop) {
//       return Row(
//         children: cards
//             .map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c)))
//             .toList(),
//       );
//     }
//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisSpacing: 10,
//       mainAxisSpacing: 10,
//       childAspectRatio: 1.5,
//       children: cards,
//     );
//   }
//
//   Widget _summaryCard({
//     required IconData icon,
//     required Color iconColor,
//     required Color iconBg,
//     required String label,
//     required String value,
//     required Color valueColor,
//     String? sub,
//     Color? subColor,
//     String? badge,
//     Color? badgeColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
//             child: Icon(icon, color: iconColor, size: 18),
//           ),
//           const SizedBox(height: 10),
//           Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
//           const SizedBox(height: 4),
//           Text(value,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: valueColor)),
//           const SizedBox(height: 4),
//           if (badge != null)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: (badgeColor ?? _kSlate).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(badge,
//                   style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: badgeColor ?? _kSlate)),
//             )
//           else if (sub != null)
//             Text(sub, style: TextStyle(fontSize: 11, color: subColor ?? Colors.grey.shade500)),
//         ],
//       ),
//     );
//   }
//
//   // ── Ledger table/card ──
//   Widget _ledgerTableCard() {
//     final provider = context.watch<FeeCollectionProvider>();
//     final isDesktop = MediaQuery.of(context).size.width >= 900;
//     final entries = provider.ledgerEntries;
//
//     return _card(
//       padding: EdgeInsets.zero,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
//             child: Row(
//               children: [
//                 const Icon(Icons.receipt_long_rounded, size: 16, color: _kPurple),
//                 const SizedBox(width: 8),
//                 const Text('Ledger Entries',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kInk)),
//                 const Spacer(),
//                 if (provider.isLoadingLedger)
//                   const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple),
//                   ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           if (provider.isLoadingLedger)
//             const Padding(
//               padding: EdgeInsets.all(40),
//               child: Center(child: CircularProgressIndicator(color: _kPurple)),
//             )
//           else if (entries.isEmpty)
//             Padding(
//               padding: const EdgeInsets.all(32),
//               child: Center(
//                 child: Column(
//                   children: [
//                     Icon(Icons.receipt_long_outlined, size: 44, color: Colors.grey.shade300),
//                     const SizedBox(height: 10),
//                     Text('No ledger entries yet', style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500)),
//                   ],
//                 ),
//               ),
//             )
//           else
//             isDesktop ? _desktopTable(entries) : _mobileCardsList(entries),
//         ],
//       ),
//     );
//   }
//
//   Widget _desktopTable(List<FamilyLedgerEntry> rows) {
//     return Container(
//       constraints: const BoxConstraints(maxHeight: 520),
//       child: Column(
//         children: [
//           Container(
//             color: const Color(0xFFF8F9FC),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: const Row(
//               children: [
//                 _Th('DATE', flex: 12),
//                 _Th('DESCRIPTION', flex: 26),
//                 _Th('DEBIT (Rs)', flex: 14, align: TextAlign.right),
//                 _Th('CREDIT (Rs)', flex: 14, align: TextAlign.right),
//                 _Th('BALANCE (Rs)', flex: 15, align: TextAlign.right),
//                 _Th('TYPE', flex: 9, align: TextAlign.center),
//               ],
//             ),
//           ),
//           Flexible(
//             child: Scrollbar(
//               thumbVisibility: true,
//               child: ListView.separated(
//                 shrinkWrap: true,
//                 itemCount: rows.length,
//                 separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
//                 itemBuilder: (context, i) => _desktopRow(rows[i]),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _desktopRow(FamilyLedgerEntry e) {
//     final isDebit = e.type == 'debit';
//     final color = isDebit ? _kRed : _kGreen;
//     final bal = e.runningBalance;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 12,
//             child: Text(DateFormat('dd MMM yyyy').format(e.date), style: const TextStyle(fontSize: 12.5, color: _kInk)),
//           ),
//           Expanded(
//             flex: 26,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(e.description, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, color: _kInk)),
//                 if (e.note != null && e.note!.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 2),
//                     child: Text(e.note!, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//                   ),
//               ],
//             ),
//           ),
//           Expanded(
//             flex: 14,
//             child: Text(
//               isDebit ? NumberFormat('#,##0').format(e.amount) : '—',
//               textAlign: TextAlign.right,
//               style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: isDebit ? _kRed : Colors.grey.shade400),
//             ),
//           ),
//           Expanded(
//             flex: 14,
//             child: Text(
//               !isDebit ? NumberFormat('#,##0').format(e.amount) : '—',
//               textAlign: TextAlign.right,
//               style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: !isDebit ? _kGreen : Colors.grey.shade400),
//             ),
//           ),
//           Expanded(
//             flex: 15,
//             child: Text(
//               '${NumberFormat('#,##0').format(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
//               textAlign: TextAlign.right,
//               style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kRed),
//             ),
//           ),
//           Expanded(
//             flex: 9,
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                 decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
//                 child: Text(isDebit ? 'Debit' : 'Credit',
//                     style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _mobileCardsList(List<FamilyLedgerEntry> rows) {
//     return Container(
//       constraints: const BoxConstraints(maxHeight: 460),
//       child: Scrollbar(
//         thumbVisibility: true,
//         child: ListView.separated(
//           shrinkWrap: true,
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           itemCount: rows.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 8),
//           itemBuilder: (context, i) => _mobileRow(rows[i]),
//         ),
//       ),
//     );
//   }
//
//   Widget _mobileRow(FamilyLedgerEntry e) {
//     final isDebit = e.type == 'debit';
//     final color = isDebit ? _kRed : _kGreen;
//     final bal = e.runningBalance;
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: _kSurface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _kBorder),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(DateFormat('dd MMM yyyy').format(e.date), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//                 const SizedBox(height: 3),
//                 Text(e.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kInk)),
//                 if (e.note != null && e.note!.isNotEmpty) ...[
//                   const SizedBox(height: 2),
//                   Text(e.note!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//                 ],
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '${NumberFormat('#,##0').format(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
//                 style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kRed),
//               ),
//               const SizedBox(height: 6),
//               Text('Rs ${NumberFormat('#,##0').format(e.amount)}',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
//                 child: Text(isDebit ? 'Debit' : 'Credit',
//                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _noteCard() {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(color: _kPurpleLight, borderRadius: BorderRadius.circular(12)),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.info_outline_rounded, size: 18, color: _kPurple),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text('Note', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kPurple)),
//                 SizedBox(height: 4),
//                 Text('•  Fee challans increase the balance (Dr)', style: TextStyle(fontSize: 12, color: _kInk)),
//                 SizedBox(height: 2),
//                 Text('•  Collected payments reduce the balance (Cr)', style: TextStyle(fontSize: 12, color: _kInk)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
//     return Container(
//       width: double.infinity,
//       padding: padding ?? const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _kBorder),
//       ),
//       child: child,
//     );
//   }
// }
//
// class _Th extends StatelessWidget {
//   final String label;
//   final int flex;
//   final TextAlign align;
//   const _Th(this.label, {this.flex = 1, this.align = TextAlign.left});
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: flex,
//       child: Text(
//         label,
//         textAlign: align,
//         style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF8B8FA8), letterSpacing: 0.4),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/fee_collection_provider.dart';

// ─────────────────────────────────────────────
//  Design tokens (matches EduCore brand + EmployeeLedgerScreen style)
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

// ─────────────────────────────────────────────
//  Family Ledger Screen
//  Opened from the family list's "Ledger" button. Shows the merged
//  chronological ledger for one family: fee_challans = Debit,
//  fee_collections = Credit, with a running balance — same visual
//  language as EmployeeLedgerScreen.
// ─────────────────────────────────────────────
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeCollectionProvider>().loadFamilyLedger(widget.familyDocId);
    });
  }

  @override
  void dispose() {
    // Don't clear on dispose synchronously against a disposed context;
    // safe no-op call guarded by mounted checks elsewhere.
    super.dispose();
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<FeeCollectionProvider>().loadFamilyLedger(widget.familyDocId),
          ),
        ],
      ),
      body: isDesktop ? _buildDesktop() : _buildMobile(),
    );
  }

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

  // ── Family info header card ──
  Widget _familyInfoCard() {
    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _kPurpleLight,
            child: Text(
              widget.familyName.isNotEmpty ? widget.familyName[0].toUpperCase() : 'F',
              style: const TextStyle(color: _kPurple, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.familyName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kInk)),
                const SizedBox(height: 3),
                Text(
                  '${widget.fatherName} • ${widget.familyId}',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary cards: Total Debit / Total Credit / Net Balance / Last txn ──
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
        value: 'Rs ${NumberFormat('#,##0').format(provider.ledgerTotalDebit)}',
        valueColor: _kRed,
      ),
      _summaryCard(
        icon: Icons.arrow_upward_rounded,
        iconColor: _kGreen,
        iconBg: _kGreenBg,
        label: 'Total Paid (Credit)',
        value: 'Rs ${NumberFormat('#,##0').format(provider.ledgerTotalCredit)}',
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
        value: lastEntry != null ? DateFormat('dd MMM yyyy').format(lastEntry.date) : '—',
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
            .map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c)))
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
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: valueColor)),
          const SizedBox(height: 4),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? _kSlate).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: badgeColor ?? _kSlate)),
            )
          else if (sub != null)
            Text(sub, style: TextStyle(fontSize: 11, color: subColor ?? Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ── Ledger table/card ──
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
                const Icon(Icons.receipt_long_rounded, size: 16, color: _kPurple),
                const SizedBox(width: 8),
                const Text('Ledger Entries',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kInk)),
                const Spacer(),
                if (provider.isLoadingLedger)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _kPurple),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (provider.isLoadingLedger)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: _kPurple)),
            )
          else if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 44, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Text('No ledger entries yet', style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500)),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rows.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, i) => _desktopRow(rows[i]),
              ),
            ),
          ),
          _desktopTotalsRow(totalDebit, totalCredit, netBalance),
        ],
      ),
    );
  }

  // ── Totals footer row (Desktop) ──
  Widget _desktopTotalsRow(double totalDebit, double totalCredit, double netBalance) {
    return Container(
      decoration: BoxDecoration(
        color: _kPurpleLight,
        border: Border(top: BorderSide(color: _kPurple.withOpacity(0.25), width: 1.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          const Expanded(
            flex: 38,
            child: Text('TOTAL',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _kPurple, letterSpacing: 0.4)),
          ),
          Expanded(
            flex: 14,
            child: Text(
              NumberFormat('#,##0').format(totalDebit),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kRed),
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              NumberFormat('#,##0').format(totalCredit),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kGreen),
            ),
          ),
          Expanded(
            flex: 15,
            child: Text(
              '${NumberFormat('#,##0').format(netBalance.abs())} ${netBalance >= 0 ? 'Dr' : 'Cr'}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kInk),
            ),
          ),
          const Expanded(flex: 9, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _desktopRow(FamilyLedgerEntry e) {
    final isDebit = e.type == 'debit';
    final color = isDebit ? _kRed : _kGreen;
    final bal = e.runningBalance;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Expanded(
            flex: 12,
            child: Text(DateFormat('dd MMM yyyy').format(e.date), style: const TextStyle(fontSize: 12.5, color: _kInk)),
          ),
          Expanded(
            flex: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.description, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, color: _kInk)),
                if (e.note != null && e.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(e.note!, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              isDebit ? NumberFormat('#,##0').format(e.amount) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: isDebit ? _kRed : Colors.grey.shade400),
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              !isDebit ? NumberFormat('#,##0').format(e.amount) : '—',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: !isDebit ? _kGreen : Colors.grey.shade400),
            ),
          ),
          Expanded(
            flex: 15,
            child: Text(
              '${NumberFormat('#,##0').format(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kRed),
            ),
          ),
          Expanded(
            flex: 9,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(isDebit ? 'Debit' : 'Credit',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileCardsList(List<FamilyLedgerEntry> rows) {
    final provider = context.read<FeeCollectionProvider>();
    return Container(
      constraints: const BoxConstraints(maxHeight: 520),
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _mobileRow(rows[i]),
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

  // ── Totals footer card (Mobile) ──
  Widget _mobileTotalsCard(double totalDebit, double totalCredit, double netBalance) {
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
              Text('Total Debit', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              Text('Rs ${NumberFormat('#,##0').format(totalDebit)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kRed)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Credit', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              Text('Rs ${NumberFormat('#,##0').format(totalCredit)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _kGreen)),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Balance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kPurple)),
              Text(
                '${NumberFormat('#,##0').format(netBalance.abs())} ${netBalance >= 0 ? 'Dr' : 'Cr'}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _kInk),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobileRow(FamilyLedgerEntry e) {
    final isDebit = e.type == 'debit';
    final color = isDebit ? _kRed : _kGreen;
    final bal = e.runningBalance;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd MMM yyyy').format(e.date), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 3),
                Text(e.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kInk)),
                if (e.note != null && e.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(e.note!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${NumberFormat('#,##0').format(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kRed),
              ),
              const SizedBox(height: 6),
              Text('Rs ${NumberFormat('#,##0').format(e.amount)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(isDebit ? 'Debit' : 'Credit',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
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
      decoration: BoxDecoration(color: _kPurpleLight, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: _kPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Note', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kPurple)),
                SizedBox(height: 4),
                Text('•  Fee challans increase the balance (Dr)', style: TextStyle(fontSize: 12, color: _kInk)),
                SizedBox(height: 2),
                Text('•  Collected payments reduce the balance (Cr)', style: TextStyle(fontSize: 12, color: _kInk)),
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
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF8B8FA8), letterSpacing: 0.4),
      ),
    );
  }
}