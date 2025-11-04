import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:heaven_book_app/model/order.dart';
import 'package:heaven_book_app/model/return_order.dart';
import 'package:heaven_book_app/services/api_client.dart';

class OrderService {
  final ApiClient apiClient;
  OrderService(this.apiClient);

  Future<bool> returnOrder({required ReturnOrder returnOrder}) async {
    try {
      final response = await apiClient.privateDio.post(
        '/order/return/${returnOrder.id}',
        data: returnOrder.toJson(),
      );

      if (response.statusCode == 201) {
        debugPrint('✅ Return order created successfully');
        return true;
      } else {
        debugPrint('❌ Failed to create return order: ${response.data}');
        throw Exception(
          'Failed to create return order: ${response.data['message']}',
        );
      }
    } on DioException catch (dioError) {
      debugPrint('❌ DioException: ${dioError.message}');

      if (dioError.response != null) {
        debugPrint('Status code: ${dioError.response?.statusCode}');
        debugPrint('Data: ${dioError.response?.data}');
        debugPrint('Headers: ${dioError.response?.headers}');
      }
      throw Exception('Lỗi khi tạo đơn hàng: ${dioError.message}');
    } catch (e) {
      debugPrint('🚨 Error creating return order: $e');
      throw Exception('Error creating return order: $e');
    }
  }

  Future<bool> updateOrderStatus({
    required int orderId,
    required int statusId,
    required String note,
  }) async {
    try {
      final response = await apiClient.privateDio.put(
        '/order',
        data: {'id': orderId, 'statusId': statusId, 'note': note},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Order status updated successfully');
        return true;
      } else {
        throw Exception(
          'Failed to update order status: ${response.data['message']}',
        );
      }
    } on DioException catch (dioError) {
      debugPrint('❌ DioException khi cập nhật trạng thái: ${dioError.message}');

      if (dioError.response != null) {
        debugPrint('Status code: ${dioError.response?.statusCode}');
        debugPrint('Data: ${dioError.response?.data}');
        debugPrint('Headers: ${dioError.response?.headers}');
      }
      throw Exception('Lỗi khi tạo đơn hàng: ${dioError.message}');
    } catch (e) {
      debugPrint('Error updating order status: $e');
      throw Exception('Error updating order status: $e');
    }
  }

  Future<bool> createOrder({
    required String note,
    required String paymentMethod,
    required String phone,
    required String address,
    required String name,
    required List<Map<String, dynamic>> items, // thêm items
  }) async {
    try {
      final response = await apiClient.privateDio.post(
        '/order/create',
        data: {
          'note': note,
          'payment_method': paymentMethod,
          'phone': phone,
          'address': address,
          'name': name,
          'items': items, // truyền list items
        },
      );

      if (response.statusCode == 201) {
        debugPrint('✅ Order created successfully');
        return true;
      } else {
        throw Exception('Failed to create order: ${response.data['message']}');
      }
    } on DioException catch (dioError) {
      debugPrint('❌ DioException khi tạo đơn hàng: ${dioError.message}');

      if (dioError.response != null) {
        debugPrint('Status code: ${dioError.response?.statusCode}');
        debugPrint('Data: ${dioError.response?.data}');
        debugPrint('Headers: ${dioError.response?.headers}');
      }
      final msg =
          dioError.response?.data?['message'] ?? 'Lỗi kết nối đến server';
      debugPrint('Chi tiết lỗi: $msg');
      throw msg; // 👉 chỉ ném chuỗi lỗi, không bọc trong Exception
    } catch (e) {
      debugPrint('Error creating order: $e');
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  Future<bool> placeOrder(
    String note,
    String paymentMethod,
    int cartId,
    String phone,
    String address,
    String name,
    int? promotionId,
  ) async {
    try {
      // Tạo dữ liệu gửi lên
      final Map<String, dynamic> data = {
        'note': note,
        'payment_method': paymentMethod,
        'cart_id': cartId,
        'phone': phone,
        'address': address,
        'name': name,
      };

      // Nếu có chọn khuyến mãi thì thêm vào
      if (promotionId != null) {
        data['promotion_id'] = promotionId;
      }

      final response = await apiClient.privateDio.post(
        '/order/place',
        data: data,
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to create order ${response.data['message']}');
      }
    } on DioException catch (dioError) {
      debugPrint('❌ DioException khi tạo đơn hàng: ${dioError.message}');

      if (dioError.response != null) {
        debugPrint('Status code: ${dioError.response?.statusCode}');
        debugPrint('Data: ${dioError.response?.data}');
        debugPrint('Headers: ${dioError.response?.headers}');
      } else {
        debugPrint('Message: ${dioError.message}');
      }
      final msg =
          dioError.response?.data?['message'] ?? 'Lỗi kết nối đến server';
      debugPrint('Chi tiết lỗi: $msg');
      throw msg; // 👉 chỉ ném chuỗi lỗi, không bọc trong Exception
    } catch (e) {
      debugPrint('Error creating order: $e');
      throw Exception('Error creating order: $e');
    }
  }

  Future<List<Order>> loadAllOrder() async {
    try {
      final response = await apiClient.privateDio.get('/order/user');
      final data = response.data['data'];
      final resultList = data['result'] as List;

      final orders =
          resultList.map((orderJson) => Order.fromJson(orderJson)).toList();

      return orders;
    } catch (e) {
      debugPrint('Error loading orders: $e');
      throw Exception('Error loading orders: $e');
    }
  }

  Future<Order> loadDetailOrder(int orderId) async {
    try {
      final response = await apiClient.privateDio.get('/order/$orderId');
      final data = response.data['data'];
      return Order.fromJson(data);
    } catch (e) {
      debugPrint('Error loading order details: $e');
      throw Exception('Error loading order details: $e');
    }
  }
}
