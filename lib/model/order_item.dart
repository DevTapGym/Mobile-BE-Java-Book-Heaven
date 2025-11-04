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
    return OrderItem(
      id: json['id'],
      quantity: int.parse(json['quantity'].toString()),
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      bookId: json['book_id'],
      bookTitle: json['book_title'] ?? '',
      bookAuthor: json['book_author'] ?? '',
      bookThumbnail: json['book_thumbnail'] ?? '',
      bookDescription: json['book_description'] ?? '',
      bookSaleOff: double.parse(json['book_sale_off'].toString()),
    );
  }
}
