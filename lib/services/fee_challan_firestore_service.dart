import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fee_challan_model.dart';

class FeeChallanFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _challansCol =>
      _db.collection('schools').doc('school1').collection('fee_challans');

  CollectionReference get _countersCol =>
      _db.collection('schools').doc('school1').collection('counters');

  // ─────────────────────────────────────
  //  Auto-generate Challan Number (CH-0001 style)
  // ─────────────────────────────────────
  Future<String> generateChallanNumber() {
    return _db.runTransaction<String>((tx) async {
      final docRef = _countersCol.doc('challan_counter');
      final snap = await tx.get(docRef);
      int current = 0;
      if (snap.exists) {
        current = (snap.data() as Map<String, dynamic>)['count'] ?? 0;
      }
      final next = current + 1;
      tx.set(docRef, {'count': next});
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
  //  Family's running previous balance = sum of remainingBalance
  //  across every existing challan for that family. Single equality
  //  filter, sorted client-side — avoids composite index issues.
  // ─────────────────────────────────────
  Future<double> getFamilyPreviousBalance(String familyDocId) async {
    if (familyDocId.isEmpty) return 0;
    final snap =
    await _challansCol.where('familyDocId', isEqualTo: familyDocId).get();
    double total = 0;
    for (final doc in snap.docs) {
      final c = FeeChallanModel.fromFirestore(doc);
      total += c.remainingBalance;
    }
    return total;
  }

  // ─────────────────────────────────────
  //  Has this family already got a challan for this billing month?
  //  Multiple equality filters only — no composite index needed.
  // ─────────────────────────────────────
  Future<bool> familyAlreadyChallanedForMonth(
      String familyDocId, int month, int year) async {
    if (familyDocId.isEmpty) return false;
    final snap = await _challansCol
        .where('familyDocId', isEqualTo: familyDocId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  // Bulk version — ONE read instead of N, used to paint "Already
  // Generated" badges on the family list for the selected month.
  Future<Set<String>> familiesAlreadyChallanedForMonth(int month, int year) async {
    final snap = await _challansCol
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();
    return snap.docs
        .map((d) => (d.data() as Map<String, dynamic>)['familyDocId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  // ─────────────────────────────────────
  //  CRUD
  // ─────────────────────────────────────
  Future<String> addChallan(FeeChallanModel challan) async {
    final docRef = await _challansCol.add(challan.toMap());
    return docRef.id;
  }

  // Kept for the future payment/collection screen — updates amountPaid etc.
  Future<void> updateChallan(FeeChallanModel challan) async {
    if (challan.id == null) return;
    final data = challan.toMap()..remove('createdAt');
    await _challansCol.doc(challan.id).update(data);
  }

  // Ready for a future "All Challans" list screen.
  Stream<List<FeeChallanModel>> getChallansStream({int? month, int? year}) {
    Query query = _challansCol;
    if (month != null) query = query.where('month', isEqualTo: month);
    if (year != null) query = query.where('year', isEqualTo: year);

    return query.snapshots().map((snap) {
      final list =
      snap.docs.map((doc) => FeeChallanModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
      return list;
    });
  }
}