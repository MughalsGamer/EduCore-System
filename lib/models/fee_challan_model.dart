import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
//  Per-Student Line Item inside a Challan
//  First-ever challan for a student carries
//  Admission (registration) + Annual + Monthly.
//  Every challan after that carries Monthly only.
// ─────────────────────────────────────────────
class ChallanStudentLine {
  String studentId;
  String name;
  String? className;
  String? sectionName;
  double monthlyFee;
  double annualFee;        // > 0 only when isFirstChallan == true
  double registrationFee;  // > 0 only when isFirstChallan == true (Admission Fee)
  bool isFirstChallan;

  ChallanStudentLine({
    required this.studentId,
    required this.name,
    this.className,
    this.sectionName,
    this.monthlyFee = 0,
    this.annualFee = 0,
    this.registrationFee = 0,
    this.isFirstChallan = false,
  });

  double get lineTotal => monthlyFee + annualFee + registrationFee;

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'name': name,
    'className': className,
    'sectionName': sectionName,
    'monthlyFee': monthlyFee,
    'annualFee': annualFee,
    'registrationFee': registrationFee,
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
    isFirstChallan: m['isFirstChallan'] ?? false,
  );
}

// ─────────────────────────────────────────────
//  Fee Challan — one document per family, per billing month.
//
//  There is intentionally NO separate "ledger" collection.
//  Per the original scenario design, the ledger is a runtime
//  view that combines these challans (Debit) with fee_collections
//  (Credit, once that payment screen is built). This challan
//  document IS the debit-side ledger entry.
// ─────────────────────────────────────────────
class FeeChallanModel {
  String? id;
  String challanNumber;      // e.g. CH-0001

  String familyDocId;        // Firestore doc id of the family (families collection)
  String familyId;           // Human-readable, e.g. KHA-0001
  String familyName;
  String fatherName;
  String fatherPhone;

  int month;                 // 1-12, billing month (not necessarily == generatedDate.month)
  int year;

  DateTime generatedDate;    // When this challan was actually generated/printed
  DateTime dueDate;          // Last date to pay

  List<ChallanStudentLine> students;

  double currentMonthTotal;  // sum of all student lineTotal for this challan
  double previousBalance;    // running balance carried from earlier challans
  double amountPaid;         // 0 until a payment/collection screen updates it

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
    this.currentMonthTotal = 0,
    this.previousBalance = 0,
    this.amountPaid = 0,
    DateTime? createdAt,
  })  : students = students ?? [],
        createdAt = createdAt ?? DateTime.now();

  double get grandTotal => currentMonthTotal + previousBalance;
  double get remainingBalance => grandTotal - amountPaid;

  /// negative previousBalance handling is automatic here — if a future
  /// payment screen ever pays MORE than grandTotal, remainingBalance goes
  /// negative and the NEXT challan's previousBalance will pick that up as
  /// an advance credit, exactly like the original scenario doc describes.
  String get status {
    if (amountPaid <= 0) return 'pending';
    if (amountPaid >= grandTotal) return 'paid';
    return 'partial';
  }

  List<String> get studentIds => students.map((s) => s.studentId).toList();

  Map<String, dynamic> toMap() => {
    'challanNumber': challanNumber,
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
    'studentIds': studentIds,
    'currentMonthTotal': currentMonthTotal,
    'previousBalance': previousBalance,
    'amountPaid': amountPaid,
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
      currentMonthTotal: (m['currentMonthTotal'] as num?)?.toDouble() ?? 0,
      previousBalance: (m['previousBalance'] as num?)?.toDouble() ?? 0,
      amountPaid: (m['amountPaid'] as num?)?.toDouble() ?? 0,
    );
  }

  static const List<String> monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String get monthLabel => (month >= 1 && month <= 12) ? monthNames[month] : '—';
}