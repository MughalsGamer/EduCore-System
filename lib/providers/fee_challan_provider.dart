// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import '../models/admission_model.dart';
// import '../models/fee_challan_model.dart';
//
// // ─────────────────────────────────────────────
// //  Helper class passed around the Generate screen — one family's
// //  regular-admission students bundled together for challan
// //  generation.
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
// // ─────────────────────────────────────────────
// //  Fee Challan Provider
// //  Handles: eligibility checks (student-level duplicate guard),
// //  batched generation, list loading with filters, and delete.
// //
// //  INDEX-FREE DESIGN
// //  ------------------
// //  Every read in this file is scoped by `familyDocId` with a SINGLE
// //  `where` clause (no compound where + orderBy on an array field).
// //  Firestore auto-creates single-field indexes for every field by
// //  default, so a lone `where('familyDocId', isEqualTo: ...)` never
// //  needs a manual composite index — unlike `arrayContainsAny` +
// //  `orderBy`, which always needs one to be created by hand in the
// //  console, and needs a NEW one every time the query shape changes.
// //
// //  A family's own O(few-dozen) challan history is small, so all
// //  "already generated this month", "prior balance", and "ever had
// //  a challan" logic is resolved by fetching that one family's
// //  challans ONCE and reasoning about them in Dart — no per-student
// //  server-side query at all. This is also strictly fewer reads than
// //  the old per-chunk arrayContainsAny approach for the normal case
// //  (generating for a modest number of families at a time).
// // ─────────────────────────────────────────────
// class FeeChallanProvider extends ChangeNotifier {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   static const String _collection = 'fee_challans';
//   static const String _counterDoc = 'counters/fee_challan_counter';
//
//   // ── Generation-screen state ──
//   bool _isGenerating = false;
//   bool get isGenerating => _isGenerating;
//
//   String? _error;
//   String? get error => _error;
//
//   List<FeeChallanModel> _lastGeneratedChallans = [];
//   List<FeeChallanModel> get lastGeneratedChallans => _lastGeneratedChallans;
//
//   int _lastGenerationSkippedCount = 0;
//   int get lastGenerationSkippedCount => _lastGenerationSkippedCount;
//
//   /// studentId -> already has a challan for the currently-selected month/year
//   Set<String> _alreadyGeneratedStudentIds = {};
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
//   // ── "Already generated this month" lookup (index-free) ──
//
//   /// Refresh the set of studentIds that already have a challan for
//   /// [month]/[year]. Compound where on two SCALAR fields (month,
//   /// year) — Firestore builds this kind of equality-only index
//   /// automatically, no manual step needed. Called once when the
//   /// Generate screen loads or the month/year changes.
//   Future<void> refreshAlreadyGenerated(int month, int year) async {
//     try {
//       final snap = await _db
//           .collection(_collection)
//           .where('month', isEqualTo: month)
//           .where('year', isEqualTo: year)
//           .get();
//
//       final ids = <String>{};
//       for (final doc in snap.docs) {
//         final data = doc.data();
//         final studentIds = (data['studentIds'] as List<dynamic>?) ?? [];
//         ids.addAll(studentIds.map((e) => e.toString()));
//       }
//       _alreadyGeneratedStudentIds = ids;
//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to check existing challans: $e';
//       notifyListeners();
//     }
//   }
//
//   List<AdmissionStudent> eligibleStudentsFor(FamilyForChallan family) {
//     return family.students
//         .where((s) => !_alreadyGeneratedStudentIds.contains(s.studentId))
//         .toList();
//   }
//
//   bool isFamilyFullyGenerated(FamilyForChallan family) {
//     if (family.students.isEmpty) return false;
//     return family.students
//         .every((s) => _alreadyGeneratedStudentIds.contains(s.studentId));
//   }
//
//   bool isFamilyPartiallyGenerated(FamilyForChallan family) {
//     final anyDone =
//     family.students.any((s) => _alreadyGeneratedStudentIds.contains(s.studentId));
//     final anyLeft =
//     family.students.any((s) => !_alreadyGeneratedStudentIds.contains(s.studentId));
//     return anyDone && anyLeft;
//   }
//
//   // ── Generation ──
//
//   Future<void> generateChallans({
//     required List<FamilyForChallan> families,
//     required int month,
//     required int year,
//     required DateTime generatedDate,
//     required DateTime dueDate,
//   }) async {
//     _isGenerating = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       // ── 1. Fire all history queries and the counter reservation concurrently ──
//       final familyDocIds = families.map((f) => f.familyDocId).toList();
//
//       // Build the list of futures – one per chunk
//       const chunkSize = 30;
//       final List<Future<QuerySnapshot<Map<String, dynamic>>>> historyFutures = [];
//
//       for (var i = 0; i < familyDocIds.length; i += chunkSize) {
//         final chunk = familyDocIds.sublist(
//             i, (i + chunkSize).clamp(0, familyDocIds.length));
//         historyFutures.add(
//           _db
//               .collection(_collection)
//               .where('familyDocId', whereIn: chunk)
//               .get(),
//         );
//       }
//
//       // Start the counter reservation in parallel
//       final counterFuture = _reserveChallanNumbers(families.length);
//
//       // Wait for ALL history queries to complete
//       final List<QuerySnapshot<Map<String, dynamic>>> historySnapshots =
//       await Future.wait(historyFutures);
//
//       // Assemble the per-family history map (same as before)
//       final Map<String, List<DocumentSnapshot>> historyByFamily = {};
//       for (final snap in historySnapshots) {
//         for (final doc in snap.docs) {
//           final fid = doc.get('familyDocId') as String;
//           historyByFamily.putIfAbsent(fid, () => []).add(doc);
//         }
//       }
//
//       // Now also wait for the counter (it might already be done)
//       final int nextNumberStart = await counterFuture;
//       int nextNumber = nextNumberStart;
//
//       // ── 2. Process families (unchanged logic) ──
//       final List<FeeChallanModel> generated = [];
//       int skipped = 0;
//       final batch = _db.batch();
//       final targetKey = year * 100 + month;
//
//       for (var i = 0; i < families.length; i++) {
//         final family = families[i];
//         final familyDocs = historyByFamily[family.familyDocId] ?? [];
//
//         // --- Dart‑side history analysis ---
//         final Set<String> doneThisMonth = {};
//         final Set<String> everHad = {};
//         final Map<String, double> priorBalance = {};
//         final Map<String, DateTime> latestPriorSeen = {};
//
//         for (final doc in familyDocs) {
//           final data = doc.data() as Map<String, dynamic>;
//           final docMonth = (data['month'] as num?)?.toInt() ?? 0;
//           final docYear = (data['year'] as num?)?.toInt() ?? 0;
//           final docKey = docYear * 100 + docMonth;
//           final sids = ((data['studentIds'] as List<dynamic>?) ?? [])
//               .map((e) => e.toString());
//
//           everHad.addAll(sids);
//           if (docKey == targetKey) {
//             doneThisMonth.addAll(sids);
//           }
//           if (docKey < targetKey) {
//             final createdAtTs = data['createdAt'];
//             final createdAt = createdAtTs is Timestamp
//                 ? createdAtTs.toDate()
//                 : DateTime.fromMillisecondsSinceEpoch(0);
//             final grandTotal =
//                 (data['currentMonthTotal'] as num?)?.toDouble() ?? 0;
//             final prevBal =
//                 (data['previousBalance'] as num?)?.toDouble() ?? 0;
//             final amountPaid =
//                 (data['amountPaid'] as num?)?.toDouble() ?? 0;
//             final remaining = (grandTotal + prevBal) - amountPaid;
//
//             for (final sid in sids) {
//               final seen = latestPriorSeen[sid];
//               if (seen == null || createdAt.isAfter(seen)) {
//                 latestPriorSeen[sid] = createdAt;
//                 priorBalance[sid] = remaining;
//               }
//             }
//           }
//         }
//
//         final eligible = family.students
//             .where((s) => !doneThisMonth.contains(s.studentId))
//             .toList();
//         if (eligible.isEmpty) {
//           skipped++;
//           continue;
//         }
//
//         final lines = <ChallanStudentLine>[];
//         double currentMonthTotal = 0;
//         double previousBalance = 0;
//
//         for (final s in eligible) {
//           final isFirst = !everHad.contains(s.studentId);
//           final line = ChallanStudentLine(
//             studentId: s.studentId,
//             name: s.name,
//             className: s.className,
//             sectionName: s.sectionName,
//             monthlyFee: s.monthlyFee ?? 0,
//             annualFee: isFirst ? (s.annualFee ?? 0) : 0,
//             registrationFee: isFirst ? (s.registrationFee ?? 0) : 0,
//             isFirstChallan: isFirst,
//           );
//           lines.add(line);
//           currentMonthTotal += line.lineTotal;
//           previousBalance += priorBalance[s.studentId] ?? 0;
//         }
//
//         final challanNumber =
//             'CH-${nextNumber.toString().padLeft(4, '0')}';
//         nextNumber++;
//
//         final docRef = _db.collection(_collection).doc();
//         final model = FeeChallanModel(
//           id: docRef.id,
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
//           amountPaid: 0,
//         );
//
//         batch.set(docRef, model.toMap());
//         generated.add(model);
//       }
//
//       // ── 3. Commit batch and update in‑memory state ──
//       if (generated.isNotEmpty) {
//         await batch.commit();
//       }
//
//       _lastGeneratedChallans = generated;
//       _lastGenerationSkippedCount = skipped;
//
//       for (final c in generated) {
//         _alreadyGeneratedStudentIds.addAll(c.studentIds);
//       }
//     } catch (e) {
//       _error = 'Failed to generate challans: $e';
//     } finally {
//       _isGenerating = false;
//       notifyListeners();
//     }
//   }
//
//   // Future<void> generateChallans({
//   //   required List<FamilyForChallan> families,
//   //   required int month,
//   //   required int year,
//   //   required DateTime generatedDate,
//   //   required DateTime dueDate,
//   // }) async
//   // {
//   //   _isGenerating = true;
//   //   _error = null;
//   //   notifyListeners();
//   //
//   //   try {
//   //     // ── Fetch all family histories with WHERE IN (chunked into groups of 30) ──
//   //     final familyDocIds = families.map((f) => f.familyDocId).toList();
//   //     final Map<String, List<DocumentSnapshot>> historyByFamily = {};
//   //
//   //     // Chunk size 30 – Firestore's maximum for `whereIn`
//   //     const chunkSize = 30;
//   //     for (var i = 0; i < familyDocIds.length; i += chunkSize) {
//   //       final chunk = familyDocIds.sublist(i, (i + chunkSize).clamp(0, familyDocIds.length));
//   //       final snap = await _db
//   //           .collection(_collection)
//   //           .where('familyDocId', whereIn: chunk)
//   //           .get();
//   //       for (final doc in snap.docs) {
//   //         final fid = doc.get('familyDocId') as String;
//   //         historyByFamily.putIfAbsent(fid, () => []).add(doc);
//   //       }
//   //     }
//   //
//   //     final List<FeeChallanModel> generated = [];
//   //     int skipped = 0;
//   //
//   //     // Reserve contiguous challan numbers
//   //     int nextNumber = await _reserveChallanNumbers(families.length);
//   //
//   //     final batch = _db.batch();
//   //     final targetKey = year * 100 + month;
//   //
//   //     for (var i = 0; i < families.length; i++) {
//   //       final family = families[i];
//   //       final familyDocs = historyByFamily[family.familyDocId] ?? [];
//   //
//   //       // --- Dart‑side history analysis (unchanged logic) ---
//   //       final Set<String> doneThisMonth = {};
//   //       final Set<String> everHad = {};
//   //       final Map<String, double> priorBalance = {};
//   //       final Map<String, DateTime> latestPriorSeen = {};
//   //
//   //       for (final doc in familyDocs) {
//   //         final data = doc.data() as Map<String, dynamic>;
//   //         final docMonth = (data['month'] as num?)?.toInt() ?? 0;
//   //         final docYear = (data['year'] as num?)?.toInt() ?? 0;
//   //         final docKey = docYear * 100 + docMonth;
//   //         final sids = ((data['studentIds'] as List<dynamic>?) ?? [])
//   //             .map((e) => e.toString());
//   //
//   //         everHad.addAll(sids);
//   //
//   //         if (docKey == targetKey) {
//   //           doneThisMonth.addAll(sids);
//   //         }
//   //
//   //         if (docKey < targetKey) {
//   //           final createdAtTs = data['createdAt'];
//   //           final createdAt = createdAtTs is Timestamp
//   //               ? createdAtTs.toDate()
//   //               : DateTime.fromMillisecondsSinceEpoch(0);
//   //           final grandTotal = (data['currentMonthTotal'] as num?)?.toDouble() ?? 0;
//   //           final prevBal = (data['previousBalance'] as num?)?.toDouble() ?? 0;
//   //           final amountPaid = (data['amountPaid'] as num?)?.toDouble() ?? 0;
//   //           final remaining = (grandTotal + prevBal) - amountPaid;
//   //
//   //           for (final sid in sids) {
//   //             final seen = latestPriorSeen[sid];
//   //             if (seen == null || createdAt.isAfter(seen)) {
//   //               latestPriorSeen[sid] = createdAt;
//   //               priorBalance[sid] = remaining;
//   //             }
//   //           }
//   //         }
//   //       }
//   //
//   //       final eligible = family.students
//   //           .where((s) => !doneThisMonth.contains(s.studentId))
//   //           .toList();
//   //
//   //       if (eligible.isEmpty) {
//   //         skipped++;
//   //         continue;
//   //       }
//   //
//   //       final lines = <ChallanStudentLine>[];
//   //       double currentMonthTotal = 0;
//   //       double previousBalance = 0;
//   //
//   //       for (final s in eligible) {
//   //         final isFirst = !everHad.contains(s.studentId);
//   //         final line = ChallanStudentLine(
//   //           studentId: s.studentId,
//   //           name: s.name,
//   //           className: s.className,
//   //           sectionName: s.sectionName,
//   //           monthlyFee: s.monthlyFee ?? 0,
//   //           annualFee: isFirst ? (s.annualFee ?? 0) : 0,
//   //           registrationFee: isFirst ? (s.registrationFee ?? 0) : 0,
//   //           isFirstChallan: isFirst,
//   //         );
//   //         lines.add(line);
//   //         currentMonthTotal += line.lineTotal;
//   //         previousBalance += priorBalance[s.studentId] ?? 0;
//   //       }
//   //
//   //       final challanNumber = 'CH-${nextNumber.toString().padLeft(4, '0')}';
//   //       nextNumber++;
//   //
//   //       final docRef = _db.collection(_collection).doc();
//   //       final model = FeeChallanModel(
//   //         id: docRef.id,
//   //         challanNumber: challanNumber,
//   //         familyDocId: family.familyDocId,
//   //         familyId: family.familyId,
//   //         familyName: family.familyName,
//   //         fatherName: family.fatherName,
//   //         fatherPhone: family.fatherPhone,
//   //         month: month,
//   //         year: year,
//   //         generatedDate: generatedDate,
//   //         dueDate: dueDate,
//   //         students: lines,
//   //         currentMonthTotal: currentMonthTotal,
//   //         previousBalance: previousBalance,
//   //         amountPaid: 0,
//   //       );
//   //
//   //       batch.set(docRef, model.toMap());
//   //       generated.add(model);
//   //     }
//   //
//   //     if (generated.isNotEmpty) {
//   //       await batch.commit();
//   //     }
//   //
//   //     _lastGeneratedChallans = generated;
//   //     _lastGenerationSkippedCount = skipped;
//   //
//   //     // Update in‑memory guard set
//   //     for (final c in generated) {
//   //       _alreadyGeneratedStudentIds.addAll(c.studentIds);
//   //     }
//   //   } catch (e) {
//   //     _error = 'Failed to generate challans: $e';
//   //   } finally {
//   //     _isGenerating = false;
//   //     notifyListeners();
//   //   }
//   // }
//
//   /// Reserve [count] sequential challan numbers in a single counter
//   /// transaction instead of one transaction per challan.
//   Future<int> _reserveChallanNumbers(int count) async {
//     final ref = _db.doc(_counterDoc);
//     return _db.runTransaction<int>((txn) async {
//       final snap = await txn.get(ref);
//       final current = (snap.data()?['value'] as num?)?.toInt() ?? 0;
//       final start = current + 1;
//       txn.set(ref, {'value': current + count}, SetOptions(merge: true));
//       return start;
//     });
//   }
//
//   // ── Challan List screen state ──
//
//   bool _isLoadingList = false;
//   bool get isLoadingList => _isLoadingList;
//
//   String? _listError;
//   String? get listError => _listError;
//
//   List<FeeChallanModel> _allChallans = [];
//   List<FeeChallanModel> get allChallans => _allChallans;
//
//   /// Loads challans for the list screen. To stay index-free, this
//   /// fetches by [month]/[year] equality only (auto-indexed) and
//   /// sorts by generatedDate CLIENT-SIDE instead of using
//   /// `.orderBy('createdAt')`, which would need a composite index
//   /// combined with the where clauses above. If both month and year
//   /// are null ("All"), it fetches everything and sorts client-side —
//   /// fine at current data volumes; can add pagination later if the
//   /// collection grows very large.
//   Future<void> loadAllChallans({int? month, int? year}) async {
//     _isLoadingList = true;
//     _listError = null;
//     notifyListeners();
//
//     try {
//       Query<Map<String, dynamic>> query = _db.collection(_collection);
//       if (month != null) query = query.where('month', isEqualTo: month);
//       if (year != null) query = query.where('year', isEqualTo: year);
//
//       final snap = await query.get();
//       final list = snap.docs.map((d) => FeeChallanModel.fromFirestore(d)).toList();
//       list.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
//       _allChallans = list;
//     } catch (e) {
//       _listError = 'Failed to load challans: $e';
//     } finally {
//       _isLoadingList = false;
//       notifyListeners();
//     }
//   }
//
//   Future<bool> deleteChallan(FeeChallanModel challan) async {
//     if (challan.id == null) return false;
//     try {
//       await _db.collection(_collection).doc(challan.id).delete();
//       _allChallans.removeWhere((c) => c.id == challan.id);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _listError = 'Failed to delete challan: $e';
//       notifyListeners();
//       return false;
//     }
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import '../models/admission_model.dart';
// import '../models/fee_challan_model.dart';
//
// // ─────────────────────────────────────────────
// //  Helper class passed around the Generate screen — one family's
// //  regular-admission students bundled together for challan
// //  generation.
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
// // ─────────────────────────────────────────────
// //  Fee Challan Provider
// //  Handles: eligibility checks (student-level duplicate guard),
// //  batched generation, list loading with filters, and delete.
// //
// //  LEDGER MODEL (per Umair)
// //  -------------------------
// //  A challan is a PURE DEBIT entry — it only records what was
// //  charged this month, student-wise. It carries no amountPaid,
// //  no status, and no previousBalance. The family's running
// //  balance is never stored/cached on the challan; it's always
// //  computed live by FeeLedgerService as:
// //      balance = sum(all challans.currentMonthTotal) - sum(all collections.amount)
// //  This removes the entire class of bugs where a per-student
// //  prior-balance got multiplied by student count, or a cached
// //  balanceAfter drifted out of sync.
// //
// //  INDEX-FREE DESIGN
// //  ------------------
// //  Every read in this file is scoped by a SINGLE equality `where`
// //  clause (familyDocId, or month+year) — no compound where +
// //  orderBy on an array field, so no manual composite index is
// //  ever needed, even as the query shape evolves.
// // ─────────────────────────────────────────────
// class FeeChallanProvider extends ChangeNotifier {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   static const String _collection = 'fee_challans';
//   static const String _counterDoc = 'counters/fee_challan_counter';
//
//   // ── Generation-screen state ──
//   bool _isGenerating = false;
//   bool get isGenerating => _isGenerating;
//
//   String? _error;
//   String? get error => _error;
//
//   List<FeeChallanModel> _lastGeneratedChallans = [];
//   List<FeeChallanModel> get lastGeneratedChallans => _lastGeneratedChallans;
//
//   int _lastGenerationSkippedCount = 0;
//   int get lastGenerationSkippedCount => _lastGenerationSkippedCount;
//
//   /// studentId -> already has a challan for the currently-selected month/year
//   Set<String> _alreadyGeneratedStudentIds = {};
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
//   // ── "Already generated this month" lookup (index-free) ──
//
//   /// Refresh the set of studentIds that already have a challan for
//   /// [month]/[year]. Compound where on two SCALAR fields (month,
//   /// year) — Firestore builds this kind of equality-only index
//   /// automatically, no manual step needed. Called once when the
//   /// Generate screen loads or the month/year changes.
//   Future<void> refreshAlreadyGenerated(int month, int year) async {
//     try {
//       final snap = await _db
//           .collection(_collection)
//           .where('month', isEqualTo: month)
//           .where('year', isEqualTo: year)
//           .get();
//
//       final ids = <String>{};
//       for (final doc in snap.docs) {
//         final data = doc.data();
//         final studentIds = (data['studentIds'] as List<dynamic>?) ?? [];
//         ids.addAll(studentIds.map((e) => e.toString()));
//       }
//       _alreadyGeneratedStudentIds = ids;
//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to check existing challans: $e';
//       notifyListeners();
//     }
//   }
//
//   List<AdmissionStudent> eligibleStudentsFor(FamilyForChallan family) {
//     return family.students
//         .where((s) => !_alreadyGeneratedStudentIds.contains(s.studentId))
//         .toList();
//   }
//
//   bool isFamilyFullyGenerated(FamilyForChallan family) {
//     if (family.students.isEmpty) return false;
//     return family.students
//         .every((s) => _alreadyGeneratedStudentIds.contains(s.studentId));
//   }
//
//   bool isFamilyPartiallyGenerated(FamilyForChallan family) {
//     final anyDone =
//     family.students.any((s) => _alreadyGeneratedStudentIds.contains(s.studentId));
//     final anyLeft =
//     family.students.any((s) => !_alreadyGeneratedStudentIds.contains(s.studentId));
//     return anyDone && anyLeft;
//   }
//
//   // ── Generation ──
//   //
//   // Much simpler now: no per-family/per-student history analysis for
//   // "prior balance" is needed at all, since balance is never cached
//   // on the challan. We only still need each family's existing
//   // studentIds (across all their past challans) to know whether a
//   // student's line is their "first challan" (annual + registration
//   // fee included) or a repeat (monthly only) — that IS legitimately
//   // per-student and per-family, unlike balance.
//   Future<void> generateChallans({
//     required List<FamilyForChallan> families,
//     required int month,
//     required int year,
//     required DateTime generatedDate,
//     required DateTime dueDate,
//   }) async {
//     _isGenerating = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final familyDocIds = families.map((f) => f.familyDocId).toList();
//
//       const chunkSize = 30;
//       final List<Future<QuerySnapshot<Map<String, dynamic>>>> historyFutures = [];
//
//       for (var i = 0; i < familyDocIds.length; i += chunkSize) {
//         final chunk = familyDocIds.sublist(
//             i, (i + chunkSize).clamp(0, familyDocIds.length));
//         historyFutures.add(
//           _db
//               .collection(_collection)
//               .where('familyDocId', whereIn: chunk)
//               .get(),
//         );
//       }
//
//       final counterFuture = _reserveChallanNumbers(families.length);
//
//       final List<QuerySnapshot<Map<String, dynamic>>> historySnapshots =
//       await Future.wait(historyFutures);
//
//       final Map<String, List<DocumentSnapshot>> historyByFamily = {};
//       for (final snap in historySnapshots) {
//         for (final doc in snap.docs) {
//           final fid = doc.get('familyDocId') as String;
//           historyByFamily.putIfAbsent(fid, () => []).add(doc);
//         }
//       }
//
//       final int nextNumberStart = await counterFuture;
//       int nextNumber = nextNumberStart;
//
//       final List<FeeChallanModel> generated = [];
//       int skipped = 0;
//       final batch = _db.batch();
//       final targetKey = year * 100 + month;
//
//       for (var i = 0; i < families.length; i++) {
//         final family = families[i];
//         final familyDocs = historyByFamily[family.familyDocId] ?? [];
//
//         final Set<String> doneThisMonth = {};
//         final Set<String> everHad = {}; // used only for first-challan detection
//
//         for (final doc in familyDocs) {
//           final data = doc.data() as Map<String, dynamic>;
//           final docMonth = (data['month'] as num?)?.toInt() ?? 0;
//           final docYear = (data['year'] as num?)?.toInt() ?? 0;
//           final docKey = docYear * 100 + docMonth;
//           final sids = ((data['studentIds'] as List<dynamic>?) ?? [])
//               .map((e) => e.toString());
//
//           everHad.addAll(sids);
//           if (docKey == targetKey) {
//             doneThisMonth.addAll(sids);
//           }
//         }
//
//         final eligible = family.students
//             .where((s) => !doneThisMonth.contains(s.studentId))
//             .toList();
//         if (eligible.isEmpty) {
//           skipped++;
//           continue;
//         }
//
//         final lines = <ChallanStudentLine>[];
//         double currentMonthTotal = 0;
//
//         for (final s in eligible) {
//           final isFirst = !everHad.contains(s.studentId);
//           final line = ChallanStudentLine(
//             studentId: s.studentId,
//             name: s.name,
//             className: s.className,
//             sectionName: s.sectionName,
//             monthlyFee: s.monthlyFee ?? 0,
//             annualFee: isFirst ? (s.annualFee ?? 0) : 0,
//             registrationFee: isFirst ? (s.registrationFee ?? 0) : 0,
//             isFirstChallan: isFirst,
//           );
//           lines.add(line);
//           currentMonthTotal += line.lineTotal;
//         }
//
//         final challanNumber = 'CH-${nextNumber.toString().padLeft(4, '0')}';
//         nextNumber++;
//
//         final docRef = _db.collection(_collection).doc();
//         final model = FeeChallanModel(
//           id: docRef.id,
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
//         );
//
//         batch.set(docRef, model.toMap());
//         generated.add(model);
//       }
//
//       if (generated.isNotEmpty) {
//         await batch.commit();
//       }
//
//       _lastGeneratedChallans = generated;
//       _lastGenerationSkippedCount = skipped;
//
//       for (final c in generated) {
//         _alreadyGeneratedStudentIds.addAll(c.studentIds);
//       }
//     } catch (e) {
//       _error = 'Failed to generate challans: $e';
//     } finally {
//       _isGenerating = false;
//       notifyListeners();
//     }
//   }
//
//   /// Reserve [count] sequential challan numbers in a single counter
//   /// transaction instead of one transaction per challan.
//   Future<int> _reserveChallanNumbers(int count) async {
//     final ref = _db.doc(_counterDoc);
//     return _db.runTransaction<int>((txn) async {
//       final snap = await txn.get(ref);
//       final current = (snap.data()?['value'] as num?)?.toInt() ?? 0;
//       final start = current + 1;
//       txn.set(ref, {'value': current + count}, SetOptions(merge: true));
//       return start;
//     });
//   }
//
//   // ── Challan List screen state ──
//
//   bool _isLoadingList = false;
//   bool get isLoadingList => _isLoadingList;
//
//   String? _listError;
//   String? get listError => _listError;
//
//   List<FeeChallanModel> _allChallans = [];
//   List<FeeChallanModel> get allChallans => _allChallans;
//
//   /// Loads challans for the list screen. To stay index-free, this
//   /// fetches by [month]/[year] equality only (auto-indexed) and
//   /// sorts by generatedDate CLIENT-SIDE instead of using
//   /// `.orderBy('createdAt')`, which would need a composite index
//   /// combined with the where clauses above.
//   Future<void> loadAllChallans({int? month, int? year}) async {
//     _isLoadingList = true;
//     _listError = null;
//     notifyListeners();
//
//     try {
//       Query<Map<String, dynamic>> query = _db.collection(_collection);
//       if (month != null) query = query.where('month', isEqualTo: month);
//       if (year != null) query = query.where('year', isEqualTo: year);
//
//       final snap = await query.get();
//       final list = snap.docs.map((d) => FeeChallanModel.fromFirestore(d)).toList();
//       list.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
//       _allChallans = list;
//     } catch (e) {
//       _listError = 'Failed to load challans: $e';
//     } finally {
//       _isLoadingList = false;
//       notifyListeners();
//     }
//   }
//
//   Future<bool> deleteChallan(FeeChallanModel challan) async {
//     if (challan.id == null) return false;
//     try {
//       await _db.collection(_collection).doc(challan.id).delete();
//       _allChallans.removeWhere((c) => c.id == challan.id);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _listError = 'Failed to delete challan: $e';
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
        // Fetch each family's past collections (credits) in the same
        // chunked, index-free pattern as challan history, so we can
        // compute each family's live balance-before-this-challan.
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

      // familyDocId -> sum of all past collection amounts (credits so far)
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
        final Set<String> everHad = {}; // used only for first-challan detection

        // Sum of currentMonthTotal across ALL of this family's past
        // challans — this is the "total debit so far" needed for the
        // previousBalance snapshot (balance BEFORE this new challan).
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
        }

        // Live balance BEFORE this new challan's debit is added —
        // exactly what FeeCollectionProvider.loadBalanceForFamily
        // would return right now for this family. Frozen onto the
        // challan purely for PDF display; the real balance calc
        // elsewhere never reads this value back.
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
          currentMonthTotal: currentMonthTotal,
          previousBalance: previousBalanceSnapshot,
        );

        batch.set(docRef, model.toMap());
        generated.add(model);
      }

      if (generated.isNotEmpty) {
        await batch.commit();
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

  /// Loads challans for the list screen. To stay index-free, this
  /// fetches by [month]/[year] equality only (auto-indexed) and
  /// sorts by generatedDate CLIENT-SIDE instead of using
  /// `.orderBy('createdAt')`, which would need a composite index
  /// combined with the where clauses above.
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