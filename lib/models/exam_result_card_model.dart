class ExamSubject {
  String name;
  int totalMarks;

  ExamSubject({required this.name, this.totalMarks = 100});

  Map<String, dynamic> toMap() => {'name': name, 'totalMarks': totalMarks};

  factory ExamSubject.fromMap(Map<String, dynamic> map) => ExamSubject(
    name: map['name'] ?? '',
    totalMarks: (map['totalMarks'] as num?)?.toInt() ?? 100,
  );
}

class StudentExamMarks {
  String studentId;
  String studentName;
  Map<String, double> obtainedMarks; // subjectName -> marks

  StudentExamMarks({
    required this.studentId,
    required this.studentName,
    Map<String, double>? obtainedMarks,
  }) : obtainedMarks = obtainedMarks ?? {};

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'studentName': studentName,
    'obtainedMarks': obtainedMarks,
  };

  factory StudentExamMarks.fromMap(Map<String, dynamic> map) => StudentExamMarks(
    studentId: map['studentId'] ?? '',
    studentName: map['studentName'] ?? '',
    obtainedMarks: (map['obtainedMarks'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
        {},
  );
}

class ExamResultCard {
  String? id;
  String examName;
  DateTime date;
  String classId;
  String className;
  String sectionId;
  String sectionName;
  List<ExamSubject> subjects;
  List<StudentExamMarks> studentMarks;
  DateTime? createdAt;
  DateTime? updatedAt;

  ExamResultCard({
    this.id,
    required this.examName,
    required this.date,
    required this.classId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
    required this.subjects,
    required this.studentMarks,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'examName': examName,
    'date': date.toIso8601String(),
    'classId': classId,
    'className': className,
    'sectionId': sectionId,
    'sectionName': sectionName,
    'subjects': subjects.map((s) => s.toMap()).toList(),
    'studentMarks': studentMarks.map((s) => s.toMap()).toList(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory ExamResultCard.fromMap(Map<String, dynamic> map, String id) => ExamResultCard(
    id: id,
    examName: map['examName'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    classId: map['classId'] ?? '',
    className: map['className'] ?? '',
    sectionId: map['sectionId'] ?? '',
    sectionName: map['sectionName'] ?? '',
    subjects: (map['subjects'] as List<dynamic>?)
        ?.map((s) => ExamSubject.fromMap(s as Map<String, dynamic>))
        .toList() ??
        [],
    studentMarks: (map['studentMarks'] as List<dynamic>?)
        ?.map((s) => StudentExamMarks.fromMap(s as Map<String, dynamic>))
        .toList() ??
        [],
    createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
    updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
  );

  ExamResultCard copyWith({
    String? examName,
    DateTime? date,
    String? classId,
    String? className,
    String? sectionId,
    String? sectionName,
    List<ExamSubject>? subjects,
    List<StudentExamMarks>? studentMarks,
  }) {
    return ExamResultCard(
      id: id,
      examName: examName ?? this.examName,
      date: date ?? this.date,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      sectionId: sectionId ?? this.sectionId,
      sectionName: sectionName ?? this.sectionName,
      subjects: subjects ?? this.subjects,
      studentMarks: studentMarks ?? this.studentMarks,
    );
  }

}




