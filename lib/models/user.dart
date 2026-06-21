class AppUser {
  final String uid;
  final String email;
  final String role; // admin, accountant, teacher

  AppUser({required this.uid, required this.email, required this.role});

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'teacher',
    );
  }
}