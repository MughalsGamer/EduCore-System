//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/fee_challan_model.dart';
//
// class FeeChallanFirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   CollectionReference get _challansCol =>
//       _db.collection('schools').doc('school1').collection('fee_challans');
//
//   CollectionReference get _countersCol =>
//       _db.collection('schools').doc('school1').collection('counters');
//
//   // ─────────────────────────────────────
//   //  Auto-generate Challan Number (CH-0001 style)
//   // ─────────────────────────────────────
//   Future<String> generateChallanNumber() {
//     return _db.runTransaction<String>((tx) async {
//       final docRef = _countersCol.doc('challan_counter');
//       final snap = await tx.get(docRef);
//       int current = 0;
//       if (snap.exists) {
//         current = (snap.data() as Map<String, dynamic>)['count'] ?? 0;
//       }
//       final next = current + 1;
//       tx.set(docRef, {'count': next});
//       return 'CH-${next.toString().padLeft(4, '0')}';
//     });
//   }
//
//   // ─────────────────────────────────────
//   //  Has this student EVER had a challan before?
//   //  Drives whether Admission + Annual fee get added this time.
//   //  Single-field array-contains query — no composite index needed.
//   // ─────────────────────────────────────
//   Future<bool> studentHasPriorChallan(String studentId) async {
//     if (studentId.isEmpty) return false;
//     final snap = await _challansCol
//         .where('studentIds', arrayContains: studentId)
//         .limit(1)
//         .get();
//     return snap.docs.isNotEmpty;
//   }
//
//   // ─────────────────────────────────────
//   //  Family's running previous balance = sum of remainingBalance
//   //  across every existing challan for that family. Single equality
//   //  filter, sorted client-side — avoids composite index issues.
//   // ─────────────────────────────────────
//   Future<double> getFamilyPreviousBalance(String familyDocId) async {
//     if (familyDocId.isEmpty) return 0;
//     final snap =
//     await _challansCol.where('familyDocId', isEqualTo: familyDocId).get();
//     double total = 0;
//     for (final doc in snap.docs) {
//       final c = FeeChallanModel.fromFirestore(doc);
//       total += c.remainingBalance;
//     }
//     return total;
//   }
//
//   // ─────────────────────────────────────
//   //  Which studentIds (within this family) ALREADY have a challan
//   //  for this exact billing month+year?
//   //  Multiple equality filters only — no composite index needed.
//   //  Used to build the "remaining students" list for a family so a
//   //  newly-admitted student (who wasn't part of the earlier challan)
//   //  can still get their own challan this month.
//   // ─────────────────────────────────────
//   Future<Set<String>> studentIdsAlreadyChallanedForFamilyMonth(
//       String familyDocId, int month, int year) async {
//     if (familyDocId.isEmpty) return {};
//     final snap = await _challansCol
//         .where('familyDocId', isEqualTo: familyDocId)
//         .where('month', isEqualTo: month)
//         .where('year', isEqualTo: year)
//         .get();
//
//     final Set<String> ids = {};
//     for (final doc in snap.docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       final studentIds = (data['studentIds'] as List<dynamic>?) ?? [];
//       ids.addAll(studentIds.map((e) => e.toString()));
//     }
//     return ids;
//   }
//
//   // Bulk version — ONE read instead of N. Returns, per family, the set
//   // of studentIds already challaned for the given month+year. Used to
//   // paint "Already Generated" / "Partial" badges on the family list.
//   Future<Map<String, Set<String>>> familyStudentIdsChallanedForMonth(
//       int month, int year) async {
//     final snap = await _challansCol
//         .where('month', isEqualTo: month)
//         .where('year', isEqualTo: year)
//         .get();
//
//     final Map<String, Set<String>> result = {};
//     for (final doc in snap.docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       final familyDocId = data['familyDocId'] as String? ?? '';
//       if (familyDocId.isEmpty) continue;
//       final studentIds = (data['studentIds'] as List<dynamic>?) ?? [];
//       result
//           .putIfAbsent(familyDocId, () => {})
//           .addAll(studentIds.map((e) => e.toString()));
//     }
//     return result;
//   }
//
//   // ─────────────────────────────────────
//   //  CRUD
//   // ─────────────────────────────────────
//   Future<String> addChallan(FeeChallanModel challan) async {
//     final docRef = await _challansCol.add(challan.toMap());
//     return docRef.id;
//   }
//
//   // Kept for the future payment/collection screen — updates amountPaid etc.
//   Future<void> updateChallan(FeeChallanModel challan) async {
//     if (challan.id == null) return;
//     final data = challan.toMap()..remove('createdAt');
//     await _challansCol.doc(challan.id).update(data);
//   }
//
//   // Delete a single challan by its Firestore doc id.
//   Future<void> deleteChallan(String challanId) async {
//     if (challanId.isEmpty) return;
//     await _challansCol.doc(challanId).delete();
//   }
//
//   // Ready for the "All Challans" list screen.
//   Stream<List<FeeChallanModel>> getChallansStream({int? month, int? year}) {
//     Query query = _challansCol;
//     if (month != null) query = query.where('month', isEqualTo: month);
//     if (year != null) query = query.where('year', isEqualTo: year);
//
//     return query.snapshots().map((snap) {
//       final list =
//       snap.docs.map((doc) => FeeChallanModel.fromFirestore(doc)).toList();
//       list.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
//       return list;
//     });
//   }
//
//   // One-time fetch version (used by the list screen alongside the stream
//   // if a manual refresh / pull-to-refresh is preferred over live stream).
//   Future<List<FeeChallanModel>> getChallansOnce({int? month, int? year}) async {
//     Query query = _challansCol;
//     if (month != null) query = query.where('month', isEqualTo: month);
//     if (year != null) query = query.where('year', isEqualTo: year);
//
//     final snap = await query.get();
//     final list =
//     snap.docs.map((doc) => FeeChallanModel.fromFirestore(doc)).toList();
//     list.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
//     return list;
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fee_challan_model.dart';

