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
        ?.map((p) =>
        TimetablePeriod.fromMap(p as Map<String, dynamic>))
        .toList() ??
        [],
  );
}

class Section {
  String sectionName;
  String headOfTeacher;
  double? monthlyFee;
  List<String>? subjects;
  List<TimetableDay>? timetable;

  Section({
    this.sectionName = '',
    this.headOfTeacher = '',
    this.monthlyFee,
    this.subjects,
    this.timetable,
  });

  Map<String, dynamic> toMap() => {
    'sectionName': sectionName,
    'headOfTeacher': headOfTeacher,
    'monthlyFee': monthlyFee,
    'subjects': subjects,
    'timetable': timetable?.map((t) => t.toMap()).toList(),
  };

  factory Section.fromMap(Map<String, dynamic> map) => Section(
    sectionName: map['sectionName'] ?? '',
    headOfTeacher: map['headOfTeacher'] ?? '',
    monthlyFee: map['monthlyFee']?.toDouble(),
    subjects:
    map['subjects'] != null ? List<String>.from(map['subjects']) : null,
    timetable: (map['timetable'] as List<dynamic>?)
        ?.map((t) => TimetableDay.fromMap(t as Map<String, dynamic>))
        .toList(),
  );
}

class SchoolClass {
  String? id;
  String name;
  String headOfClassTeacher;
  double? monthlyFee;
  List<String>? subjects;
  List<TimetableDay>? timetable;
  List<Section> sections;

  SchoolClass({
    this.id,
    this.name = '',
    this.headOfClassTeacher = '',
    this.monthlyFee,
    this.subjects,
    this.timetable,
    List<Section>? sections,
  }) : sections = sections ?? [];

  Map<String, dynamic> toMap() => {
    'name': name,
    'headOfClassTeacher': headOfClassTeacher,
    'monthlyFee': monthlyFee,
    'subjects': subjects,
    'timetable': timetable?.map((t) => t.toMap()).toList(),
    'sections': sections.map((s) => s.toMap()).toList(),
  };

  factory SchoolClass.fromMap(Map<String, dynamic> map, String id) =>
      SchoolClass(
        id: id,
        name: map['name'] ?? '',
        headOfClassTeacher: map['headOfClassTeacher'] ?? '',
        monthlyFee: map['monthlyFee']?.toDouble(),
        subjects:
        map['subjects'] != null ? List<String>.from(map['subjects']) : null,
        timetable: (map['timetable'] as List<dynamic>?)
            ?.map((t) => TimetableDay.fromMap(t as Map<String, dynamic>))
            .toList(),
        sections: (map['sections'] as List<dynamic>?)
            ?.map((s) => Section.fromMap(s as Map<String, dynamic>))
            .toList() ??
            [],
      );

  // Firebase Document ke liye additional factory
  factory SchoolClass.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SchoolClass.fromMap(data, doc.id);
  }
}