class FeeStructure {
  String? id;
  String className;
  double monthlyFee;
  double examFee;
  double annualFee;

  FeeStructure({
    this.id,
    required this.className,
    required this.monthlyFee,
    required this.examFee,
    required this.annualFee,
  });

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'monthlyFee': monthlyFee,
      'examFee': examFee,
      'annualFee': annualFee,
    };
  }

  factory FeeStructure.fromMap(Map<String, dynamic> map, String id) {
    return FeeStructure(
      id: id,
      className: map['className'] ?? '',
      monthlyFee: (map['monthlyFee'] ?? 0).toDouble(),
      examFee: (map['examFee'] ?? 0).toDouble(),
      annualFee: (map['annualFee'] ?? 0).toDouble(),
    );
  }
}