import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
//  Lightweight row for the Families Report screen.
//  balance > 0  => family owes (Dr)
//  balance < 0  => family is in advance (Cr)
// ─────────────────────────────────────────────
class FamilyReportRow {
  final String familyDocId;
  final String familyId;
  final String familyName;
  final String fatherName;
  final String fatherPhone;
  final double balance;

  FamilyReportRow({
    required this.familyDocId,
    required this.familyId,
    required this.familyName,
    required this.fatherName,
    required this.fatherPhone,
    required this.balance,
  });
}

// ─────────────────────────────────────────────
//  Computes live ledger balance for every family in one go.
//
//  Same formula as FeeCollectionProvider.loadFamilyLedger:
//    balance = sum(fee_challans.currentMonthTotal) - sum(fee_collections.amount)
//
//  Both collections are pulled in full ONCE (not per-family), then
//  grouped client-side by familyDocId. This avoids N+1 queries when
//  there are many families — a single pair of reads instead of
//  2 x familyCount reads.
// ─────────────────────────────────────────────
class FamilyReportService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<List<FamilyReportRow>> buildReport({
    required List<_FamilyBasicInfo> families,
  }) async {
    final results = await Future.wait([
      _db.collection('fee_challans').get(),
      _db.collection('fee_collections').get(),
    ]);

    final challanSnap = results[0];
    final collectionSnap = results[1];

    final Map<String, double> debitByFamily = {};
    for (final doc in challanSnap.docs) {
      final data = doc.data();
      final familyDocId = data['familyDocId'] as String?;
      if (familyDocId == null || familyDocId.isEmpty) continue;
      final amount = (data['currentMonthTotal'] as num?)?.toDouble() ?? 0;
      debitByFamily[familyDocId] = (debitByFamily[familyDocId] ?? 0) + amount;
    }

    final Map<String, double> creditByFamily = {};
    for (final doc in collectionSnap.docs) {
      final data = doc.data();
      final familyDocId = data['familyDocId'] as String?;
      if (familyDocId == null || familyDocId.isEmpty) continue;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      creditByFamily[familyDocId] = (creditByFamily[familyDocId] ?? 0) + amount;
    }

    return families.map((f) {
      final debit = debitByFamily[f.familyDocId] ?? 0;
      final credit = creditByFamily[f.familyDocId] ?? 0;
      return FamilyReportRow(
        familyDocId: f.familyDocId,
        familyId: f.familyId,
        familyName: f.familyName,
        fatherName: f.fatherName,
        fatherPhone: f.fatherPhone,
        balance: debit - credit,
      );
    }).toList()
      ..sort((a, b) => a.familyName.toLowerCase().compareTo(b.familyName.toLowerCase()));
  }
}

// ─────────────────────────────────────────────
//  Minimal input shape — caller (report screen) builds this list
//  from whatever family/admission source it already has grouped
//  (matches the grouping already done in FamilyManagementScreen).
// ─────────────────────────────────────────────
class _FamilyBasicInfo {
  final String familyDocId;
  final String familyId;
  final String familyName;
  final String fatherName;
  final String fatherPhone;

  _FamilyBasicInfo({
    required this.familyDocId,
    required this.familyId,
    required this.familyName,
    required this.fatherName,
    required this.fatherPhone,
  });
}

typedef FamilyBasicInfo = _FamilyBasicInfo;