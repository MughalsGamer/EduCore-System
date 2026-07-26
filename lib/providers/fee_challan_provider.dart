// import 'package:flutter/material.dart';
//
// import '../models/admission_model.dart';
// import '../models/fee_challan_model.dart';
// import '../services/fee_challan_firestore_service.dart';
//
// // ─────────────────────────────────────────────
// //  Lightweight struct: one family + its REGULAR-admission
// //  students, built by the screen from AdmissionProvider's data.
// //  Not a Firestore model — just what the generator needs.
// // ─────────────────────────────────────────────
// class FamilyForChallan {
//   final String familyDocId;
//   final String familyId;
//   final String familyName;
//   final String fatherName;
//   final String fatherPhone;
//   final List<AdmissionStudent> students;
//
//   FamilyForChallan({
//     required this.familyDocId,
//     required this.familyId,
//     required this.familyName,
//     required this.fatherName,
//     required this.fatherPhone,
//     required this.students,
//   });
// }
//
// class FeeChallanProvider extends ChangeNotifier {
//   final FeeChallanFirestoreService _service = FeeChallanFirestoreService();
//
//   bool _isGenerating = false;
//   String? _error;
//
//   Set<String> _alreadyChallanedFamilyDocIds = {};
//   List<FeeChallanModel> _lastGeneratedChallans = [];
//   int _lastGenerationSkippedCount = 0;
//
//   bool get isGenerating => _isGenerating;
//   String? get error => _error;
//   Set<String> get alreadyChallanedFamilyDocIds => _alreadyChallanedFamilyDocIds;
//   List<FeeChallanModel> get lastGeneratedChallans => _lastGeneratedChallans;
//   int get lastGenerationSkippedCount => _lastGenerationSkippedCount;
//
//   // Call whenever the billing month/year is picked, so the family list
//   // can grey out / badge families that already have a challan for it.
//   Future<void> refreshAlreadyGenerated(int month, int year) async {
//     try {
//       _alreadyChallanedFamilyDocIds =
//       await _service.familiesAlreadyChallanedForMonth(month, year);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('refreshAlreadyGenerated error: $e');
//     }
//   }
//
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
//
//   void clearResults() {
//     _lastGeneratedChallans = [];
//     _lastGenerationSkippedCount = 0;
//     notifyListeners();
//   }
//
//   // ─────────────────────────────────────
//   //  Main generation entrypoint — called once per "Generate" tap,
//   //  with every family the user selected.
//   // ─────────────────────────────────────
//   Future<void> generateChallans({
//     required List<FamilyForChallan> families,
//     required int month,
//     required int year,
//     required DateTime generatedDate,
//     required DateTime dueDate,
//   }) async {
//     _isGenerating = true;
//     _error = null;
//     _lastGeneratedChallans = [];
//     _lastGenerationSkippedCount = 0;
//     notifyListeners();
//
//     try {
//       for (final family in families) {
//         // Safety net: skip if this family already has a challan for
//         // this exact billing month (e.g. generated twice by mistake).
//         final alreadyDone = await _service.familyAlreadyChallanedForMonth(
//             family.familyDocId, month, year);
//         if (alreadyDone) {
//           _lastGenerationSkippedCount++;
//           continue;
//         }
//
//         final List<ChallanStudentLine> lines = [];
//         for (final s in family.students) {
//           final isFirst = !(await _service.studentHasPriorChallan(s.studentId));
//           lines.add(ChallanStudentLine(
//             studentId: s.studentId,
//             name: s.name,
//             className: s.className,
//             sectionName: s.sectionName,
//             monthlyFee: s.monthlyFee ?? 0,
//             annualFee: isFirst ? (s.annualFee ?? 0) : 0,
//             registrationFee: isFirst ? (s.registrationFee ?? 0) : 0,
//             isFirstChallan: isFirst,
//           ));
//         }
//
//         final currentMonthTotal =
//         lines.fold<double>(0, (sum, l) => sum + l.lineTotal);
//         final previousBalance =
//         await _service.getFamilyPreviousBalance(family.familyDocId);
//
//         final challanNumber = await _service.generateChallanNumber();
//
//         final challan = FeeChallanModel(
//           challanNumber: challanNumber,
//           familyDocId: family.familyDocId,
//           familyId: family.familyId,
//           familyName: family.familyName,
//           fatherName: family.fatherName,
//           fatherPhone: family.fatherPhone,
//           month: month,
//           year: year,
//           generatedDate: generatedDate,
//           dueDate: dueDate,
//           students: lines,
//           currentMonthTotal: currentMonthTotal,
//           previousBalance: previousBalance,
//         );
//
//         final docId = await _service.addChallan(challan);
//         challan.id = docId;
//
//         _lastGeneratedChallans.add(challan);
//         _alreadyChallanedFamilyDocIds.add(family.familyDocId);
//       }
//
//       debugPrint(
//           'Challan generation done: ${_lastGeneratedChallans.length} created, $_lastGenerationSkippedCount skipped');
//     } catch (e) {
//       _error = e.toString();
//       debugPrint('generateChallans error: $e');
//     } finally {
//       _isGenerating = false;
//       notifyListeners();
//     }
//   }
// }


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

  // familyDocId -> set of studentIds already challaned for the
  // currently selected billing month+year. A family with an empty
  // matching set (relative to its live student list) is fully eligible;
  // a family where every current student's id is in the set is fully
  // "Already Generated"; anything in between is "Partial" (new student
  // added since the family's last challan for this month).
  Map<String, Set<String>> _challanedStudentIdsByFamily = {};

  List<FeeChallanModel> _lastGeneratedChallans = [];
  int _lastGenerationSkippedCount = 0;

  // ── Challan list screen state ──
  bool _isLoadingList = false;
  String? _listError;
  List<FeeChallanModel> _allChallans = [];
  bool _isDeleting = false;

  bool get isGenerating => _isGenerating;
  String? get error => _error;
  List<FeeChallanModel> get lastGeneratedChallans => _lastGeneratedChallans;
  int get lastGenerationSkippedCount => _lastGenerationSkippedCount;

  bool get isLoadingList => _isLoadingList;
  String? get listError => _listError;
  List<FeeChallanModel> get allChallans => _allChallans;
  bool get isDeleting => _isDeleting;

  // Back-compat convenience: purely "fully generated" family ids (used by
  // the generator screen to grey out / badge fully-done families).
  Set<String> get alreadyChallanedFamilyDocIds =>
      _challanedStudentIdsByFamily.keys.toSet();

  // ── Per-family/per-student duplicate helpers ──

  /// Which studentIds (within [familyDocId]) already have a challan for
  /// the currently loaded month/year.
  Set<String> challanedStudentIdsFor(String familyDocId) =>
      _challanedStudentIdsByFamily[familyDocId] ?? {};

  /// Given a family's live (current) student list, returns only the
  /// students who do NOT yet have a challan for the selected month+year.
  /// - Empty result + family had no students = nothing to do.
  /// - Empty result + family HAD challaned students = fully done, skip.
  /// - Non-empty result = these are the (new) students eligible this run.
  List<AdmissionStudent> eligibleStudentsFor(FamilyForChallan family) {
    final done = challanedStudentIdsFor(family.familyDocId);
    if (done.isEmpty) return family.students; // nothing challaned yet
    return family.students
        .where((s) => !done.contains(s.studentId))
        .toList();
  }

  /// True if every current student in the family already has a challan
  /// for the selected month+year (nothing left to generate).
  bool isFamilyFullyGenerated(FamilyForChallan family) {
    if (family.students.isEmpty) return false;
    final done = challanedStudentIdsFor(family.familyDocId);
    if (done.isEmpty) return false;
    return family.students.every((s) => done.contains(s.studentId));
  }

  /// True if SOME (but not all) students in the family already have a
  /// challan for the selected month — i.e. a new student was added after
  /// the family's challan for this month was generated.
  bool isFamilyPartiallyGenerated(FamilyForChallan family) {
    final done = challanedStudentIdsFor(family.familyDocId);
    if (done.isEmpty) return false;
    return family.students.any((s) => done.contains(s.studentId)) &&
        !isFamilyFullyGenerated(family);
  }

  // Call whenever the billing month/year is picked, so the family list
  // can grey out / badge families that already have a challan for it.
  Future<void> refreshAlreadyGenerated(int month, int year) async {
    try {
      _challanedStudentIdsByFamily =
      await _service.familyStudentIdsChallanedForMonth(month, year);
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
  //
  //  For each family, only students who do NOT already have a challan
  //  for this billing month+year are included. If a family has zero
  //  eligible students (already fully challaned), it's skipped entirely.
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
        // Re-check live from Firestore (covers races / stale UI state),
        // then narrow down to students not yet challaned this month.
        final alreadyDoneIds = await _service
            .studentIdsAlreadyChallanedForFamilyMonth(
            family.familyDocId, month, year);

        final eligibleStudents = alreadyDoneIds.isEmpty
            ? family.students
            : family.students
            .where((s) => !alreadyDoneIds.contains(s.studentId))
            .toList();

        if (eligibleStudents.isEmpty) {
          // Every current student in this family already has a challan
          // for this month — nothing new to generate.
          _lastGenerationSkippedCount++;
          continue;
        }

        final List<ChallanStudentLine> lines = [];
        for (final s in eligibleStudents) {
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

        // Patch local map immediately so UI reflects the new state
        // without waiting for a full refetch.
        _challanedStudentIdsByFamily
            .putIfAbsent(family.familyDocId, () => {})
            .addAll(eligibleStudents.map((s) => s.studentId));
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

  // ─────────────────────────────────────
  //  Challan List Screen
  // ─────────────────────────────────────

  Future<void> loadAllChallans({int? month, int? year}) async {
    _isLoadingList = true;
    _listError = null;
    notifyListeners();
    try {
      _allChallans = await _service.getChallansOnce(month: month, year: year);
    } catch (e) {
      _listError = e.toString();
      debugPrint('loadAllChallans error: $e');
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChallan(FeeChallanModel challan) async {
    if (challan.id == null) return false;
    _isDeleting = true;
    notifyListeners();
    try {
      await _service.deleteChallan(challan.id!);

      // Patch local list immediately.
      _allChallans.removeWhere((c) => c.id == challan.id);

      // Patch the generator-screen map too, in case the deleted challan's
      // month/year matches what's currently loaded there — otherwise a
      // just-deleted student would still show as "already generated".
      final familySet = _challanedStudentIdsByFamily[challan.familyDocId];
      if (familySet != null) {
        familySet.removeWhere((id) => challan.studentIds.contains(id));
        if (familySet.isEmpty) {
          _challanedStudentIdsByFamily.remove(challan.familyDocId);
        }
      }

      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _listError = e.toString();
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }
}