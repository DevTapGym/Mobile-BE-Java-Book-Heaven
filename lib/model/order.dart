import 'package:heaven_book_app/model/order_item.dart';
import 'package:heaven_book_app/model/status_order.dart';

class Order {
  final int id;
  final String orderNumber;
  final DateTime orderDate;
  final double shippingFee;
  final double totalAmount;
  final String note;
  final String receiverName;
  final String receiverAddress;
  final String receiverPhone;
  final String paymentMethod;
  final List<OrderItem> items;
  final List<StatusOrder> statusHistory;
  final String? email;
  final int? customerId;
  final bool? isParent;
  final double? totalPromotionValue;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.shippingFee,
    required this.totalAmount,
    required this.note,
    required this.receiverName,
    required this.receiverAddress,
    required this.receiverPhone,
    required this.paymentMethod,
    required this.items,
    required this.statusHistory,
    this.email,
    this.customerId,
    this.isParent,
    this.totalPromotionValue,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['code'] ?? '', // đổi từ order_number -> code
      orderDate: DateTime.parse(
        json['createdAt'],
      ), // đổi created_at -> createdAt
      shippingFee: 0.0, // JSON không có shipping_fee
      totalAmount: double.parse(
        json['totalPrice'].toString(),
      ), // đổi total_amount -> totalPrice
      receiverName: json['receiverName'] ?? '',
      receiverAddress: json['receiverAddress'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      note: '', // JSON không có note
      items:
          (json['orderItems'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(), // đổi order_items -> orderItems
      statusHistory:
          (json['orderShippingEvents'] as List)
              .map((event) => StatusOrder.fromJson(event['shippingStatus']))
              .toList(), // đổi status_histories -> orderShippingEvents.shippingStatus
      email: json['receiverEmail'],
      customerId: json['customer']?['id'], // đổi customer_id -> customer.id
      isParent: false, // JSON không có has_return
      totalPromotionValue:
          json['totalPromotionValue'] != null
              ? double.parse(json['totalPromotionValue'].toString())
              : null,
    );
  }

  @override
  String toString() {
    return 'Order{id: $id, orderNumber: $orderNumber, orderDate: $orderDate, shippingFee: $shippingFee, totalAmount: $totalAmount, note: $note, receiverName: $receiverName, receiverAddress: $receiverAddress, receiverPhone: $receiverPhone, paymentMethod: $paymentMethod, items: $items, statusHistory: $statusHistory}';
  }
}
