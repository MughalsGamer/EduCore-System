

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/fee_challan_model.dart';

// ─────────────────────────────────────────────────────────────────────────
// Family Ledger PDF
// ─────────────────────────────────────────────────────────────────────────

const _navy = PdfColor.fromInt(0xFF0F1E3D);
const _purple = PdfColor.fromInt(0xFF534AB7);
const _purpleLight = PdfColor.fromInt(0xFFF0EFFE);
const _green = PdfColor.fromInt(0xFF16A34A);
const _greenLight = PdfColor.fromInt(0xFFECFDF3);
const _red = PdfColor.fromInt(0xFFDC2626);
const _redLight = PdfColor.fromInt(0xFFFEF2F2);
const _grey900 = PdfColor.fromInt(0xFF1A1A2E);
const _grey600 = PdfColor.fromInt(0xFF64748B);
const _grey500 = PdfColor.fromInt(0xFF888899);
const _grey200 = PdfColor.fromInt(0xFFE5E7EB);
const _grey100 = PdfColor.fromInt(0xFFF8FAFC);
const _white = PdfColors.white;

String _fmtDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String _fmtMoney(num value) {
  final s = value.abs().toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final reversed = intPart.split('').reversed.toList();
  final buffer = StringBuffer();
  for (var i = 0; i < reversed.length; i++) {
    buffer.write(reversed[i]);
    final posFromEnd = i + 1;
    if (posFromEnd == 3 || (posFromEnd > 3 && (posFromEnd - 3) % 2 == 0)) {
      if (i != reversed.length - 1) buffer.write(',');
    }
  }
  final formattedInt = buffer.toString().split('').reversed.join();
  return '$formattedInt.${parts[1]}';
}

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  if (parts.isNotEmpty && parts[0].isNotEmpty) {
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
  return '?';
}

/// A single credit-side (payment collected) row.
class FamilyLedgerCreditEntry {
  final DateTime date;
  final double amount;
  final String description;
  final String? note;

  FamilyLedgerCreditEntry({
    required this.date,
    required this.amount,
    required this.description,
    this.note,
  });
}

/// Internal unified row used for sorting + running balance calculation.
class _LedgerRow {
  final DateTime date;
  final bool isDebit;
  final double amount;
  final FeeChallanModel? challan;
  final FamilyLedgerCreditEntry? credit;
  double runningBalance = 0;

  _LedgerRow.debit(this.challan)
      : date = challan!.generatedDate,
        isDebit = true,
        amount = challan.currentMonthTotal,
        credit = null;

  _LedgerRow.credit(this.credit)
      : date = credit!.date,
        isDebit = false,
        amount = credit.amount,
        challan = null;
}

