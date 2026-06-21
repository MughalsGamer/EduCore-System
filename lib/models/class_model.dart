class TimeTableEntry {
  String day;
  String startTime;
  String endTime;
  String subject;
  String teacher;

  TimeTableEntry({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.teacher,
  });

  Map<String, dynamic> toMap() => {
    'day': day,
    'startTime': startTime,
    'endTime': endTime,
    'subject': subject,
    'teacher': teacher,
  };

  factory TimeTableEntry.fromMap(Map<String, dynamic> map) => TimeTableEntry(
    day: map['day'] ?? '',
    startTime: map['startTime'] ?? '',
    endTime: map['endTime'] ?? '',
    subject: map['subject'] ?? '',
    teacher: map['teacher'] ?? '',
  );
}

class SectionModel {
  String name;
  String? headTeacher;
  double? monthlyFee;
  List<String> subjects;
  List<TimeTableEntry> timeTable;

  SectionModel({
    required this.name,
    this.headTeacher,
    this.monthlyFee,
    List<String>? subjects,
    List<TimeTableEntry>? timeTable,
  })  : subjects = subjects ?? [],
        timeTable = timeTable ?? [];

  Map<String, dynamic> toMap() => {
    'name': name,
    'headTeacher': headTeacher ?? '',
    'monthlyFee': monthlyFee ?? 0,
    'subjects': subjects,
    'timeTable': timeTable.map((e) => e.toMap()).toList(),
  };

  factory SectionModel.fromMap(Map<String, dynamic> map) => SectionModel(
    name: map['name'] ?? '',
    headTeacher:
    map['headTeacher']?.isNotEmpty == true ? map['headTeacher'] : null,
    monthlyFee: map['monthlyFee'] != null
        ? (map['monthlyFee'] as num).toDouble()
        : null,
    subjects: List<String>.from(map['subjects'] ?? []),
    timeTable: (map['timeTable'] as List<dynamic>?)
        ?.map((e) => TimeTableEntry.fromMap(e as Map<String, dynamic>))
        .toList() ??
        [],
  );
}

class ClassModel {
  String? id;
  String name;
  bool hasSections;
  List<SectionModel> sections;

  // Class‑level optional fields (used when hasSections == false)
  String? headTeacher;
  double? monthlyFee;
  List<String> subjects;
  List<TimeTableEntry> timeTable;

  ClassModel({
    this.id,
    required this.name,
    required this.hasSections,
    List<SectionModel>? sections,
    this.headTeacher,
    this.monthlyFee,
    List<String>? subjects,
    List<TimeTableEntry>? timeTable,
  })  : sections = sections ?? [],
        subjects = subjects ?? [],
        timeTable = timeTable ?? [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hasSections': hasSections,
      'sections': sections.map((s) => s.toMap()).toList(),
      'headTeacher': headTeacher ?? '',
      'monthlyFee': monthlyFee ?? 0,
      'subjects': subjects,
      'timeTable': timeTable.map((e) => e.toMap()).toList(),
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    return ClassModel(
      id: id,
      name: map['name'] ?? '',
      hasSections: map['hasSections'] ?? false,
      sections: (map['sections'] as List<dynamic>?)
          ?.map((s) => SectionModel.fromMap(s as Map<String, dynamic>))
          .toList() ??
          [],
      headTeacher:
      map['headTeacher']?.isNotEmpty == true ? map['headTeacher'] : null,
      monthlyFee: map['monthlyFee'] != null
          ? (map['monthlyFee'] as num).toDouble()
          : null,
      subjects: List<String>.from(map['subjects'] ?? []),
      timeTable: (map['timeTable'] as List<dynamic>?)
          ?.map((e) => TimeTableEntry.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}