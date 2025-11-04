import 'package:heaven_book_app/model/return_order_item.dart';

class ReturnOrder {
  final int id;
  final String? receiverName;
  final String? receiverAddress;
  final String? receiverPhone;
  final String? email;
  final String? paymentMethod;
  final int? customerId;
  final int? promotionId;
  final double? totalPrice;
  final String? orderType;
  final double? totalPromotionValue;
  final int? statusId;
  final double? returnFee;
  final String? returnFeeType;
  final List<ReturnOrderItem>? orderItems;

  ReturnOrder({
    required this.id,
    this.receiverName,
    this.email,
    this.receiverAddress,
    this.receiverPhone,
    this.paymentMethod,
    this.customerId,
    this.promotionId,
    this.totalPrice,
    this.orderType,
    this.totalPromotionValue,
    this.statusId,
    this.returnFee,
    this.returnFeeType,
    this.orderItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverName': receiverName,
      'email': email,
      'receiverAddress': receiverAddress,
      'receiverPhone': receiverPhone,
      'paymentMethod': paymentMethod,
      'customerId': customerId,
      'promotionId': promotionId,
      'totalPrice': totalPrice,
      'orderType': orderType,
      'totalPromotionValue': totalPromotionValue,
      'statusId': statusId,
      'returnFee': returnFee,
      'returnFeeType': returnFeeType,
      'orderItems': orderItems?.map((e) => e.toJson()).toList(),
    };
  }
}
