


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/admission_model.dart';
import '../models/fee_collection_model.dart';

// ─────────────────────────────────────────────
//  Lightweight row used to populate the search list.
//  Built once from AdmissionProvider's already-loaded
//  `admissions` list (no extra Firestore read), so
//  search stays instant / no network round-trip per
//  keystroke.
// ─────────────────────────────────────────────
class FamilyForCollection {
  final String familyDocId;
  final String familyId;
  final String familyName;
  final String fatherName;
  final String fatherPhone;
  final String? firstStudentPicBase64;
  final int studentCount;

  FamilyForCollection({
    required this.familyDocId,
    required this.familyId,
    required this.familyName,
    required this.fatherName,
    required this.fatherPhone,
    required this.firstStudentPicBase64,
    required this.studentCount,
  });
}

// ─────────────────────────────────────────────
//  A single merged ledger row for a family: either a debit
//  (fee_challans doc) or credit (fee_collections doc), with a
//  running balance computed once entries are sorted oldest→newest.
// ─────────────────────────────────────────────
class FamilyLedgerEntry {
  final String id;
  final String type; // 'debit' | 'credit'
  final double amount;
  final DateTime date;
  final String description;
  final String? note;
  double runningBalance;

  FamilyLedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.note,
    this.runningBalance = 0,
  });
}

