import 'package:flutter/material.dart';
import 'package:heaven_book_app/model/book.dart';
import 'package:heaven_book_app/services/api_client.dart';

class SuggestService {
  final ApiClient apiClient;

  SuggestService(this.apiClient);

  Future<List<Book>> getSuggestions({
    required int customerId,
    required String position,
  }) async {
    try {
      final response = await apiClient.publicDio.post(
        '/AI/recommend',
        data: {'customerId': customerId, 'topK': 12, 'position': position},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData['status'] == 200 &&
            responseData['data'] is List) {
          final list = responseData['data'] as List;

          return list
              .map((item) => Book.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw Exception(
          'Failed to load suggest (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('💥 Error in suggest: $e');
      throw Exception('Error loading suggest: $e');
    }
  }

  Future<void> feedback({
    required int customerId,
    required int action,
    required String position,
    required String evenType,
  }) async {
    try {
      final response = await apiClient.publicDio.post(
        '/AI/feedback',
        data: {
          'customerId': customerId,
          'action': action,
          'position': position,
          'even_type': evenType,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 200 && responseData['data'] != null) {
          debugPrint('✅ Feedback sent successfully');
          return;
        } else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw Exception(
          'Failed to load suggest (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('💥 Error in suggest: $e');
      throw Exception('Error loading suggest: $e');
    }
  }
}
