import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/fee_challan_model.dart';
import '../models/school_setting_model.dart';

// ─────────────────────────────────────────────
//  Fee Challan PDF Service
//  A4 page, 2 challans printed per page (top/bottom half — the
//  standard "school copy" + "parent copy" tear-off layout).
//  School header (name, logo, phone, address) is pulled from
//  SchoolSettings and passed in by the caller — this service does
//  not touch Firestore/Provider directly, keeping it a pure,
//  fast, synchronous-build PDF layer (same pattern as
//  SalaryPdfService).
// ─────────────────────────────────────────────
class FeeChallanPdfService {
  static const PdfColor _purple = PdfColor.fromInt(0xFF534AB7);
  static const PdfColor _lightPurple = PdfColor.fromInt(0xFFEEECFA);
  static const PdfColor _grey = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFFF3F4F6);
  static const PdfColor _borderGrey = PdfColor.fromInt(0xFFE5E7EB);
  static const PdfColor _red = PdfColor.fromInt(0xFFDC2626);
  static const PdfColor _green = PdfColor.fromInt(0xFF16A34A);

  // ── Public API (mirrors SalaryPdfService) ──

  /// Build a single-challan PDF (used for one-off print/download from
  /// an expanded card, if ever needed) — still lays out 2-per-page
  /// with the same challan repeated is wasteful, so single mode uses
  /// a full-page single copy instead.
  static Future<Uint8List> buildSinglePdf(
      FeeChallanModel challan, SchoolSettings settings) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _challanBlock(challan, settings, compact: false),
          ],
        ),
      ),
    );
    return doc.save();
  }

  /// Build a merged PDF: every challan gets its own half-page slot,
  /// two challans per A4 sheet, minimizing page count for bulk
  /// printing/downloading (mirrors SalaryPdfService.buildMergedPdf).
  static Future<Uint8List> buildMergedPdf(
      List<FeeChallanModel> challans, SchoolSettings settings) async {
    final doc = pw.Document();

    // Chunk into pairs so every page holds exactly 2 challans.
    for (var i = 0; i < challans.length; i += 2) {
      final first = challans[i];
      final second = (i + 1 < challans.length) ? challans[i + 1] : null;

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          build: (context) => pw.Column(
            children: [
              _challanBlock(first, settings, compact: true),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 0,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                        color: _borderGrey, width: 1, style: pw.BorderStyle.dashed),
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              if (second != null)
                _challanBlock(second, settings, compact: true)
              else
                pw.Expanded(child: pw.Container()),
            ],
          ),
        ),
      );
    }

    return doc.save();
  }

  static Future<void> downloadAndOpen(
      FeeChallanModel challan, SchoolSettings settings) async {
    final bytes = await buildSinglePdf(challan, settings);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Challan_${challan.challanNumber}.pdf',
    );
  }

  static Future<void> printChallan(
      FeeChallanModel challan, SchoolSettings settings) async {
    final bytes = await buildSinglePdf(challan, settings);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Challan_${challan.challanNumber}.pdf',
    );
  }

  static Future<void> bulkDownload(
      List<FeeChallanModel> challans, SchoolSettings settings) async {
    final bytes = await buildMergedPdf(challans, settings);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Fee_Challans_Bulk.pdf',
    );
  }

  static Future<void> bulkPrint(
      List<FeeChallanModel> challans, SchoolSettings settings) async {
    final bytes = await buildMergedPdf(challans, settings);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Fee_Challans_Bulk.pdf',
    );
  }

  // ── Layout builders ──

  static pw.Widget _challanBlock(
      FeeChallanModel c, SchoolSettings settings,
      {required bool compact}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderGrey, width: 1),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _schoolHeader(settings),
          pw.SizedBox(height: 8),
          pw.Container(height: 1, color: _borderGrey),
          pw.SizedBox(height: 8),
          _challanMetaRow(c),
          pw.SizedBox(height: 8),
          _studentTable(c),
          pw.SizedBox(height: 8),
          _totalsBlock(c),
          if (!compact) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              'Please pay before the due date to avoid late fee. This is a system-generated challan.',
              style: pw.TextStyle(fontSize: 8, color: _grey),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _schoolHeader(SchoolSettings settings) {
    final hasLogo = settings.logoBase64 != null && settings.logoBase64!.isNotEmpty;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (hasLogo) ...[
          pw.Container(
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              image: pw.DecorationImage(
                image: pw.MemoryImage(
                  base64Decode(settings.logoBase64!),
                ),
                fit: pw.BoxFit.cover,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
        ] else ...[
          pw.Container(
            width: 40,
            height: 40,
            decoration: const pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: _lightPurple,
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              settings.schoolName.isNotEmpty
                  ? settings.schoolName[0].toUpperCase()
                  : 'S',
              style: pw.TextStyle(
                  color: _purple, fontWeight: pw.FontWeight.bold, fontSize: 18),
            ),
          ),
          pw.SizedBox(width: 10),
        ],
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                settings.schoolName.isNotEmpty ? settings.schoolName : 'School Name',
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold, color: _purple),
              ),
              pw.SizedBox(height: 2),
              if (settings.address.isNotEmpty)
                pw.Text(settings.address,
                    style: pw.TextStyle(fontSize: 8, color: _grey)),
              pw.Text(
                [
                  if (settings.phone.isNotEmpty) 'Ph: ${settings.phone}',
                  if (settings.city.isNotEmpty) settings.city,
                ].join('  •  '),
                style: pw.TextStyle(fontSize: 8, color: _grey),
              ),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('FEE CHALLAN',
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold, color: _purple)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _challanMetaRow(FeeChallanModel c) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _metaLine('Family', c.familyName),
              _metaLine('Father', c.fatherName),
              if (c.fatherPhone.isNotEmpty) _metaLine('Phone', c.fatherPhone),
            ],
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _metaLine('Challan #', c.challanNumber),
              _metaLine('Month', '${c.monthLabel} ${c.year}'),
              _metaLine('Family ID', c.familyId),
            ],
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _metaLine('Generated', _fmt(c.generatedDate)),
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 2),
                padding:
                const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFFEF2F2),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text('Due: ${_fmt(c.dueDate)}',
                    style: pw.TextStyle(
                        fontSize: 8,
                        color: _red,
                        fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _metaLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
                text: '$label: ',
                style: pw.TextStyle(fontSize: 8, color: _grey)),
            pw.TextSpan(
                text: value.isNotEmpty ? value : '—',
                style: pw.TextStyle(
                    fontSize: 8.5,
                    color: PdfColors.black,
                    fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _studentTable(FeeChallanModel c) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _lightGrey),
          children: [
            _tableHeaderCell('Student'),
            _tableHeaderCell('Class'),
            _tableHeaderCell('Admission'),
            _tableHeaderCell('Annual'),
            _tableHeaderCell('Monthly'),
            _tableHeaderCell('Total'),
          ],
        ),
        ...c.students.map((s) => pw.TableRow(
          children: [
            _tableCell(s.name, bold: true),
            _tableCell([
              if (s.className != null && s.className!.isNotEmpty) s.className!,
              if (s.sectionName != null && s.sectionName!.isNotEmpty)
                s.sectionName!,
            ].join(' - ')),
            _tableCell(
                s.registrationFee > 0 ? s.registrationFee.toStringAsFixed(0) : '—',
                align: pw.TextAlign.right),
            _tableCell(s.annualFee > 0 ? s.annualFee.toStringAsFixed(0) : '—',
                align: pw.TextAlign.right),
            _tableCell(s.monthlyFee.toStringAsFixed(0), align: pw.TextAlign.right),
            _tableCell(s.lineTotal.toStringAsFixed(0),
                align: pw.TextAlign.right, bold: true),
          ],
        )),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: _purple)),
    );
  }

  static pw.Widget _tableCell(String text,
      {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(text,
          textAlign: align,
          style: pw.TextStyle(
              fontSize: 8,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );
  }

  static pw.Widget _totalsBlock(FeeChallanModel c) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 220,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: _lightPurple,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            _totalRow('Current Month', c.currentMonthTotal),
            if (c.previousBalance > 0)
              _totalRow('Previous Balance', c.previousBalance),
            if (c.previousBalance < 0)
              _totalRow('Advance Carried Forward', c.previousBalance,
                  color: _green),
            pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 3),
                height: 0.5,
                color: _borderGrey),
            _totalRow('Grand Total', c.grandTotal, bold: true),
            if (c.amountPaid > 0) _totalRow('Amount Paid', c.amountPaid),
            if (c.amountPaid > 0)
              _totalRow('Remaining Balance', c.remainingBalance, bold: true),
          ],
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, double value,
      {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: color ?? (bold ? PdfColors.black : _grey))),
          pw.Text('Rs ${value.toStringAsFixed(0)}',
              style: pw.TextStyle(
                  fontSize: bold ? 10 : 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: color ?? (bold ? _purple : PdfColors.black))),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}