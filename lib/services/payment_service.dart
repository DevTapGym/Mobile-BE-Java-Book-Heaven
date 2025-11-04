import 'package:flutter/widgets.dart';
import 'package:heaven_book_app/model/payment.dart';
import 'package:heaven_book_app/services/api_client.dart';

class PaymentService {
  final ApiClient apiClient;

  PaymentService(this.apiClient);

  Future<List<Payment>> getPaymentMethods() async {
    try {
      final response = await apiClient.privateDio.get('/payment-method');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200 &&
            responseData['data'] != null) {
          final data = responseData['data'];

          if (data is List) {
            return data
                .map((e) => Payment.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else {
            throw Exception('Data is not a list');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final responseData = response.data['message'] ?? 'Unknown error';
        throw Exception(
          'Failed to load payment methods (status: ${response.statusCode}, message: $responseData)',
        );
      }
    } catch (e) {
      debugPrint('💥 Error in getPaymentMethods: $e');
      throw Exception('Error loading payment methods: $e');
    }
  }
}
