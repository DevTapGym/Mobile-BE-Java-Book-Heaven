class User {
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final bool isActive;

  User({
    required this.email,
    required this.isActive,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      isActive: (json['is_active'] ?? 0) == 1,
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatar'],
      gender: json['gender'],
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'])
              : null,
    );
  }

  User copyWith({
    User? user,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? gender,
    String? dateOfBirth,
    bool? isActive,
  }) {
    final source = user ?? this;

    return User(
      name: name ?? source.name,
      email: email ?? source.email,
      phone: phone ?? source.phone,
      avatarUrl: avatarUrl ?? source.avatarUrl,
      gender: gender ?? source.gender,
      dateOfBirth:
          dateOfBirth != null
              ? DateTime.parse(dateOfBirth)
              : source.dateOfBirth,
      isActive: isActive ?? source.isActive,
    );
  }

  @override
  String toString() {
    return 'User{name: $name, email: $email, phone: $phone, avatarUrl: $avatarUrl, gender: $gender, dateOfBirth: $dateOfBirth, isActive: $isActive}';
  }
}
