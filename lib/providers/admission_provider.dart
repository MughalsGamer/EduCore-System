import 'dart:async';

import 'package:flutter/material.dart';

import '../models/admission_model.dart';
import '../services/Admission_firestore_sercice.dart';

class AdmissionProvider extends ChangeNotifier {
  final AdmissionFirestoreService _service = AdmissionFirestoreService();

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
    _listen(); // re‑subscribe to the stream, triggers a fresh fetch + notifyListeners()
  }

  // ── ID Generators ──────────────────────────────
  Future<String> generateAdmissionId(AdmissionType type) =>
      _service.generateAdmissionId(type);

  Future<String> generateFamilyId(String familyName) =>
      _service.generateFamilyId(familyName);

  Future<String> generateStudentId(String name) =>
      _service.generateStudentId(name);

  // ── Class/Section Fees ─────────────────────────
  Future<Map<String, double?>> fetchFees(
      String classId, String? sectionName) async {
    if (sectionName != null && sectionName.isNotEmpty) {
      return _service.getSectionFees(classId, sectionName);
    }
    return _service.getClassFees(classId);
  }

  // ── Save ───────────────────────────────────────
  Future<void> saveAdmission(AdmissionModel admission) async {
    try {
      _isLoading = true;
      notifyListeners();
      if (admission.id == null) {
        await _service.addAdmission(admission); // ID return ho rahi hai, idhar ignore kar rahe
      } else {
        await _service.updateAdmission(admission);
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAdmission(String id) async {
    try {
      await _service.deleteAdmission(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ── Convert to Regular (Fixed) ──────────────────
  Future<void> convertToRegular(AdmissionModel preAdmission, {DateTime? customDate}) async {
    // Guard: agar already loading ho ya ID na ho to ignore
    if (_isLoading || preAdmission.id == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // 1. Generate new Registration ID
      final newRegId = await generateAdmissionId(AdmissionType.regular);

      // 2. Admission date
      final regDate = customDate ?? DateTime.now();

      // 3. Create a copy with required changes
      final converted = AdmissionModel(
        id: null, // will be set after Firestore add
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
        familyId: preAdmission.familyId,
        familyName: preAdmission.familyName,
        previousSchoolName: preAdmission.previousSchoolName,
        previousClassName: preAdmission.previousClassName,
        previousClassMarks: preAdmission.previousClassMarks,
        students: List<AdmissionStudent>.from(
          preAdmission.students.map((s) => AdmissionStudent(
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
          )),
        ),
      );

      // 4. Add new regular admission and get the real Firestore ID
      final newDocId = await _service.addAdmission(converted);
      converted.id = newDocId; // ✅ Real ID set kar do

      // 5. Delete old pre-admission
      await _service.deleteAdmission(preAdmission.id!);

      // 6. Immediate local update (ab ID valid hai, duplicate nahi hoga)
      _admissions.removeWhere((a) => a.id == preAdmission.id);
      _admissions.insert(0, converted);
      _admissions.sort((a, b) => b.admissionDate.compareTo(a.admissionDate));

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

  Future<List<AdmissionModel>> searchFamilies(String query) =>
      _service.searchFamiliesByName(query);

}