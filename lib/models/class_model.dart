class ClassModel {
  String? id;
  String name;
  List<String> sections;
  List<String> subjects;

  ClassModel({
    this.id,
    required this.name,
    required this.sections,
    required this.subjects,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sections': sections,
      'subjects': subjects,
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    return ClassModel(
      id: id,
      name: map['name'] ?? '',
      sections: List<String>.from(map['sections'] ?? []),
      subjects: List<String>.from(map['subjects'] ?? []),
    );
  }
}