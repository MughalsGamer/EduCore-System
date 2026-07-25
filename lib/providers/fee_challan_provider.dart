import 'package:flutter/material.dart';

import '../models/admission_model.dart';
import '../models/fee_challan_model.dart';
import '../services/fee_challan_firestore_service.dart';

// ─────────────────────────────────────────────
//  Lightweight struct: one family + its REGULAR-admission
//  students, built by the screen from AdmissionProvider's data.
//  Not a Firestore model — just what the generator needs.
// ─────────────────────────────────────────────
class FamilyForChallan {
  final String familyDocId;
  final String familyId;
  final String familyName;
  final String fatherName;
  final String fatherPhone;
  final List<AdmissionStudent> students;

  FamilyForChallan({
    required this.familyDocId,
    required this.familyId,
    required this.familyName,
    required this.fatherName,
    required this.fatherPhone,
    required this.students,
  });
}

class FeeChallanProvider extends ChangeNotifier {
  final FeeChallanFirestoreService _service = FeeChallanFirestoreService();

  bool _isGenerating = false;
  String? _error;

  Set<String> _alreadyChallanedFamilyDocIds = {};
  List<FeeChallanModel> _lastGeneratedChallans = [];
  int _lastGenerationSkippedCount = 0;

  bool get isGenerating => _isGenerating;
  String? get error => _error;
  Set<String> get alreadyChallanedFamilyDocIds => _alreadyChallanedFamilyDocIds;
  List<FeeChallanModel> get lastGeneratedChallans => _lastGeneratedChallans;
  int get lastGenerationSkippedCount => _lastGenerationSkippedCount;

  // Call whenever the billing month/year is picked, so the family list
  // can grey out / badge families that already have a challan for it.
  Future<void> refreshAlreadyGenerated(int month, int year) async {
    try {
      _alreadyChallanedFamilyDocIds =
      await _service.familiesAlreadyChallanedForMonth(month, year);
      notifyListeners();
    } catch (e) {
      debugPrint('refreshAlreadyGenerated error: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearResults() {
    _lastGeneratedChallans = [];
    _lastGenerationSkippedCount = 0;
    notifyListeners();
  }

  // ─────────────────────────────────────
  //  Main generation entrypoint — called once per "Generate" tap,
  //  with every family the user selected.
  // ─────────────────────────────────────
  Future<void> generateChallans({
    required List<FamilyForChallan> families,
    required int month,
    required int year,
    required DateTime generatedDate,
    required DateTime dueDate,
  }) async {
    _isGenerating = true;
    _error = null;
    _lastGeneratedChallans = [];
    _lastGenerationSkippedCount = 0;
    notifyListeners();

    try {
      for (final family in families) {
        // Safety net: skip if this family already has a challan for
        // this exact billing month (e.g. generated twice by mistake).
        final alreadyDone = await _service.familyAlreadyChallanedForMonth(
            family.familyDocId, month, year);
        if (alreadyDone) {
          _lastGenerationSkippedCount++;
          continue;
        }

        final List<ChallanStudentLine> lines = [];
        for (final s in family.students) {
          final isFirst = !(await _service.studentHasPriorChallan(s.studentId));
          lines.add(ChallanStudentLine(
            studentId: s.studentId,
            name: s.name,
            className: s.className,
            sectionName: s.sectionName,
            monthlyFee: s.monthlyFee ?? 0,
            annualFee: isFirst ? (s.annualFee ?? 0) : 0,
            registrationFee: isFirst ? (s.registrationFee ?? 0) : 0,
            isFirstChallan: isFirst,
          ));
        }

        final currentMonthTotal =
        lines.fold<double>(0, (sum, l) => sum + l.lineTotal);
        final previousBalance =
        await _service.getFamilyPreviousBalance(family.familyDocId);

        final challanNumber = await _service.generateChallanNumber();

        final challan = FeeChallanModel(
          challanNumber: challanNumber,
          familyDocId: family.familyDocId,
          familyId: family.familyId,
          familyName: family.familyName,
          fatherName: family.fatherName,
          fatherPhone: family.fatherPhone,
          month: month,
          year: year,
          generatedDate: generatedDate,
          dueDate: dueDate,
          students: lines,
          currentMonthTotal: currentMonthTotal,
          previousBalance: previousBalance,
        );

        final docId = await _service.addChallan(challan);
        challan.id = docId;

        _lastGeneratedChallans.add(challan);
        _alreadyChallanedFamilyDocIds.add(family.familyDocId);
      }

      debugPrint(
          'Challan generation done: ${_lastGeneratedChallans.length} created, $_lastGenerationSkippedCount skipped');
    } catch (e) {
      _error = e.toString();
      debugPrint('generateChallans error: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}