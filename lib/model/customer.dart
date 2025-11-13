class Customer {
  final int id;
  final String? name;
  final String? address;
  final String? phone;
  final String? email;
  final DateTime? birthday;
  final String? gender;
  final DateTime? createdAt;
  final bool isOauthUser;

  Customer({
    required this.id,
    this.name,
    this.address,
    this.phone,
    this.email,
    this.birthday,
    this.gender,
    this.createdAt,
    required this.isOauthUser,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      gender: json['gender'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      isOauthUser: json['isOauthUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'birthday': birthday?.toIso8601String(),
      'gender': gender,
      'createdAt': createdAt?.toIso8601String(),
      'isOauthUser': isOauthUser,
    };
  }

  @override
  String toString() {
    return 'Customer{id: $id, name: $name, address: $address, phone: $phone, email: $email, birthday: $birthday, gender: $gender, createdAt: $createdAt, isOauthUser: $isOauthUser}';
  }
}
