// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import '../models/admission_model.dart';
// import '../models/fee_challan_model.dart';
// import '../models/fee_collection_model.dart';
//
// // ─────────────────────────────────────────────
// //  Lightweight row used to populate the search list.
// //  Built once from AdmissionProvider's already-loaded
// //  `admissions` list (no extra Firestore read), so
// //  search stays instant / no network round-trip per
// //  keystroke.
// // ─────────────────────────────────────────────
// class FamilyForCollection {
//   final String familyDocId;
//   final String familyId;
//   final String familyName;
//   final String fatherName;
//   final String fatherPhone;
//   final String? firstStudentPicBase64;
//   final int studentCount;
//
//   FamilyForCollection({
//     required this.familyDocId,
//     required this.familyId,
//     required this.familyName,
//     required this.fatherName,
//     required this.fatherPhone,
//     required this.firstStudentPicBase64,
//     required this.studentCount,
//   });
// }
//
// class FeeCollectionProvider extends ChangeNotifier {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   static const String _challansCollection = 'fee_challans';
//   static const String _collectionsCollection = 'fee_collections';
//   static const String _counterDoc = 'counters/fee_collection_counter';
//
//   bool _isSaving = false;
//   bool get isSaving => _isSaving;
//
//   String? _error;
//   String? get error => _error;
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
//
//   // ── Balance lookup (per selected family) ──
//   bool _isLoadingBalance = false;
//   bool get isLoadingBalance => _isLoadingBalance;
//
//   FeeChallanModel? _latestChallan; // null if family never had a challan
//   FeeChallanModel? get latestChallan => _latestChallan;
//
//   double _currentBalance = 0;
//   double get currentBalance => _currentBalance;
//
//   /// Fetch just this ONE family's challans (single equality where on
//   /// familyDocId — auto-indexed, no composite index needed) and take
//   /// the most recent by generatedDate. That challan's remainingBalance
//   /// IS the family's current overall balance, since previousBalance is
//   /// already carried forward at generation time.
//   ///
//   /// If the family has no challan at all yet, balance is simply the
//   /// negative sum of any collections already recorded against it
//   /// (so a payment made before a challan exists still shows up as an
//   /// advance/negative balance, and folds into the ledger later).
//   Future<void> loadBalanceForFamily(String familyDocId) async {
//     _isLoadingBalance = true;
//     _latestChallan = null;
//     _currentBalance = 0;
//     notifyListeners();
//
//     try {
//       final challanSnap = await _db
//           .collection(_challansCollection)
//           .where('familyDocId', isEqualTo: familyDocId)
//           .get();
//
//       if (challanSnap.docs.isNotEmpty) {
//         final challans = challanSnap.docs
//             .map((d) => FeeChallanModel.fromFirestore(d))
//             .toList()
//           ..sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
//         _latestChallan = challans.first;
//         _currentBalance = _latestChallan!.remainingBalance;
//       } else {
//         // No challan yet — balance is purely whatever has already been
//         // collected (each payment recorded a balanceAfter snapshot; the
//         // most recent one is the running balance).
//         final collSnap = await _db
//             .collection(_collectionsCollection)
//             .where('familyDocId', isEqualTo: familyDocId)
//             .get();
//         if (collSnap.docs.isNotEmpty) {
//           final payments = collSnap.docs
//               .map((d) => FeeCollectionModel.fromFirestore(d))
//               .toList()
//             ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
//           _currentBalance = payments.first.balanceAfter;
//         } else {
//           _currentBalance = 0;
//         }
//       }
//     } catch (e) {
//       _error = 'Failed to load balance: $e';
//     } finally {
//       _isLoadingBalance = false;
//       notifyListeners();
//     }
//   }
//
//   void clearSelection() {
//     _latestChallan = null;
//     _currentBalance = 0;
//     notifyListeners();
//   }
//
//   // ── Save a payment ──
//   //
//   // Rule (per Umair): payment is applied to the family's LATEST
//   // challan's amountPaid (if one exists). balanceAfter = balanceBefore
//   // - amount, and can legitimately go negative (advance). If no challan
//   // exists yet, we just record the collection standalone; balanceAfter
//   // still = balanceBefore - amount (negative = advance), and the next
//   // challan generation already knows how to carry a family's running
//   // balance forward via previousBalance.
//   Future<bool> collectFee({
//     required FamilyForCollection family,
//     required double amount,
//     required DateTime paymentDate,
//     required String paymentMethod,
//     String? note,
//   }) async {
//     _isSaving = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final balanceBefore = _currentBalance;
//       final balanceAfter = balanceBefore - amount;
//
//       final receiptNumber = await _reserveReceiptNumber();
//
//       final batch = _db.batch();
//
//       // 1. Create the collection (receipt) document.
//       final collRef = _db.collection(_collectionsCollection).doc();
//       final collection = FeeCollectionModel(
//         id: collRef.id,
//         receiptNumber: receiptNumber,
//         familyDocId: family.familyDocId,
//         familyId: family.familyId,
//         familyName: family.familyName,
//         fatherName: family.fatherName,
//         fatherPhone: family.fatherPhone,
//         challanId: _latestChallan?.id,
//         challanNumber: _latestChallan?.challanNumber,
//         amount: amount,
//         balanceBefore: balanceBefore,
//         balanceAfter: balanceAfter,
//         paymentMethod: paymentMethod,
//         note: note,
//         paymentDate: paymentDate,
//       );
//       batch.set(collRef, collection.toMap());
//
//       // 2. If a challan exists, bump its amountPaid so its own
//       //    status/remainingBalance stays accurate.
//       if (_latestChallan?.id != null) {
//         final challanRef =
//         _db.collection(_challansCollection).doc(_latestChallan!.id);
//         final newAmountPaid = _latestChallan!.amountPaid + amount;
//         batch.update(challanRef, {'amountPaid': newAmountPaid});
//       }
//
//       await batch.commit();
//
//       _currentBalance = balanceAfter;
//       if (_latestChallan != null) {
//         _latestChallan!.amountPaid += amount;
//       }
//       return true;
//     } catch (e) {
//       _error = 'Failed to save payment: $e';
//       return false;
//     } finally {
//       _isSaving = false;
//       notifyListeners();
//     }
//   }
//
//   Future<String> _reserveReceiptNumber() async {
//     final ref = _db.doc(_counterDoc);
//     final next = await _db.runTransaction<int>((txn) async {
//       final snap = await txn.get(ref);
//       final current = (snap.data()?['value'] as num?)?.toInt() ?? 0;
//       final n = current + 1;
//       txn.set(ref, {'value': n}, SetOptions(merge: true));
//       return n;
//     });
//     return 'RCT-${next.toString().padLeft(4, '0')}';
//   }
//
//   // ── Build the searchable family list from admissions already
//   //    loaded in AdmissionProvider — no extra Firestore read. ──
//   static List<FamilyForCollection> buildFamilyList(
//       List<AdmissionModel> admissions) {
//     final regular =
//     admissions.where((a) => a.type == AdmissionType.regular).toList();
//
//     final Map<String, List<AdmissionModel>> grouped = {};
//     for (final a in regular) {
//       if (a.familyDocId.isEmpty) continue;
//       grouped.putIfAbsent(a.familyDocId, () => []).add(a);
//     }
//
//     final List<FamilyForCollection> result = [];
//     grouped.forEach((familyDocId, admissionsForFamily) {
//       final rep = admissionsForFamily.first;
//       final students =
//       admissionsForFamily.expand((a) => a.students).toList();
//       if (students.isEmpty) return;
//
//       String? firstPic;
//       for (final s in students) {
//         if (s.picBase64 != null && s.picBase64!.isNotEmpty) {
//           firstPic = s.picBase64;
//           break;
//         }
//       }
//
//       result.add(FamilyForCollection(
//         familyDocId: familyDocId,
//         familyId: rep.familyId,
//         familyName:
//         rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
//         fatherName: rep.fatherName,
//         fatherPhone: rep.fatherPhone,
//         firstStudentPicBase64: firstPic,
//         studentCount: students.length,
//       ));
//     });
//
//     result.sort((a, b) =>
//         a.familyName.toLowerCase().compareTo(b.familyName.toLowerCase()));
//     return result;
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/admission_model.dart';
import '../models/fee_collection_model.dart';

