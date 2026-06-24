// ─────────────────────────────────────────────────────────────
//  models/subject_model.dart
// ─────────────────────────────────────────────────────────────

class Muddul {
  final String? id;
  final String subjectName;
  final String code;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Muddul({
    this.id,
    required this.subjectName,
    required this.code,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Muddul.fromMap(Map<String, dynamic> map, String docId) {
    return Muddul(
      id: docId,
      subjectName: map['subjectName'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'code': code,
      'description': description ?? '',
    };
  }

  Muddul copyWith({
    String? id,
    String? subjectName,
    String? code,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Muddul(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      code: code ?? this.code,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}