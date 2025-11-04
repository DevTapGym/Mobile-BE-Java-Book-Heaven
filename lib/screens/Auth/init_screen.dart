import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      //Case 0: Mới đăng xuất hoặc đổi mật khẩu -> Login
      final currentAuthState = context.read<AuthBloc>().state;
      if (currentAuthState is AuthLoggedOut) {
        debugPrint('❌ [InitScreen] Mới đăng xuất hoặc đổi mật khẩu → Login');
        _navigateToLogin();
        return;
      }

      final accessToken = await _secureStorage.read(key: 'access_token');
      final isActive = await _secureStorage.read(key: 'is_active');

      debugPrint('🔍 [InitScreen] Kiểm tra auto login...');
      debugPrint('🔍 [InitScreen] Access token exists: ${accessToken != null}');
      debugPrint('🔍 [InitScreen] Is active: $isActive');

      // Case 1: Không có token hoặc chưa active -> Login
      if (accessToken == null || accessToken.isEmpty || isActive != 'true') {
        debugPrint('❌ [InitScreen] Không có token hoặc chưa active → Login');
        _navigateToLogin();
        return;
      }

      // Case 2: Có token và active = '1' -> Kiểm tra expired
      final isExpired = _isTokenExpired(accessToken);
      debugPrint('🔍 [InitScreen] Token expired: $isExpired');

      if (isExpired) {
        // Token hết hạn -> Thử refresh
        debugPrint('⏰ [InitScreen] Token hết hạn → Thử refresh token');
        await _handleRefreshToken();
      } else {
        if (mounted) {
          context.read<AuthBloc>().add(AppStarted(isTokenExpired: true));
          debugPrint('✅ [InitScreen] Token còn hạn → Main');
          _navigateToMain();
        }
      }
    } catch (e) {
      debugPrint('🚨 [InitScreen] Lỗi kiểm tra auto login: $e → Login');
      _navigateToLogin();
    }
  }

  Future<void> _handleRefreshToken() async {
    try {
      debugPrint('⏳ [InitScreen] Bắt đầu refresh token...');

      final authBloc = context.read<AuthBloc>();

      // Dispatch refresh token event
      authBloc.add(AppStarted(isTokenExpired: true));

      // Wait for the next state that's not loading
      final result = await authBloc.stream
          .firstWhere((state) => state is! AuthLoading)
          .timeout(const Duration(seconds: 10));

      if (result is AuthSuccess) {
        debugPrint(
          '🎉 [InitScreen] Refresh token thành công → Chuyển vào Main',
        );
        if (mounted) {
          _navigateToMain();
        }
      } else if (result is AuthLoggedOut) {
        debugPrint('❌ [InitScreen] Refresh token thất bại → Login lại');
        if (mounted) {
          _navigateToLogin();
        }
      } else {
        debugPrint('⚠️ [InitScreen] Unexpected state: ${result.runtimeType}');
        if (mounted) {
          _navigateToLogin();
        }
      }
    } on TimeoutException {
      debugPrint('⏰ [InitScreen] Refresh token timeout');
      if (mounted) {
        _navigateToLogin();
      }
    } catch (e) {
      debugPrint('🚨 [InitScreen] Lỗi refresh token: $e');
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      final Map<String, dynamic> payloadMap = json.decode(decoded);

      final exp = payloadMap['exp'];
      if (exp == null) {
        return true;
      }

      final expTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final bufferedExpTime = expTime.subtract(const Duration(minutes: 5));

      debugPrint('📅 [InitScreen] Token hết hạn lúc: $expTime');
      debugPrint('📅 [InitScreen] Thời gian hiện tại: $now');
      debugPrint(
        '📅 [InitScreen] Thời gian buffer (trừ 5 phút): $bufferedExpTime',
      );

      final isExpired = bufferedExpTime.isBefore(now);

      return isExpired;
    } catch (e) {
      return true;
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushNamed(context, '/login');
    }
  }

  void _navigateToMain() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang kiểm tra đăng nhập...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
