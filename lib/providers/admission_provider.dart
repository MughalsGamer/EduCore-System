// import 'dart:async';
//
// import 'package:flutter/material.dart';
//
// import '../models/admission_model.dart';
// import '../models/family_model.dart';
// import '../services/Admission_firestore_sercice.dart';
// import '../services/family_firestore_service.dart';
//
// class AdmissionProvider extends ChangeNotifier {
//   final AdmissionFirestoreService _service = AdmissionFirestoreService();
//   final FamilyFirestoreService _familyService = FamilyFirestoreService();
//
//   List<AdmissionModel> _admissions = [];
//   bool _isLoading = false;
//   String? _error;
//   AdmissionType? _activeFilter;
//
//   StreamSubscription<List<AdmissionModel>>? _subscription;
//
//   List<AdmissionModel> get admissions => _admissions;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   AdmissionType? get activeFilter => _activeFilter;
//
//   AdmissionProvider() {
//     _listen();
//   }
//
//   void _listen() {
//     _subscription?.cancel();
//     _subscription = null;
//
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     _subscription = _service
//         .getAdmissionsStream(filterType: _activeFilter)
//         .listen(
//           (list) {
//         list.sort((a, b) => b.admissionDate.compareTo(a.admissionDate));
//         _admissions = list;
//         _isLoading = false;
//         notifyListeners();
//       },
//       onError: (e) {
//         _error = e.toString();
//         _isLoading = false;
//         notifyListeners();
//       },
//     );
//   }
//
//   void setFilter(AdmissionType? type) {
//     if (_activeFilter == type) return;
//     _activeFilter = type;
//     _listen();
//   }
//
//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }
//
//   void refresh() {
//     _listen(); // re‑subscribe to the stream, triggers a fresh fetch + notifyListeners()
//   }
//
//   // In admission_provider.dart
//   Future<List<FamilyModel>> fetchAllFamilies() =>
//       _familyService.fetchAllFamilies();
//
//   // ── ID Generators ──────────────────────────────
//   Future<String> generateAdmissionId(AdmissionType type) =>
//       _service.generateAdmissionId(type);
//
//   Future<String> generateFamilyId(String familyName) =>
//       _familyService.generateFamilyId(familyName);
//
//   Future<String> generateStudentId(String name) =>
//       _service.generateStudentId(name);
//
//   // ── Family search (delegates to FamilyFirestoreService) ──
//   Future<List<FamilyModel>> searchFamilies(String query) =>
//       _familyService.searchFamiliesByName(query);
//
//   // ── Class/Section Fees ─────────────────────────
//   Future<Map<String, double?>> fetchFees(
//       String classId, String? sectionName) async {
//     if (sectionName != null && sectionName.isNotEmpty) {
//       return _service.getSectionFees(classId, sectionName);
//     }
//     return _service.getClassFees(classId);
//   }
//
//   // ── Save ───────────────────────────────────────
//   // `family` must always be provided: either a brand-new FamilyModel
//   // (not yet created in Firestore, docId == null) or an existing one
//   // (docId != null) that the user selected via search.
//   Future<void> saveAdmission(
//       AdmissionModel admission, FamilyModel family) async {
//     try {
//       _isLoading = true;
//       notifyListeners();
//
//       // 1. Ensure the family document exists — create if new.
//       String familyDocId = family.docId ?? '';
//       if (familyDocId.isEmpty) {
//         familyDocId = await _familyService.createFamily(family);
//         family.docId = familyDocId;
//       }
//
//       admission.familyDocId = familyDocId;
//       admission.familyId = family.familyId;
//       admission.familyName = family.familyName;
//
//       // 2. Save the admission itself (add or update).
//       String admissionDocId;
//       if (admission.id == null) {
//         admissionDocId = await _service.addAdmission(admission);
//         admission.id = admissionDocId;
//       } else {
//         admissionDocId = admission.id!;
//         await _service.updateAdmission(admission);
//       }
//
//       debugPrint('Admission saved with ID: $admissionDocId');
//
//       // 3. Sync every student in this admission into the family's
//       //    students[] array (add new / refresh existing by studentId).
//       for (final s in admission.students) {
//         if (s.studentId.isEmpty) continue;
//         try {
//           await _familyService.upsertStudentRef(
//             familyDocId: familyDocId,
//             ref: FamilyStudentRef(
//               studentId: s.studentId,
//               name: s.name,
//               admissionId: admissionDocId,
//               inquiryOrRegId: admission.inquiryOrRegId,
//               type: admission.type,
//             ),
//           );
//         } catch (e) {
//           // Silent error na ho, console mein dikhao
//           debugPrint('Error upserting student ref ${s.studentId}: $e');
//         }
//       }
//
//       debugPrint('All student refs upserted successfully');
//     } catch (e) {
//       _error = e.toString();
//       debugPrint('saveAdmission main error: $e');
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//   // Future<void> saveAdmission(
//   //     AdmissionModel admission, FamilyModel family) async
//   // {
//   //   try {
//   //     _isLoading = true;
//   //     notifyListeners();
//   //
//   //     // 1. Ensure the family document exists — create if new.
//   //     String familyDocId = family.docId ?? '';
//   //     if (familyDocId.isEmpty) {
//   //       familyDocId = await _familyService.createFamily(family);
//   //       family.docId = familyDocId;
//   //     }
//   //
//   //     admission.familyDocId = familyDocId;
//   //     admission.familyId = family.familyId;
//   //     admission.familyName = family.familyName;
//   //
//   //     // 2. Save the admission itself (add or update).
//   //     String admissionDocId;
//   //     if (admission.id == null) {
//   //       admissionDocId = await _service.addAdmission(admission);
//   //       admission.id = admissionDocId;
//   //     } else {
//   //       admissionDocId = admission.id!;
//   //       await _service.updateAdmission(admission);
//   //     }
//   //
//   //     // 3. Sync every student in this admission into the family's
//   //     //    students[] array (add new / refresh existing by studentId).
//   //     for (final s in admission.students) {
//   //       if (s.studentId.isEmpty) continue;
//   //       await _familyService.upsertStudentRef(
//   //         familyDocId: familyDocId,
//   //         ref: FamilyStudentRef(
//   //           studentId: s.studentId,
//   //           name: s.name,
//   //           admissionId: admissionDocId,
//   //           inquiryOrRegId: admission.inquiryOrRegId,
//   //           type: admission.type,
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     _error = e.toString();
//   //     rethrow;
//   //   } finally {
//   //     _isLoading = false;
//   //     notifyListeners();
//   //   }
//   // }
//
//   Future<void> deleteAdmission(String id) async {
//     try {
//       // Find the admission first so we can clean up its family refs.
//       final admission = _admissions.firstWhere(
//             (a) => a.id == id,
//         orElse: () => AdmissionModel(),
//       );
//
//       await _service.deleteAdmission(id);
//
//       if (admission.familyDocId.isNotEmpty) {
//         for (final s in admission.students) {
//           if (s.studentId.isEmpty) continue;
//           await _familyService.removeStudentRef(
//             familyDocId: admission.familyDocId,
//             studentId: s.studentId,
//           );
//         }
//       }
//     } catch (e) {
//       _error = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }
//
//   // ── Convert to Regular (Fixed) ──────────────────
//   // In AdmissionProvider, inside convertToRegular method signature:
//   Future<void> convertToRegular(
//       AdmissionModel preAdmission, {
//         DateTime? customDate,
//         List<AdmissionStudent>? studentsOverride,
//       }) async {
//     if (_isLoading || preAdmission.id == null) return;
//
//     try {
//       _isLoading = true;
//       notifyListeners();
//
//       final newRegId = await generateAdmissionId(AdmissionType.regular);
//       final regDate = customDate ?? DateTime.now();
//
//       final sourceStudents = studentsOverride ?? preAdmission.students;
//
//       final converted = AdmissionModel(
//         id: null,
//         type: AdmissionType.regular,
//         inquiryOrRegId: newRegId,
//         admissionDate: regDate,
//         fatherName: preAdmission.fatherName,
//         fatherPhone: preAdmission.fatherPhone,
//         fatherCnic: preAdmission.fatherCnic,
//         fatherOccupation: preAdmission.fatherOccupation,
//         motherName: preAdmission.motherName,
//         motherPhone: preAdmission.motherPhone,
//         motherCnic: preAdmission.motherCnic,
//         caste: preAdmission.caste,
//         address: preAdmission.address,
//         familyDocId: preAdmission.familyDocId,
//         familyId: preAdmission.familyId,
//         familyName: preAdmission.familyName,
//         previousSchoolName: preAdmission.previousSchoolName,
//         previousClassName: preAdmission.previousClassName,
//         previousClassMarks: preAdmission.previousClassMarks,
//         students: List<AdmissionStudent>.from(
//           sourceStudents.map((s) => AdmissionStudent(
//             name: s.name,
//             className: s.className,
//             sectionName: s.sectionName,
//             classRollNo: s.classRollNo,
//             bFormCnic: s.bFormCnic,
//             dob: s.dob,
//             monthlyFee: s.monthlyFee,
//             annualFee: s.annualFee,
//             registrationFee: s.registrationFee,
//             picBase64: s.picBase64,
//             studentId: s.studentId,
//             sectionId: s.sectionId,
//             classId: s.classId,
//           )),
//         ),
//       );
//
//       // 1. Add new regular admission
//       final newDocId = await _service.addAdmission(converted);
//       converted.id = newDocId;
//
//       // 2. Delete old pre-admission
//       await _service.deleteAdmission(preAdmission.id!);
//
//       // 3. Update family student refs
//       if (preAdmission.familyDocId.isNotEmpty) {
//         for (final s in converted.students) {
//           if (s.studentId.isEmpty) continue;
//           await _familyService.updateStudentRefType(
//             familyDocId: preAdmission.familyDocId,
//             studentId: s.studentId,
//             newAdmissionId: newDocId,
//             newInquiryOrRegId: newRegId,
//             newType: AdmissionType.regular,
//           );
//         }
//       }
//
//       // ❌ یہ تین لائنیں ڈیلیٹ کر دی گئی ہیں (local list manipulation)
//       // _admissions.removeWhere((a) => a.id == preAdmission.id);
//       // _admissions.insert(0, converted);
//       // _admissions.sort((a, b) => b.admissionDate.compareTo(a.admissionDate));
//
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _error = e.toString();
//       _isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }
//   // Future<void> convertToRegular(
//   //     AdmissionModel preAdmission, {
//   //       DateTime? customDate,
//   //       List<AdmissionStudent>? studentsOverride,  // 1. یہ نیا پیرامیٹر شامل کریں
//   //     }) async
//   // {
//   //   if (_isLoading || preAdmission.id == null) return;
//   //
//   //   try {
//   //     _isLoading = true;
//   //     notifyListeners();
//   //
//   //     final newRegId = await generateAdmissionId(AdmissionType.regular);
//   //     final regDate = customDate ?? DateTime.now();
//   //
//   //     // 2. یہ لائن بدلیں: sourceStudents کو studentsOverride سے لیا جائے
//   //     final sourceStudents = studentsOverride ?? preAdmission.students;
//   //
//   //     final converted = AdmissionModel(
//   //       id: null,
//   //       type: AdmissionType.regular,
//   //       inquiryOrRegId: newRegId,
//   //       admissionDate: regDate,
//   //       fatherName: preAdmission.fatherName,
//   //       fatherPhone: preAdmission.fatherPhone,
//   //       fatherCnic: preAdmission.fatherCnic,
//   //       fatherOccupation: preAdmission.fatherOccupation,
//   //       motherName: preAdmission.motherName,
//   //       motherPhone: preAdmission.motherPhone,
//   //       motherCnic: preAdmission.motherCnic,
//   //       caste: preAdmission.caste,
//   //       address: preAdmission.address,
//   //       familyDocId: preAdmission.familyDocId,
//   //       familyId: preAdmission.familyId,
//   //       familyName: preAdmission.familyName,
//   //       previousSchoolName: preAdmission.previousSchoolName,
//   //       previousClassName: preAdmission.previousClassName,
//   //       previousClassMarks: preAdmission.previousClassMarks,
//   //       // 3. students کی جگہ یہ پورا بلاک رکھیں
//   //       students: List<AdmissionStudent>.from(
//   //         sourceStudents.map((s) => AdmissionStudent(
//   //           name: s.name,
//   //           className: s.className,
//   //           sectionName: s.sectionName,
//   //           classRollNo: s.classRollNo,
//   //           bFormCnic: s.bFormCnic,
//   //           dob: s.dob,
//   //           monthlyFee: s.monthlyFee,
//   //           annualFee: s.annualFee,
//   //           registrationFee: s.registrationFee,
//   //           picBase64: s.picBase64,
//   //           studentId: s.studentId,
//   //           sectionId: s.sectionId,
//   //           classId: s.classId,
//   //         )),
//   //       ),
//   //     );
//   //
//   //     // باقی کوڈ (add, delete, update family refs) وہی رہے گا
//   //     final newDocId = await _service.addAdmission(converted);
//   //     converted.id = newDocId;
//   //     await _service.deleteAdmission(preAdmission.id!);
//   //
//   //     if (preAdmission.familyDocId.isNotEmpty) {
//   //       for (final s in converted.students) {
//   //         if (s.studentId.isEmpty) continue;
//   //         await _familyService.updateStudentRefType(
//   //           familyDocId: preAdmission.familyDocId,
//   //           studentId: s.studentId,
//   //           newAdmissionId: newDocId,
//   //           newInquiryOrRegId: newRegId,
//   //           newType: AdmissionType.regular,
//   //         );
//   //       }
//   //     }
//   //
//   //     _admissions.removeWhere((a) => a.id == preAdmission.id);
//   //     _admissions.insert(0, converted);
//   //     _admissions.sort((a, b) => b.admissionDate.compareTo(a.admissionDate));
//   //
//   //     _isLoading = false;
//   //     notifyListeners();
//   //   } catch (e) {
//   //     _error = e.toString();
//   //     _isLoading = false;
//   //     notifyListeners();
//   //     rethrow;
//   //   }
//   // }
//   //
//
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import '../models/admission_model.dart';
import '../models/family_model.dart';
import '../services/Admission_firestore_sercice.dart';
import '../services/family_firestore_service.dart';

