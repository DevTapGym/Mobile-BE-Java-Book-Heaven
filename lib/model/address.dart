class Address {
  final int id;
  final String recipientName;
  final String address;
  final String phoneNumber;
  final int isDefault;
  final int tagId;
  final String tagName;

  Address({
    required this.id,
    required this.recipientName,
    required this.address,
    required this.phoneNumber,
    required this.isDefault,
    required this.tagId,
    required this.tagName,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      recipientName: json['recipient_name'] ?? '',
      address: json['address'],
      phoneNumber: json['phone_number'],
      isDefault: json['is_default'] ?? 1,
      tagId: json['tag_id'] ?? 1,
      tagName: json['tag_name'] ?? '',
    );
  }
}
