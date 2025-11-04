class CartItem {
  final int id;
  final int bookId;
  final int categoryId;
  final String bookName;
  final String bookAuthor;
  final String bookThumbnail;
  final double unitPrice;
  final double totalPrice;
  int quantity;
  final int inStock;
  final double sale;
  bool isSelected;

  CartItem({
    required this.id,
    required this.bookId,
    required this.categoryId,
    required this.bookName,
    required this.bookAuthor,
    required this.bookThumbnail,
    required this.unitPrice,
    required this.totalPrice,
    required this.quantity,
    required this.inStock,
    required this.sale,
    required this.isSelected,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      bookId: json['book_id'],
      categoryId: json['category_id'],
      bookName: json['book_name'],
      bookAuthor: json['book_author'],
      bookThumbnail: json['book_thumbnail'],
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '') ?? 0.0,
      quantity: json['quantity'],
      inStock: json['in_stock'],
      sale: double.tryParse(json['sale']?.toString() ?? '') ?? 0.0,
      isSelected: json['is_selected'] ?? false,
    );
  }
}
