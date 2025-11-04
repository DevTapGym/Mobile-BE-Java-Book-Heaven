import 'package:heaven_book_app/model/book.dart';
import 'package:heaven_book_app/services/api_client.dart';

class BookService {
  final ApiClient apiClient;

  BookService(this.apiClient);

  Future<List<Book>> getAllBooks() async {
    try {
      final response = await apiClient.publicDio.get('/book/?size=20&page=1');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> &&
            data['data'] is Map<String, dynamic> &&
            data['data']['result'] is List) {
          final List<dynamic> list = data['data']['result'];
          return list
              .map((e) => Book.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception(
          'Failed to load books (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error loading books: $e');
    }
  }

  Future<List<Book>> getRandomBooks() async {
    try {
      final response = await apiClient.publicDio.get('/book/random');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] is List) {
          final List<dynamic> list = data['data'];
          return list
              .map((e) => Book.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          throw Exception('Invalid API response format');
        }
      } else {
        throw Exception(
          'Failed to load books (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error loading books: $e');
    }
  }

  Future<Book> getBookDetail(int id) async {
    try {
      final response = await apiClient.publicDio.get('/book/$id');
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
    } catch (e) {
      throw Exception('Error loading book: $e');
    }
  }

  Future<List<Book>> getPopularBooks() async {
    try {
      final response = await apiClient.publicDio.get('/book/popular');

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

  Future<List<Book>> getSaleOffBooks() async {
    try {
      final response = await apiClient.publicDio.get('/book/sale-off');

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

  Future<List<Book>> getBestSellingBooksInYear() async {
    try {
      final response = await apiClient.publicDio.get('/book/top-selling');

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
      final response = await apiClient.publicDio.get('/book/search/$query');

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
          'Failed to search books (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  Future<List<Book>> getBooksByCategory(int categoryId) async {
    try {
      final response = await apiClient.publicDio.get(
        '/book/category/$categoryId',
      );

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
          'Failed to load books by category (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Error loading books by category: $e');
    }
  }
}
