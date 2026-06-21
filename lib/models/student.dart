class Student {
  String? id;
  String name;
  String fatherName;
  String className;
  String section;
  String rollNumber;
  String admissionDate;
  double annualFee;
  double uniformCharges;
  double booksCharges;
  bool isActive;

  Student({
    this.id,
    required this.name,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.rollNumber,
    required this.admissionDate,
    this.annualFee = 0,
    this.uniformCharges = 0,
    this.booksCharges = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fatherName': fatherName,
      'className': className,
      'section': section,
      'rollNumber': rollNumber,
      'admissionDate': admissionDate,
      'annualFee': annualFee,
      'uniformCharges': uniformCharges,
      'booksCharges': booksCharges,
      'isActive': isActive,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      fatherName: map['fatherName'] ?? '',
      className: map['className'] ?? '',
      section: map['section'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      admissionDate: map['admissionDate'] ?? '',
      annualFee: (map['annualFee'] ?? 0).toDouble(),
      uniformCharges: (map['uniformCharges'] ?? 0).toDouble(),
      booksCharges: (map['booksCharges'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
    );
  }
}