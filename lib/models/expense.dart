class Expense {
  String? id;
  String category; // Salary, Utility, Maintenance, Stationery, Miscellaneous
  String description;
  double amount;
  DateTime date;

  Expense({
    this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      category: map['category'] ?? 'Miscellaneous',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}