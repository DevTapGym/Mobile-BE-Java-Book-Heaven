import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final AuthService _authService;
  final Dio _dio;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  AuthInterceptor(this._storage, this._dio, this._authService);

  /// Đọc từ secure storage an toàn, xử lý lỗi giải mã khi đổi thiết bị
  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      // Lỗi giải mã khi đổi thiết bị hoặc reinstall app
      if (e.message?.contains('BadPaddingException') == true ||
          e.message?.contains('BAD_DECRYPT') == true) {
        debugPrint('🚨 Lỗi giải mã storage (đổi thiết bị): ${e.message}');
        try {
          await _storage.deleteAll();
          debugPrint('🧹 Đã clear storage do lỗi giải mã');
        } catch (clearError) {
          debugPrint('🚨 Lỗi clear storage: $clearError');
        }
      }
      return null;
    } catch (e) {
      debugPrint('🚨 Lỗi đọc storage: $e');
      return null;
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _safeRead('access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Nếu lỗi 401
    if (err.response?.statusCode == 401) {
      final responseData = err.response?.data;

      // Kiểm tra lỗi Unauthorized
      if (responseData is Map<String, dynamic> &&
          responseData['error'] == 'Unauthorized' &&
          responseData['message'] == 'Token is invalid or not transmitted') {
        // Nếu request chính là refresh token → logout
        if (err.requestOptions.path.contains('/refresh') ||
            err.requestOptions.path.contains('/auth/refresh')) {
          await _handleLogout();
          return handler.reject(err);
        }

        // Nếu đang refresh token → đợi hoàn tất
        if (_isRefreshing) {
          final success = await _refreshCompleter?.future ?? false;
          if (success) {
            // Token mới đã được lưu → retry request
            final newToken = await _safeRead('access_token');
            if (newToken != null) {
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.reject(e as DioException);
              }
            }
          } else {
            await _handleLogout();
            return handler.reject(err);
          }
        }

        // Chưa refresh → bắt đầu refresh token
        _isRefreshing = true;
        _refreshCompleter = Completer<bool>();

        try {
          final result = await _authService.refreshToken();
          final success = result['success'] == true;

          if (success) {
            debugPrint('✅ Refresh token thành công');

            // Retry request với token mới
            final newToken = await _safeRead('access_token');
            if (newToken != null) {
              final opts = err.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              final response = await _dio.fetch(opts);
              _refreshCompleter!.complete(true);
              return handler.resolve(response);
            }
          } else {
            debugPrint('❌ Refresh token thất bại: ${result['message']}');
            _refreshCompleter!.complete(false);
            await _handleLogout();
            return handler.reject(err);
          }
        } catch (e) {
          debugPrint('🚨 Lỗi refresh token: $e');
          _refreshCompleter!.complete(false);
          await _handleLogout();
          return handler.reject(err);
        } finally {
          _isRefreshing = false;
          _refreshCompleter = null;
        }
      }
    }

    // Các lỗi khác → cho đi bình thường
    handler.next(err);
  }

  Future<void> _handleLogout() async {
    try {
      debugPrint('🚪 Logout do token invalid...');
      await _authService.logout();
      await _authService.handleTokenExpired();
    } catch (e) {
      debugPrint('🚨 Lỗi logout: $e');
      try {
        await _storage.deleteAll();
        debugPrint('🧹 Clear storage thủ công');
      } catch (storageError) {
        debugPrint('🚨 Storage clear error: $storageError');
      }
    }
  }
}
