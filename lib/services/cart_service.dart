import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:heaven_book_app/model/cart.dart';
import 'package:heaven_book_app/services/api_client.dart';
import 'package:heaven_book_app/services/auth_service.dart';

class CartService {
  final ApiClient apiClient;
  final AuthService authService;
  int? _cartId;

  CartService(this.apiClient, this.authService);

  Future<Cart> getMyCart(int customerID) async {
    try {
      final response = await apiClient.privateDio.get(
        '/cart/by-customer/$customerID',
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic> && body['data'] != null) {
          final cartData = Map<String, dynamic>.from(body['data']);
          final cart = Cart.fromJson(cartData);
          _cartId = cart.id;
          return cart;
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('Unexpected status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data?['message'] == 'Cart not found') {
        debugPrint('⚠️ Cart not found -> tạo cart tạm');
        final tempCart = Cart(id: 0, items: [], totalPrice: 0.0, totalItems: 0);
        return tempCart;
      }

      debugPrint('❌ DioException in getMyCart: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error in getMyCart: $e');
      throw Exception('Error loading cart: $e');
    }
  }

  Future<void> toggleCartItem(int cartItemId, bool isSelect) async {
    try {
      final response = await apiClient.privateDio.put(
        '/cart/item/toggle-is-select',
        data: {'is_selected': isSelect, 'cart_item_id': cartItemId},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to toggle cart item (status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in toggleCartItem: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error in toggleCartItem: $e');
      throw Exception('Error toggling cart item: $e');
    }
  }

  Future<void> updateCartItemQuantity(int cartItemId, int newQuantity) async {
    try {
      final response = await apiClient.privateDio.put(
        '/cart/update',
        data: {
          'quantity': newQuantity,
          'cartId': _cartId,
          'cartItemId': cartItemId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update cart item (status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in updateCartItemQuantity: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error in updateCartItemQuantity: $e');
      throw Exception('Error updating cart item: $e');
    }
  }

  Future<String> addToCart(int bookId, int quantity) async {
    try {
      final user = await authService.getCurrentUser();
      final email = user.email;

      final response = await apiClient.privateDio.post(
        '/cart/add',
        data: {'email': email, 'productId': bookId, 'quantity': quantity},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return "Item added to cart successfully";
      } else {
        throw Exception(
          'Failed to add to cart (status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      debugPrint('DioException in addToCart: $errorMessage');
      throw Exception('Failed to add to cart: $errorMessage');
    } catch (e) {
      debugPrint('Error in addToCart: $e');
      throw Exception('Error adding to cart: $e');
    }
  }

  Future<String> removeCartItem(int cartItemId) async {
    try {
      final response = await apiClient.privateDio.delete(
        '/cart/delete/$cartItemId',
      );

      if (response.statusCode == 200) {
        return "Item removed from cart successfully";
      } else {
        throw Exception(
          'Failed to remove cart item (status: ${response.statusCode})',
        );
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
      debugPrint('Error in removeCartItem: $e');
      throw Exception('Error removing cart item: $e');
    }
  }
}
