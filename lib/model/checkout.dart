class Checkout {
  final int bookId;
  final int quantity;
  final String bookTitle;
  final double unitPrice;
  final double saleOff;
  final String bookThumbnail;

  Checkout({
    required this.bookId,
    required this.quantity,
    required this.bookTitle,
    required this.unitPrice,
    required this.saleOff,
    required this.bookThumbnail,
  });
}
