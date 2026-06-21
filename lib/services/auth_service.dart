import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register new user (only admin can create users)
  Future<void> registerUser(String email, String password, String role) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'email': email,
      'role': role,
    });
  }

  // Sign in
  Future<User?> signIn(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return cred.user;
  }

  // Get role
  Future<String> getUserRole(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc['role'] ?? 'teacher';
    }
    return 'teacher';
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}