// ─────────────────────────────────────────────
//  Fee Collection Provider
//
//  LEDGER MODEL (per Umair)
//  -------------------------
//  - fee_challans   = DEBIT entries  (student-wise detail, currentMonthTotal)
//  - fee_collections = CREDIT entries (just an amount)
//  - balance = sum(all challans.currentMonthTotal) - sum(all collections.amount)
//
//  This is always computed LIVE, never cached/stored anywhere. Both
//  reads are single-equality-where on familyDocId (auto-indexed, no
//  composite index needed) and, at the realistic scale of one
//  family's own history (a few dozen documents at most), this is
//  fast and — crucially — free of the drift/duplication bugs that a
//  cached running balance can accumulate.
// ─────────────────────────────────────────────
class FeeCollectionProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _challansCollection = 'fee_challans';
  static const String _collectionsCollection = 'fee_collections';
  static const String _counterDoc = 'counters/fee_collection_counter';

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Balance lookup (per selected family) ──
  bool _isLoadingBalance = false;
  bool get isLoadingBalance => _isLoadingBalance;

  double _currentBalance = 0;
  double get currentBalance => _currentBalance;

  /// Live balance = sum(challans.currentMonthTotal) - sum(collections.amount)
  /// for this family. Both queries are simple single-field equality
  /// filters on familyDocId, run in parallel.
  Future<void> loadBalanceForFamily(String familyDocId) async {
    _isLoadingBalance = true;
    _currentBalance = 0;
    notifyListeners();

    try {
      final results = await Future.wait([
        _db
            .collection(_challansCollection)
            .where('familyDocId', isEqualTo: familyDocId)
            .get(),
        _db
            .collection(_collectionsCollection)
            .where('familyDocId', isEqualTo: familyDocId)
            .get(),
      ]);

      final challanSnap = results[0];
      final collectionSnap = results[1];

      double totalDebit = 0;
      for (final doc in challanSnap.docs) {
        final data = doc.data();
        totalDebit += (data['currentMonthTotal'] as num?)?.toDouble() ?? 0;
      }

      double totalCredit = 0;
      for (final doc in collectionSnap.docs) {
        final data = doc.data();
        totalCredit += (data['amount'] as num?)?.toDouble() ?? 0;
      }

      _currentBalance = totalDebit - totalCredit;
    } catch (e) {
      _error = 'Failed to load balance: $e';
    } finally {
      _isLoadingBalance = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _currentBalance = 0;
    notifyListeners();
  }

  // ── Save a payment (pure credit entry) ──
  //
  // No challan document is touched at all. The payment is simply
  // recorded as its own credit entry; the next time anyone loads
  // this family's balance (here, or on the next challan-generation
  // screen), it's naturally reflected because the live sum includes
  // it.
  Future<bool> collectFee({
    required FamilyForCollection family,
    required double amount,
    required DateTime paymentDate,
    required String paymentMethod,
    String? note,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final receiptNumber = await _reserveReceiptNumber();

      final collRef = _db.collection(_collectionsCollection).doc();
      final collection = FeeCollectionModel(
        id: collRef.id,
        receiptNumber: receiptNumber,
        familyDocId: family.familyDocId,
        familyId: family.familyId,
        familyName: family.familyName,
        fatherName: family.fatherName,
        fatherPhone: family.fatherPhone,
        amount: amount,
        paymentMethod: paymentMethod,
        note: note,
        paymentDate: paymentDate,
      );

      await collRef.set(collection.toMap());

      _currentBalance -= amount;

      // Keep the in-memory history list fresh immediately, instead of
      // waiting for a full reload — same pattern used elsewhere in
      // EduCore (patch local list right after a Firestore write).
      _allHistory.insert(0, collection);
      _applyHistoryFilter();

      return true;
    } catch (e) {
      _error = 'Failed to save payment: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String> _reserveReceiptNumber() async {
    final ref = _db.doc(_counterDoc);
    final next = await _db.runTransaction<int>((txn) async {
      final snap = await txn.get(ref);
      final current = (snap.data()?['value'] as num?)?.toInt() ?? 0;
      final n = current + 1;
      txn.set(ref, {'value': n}, SetOptions(merge: true));
      return n;
    });
    return 'RCT-${next.toString().padLeft(4, '0')}';
  }

  // ── Build the searchable family list from admissions already
  //    loaded in AdmissionProvider — no extra Firestore read. ──
  static List<FamilyForCollection> buildFamilyList(
      List<AdmissionModel> admissions) {
    final regular =
    admissions.where((a) => a.type == AdmissionType.regular).toList();

    final Map<String, List<AdmissionModel>> grouped = {};
    for (final a in regular) {
      if (a.familyDocId.isEmpty) continue;
      grouped.putIfAbsent(a.familyDocId, () => []).add(a);
    }

    final List<FamilyForCollection> result = [];
    grouped.forEach((familyDocId, admissionsForFamily) {
      final rep = admissionsForFamily.first;
      final students =
      admissionsForFamily.expand((a) => a.students).toList();
      if (students.isEmpty) return;

      String? firstPic;
      for (final s in students) {
        if (s.picBase64 != null && s.picBase64!.isNotEmpty) {
          firstPic = s.picBase64;
          break;
        }
      }

      result.add(FamilyForCollection(
        familyDocId: familyDocId,
        familyId: rep.familyId,
        familyName:
        rep.familyName.isNotEmpty ? rep.familyName : rep.fatherName,
        fatherName: rep.fatherName,
        fatherPhone: rep.fatherPhone,
        firstStudentPicBase64: firstPic,
        studentCount: students.length,
      ));
    });

    result.sort((a, b) =>
        a.familyName.toLowerCase().compareTo(b.familyName.toLowerCase()));
    return result;
  }

  // ═════════════════════════════════════════════════════════
  //  FAMILY LEDGER (single family: challans=debit + collections=credit,
  //  merged chronologically with a running balance, like the
  //  EmployeeLedgerScreen pattern).
  // ═════════════════════════════════════════════════════════

  bool _isLoadingLedger = false;
  bool get isLoadingLedger => _isLoadingLedger;

  List<FamilyLedgerEntry> _ledgerEntries = [];
  List<FamilyLedgerEntry> get ledgerEntries => _ledgerEntries;

  double _ledgerBalance = 0;
  double get ledgerBalance => _ledgerBalance;

  double get ledgerTotalDebit => _ledgerEntries
      .where((e) => e.type == 'debit')
      .fold(0.0, (s, e) => s + e.amount);

  double get ledgerTotalCredit => _ledgerEntries
      .where((e) => e.type == 'credit')
      .fold(0.0, (s, e) => s + e.amount);

  /// Loads a single family's complete ledger: every fee_challans doc
  /// (debit) + every fee_collections doc (credit) for that family,
  /// merged and sorted oldest → newest, with a running balance
  /// computed left-to-right (matches EmployeeLedgerScreen's approach).
  Future<void> loadFamilyLedger(String familyDocId) async {
    _isLoadingLedger = true;
    _ledgerEntries = [];
    _ledgerBalance = 0;
    notifyListeners();

    try {
      final results = await Future.wait([
        _db
            .collection(_challansCollection)
            .where('familyDocId', isEqualTo: familyDocId)
            .get(),
        _db
            .collection(_collectionsCollection)
            .where('familyDocId', isEqualTo: familyDocId)
            .get(),
      ]);

      final challanSnap = results[0];
      final collectionSnap = results[1];

      final List<FamilyLedgerEntry> entries = [];

      for (final doc in challanSnap.docs) {
        final data = doc.data();
        final amount = (data['currentMonthTotal'] as num?)?.toDouble() ?? 0;
        final dateStr = data['generatedDate'] ?? data['createdDate'] ?? data['month'];
        DateTime date;
        if (dateStr is String) {
          date = DateTime.tryParse(dateStr) ?? DateTime.now();
        } else if (data['createdAt'] is Timestamp) {
          date = (data['createdAt'] as Timestamp).toDate();
        } else {
          date = DateTime.now();
        }
        entries.add(FamilyLedgerEntry(
          id: doc.id,
          type: 'debit',
          amount: amount,
          date: date,
          description: data['month'] != null
              ? 'Challan - ${data['month']}'
              : 'Fee Challan',
          note: null,
        ));
      }

      for (final doc in collectionSnap.docs) {
        final c = FeeCollectionModel.fromFirestore(doc);
        entries.add(FamilyLedgerEntry(
          id: doc.id,
          type: 'credit',
          amount: c.amount,
          date: c.paymentDate,
          description: 'Payment (${c.paymentMethod}) - ${c.receiptNumber}',
          note: c.note,
        ));
      }

      // Oldest → newest, matching EmployeeLedgerScreen's convention.
      entries.sort((a, b) => a.date.compareTo(b.date));

      double running = 0;
      for (final e in entries) {
        running += e.type == 'debit' ? e.amount : -e.amount;
        e.runningBalance = running;
      }

      _ledgerEntries = entries;
      _ledgerBalance = running;
    } catch (e) {
      _error = 'Failed to load ledger: $e';
    } finally {
      _isLoadingLedger = false;
      notifyListeners();
    }
  }

  void clearLedger() {
    _ledgerEntries = [];
    _ledgerBalance = 0;
    notifyListeners();
  }

  // ═════════════════════════════════════════════════════════
  //  FEE COLLECTION HISTORY (list / search / filter / delete)
  // ═════════════════════════════════════════════════════════

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  List<FeeCollectionModel> _allHistory = [];
  List<FeeCollectionModel> _filteredHistory = [];
  List<FeeCollectionModel> get history => _filteredHistory;

  String _historyQuery = '';
  String get historyQuery => _historyQuery;

  String _historyMethodFilter = 'All'; // All / Cash / Bank / Online
  String get historyMethodFilter => _historyMethodFilter;

  DateTimeRange? _historyDateRange;
  DateTimeRange? get historyDateRange => _historyDateRange;

  double get historyTotal =>
      _filteredHistory.fold(0.0, (sum, c) => sum + c.amount);

  /// Loads ALL fee_collections documents, newest first.
  /// Uses a plain `.get()` + client-side sort (per established
  /// EduCore pattern: Firestore orderBy silently drops docs missing
  /// the sort field, so this is safer than a server-side orderBy).
  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final snap = await _db.collection(_collectionsCollection).get();
      final list =
      snap.docs.map((d) => FeeCollectionModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      _allHistory = list;
      _applyHistoryFilter();
    } catch (e) {
      _error = 'Failed to load history: $e';
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  void setHistorySearch(String query) {
    _historyQuery = query;
    _applyHistoryFilter();
    notifyListeners();
  }

  void setHistoryMethodFilter(String method) {
    _historyMethodFilter = method;
    _applyHistoryFilter();
    notifyListeners();
  }

  void setHistoryDateRange(DateTimeRange? range) {
    _historyDateRange = range;
    _applyHistoryFilter();
    notifyListeners();
  }

  void clearHistoryFilters() {
    _historyQuery = '';
    _historyMethodFilter = 'All';
    _historyDateRange = null;
    _applyHistoryFilter();
    notifyListeners();
  }

  void _applyHistoryFilter() {
    final q = _historyQuery.trim().toLowerCase();
    _filteredHistory = _allHistory.where((c) {
      final matchesQuery = q.isEmpty ||
          c.familyName.toLowerCase().contains(q) ||
          c.fatherName.toLowerCase().contains(q) ||
          c.familyId.toLowerCase().contains(q) ||
          c.fatherPhone.contains(q) ||
          c.receiptNumber.toLowerCase().contains(q);

      final matchesMethod = _historyMethodFilter == 'All' ||
          c.paymentMethod == _historyMethodFilter;

      final matchesDate = _historyDateRange == null ||
          (!c.paymentDate.isBefore(_historyDateRange!.start) &&
              !c.paymentDate
                  .isAfter(_historyDateRange!.end.add(const Duration(days: 1))));

      return matchesQuery && matchesMethod && matchesDate;
    }).toList();
  }

  /// Deletes a single collection (payment) both locally and from
  /// Firestore. Returns true on success.
  Future<bool> deleteCollection(String docId) async {
    _isDeleting = true;
    _error = null;
    notifyListeners();

    try {
      await _db.collection(_collectionsCollection).doc(docId).delete();

      _allHistory.removeWhere((c) => c.id == docId);
      _applyHistoryFilter();

      return true;
    } catch (e) {
      _error = 'Failed to delete: $e';
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}