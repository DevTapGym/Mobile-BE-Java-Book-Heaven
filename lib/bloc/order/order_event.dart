import 'package:equatable/equatable.dart';
import 'package:heaven_book_app/model/return_order.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllOrders extends OrderEvent {}

class CreateReturnOrder extends OrderEvent {
  final ReturnOrder returnOrder;
  final int customerId;

  CreateReturnOrder({required this.returnOrder, required this.customerId});

  @override
  List<Object?> get props => [returnOrder];
}

class UpdateOrderStatus extends OrderEvent {
  final int orderId;
  final int statusId;
  final String note;

  UpdateOrderStatus({
    required this.orderId,
    required this.statusId,
    required this.note,
  });

  @override
  List<Object?> get props => [orderId, statusId, note];
}

class CreateOrder extends OrderEvent {
  final String note;
  final String paymentMethod;
  final String phone;
  final String address;
  final String name;
  final List<Map<String, dynamic>> items;

  CreateOrder({
    required this.note,
    required this.paymentMethod,
    required this.phone,
    required this.address,
    required this.name,
    required this.items,
  });

  @override
  List<Object?> get props => [note, paymentMethod, phone, address, name, items];
}

class PlaceOrder extends OrderEvent {
  final String? note;
  final String paymentMethod;
  final int cartId;
  final String phone;
  final String address;
  final String name;
  final int? promotionId;

  PlaceOrder({
    this.note,
    required this.paymentMethod,
    required this.cartId,
    required this.phone,
    required this.address,
    required this.name,
    this.promotionId,
  });

  @override
  List<Object?> get props => [
    note,
    paymentMethod,
    cartId,
    phone,
    address,
    name,
  ];
}

class LoadDetailOrder extends OrderEvent {
  final int orderId;

  LoadDetailOrder({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