// ─────────────────────────────────────────────
//  Fee Challan Firestore Service
//
//  NOTE: FeeChallanProvider currently talks to Firestore directly
//  (batched generation + its own counter transaction) and does NOT
//  call this service. This file is kept as a standalone, reusable
//  data-access layer in case a screen/provider other than the
//  generation flow needs simple single-challan CRUD or streaming
//  without re-implementing the batch-generation logic.
//
//  LEDGER MODEL (per Umair)
//  -------------------------
//  A challan is a PURE DEBIT entry — student-wise detail plus
//  currentMonthTotal only. It carries no amountPaid, status, or
//  remainingBalance/previousBalance. Any running family balance is
//  computed live (sum of all challans' currentMonthTotal minus sum
//  of all fee_collections' amount) — see FeeCollectionProvider.
//  Nothing here reads/writes those removed fields anymore.
//
//  COLLECTION PATH
//  ----------------
//  Kept consistent with FeeChallanProvider: top-level 'fee_challans'
//  collection (not the old 'schools/school1/fee_challans' nested
//  path), so both stay in sync against the same data.
// ─────────────────────────────────────────────
class FeeChallanFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _collection = 'fee_challans';
  static const String _counterDoc = 'counters/fee_challan_counter';

  CollectionReference<Map<String, dynamic>> get _challansCol =>
      _db.collection(_collection);

  // ─────────────────────────────────────
  //  Auto-generate Challan Number (CH-0001 style)
  // ─────────────────────────────────────
  Future<String> generateChallanNumber() {
    return _db.runTransaction<String>((tx) async {
      final docRef = _db.doc(_counterDoc);
      final snap = await tx.get(docRef);
      final current = (snap.data()?['value'] as num?)?.toInt() ?? 0;
      final next = current + 1;
      tx.set(docRef, {'value': next}, SetOptions(merge: true));
      return 'CH-${next.toString().padLeft(4, '0')}';
    });
  }

  // ─────────────────────────────────────
  //  Has this student EVER had a challan before?
  //  Drives whether Admission + Annual fee get added this time.
  //  Single-field array-contains query — no composite index needed.
  // ─────────────────────────────────────
  Future<bool> studentHasPriorChallan(String studentId) async {
    if (studentId.isEmpty) return false;
    final snap = await _challansCol
        .where('studentIds', arrayContains: studentId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  // ─────────────────────────────────────
  //  Which studentIds (within this family) ALREADY have a challan
  //  for this exact billing month+year?
  //  Multiple equality filters only — no composite index needed.
  //  Used to build the "remaining students" list for a family so a
  //  newly-admitted student (who wasn't part of the earlier challan)
  //  can still get their own challan this month.
  // ─────────────────────────────────────
  Future<Set<String>> studentIdsAlreadyChallanedForFamilyMonth(
      String familyDocId, int month, int year) async {
    if (familyDocId.isEmpty) return {};
    final snap = await _challansCol
        .where('familyDocId', isEqualTo: familyDocId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();

    final Set<String> ids = {};
    for (final doc in snap.docs) {
      final data = doc.data();
      final studentIds = (data['studentIds'] as List<dynamic>?) ?? [];
      ids.addAll(studentIds.map((e) => e.toString()));
    }
    return ids;
  }

  // Bulk version — ONE read instead of N. Returns, per family, the set
  // of studentIds already challaned for the given month+year. Used to
  // paint "Already Generated" / "Partial" badges on the family list.
  Future<Map<String, Set<String>>> familyStudentIdsChallanedForMonth(
      int month, int year) async {
    final snap = await _challansCol
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();

    final Map<String, Set<String>> result = {};
    for (final doc in snap.docs) {
      final data = doc.data();
      final familyDocId = data['familyDocId'] as String? ?? '';
      if (familyDocId.isEmpty) continue;
      final studentIds = (data['studentIds'] as List<dynamic>?) ?? [];
      result
          .putIfAbsent(familyDocId, () => {})
          .addAll(studentIds.map((e) => e.toString()));
    }
    return result;
  }

  // ─────────────────────────────────────
  //  Family's live balance = sum(all challans.currentMonthTotal)
  //  for this family MINUS sum(all fee_collections.amount).
  //  This service only knows the debit side (challans); pass in the
  //  credit total (from FeeCollectionFirestoreService /
  //  FeeCollectionProvider) to get the real balance. Kept here as a
  //  convenience so callers that only have a familyDocId can get the
  //  debit sum without pulling in the collection provider.
  // ─────────────────────────────────────
  Future<double> getFamilyDebitTotal(String familyDocId) async {
    if (familyDocId.isEmpty) return 0;
    final snap =
    await _challansCol.where('familyDocId', isEqualTo: familyDocId).get();
    double total = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      total += (data['currentMonthTotal'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  // ─────────────────────────────────────
  //  CRUD
  // ─────────────────────────────────────
  Future<String> addChallan(FeeChallanModel challan) async {
    final docRef = await _challansCol.add(challan.toMap());
    return docRef.id;
  }

  // Delete a single challan by its Firestore doc id.
  Future<void> deleteChallan(String challanId) async {
    if (challanId.isEmpty) return;
    await _challansCol.doc(challanId).delete();
  }

  // Live stream for the "All Challans" list screen.
  Stream<List<FeeChallanModel>> getChallansStream({int? month, int? year}) {
    Query<Map<String, dynamic>> query = _challansCol;
    if (month != null) query = query.where('month', isEqualTo: month);
    if (year != null) query = query.where('year', isEqualTo: year);

    return query.snapshots().map((snap) {
      final list =
      snap.docs.map((doc) => FeeChallanModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
      return list;
    });
  }

  // One-time fetch version (used alongside the stream if a manual
  // refresh / pull-to-refresh is preferred over a live stream).
  Future<List<FeeChallanModel>> getChallansOnce({int? month, int? year}) async {
    Query<Map<String, dynamic>> query = _challansCol;
    if (month != null) query = query.where('month', isEqualTo: month);
    if (year != null) query = query.where('year', isEqualTo: year);

    final snap = await query.get();
    final list =
    snap.docs.map((doc) => FeeChallanModel.fromFirestore(doc)).toList();
    list.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
    return list;
  }
}