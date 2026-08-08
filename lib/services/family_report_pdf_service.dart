import 'dart:typed_data';
import 'package:printing/printing.dart';

import '../pdf_files/family_report_pdf_generator.dart';
import 'family_report_service.dart';

// ─────────────────────────────────────────────
//  Print / Save service for the Families Report PDF.
//  `Printing.sharePdf` on Web triggers a browser download AND on
//  most platforms opens/previews it automatically — same pattern
//  already used by FamilyLedgerPdfService, kept 1:1 here so
//  behaviour (auto-open on Web + Mobile) matches the rest of the app.
// ─────────────────────────────────────────────
class FamilyReportPdfService {
  static Future<Uint8List> buildReportPdf({
    required List<FamilyReportRow> families,
  }) async {
    return generateFamiliesReportPdf(families: families);
  }

  static Future<void> printReport({
    required List<FamilyReportRow> families,
  }) async {
    final bytes = await buildReportPdf(families: families);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Families_Report.pdf',
    );
  }

  static Future<void> downloadAndOpen({
    required List<FamilyReportRow> families,
  }) async {
    final bytes = await buildReportPdf(families: families);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Families_Report.pdf',
    );
  }
}