// ─────────────────────────────────────────────
//  Lightweight row used to populate the search list.
//  Built once from AdmissionProvider's already-loaded
//  `admissions` list (no extra Firestore read), so
//  search stays instant / no network round-trip per
//  keystroke.
// ─────────────────────────────────────────────
class FamilyForCollection {
  final String familyDocId;
  final String familyId;
  final String familyName;
  final String fatherName;
  final String fatherPhone;
  final String? firstStudentPicBase64;
  final int studentCount;

  FamilyForCollection({
    required this.familyDocId,
    required this.familyId,
    required this.familyName,
    required this.fatherName,
    required this.fatherPhone,
    required this.firstStudentPicBase64,
    required this.studentCount,
  });
}

// ─────────────────────────────────────────────
//  Fee Collection Provider
//
//  LEDGER MODEL (per Umair)
//  -------------------------
//  - fee_challans   = DEBIT entries  (student-wise detail, currentMonthTotal)
//  - fee_collections = CREDIT entries (just an amount)
//  - balance = sum(all challans.currentMonthTotal) - sum(all collections.amount)
//
//  This is always computed LIVE, never cached/stored anywhere. Both
//  reads are single-equality-where on familyDocId (auto-indexed, no
//  composite index needed) and, at the realistic scale of one
//  family's own history (a few dozen documents at most), this is
//  fast and — crucially — free of the drift/duplication bugs that a
//  cached running balance can accumulate.
// ─────────────────────────────────────────────
class FeeCollectionProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _challansCollection = 'fee_challans';
  static const String _collectionsCollection = 'fee_collections';
  static const String _counterDoc = 'counters/fee_collection_counter';

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Balance lookup (per selected family) ──
  bool _isLoadingBalance = false;
  bool get isLoadingBalance => _isLoadingBalance;

  double _currentBalance = 0;
  double get currentBalance => _currentBalance;

  /// Live balance = sum(challans.currentMonthTotal) - sum(collections.amount)
  /// for this family. Both queries are simple single-field equality
  /// filters on familyDocId, run in parallel.
  Future<void> loadBalanceForFamily(String familyDocId) async {
    _isLoadingBalance = true;
    _currentBalance = 0;
    notifyListeners();

    try {
      final results = await Future.wait([
        _db
            .collection(_challansCollection)
            .where('familyDocId', isEqualTo: familyDocId)
            .get(),
        _db
            .collection(_collectionsCollection)
            .where('familyDocId', isEqualTo: familyDocId)
            .get(),
      ]);

      final challanSnap = results[0];
      final collectionSnap = results[1];

      double totalDebit = 0;
      for (final doc in challanSnap.docs) {
        final data = doc.data();
        totalDebit += (data['currentMonthTotal'] as num?)?.toDouble() ?? 0;
      }

      double totalCredit = 0;
      for (final doc in collectionSnap.docs) {
        final data = doc.data();
        totalCredit += (data['amount'] as num?)?.toDouble() ?? 0;
      }

      _currentBalance = totalDebit - totalCredit;
    } catch (e) {
      _error = 'Failed to load balance: $e';
    } finally {
      _isLoadingBalance = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _currentBalance = 0;
    notifyListeners();
  }

  // ── Save a payment (pure credit entry) ──
  //
  // No challan document is touched at all. The payment is simply
  // recorded as its own credit entry; the next time anyone loads
  // this family's balance (here, or on the next challan-generation
  // screen), it's naturally reflected because the live sum includes
  // it.
  Future<bool> collectFee({
    required FamilyForCollection family,
    required double amount,
    required DateTime paymentDate,
    required String paymentMethod,
    String? note,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final receiptNumber = await _reserveReceiptNumber();

      final collRef = _db.collection(_collectionsCollection).doc();
      final collection = FeeCollectionModel(
        id: collRef.id,
        receiptNumber: receiptNumber,
        familyDocId: family.familyDocId,
        familyId: family.familyId,
        familyName: family.familyName,
        fatherName: family.fatherName,
        fatherPhone: family.fatherPhone,
        amount: amount,
        paymentMethod: paymentMethod,
        note: note,
        paymentDate: paymentDate,
      );

      await collRef.set(collection.toMap());

      _currentBalance -= amount;
      return true;
    } catch (e) {
      _error = 'Failed to save payment: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String> _reserveReceiptNumber() async {
    final ref = _db.doc(_counterDoc);
    final next = await _db.runTransaction<int>((txn) async {
      final snap = await txn.get(ref);
      final current = (snap.data()?['value'] as num?)?.toInt() ?? 0;
      final n = current + 1;
      txn.set(ref, {'value': n}, SetOptions(merge: true));
      return n;
    });
    return 'RCT-${next.toString().padLeft(4, '0')}';
  }

  // ── Build the searchable family list from admissions already
  //    loaded in AdmissionProvider — no extra Firestore read. ──
  static List<FamilyForCollection> buildFamilyList(
      List<AdmissionModel> admissions) {
    final regular =
    admissions.where((a) => a.type == AdmissionType.regular).toList();

    final Map<String, List<AdmissionModel>> grouped = {};
    for (final a in regular) {
      if (a.familyDocId.isEmpty) continue;
      grouped.putIfAbsent(a.familyDocId, () => []).add(a);
    }

    final List<FamilyForCollection> result = [];
    grouped.forEach((familyDocId, admissionsForFamily) {
      final rep = admissionsForFamily.first;
      final students =
      admissionsForFamily.expand((a) => a.students).toList();
      if (students.isEmpty) return;

      String? firstPic;
      for (final s in students) {
        if (s.picBase64 != null && s.picBase64!.isNotEmpty) {
          firstPic = s.picBase64;
          break;
        }
      }

      result.add(FamilyForCollection(
        familyDocId: familyDocId,
        familyId: rep.familyId,
        familyName:
        rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
        fatherName: rep.fatherName,
        fatherPhone: rep.fatherPhone,
        firstStudentPicBase64: firstPic,
        studentCount: students.length,
      ));
    });

    result.sort((a, b) =>
        a.familyName.toLowerCase().compareTo(b.familyName.toLowerCase()));
    return result;
  }
}