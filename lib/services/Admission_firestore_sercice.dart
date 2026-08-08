//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/admission_model.dart';
//
// class AdmissionFirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   CollectionReference get _admissionsCol =>
//       _db.collection('schools').doc('school1').collection('admissions');
//
//   CollectionReference get _countersCol =>
//       _db.collection('schools').doc('school1').collection('counters');
//
//   // ─────────────────────────────────────
//   //  Auto-generate Inquiry / Reg ID
//   // ─────────────────────────────────────
//   Future<String> generateAdmissionId(AdmissionType type) async {
//     final prefix = type == AdmissionType.preAdmission ? 'INQ' : 'REG';
//     final counterKey = type == AdmissionType.preAdmission
//         ? 'inquiry_counter'
//         : 'registration_counter';
//
//     return _db.runTransaction<String>((tx) async {
//       final docRef = _countersCol.doc(counterKey);
//       final snap = await tx.get(docRef);
//       int current = 0;
//       if (snap.exists) {
//         current = (snap.data() as Map<String, dynamic>)['count'] ?? 0;
//       }
//       final next = current + 1;
//       tx.set(docRef, {'count': next});
//       return '$prefix-${next.toString().padLeft(4, '0')}';
//     });
//   }
//
//   // ─────────────────────────────────────
//   //  Auto-generate Student ID
//   // ─────────────────────────────────────
//   Future<String> generateStudentId(String studentName) async {
//     final cleaned = studentName.trim().replaceAll(RegExp(r'\s+'), '');
//     final prefix = cleaned.length >= 2
//         ? cleaned.substring(0, 2).toUpperCase()
//         : cleaned.toUpperCase().padRight(2, 'X');
//
//     return _db.runTransaction<String>((tx) async {
//       final counterKey = 'student_${prefix.toLowerCase()}';
//       final docRef = _countersCol.doc(counterKey);
//       final snap = await tx.get(docRef);
//       int current = 0;
//       if (snap.exists) {
//         current = (snap.data() as Map<String, dynamic>)['count'] ?? 0;
//       }
//       final next = current + 1;
//       tx.set(docRef, {'count': next});
//       return '$prefix${next.toString().padLeft(4, '0')}';
//     });
//   }
//
//   // ─────────────────────────────────────
//   //  CRUD
//   // ─────────────────────────────────────
//   Future<String> addAdmission(AdmissionModel admission) async {
//     final docRef = await _admissionsCol.add(admission.toMap());
//     return docRef.id;
//   }
//
//   Future<void> updateAdmission(AdmissionModel admission) async {
//     final data = admission.toMap()..remove('createdAt');
//     data['updatedAt'] = FieldValue.serverTimestamp();
//     await _admissionsCol.doc(admission.id!).update(data);
//   }
//
//   Future<void> deleteAdmission(String id) async {
//     await _admissionsCol.doc(id).delete();
//   }
//
//   Stream<List<AdmissionModel>> getAdmissionsStream(
//       {AdmissionType? filterType}) {
//     Query query = _admissionsCol;
//
//     if (filterType != null) {
//       query = query.where('type', isEqualTo: filterType.value);
//     }
//
//     return query
//         .snapshots()
//         .map((snap) =>
//         snap.docs.map((doc) => AdmissionModel.fromFirestore(doc)).toList());
//   }
//
//   Future<AdmissionModel?> getAdmissionById(String id) async {
//     final doc = await _admissionsCol.doc(id).get();
//     if (!doc.exists) return null;
//     return AdmissionModel.fromFirestore(doc);
//   }
//
//   Future<Map<String, double?>> getClassFees(String classId) async {
//     try {
//       final doc = await _db
//           .collection('schools')
//           .doc('school1')
//           .collection('classes')
//           .doc(classId)
//           .get();
//       if (!doc.exists) return {};
//       final data = doc.data() as Map<String, dynamic>;
//       return {
//         'annualFee': data['annualFee']?.toDouble(),
//         'registrationFee': data['registrationFee']?.toDouble(),
//         'monthlyFee': data['monthlyFee']?.toDouble(),
//       };
//     } catch (_) {
//       return {};
//     }
//   }
//
//   Future<Map<String, double?>> getSectionFees(
//       String classId, String sectionName) async {
//     try {
//       final doc = await _db
//           .collection('schools')
//           .doc('school1')
//           .collection('classes')
//           .doc(classId)
//           .get();
//       if (!doc.exists) return {};
//       final data = doc.data() as Map<String, dynamic>;
//       final sections = (data['sections'] as List<dynamic>?) ?? [];
//       final section = sections.firstWhere(
//             (s) => (s as Map<String, dynamic>)['sectionName'] == sectionName,
//         orElse: () => null,
//       );
//       if (section == null) return getClassFees(classId);
//       final s = section as Map<String, dynamic>;
//       return {
//         'annualFee':
//         s['annualFee']?.toDouble() ?? data['annualFee']?.toDouble(),
//         'registrationFee': s['registrationFee']?.toDouble() ??
//             data['registrationFee']?.toDouble(),
//         'monthlyFee':
//         s['monthlyFee']?.toDouble() ?? data['monthlyFee']?.toDouble(),
//       };
//     } catch (_) {
//       return {};
//     }
//   }
//
//   // ─────────────────────────────────────
//   //  ACADEMY METHODS
//   // ─────────────────────────────────────
//   Future<List<Academy>> getAcademies() async {
//     final snap = await _db
//         .collection('schools')
//         .doc('school1')
//         .collection('academies')
//         .get();
//     return snap.docs.map((doc) => Academy.fromFirestore(doc)).toList();
//   }
//
//   Future<Map<String, double?>> getAcademyFees(String academyId) async {
//     try {
//       final doc = await _db
//           .collection('schools')
//           .doc('school1')
//           .collection('academies')
//           .doc(academyId)
//           .get();
//       if (!doc.exists) return {};
//       final data = doc.data() as Map<String, dynamic>;
//       return {
//         'annualFee': data['annualFee']?.toDouble(),
//         'registrationFee': data['registrationFee']?.toDouble(),
//         'monthlyFee': data['monthlyFee']?.toDouble(),
//       };
//     } catch (_) {
//       return {};
//     }
//   }
// }


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
  Future<String> addAdmission(AdmissionModel admission) async {
    final docRef = await _admissionsCol.add(admission.toMap());
    return docRef.id;
  }

  Future<void> updateAdmission(AdmissionModel admission) async {
    final data = admission.toMap()..remove('createdAt');
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _admissionsCol.doc(admission.id!).update(data);
  }

  Future<void> deleteAdmission(String id) async {
    await _admissionsCol.doc(id).delete();
  }

  Stream<List<AdmissionModel>> getAdmissionsStream(
      {AdmissionType? filterType}) {
    Query query = _admissionsCol;

    if (filterType != null) {
      query = query.where('type', isEqualTo: filterType.value);
    }

    return query
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => AdmissionModel.fromFirestore(doc)).toList());
  }

  Future<AdmissionModel?> getAdmissionById(String id) async {
    final doc = await _admissionsCol.doc(id).get();
    if (!doc.exists) return null;
    return AdmissionModel.fromFirestore(doc);
  }

  // ─────────────────────────────────────
  //  STUDENT STATUS (deactivate / rejoin)
  //  A student lives inside an admission's `students` array, so we
  //  can't patch a single array element directly in Firestore — we
  //  fetch the whole admission, replace the matching student in the
  //  in-memory list, then write the full `students` array back.
  // ─────────────────────────────────────
  Future<void> updateStudentInAdmission({
    required String admissionId,
    required String studentId,
    required AdmissionStudent Function(AdmissionStudent current) updater,
  }) async {
    final docRef = _admissionsCol.doc(admissionId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception('Admission not found');
      }
      final admission = AdmissionModel.fromFirestore(snap);

      final idx =
      admission.students.indexWhere((s) => s.studentId == studentId);
      if (idx == -1) {
        throw Exception('Student not found in this admission');
      }

      final updatedStudent = updater(admission.students[idx]);
      admission.students[idx] = updatedStudent;

      tx.update(docRef, {
        'students': admission.students.map((s) => s.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Marks a student as deactivated (Left School / Terminated) and
  /// appends an event to their status history.
  Future<void> deactivateStudent({
    required String admissionId,
    required String studentId,
    required String reason, // 'left_school' | 'terminated'
    required String date, // ISO date string
    String? note,
  }) {
    return updateStudentInAdmission(
      admissionId: admissionId,
      studentId: studentId,
      updater: (current) {
        final history = List<StudentStatusEvent>.from(current.statusHistory);
        history.add(StudentStatusEvent(
          type: 'deactivated',
          date: date,
          reason: reason,
          note: note,
        ));
        return current.copyWith(
          isActive: false,
          deactivationDate: date,
          deactivationReason: reason,
          deactivationNote: note,
          statusHistory: history,
        );
      },
    );
  }

  /// Restores a deactivated student back to active, optionally updating
  /// their class/section/fees at the same time (rejoin with changes).
  Future<void> rejoinStudent({
    required String admissionId,
    required String studentId,
    required String rejoiningDate,
    String? note,
    String? classId,
    String? className,
    String? sectionId,
    String? sectionName,
    double? annualFee,
    double? registrationFee,
    double? monthlyFee,
    bool? hasAcademy,
    String? academyId,
    String? academyName,
    double? academyFee,
  }) {
    return updateStudentInAdmission(
      admissionId: admissionId,
      studentId: studentId,
      updater: (current) {
        final history = List<StudentStatusEvent>.from(current.statusHistory);
        history.add(StudentStatusEvent(
          type: 'rejoined',
          date: rejoiningDate,
          note: note,
        ));
        return current.copyWith(
          isActive: true,
          deactivationDate: null,
          deactivationReason: null,
          deactivationNote: null,
          statusHistory: history,
          classId: classId ?? current.classId,
          className: className ?? current.className,
          sectionId: sectionId ?? current.sectionId,
          sectionName: sectionName ?? current.sectionName,
          annualFee: annualFee ?? current.annualFee,
          registrationFee: registrationFee ?? current.registrationFee,
          monthlyFee: monthlyFee ?? current.monthlyFee,
          hasAcademy: hasAcademy ?? current.hasAcademy,
          academyId: academyId ?? current.academyId,
          academyName: academyName ?? current.academyName,
          academyFee: academyFee ?? current.academyFee,
        );
      },
    );
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
        'annualFee':
        s['annualFee']?.toDouble() ?? data['annualFee']?.toDouble(),
        'registrationFee': s['registrationFee']?.toDouble() ??
            data['registrationFee']?.toDouble(),
        'monthlyFee':
        s['monthlyFee']?.toDouble() ?? data['monthlyFee']?.toDouble(),
      };
    } catch (_) {
      return {};
    }
  }

  // ─────────────────────────────────────
  //  ACADEMY METHODS
  // ─────────────────────────────────────
  Future<List<Academy>> getAcademies() async {
    final snap = await _db
        .collection('schools')
        .doc('school1')
        .collection('academies')
        .get();
    return snap.docs.map((doc) => Academy.fromFirestore(doc)).toList();
  }

  Future<Map<String, double?>> getAcademyFees(String academyId) async {
    try {
      final doc = await _db
          .collection('schools')
          .doc('school1')
          .collection('academies')
          .doc(academyId)
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
}