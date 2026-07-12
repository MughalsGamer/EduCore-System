import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user_Model.dart';

// ============================================================
// APP USER FIRESTORE SERVICE
// Collection: users   (same collection AuthService.registerUser
// already writes to — this just reads/edits it for the
// School Settings → Registered Users panel).
// ============================================================
class AppUserFirestoreService {
  final CollectionReference<Map<String, dynamic>> _collection =
  FirebaseFirestore.instance.collection('users');

  /// Live list of all registered users, newest first when createdAt exists.
  Stream<List<AppUser>> watchUsers() {
    return _collection.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => AppUser.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ac = a.createdAt;
        final bc = b.createdAt;
        if (ac == null && bc == null) return 0;
        if (ac == null) return 1;
        if (bc == null) return -1;
        return bc.compareTo(ac);
      });
      return list;
    });
  }

  Future<List<AppUser>> fetchUsers() async {
    final snap = await _collection.get();
    return snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();
  }

  /// Updates name / role / password / isActive for a user.
  /// Note: this only updates the Firestore profile document. It does NOT
  /// change the user's Firebase Auth password — if the password value is
  /// changed here, keep in mind actual sign-in still uses the Auth
  /// password. Syncing Auth passwords requires an admin SDK / callable
  /// function since the client SDK can't change another user's password.
  Future<void> updateUser(AppUser user) async {
    await _collection.doc(user.uid).update(user.toMap());
  }

  Future<void> setActive(String uid, bool isActive) async {
    await _collection.doc(uid).update({'isActive': isActive});
  }
}