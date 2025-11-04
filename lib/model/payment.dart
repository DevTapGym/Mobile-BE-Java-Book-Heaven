class Payment {
  final int id;
  final String name;
  final int isActive;
  final String provider;
  final String type;
  final String? imageUrl;

  Payment({
    required this.id,
    required this.name,
    required this.isActive,
    required this.provider,
    required this.type,
    required this.imageUrl,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'] ?? 1,
      provider: json['provider'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['logo_url'] ?? '',
    );
  }
}
