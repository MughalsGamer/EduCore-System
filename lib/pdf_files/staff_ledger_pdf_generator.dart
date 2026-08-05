import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as pw_fonts;
import 'package:intl/intl.dart';

import '../../../models/employee_trasaction_model.dart';
import '../../../models/teacher.dart';



// ─────────────────────────────────────────────────────────────────────────
// Color palette (matches staff profile PDF for visual consistency)
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
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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


String _staffTypeLabel(String type) {
  switch (type) {
    case 'teacher':
      return 'Teacher';
    case 'academy_staff':
      return 'Academy Staff';
    default:
      return 'Staff';
  }
}

/// Fallback display-category logic (in case StaffTransaction.displayCategory
/// isn't accessible / doesn't exist under that exact name).
String _displayCategory(StaffTransaction t) {
  if (t.category == 'Others' &&
      t.customCategory != null &&
      t.customCategory!.trim().isNotEmpty) {
    return t.customCategory!.trim();
  }
  return t.category;
}

class _FontCache {
  static pw.Font? _iconFont;
  static Future<pw.Font> get iconFont async {
    if (_iconFont != null) return _iconFont!;
    _iconFont = await pw_fonts.PdfGoogleFonts.materialIconsRegular();
    return _iconFont!;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Main PDF generation
// ─────────────────────────────────────────────────────────────────────────
Future<Uint8List> generateEmployeeLedgerPdf({
  required StaffMember employee,
  required List<StaffTransaction> transactions, // ascending by date
  required double balance,
}) async {
  final pdf = pw.Document();
  final regularFont = pw.Font.helvetica();
  final boldFont = pw.Font.helveticaBold();
  final decorativeFont = pw.Font.timesBold();
  final iconFont = await _FontCache.iconFont;

  final totalDebit = transactions
      .where((t) => t.transactionType == 'debit')
      .fold(0.0, (s, t) => s + t.amount);
  final totalCredit = transactions
      .where((t) => t.transactionType == 'credit')
      .fold(0.0, (s, t) => s + t.amount);

  final generatedOn = _fmtDate(DateTime.now());

  // ── Header shown on every page ──
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
                pw.Text('EMPLOYEE LEDGER',
                    style: pw.TextStyle(fontSize: 20, font: decorativeFont, color: _navy)),
                pw.SizedBox(height: 3),
                pw.Container(width: 60, height: 1.5, color: _purple),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Generated on',
                    style: pw.TextStyle(fontSize: 8, font: regularFont, color: _grey500)),
                pw.Text(generatedOn,
                    style: pw.TextStyle(fontSize: 9.5, font: boldFont, color: _grey900)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),

        // Employee info card
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: _purpleLight,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 40,
                height: 40,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: _purple,
                  image: employee.imageBase64 != null
                      ? pw.DecorationImage(
                    image: pw.MemoryImage(base64Decode(employee.imageBase64!)),
                    fit: pw.BoxFit.cover,
                  )
                      : null,
                ),
                child: employee.imageBase64 == null
                    ? pw.Center(
                  child: pw.Text(_initials(employee.name),
                      style: pw.TextStyle(fontSize: 15, font: boldFont, color: _white)),
                )
                    : null,
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(employee.name,
                        style: pw.TextStyle(fontSize: 12.5, font: boldFont, color: _grey900)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      (employee.designation != null && employee.designation!.isNotEmpty)
                          ? employee.designation!
                          : _staffTypeLabel(employee.type),
                      style: pw.TextStyle(fontSize: 8.5, font: regularFont, color: _grey600),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: _miniInfo('Type', _staffTypeLabel(employee.type),
                    regularFont: regularFont, boldFont: boldFont),
              ),
              pw.Expanded(
                flex: 3,
                child: _miniInfo('Phone', employee.phone.isNotEmpty ? employee.phone : '--',
                    regularFont: regularFont, boldFont: boldFont),
              ),
              pw.Expanded(
                flex: 3,
                child: _miniInfo(
                  'Employee ID',
                  (employee.id != null && employee.id!.length >= 6)
                      ? employee.id!.substring(0, 6).toUpperCase()
                      : (employee.id ?? '--'),
                  regularFont: regularFont,
                  boldFont: boldFont,
                ),
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
                label: 'Total Debit',
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
                label: 'Total Credit',
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
                label: balance >= 0 ? 'Debit Balance' : 'Credit Balance',
                value: 'Rs ${_fmtMoney(balance.abs())}',
                color: _purple,
                bg: _purpleLight,
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
        _headerCell('CATEGORY', boldFont),
        _headerCell('DEBIT', boldFont, align: pw.Alignment.centerRight),
        _headerCell('CREDIT', boldFont, align: pw.Alignment.centerRight),
        _headerCell('BALANCE', boldFont, align: pw.Alignment.centerRight),
      ],
    );
  }

  pw.TableRow buildDataRow(StaffTransaction t, int index) {
    final isDebit = t.transactionType == 'debit';
    final bal = t.runningBalance ?? 0;
    final rowBg = index.isEven ? _white : _grey100;

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: rowBg),
      children: [
        _dataCell(_fmtDate(t.date), regularFont),
        _dataCell(
          (t.note != null && t.note!.trim().isNotEmpty)
              ? t.note!.trim()
              : _displayCategory(t),
          regularFont,
        ),
        _dataCell(_displayCategory(t), regularFont),
        _dataCell(
          isDebit ? _fmtMoney(t.amount) : '--',
          regularFont,
          align: pw.Alignment.centerRight,
          color: isDebit ? _red : _grey500,
          bold: isDebit,
        ),
        _dataCell(
          !isDebit ? _fmtMoney(t.amount) : '--',
          regularFont,
          align: pw.Alignment.centerRight,
          color: !isDebit ? _green : _grey500,
          bold: !isDebit,
        ),
        _dataCell(
          '${_fmtMoney(bal.abs())} ${bal >= 0 ? 'Dr' : 'Cr'}',
          regularFont,
          align: pw.Alignment.centerRight,
          color: _grey900,
          bold: true,
        ),
      ],
    );
  }

  // ── Build the ledger table, split automatically across pages ──
  final tableRows = <pw.TableRow>[
    buildTableHeaderRow(),
    ...transactions.asMap().entries.map((e) => buildDataRow(e.value, e.key)),
  ];

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 28),
      header: (context) => context.pageNumber == 1
          ? buildHeader()
          : pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          '${employee.name} — Ledger (contd.)',
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
        if (transactions.isEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 60),
            child: pw.Center(
              child: pw.Text('No transactions recorded for this employee.',
                  style: pw.TextStyle(fontSize: 11, font: regularFont, color: _grey500)),
            ),
          )
        else
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(1.6),
              1: pw.FlexColumnWidth(3.2),
              2: pw.FlexColumnWidth(1.8),
              3: pw.FlexColumnWidth(1.6),
              4: pw.FlexColumnWidth(1.6),
              5: pw.FlexColumnWidth(1.8),
            },
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: _grey200, width: 0.5),
            ),
            children: tableRows,
          ),
      ],
    ),
  );

  return pdf.save();
}

// ─────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────
pw.Widget _miniInfo(String label, String value,
    {required pw.Font regularFont, required pw.Font boldFont}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: pw.TextStyle(fontSize: 7.5, font: regularFont, color: _grey500)),
      pw.SizedBox(height: 2),
      pw.Text(value,
          overflow: pw.TextOverflow.clip,
          style: pw.TextStyle(fontSize: 9, font: boldFont, color: _grey900)),
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
    child: pw.Text(text,
        style: pw.TextStyle(fontSize: 8, font: font, color: _white, letterSpacing: 0.3)),
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