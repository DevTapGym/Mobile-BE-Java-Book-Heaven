import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/order/order_event.dart';
import 'package:heaven_book_app/bloc/order/order_state.dart';
import 'package:heaven_book_app/interceptors/app_session.dart';
import 'package:heaven_book_app/services/order_service.dart';
import 'package:heaven_book_app/services/cart_service.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderService _orderService;
  final CartService _cartService;

  OrderBloc(this._orderService, this._cartService) : super(OrderInitial()) {
    on<LoadAllOrders>(_onLoadAllOrders);
    on<PlaceOrder>(_onPlaceOrder);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<CreateReturnOrder>(_onReturnOrder);
  }

  Future<void> _onReturnOrder(
    CreateReturnOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final success = await _orderService.returnOrder(
        returnOrder: event.returnOrder,
      );
      if (success) {
        final orders = await _orderService.loadAllOrder();
        emit(
          OrderLoaded(
            orders: orders,
            message: 'Return order created successfully',
          ),
        );
      } else {
        emit(OrderError('Failed to create return order'));
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final success = await _orderService.updateOrderStatus(
        orderId: event.orderId,
        statusId: event.statusId,
        note: event.note,
      );
      if (success) {
        final orders = await _orderService.loadAllOrderByCustomer(
          AppSession().currentUser!.id,
        );
        emit(OrderLoaded(orders: orders, message: 'Đơn hàng đã được cập nhật'));
      } else {
        emit(OrderError('Cập nhật đơn hàng thất bại'));
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final success = await _orderService.createOrder(
        customerId: event.customerId,
        paymentMethod: event.paymentMethod,
        phone: event.phone,
        address: event.address,
        name: event.name,
        items: event.items,
        promotionId: event.promotionId,
        email: AppSession().currentUser!.email,
      );
      if (success) {
        // Xóa các sản phẩm đã đặt hàng khỏi giỏ hàng
        for (var item in event.items) {
          try {
            final cartItemId = item['cartItemId'] as int?;
            if (cartItemId != null) {
              await _cartService.removeCartItem(cartItemId);
            }
          } catch (e) {
            // Log lỗi nhưng không làm gián đoạn flow
            debugPrint('Error removing cart item: $e');
          }
        }

        final orders = await _orderService.loadAllOrderByCustomer(
          AppSession().currentUser!.id,
        );
        emit(
          OrderLoaded(orders: orders, message: 'Đơn hàng đã đặt thành công'),
        );
      } else {
        emit(OrderError('Đặt hàng thất bại'));
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final success = await _orderService.placeOrder(
        event.note ?? '',
        event.paymentMethod,
        event.cartId,
        event.phone,
        event.address,
        event.name,
        event.promotionId,
      );
      if (success) {
        final orders = await _orderService.loadAllOrder();
        emit(OrderLoaded(orders: orders, message: 'Order placed successfully'));
      } else {
        emit(OrderError('Failed to place order'));
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onLoadAllOrders(
    LoadAllOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      //final orders = await _orderService.loadAllOrder();
      final orders = await _orderService.loadAllOrderByCustomer(
        AppSession().currentUser!.id,
      );
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
