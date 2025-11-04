import 'cart_item.dart';

class Cart {
  final int id;
  final int totalItems;
  final double totalPrice;
  final List<CartItem> items;

  Cart({
    required this.id,
    required this.totalItems,
    required this.totalPrice,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      totalItems: json['total_items'],
      totalPrice: double.parse(json['total_price'].toString()),
      items:
          (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
    );
  }

  Cart copyWith({
    int? id,
    int? totalItems,
    double? totalPrice,
    List<CartItem>? items,
  }) {
    return Cart(
      id: id ?? this.id,
      totalItems: totalItems ?? this.totalItems,
      totalPrice: totalPrice ?? this.totalPrice,
      items: items ?? this.items,
    );
  }
}
