// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ExamResultCardTempStorage {
//   static const _prefix = 'erc_temp_';
//   static const _examNameKey = _prefix + 'examName';
//   static const _dateKey = _prefix + 'date';
//   static const _classIdKey = _prefix + 'classId';
//   static const _classNameKey = _prefix + 'className';
//   static const _sectionIdKey = _prefix + 'sectionId';
//   static const _sectionNameKey = _prefix + 'sectionName';
//   static const _subjectsKey = _prefix + 'subjects';
//
//   static Future<void> saveSettings({
//     required String examName,
//     required DateTime date,
//     required String classId,
//     required String className,
//     required String sectionId,
//     required String sectionName,
//     required List<Map<String, dynamic>> subjects,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_examNameKey, examName);
//     await prefs.setString(_dateKey, date.toIso8601String());
//     await prefs.setString(_classIdKey, classId);
//     await prefs.setString(_classNameKey, className);
//     await prefs.setString(_sectionIdKey, sectionId);
//     await prefs.setString(_sectionNameKey, sectionName);
//     await prefs.setString(_subjectsKey, jsonEncode(subjects));
//   }
//
//   static Future<Map<String, dynamic>?> loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     final examName = prefs.getString(_examNameKey);
//     if (examName == null) return null;
//     final dateStr = prefs.getString(_dateKey);
//     final classId = prefs.getString(_classIdKey) ?? '';
//     final className = prefs.getString(_classNameKey) ?? '';
//     final sectionId = prefs.getString(_sectionIdKey) ?? '';
//     final sectionName = prefs.getString(_sectionNameKey) ?? '';
//     final subjectsJson = prefs.getString(_subjectsKey);
//     List<Map<String, dynamic>> subjects = [];
//     if (subjectsJson != null) {
//       final decoded = jsonDecode(subjectsJson);
//       if (decoded is List) {
//         subjects = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
//       }
//     }
//     return {
//       'examName': examName,
//       'date': DateTime.tryParse(dateStr ?? '') ?? DateTime.now(),
//       'classId': classId,
//       'className': className,
//       'sectionId': sectionId,
//       'sectionName': sectionName,
//       'subjects': subjects,
//     };
//   }
//
//   static Future<void> clearSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_examNameKey);
//     await prefs.remove(_dateKey);
//     await prefs.remove(_classIdKey);
//     await prefs.remove(_classNameKey);
//     await prefs.remove(_sectionIdKey);
//     await prefs.remove(_sectionNameKey);
//     await prefs.remove(_subjectsKey);
//   }
// }


import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExamResultCardTempStorage {
  static const String _key = 'exam_result_draft';

  static Future<void> saveSettings({
    required String examName,
    required DateTime date,
    required String classId,
    required String className,
    required String sectionId,
    required String sectionName,
    required List<Map<String, dynamic>> subjects,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'examName': examName,
      'date': date.toIso8601String(),
      'classId': classId,
      'className': className,
      'sectionId': sectionId,
      'sectionName': sectionName,
      'subjects': subjects,
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    final Map<String, dynamic> map = jsonDecode(json);
    map['date'] = DateTime.parse(map['date'] as String);
    return map;
  }

  static Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}