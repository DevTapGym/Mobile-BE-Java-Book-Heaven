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
      totalItems: json['count'],
      totalPrice: double.tryParse(json['sumPrice']?.toString() ?? '0') ?? 0.0,
      items:
          (json['cartItems'] as List<dynamic>)
              .map((item) => CartItem.fromJson(item))
              .toList(),
    );
  }
}
