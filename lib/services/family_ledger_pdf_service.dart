
import 'dart:typed_data';
import 'package:printing/printing.dart';

import '../../models/fee_challan_model.dart';
import '../pdf_files/family_ledger_pdf_generator.dart';

class FamilyLedgerPdfService {
  static Future<Uint8List> buildLedgerPdf({
    required String familyName,
    required String fatherName,
    required String familyId,
    required String? fatherPhone,
    required List<FeeChallanModel> challans,
    required List<FamilyLedgerCreditEntry> credits,
    bool includeBreakdown = true,
  }) async {
    return generateFamilyLedgerPdf(
      familyName: familyName,
      fatherName: fatherName,
      familyId: familyId,
      fatherPhone: fatherPhone,
      challans: challans,
      credits: credits,
      includeBreakdown: includeBreakdown,
    );
  }

  static Future<void> printLedger({
    required String familyName,
    required String fatherName,
    required String familyId,
    required List<FeeChallanModel> challans,
    required List<FamilyLedgerCreditEntry> credits,
    String? fatherPhone,
    bool includeBreakdown = true,
  }) async {
    final bytes = await buildLedgerPdf(
      familyName: familyName,
      fatherName: fatherName,
      familyId: familyId,
      fatherPhone: fatherPhone,
      challans: challans,
      credits: credits,
      includeBreakdown: includeBreakdown,
    );
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Family_Ledger.pdf',
    );
  }

  static Future<void> downloadAndOpen({
    required String familyName,
    required String fatherName,
    required String familyId,
    required List<FeeChallanModel> challans,
    required List<FamilyLedgerCreditEntry> credits,
    String? fatherPhone,
    bool includeBreakdown = true,
  }) async {
    final bytes = await buildLedgerPdf(
      familyName: familyName,
      fatherName: fatherName,
      familyId: familyId,
      fatherPhone: fatherPhone,
      challans: challans,
      credits: credits,
      includeBreakdown: includeBreakdown,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Family_Ledger.pdf',
    );
  }
}