class AdmissionProvider extends ChangeNotifier {
  final AdmissionFirestoreService _service = AdmissionFirestoreService();
  final FamilyFirestoreService _familyService = FamilyFirestoreService();

  List<AdmissionModel> _admissions = [];
  bool _isLoading = false;
  String? _error;
  AdmissionType? _activeFilter;

  StreamSubscription<List<AdmissionModel>>? _subscription;

  List<AdmissionModel> get admissions => _admissions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AdmissionType? get activeFilter => _activeFilter;

  AdmissionProvider() {
    _listen();
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription = _service
        .getAdmissionsStream(filterType: _activeFilter)
        .listen(
          (list) {
        list.sort((a, b) => b.admissionDate.compareTo(a.admissionDate));
        _admissions = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setFilter(AdmissionType? type) {
    if (_activeFilter == type) return;
    _activeFilter = type;
    _listen();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void refresh() {
    _listen();
  }

  Future<List<FamilyModel>> fetchAllFamilies() =>
      _familyService.fetchAllFamilies();

  Future<String> generateAdmissionId(AdmissionType type) =>
      _service.generateAdmissionId(type);

  Future<String> generateFamilyId(String familyName) =>
      _familyService.generateFamilyId(familyName);

  Future<String> generateStudentId(String name) =>
      _service.generateStudentId(name);

  Future<List<FamilyModel>> searchFamilies(String query) =>
      _familyService.searchFamiliesByName(query);

  Future<Map<String, double?>> fetchFees(
      String classId, String? sectionName) async {
    if (sectionName != null && sectionName.isNotEmpty) {
      return _service.getSectionFees(classId, sectionName);
    }
    return _service.getClassFees(classId);
  }

  Future<List<Academy>> fetchAcademies() => _service.getAcademies();

  Future<Map<String, double?>> fetchAcademyFees(String academyId) =>
      _service.getAcademyFees(academyId);

  Future<void> saveAdmission(
      AdmissionModel admission, FamilyModel family) async {
    try {
      _isLoading = true;
      notifyListeners();

      String familyDocId = family.docId ?? '';
      if (familyDocId.isEmpty) {
        familyDocId = await _familyService.createFamily(family);
        family.docId = familyDocId;
      }

      admission.familyDocId = familyDocId;
      admission.familyId = family.familyId;
      admission.familyName = family.familyName;

      String admissionDocId;
      if (admission.id == null) {
        admissionDocId = await _service.addAdmission(admission);
        admission.id = admissionDocId;
      } else {
        admissionDocId = admission.id!;
        await _service.updateAdmission(admission);
      }

      debugPrint('Admission saved with ID: $admissionDocId');

      for (final s in admission.students) {
        if (s.studentId.isEmpty) continue;
        try {
          await _familyService.upsertStudentRef(
            familyDocId: familyDocId,
            ref: FamilyStudentRef(
              studentId: s.studentId,
              name: s.name,
              admissionId: admissionDocId,
              inquiryOrRegId: admission.inquiryOrRegId,
              type: admission.type,
            ),
          );
        } catch (e) {
          debugPrint('Error upserting student ref ${s.studentId}: $e');
        }
      }

      debugPrint('All student refs upserted successfully');
    } catch (e) {
      _error = e.toString();
      debugPrint('saveAdmission main error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAdmission(String id) async {
    try {
      final admission = _admissions.firstWhere(
            (a) => a.id == id,
        orElse: () => AdmissionModel(),
      );

      await _service.deleteAdmission(id);

      if (admission.familyDocId.isNotEmpty) {
        for (final s in admission.students) {
          if (s.studentId.isEmpty) continue;
          await _familyService.removeStudentRef(
            familyDocId: admission.familyDocId,
            studentId: s.studentId,
          );
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> convertToRegular(
      AdmissionModel preAdmission, {
        DateTime? customDate,
        List<AdmissionStudent>? studentsOverride,
      }) async {
    if (_isLoading || preAdmission.id == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final newRegId = await generateAdmissionId(AdmissionType.regular);
      final regDate = customDate ?? DateTime.now();
      final sourceStudents = studentsOverride ?? preAdmission.students;

      final converted = AdmissionModel(
        id: null,
        type: AdmissionType.regular,
        inquiryOrRegId: newRegId,
        admissionDate: regDate,
        fatherName: preAdmission.fatherName,
        fatherPhone: preAdmission.fatherPhone,
        fatherCnic: preAdmission.fatherCnic,
        fatherOccupation: preAdmission.fatherOccupation,
        motherName: preAdmission.motherName,
        motherPhone: preAdmission.motherPhone,
        motherCnic: preAdmission.motherCnic,
        caste: preAdmission.caste,
        address: preAdmission.address,
        familyDocId: preAdmission.familyDocId,
        familyId: preAdmission.familyId,
        familyName: preAdmission.familyName,
        previousSchoolName: preAdmission.previousSchoolName,
        previousClassName: preAdmission.previousClassName,
        previousClassMarks: preAdmission.previousClassMarks,
        students: List<AdmissionStudent>.from(
          sourceStudents.map((s) => AdmissionStudent(
            name: s.name,
            className: s.className,
            sectionName: s.sectionName,
            classRollNo: s.classRollNo,
            bFormCnic: s.bFormCnic,
            dob: s.dob,
            monthlyFee: s.monthlyFee,
            annualFee: s.annualFee,
            registrationFee: s.registrationFee,
            picBase64: s.picBase64,
            studentId: s.studentId,
            sectionId: s.sectionId,
            classId: s.classId,
            hasSchool: s.hasSchool,
            hasAcademy: s.hasAcademy,
            academyId: s.academyId,
            academyName: s.academyName,
            academyFee: s.academyFee,
          )),
        ),
      );

      final newDocId = await _service.addAdmission(converted);
      converted.id = newDocId;

      await _service.deleteAdmission(preAdmission.id!);

      if (preAdmission.familyDocId.isNotEmpty) {
        for (final s in converted.students) {
          if (s.studentId.isEmpty) continue;
          await _familyService.updateStudentRefType(
            familyDocId: preAdmission.familyDocId,
            studentId: s.studentId,
            newAdmissionId: newDocId,
            newInquiryOrRegId: newRegId,
            newType: AdmissionType.regular,
          );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}