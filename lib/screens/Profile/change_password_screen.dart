import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/user/user_bloc.dart';
import 'package:heaven_book_app/bloc/user/user_event.dart';
import 'package:heaven_book_app/bloc/user/user_state.dart';
import 'package:heaven_book_app/screens/Auth/login_screen.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/widgets/appbar_custom_widget.dart';
import 'package:heaven_book_app/widgets/textfield_custom_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordValid = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasMinLength = false;
  String _passwordStrengthText = 'Mật khẩu yếu';
  Color _progressBarColor = Colors.grey;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  void _validatePassword(String value) {
    setState(() {
      _hasUppercase = _newPasswordController.text.contains(RegExp(r'[A-Z]'));
      _hasNumber = _newPasswordController.text.contains(RegExp(r'[0-9]'));
      _hasMinLength = _newPasswordController.text.length >= 8;

      int conditionsMet = 0;
      if (_hasUppercase) conditionsMet++;
      if (_hasNumber) conditionsMet++;
      if (_hasMinLength) conditionsMet++;

      switch (conditionsMet) {
        case 0:
          _progressBarColor = Colors.grey;
          _passwordStrengthText = 'Mật khẩu yếu';
          break;
        case 1:
          _progressBarColor = Colors.red;
          _passwordStrengthText = 'Mật khẩu yếu';
          break;
        case 2:
          _progressBarColor = Colors.orange;
          _passwordStrengthText = 'Mật khẩu trung bình';
          break;
        case 3:
          _progressBarColor = Colors.green;
          _passwordStrengthText = 'Mật khẩu mạnh';
          break;
      }

      _isPasswordValid =
          _hasUppercase &&
          _hasNumber &&
          _hasMinLength &&
          _newPasswordController.text == _confirmPasswordController.text &&
          _newPasswordController.text.isNotEmpty;
    });
  }

  void _handlePasswordChange() {
    if (_isPasswordValid) {
      context.read<UserBloc>().add(
        ChangePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          newPasswordConfirmation: _confirmPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is UserLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              //content: Text('Password changed successfully!'),
              content: Text('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          setState(() {
            _isPasswordValid = false;
            _hasUppercase = false;
            _hasNumber = false;
            _hasMinLength = false;
            _passwordStrengthText = 'Mật khẩu yếu';
            _progressBarColor = Colors.grey;
          });

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          }
        }
      },

      child: Scaffold(
        appBar: AppbarCustomWidget(title: ''),
        body: Container(
          height: double.infinity,
          padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.background],
              stops: [0.3, 1],
            ),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12.0,
                      spreadRadius: 2,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(64.0),
                        border: Border.all(color: Colors.black54, width: 4.0),
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 64.0,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Đổi Mật Khẩu',
                      style: TextStyle(
                        fontSize: 28.0,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 4),
                            blurRadius: 4.0,
                            color: Colors.black26.withValues(alpha: 0.2),
                          ),
                        ],
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      //'Update your password to keep your account secure',
                      'Cập nhật mật khẩu của bạn để giữ an toàn cho tài khoản',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.0, color: Colors.black54),
                    ),
                    SizedBox(height: 32.0),
                    LabelTextField(
                      //label: 'Current Password',
                      label: 'Mật khẩu hiện tại',
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.black60,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    LabelTextField(
                      //label: 'New Password',
                      label: 'Mật khẩu mới',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      onChanged: _validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.black60,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    LabelTextField(
                      //label: 'Confirm New Password',
                      label: 'Xác nhận mật khẩu mới',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      onChanged: _validatePassword,
                    ),

                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _progressBarColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                _hasUppercase && _hasNumber
                                    ? _progressBarColor
                                    : Colors.grey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                _hasUppercase && _hasNumber && _hasMinLength
                                    ? _progressBarColor
                                    : Colors.grey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _passwordStrengthText,
                            style: TextStyle(
                              color: _progressBarColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          _hasUppercase ? Icons.check_circle : Icons.close,
                          color: _hasUppercase ? Colors.green : Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        //Text('At least 1 uppercase'),
                        Text('Ít nhất 1 chữ cái in hoa'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          _hasNumber ? Icons.check_circle : Icons.close,
                          color: _hasNumber ? Colors.green : Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        //Text('At least 1 number'),
                        Text('Ít nhất 1 chữ số'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          _hasMinLength ? Icons.check_circle : Icons.close,
                          color: _hasMinLength ? Colors.green : Colors.grey,
                        ),
                        SizedBox(width: 8.0),
                        //Text('At least 8 characters'),
                        Text('Ít nhất 8 ký tự'),
                      ],
                    ),
                    SizedBox(height: 32.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isPasswordValid ? _handlePasswordChange : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: Text(
                          //'Change',
                          'Đổi Mật Khẩu',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
