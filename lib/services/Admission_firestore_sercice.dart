
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admission_model.dart';

class AdmissionFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _admissionsCol =>
      _db.collection('schools').doc('school1').collection('admissions');

  CollectionReference get _countersCol =>
      _db.collection('schools').doc('school1').collection('counters');

  // ─────────────────────────────────────
  //  Auto-generate Inquiry / Reg ID
  // ─────────────────────────────────────
  Future<String> generateAdmissionId(AdmissionType type) async {
    final prefix = type == AdmissionType.preAdmission ? 'INQ' : 'REG';
    final counterKey = type == AdmissionType.preAdmission
        ? 'inquiry_counter'
        : 'registration_counter';

    return _db.runTransaction<String>((tx) async {
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
  //  Auto-generate Family ID
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
  //  Auto-generate Student ID
  // ─────────────────────────────────────
  Future<String> generateStudentId(String studentName) async {
    final cleaned = studentName.trim().replaceAll(RegExp(r'\s+'), '');
    final prefix = cleaned.length >= 2
        ? cleaned.substring(0, 2).toUpperCase()
        : cleaned.toUpperCase().padRight(2, 'X');

    return _db.runTransaction<String>((tx) async {
      final counterKey = 'student_${prefix.toLowerCase()}';
      final docRef = _countersCol.doc(counterKey);
      final snap = await tx.get(docRef);
      int current = 0;
      if (snap.exists) {
        current = (snap.data() as Map<String, dynamic>)['count'] ?? 0;
      }
      final next = current + 1;
      tx.set(docRef, {'count': next});
      return '$prefix${next.toString().padLeft(4, '0')}';
    });
  }

  // ─────────────────────────────────────
  //  CRUD
  // ─────────────────────────────────────
  Future<void> addAdmission(AdmissionModel admission) async {
    await _admissionsCol.add(admission.toMap());
  }

  Future<void> updateAdmission(AdmissionModel admission) async {
    final data = admission.toMap()..remove('createdAt');
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _admissionsCol.doc(admission.id!).update(data);
  }

  Future<void> deleteAdmission(String id) async {
    await _admissionsCol.doc(id).delete();
  }

  // ✅ FIX: orderBy hata diya — provider mein client-side sort ho raha hai
  // where + orderBy on different fields = composite index required (error)
  // Solution: Firestore se sirf data lo, sorting Dart mein karo
  Stream<List<AdmissionModel>> getAdmissionsStream({AdmissionType? filterType}) {
    Query query = _admissionsCol; // ← no orderBy here

    if (filterType != null) {
      query = query.where('type', isEqualTo: filterType.value);
    }

    return query.snapshots().map(
          (snap) => snap.docs
          .map((doc) => AdmissionModel.fromFirestore(doc))
          .toList(),
    );
  }

  Future<AdmissionModel?> getAdmissionById(String id) async {
    final doc = await _admissionsCol.doc(id).get();
    if (!doc.exists) return null;
    return AdmissionModel.fromFirestore(doc);
  }

  Future<bool> familyIdExists(String familyId) async {
    final snap = await _admissionsCol
        .where('familyId', isEqualTo: familyId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<Map<String, double?>> getClassFees(String classId) async {
    try {
      final doc = await _db
          .collection('schools')
          .doc('school1')
          .collection('classes')
          .doc(classId)
          .get();
      if (!doc.exists) return {};
      final data = doc.data() as Map<String, dynamic>;
      return {
        'annualFee': data['annualFee']?.toDouble(),
        'registrationFee': data['registrationFee']?.toDouble(),
        'monthlyFee': data['monthlyFee']?.toDouble(),
      };
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, double?>> getSectionFees(
      String classId, String sectionName) async {
    try {
      final doc = await _db
          .collection('schools')
          .doc('school1')
          .collection('classes')
          .doc(classId)
          .get();
      if (!doc.exists) return {};
      final data = doc.data() as Map<String, dynamic>;
      final sections = (data['sections'] as List<dynamic>?) ?? [];
      final section = sections.firstWhere(
            (s) => (s as Map<String, dynamic>)['sectionName'] == sectionName,
        orElse: () => null,
      );
      if (section == null) return getClassFees(classId);
      final s = section as Map<String, dynamic>;
      return {
        'annualFee': s['annualFee']?.toDouble() ?? data['annualFee']?.toDouble(),
        'registrationFee':
        s['registrationFee']?.toDouble() ?? data['registrationFee']?.toDouble(),
        'monthlyFee':
        s['monthlyFee']?.toDouble() ?? data['monthlyFee']?.toDouble(),
      };
    } catch (_) {
      return {};
    }
  }
}