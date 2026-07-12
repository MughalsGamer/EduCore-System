// ============================================================
// APP USER MODEL
// Firestore path: users/{uid}
// Represents any registered account in the system (admin,
// accountant, teacher, etc.) — used by the School Settings →
// "Registered Users" list for viewing/editing name, role,
// password, and active/deactivated status.
// ============================================================
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String password; // plain text, stored the same way as email/role
  final String role; // admin | accountant | teacher | ...
  final bool isActive;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    this.name = '',
    this.email = '',
    this.password = '',
    this.role = 'teacher',
    this.isActive = true,
    this.createdAt,
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? password,
    String? role,
    bool? isActive,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'isActive': isActive,
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      password: (map['password'] ?? '').toString(),
      role: (map['role'] ?? 'teacher').toString(),
      isActive: map['isActive'] is bool ? map['isActive'] as bool : true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }
}