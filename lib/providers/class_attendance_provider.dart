import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/class_attendance_model.dart';

// ─────────────────────────────────────────────
//  Class Attendance Provider
//
//  PERFORMANCE DESIGN
//  -------------------
//  - Roster (which students belong to a class+section) is NEVER
//    stored here or in Firestore separately — it always comes live
//    from StudentProvider/AdmissionProvider's existing stream,
//    filtered by className+sectionName. This means promote/demote
//    is handled for free: the moment a student's className changes,
//    they vanish from the old class's roster and appear in the new
//    one on the very next build — zero migration, zero extra writes.
//  - Checking "is today already marked" is a single doc.get() by a
//    deterministic ID (classId_sectionId_date) — no query, no index,
//    no composite where clauses.
//  - Saving attendance is ONE document write for the whole class
//    (a map of studentId -> {name, status}), not one write per
//    student — this is what keeps Save feeling instant even for a
//    class of 60 kids.
// ─────────────────────────────────────────────
class ClassAttendanceProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'attendance';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  ClassAttendanceModel? _current;
  ClassAttendanceModel? get current => _current;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Loads (or initializes) attendance for a class+section+date.
  /// If no doc exists yet, builds an in-memory one defaulted to
  /// "present" for every active student passed in — this is what
  /// makes opening the page feel instant: no waiting on a second
  /// round-trip to default statuses.
  Future<void> loadForClass({
    required String classId,
    required String className,
    required String sectionId,
    required String sectionName,
    required String date,
    required List<MapEntry<String, String>> activeStudents, // studentId -> name
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docId = ClassAttendanceModel.buildDocId(classId, sectionId, date);
      final snap = await _db.collection(_collection).doc(docId).get();

      if (snap.exists) {
        _current = ClassAttendanceModel.fromFirestore(snap);
        // Merge in any NEW students not yet in the saved doc (e.g. a
        // student was admitted after this date's attendance was first
        // marked, or just promoted in) — default them to present so
        // the marker doesn't have to manually add them.
        for (final entry in activeStudents) {
          _current!.records.putIfAbsent(
            entry.key,
                () => AttendanceRecord(studentId: entry.key, name: entry.value),
          );
        }
      } else {
        _current = ClassAttendanceModel(
          classId: classId,
          className: className,
          sectionId: sectionId,
          sectionName: sectionName,
          date: date,
          records: {
            for (final entry in activeStudents)
              entry.key: AttendanceRecord(studentId: entry.key, name: entry.value),
          },
        );
      }
    } catch (e) {
      _error = 'Failed to load attendance: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatus(String studentId, AttendanceStatus status) {
    final rec = _current?.records[studentId];
    if (rec == null || _current!.locked) return;
    rec.status = status;
    notifyListeners();
  }

  void markAllPresent() {
    if (_current == null || _current!.locked) return;
    for (final r in _current!.records.values) {
      r.status = AttendanceStatus.present;
    }
    notifyListeners();
  }

  Future<bool> submit({String? markedBy}) async {
    if (_current == null) return false;
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final docId = ClassAttendanceModel.buildDocId(
        _current!.classId,
        _current!.sectionId,
        _current!.date,
      );
      _current!.locked = true;
      _current!.markedBy = markedBy;

      // Single write for the whole class — fast even for large sections.
      await _db.collection(_collection).doc(docId).set(_current!.toMap());

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _current!.locked = false; // revert optimistic lock on failure
      _error = 'Failed to save attendance: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> unlock() async {
    if (_current == null || _current!.id == null) return false;
    try {
      await _db.collection(_collection).doc(_current!.id).update({'locked': false});
      _current!.locked = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to unlock: $e';
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _current = null;
    notifyListeners();
  }
}