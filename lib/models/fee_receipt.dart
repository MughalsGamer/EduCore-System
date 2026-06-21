class FeeReceipt {
  String? id;
  String studentId;
  String studentName;
  String className;
  double amountPaid;
  DateTime date;
  String month; // for monthly fee
  String paymentType; // cash, online

  FeeReceipt({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.amountPaid,
    required this.date,
    required this.month,
    required this.paymentType,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'amountPaid': amountPaid,
      'date': date.toIso8601String(),
      'month': month,
      'paymentType': paymentType,
    };
  }

  factory FeeReceipt.fromMap(Map<String, dynamic> map, String id) {
    return FeeReceipt(
      id: id,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      className: map['className'] ?? '',
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      month: map['month'] ?? '',
      paymentType: map['paymentType'] ?? 'cash',
    );
  }
}