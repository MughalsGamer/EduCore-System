import 'package:cloud_firestore/cloud_firestore.dart';

// ---- TimeTableEntry (unchanged) ----
class TimeTableEntry {
  String day;
  String startTime;
  String endTime;
  String subject;
  String teacher;
  bool isLunch;

  TimeTableEntry({
    required this.day,
    required this.startTime,
    required this.endTime,
    this.subject = '',
    this.teacher = '',
    this.isLunch = false,
  });

  Map<String, dynamic> toMap() => {
    'day': day,
    'startTime': startTime,
    'endTime': endTime,
    'subject': subject,
    'teacher': teacher,
    'isLunch': isLunch,
  };

  factory TimeTableEntry.fromMap(Map<String, dynamic> map) => TimeTableEntry(
    day: map['day'] ?? '',
    startTime: map['startTime'] ?? '',
    endTime: map['endTime'] ?? '',
    subject: map['subject'] ?? '',
    teacher: map['teacher'] ?? '',
    isLunch: map['isLunch'] ?? false,
  );
}

// ---- SectionModel (now also holds its own document ID) ----
class SectionModel {
  String? id; // Firestore document ID (optional for new sections)
  String name;
  String? headTeacher;
  double? monthlyFee;
  List<String> subjects;
  List<TimeTableEntry> timeTable;

  SectionModel({
    this.id,
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

  factory SectionModel.fromMap(Map<String, dynamic> map, {String? id}) =>
      SectionModel(
        id: id,
        name: map['name'] ?? '',
        headTeacher: map['headTeacher']?.isNotEmpty == true
            ? map['headTeacher']
            : null,
        monthlyFee: (map['monthlyFee'] as num?)?.toDouble(),
        subjects: List<String>.from(map['subjects'] ?? []),
        timeTable: (map['timeTable'] as List<dynamic>?)
            ?.map((e) => TimeTableEntry.fromMap(e as Map<String, dynamic>))
            .toList() ??
            [],
      );
}

// ---- ClassModel (main document) ----
class ClassModel {
  String? id;
  String name;
  bool hasSections;
  // These are only used when hasSections == false
  String? headTeacher;
  double? monthlyFee;
  List<String> subjects;
  List<TimeTableEntry> timeTable;
  // Sections are NOT stored as a list here – they are subcollections.
  // We keep a local list for UI state, but it's not persisted in the main doc.
  List<SectionModel> sections; // only for UI, saved separately

  ClassModel({
    this.id,
    required this.name,
    required this.hasSections,
    this.headTeacher,
    this.monthlyFee,
    List<String>? subjects,
    List<TimeTableEntry>? timeTable,
    List<SectionModel>? sections,
  })  : subjects = subjects ?? [],
        timeTable = timeTable ?? [],
        sections = sections ?? [];

  // Map for the main document (does not include sections)
  Map<String, dynamic> toMap() => {
    'name': name,
    'hasSections': hasSections,
    'headTeacher': headTeacher ?? '',
    'monthlyFee': monthlyFee ?? 0,
    'subjects': subjects,
    'timeTable': timeTable.map((e) => e.toMap()).toList(),
  };

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) =>
      ClassModel(
        id: id,
        name: map['name'] ?? '',
        hasSections: map['hasSections'] ?? false,
        headTeacher: map['headTeacher']?.isNotEmpty == true
            ? map['headTeacher']
            : null,
        monthlyFee: (map['monthlyFee'] as num?)?.toDouble(),
        subjects: List<String>.from(map['subjects'] ?? []),
        timeTable: (map['timeTable'] as List<dynamic>?)
            ?.map((e) => TimeTableEntry.fromMap(e as Map<String, dynamic>))
            .toList() ??
            [],
        // sections are loaded separately from subcollection
        sections: [],
      );
}