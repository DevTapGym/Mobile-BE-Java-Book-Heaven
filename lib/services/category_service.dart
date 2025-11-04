import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heaven_book_app/model/category.dart';
import 'package:heaven_book_app/services/api_client.dart';
import 'package:heaven_book_app/services/auth_service.dart';

class CategoryService {
  final apiClient = ApiClient(FlutterSecureStorage(), AuthService());

  Future<List<Category>> getAllCategories({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await apiClient.publicDio.get(
        '/categories/page',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> &&
            data['data'] != null &&
            data['data']['result'] is List) {
          final List<dynamic> list = data['data']['result'];
          return list
              .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('❌ Dữ liệu trả về không đúng định dạng');
        }
      } else {
        throw Exception('⚠️ Lỗi tải danh mục (status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('🚫 Lỗi API: $message');
    } catch (e) {
      throw Exception('💥 Lỗi không xác định khi tải danh mục: $e');
    }
  }
}
