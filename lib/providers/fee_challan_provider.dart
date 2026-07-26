// // import 'package:flutter/material.dart';
// //
// // import '../models/admission_model.dart';
// // import '../models/fee_challan_model.dart';
// // import '../services/fee_challan_firestore_service.dart';
// //
// // // ─────────────────────────────────────────────
// // //  Lightweight struct: one family + its REGULAR-admission
// // //  students, built by the screen from AdmissionProvider's data.
// // //  Not a Firestore model — just what the generator needs.
// // // ─────────────────────────────────────────────
// // class FamilyForChallan {
// //   final String familyDocId;
// //   final String familyId;
// //   final String familyName;
// //   final String fatherName;
// //   final String fatherPhone;
// //   final List<AdmissionStudent> students;
// //
// //   FamilyForChallan({
// //     required this.familyDocId,
// //     required this.familyId,
// //     required this.familyName,
// //     required this.fatherName,
// //     required this.fatherPhone,
// //     required this.students,
// //   });
// // }
// //
// // class FeeChallanProvider extends ChangeNotifier {
// //   final FeeChallanFirestoreService _service = FeeChallanFirestoreService();
// //
// //   bool _isGenerating = false;
// //   String? _error;
// //
// //   Set<String> _alreadyChallanedFamilyDocIds = {};
// //   List<FeeChallanModel> _lastGeneratedChallans = [];
// //   int _lastGenerationSkippedCount = 0;
// //
// //   bool get isGenerating => _isGenerating;
// //   String? get error => _error;
// //   Set<String> get alreadyChallanedFamilyDocIds => _alreadyChallanedFamilyDocIds;
// //   List<FeeChallanModel> get lastGeneratedChallans => _lastGeneratedChallans;
// //   int get lastGenerationSkippedCount => _lastGenerationSkippedCount;
// //
// //   // Call whenever the billing month/year is picked, so the family list
// //   // can grey out / badge families that already have a challan for it.
// //   Future<void> refreshAlreadyGenerated(int month, int year) async {
// //     try {
// //       _alreadyChallanedFamilyDocIds =
// //       await _service.familiesAlreadyChallanedForMonth(month, year);
// //       notifyListeners();
// //     } catch (e) {
// //       debugPrint('refreshAlreadyGenerated error: $e');
// //     }
// //   }
// //
// //   void clearError() {
// //     _error = null;
// //     notifyListeners();
// //   }
// //
// //   void clearResults() {
// //     _lastGeneratedChallans = [];
// //     _lastGenerationSkippedCount = 0;
// //     notifyListeners();
// //   }
// //
// //   // ─────────────────────────────────────
// //   //  Main generation entrypoint — called once per "Generate" tap,
// //   //  with every family the user selected.
// //   // ─────────────────────────────────────
// //   Future<void> generateChallans({
// //     required List<FamilyForChallan> families,
// //     required int month,
// //     required int year,
// //     required DateTime generatedDate,
// //     required DateTime dueDate,
// //   }) async {
// //     _isGenerating = true;
// //     _error = null;
// //     _lastGeneratedChallans = [];
// //     _lastGenerationSkippedCount = 0;
// //     notifyListeners();
// //
// //     try {
// //       for (final family in families) {
// //         // Safety net: skip if this family already has a challan for
// //         // this exact billing month (e.g. generated twice by mistake).
// //         final alreadyDone = await _service.familyAlreadyChallanedForMonth(
// //             family.familyDocId, month, year);
// //         if (alreadyDone) {
// //           _lastGenerationSkippedCount++;
// //           continue;
// //         }
// //
// //         final List<ChallanStudentLine> lines = [];
// //         for (final s in family.students) {
// //           final isFirst = !(await _service.studentHasPriorChallan(s.studentId));
// //           lines.add(ChallanStudentLine(
// //             studentId: s.studentId,
// //             name: s.name,
// //             className: s.className,
// //             sectionName: s.sectionName,
// //             monthlyFee: s.monthlyFee ?? 0,
// //             annualFee: isFirst ? (s.annualFee ?? 0) : 0,
// //             registrationFee: isFirst ? (s.registrationFee ?? 0) : 0,
// //             isFirstChallan: isFirst,
// //           ));
// //         }
// //
// //         final currentMonthTotal =
// //         lines.fold<double>(0, (sum, l) => sum + l.lineTotal);
// //         final previousBalance =
// //         await _service.getFamilyPreviousBalance(family.familyDocId);
// //
// //         final challanNumber = await _service.generateChallanNumber();
// //
// //         final challan = FeeChallanModel(
// //           challanNumber: challanNumber,
// //           familyDocId: family.familyDocId,
// //           familyId: family.familyId,
// //           familyName: family.familyName,
// //           fatherName: family.fatherName,
// //           fatherPhone: family.fatherPhone,
// //           month: month,
// //           year: year,
// //           generatedDate: generatedDate,
// //           dueDate: dueDate,
// //           students: lines,
// //           currentMonthTotal: currentMonthTotal,
// //           previousBalance: previousBalance,
// //         );
// //
// //         final docId = await _service.addChallan(challan);
// //         challan.id = docId;
// //
// //         _lastGeneratedChallans.add(challan);
// //         _alreadyChallanedFamilyDocIds.add(family.familyDocId);
// //       }
// //
// //       debugPrint(
// //           'Challan generation done: ${_lastGeneratedChallans.length} created, $_lastGenerationSkippedCount skipped');
// //     } catch (e) {
// //       _error = e.toString();
// //       debugPrint('generateChallans error: $e');
// //     } finally {
// //       _isGenerating = false;
// //       notifyListeners();
// //     }
// //   }
// // }
//
//
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
//   // familyDocId -> set of studentIds already challaned for the
//   // currently selected billing month+year. A family with an empty
//   // matching set (relative to its live student list) is fully eligible;
//   // a family where every current student's id is in the set is fully
//   // "Already Generated"; anything in between is "Partial" (new student
//   // added since the family's last challan for this month).
//   Map<String, Set<String>> _challanedStudentIdsByFamily = {};
//
//   List<FeeChallanModel> _lastGeneratedChallans = [];
//   int _lastGenerationSkippedCount = 0;
//
//   // ── Challan list screen state ──
//   bool _isLoadingList = false;
//   String? _listError;
//   List<FeeChallanModel> _allChallans = [];
//   bool _isDeleting = false;
//
//   bool get isGenerating => _isGenerating;
//   String? get error => _error;
//   List<FeeChallanModel> get lastGeneratedChallans => _lastGeneratedChallans;
//   int get lastGenerationSkippedCount => _lastGenerationSkippedCount;
//
//   bool get isLoadingList => _isLoadingList;
//   String? get listError => _listError;
//   List<FeeChallanModel> get allChallans => _allChallans;
//   bool get isDeleting => _isDeleting;
//
//   // Back-compat convenience: purely "fully generated" family ids (used by
//   // the generator screen to grey out / badge fully-done families).
//   Set<String> get alreadyChallanedFamilyDocIds =>
//       _challanedStudentIdsByFamily.keys.toSet();
//
//   // ── Per-family/per-student duplicate helpers ──
//
//   /// Which studentIds (within [familyDocId]) already have a challan for
//   /// the currently loaded month/year.
//   Set<String> challanedStudentIdsFor(String familyDocId) =>
//       _challanedStudentIdsByFamily[familyDocId] ?? {};
//
//   /// Given a family's live (current) student list, returns only the
//   /// students who do NOT yet have a challan for the selected month+year.
//   /// - Empty result + family had no students = nothing to do.
//   /// - Empty result + family HAD challaned students = fully done, skip.
//   /// - Non-empty result = these are the (new) students eligible this run.
//   List<AdmissionStudent> eligibleStudentsFor(FamilyForChallan family) {
//     final done = challanedStudentIdsFor(family.familyDocId);
//     if (done.isEmpty) return family.students; // nothing challaned yet
//     return family.students
//         .where((s) => !done.contains(s.studentId))
//         .toList();
//   }
//
//   /// True if every current student in the family already has a challan
//   /// for the selected month+year (nothing left to generate).
//   bool isFamilyFullyGenerated(FamilyForChallan family) {
//     if (family.students.isEmpty) return false;
//     final done = challanedStudentIdsFor(family.familyDocId);
//     if (done.isEmpty) return false;
//     return family.students.every((s) => done.contains(s.studentId));
//   }
//
//   /// True if SOME (but not all) students in the family already have a
//   /// challan for the selected month — i.e. a new student was added after
//   /// the family's challan for this month was generated.
//   bool isFamilyPartiallyGenerated(FamilyForChallan family) {
//     final done = challanedStudentIdsFor(family.familyDocId);
//     if (done.isEmpty) return false;
//     return family.students.any((s) => done.contains(s.studentId)) &&
//         !isFamilyFullyGenerated(family);
//   }
//
//   // Call whenever the billing month/year is picked, so the family list
//   // can grey out / badge families that already have a challan for it.
//   Future<void> refreshAlreadyGenerated(int month, int year) async {
//     try {
//       _challanedStudentIdsByFamily =
//       await _service.familyStudentIdsChallanedForMonth(month, year);
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
//   //
//   //  For each family, only students who do NOT already have a challan
//   //  for this billing month+year are included. If a family has zero
//   //  eligible students (already fully challaned), it's skipped entirely.
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
//         // Re-check live from Firestore (covers races / stale UI state),
//         // then narrow down to students not yet challaned this month.
//         final alreadyDoneIds = await _service
//             .studentIdsAlreadyChallanedForFamilyMonth(
//             family.familyDocId, month, year);
//
//         final eligibleStudents = alreadyDoneIds.isEmpty
//             ? family.students
//             : family.students
//             .where((s) => !alreadyDoneIds.contains(s.studentId))
//             .toList();
//
//         if (eligibleStudents.isEmpty) {
//           // Every current student in this family already has a challan
//           // for this month — nothing new to generate.
//           _lastGenerationSkippedCount++;
//           continue;
//         }
//
//         final List<ChallanStudentLine> lines = [];
//         for (final s in eligibleStudents) {
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
//
//         // Patch local map immediately so UI reflects the new state
//         // without waiting for a full refetch.
//         _challanedStudentIdsByFamily
//             .putIfAbsent(family.familyDocId, () => {})
//             .addAll(eligibleStudents.map((s) => s.studentId));
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
//
//   // ─────────────────────────────────────
//   //  Challan List Screen
//   // ─────────────────────────────────────
//
//   Future<void> loadAllChallans({int? month, int? year}) async {
//     _isLoadingList = true;
//     _listError = null;
//     notifyListeners();
//     try {
//       _allChallans = await _service.getChallansOnce(month: month, year: year);
//     } catch (e) {
//       _listError = e.toString();
//       debugPrint('loadAllChallans error: $e');
//     } finally {
//       _isLoadingList = false;
//       notifyListeners();
//     }
//   }
//
//   Future<bool> deleteChallan(FeeChallanModel challan) async {
//     if (challan.id == null) return false;
//     _isDeleting = true;
//     notifyListeners();
//     try {
//       await _service.deleteChallan(challan.id!);
//
//       // Patch local list immediately.
//       _allChallans.removeWhere((c) => c.id == challan.id);
//
//       // Patch the generator-screen map too, in case the deleted challan's
//       // month/year matches what's currently loaded there — otherwise a
//       // just-deleted student would still show as "already generated".
//       final familySet = _challanedStudentIdsByFamily[challan.familyDocId];
//       if (familySet != null) {
//         familySet.removeWhere((id) => challan.studentIds.contains(id));
//         if (familySet.isEmpty) {
//           _challanedStudentIdsByFamily.remove(challan.familyDocId);
//         }
//       }
//
//       _isDeleting = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _listError = e.toString();
//       _isDeleting = false;
//       notifyListeners();
//       return false;
//     }
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/admission_model.dart';
import '../models/fee_challan_model.dart';