// ─────────────────────────────────────────────────────────────────────────
// Main PDF generation – now with `includeBreakdown` flag
// ─────────────────────────────────────────────────────────────────────────
Future<Uint8List> generateFamilyLedgerPdf({
  required String familyName,
  required String fatherName,
  required String familyId,
  required String? fatherPhone,
  required List<FeeChallanModel> challans,
  required List<FamilyLedgerCreditEntry> credits,
  bool includeBreakdown = true, // <── NEW
}) async {
  final pdf = pw.Document();
  final regularFont = pw.Font.helvetica();
  final boldFont = pw.Font.helveticaBold();
  final decorativeFont = pw.Font.timesBold();

  // ── Build unified, chronologically-sorted rows with running balance ──
  final rows = <_LedgerRow>[
    ...challans.map((c) => _LedgerRow.debit(c)),
    ...credits.map((c) => _LedgerRow.credit(c)),
  ]..sort((a, b) => a.date.compareTo(b.date));

  double running = 0;
  for (final r in rows) {
    running += r.isDebit ? r.amount : -r.amount;
    r.runningBalance = running;
  }

  final totalDebit = challans.fold<double>(0, (s, c) => s + c.currentMonthTotal);
  final totalCredit = credits.fold<double>(0, (s, c) => s + c.amount);
  final balance = totalDebit - totalCredit;

  final generatedOn = _fmtDate(DateTime.now());

  // ── Header shown on first page ──
  pw.Widget buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('FAMILY LEDGER', style: pw.TextStyle(fontSize: 20, font: decorativeFont, color: _navy)),
                pw.SizedBox(height: 3),
                pw.Container(width: 60, height: 1.5, color: _purple),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Generated on', style: pw.TextStyle(fontSize: 8, font: regularFont, color: _grey500)),
                pw.Text(generatedOn, style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _grey900)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),

        // Family info card (no image — initials badge instead)
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(color: _purpleLight, borderRadius: pw.BorderRadius.circular(10)),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 40,
                height: 40,
                decoration: const pw.BoxDecoration(shape: pw.BoxShape.circle, color: _purple),
                child: pw.Center(
                  child: pw.Text(_initials(familyName.isNotEmpty ? familyName : fatherName),
                      style: pw.TextStyle(fontSize: 15, font: boldFont, color: _white)),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(familyName.isNotEmpty ? familyName : fatherName,
                        style: pw.TextStyle(fontSize: 12.5, font: boldFont, color: _grey900)),
                    pw.SizedBox(height: 2),
                    pw.Text('Father: $fatherName', style: pw.TextStyle(fontSize: 8.5, font: regularFont, color: _grey600)),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: _miniInfo('Family ID', familyId.isNotEmpty ? familyId : '--', regularFont: regularFont, boldFont: boldFont),
              ),
              pw.Expanded(
                flex: 3,
                child: _miniInfo('Phone', (fatherPhone != null && fatherPhone.isNotEmpty) ? fatherPhone : '--',
                    regularFont: regularFont, boldFont: boldFont),
              ),
              pw.Expanded(
                flex: 2,
                child: _miniInfo('Challans', '${challans.length}', regularFont: regularFont, boldFont: boldFont),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),

        // Summary row
        pw.Row(
          children: [
            pw.Expanded(
              child: _summaryBox(
                label: 'Total Debit (Challans)',
                value: 'Rs ${_fmtMoney(totalDebit)}',
                color: _red,
                bg: _redLight,
                boldFont: boldFont,
                regularFont: regularFont,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _summaryBox(
                label: 'Total Credit (Paid)',
                value: 'Rs ${_fmtMoney(totalCredit)}',
                color: _green,
                bg: _greenLight,
                boldFont: boldFont,
                regularFont: regularFont,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _summaryBox(
                label: balance >= 0 ? 'Balance Due' : 'Advance Balance',
                value: '${balance < 0 ? '-' : ''}Rs ${_fmtMoney(balance.abs())}',
                color: balance >= 0 ? _purple : _green,
                bg: balance >= 0 ? _purpleLight : _greenLight,
                boldFont: boldFont,
                regularFont: regularFont,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  // ── Table header row ──
  pw.TableRow buildTableHeaderRow() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: _navy),
      children: [
        _headerCell('DATE', boldFont),
        _headerCell('PARTICULARS', boldFont),
        _headerCell('DEBIT', boldFont, align: pw.Alignment.centerRight),
        _headerCell('CREDIT', boldFont, align: pw.Alignment.centerRight),
        _headerCell('BALANCE', boldFont, align: pw.Alignment.centerRight),
      ],
    );
  }

  // ── One "block" per row: the summary line, and for debit rows a
  //     compact student-wise breakdown table right underneath (if includeBreakdown) ──
  pw.Widget buildRowBlock(_LedgerRow r, int index) {
    final rowBg = index.isEven ? _white : _grey100;
    final bal = r.runningBalance;

    final summaryLine = pw.Container(
      color: rowBg,
      child: pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(1.6),
          1: pw.FlexColumnWidth(3.6),
          2: pw.FlexColumnWidth(1.6),
          3: pw.FlexColumnWidth(1.6),
          4: pw.FlexColumnWidth(1.8),
        },
        children: [
          pw.TableRow(
            children: [
              _dataCell(_fmtDate(r.date), regularFont),
              _dataCell(
                r.isDebit
                    ? 'Fee Challan   ${r.challan!.challanNumber} (${r.challan!.monthLabel} ${r.challan!.year})'
                    : (r.credit!.note != null && r.credit!.note!.trim().isNotEmpty ? r.credit!.note!.trim() : r.credit!.description),
                regularFont,
                bold: true,
              ),
              _dataCell(
                r.isDebit ? _fmtMoney(r.amount) : '--',
                regularFont,
                align: pw.Alignment.centerRight,
                color: r.isDebit ? _red : _grey500,
                bold: r.isDebit,
              ),
              _dataCell(
                !r.isDebit ? _fmtMoney(r.amount) : '--',
                regularFont,
                align: pw.Alignment.centerRight,
                color: !r.isDebit ? _green : _grey500,
                bold: !r.isDebit,
              ),
              _dataCell(
                '${bal < 0 ? '-' : ''}${_fmtMoney(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
                regularFont,
                align: pw.Alignment.centerRight,
                color: bal >= 0 ? _grey900 : _green,
                bold: true,
              ),
            ],
          ),
        ],
      ),
    );

    // ── If includeBreakdown is false OR this is a credit row, skip the breakdown ──
    if (!includeBreakdown || !r.isDebit) {
      return summaryLine;
    }

    // Debit rows with breakdown (student-wise details)
    final challan = r.challan!;
    return pw.Container(
      color: rowBg,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          summaryLine,
          pw.Container(
            margin: const pw.EdgeInsets.fromLTRB(30, 0, 8, 8),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _white,
              border: pw.Border.all(color: _grey200, width: 0.6),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('STUDENT-WISE BREAKDOWN',
                    style: pw.TextStyle(fontSize: 6.8, font: boldFont, color: _grey600, letterSpacing: 0.4)),
                pw.SizedBox(height: 5),
                pw.Table(
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2.6),
                    1: pw.FlexColumnWidth(1.6),
                    2: pw.FlexColumnWidth(3.6),
                    3: pw.FlexColumnWidth(1.4),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        _subHeaderCell('Student', boldFont),
                        _subHeaderCell('Class', boldFont),
                        _subHeaderCell('Fee Heads', boldFont),
                        _subHeaderCell('Amount', boldFont, align: pw.Alignment.centerRight),
                      ],
                    ),
                    ...challan.students.map((s) {
                      final heads = <String>[];
                      if (s.isFirstChallan) {
                        if (s.registrationFee > 0) heads.add('Admission: Rs ${_fmtMoney(s.registrationFee)}');
                        if (s.annualFee > 0) heads.add('Annual: Rs ${_fmtMoney(s.annualFee)}');
                      }
                      if (s.monthlyFee > 0) heads.add('Monthly: Rs ${_fmtMoney(s.monthlyFee)}');
                      if (s.academyFee > 0) heads.add('Academy: Rs ${_fmtMoney(s.academyFee)}');

                      final classLabel = (s.className != null && s.className!.isNotEmpty)
                          ? (s.sectionName != null && s.sectionName!.isNotEmpty ? '${s.className} - ${s.sectionName}' : s.className!)
                          : '';

                      return pw.TableRow(
                        children: [
                          _subDataCell(s.name, regularFont, bold: true),
                          _subDataCell(classLabel, regularFont),
                          _subDataCell(heads.isEmpty ? '' : heads.join('    '), regularFont),
                          _subDataCell('Rs ${_fmtMoney(s.lineTotal)}', regularFont,
                              align: pw.Alignment.centerRight, bold: true, color: _purple),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Challan Total: Rs ${_fmtMoney(challan.currentMonthTotal)}',
                      style: pw.TextStyle(fontSize: 8, font: boldFont, color: _red)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 28),
      header: (context) => context.pageNumber == 1
          ? buildHeader()
          : pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          '${familyName.isNotEmpty ? familyName : fatherName} — Ledger (contd.)',
          style: pw.TextStyle(fontSize: 10, font: boldFont, color: _grey600),
        ),
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}   |   Developed by Ali Haider | 0300-7465064',
          style: pw.TextStyle(fontSize: 8, font: regularFont, color: _grey500),
        ),
      ),
      build: (context) => [
        if (rows.isEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 60),
            child: pw.Center(
              child: pw.Text('No ledger entries recorded for this family.',
                  style: pw.TextStyle(fontSize: 11, font: regularFont, color: _grey500)),
            ),
          )
        else ...[
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(1.6),
              1: pw.FlexColumnWidth(3.6),
              2: pw.FlexColumnWidth(1.6),
              3: pw.FlexColumnWidth(1.6),
              4: pw.FlexColumnWidth(1.8),
            },
            children: [buildTableHeaderRow()],
          ),
          pw.SizedBox(height: 2),
          ...rows.asMap().entries.map((e) => buildRowBlock(e.value, e.key)),
          pw.SizedBox(height: 10),

          // Totals footer
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: pw.BoxDecoration(color: _purpleLight, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Table(
              columnWidths: const {
                0: pw.FlexColumnWidth(3.6),
                1: pw.FlexColumnWidth(1.6),
                2: pw.FlexColumnWidth(1.6),
                3: pw.FlexColumnWidth(1.8),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('TOTAL', style: pw.TextStyle(fontSize: 9, font: boldFont, color: _purple, letterSpacing: 0.4)),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(_fmtMoney(totalDebit), style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _red)),
                    ),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(_fmtMoney(totalCredit), style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _green)),
                    ),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text('${balance < 0 ? '-' : ''}${_fmtMoney(balance.abs())} ${balance >= 0 ? 'Dr' : 'Cr'}',
                          style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: balance >= 0 ? _grey900 : _green)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );

  return pdf.save();
}

