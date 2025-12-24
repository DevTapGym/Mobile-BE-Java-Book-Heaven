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
          //baseUrl: 'http://192.168.1.123:8080/api/v1',
          baseUrl: 'https://api.thebookheaven.io.vn/api/v1',
          headers: {'Content-Type': 'application/json'},
        ),
      ),
      //10.0.2.2
      privateDio = Dio(
        BaseOptions(
          //baseUrl: 'http://192.168.1.123:8080/api/v1',
          baseUrl: 'https://api.thebookheaven.io.vn/api/v1',
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