// ─────────────────────────────────────────────
//  Helper class passed around the Generate screen — one family's
//  regular-admission students bundled together for challan
//  generation.
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

// ─────────────────────────────────────────────
//  Fee Challan Provider
//  Handles: eligibility checks (student-level duplicate guard),
//  batched generation, list loading with filters, and delete.
//
//  INDEX-FREE DESIGN
//  ------------------
//  Every read in this file is scoped by `familyDocId` with a SINGLE
//  `where` clause (no compound where + orderBy on an array field).
//  Firestore auto-creates single-field indexes for every field by
//  default, so a lone `where('familyDocId', isEqualTo: ...)` never
//  needs a manual composite index — unlike `arrayContainsAny` +
//  `orderBy`, which always needs one to be created by hand in the
//  console, and needs a NEW one every time the query shape changes.
//
//  A family's own O(few-dozen) challan history is small, so all
//  "already generated this month", "prior balance", and "ever had
//  a challan" logic is resolved by fetching that one family's
//  challans ONCE and reasoning about them in Dart — no per-student
//  server-side query at all. This is also strictly fewer reads than
//  the old per-chunk arrayContainsAny approach for the normal case
//  (generating for a modest number of families at a time).
// ─────────────────────────────────────────────
class FeeChallanProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'fee_challans';
  static const String _counterDoc = 'counters/fee_challan_counter';

  // ── Generation-screen state ──
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String? _error;
  String? get error => _error;

  List<FeeChallanModel> _lastGeneratedChallans = [];
  List<FeeChallanModel> get lastGeneratedChallans => _lastGeneratedChallans;

  int _lastGenerationSkippedCount = 0;
  int get lastGenerationSkippedCount => _lastGenerationSkippedCount;

  /// studentId -> already has a challan for the currently-selected month/year
  Set<String> _alreadyGeneratedStudentIds = {};

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearResults() {
    _lastGeneratedChallans = [];
    _lastGenerationSkippedCount = 0;
    notifyListeners();
  }

  // ── "Already generated this month" lookup (index-free) ──

  /// Refresh the set of studentIds that already have a challan for
  /// [month]/[year]. Compound where on two SCALAR fields (month,
  /// year) — Firestore builds this kind of equality-only index
  /// automatically, no manual step needed. Called once when the
  /// Generate screen loads or the month/year changes.
  Future<void> refreshAlreadyGenerated(int month, int year) async {
    try {
      final snap = await _db
          .collection(_collection)
          .where('month', isEqualTo: month)
          .where('year', isEqualTo: year)
          .get();

      final ids = <String>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final studentIds = (data['studentIds'] as List<dynamic>?) ?? [];
        ids.addAll(studentIds.map((e) => e.toString()));
      }
      _alreadyGeneratedStudentIds = ids;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to check existing challans: $e';
      notifyListeners();
    }
  }

  List<AdmissionStudent> eligibleStudentsFor(FamilyForChallan family) {
    return family.students
        .where((s) => !_alreadyGeneratedStudentIds.contains(s.studentId))
        .toList();
  }

  bool isFamilyFullyGenerated(FamilyForChallan family) {
    if (family.students.isEmpty) return false;
    return family.students
        .every((s) => _alreadyGeneratedStudentIds.contains(s.studentId));
  }

  bool isFamilyPartiallyGenerated(FamilyForChallan family) {
    final anyDone =
    family.students.any((s) => _alreadyGeneratedStudentIds.contains(s.studentId));
    final anyLeft =
    family.students.any((s) => !_alreadyGeneratedStudentIds.contains(s.studentId));
    return anyDone && anyLeft;
  }

  // ── Generation ──

  Future<void> generateChallans({
    required List<FamilyForChallan> families,
    required int month,
    required int year,
    required DateTime generatedDate,
    required DateTime dueDate,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch each selected family's own challan history in parallel —
      // one simple `where('familyDocId', ...)` query per family, all
      // fired together with Future.wait. No arrayContainsAny, no
      // orderBy, no composite index ever required for this call.
      final histories = await Future.wait(
        families.map((f) => _db
            .collection(_collection)
            .where('familyDocId', isEqualTo: f.familyDocId)
            .get()),
      );

      final List<FeeChallanModel> generated = [];
      int skipped = 0;

      // Reserve a contiguous block of challan numbers up front (one
      // counter transaction) instead of one transaction per challan.
      int nextNumber = await _reserveChallanNumbers(families.length);

      final batch = _db.batch();
      final targetKey = year * 100 + month;

      for (var i = 0; i < families.length; i++) {
        final family = families[i];
        final familyDocs = histories[i].docs;

        // Reason about this family's history entirely in Dart —
        // cheap since it's at most a few dozen documents.
        final Set<String> doneThisMonth = {};
        final Set<String> everHad = {};
        final Map<String, double> priorBalance = {};
        final Map<String, DateTime> latestPriorSeen = {};

        for (final doc in familyDocs) {
          final data = doc.data();
          final docMonth = (data['month'] as num?)?.toInt() ?? 0;
          final docYear = (data['year'] as num?)?.toInt() ?? 0;
          final docKey = docYear * 100 + docMonth;
          final sids = ((data['studentIds'] as List<dynamic>?) ?? [])
              .map((e) => e.toString());

          everHad.addAll(sids);

          if (docKey == targetKey) {
            doneThisMonth.addAll(sids);
          }

          if (docKey < targetKey) {
            final createdAtTs = data['createdAt'];
            final createdAt = createdAtTs is Timestamp
                ? createdAtTs.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
            final grandTotal = (data['currentMonthTotal'] as num?)?.toDouble() ?? 0;
            final prevBal = (data['previousBalance'] as num?)?.toDouble() ?? 0;
            final amountPaid = (data['amountPaid'] as num?)?.toDouble() ?? 0;
            final remaining = (grandTotal + prevBal) - amountPaid;

            for (final sid in sids) {
              final seen = latestPriorSeen[sid];
              if (seen == null || createdAt.isAfter(seen)) {
                latestPriorSeen[sid] = createdAt;
                priorBalance[sid] = remaining;
              }
            }
          }
        }

        final eligible = family.students
            .where((s) => !doneThisMonth.contains(s.studentId))
            .toList();

        if (eligible.isEmpty) {
          skipped++;
          continue;
        }

        final lines = <ChallanStudentLine>[];
        double currentMonthTotal = 0;
        double previousBalance = 0;

        for (final s in eligible) {
          final isFirst = !everHad.contains(s.studentId);
          final line = ChallanStudentLine(
            studentId: s.studentId,
            name: s.name,
            className: s.className,
            sectionName: s.sectionName,
            monthlyFee: s.monthlyFee ?? 0,
            annualFee: isFirst ? (s.annualFee ?? 0) : 0,
            registrationFee: isFirst ? (s.registrationFee ?? 0) : 0,
            isFirstChallan: isFirst,
          );
          lines.add(line);
          currentMonthTotal += line.lineTotal;
          previousBalance += priorBalance[s.studentId] ?? 0;
        }

        final challanNumber = 'CH-${nextNumber.toString().padLeft(4, '0')}';
        nextNumber++;

        final docRef = _db.collection(_collection).doc();
        final model = FeeChallanModel(
          id: docRef.id,
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
          amountPaid: 0,
        );

        batch.set(docRef, model.toMap());
        generated.add(model);
      }

      if (generated.isNotEmpty) {
        await batch.commit();
      }

      _lastGeneratedChallans = generated;
      _lastGenerationSkippedCount = skipped;

      // Keep the in-memory guard set current without a full re-fetch.
      for (final c in generated) {
        _alreadyGeneratedStudentIds.addAll(c.studentIds);
      }
    } catch (e) {
      _error = 'Failed to generate challans: $e';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Reserve [count] sequential challan numbers in a single counter
  /// transaction instead of one transaction per challan.
  Future<int> _reserveChallanNumbers(int count) async {
    final ref = _db.doc(_counterDoc);
    return _db.runTransaction<int>((txn) async {
      final snap = await txn.get(ref);
      final current = (snap.data()?['value'] as num?)?.toInt() ?? 0;
      final start = current + 1;
      txn.set(ref, {'value': current + count}, SetOptions(merge: true));
      return start;
    });
  }

  // ── Challan List screen state ──

  bool _isLoadingList = false;
  bool get isLoadingList => _isLoadingList;

  String? _listError;
  String? get listError => _listError;

  List<FeeChallanModel> _allChallans = [];
  List<FeeChallanModel> get allChallans => _allChallans;

  /// Loads challans for the list screen. To stay index-free, this
  /// fetches by [month]/[year] equality only (auto-indexed) and
  /// sorts by generatedDate CLIENT-SIDE instead of using
  /// `.orderBy('createdAt')`, which would need a composite index
  /// combined with the where clauses above. If both month and year
  /// are null ("All"), it fetches everything and sorts client-side —
  /// fine at current data volumes; can add pagination later if the
  /// collection grows very large.
  Future<void> loadAllChallans({int? month, int? year}) async {
    _isLoadingList = true;
    _listError = null;
    notifyListeners();

    try {
      Query<Map<String, dynamic>> query = _db.collection(_collection);
      if (month != null) query = query.where('month', isEqualTo: month);
      if (year != null) query = query.where('year', isEqualTo: year);

      final snap = await query.get();
      final list = snap.docs.map((d) => FeeChallanModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
      _allChallans = list;
    } catch (e) {
      _listError = 'Failed to load challans: $e';
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChallan(FeeChallanModel challan) async {
    if (challan.id == null) return false;
    try {
      await _db.collection(_collection).doc(challan.id).delete();
      _allChallans.removeWhere((c) => c.id == challan.id);
      notifyListeners();
      return true;
    } catch (e) {
      _listError = 'Failed to delete challan: $e';
      notifyListeners();
      return false;
    }
  }
}