import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isActive;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.isActive,
  });

  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isActive': isActive,
    };
  }

  EventModel copyWith({
    String? title,
    String? description,
    DateTime? date,
    bool? isActive,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Event ki apni assigned date guzar chuki hai ya nahi (date-only compare)
  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    return eventDay.isBefore(today);
  }
}