// ─────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────
pw.Widget _miniInfo(String label, String value, {required pw.Font regularFont, required pw.Font boldFont}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: pw.TextStyle(fontSize: 7.5, font: regularFont, color: _grey500)),
      pw.SizedBox(height: 2),
      pw.Text(value, overflow: pw.TextOverflow.clip, style: pw.TextStyle(fontSize: 9, font: boldFont, color: _grey900)),
    ],
  );
}

pw.Widget _summaryBox({
  required String label,
  required String value,
  required PdfColor color,
  required PdfColor bg,
  required pw.Font boldFont,
  required pw.Font regularFont,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: pw.BoxDecoration(color: bg, borderRadius: pw.BorderRadius.circular(8)),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7.5, font: regularFont, color: _grey600)),
        pw.SizedBox(height: 3),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, font: boldFont, color: color)),
      ],
    ),
  );
}

pw.Widget _headerCell(String text, pw.Font font, {pw.Alignment align = pw.Alignment.centerLeft}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
    alignment: align,
    child: pw.Text(text, style: pw.TextStyle(fontSize: 8, font: font, color: _white, letterSpacing: 0.3)),
  );
}

pw.Widget _dataCell(
    String text,
    pw.Font font, {
      pw.Alignment align = pw.Alignment.centerLeft,
      PdfColor? color,
      bool bold = false,
    }) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    alignment: align,
    child: pw.Text(
      text,
      overflow: pw.TextOverflow.clip,
      maxLines: 2,
      style: pw.TextStyle(
        fontSize: 8,
        font: font,
        color: color ?? _grey900,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

pw.Widget _subHeaderCell(String text, pw.Font font, {pw.Alignment align = pw.Alignment.centerLeft}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    alignment: align,
    child: pw.Text(text, style: pw.TextStyle(fontSize: 7, font: font, color: _grey600, letterSpacing: 0.3)),
  );
}

pw.Widget _subDataCell(
    String text,
    pw.Font font, {
      pw.Alignment align = pw.Alignment.centerLeft,
      PdfColor? color,
      bool bold = false,
    }) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    alignment: align,
    child: pw.Text(
      text,
      overflow: pw.TextOverflow.clip,
      maxLines: 2,
      style: pw.TextStyle(
        fontSize: 7.5,
        font: font,
        color: color ?? _grey900,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}