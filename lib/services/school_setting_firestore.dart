import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/school_setting_model.dart';

// ============================================================
// SCHOOL SETTINGS FIRESTORE SERVICE
// Collection: school_settings   Doc id: 'main'
// Kept as its own top-level collection (not nested under any other
// module) so any screen in the app can fetch it directly and cheaply,
// e.g. context.read<SchoolSettingsProvider>() or a one-off fetch,
// without touching students/staff/attendance data.
// ============================================================
class SchoolSettingsFirestoreService {
  final CollectionReference<Map<String, dynamic>> _collection =
  FirebaseFirestore.instance.collection('school_settings');

  static const String _docId = 'main';

  /// One-time fetch.
  Future<SchoolSettings?> fetchSettings() async {
    final snap = await _collection.doc(_docId).get();
    if (!snap.exists || snap.data() == null) return null;
    return SchoolSettings.fromMap(snap.data()!);
  }

  /// Live stream — useful if other screens want to react instantly
  /// to settings changes (e.g. currency symbol, school name in headers).
  Stream<SchoolSettings?> watchSettings() {
    return _collection.doc(_docId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return SchoolSettings.fromMap(snap.data()!);
    });
  }

  Future<void> saveSettings(SchoolSettings settings) async {
    await _collection.doc(_docId).set(settings.toMap(), SetOptions(merge: true));
  }
}