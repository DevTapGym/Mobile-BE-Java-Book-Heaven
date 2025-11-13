import 'customer.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? role;
  final Customer? customer;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.role,
    this.phone,
    this.avatarUrl,
    this.customer,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatar'],
      role: json['role'] ?? '',
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? gender,
    Customer? customer,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      customer: customer ?? this.customer,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, phone: $phone, avatarUrl: $avatarUrl, role: $role, customer: $customer}';
  }
}
