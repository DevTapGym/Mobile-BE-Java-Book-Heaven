class ReturnOrderItem {
  final int? bookId;
  final int? quantity;
  final int? orderItemId;

  ReturnOrderItem({this.bookId, this.quantity, this.orderItemId});

  Map<String, dynamic> toJson() {
    return {'bookId': bookId, 'quantity': quantity, 'orderItemId': orderItemId};
  }
}
