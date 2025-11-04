import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  AuthBloc(this.authService) : super(AuthInitial()) {
    authService.onTokenExpired.listen((_) {
      add(TokenExpiredEvent());
    });

    on<LoginWithGoogleRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authService.loginWithGoogle();

        final token = result['token'] as String;
        final isActive = result['isActive'] as bool;

        emit(AuthSuccess(token: token, isActive: isActive));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.logout();
        emit(AuthLoggedOut());
      } catch (e) {
        emit(AuthFailure('Đăng xuất thất bại: ${e.toString()}'));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authService.register(
          name: event.name,
          email: event.email,
          password: event.password,
          passwordConfirmation: event.passwordConfirmation,
        );
        final userData = result['user'] as Map<String, dynamic>;
        final message = result['message'] as String;

        emit(AuthRegisterSuccess(userData: userData, message: message));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authService.login(event.username, event.password);

        final token = result['token'] as String;
        final isActive = result['isActive'] as bool;

        emit(AuthSuccess(token: token, isActive: isActive));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AppStarted>((event, emit) async {
      emit(AuthLoading());

      try {
        if (event.isTokenExpired) {
          // Nếu token đã hết hạn, không cần kiểm tra lại
          final refreshToken = await authService.getRefreshToken();

          if (refreshToken != null && refreshToken.isNotEmpty) {
            final result = await authService.refreshToken();

            final token = result['token'] as String;
            final isActive = result['isActive'] as bool;

            emit(AuthSuccess(token: token, isActive: isActive));
            return;
          }
          emit(AuthFailure('Cần đăng nhập lại'));
        } else {
          final accessToken = await secureStorage.read(key: 'access_token');
          final isActive = await secureStorage.read(key: 'is_active');
          if (accessToken == null || isActive == null) {
            emit(AuthFailure('Cần đăng nhập lại'));
            return;
          }

          emit(AuthSuccess(token: accessToken, isActive: isActive == 'true'));
        }
      } catch (e) {
        emit(AuthLoggedOut());
      }
    });

    on<CheckUserActive>((event, emit) async {
      try {
        final isActiveString = await secureStorage.read(key: 'is_active');
        final token = await secureStorage.read(key: 'access_token');

        if (isActiveString != null && token != null) {
          final isActive = isActiveString == 'true';
          emit(AuthSuccess(token: token, isActive: isActive));
        } else {
          emit(AuthFailure('Không thể xác thực người dùng'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SendActivationCodeRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.sendActivationCode();
        emit(
          ActivationCodeSent(
            message: 'Mã kích hoạt đã được gửi đến email của bạn',
          ),
        );
      } catch (e) {
        emit(AuthFailure('Không thể gửi mã kích hoạt: ${e.toString()}'));
      }
    });

    on<VerifyActivationCodeRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authService.verifyActivationCode(event.code);

        final token = await secureStorage.read(key: 'access_token');

        emit(AuthSuccess(token: token!, isActive: true));
      } catch (e) {
        emit(AuthFailure('Mã kích hoạt không hợp lệ: ${e.toString()}'));
      }
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authService.forgotPassword(event.email);
        final message = result['message'] as String;
        emit(ForgotPasswordSuccess(message: message));
      } catch (e) {
        //emit(AuthFailure('Không thể gửi mã đặt lại mật khẩu: ${e.toString()}'));
        emit(
          AuthFailure(
            'Không thể gửi mã đặt lại mật khẩu: Có thể bạn đã nhập sai email hoặc tài khoản chưa được đăng ký.',
          ),
        );
      }
    });

    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await authService.resetPassword(
          email: event.email,
          code: event.code,
          newPassword: event.newPassword,
        );
        final message = result['message'] as String;
        emit(ResetPasswordSuccess(message: message));
      } catch (e) {
        emit(AuthFailure('Không thể đặt lại mật khẩu: ${e.toString()}'));
      }
    });

    on<TokenExpiredEvent>((event, emit) async {
      emit(AuthFailure('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
      emit(AuthLoggedOut());
    });
  }
}
