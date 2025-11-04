import 'package:flutter/widgets.dart';
import 'package:heaven_book_app/model/address.dart';
import 'package:heaven_book_app/model/tag_address.dart';
import 'package:heaven_book_app/services/api_client.dart';

class AddressService {
  final ApiClient apiClient;

  AddressService(this.apiClient);

  Future<List<Address>> getMyAddresses({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await apiClient.privateDio.get(
        '/address/customer',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200 &&
            responseData['data'] != null) {
          final data = responseData['data'];

          if (data is List) {
            return data
                .map((e) => Address.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else {
            throw Exception('Data is not a list');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
          'Failed to load addresses (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('💥 Error in getAllAddresses: $e');
      throw Exception('Error loading addresses: $e');
    }
  }

  Future<List<TagAddress>> getAllTagAddresses() async {
    try {
      final response = await apiClient.privateDio.get('/address-tag');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200 &&
            responseData['data'] != null) {
          final data = responseData['data'];

          if (data is List) {
            return data
                .map((e) => TagAddress.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else {
            throw Exception('Data is not a list');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
          'Failed to load tag addresses (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('💥 Error in getAllTagAddresses: $e');
      throw Exception('Error loading tag addresses: $e');
    }
  }

  Future<void> addNewAddress({
    required String recipientName,
    required String address,
    required String phoneNumber,
    required int tagId,
    bool isDefault = false,
  }) async {
    try {
      final response = await apiClient.privateDio.post(
        '/address',
        data: {
          'recipient_name': recipientName,
          'address': address,
          'phone_number': phoneNumber,
          'tag_id': tagId,
          'is_default': isDefault,
        },
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 201) {
          return;
        } else {
          throw Exception('Failed to add address: Invalid response format');
        }
      } else {
        throw Exception(
          'Failed to add address (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('💥 Error in addNewAddress: $e');
      throw Exception('Error adding new address: $e');
    }
  }

  Future<void> updateAddress({
    required int addressId,
    required String recipientName,
    required String address,
    required String phoneNumber,
    required int tagId,
    required bool isDefault,
  }) async {
    try {
      final response = await apiClient.privateDio.put(
        '/address',
        data: {
          'id': addressId,
          'recipient_name': recipientName,
          'address': address,
          'phone_number': phoneNumber,
          'tag_id': tagId,
          'is_default': isDefault,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200) {
          return;
        } else {
          throw Exception('Failed to update address: Invalid response format');
        }
      } else {
        throw Exception(
          'Failed to update address (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('💥 Error in updateAddress: $e');
      throw Exception('Error updating address: $e');
    }
  }

  Future<void> deleteAddress(int addressId) async {
    try {
      final response = await apiClient.privateDio.delete('/address/$addressId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200) {
          return;
        } else {
          throw Exception('Failed to delete address: Invalid response format');
        }
      } else {
        throw Exception(
          'Failed to delete address (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('💥 Error in deleteAddress: $e');
      throw Exception('Error deleting address: $e');
    }
  }
}
