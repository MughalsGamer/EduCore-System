
import 'package:cloud_firestore/cloud_firestore.dart';

class FeeChallanModel {
  String? id;
  String challanNumber;      // e.g. CH-0001

  // ── Ledger-common fields ──
  static const String ledgerType = 'debit';
  String familyDocId;        // Firestore doc id of the family (families collection)
  String familyId;           // Human-readable, e.g. KHA-0001
  String familyName;
  String fatherName;
  String fatherPhone;
  double get amount => currentMonthTotal; // ledger "debit amount" for this entry
  DateTime get date => generatedDate;      // ledger date

  int month;                 // 1-12, billing month (not necessarily == generatedDate.month)
  int year;

  DateTime generatedDate;    // When this challan was actually generated/printed
  DateTime dueDate;          // Last date to pay

  List<ChallanStudentLine> students;
  List<ChallanExtraCharge> extraCharges;   // ★ NEW


  double currentMonthTotal;  // sum of all student lineTotal for this challan (pure debit, unchanged)

  /// FROZEN SNAPSHOT of the family's live balance at the moment this
  /// challan was generated (BEFORE this challan's own debit was
  /// added). Used only for PDF display. Never read by any balance
  /// calculation — those always stay live via FeeCollectionProvider.
  double previousBalance;

  /// FROZEN SNAPSHOT = previousBalance + currentMonthTotal, computed
  /// once at generation time. This is what prints as "Net Payable"
  /// on the PDF for this specific challan, forever, regardless of
  /// what happens to the family's account afterwards.
  double get netPayableSnapshot => previousBalance + currentMonthTotal;

  DateTime createdAt;

  FeeChallanModel({
    this.id,
    this.challanNumber = '',
    this.familyDocId = '',
    this.familyId = '',
    this.familyName = '',
    this.fatherName = '',
    this.fatherPhone = '',
    required this.month,
    required this.year,
    required this.generatedDate,
    required this.dueDate,
    List<ChallanStudentLine>? students,
    List<ChallanExtraCharge>? extraCharges,   // ★ NEW

    this.currentMonthTotal = 0,
    this.previousBalance = 0,
    DateTime? createdAt,
  })  : students = students ?? [],
        extraCharges = extraCharges ?? [],     // ★ NEW

      createdAt = createdAt ?? DateTime.now();

  double get extraChargesTotal =>
      extraCharges.fold(0.0, (s, e) => s + e.amount);   // ★ NEW helper
  List<String> get studentIds => students.map((s) => s.studentId).toList();

  Map<String, dynamic> toMap() => {
    'challanNumber': challanNumber,
    'ledgerType': ledgerType,
    'familyDocId': familyDocId,
    'familyId': familyId,
    'familyName': familyName,
    'fatherName': fatherName,
    'fatherPhone': fatherPhone,
    'month': month,
    'year': year,
    'generatedDate': generatedDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'students': students.map((s) => s.toMap()).toList(),
    'extraCharges': extraCharges.map((e) => e.toMap()).toList(),   // ★ NEW

    'studentIds': studentIds,
    'currentMonthTotal': currentMonthTotal,
    'previousBalance': previousBalance,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory FeeChallanModel.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return FeeChallanModel(
      id: doc.id,
      challanNumber: m['challanNumber'] ?? '',
      familyDocId: m['familyDocId'] ?? '',
      familyId: m['familyId'] ?? '',
      familyName: m['familyName'] ?? '',
      fatherName: m['fatherName'] ?? '',
      fatherPhone: m['fatherPhone'] ?? '',
      month: (m['month'] as num?)?.toInt() ?? 1,
      year: (m['year'] as num?)?.toInt() ?? DateTime.now().year,
      generatedDate: m['generatedDate'] != null
          ? DateTime.tryParse(m['generatedDate']) ?? DateTime.now()
          : DateTime.now(),
      dueDate: m['dueDate'] != null
          ? DateTime.tryParse(m['dueDate']) ?? DateTime.now()
          : DateTime.now(),
      students: (m['students'] as List<dynamic>?)
          ?.map((s) => ChallanStudentLine.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList() ??
          [],
      extraCharges: (m['extraCharges'] as List<dynamic>?)               // ★ NEW
          ?.map((e) => ChallanExtraCharge.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList() ??
          [],
      currentMonthTotal: (m['currentMonthTotal'] as num?)?.toDouble() ?? 0,
      previousBalance: (m['previousBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  static const List<String> monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String get monthLabel => (month >= 1 && month <= 12) ? monthNames[month] : '—';
}



class ChallanStudentLine {
  String studentId;
  String name;
  String? className;
  String? sectionName;
  double monthlyFee;
  double annualFee;        // > 0 only when isFirstChallan == true
  double registrationFee;  // > 0 only when isFirstChallan == true (Admission Fee)
  double academyFee;       // repeats every challan, like monthlyFee
  bool isFirstChallan;

  ChallanStudentLine({
    required this.studentId,
    required this.name,
    this.className,
    this.sectionName,
    this.monthlyFee = 0,
    this.annualFee = 0,
    this.registrationFee = 0,
    this.academyFee = 0,
    this.isFirstChallan = false,
  });

  double get lineTotal => monthlyFee + annualFee + registrationFee + academyFee;

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'name': name,
    'className': className,
    'sectionName': sectionName,
    'monthlyFee': monthlyFee,
    'annualFee': annualFee,
    'registrationFee': registrationFee,
    'academyFee': academyFee,
    'isFirstChallan': isFirstChallan,
  };

  factory ChallanStudentLine.fromMap(Map<String, dynamic> m) => ChallanStudentLine(
    studentId: m['studentId'] ?? '',
    name: m['name'] ?? '',
    className: m['className'],
    sectionName: m['sectionName'],
    monthlyFee: (m['monthlyFee'] as num?)?.toDouble() ?? 0,
    annualFee: (m['annualFee'] as num?)?.toDouble() ?? 0,
    registrationFee: (m['registrationFee'] as num?)?.toDouble() ?? 0,
    academyFee: (m['academyFee'] as num?)?.toDouble() ?? 0,
    isFirstChallan: m['isFirstChallan'] ?? false,
  );
}



// ─────────────────────────────────────────────
//  Extra Charge — optional ad-hoc debit line added on top of the
//  regular fee breakdown. Can come from "Overall" (same label +
//  amount applied to every selected family) and/or "Family-wise"
//  (a specific amount + label entered just for that one family).
//  Both can co-exist on the same challan — their amounts are
//  simply summed and both lines are kept for transparency.
// ─────────────────────────────────────────────
class ChallanExtraCharge {
  String label;   // default "Extra Charge", user-editable
  double amount;
  String source;  // 'overall' | 'family'

  ChallanExtraCharge({
    this.label = 'Extra Charge',
    required this.amount,
    required this.source,
  });

  Map<String, dynamic> toMap() => {
    'label': label,
    'amount': amount,
    'source': source,
  };

  factory ChallanExtraCharge.fromMap(Map<String, dynamic> m) => ChallanExtraCharge(
    label: m['label'] ?? 'Extra Charge',
    amount: (m['amount'] as num?)?.toDouble() ?? 0,
    source: m['source'] ?? 'family',
  );
}