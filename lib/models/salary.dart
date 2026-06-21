class Salary {
  String? id;
  String teacherId;
  String teacherName;
  double amount;
  DateTime date;
  String month;

  Salary({
    this.id,
    required this.teacherId,
    required this.teacherName,
    required this.amount,
    required this.date,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'amount': amount,
      'date': date.toIso8601String(),
      'month': month,
    };
  }

  factory Salary.fromMap(Map<String, dynamic> map, String id) {
    return Salary(
      id: id,
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      month: map['month'] ?? '',
    );
  }
}