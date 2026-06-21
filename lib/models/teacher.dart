class Teacher {
  String? id;
  String name;
  String email;
  String phone;
  String subject;
  String assignedClass;
  double salary;

  Teacher({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subject,
    required this.assignedClass,
    required this.salary,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'assignedClass': assignedClass,
      'salary': salary,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map, String id) {
    return Teacher(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      subject: map['subject'] ?? '',
      assignedClass: map['assignedClass'] ?? '',
      salary: (map['salary'] ?? 0).toDouble(),
    );
  }
}