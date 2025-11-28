class ProductType {
  final int id;
  final String name;

  ProductType({required this.id, required this.name});

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
