import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:heaven_book_app/interceptors/auth_interceptor.dart';
import 'package:heaven_book_app/services/auth_service.dart';

class ApiClient {
  final Dio publicDio;
  final Dio privateDio;

  ApiClient(FlutterSecureStorage secureStorage, AuthService authService)
    : publicDio = Dio(
        BaseOptions(
          baseUrl: 'http://10.0.2.2:8000/api/v1',
          headers: {'Content-Type': 'application/json'},
        ),
      ),

      privateDio = Dio(
        BaseOptions(
          baseUrl: 'http://10.0.2.2:8000/api/v1',
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    privateDio.interceptors.add(
      AuthInterceptor(secureStorage, privateDio, authService),
    );
  }

  void dispose() {
    publicDio.close();
    privateDio.close();
  }
}
