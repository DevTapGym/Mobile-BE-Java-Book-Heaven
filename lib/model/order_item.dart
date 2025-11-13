class OrderItem {
  final int id;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookThumbnail;
  final String? bookDescription;
  final double bookSaleOff;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookThumbnail,
    this.bookDescription,
    required this.bookSaleOff,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};

    return OrderItem(
      id: json['id'],
      quantity: int.parse(json['quantity'].toString()),
      unitPrice: double.parse(
        json['price'].toString(),
      ), // đổi unit_price -> price
      totalPrice: double.parse(
        json['totalPrice'].toString(),
      ), // đổi total_price -> totalPrice
      bookId: product['id'] ?? 0, // đổi book_id -> product.id
      bookTitle: product['name'] ?? '',
      bookAuthor: product['author'] ?? '',
      bookThumbnail: product['thumbnail'], // JSON không có ảnh
      bookDescription: '', // JSON không có mô tả
      bookSaleOff: 0, // JSON không có sale_off
    );
  }
}
