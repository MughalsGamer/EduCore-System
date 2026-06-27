import 'package:cloud_firestore/cloud_firestore.dart';

class TimetablePeriod {
  String subject;
  String startTime;
  String endTime;
  bool isLunchBreak;

  TimetablePeriod({
    this.subject = '',
    this.startTime = '09:00',
    this.endTime = '09:45',
    this.isLunchBreak = false,
  });

  Map<String, dynamic> toMap() => {
    'subject': subject,
    'startTime': startTime,
    'endTime': endTime,
    'isLunchBreak': isLunchBreak,
  };

  factory TimetablePeriod.fromMap(Map<String, dynamic> map) => TimetablePeriod(
    subject: map['subject'] ?? '',
    startTime: map['startTime'] ?? '09:00',
    endTime: map['endTime'] ?? '09:45',
    isLunchBreak: map['isLunchBreak'] ?? false,
  );
}

class TimetableDay {
  String day;
  List<TimetablePeriod> periods;

  TimetableDay({this.day = 'Monday', List<TimetablePeriod>? periods})
      : periods = periods ?? [];

  Map<String, dynamic> toMap() => {
    'day': day,
    'periods': periods.map((p) => p.toMap()).toList(),
  };

  factory TimetableDay.fromMap(Map<String, dynamic> map) => TimetableDay(
    day: map['day'] ?? 'Monday',
    periods: (map['periods'] as List<dynamic>?)
        ?.map((p) => TimetablePeriod.fromMap(p as Map<String, dynamic>))
        .toList() ??
        [],
  );
}

class Section {
  String sectionName;
  String headOfTeacher;
  double? annualFee;
  double? registrationFee;
  double? monthlyFee;
  List<String>? subjects;       // legacy field – kept for backward compat
  List<SubjectMark>? subjectMarks;
  List<TimetableDay>? timetable;

  Section({
    this.sectionName = '',
    this.headOfTeacher = '',
    this.annualFee,
    this.registrationFee,
    this.monthlyFee,
    this.subjects,
    this.timetable,
    this.subjectMarks,
  });

  Map<String, dynamic> toMap() => {
    'sectionName': sectionName,
    'headOfTeacher': headOfTeacher,
    'annualFee': annualFee,
    'registrationFee': registrationFee,
    'monthlyFee': monthlyFee,
    'subjects': subjects,
    'timetable': timetable?.map((t) => t.toMap()).toList(),
    'subjectMarks': subjectMarks?.map((s) => s.toMap()).toList(),
  };

  factory Section.fromMap(Map<String, dynamic> map) => Section(
    sectionName: map['sectionName'] ?? '',
    headOfTeacher: map['headOfTeacher'] ?? '',
    annualFee: map['annualFee']?.toDouble(),
    registrationFee: map['registrationFee']?.toDouble(),
    monthlyFee: map['monthlyFee']?.toDouble(),
    subjects:
    map['subjects'] != null ? List<String>.from(map['subjects']) : null,
    timetable: (map['timetable'] as List<dynamic>?)
        ?.map((t) => TimetableDay.fromMap(t as Map<String, dynamic>))
        .toList(),
    subjectMarks: (map['subjectMarks'] as List<dynamic>?)
        ?.map((s) => SubjectMark.fromMap(s as Map<String, dynamic>))
        .toList(),
  );
}

class SchoolClass {
  String? id;
  String name;
  String headOfClassTeacher;
  double? annualFee;
  double? registrationFee;
  double? monthlyFee;

  // ── CHANGED: was List<String>?, now List<SubjectMark>? ──
  // Backward compat handled in fromMap/_parseSubjects below.
  List<SubjectMark>? subjects;

  List<TimetableDay>? timetable;
  List<Section> sections;

  SchoolClass({
    this.id,
    this.name = '',
    this.headOfClassTeacher = '',
    this.annualFee,
    this.registrationFee,
    this.monthlyFee,
    this.subjects,
    this.timetable,
    List<Section>? sections,
  }) : sections = sections ?? [];

  Map<String, dynamic> toMap() => {
    'name': name,
    'headOfClassTeacher': headOfClassTeacher,
    'annualFee': annualFee,
    'registrationFee': registrationFee,
    'monthlyFee': monthlyFee,
    // Serialize as list of maps (SubjectMark)
    'subjects': subjects?.map((s) => s.toMap()).toList(),
    'timetable': timetable?.map((t) => t.toMap()).toList(),
    'sections': sections.map((s) => s.toMap()).toList(),
  };

  factory SchoolClass.fromMap(Map<String, dynamic> map, String id) =>
      SchoolClass(
        id: id,
        name: map['name'] ?? '',
        headOfClassTeacher: map['headOfClassTeacher'] ?? '',
        annualFee: map['annualFee']?.toDouble(),
        registrationFee: map['registrationFee']?.toDouble(),
        monthlyFee: map['monthlyFee']?.toDouble(),
        // Backward compat: handles both old List<String> and new List<SubjectMark>
        subjects: _parseSubjects(map['subjects']),
        timetable: (map['timetable'] as List<dynamic>?)
            ?.map((t) => TimetableDay.fromMap(t as Map<String, dynamic>))
            .toList(),
        sections: (map['sections'] as List<dynamic>?)
            ?.map((s) => Section.fromMap(s as Map<String, dynamic>))
            .toList() ??
            [],
      );

  factory SchoolClass.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SchoolClass.fromMap(data, doc.id);
  }

  /// Handles Firestore data that may be:
  ///   - null
  ///   - List<String>  (old format)
  ///   - List<Map>     (new format with name + totalMarks)
  static List<SubjectMark>? _parseSubjects(dynamic raw) {
    if (raw == null) return null;
    if (raw is! List) return null;
    if (raw.isEmpty) return [];
    return raw.map((s) {
      if (s is String) {
        // Old format – default marks to 100
        return SubjectMark(name: s, totalMarks: 100);
      } else if (s is Map<String, dynamic>) {
        return SubjectMark.fromMap(s);
      }
      return SubjectMark(name: s.toString(), totalMarks: 100);
    }).toList();
  }
}

// ── Subject with marks ──
class SubjectMark {
  String name;
  int totalMarks;

  SubjectMark({required this.name, this.totalMarks = 100});

  Map<String, dynamic> toMap() => {
    'name': name,
    'totalMarks': totalMarks,
  };

  factory SubjectMark.fromMap(Map<String, dynamic> map) => SubjectMark(
    name: map['name'] ?? '',
    totalMarks: (map['totalMarks'] as num?)?.toInt() ?? 100,
  );
}