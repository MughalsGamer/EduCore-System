import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/admission_model.dart';
import '../services/firestore_service.dart'; // ✅ Only one service file

class AdmissionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // --- Form fields ---
  String admissionType = 'family';
  DateTime? admissionDate;
  String previousClass = '';
  String previousSchool = '';

  // Parent fields
  String fatherName = '';
  String fatherCNIC = '';
  String occupation = '';
  String phone = '';
  String motherName = '';
  String motherCNIC = '';
  String address = '';
  String city = '';

  // Family fields
  String familyName = '';

  // Children list (always at least one)
  List<ChildFormData> children = [ChildFormData()];

  // Loading state
  bool isLoading = false;

  // Picked images map (index -> File)
  final Map<int, File> _childImages = {};

  File? getChildImage(int index) => _childImages[index];

  void setAdmissionType(String type) {
    admissionType = type;
    if (type == 'individual') {
      children = [ChildFormData()];
    } else {
      if (children.isEmpty) children = [ChildFormData()];
    }
    notifyListeners();
  }

  void addChild() {
    if (admissionType == 'family') {
      children.add(ChildFormData());
      notifyListeners();
    }
  }

  void removeChild(int index) {
    if (admissionType == 'family' && children.length > 1) {
      children.removeAt(index);
      final updated = <int, File>{};
      _childImages.forEach((k, v) {
        if (k < index) updated[k] = v;
        if (k > index) updated[k - 1] = v;
      });
      _childImages
        ..clear()
        ..addAll(updated);
      notifyListeners();
    }
  }

  Future<void> pickImage(int childIndex) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _childImages[childIndex] = File(image.path);
      notifyListeners();
    }
  }

  Future<void> submit() async {
    isLoading = true;
    notifyListeners();

    try {
      final List<StudentModel> students = [];
      for (int i = 0; i < children.length; i++) {
        final child = children[i];
        String? base64Image;
        if (_childImages.containsKey(i)) {
          final bytes = await _childImages[i]!.readAsBytes();
          base64Image = base64Encode(bytes);
        }

        students.add(StudentModel(
          rollNo: child.rollNo,
          studentName: child.studentName,
          bFormCNIC: child.bFormCNIC,
          dob: child.dob,
          studentClass: child.studentClass,
          section: child.section,
          monthlyFee: child.monthlyFee,
          booksCharges: child.booksCharges,
          uniformCharges: child.uniformCharges,
          stationeryCharges: child.stationeryCharges,
          transportFee: child.transportFee,
          securityFee: child.securityFee,
          studentPictureBase64: base64Image,
        ));
      }

      final admission = AdmissionModel(
        type: admissionType,
        admissionDate: admissionDate,
        previousClass: previousClass,
        previousSchool: previousSchool,
        familyName: admissionType == 'family' ? familyName : null,
        parent: ParentModel(
          fatherName: fatherName,
          fatherCNIC: fatherCNIC,
          occupation: occupation,
          phone: phone,
          motherName: motherName,
          motherCNIC: motherCNIC,
          address: address,
          city: city,
        ),
        children: students,
      );

      // ✅ Correct method name — addAdmission, not add
      await _firestoreService.addAdmission(admission);
      _resetForm();
    } catch (e) {
      debugPrint('Error submitting: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _resetForm() {
    admissionType = 'family';
    admissionDate = null;
    previousClass = '';
    previousSchool = '';
    fatherName = '';
    fatherCNIC = '';
    occupation = '';
    phone = '';
    motherName = '';
    motherCNIC = '';
    address = '';
    city = '';
    familyName = '';
    children = [ChildFormData()];
    _childImages.clear();
  }
}

class ChildFormData {
  String rollNo = '';
  String studentName = '';
  String bFormCNIC = '';
  DateTime? dob;
  String studentClass = '';
  String section = '';
  double monthlyFee = 0;
  double booksCharges = 0;
  double uniformCharges = 0;
  double stationeryCharges = 0;
  double transportFee = 0;
  double securityFee = 0;
  String? studentPictureBase64;
}