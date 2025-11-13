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
    final product = json['product'] ?? {};
    final category = product['category'] ?? {};

    return CartItem(
      id: json['id'],
      bookId: product['id'],
      categoryId: category['id'] ?? 0,
      bookName: product['name'] ?? '',
      bookAuthor: product['author'] ?? '',
      bookThumbnail: product['thumbnail'] ?? '',
      unitPrice: double.tryParse(product['price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 0,
      inStock: product['quantity'] ?? 0,
      sale: 0.0, // nếu sau này backend có thêm trường giảm giá thì sửa chỗ này
      isSelected: false,
    );
  }
}
