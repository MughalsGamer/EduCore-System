
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
//  Fee Collection — one document per payment made
//  against a family. This is the PURE CREDIT entry
//  in the ledger; FeeChallanModel documents are the
//  DEBIT entries. No balanceBefore/After snapshot is
//  kept here — the running balance is always computed
//  live (sum of all debits - sum of all credits) so
//  there's nothing to go stale or drift out of sync.
//
//  Ledger-friendly fields (type/date/amount/familyDocId)
//  are kept consistent with FeeChallanModel so the two
//  can later be merged into a single chronological
//  ledger view.
// ─────────────────────────────────────────────
class FeeCollectionModel {
  String? id;
  String receiptNumber; // e.g. RCT-0001

  // ── Ledger-common fields ──
  static const String ledgerType = 'credit';
  String familyDocId;
  String familyId;
  String familyName;
  String fatherName;
  String fatherPhone;
  double amount; // ledger "credit amount" for this entry
  DateTime get date => paymentDate; // ledger date

  String paymentMethod; // Cash / Bank / Online
  String? note;

  DateTime paymentDate;
  DateTime createdAt;

  FeeCollectionModel({
    this.id,
    this.receiptNumber = '',
    this.familyDocId = '',
    this.familyId = '',
    this.familyName = '',
    this.fatherName = '',
    this.fatherPhone = '',
    this.amount = 0,
    this.paymentMethod = 'Cash',
    this.note,
    DateTime? paymentDate,
    DateTime? createdAt,
  })  : paymentDate = paymentDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'receiptNumber': receiptNumber,
    'ledgerType': ledgerType,
    'familyDocId': familyDocId,
    'familyId': familyId,
    'familyName': familyName,
    'fatherName': fatherName,
    'fatherPhone': fatherPhone,
    'amount': amount,
    'paymentMethod': paymentMethod,
    'note': note,
    'paymentDate': paymentDate.toIso8601String(),
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory FeeCollectionModel.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return FeeCollectionModel(
      id: doc.id,
      receiptNumber: m['receiptNumber'] ?? '',
      familyDocId: m['familyDocId'] ?? '',
      familyId: m['familyId'] ?? '',
      familyName: m['familyName'] ?? '',
      fatherName: m['fatherName'] ?? '',
      fatherPhone: m['fatherPhone'] ?? '',
      amount: (m['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: m['paymentMethod'] ?? 'Cash',
      note: m['note'],
      paymentDate: m['paymentDate'] != null
          ? DateTime.tryParse(m['paymentDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}