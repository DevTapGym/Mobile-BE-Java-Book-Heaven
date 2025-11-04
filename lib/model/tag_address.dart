class TagAddress {
  final int id;
  final String name;

  TagAddress({required this.id, required this.name});

  factory TagAddress.fromJson(Map<String, dynamic> json) {
    return TagAddress(id: json['id'], name: json['name']);
  }
}
