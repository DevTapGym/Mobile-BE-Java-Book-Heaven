import 'package:dio/dio.dart';
import 'package:heaven_book_app/model/product_type.dart';
import 'package:heaven_book_app/services/api_client.dart';

class ProductTypeService {
  final ApiClient apiClient;

  ProductTypeService(this.apiClient);

  Future<List<ProductType>> getAllProductType() async {
    try {
      final response = await apiClient.publicDio.get('/product-types');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> &&
            data['data'] != null &&
            data['data'] is List) {
          final List<dynamic> list = data['data'];
          return list
              .map((e) => ProductType.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('❌ Dữ liệu trả về không đúng định dạng');
        }
      } else {
        throw Exception(
          '⚠️ Lỗi tải product_type (status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('🚫 Lỗi API: $message');
    } catch (e) {
      throw Exception('💥 Lỗi không xác định khi tải product_type: $e');
    }
  }
}
