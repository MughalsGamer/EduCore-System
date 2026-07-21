import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_model.dart';
import '../models/admission_model.dart';

class FamilyFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _familiesCol =>
      _db.collection('schools').doc('school1').collection('families');
  // ✅ Add this line
  CollectionReference get familiesCollection => _familiesCol;

  CollectionReference get _countersCol =>
      _db.collection('schools').doc('school1').collection('counters');
  // In family_firestore_service.dart
  Future<List<FamilyModel>> fetchAllFamilies() async {
    final snapshot = await familiesCollection
        .orderBy('familyName')
        .get();
    return snapshot.docs.map((doc) => FamilyModel.fromFirestore(doc)).toList();
  }

  // ─────────────────────────────────────
  //  Auto-generate Family ID (KHA-0001 style)
  //  Same scheme as before, kept in this service now.
  // ─────────────────────────────────────
  Future<String> generateFamilyId(String familyName) async {
    final cleaned = familyName.trim().replaceAll(RegExp(r'\s+'), '');
    final prefix = cleaned.length >= 3
        ? cleaned.substring(0, 3).toUpperCase()
        : cleaned.toUpperCase().padRight(3, 'X');

    return _db.runTransaction<String>((tx) async {
      final counterKey = 'family_${prefix.toLowerCase()}';
      final docRef = _countersCol.doc(counterKey);
      final snap = await tx.get(docRef);
      int current = 0;
      if (snap.exists) {
        current = (snap.data() as Map<String, dynamic>)['count'] ?? 0;
      }
      final next = current + 1;
      tx.set(docRef, {'count': next});
      return '$prefix-${next.toString().padLeft(4, '0')}';
    });
  }

  // ─────────────────────────────────────
  //  Create a brand-new family document.
  //  Returns the Firestore auto doc-ID.
  // ─────────────────────────────────────
  Future<String> createFamily(FamilyModel family) async {
    final docRef = await _familiesCol.add(family.toMap());
    return docRef.id;
  }

  Future<void> updateFamily(FamilyModel family) async {
    if (family.docId == null) return;
    await _familiesCol.doc(family.docId).update(family.toMap());
  }

  Future<FamilyModel?> getFamilyByDocId(String docId) async {
    final doc = await _familiesCol.doc(docId).get();
    if (!doc.exists) return null;
    return FamilyModel.fromFirestore(doc);
  }

  // ─────────────────────────────────────
  //  Search families by name (prefix search) — used by "Existing Family" UI
  // ─────────────────────────────────────
  Future<List<FamilyModel>> searchFamiliesByName(String query) async {
    if (query.trim().isEmpty) return [];
    final snap = await _familiesCol
        .where('familyName', isGreaterThanOrEqualTo: query.trim())
        .where('familyName', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .limit(20)
        .get();

    return snap.docs.map((doc) => FamilyModel.fromFirestore(doc)).toList();
  }

  // ─────────────────────────────────────
  //  Add/refresh a student reference inside a family's students[] array.
  //  Called every time an admission (pre or regular) is saved.
  //  If the studentId already exists in the array, it's replaced (update),
  //  otherwise appended.
  // ─────────────────────────────────────
  Future<void> upsertStudentRef({
    required String familyDocId,
    required FamilyStudentRef ref,
  }) async {
    final docRef = _familiesCol.doc(familyDocId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final list = (data['students'] as List<dynamic>?) ?? [];

      final students = list
          .map((s) => FamilyStudentRef.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList();

      final idx = students.indexWhere((s) => s.studentId == ref.studentId);
      if (idx >= 0) {
        students[idx] = ref;
      } else {
        students.add(ref);
      }

      tx.update(docRef, {
        'students': students.map((s) => s.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ─────────────────────────────────────
  //  Update a student ref's type + admissionId (used on convertToRegular)
  // ─────────────────────────────────────
  Future<void> updateStudentRefType({
    required String familyDocId,
    required String studentId,
    required String newAdmissionId,
    required String newInquiryOrRegId,
    required AdmissionType newType,
  }) async {
    final docRef = _familiesCol.doc(familyDocId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final list = (data['students'] as List<dynamic>?) ?? [];

      final students = list
          .map((s) => FamilyStudentRef.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList();

      final idx = students.indexWhere((s) => s.studentId == studentId);
      if (idx >= 0) {
        students[idx] = FamilyStudentRef(
          studentId: studentId,
          name: students[idx].name,
          admissionId: newAdmissionId,
          inquiryOrRegId: newInquiryOrRegId,
          type: newType,
        );
      }

      tx.update(docRef, {
        'students': students.map((s) => s.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> removeStudentRef({
    required String familyDocId,
    required String studentId,
  }) async {
    final docRef = _familiesCol.doc(familyDocId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final list = (data['students'] as List<dynamic>?) ?? [];

      final students = list
          .map((s) => FamilyStudentRef.fromMap(Map<String, dynamic>.from(s as Map)))
          .where((s) => s.studentId != studentId)
          .toList();

      tx.update(docRef, {
        'students': students.map((s) => s.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}