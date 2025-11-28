import 'package:heaven_book_app/model/book.dart';
import 'package:heaven_book_app/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class BookService {
  final ApiClient apiClient;

  BookService(this.apiClient);

  Future<List<Book>> getAllBooks() async {
    try {
      final response = await apiClient.privateDio.get('/productsNoPagination');

      if (response.statusCode == 200) {
        final data = response.data;

        // Kiểm tra nhiều cấu trúc response khác nhau
        List<dynamic> bookList;

        if (data is Map<String, dynamic>) {
          if (data['data'] is Map<String, dynamic> &&
              data['data']['result'] is List) {
            bookList = data['data']['result'];
          } else if (data['data'] is List) {
            bookList = data['data'];
          } else {
            throw Exception('Invalid API response format');
          }
        } else if (data is List) {
          bookList = data;
        } else {
          throw Exception('Invalid API response format');
        }

        return bookList
            .map((e) => Book.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        throw Exception(
          'Failed to load books (status: ${response.statusCode})',
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
      throw Exception('Error loading books: $e');
    }
  }

  Future<Book> getBookDetail(int id) async {
    try {
      final response = await apiClient.privateDio.get('/products/$id');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return Book.fromJson(Map<String, dynamic>.from(data['data']));
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception('Failed to load book (status: ${response.statusCode})');
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
      throw Exception('Error loading book: $e');
    }
  }

  Future<List<Book>> getBestSellingBooksInYear() async {
    try {
      final response = await apiClient.privateDio.get(
        '/products?sort=sold,desc',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data']['result'] is List) {
          final List<dynamic> bookList = data['data']['result'];
          return bookList
              .map((e) => Book.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception(
          'Failed to load Best Selling Books In Year (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error load Best Selling Books In Year books: $e');
    }
  }

  Future<List<Book>> getBannerBooks() async {
    try {
      final response = await apiClient.publicDio.get('/book/banner');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data'] is List) {
          final List<dynamic> bookList = data['data'];
          return bookList
              .map((e) => Book.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception(
          'Failed to load popular books (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error loading popular books: $e');
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    try {
      final response = await apiClient.privateDio.get(
        '/products?filter=name~\'$query\'',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data']['result'] is List) {
          final List<dynamic> bookList = data['data']['result'];
          return bookList
              .map((e) => Book.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception(
          'Failed to search books (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  Future<List<Book>> getBooksByCategory(String categoryName) async {
    try {
      final response = await apiClient.privateDio.get(
        '/products?filter=category.name~\'$categoryName\'',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data']['result'] is List) {
          final List<dynamic> bookList = data['data']['result'];
          return bookList
              .map((e) => Book.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception(
          'Failed to load books by category (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error loading books by category: $e');
    }
  }

  Future<List<Book>> getBooksByProductType(String productTypeName) async {
    try {
      final response = await apiClient.privateDio.get(
        '/products?filter=productType.name~\'$productTypeName\'',
      );
      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['data']['result'] is List) {
          final List<dynamic> bookList = data['data']['result'];
          return bookList
              .map((e) => Book.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception(
          'Failed to load books by category (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error loading books by category: $e');
    }
  }
}
