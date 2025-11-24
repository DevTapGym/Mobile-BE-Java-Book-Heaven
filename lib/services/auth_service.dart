import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heaven_book_app/model/user.dart';
import 'package:heaven_book_app/services/api_client.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final ApiClient apiClient;

  final StreamController<void> _onTokenExpiredController =
      StreamController.broadcast();
  Stream<void> get onTokenExpired => _onTokenExpiredController.stream;

  AuthService() {
    apiClient = ApiClient(_secureStorage, this);
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final fb_auth.FirebaseAuth firebaseAuth = fb_auth.FirebaseAuth.instance;

      await googleSignIn.signOut();
      await fb_auth.FirebaseAuth.instance.signOut();

      // 1️⃣ Đăng nhập Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Người dùng đã hủy đăng nhập Google');
      }

      // 2️⃣ Lấy token từ Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3️⃣ Đăng nhập Firebase bằng credential
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fb_auth.UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Không thể đăng nhập Firebase.');
      }

      // 4️⃣ Lấy token xác thực Firebase gửi về BE (nếu BE kiểm tra)
      final idToken = await user.getIdToken();

      // 5️⃣ Gửi thông tin đến Backend
      final response = await apiClient.publicDio.post(
        '/auth/loginWithGoogle',
        data: {"idToken": idToken},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];

        // 6️⃣ Lưu Access Token
        final accessToken = data['access_token'];
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('Không tìm thấy access_token trong phản hồi');
        }
        await _secureStorage.write(key: 'access_token', value: accessToken);
        debugPrint('✅ Access token đã lưu sau Google login');

        // 7️⃣ Lưu Refresh Token từ cookie
        final setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
          final refreshCookie = setCookieHeader
              .map((str) => Cookie.fromSetCookieValue(str))
              .firstWhere(
                (c) => c.name == 'refresh_token',
                orElse: () => Cookie('refresh_token', ''),
              );

          if (refreshCookie.value.isNotEmpty) {
            await _secureStorage.write(
              key: 'refresh_token',
              value: refreshCookie.value,
            );
            debugPrint('✅ Refresh token đã lưu sau Google login');
          }
        }

        debugPrint('✅ Google login thành công: ${user.email}');

        return {'token': accessToken};
      } else {
        throw Exception(
          response.data['message'] ?? 'Đăng nhập Google thất bại',
        );
      }
    } on DioException catch (dioError) {
      debugPrint('❌ DioException: ${dioError.message}');

      if (dioError.response != null) {
        debugPrint('Status code: ${dioError.response?.statusCode}');
        debugPrint('Data: ${dioError.response?.data}');
        debugPrint('Headers: ${dioError.response?.headers}');
      }
      throw Exception('Lỗi đăng nhập google: ${dioError.message}');
    } catch (e) {
      debugPrint('❌ Lỗi loginWithGoogle: $e');
      throw Exception('Đăng nhập Google thất bại: $e');
    }
  }

  Future<String> uploadAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'folder': 'avatar',
      });

      final response = await apiClient.privateDio.post(
        '/files',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        debugPrint('Upload avatar thành công');

        // Lấy tên file từ phản hồi
        final fileName = response.data['data']['fileName'];
        return fileName;
      } else {
        final message = response.data['message'] ?? 'Upload avatar thất bại';
        final error = response.data['error'];
        throw Exception(error != null ? '$message: $error' : message);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Không thể upload avatar',
        );
      }
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    } catch (e, stack) {
      debugPrint('Upload avatar error: $e');
      debugPrint('Stacktrace: $stack');
      rethrow;
    }
  }

  Future<bool> updateInfoUser(
    int id, {
    String? name,
    String? phone,
    String? avatar,
    String? email,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'id': id,
        'role': {'id': 2, 'name': 'CUSTOMER'},
      };
      if (name != null && name.isNotEmpty) {
        data['username'] = name;
      }
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }
      if (avatar != null && avatar.isNotEmpty) {
        data['avatar'] = avatar;
      }
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      if (data.isEmpty) {
        throw Exception('Không có thông tin nào để cập nhật.');
      }

      final response = await apiClient.privateDio.put('/account', data: data);

      if (response.statusCode == 200) {
        debugPrint('✅ Cập nhật thông tin người dùng thành công');
        return true;
      } else {
        final message = response.data['message'] ?? 'Cập nhật thất bại';
        final error = response.data['error'];
        throw Exception(error != null ? '$message: $error' : message);
      }
    } on DioException catch (dioError) {
      debugPrint('❌ DioException khi cập nhật thông tin người dùng:');
      if (dioError.response != null) {
        debugPrint('Status code: ${dioError.response?.statusCode}');
        debugPrint('Data: ${dioError.response?.data}');
        debugPrint('Headers: ${dioError.response?.headers}');
      } else {
        debugPrint('Message: ${dioError.message}');
      }
      throw Exception(
        dioError.response?.data['message'] ??
            'Không thể kết nối đến server. Vui lòng thử lại.',
      );
    } catch (e, stack) {
      debugPrint('❌ Lỗi không xác định khi cập nhật thông tin: $e');
      debugPrint('❌ Stacktrace: $stack');
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  Future<bool> updateCustomer(
    int id,
    String name,
    String phone,
    String email,
    String birthday,
    String gender,
  ) async {
    try {
      final response = await apiClient.privateDio.put(
        '/customer',
        data: {
          "id": id,
          "name": name,
          "birthday": birthday,
          "email": email,
          "phone": phone,
          "gender": gender,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        debugPrint('✅ Cập nhật thông tin khách hàng thành công');
        return true;
      } else {
        final message = response.data['message'] ?? 'Cập nhật thất bại';
        final error = response.data['error'];
        debugPrint('⚠️ Cập nhật thông tin khách hàng thất bại: $message');
        throw Exception(error != null ? '$message: $error' : message);
      }
    } on DioException catch (dioError) {
      debugPrint('❌ DioException khi cập nhật thông tin người dùng:');

      if (dioError.response != null) {
        debugPrint('Status code: ${dioError.response?.statusCode}');
        debugPrint('Data: ${dioError.response?.data}');
        debugPrint('Headers: ${dioError.response?.headers}');
      } else {
        debugPrint('Message: ${dioError.message}');
      }

      // Có thể throw lại lỗi nếu cần cho Bloc/UI xử lý
      throw Exception('Lỗi cập nhật thông tin: ${dioError.message}');
    } catch (e, stack) {
      debugPrint('❌ Lỗi không xác định khi cập nhật thông tin: $e');
      debugPrint('❌ Stacktrace: $stack');
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String email,
  ) async {
    try {
      final response = await apiClient.privateDio.post(
        '/account/change-password',
        data: {
          "email": email,
          "oldPassword": currentPassword,
          "newPassword": newPassword,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Đổi mật khẩu thành công');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Không thể đổi mật khẩu');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Không thể đổi mật khẩu',
        );
      }
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await apiClient.privateDio.get('/auth/account');

      if (response.statusCode == 200 &&
          response.data['data'] != null &&
          response.data['data']['account'] != null) {
        final userJson = response.data['data']['account'];
        return User.fromJson(userJson);
      } else {
        throw Exception('Không thể lấy thông tin người dùng');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Không thể lấy thông tin người dùng',
        );
      }
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  // ==================== LOGIN ====================
  Future<String> login(String username, String password) async {
    try {
      final response = await apiClient.publicDio.post(
        '/auth/login',
        data: {"username": username, "password": password},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        final accessToken = data['access_token'];

        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('Không tìm thấy access_token trong phản hồi');
        }
        await _secureStorage.write(key: 'access_token', value: accessToken);

        final setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
          final refreshCookie = setCookieHeader
              .map((str) => Cookie.fromSetCookieValue(str))
              .firstWhere(
                (c) => c.name == 'refresh_token',
                orElse: () => Cookie('refresh_token', ''),
              );

          if (refreshCookie.value.isNotEmpty) {
            await _secureStorage.write(
              key: 'refresh_token',
              value: refreshCookie.value,
            );
          }
        }

        return accessToken;
      } else {
        throw Exception(response.data['message'] ?? 'Đăng nhập thất bại');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Đăng nhập thất bại');
      }
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Không tìm thấy refresh token trong SecureStorage');
      }

      final response = await apiClient.publicDio.get(
        '/auth/refresh',
        options: Options(headers: {'Cookie': 'refresh_token=$refreshToken'}),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        final newAccessToken = data['access_token'];

        await _secureStorage.write(key: 'access_token', value: newAccessToken);
        debugPrint('✅ Access token đã được làm mới và lưu');
        final token = await _secureStorage.read(key: 'access_token');
        debugPrint('🔑 [InitScreen] New access token: $token');

        final setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
          final newRefresh = setCookieHeader
              .map((str) => Cookie.fromSetCookieValue(str))
              .firstWhere(
                (c) => c.name == 'refresh_token',
                orElse: () => Cookie('refresh_token', ''),
              );

          if (newRefresh.value.isNotEmpty) {
            await _secureStorage.write(
              key: 'refresh_token',
              value: newRefresh.value,
            );
            debugPrint('✅ Refresh token mới đã lưu');
            final refresh = await _secureStorage.read(key: 'refresh_token');
            debugPrint('🔑 [InitScreen] New refresh token: $refresh');
          }
        }

        return {'token': newAccessToken, 'success': true};
      } else {
        throw Exception('Làm mới token thất bại');
      }
    } catch (e) {
      debugPrint('❌ Refresh token error: $e');
      throw Exception('Không thể làm mới token, vui lòng đăng nhập lại.');
    }
  }

  // ==================== XỬ LÝ HẾT HẠN TOKEN ====================
  Future<void> handleTokenExpired() async {
    await _secureStorage.deleteAll();
    debugPrint('❌ Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.');
    _onTokenExpiredController.add(null);
  }

  // ==================== DỌN DẸP ====================
  Future<void> _cleanupLocalData() async {
    await _secureStorage.deleteAll();
    debugPrint(
      '🧹 [AuthService] Đã xóa access token + refresh token + user data',
    );
  }

  // ==================== LOGOUT ====================
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await apiClient.privateDio.post('/auth/logout');

      if (response.statusCode == 200) {
        await _cleanupLocalData();
        return {
          'success': true,
          'message': response.data['message'] ?? 'Đăng xuất thành công',
          'data': response.data['data'],
        };
      } else {
        await _cleanupLocalData();
        throw Exception(
          response.data['message'] ?? 'Đăng xuất không thành công',
        );
      }
    } on DioException catch (e) {
      await _cleanupLocalData();
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi khi đăng xuất');
      }
      return {
        'success': true,
        'message': 'Đăng xuất thành công (offline)',
        'data': null,
      };
    } catch (e) {
      await _cleanupLocalData();
      return {'success': true, 'message': 'Đăng xuất thành công', 'data': null};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await apiClient.publicDio.post(
        '/auth/register',
        data: {
          "username": name,
          "email": email,
          "password": password,
          "phone": phone,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'];

        return {
          'success': true,
          'status': response.data['status'],
          'message': response.data['message'] ?? 'Đăng ký thành công',
          'user': data,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Đăng ký thất bại');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Đăng ký thất bại');
      }
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  Future<Map<String, dynamic>> sendActivationCode() async {
    try {
      final response = await apiClient.privateDio.post('/auth/send-code');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Mã xác thực đã được gửi',
          'data': response.data['data'],
        };
      } else {
        throw Exception(
          response.data['message'] ?? 'Không thể gửi mã xác thực',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Không thể gửi mã xác thực',
        );
      }
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  Future<Map<String, dynamic>> verifyActivationCode(String code) async {
    try {
      final response = await apiClient.privateDio.post(
        '/auth/verify-code',
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        await _secureStorage.write(
          key: 'is_active',
          value: response.data['is_active'],
        );

        return {
          'success': true,
          'message': response.data['message'] ?? 'Kích hoạt thành công',
          'data': response.data['data'],
        };
      } else {
        throw Exception(response.data['message'] ?? 'Mã xác thực không hợp lệ');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Mã xác thực không hợp lệ',
        );
      }
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await apiClient.publicDio.post(
        '/auth/forgot-password',
        data: {"email": email},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              response.data['message'] ?? 'Mã xác thực đã được gửi về email',
          'data': response.data['data'],
        };
      } else {
        throw Exception(
          response.data['message'] ?? 'Không thể gửi mã xác thực',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Không thể gửi mã xác thực',
        );
      }
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.publicDio.post(
        '/auth/reset-password',
        data: {"email": email, "code": code, "new_password": newPassword},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Đặt lại mật khẩu thành công',
          'data': response.data['data'],
        };
      } else {
        throw Exception(
          response.data['message'] ?? 'Không thể đặt lại mật khẩu',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Không thể đặt lại mật khẩu',
        );
      }
      throw Exception('Không thể kết nối đến server. Vui lòng thử lại.');
    }
  }
}
