import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/bloc/auth/auth_bloc.dart';
import 'package:heaven_book_app/bloc/auth/auth_event.dart';
import 'package:heaven_book_app/bloc/auth/auth_state.dart';
import 'package:heaven_book_app/main.dart';
import 'dart:async';

class ActiveScreen extends StatefulWidget {
  const ActiveScreen({super.key});

  @override
  State<ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  bool _canResend = false;
  int _resendCountdown = 90;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _sendInitialActivationCode();
  }

  void _resendCode() {
    context.read<AuthBloc>().add(SendActivationCodeRequested());
    _startResendTimer();
  }

  void _sendInitialActivationCode() {
    context.read<AuthBloc>().add(SendActivationCodeRequested());
  }

  void _handleActivateAccount() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vui lòng nhập đầy đủ 6 số của mã kích hoạt',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(VerifyActivationCodeRequested(code: code));
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 90;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _codeFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ActivationCodeSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontSize: 16),
              ),
              backgroundColor: AppColors.primaryDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          Navigator.pop(context);
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Kích hoạt tài khoản thành công!',
                style: const TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          final navigator = Navigator.of(context);
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
              );
            }
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.primaryDark,
                    size: 26,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
            body: Stack(
              children: [
                // Custom background with decorative circles
                CustomPaint(
                  size: Size.infinite,
                  painter: CircleBackgroundPainter(),
                ),
                // Main content
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  size: 120,
                                  color: AppColors.primaryDark,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 8.0,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Title
                                Text(
                                  'Kích hoạt tài khoản',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 4.0,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                // Subtitle
                                Text(
                                  'Nhập mã kích hoạt 6 số đã được gửi đến email của bạn',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),
                                // Activation code input fields
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(6, (index) {
                                    return SizedBox(
                                      width: 48,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _codeControllers[index],
                                          focusNode: _codeFocusNodes[index],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: AppColors.text,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: AppColors.primaryDark,
                                                width: 2,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: AppColors.primaryDark,
                                                width: 2,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: AppColors.primaryDark,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                            counterText: '',
                                          ),
                                          maxLength: 1,
                                          onChanged: (value) {
                                            if (value.isNotEmpty && index < 5) {
                                              FocusScope.of(
                                                context,
                                              ).requestFocus(
                                                _codeFocusNodes[index + 1],
                                              );
                                            } else if (value.isEmpty &&
                                                index > 0) {
                                              FocusScope.of(
                                                context,
                                              ).requestFocus(
                                                _codeFocusNodes[index - 1],
                                              );
                                            }
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return '';
                                            }
                                            if (!RegExp(
                                              r'^\d$',
                                            ).hasMatch(value)) {
                                              return '';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 32),
                                // Resend code link
                                Center(
                                  child: TextButton(
                                    onPressed:
                                        _canResend && !isLoading
                                            ? _resendCode
                                            : null,
                                    child: Text(
                                      _canResend && !isLoading
                                          ? 'Không nhận được mã? Gửi lại'
                                          : 'Có thể gửi lại sau ${_resendCountdown}s',
                                      style: TextStyle(
                                        color:
                                            _canResend && !isLoading
                                                ? AppColors.primaryDark
                                                : Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        decoration:
                                            _canResend && !isLoading
                                                ? TextDecoration.underline
                                                : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Activate button
                                ElevatedButton(
                                  onPressed:
                                      isLoading ? null : _handleActivateAccount,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  child:
                                      isLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : Text(
                                            'Kích hoạt tài khoản',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for decorative circles
class CircleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = AppColors.primary.withValues(alpha: 0.4);

    // Draw large blurred circles with bolder opacity
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      100,
      paint..color = AppColors.primary.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      80,
      paint..color = AppColors.primaryDark.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.7),
      120,
      paint..color = AppColors.primary.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.6),
      90,
      paint..color = AppColors.text.withValues(alpha: 0.4),
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.1),
      70,
      paint..color = AppColors.card.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      85,
      paint..color = AppColors.primaryDark.withValues(alpha: 0.4),
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.9),
      60,
      paint..color = AppColors.text.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
