import 'package:flutter/foundation.dart';
import 'package:heaven_book_app/model/promotion.dart';
import 'package:heaven_book_app/services/api_client.dart';

class PromotionService {
  final ApiClient apiClient;

  PromotionService(this.apiClient);

  Future<List<Promotion>> getAllPromotions() async {
    try {
      final response = await apiClient.privateDio.get(
        '/promotions',
        queryParameters: {'size': 30},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200 &&
            responseData['data'] != null) {
          final data = responseData['data'];

          if (data is Map<String, dynamic> && data['result'] is List) {
            final result = data['result'] as List;
            return result
                .map((e) => Promotion.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          } else {
            throw Exception('Invalid promotion data format');
          }
        } else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw Exception(
          'Failed to load promotions (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('💥 Error in getAllPromotions: $e');
      throw Exception('Error loading promotions: $e');
    }
  }
}
