
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
//  LEDGER MODEL (per Umair)
//  -------------------------
//  A challan's `currentMonthTotal` is a PURE DEBIT entry — it only
//  records what was charged this month, student-wise. The family's
//  REAL running balance is NEVER stored/cached and is always
//  computed live by FeeCollectionProvider as:
//      balance = sum(all challans.currentMonthTotal) - sum(all collections.amount)
//  This is untouched by this file and remains fully conflict-free.
//
//  PDF DISPLAY SNAPSHOT (previousBalance)
//  ----------------------------------------
//  Purely for printing "Previous Balance" + "Net Payable" on THIS
//  challan's PDF, we ALSO capture — at the moment of generation
//  only — a frozen snapshot of what the family's live balance was
//  right before this challan's debit was added. This is stored on
//  the challan doc as `previousBalance` and never recalculated
//  afterwards, so:
//    - Re-opening/re-printing an OLD challan always shows the same
//      Previous Balance / Net Payable it showed on day one.
//    - The REAL balance (used everywhere else in the app) keeps
//      coming from the live sum-of-debits-minus-credits formula,
//      so there is no possibility of the two figures conflicting —
//      previousBalance is display-only history, never read by any
//      balance calculation.
//
//  INDEX-FREE DESIGN
//  ------------------
//  Every read in this file is scoped by a SINGLE equality `where`
//  clause (familyDocId, or month+year) — no compound where +
//  orderBy on an array field, so no manual composite index is
//  ever needed, even as the query shape evolves.
// ─────────────────────────────────────────────
class FeeChallanProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'fee_challans';
  static const String _collectionsCollection = 'fee_collections';
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

  // ★ NEW: set of ALL studentIds that have EVER had a challan (for first-challan detection)
  Set<String> _allStudentIdsWithChallans = {};

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

  // ★ NEW: Load all student IDs that appear in ANY challan (for accurate
  // first-challan detection in the preview). This is called once when
  // the Generate screen initialises.
  Future<void> loadAllStudentIdsWithChallans() async {
    try {
      final snap = await _db.collection(_collection).get();
      final ids = <String>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final studentIds = (data['studentIds'] as List<dynamic>?) ?? [];
        ids.addAll(studentIds.map((e) => e.toString()));
      }
      _allStudentIdsWithChallans = ids;
      notifyListeners();
    } catch (e) {
      // Non‑critical; the preview may just show less accurate first‑challan state.
      debugPrint('Failed to load all student IDs with challans: $e');
    }
  }

  /// Returns `true` if the student has NO previous challan anywhere.
  /// Must be called after [loadAllStudentIdsWithChallans] for accuracy.
  bool isFirstChallan(String studentId) {
    return !_allStudentIdsWithChallans.contains(studentId);
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
  //
  // Still no per-family/per-student history analysis is needed for
  // the REAL balance (it's never cached on the challan). We need
  // each family's existing studentIds (across all their past
  // challans) for two reasons now:
  //   1) "first challan" detection (annual + registration fee vs
  //      monthly-only) — unchanged from before.
  //   2) Computing the live balance snapshot (previousBalance) to
  //      freeze onto the new challan for PDF display — NEW.
  Future<void> generateChallans({
    required List<FamilyForChallan> families,
    required int month,
    required int year,
    required DateTime generatedDate,
    required DateTime dueDate,
    double? overallExtraAmount,          // ★ NEW — applied to every family below
    String overallExtraLabel = 'Extra Charge',   // ★ NEW
    Map<String, double>? familyExtraAmounts,     // ★ NEW familyDocId -> amount
    Map<String, String>? familyExtraLabels,      // ★ NEW familyDocId -> label
    bool includeAnnualFund = false,      // ★ NEW — include annual fee for all students
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final familyDocIds = families.map((f) => f.familyDocId).toList();

      const chunkSize = 30;
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> historyFutures = [];
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> collectionFutures = [];

      for (var i = 0; i < familyDocIds.length; i += chunkSize) {
        final chunk = familyDocIds.sublist(
            i, (i + chunkSize).clamp(0, familyDocIds.length));
        historyFutures.add(
          _db
              .collection(_collection)
              .where('familyDocId', whereIn: chunk)
              .get(),
        );
        collectionFutures.add(
          _db
              .collection(_collectionsCollection)
              .where('familyDocId', whereIn: chunk)
              .get(),
        );
      }

      final counterFuture = _reserveChallanNumbers(families.length);

      final List<QuerySnapshot<Map<String, dynamic>>> historySnapshots =
      await Future.wait(historyFutures);
      final List<QuerySnapshot<Map<String, dynamic>>> collectionSnapshots =
      await Future.wait(collectionFutures);

      final Map<String, List<DocumentSnapshot>> historyByFamily = {};
      for (final snap in historySnapshots) {
        for (final doc in snap.docs) {
          final fid = doc.get('familyDocId') as String;
          historyByFamily.putIfAbsent(fid, () => []).add(doc);
        }
      }

      final Map<String, double> totalCollectedByFamily = {};
      for (final snap in collectionSnapshots) {
        for (final doc in snap.docs) {
          final data = doc.data();
          final fid = data['familyDocId'] as String? ?? '';
          if (fid.isEmpty) continue;
          final amt = (data['amount'] as num?)?.toDouble() ?? 0;
          totalCollectedByFamily.update(
            fid,
                (v) => v + amt,
            ifAbsent: () => amt,
          );
        }
      }

      final int nextNumberStart = await counterFuture;
      int nextNumber = nextNumberStart;

      final List<FeeChallanModel> generated = [];
      int skipped = 0;
      final batch = _db.batch();
      final targetKey = year * 100 + month;

      for (var i = 0; i < families.length; i++) {
        final family = families[i];
        final familyDocs = historyByFamily[family.familyDocId] ?? [];

        final Set<String> doneThisMonth = {};
        final Set<String> everHad = {};

        double totalDebitSoFar = 0;

        for (final doc in familyDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final docMonth = (data['month'] as num?)?.toInt() ?? 0;
          final docYear = (data['year'] as num?)?.toInt() ?? 0;
          final docKey = docYear * 100 + docMonth;
          final sids = ((data['studentIds'] as List<dynamic>?) ?? [])
              .map((e) => e.toString());

          everHad.addAll(sids);
          if (docKey == targetKey) {
            doneThisMonth.addAll(sids);
          }

          totalDebitSoFar +=
              (data['currentMonthTotal'] as num?)?.toDouble() ?? 0;
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

        for (final s in eligible) {
          final isFirst = !everHad.contains(s.studentId) || s.rebillAnnualFeeOnce;

          // ★ NEW: include annual fee even if not first, when includeAnnualFund is true
          final includeAnnual = isFirst || includeAnnualFund;

          final line = ChallanStudentLine(
            studentId: s.studentId,
            name: s.name,
            className: s.className,
            sectionName: s.sectionName,
            monthlyFee: s.monthlyFee ?? 0,
            annualFee: includeAnnual ? (s.annualFee ?? 0) : 0,
            registrationFee: isFirst ? (s.registrationFee ?? 0) : 0,
            academyFee: s.academyFee ?? 0,
            isFirstChallan: isFirst,
          );
          lines.add(line);
          currentMonthTotal += line.lineTotal;
        }

        final extraCharges = <ChallanExtraCharge>[];

        if (overallExtraAmount != null && overallExtraAmount > 0) {
          extraCharges.add(ChallanExtraCharge(
            label: overallExtraLabel.trim().isEmpty ? 'Extra Charge' : overallExtraLabel.trim(),
            amount: overallExtraAmount,
            source: 'overall',
          ));
        }

        final familyExtra = familyExtraAmounts?[family.familyDocId];
        if (familyExtra != null && familyExtra > 0) {
          final familyLabel = familyExtraLabels?[family.familyDocId] ?? 'Extra Charge';
          extraCharges.add(ChallanExtraCharge(
            label: familyLabel.trim().isEmpty ? 'Extra Charge' : familyLabel.trim(),
            amount: familyExtra,
            source: 'family',
          ));
        }

        currentMonthTotal += extraCharges.fold(0.0, (s, e) => s + e.amount);

        final totalCreditSoFar = totalCollectedByFamily[family.familyDocId] ?? 0;
        final previousBalanceSnapshot = totalDebitSoFar - totalCreditSoFar;

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
          extraCharges: extraCharges,
          currentMonthTotal: currentMonthTotal,
          previousBalance: previousBalanceSnapshot,
        );

        batch.set(docRef, model.toMap());
        generated.add(model);
      }

      if (generated.isNotEmpty) {
        await batch.commit();
      }

      final rebilledStudentIds = <String>{};
      for (final c in generated) {
        for (final line in c.students) {
          if (line.isFirstChallan) rebilledStudentIds.add(line.studentId);
        }
      }
      if (rebilledStudentIds.isNotEmpty) {
        await _clearRebillFlags(rebilledStudentIds);
      }

      _lastGeneratedChallans = generated;
      _lastGenerationSkippedCount = skipped;

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

  Future<void> _clearRebillFlags(Set<String> studentIds) async {
    try {
      final admissionsSnap = await _db.collection('admissions').get();
      final batch = _db.batch();
      var touched = false;

      for (final doc in admissionsSnap.docs) {
        final data = doc.data();
        final students = (data['students'] as List<dynamic>?) ?? [];
        var changed = false;

        final updated = students.map((raw) {
          final s = Map<String, dynamic>.from(raw as Map);
          if (studentIds.contains(s['studentId']) &&
              s['rebillAnnualFeeOnce'] == true) {
            s['rebillAnnualFeeOnce'] = false;
            changed = true;
          }
          return s;
        }).toList();

        if (changed) {
          batch.update(doc.reference, {'students': updated});
          touched = true;
        }
      }

      if (touched) await batch.commit();
    } catch (_) {
      // Non-critical — worst case the flag clears on next admission edit.
    }
  }
}
