import 'package:printing/printing.dart';

import '../models/fee_challan_model.dart';
import '../pdf_files/family_ledger_pdf_generator.dart';

/// Thin service wrapper around [generateFamilyLedgerPdf], following the
/// same save/print/open pattern already used by FeeChallanPdfService.
class FamilyLedgerPdfService {
  static Future<void> printLedger({
    required String familyName,
    required String fatherName,
    required String familyId,
    String? fatherPhone,
    required List<FeeChallanModel> challans,
    required List<FamilyLedgerCreditEntry> credits,
  }) async {
    final bytes = await generateFamilyLedgerPdf(
      familyName: familyName,
      fatherName: fatherName,
      familyId: familyId,
      fatherPhone: fatherPhone,
      challans: challans,
      credits: credits,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<void> downloadAndOpen({
    required String familyName,
    required String fatherName,
    required String familyId,
    String? fatherPhone,
    required List<FeeChallanModel> challans,
    required List<FamilyLedgerCreditEntry> credits,
  }) async {
    final bytes = await generateFamilyLedgerPdf(
      familyName: familyName,
      fatherName: fatherName,
      familyId: familyId,
      fatherPhone: fatherPhone,
      challans: challans,
      credits: credits,
    );
    final safeName = (familyName.isNotEmpty ? familyName : fatherName).replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await Printing.sharePdf(bytes: bytes, filename: 'Ledger_$safeName.pdf');
  }
}