import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admission_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Counter Helper ───────────────────────────────────────────────────────
  Future<String> _getNextNumber(String counterName) async {
    final counterRef = _firestore.collection('counters').doc(counterName);
    return _firestore.runTransaction<String>((transaction) async {
      final snapshot = await transaction.get(counterRef);
      int nextNumber = 1;
      if (snapshot.exists) {
        nextNumber = (snapshot.data()?['value'] ?? 0) + 1;
      }
      transaction.set(
        counterRef,
        {'value': nextNumber},
        SetOptions(merge: true),
      );
      return nextNumber.toString().padLeft(5, '0');
    });
  }

  // ─── Admission ────────────────────────────────────────────────────────────
  Future<void> addAdmission(AdmissionModel admission) async {
    final admNo = await _getNextNumber('admission_counter');
    admission.admissionNo = admNo;

    if (admission.type == 'family') {
      final famNo = await _getNextNumber('family_counter');
      admission.familyId = 'FAM-$famNo';
    }

    for (var child in admission.children) {
      final stuNo = await _getNextNumber('student_counter');
      child.studentId = 'STU-$stuNo';
    }

    await _firestore.collection('admissions').add(admission.toMap());
  }

  Stream<List<AdmissionModel>> getAdmissions() {
    return _firestore
        .collection('admissions')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AdmissionModel.fromMap(doc.data(), id: doc.id))
        .toList());
  }

  Future<void> deleteAdmission(String id) {
    return _firestore.collection('admissions').doc(id).delete();
  }
}