import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../services/family_report_service.dart';


// ─────────────────────────────────────────────
//  Families Report PDF
//  Columns: Family Name | Father Name | Family ID | Balance
// ─────────────────────────────────────────────
Future<Uint8List> generateFamiliesReportPdf({
  required List<FamilyReportRow> families,
}) async {
  final doc = pw.Document();
  final currency = NumberFormat('#,##0');

  final purple = PdfColor.fromHex('#534AB7');
  final purpleLight = PdfColor.fromHex('#F0EFFE');
  final red = PdfColor.fromHex('#DC2626');
  final green = PdfColor.fromHex('#16A34A');
  final border = PdfColor.fromHex('#E5E7EB');
  final ink = PdfColor.fromHex('#1A1A2E');
  final slate = PdfColor.fromHex('#64748B');

  const rowsPerPage = 28;
  final chunks = <List<FamilyReportRow>>[];
  for (var i = 0; i < families.length; i += rowsPerPage) {
    chunks.add(families.sublist(
        i, i + rowsPerPage > families.length ? families.length : i + rowsPerPage));
  }
  if (chunks.isEmpty) chunks.add([]);

  final totalDue = families.where((f) => f.balance > 0).fold(0.0, (s, f) => s + f.balance);
  final totalAdvance =
  families.where((f) => f.balance < 0).fold(0.0, (s, f) => s + f.balance.abs());

  for (var pageIndex = 0; pageIndex < chunks.length; pageIndex++) {
    final pageRows = chunks[pageIndex];

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──
              if (pageIndex == 0) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('EduCore',
                            style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: purple)),
                        pw.SizedBox(height: 2),
                        pw.Text('Families Report',
                            style: pw.TextStyle(fontSize: 13, color: slate)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                            style: pw.TextStyle(fontSize: 10, color: slate)),
                        pw.Text('Total Families: ${families.length}',
                            style: pw.TextStyle(fontSize: 10, color: slate)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    _summaryBox('Total Families', '${families.length}', purple, purpleLight),
                    pw.SizedBox(width: 8),
                    _summaryBox('Total Due (Dr)', 'Rs ${currency.format(totalDue)}', red,
                        PdfColor.fromHex('#FEF2F2')),
                    pw.SizedBox(width: 8),
                    _summaryBox('Total Advance (Cr)', 'Rs ${currency.format(totalAdvance)}',
                        green, PdfColor.fromHex('#ECFDF3')),
                  ],
                ),
                pw.SizedBox(height: 14),
              ] else
                pw.SizedBox(height: 6),

              // ── Table header ──
              pw.Container(
                decoration: pw.BoxDecoration(color: purpleLight),
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4, child: _th('FAMILY NAME', purple)),
                    pw.Expanded(flex: 4, child: _th('FATHER NAME', purple)),
                    pw.Expanded(flex: 3, child: _th('FAMILY ID', purple)),
                    pw.Expanded(flex: 4, child: _th('BALANCE (Rs)', purple, align: pw.TextAlign.right)),
                  ],
                ),
              ),
              pw.Divider(height: 1, color: border, thickness: 1),

              // ── Rows ──
              ...pageRows.map((f) {
                final isDue = f.balance > 0;
                final isZero = f.balance == 0;
                final balColor = isZero ? slate : (isDue ? red : green);
                final balLabel = isZero
                    ? '0'
                    : '${currency.format(f.balance.abs())} ${isDue ? "Dr" : "Cr"}';

                return pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: border, width: 0.5)),
                  ),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                          flex: 4,
                          child: pw.Text(f.familyName.isNotEmpty ? f.familyName : '—',
                              style: pw.TextStyle(fontSize: 10, color: ink))),
                      pw.Expanded(
                          flex: 4,
                          child: pw.Text(f.fatherName.isNotEmpty ? f.fatherName : '—',
                              style: pw.TextStyle(fontSize: 10, color: ink))),
                      pw.Expanded(
                          flex: 3,
                          child: pw.Text(f.familyId.isNotEmpty ? f.familyId : '—',
                              style: pw.TextStyle(fontSize: 10, color: slate))),
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(
                          balLabel,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold, color: balColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // ── Totals footer on last page ──
              if (pageIndex == chunks.length - 1) ...[
                pw.SizedBox(height: 10),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: purpleLight,
                    border: pw.Border(top: pw.BorderSide(color: purple, width: 1.2)),
                  ),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Net Balance (all families)',
                          style: pw.TextStyle(
                              fontSize: 11, fontWeight: pw.FontWeight.bold, color: purple)),
                      pw.Text(
                        'Rs ${currency.format((totalDue - totalAdvance).abs())} ${(totalDue - totalAdvance) >= 0 ? "Dr" : "Cr"}',
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold, color: ink),
                      ),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),
              pw.Divider(color: border),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('EduCore School Management System',
                      style: pw.TextStyle(fontSize: 8, color: slate)),
                  pw.Text('Page ${pageIndex + 1} of ${chunks.length}',
                      style: pw.TextStyle(fontSize: 8, color: slate)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  return doc.save();
}

pw.Widget _th(String text, PdfColor color, {pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Text(
    text,
    textAlign: align,
    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: color),
  );
}

pw.Widget _summaryBox(String label, String value, PdfColor fg, PdfColor bg) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8, color: fg)),
          pw.SizedBox(height: 3),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: fg)),
        ],
      ),
    ),
  );
}