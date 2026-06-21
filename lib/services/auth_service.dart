import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register user with auto-role based on current user count.
  /// First user → admin, second → accountant, third+ → teacher.
  /// The [selectedRole] parameter is ignored for the first two users.
  Future<void> registerUser(String email, String password, String selectedRole) async {
    // Count existing users in Firestore 'users' collection
    final usersSnapshot = await _firestore.collection('users').get();
    final userCount = usersSnapshot.docs.length;

    // Determine actual role
    String assignedRole;
    if (userCount == 0) {
      assignedRole = 'admin';
    } else if (userCount == 1) {
      assignedRole = 'accountant';
    } else {
      assignedRole = selectedRole; // from third user onward, accept chosen role
    }

    // Create user in Firebase Auth
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save user profile to Firestore
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'email': email,
      'role': assignedRole,
    });
  }

  Future<User?> signIn(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<String> getUserRole(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc['role'] ?? 'teacher';
    }
    return 'teacher';
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}