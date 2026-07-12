// ============================================================
// SCHOOL SETTINGS MODEL
// Firestore path: school_settings/main   (single document, separate
// top-level collection so this data can be fetched independently
// from anywhere in the app without pulling in unrelated data).
// ============================================================
class SchoolSettings {
  final String schoolName;
  final String email;
  final String phone;
  final String city;
  final String country;
  final String address;
  final String sessionYear;
  final String currency;
  final String timezone;
  final double finederDay; // fine per day (late fee etc.)
  final String? logoBase64;
  final DateTime? updatedAt;

  const SchoolSettings({
    this.schoolName = '',
    this.email = '',
    this.phone = '',
    this.city = '',
    this.country = '',
    this.address = '',
    this.sessionYear = '',
    this.currency = 'PKR',
    this.timezone = 'Asia/Karachi',
    this.finederDay = 0,
    this.logoBase64,
    this.updatedAt,
  });

  SchoolSettings copyWith({
    String? schoolName,
    String? email,
    String? phone,
    String? city,
    String? country,
    String? address,
    String? sessionYear,
    String? currency,
    String? timezone,
    double? fineperDay,
    String? logoBase64,
    DateTime? updatedAt,
  }) {
    return SchoolSettings(
      schoolName: schoolName ?? this.schoolName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      country: country ?? this.country,
      address: address ?? this.address,
      sessionYear: sessionYear ?? this.sessionYear,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      finederDay: fineperDay ?? finederDay,
      logoBase64: logoBase64 ?? this.logoBase64,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolName': schoolName,
      'email': email,
      'phone': phone,
      'city': city,
      'country': country,
      'address': address,
      'sessionYear': sessionYear,
      'currency': currency,
      'timezone': timezone,
      'fineperDay': finederDay,
      'logoBase64': logoBase64,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory SchoolSettings.fromMap(Map<String, dynamic> map) {
    return SchoolSettings(
      schoolName: (map['schoolName'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      country: (map['country'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      sessionYear: (map['sessionYear'] ?? '').toString(),
      currency: (map['currency'] ?? 'PKR').toString(),
      timezone: (map['timezone'] ?? 'Asia/Karachi').toString(),
      finederDay: (map['fineperDay'] is num)
          ? (map['fineperDay'] as num).toDouble()
          : double.tryParse('${map['fineperDay'] ?? 0}') ?? 0,
      logoBase64: map['logoBase64'] as String?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }
}