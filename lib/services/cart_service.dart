import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:heaven_book_app/model/cart.dart';
import 'package:heaven_book_app/services/api_client.dart';

class CartService {
  final ApiClient apiClient;
  int? _cartId;

  CartService(this.apiClient);

  Future<Cart> getMyCart() async {
    try {
      final response = await apiClient.privateDio.get('/cart/my-cart');

      if (response.statusCode == 200) {
        final body = response.data;

        if (body is Map<String, dynamic> && body['data'] != null) {
          final cartData = Map<String, dynamic>.from(body['data']);
          _cartId = Cart.fromJson(cartData).id;
          return Cart.fromJson(cartData);
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('Failed to load cart (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('DioException in getMyCart: $e');
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
        '/cart/update/$cartItemId',
        data: {'quantity': newQuantity},
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
      // Đảm bảo có cartId trước khi add
      if (_cartId == null) {
        await getMyCart(); // Lấy cart để có _cartId
      }

      final response = await apiClient.privateDio.post(
        '/cart/add',
        data: {'book_id': bookId, 'quantity': quantity, 'cart_id': _cartId},
      );

      if (response.statusCode == 201) {
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
        '/cart/remove/$cartItemId',
      );

      if (response.statusCode == 200) {
        return "Item removed from cart successfully";
      } else {
        throw Exception(
          'Failed to remove cart item (status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in removeCartItem: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error in removeCartItem: $e');
      throw Exception('Error removing cart item: $e');
    }
  }
}
